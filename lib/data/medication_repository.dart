import 'dart:convert';

import '../models/drug_interaction.dart';
import '../models/medication.dart';
import '../models/medication_price.dart';

class MedicationRepository {
  const MedicationRepository({
    required this.medications,
    required this.interactions,
  });

  final List<Medication> medications;
  final List<DrugInteraction> interactions;

  factory MedicationRepository.fromOfficialJson(String rawJson) {
    final decoded = jsonDecode(rawJson);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Neispravan format kataloga lijekova.');
    }

    final source = decoded['source'];
    final sourceMap = source is Map<String, dynamic>
        ? source
        : <String, dynamic>{};
    final sourceName = sourceMap['name']?.toString() ?? 'catalog';
    final sourceUrl = sourceMap['url']?.toString();
    final effectiveDate = DateTime.tryParse(
          sourceMap['effective_date']?.toString() ?? '',
        ) ??
        DateTime(2026, 10, 1);

    final rawRecords = decoded['records'];
    if (rawRecords is! List || rawRecords.isEmpty) {
      throw const FormatException('Katalog lijekova nema zapisa.');
    }

    final medications = <Medication>[];

    for (final rawRecord in rawRecords) {
      if (rawRecord is! Map) continue;
      final record = Map<String, dynamic>.from(rawRecord);

      final id = record['id']?.toString().trim() ?? '';
      final name = record['name']?.toString().trim() ?? '';
      final activeIngredient =
          record['active_ingredient']?.toString().trim() ?? '';

      if (id.isEmpty || name.isEmpty || activeIngredient.isEmpty) {
        continue;
      }

      final copay = _asDouble(record['copay_eur']);
      final prices = <MedicationPrice>[
        if (copay != null)
          MedicationPrice(
            amount: copay,
            currency: 'EUR',
            kind: MedicationPriceKind.hzzoCopay,
            source: sourceName,
            validFrom: effectiveDate,
            note: 'Doplata za originalno pakiranje.',
          ),
      ];

      final basicList = _asBool(record['basic_list']);
      final supplementaryList = _asBool(record['supplementary_list']);
      final reimbursementStatus = basicList
          ? ReimbursementStatus.basic
          : supplementaryList
              ? ReimbursementStatus.supplementary
              : ReimbursementStatus.none;

      final package = record['package']?.toString().trim();
      final form = record['form']?.toString().trim();
      final strength = record['strength']?.toString().trim();

      medications.add(
        Medication(
          id: id,
          name: name,
          activeIngredient: activeIngredient,
          strength: strength == null || strength.isEmpty
              ? (package?.isNotEmpty == true ? package! : 'nije navedeno')
              : strength,
          form: form == null || form.isEmpty ? 'lijek' : form,
          category: record['category']?.toString().trim().isNotEmpty == true
              ? record['category'].toString().trim()
              : _categoryForAtc(record['atc_code']?.toString()),
          requiresPrescription:
              _requiresPrescription(record['rx_status']?.toString()),
          summary:
              'Podaci o lijeku i pakiranju dostupni su u lokalnom MediX katalogu. Kliničke sekcije prikazuju se samo kada su sinkronizirane za konkretni proizvod.',
          uses: const [],
          dosageGuidance:
              'Doziranje treba provjeriti za konkretni lijek i farmaceutski oblik.',
          sideEffects: const [],
          warnings: const [],
          sourceLabel: sourceName,
          lastReviewed: effectiveDate,
          atcCode: _nullableString(record['atc_code']),
          marketingAuthorizationHolder: _nullableString(record['holder']),
          route: _nullableString(record['route']),
          packageDescription: _nullableString(record['package']),
          reimbursementStatus: reimbursementStatus,
          hzzoGuidelineCode: _nullableString(record['guideline']),
          prices: prices,
          officialRecordUrl: sourceUrl,
          isDemo: false,
        ),
      );
    }

    if (medications.isEmpty) {
      throw const FormatException(
        'Katalog ne sadrži valjane zapise.',
      );
    }

    return MedicationRepository(
      medications: medications,
      interactions: const [],
    );
  }

  factory MedicationRepository.fromBundledCatalogs({
    required String reimbursementJson,
    required String priceJson,
  }) {
    final base = MedicationRepository.fromOfficialJson(reimbursementJson);
    final medications = List<Medication>.from(base.medications);

    final decoded = jsonDecode(priceJson);
    if (decoded is! Map<String, dynamic>) {
      return base;
    }

    final source = decoded['source'];
    final sourceMap = source is Map<String, dynamic>
        ? source
        : <String, dynamic>{};
    final sourceName = sourceMap['name']?.toString() ?? 'price-catalog';
    final publishedDate = DateTime.tryParse(
          sourceMap['published_date']?.toString() ?? '',
        ) ??
        DateTime(2026, 6, 18);

    final rawRecords = decoded['records'];
    if (rawRecords is! List || rawRecords.isEmpty) {
      return base;
    }

    final byProduct = <String, int>{};
    for (var i = 0; i < medications.length; i++) {
      final item = medications[i];
      byProduct.putIfAbsent(
        _productKey(item.name, item.activeIngredient, item.atcCode),
        () => i,
      );
    }

    for (final rawRecord in rawRecords) {
      if (rawRecord is! Map) continue;
      final record = Map<String, dynamic>.from(rawRecord);

      final id = record['id']?.toString().trim() ?? '';
      final name = record['name']?.toString().trim() ?? '';
      final active =
          record['active_ingredient']?.toString().trim() ?? '';
      final atc = _nullableString(record['atc_code']);
      final package = _nullableString(record['name_and_package']);
      final price = _asDouble(record['max_wholesale_eur']);

      if (id.isEmpty || name.isEmpty || active.isEmpty) continue;

      final maxPrice = price == null
          ? null
          : MedicationPrice(
              amount: price,
              currency: 'EUR',
              kind: MedicationPriceKind.maxWholesale,
              source: sourceName,
              validFrom: publishedDate,
              note: 'Najviša evidentirana cijena za navedeno pakiranje.',
            );

      final key = _productKey(name, active, atc);
      final existingIndex = byProduct[key];

      if (existingIndex != null) {
        final existing = medications[existingIndex];
        final mergedPrices = <MedicationPrice>[
          ...existing.prices,
          if (maxPrice != null &&
              existing.prices.every(
                (item) =>
                    item.kind != MedicationPriceKind.maxWholesale ||
                    item.amount != maxPrice.amount,
              ))
            maxPrice,
        ];

        medications[existingIndex] = existing.copyWith(
          authorizationNumber:
              _nullableString(record['authorization_number']),
          marketingAuthorizationHolder:
              existing.marketingAuthorizationHolder ??
                  _nullableString(record['holder']),
          packageDescription:
              existing.packageDescription ?? package,
          prices: mergedPrices,
          lastReviewed: existing.lastReviewed.isAfter(publishedDate)
              ? existing.lastReviewed
              : publishedDate,
        );
        continue;
      }

      final strength = _extractStrength(package ?? '');
      medications.add(
        Medication(
          id: id,
          name: name,
          activeIngredient: active,
          strength: strength.isEmpty ? 'nije navedeno' : strength,
          form: _extractForm(package ?? ''),
          category: _categoryForAtc(atc),
          requiresPrescription: null,
          summary:
              'Registrirani lijek u MediX katalogu. Režim izdavanja i kliničke sekcije prikazuju se kada su dostupni za konkretni zapis.',
          uses: const [],
          dosageGuidance:
              'Doziranje treba provjeriti za konkretni lijek i farmaceutski oblik.',
          sideEffects: const [],
          warnings: const [],
          sourceLabel: sourceName,
          lastReviewed: publishedDate,
          atcCode: atc,
          authorizationNumber:
              _nullableString(record['authorization_number']),
          marketingAuthorizationHolder:
              _nullableString(record['holder']),
          packageDescription: package,
          prices: [
            if (maxPrice != null) maxPrice,
          ],
          isDemo: false,
        ),
      );
      byProduct[key] = medications.length - 1;
    }

    medications.sort(
      (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
    );

    return MedicationRepository(
      medications: medications,
      interactions: base.interactions,
    );
  }

  static String? _nullableString(Object? value) {
    final text = value?.toString().trim();
    return text == null || text.isEmpty ? null : text;
  }

  static bool _asBool(Object? value) {
    if (value is bool) return value;
    final text = value?.toString().toLowerCase().trim();
    return text == 'true' || text == 'da' || text == '1';
  }

  static double? _asDouble(Object? value) {
    if (value is num) return value.toDouble();
    final normalized =
        value?.toString().replaceAll(',', '.').trim() ?? '';
    return double.tryParse(normalized);
  }

  static bool? _requiresPrescription(String? value) {
    final normalized = value?.toUpperCase().trim() ?? '';
    if (normalized.isEmpty) return null;
    if (normalized.startsWith('R') || normalized.contains('RECEPT')) {
      return true;
    }
    return false;
  }

  static String _productKey(
    String name,
    String ingredient,
    String? atc,
  ) {
    String normalize(String value) => value
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9čćžšđ]+'), ' ')
        .trim();

    return [
      normalize(name),
      normalize(ingredient),
      normalize(atc ?? ''),
    ].join('|');
  }

  static String _categoryForAtc(String? atc) {
    final first = (atc ?? '').trim().toUpperCase();
    if (first.isEmpty) return 'Ostali lijekovi';

    return switch (first[0]) {
      'A' => 'Probavni sustav i metabolizam',
      'B' => 'Krv i krvotvorni organi',
      'C' => 'Srce i krvožilni sustav',
      'D' => 'Dermatološki lijekovi',
      'G' => 'Mokraćni i spolni sustav',
      'H' => 'Hormonski lijekovi',
      'J' => 'Antiinfektivni lijekovi',
      'L' => 'Antineoplastici i imunomodulatori',
      'M' => 'Mišićno-koštani sustav',
      'N' => 'Živčani sustav',
      'P' => 'Antiparazitici',
      'R' => 'Dišni sustav',
      'S' => 'Osjetila',
      _ => 'Ostali lijekovi',
    };
  }

  static String _extractStrength(String package) {
    final match = RegExp(
      r'(\d+(?:[.,]\d+)?\s*(?:mg|g|µg|mcg|ml|mmol|IU|i\.j\.|%)(?:\s*/\s*\d+(?:[.,]\d+)?\s*(?:ml|g))?)',
      caseSensitive: false,
    ).firstMatch(package);
    return match?.group(1)?.trim() ?? '';
  }

  static String _extractForm(String package) {
    final lower = package.toLowerCase();
    const forms = <String>[
      'tablete',
      'tableta',
      'kapsule',
      'kapsula',
      'sirup',
      'oralna otopina',
      'otopina za injekciju',
      'otopina za infuziju',
      'krema',
      'mast',
      'gel',
      'sprej',
      'kapi',
      'prašak',
      'čepići',
    ];
    for (final form in forms) {
      if (lower.contains(form)) return form;
    }
    return 'lijek';
  }

  factory MedicationRepository.demo() {
    final reviewed = DateTime(2026, 10, 1);

    return MedicationRepository(
      medications: [
        Medication(
          id: 'paracetamol-500',
          name: 'Paracetamol',
          activeIngredient: 'Paracetamol',
          strength: '500 mg',
          form: 'tablete',
          category: 'Protiv bolova i temperature',
          requiresPrescription: false,
          summary:
              'Demo zapis za prikaz strukture podataka o lijeku. Produkcijski sadržaj mora biti vezan uz provjereni službeni izvor.',
          uses: ['Bol', 'Povišena tjelesna temperatura'],
          dosageGuidance:
              'Za doziranje provjerite službenu uputu konkretnog proizvoda ili se obratite liječniku ili ljekarniku.',
          sideEffects: [
            'Moguće nuspojave ovise o konkretnom proizvodu i korisniku.',
          ],
          warnings: [
            'Ne prelaziti dozu navedenu u službenoj uputi proizvoda.',
          ],
          sourceLabel: 'Demo podatak — nije regulatorni izvor',
          lastReviewed: reviewed,
        ),
        Medication(
          id: 'ibuprofen-400',
          name: 'Ibuprofen',
          activeIngredient: 'Ibuprofen',
          strength: '400 mg',
          form: 'tablete',
          category: 'Protiv bolova i upale',
          requiresPrescription: false,
          summary:
              'Demo zapis nesteroidnog protuupalnog lijeka za razvoj korisničkog sučelja.',
          uses: ['Bol', 'Upalna stanja', 'Povišena tjelesna temperatura'],
          dosageGuidance:
              'Doziranje ovisi o proizvodu, dobi i zdravstvenom stanju. Provjerite službenu uputu.',
          sideEffects: [
            'Moguće probavne i druge nuspojave; provjerite službenu uputu.',
          ],
          warnings: [
            'Poseban oprez može biti potreban kod određenih bolesti i drugih terapija.',
          ],
          sourceLabel: 'Demo podatak — nije regulatorni izvor',
          lastReviewed: reviewed,
        ),
        Medication(
          id: 'amoxicillin-500',
          name: 'Amoksicilin',
          activeIngredient: 'Amoksicilin',
          strength: '500 mg',
          form: 'kapsule',
          category: 'Antibiotici',
          requiresPrescription: true,
          summary:
              'Demo zapis antibiotika. Antibiotici se koriste samo prema medicinskoj indikaciji i uputi zdravstvenog stručnjaka.',
          uses: [
            'Određene bakterijske infekcije prema procjeni liječnika',
          ],
          dosageGuidance:
              'Primjenjuje se prema liječničkoj uputi i službenim informacijama konkretnog proizvoda.',
          sideEffects: [
            'Nuspojave ovise o proizvodu i osobi; provjerite službenu uputu.',
          ],
          warnings: [
            'Ne uzimati antibiotik bez odgovarajuće medicinske indikacije.',
          ],
          sourceLabel: 'Demo podatak — nije regulatorni izvor',
          lastReviewed: reviewed,
        ),
        Medication(
          id: 'warfarin',
          name: 'Varfarin',
          activeIngredient: 'Varfarin',
          strength: 'različite jačine',
          form: 'tablete',
          category: 'Antikoagulansi',
          requiresPrescription: true,
          summary:
              'Demo zapis antikoagulansa za razvoj modula interakcija i upozorenja.',
          uses: [
            'Antikoagulantna terapija prema liječničkoj procjeni',
          ],
          dosageGuidance:
              'Dozu individualno određuje zdravstveni stručnjak uz odgovarajuće praćenje.',
          sideEffects: [
            'Krvarenje i druge nuspojave zahtijevaju pažljivo praćenje.',
          ],
          warnings: [
            'Može imati klinički važne interakcije s drugim lijekovima i hranom.',
          ],
          sourceLabel: 'Demo podatak — nije regulatorni izvor',
          lastReviewed: reviewed,
        ),
        Medication(
          id: 'loratadine-10',
          name: 'Loratadin',
          activeIngredient: 'Loratadin',
          strength: '10 mg',
          form: 'tablete',
          category: 'Alergije',
          requiresPrescription: false,
          summary:
              'Demo zapis antihistaminika za razvoj pretrage i kategorija.',
          uses: ['Simptomi određenih alergijskih stanja'],
          dosageGuidance:
              'Provjerite službenu uputu konkretnog proizvoda.',
          sideEffects: [
            'Moguće nuspojave navedene su u službenoj uputi proizvoda.',
          ],
          warnings: [
            'Kod dvojbe se savjetujte s liječnikom ili ljekarnikom.',
          ],
          sourceLabel: 'Demo podatak — nije regulatorni izvor',
          lastReviewed: reviewed,
        ),
        Medication(
          id: 'omeprazole-20',
          name: 'Omeprazol',
          activeIngredient: 'Omeprazol',
          strength: '20 mg',
          form: 'kapsule',
          category: 'Probavni sustav',
          requiresPrescription: false,
          summary: 'Demo zapis za razvoj kategorija i detalja lijeka.',
          uses: [
            'Stanja povezana sa želučanom kiselinom, ovisno o proizvodu i indikaciji',
          ],
          dosageGuidance:
              'Provjerite službenu uputu konkretnog proizvoda.',
          sideEffects: [
            'Moguće nuspojave navedene su u službenoj uputi proizvoda.',
          ],
          warnings: [
            'Dugotrajniju primjenu treba uskladiti sa stručnim savjetom.',
          ],
          sourceLabel: 'Demo podatak — nije regulatorni izvor',
          lastReviewed: reviewed,
        ),
      ],
      interactions: const [
        DrugInteraction(
          firstMedicationId: 'warfarin',
          secondMedicationId: 'ibuprofen-400',
          severity: InteractionSeverity.significant,
          summary:
              'Poznata kombinacija koja može povećati rizik od krvarenja i zahtijeva stručnu procjenu.',
          guidance:
              'Nemojte mijenjati terapiju na temelju aplikacije. Obratite se liječniku ili ljekarniku.',
        ),
      ],
    );
  }

  List<Medication> search(String rawQuery) {
    final query = rawQuery.trim().toLowerCase();
    if (query.isEmpty) {
      return medications;
    }

    return medications.where((medication) {
      final haystack = [
        medication.name,
        medication.activeIngredient,
        medication.category,
        medication.summary,
        medication.atcCode ?? '',
        medication.marketingAuthorizationHolder ?? '',
        medication.manufacturer ?? '',
        medication.packageDescription ?? '',
        ...medication.uses,
      ].join(' ').toLowerCase();

      return haystack.contains(query);
    }).toList();
  }

  List<String> get categories {
    final result = medications.map((item) => item.category).toSet().toList()
      ..sort();
    return result;
  }

  List<Medication> byCategory(String category) {
    return medications.where((item) => item.category == category).toList();
  }

  DrugInteraction? interactionBetween(String firstId, String secondId) {
    if (firstId == secondId) {
      return null;
    }

    for (final interaction in interactions) {
      if (interaction.matches(firstId, secondId)) {
        return interaction;
      }
    }
    return null;
  }
}
