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

  factory MedicationRepository.fromHalmedJson(String rawJson) {
    final decoded = jsonDecode(rawJson);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Neispravan HALMED katalog lijekova.');
    }

    final source = decoded['source'];
    final sourceMap = source is Map<String, dynamic>
        ? source
        : <String, dynamic>{};
    final sourceName =
        sourceMap['name']?.toString() ?? 'HALMED Baza lijekova';
    final sourceUrl = sourceMap['url']?.toString();
    final reviewed = DateTime.tryParse(
          decoded['generated_at']?.toString() ?? '',
        ) ??
        DateTime(2026, 10, 2);

    final rawRecords = decoded['records'];
    if (rawRecords is! List || rawRecords.isEmpty) {
      throw const FormatException('HALMED katalog nema zapisa.');
    }

    final medications = <Medication>[];
    for (final rawRecord in rawRecords) {
      if (rawRecord is! Map) continue;
      final record = Map<String, dynamic>.from(rawRecord);

      if (!_isValidHumanMedicineRecord(record)) {
        continue;
      }

      final id = record['id']?.toString().trim() ?? '';
      final name = record['name']?.toString().trim() ?? '';
      final approval =
          record['authorization_number']?.toString().trim() ?? '';
      final active =
          record['active_ingredient']?.toString().trim() ?? '';
      final form = record['form']?.toString().trim() ?? '';
      final strength = record['strength']?.toString().trim() ?? '';
      final atc = _nullableString(record['atc_code']);

      medications.add(
        Medication(
          id: id,
          name: name,
          activeIngredient: active,
          strength: strength,
          form: form,
          category:
              record['category']?.toString().trim().isNotEmpty ==
                      true
                  ? record['category'].toString().trim()
                  : _categoryForAtc(atc),
          requiresPrescription:
              _requiresPrescription(record['rx_status']?.toString()),
          summary:
              'Podaci o registriranom lijeku i pakiranju dostupni su u lokalnom MediX katalogu.',
          uses: const [],
          dosageGuidance:
              'Doziranje se mora provjeriti za konkretni lijek, jačinu i farmaceutski oblik.',
          sideEffects: const [],
          warnings: const [],
          sourceLabel: sourceName,
          lastReviewed: reviewed,
          atcCode: atc,
          authorizationNumber: approval,
          marketingAuthorizationHolder:
              _nullableString(record['holder']),
          manufacturer:
              _nullableString(record['manufacturer']),
          localRepresentative:
              _nullableString(record['local_representative']),
          packageDescription:
              _nullableString(record['package']),
          dispensingStatus:
              _nullableString(record['rx_status']),
          prescribingMode:
              _nullableString(record['prescribing_mode']),
          dispensingPlace:
              _nullableString(record['dispensing_place']),
          marketStatus:
              _nullableString(record['market_status']),
          reimbursementStatus: ReimbursementStatus.none,
          prices: const [],
          officialRecordUrl:
              _nullableString(record['official_record_url']) ??
                  sourceUrl,
          shortageStatus:
              _nullableString(record['shortage_status']),
          isDemo: false,
        ),
      );
    }

    if (medications.isEmpty) {
      throw const FormatException(
        'HALMED katalog ne sadrži valjane lijekove.',
      );
    }

    medications.sort(
      (a, b) =>
          a.name.toLowerCase().compareTo(b.name.toLowerCase()),
    );

    return MedicationRepository(
      medications: medications,
      interactions: const [],
    );
  }

  factory MedicationRepository.fromBundledCatalogs({
    required String halmedJson,
    required String reimbursementJson,
    required String priceJson,
  }) {
    final base = MedicationRepository.fromHalmedJson(halmedJson);
    final medications = List<Medication>.from(base.medications);

    _mergeReimbursementCatalog(
      medications,
      reimbursementJson,
    );
    _mergePriceCatalog(
      medications,
      priceJson,
    );

    medications.sort(
      (a, b) =>
          a.name.toLowerCase().compareTo(b.name.toLowerCase()),
    );

    return MedicationRepository(
      medications: medications,
      interactions: base.interactions,
    );
  }

  static void _mergeReimbursementCatalog(
    List<Medication> medications,
    String rawJson,
  ) {
    MedicationRepository reimbursement;
    try {
      reimbursement =
          MedicationRepository.fromOfficialJson(rawJson);
    } on FormatException {
      return;
    }

    for (final incoming in reimbursement.medications) {
      final index = _findBestMatch(
        medications,
        name: incoming.name,
        activeIngredient: incoming.activeIngredient,
        atcCode: incoming.atcCode,
        strengthOrPackage: [
          incoming.strength,
          incoming.packageDescription ?? '',
        ].join(' '),
        holder: incoming.marketingAuthorizationHolder,
      );
      if (index == null) continue;

      final existing = medications[index];
      final mergedPrices = <MedicationPrice>[
        ...existing.prices,
      ];
      for (final price in incoming.prices) {
        final duplicate = mergedPrices.any(
          (item) =>
              item.kind == price.kind &&
              item.amount == price.amount,
        );
        if (!duplicate) mergedPrices.add(price);
      }

      medications[index] = existing.copyWith(
        reimbursementStatus: incoming.reimbursementStatus,
        hzzoGuidelineCode: incoming.hzzoGuidelineCode,
        prices: mergedPrices,
        route: existing.route ?? incoming.route,
        packageDescription:
            existing.packageDescription ??
                incoming.packageDescription,
        lastReviewed:
            existing.lastReviewed.isAfter(incoming.lastReviewed)
                ? existing.lastReviewed
                : incoming.lastReviewed,
      );
    }
  }

  static void _mergePriceCatalog(
    List<Medication> medications,
    String rawJson,
  ) {
    final decoded = jsonDecode(rawJson);
    if (decoded is! Map<String, dynamic>) return;

    final source = decoded['source'];
    final sourceMap = source is Map<String, dynamic>
        ? source
        : <String, dynamic>{};
    final sourceName =
        sourceMap['name']?.toString() ?? 'price-catalog';
    final publishedDate = DateTime.tryParse(
          sourceMap['published_date']?.toString() ?? '',
        ) ??
        DateTime(2026, 6, 18);

    final rawRecords = decoded['records'];
    if (rawRecords is! List || rawRecords.isEmpty) return;

    for (final rawRecord in rawRecords) {
      if (rawRecord is! Map) continue;
      final record = Map<String, dynamic>.from(rawRecord);

      final name = record['name']?.toString().trim() ?? '';
      final active =
          record['active_ingredient']?.toString().trim() ?? '';
      final atc = _nullableString(record['atc_code']);
      final package =
          _nullableString(record['name_and_package']) ?? '';
      final price = _asDouble(record['max_wholesale_eur']);

      if (name.isEmpty || price == null) continue;

      final index = _findBestMatch(
        medications,
        name: name,
        activeIngredient: active,
        atcCode: atc,
        strengthOrPackage: package,
        holder: _nullableString(record['holder']),
      );
      if (index == null) {
        // A secondary source can enrich an existing HALMED medicine,
        // but it is never allowed to create a medicine identity.
        continue;
      }

      final existing = medications[index];
      final maxPrice = MedicationPrice(
        amount: price,
        currency: 'EUR',
        kind: MedicationPriceKind.maxWholesale,
        source: sourceName,
        validFrom: publishedDate,
        note: 'Najviša evidentirana cijena za navedeno pakiranje.',
      );

      final mergedPrices = <MedicationPrice>[
        ...existing.prices,
        if (existing.prices.every(
          (item) =>
              item.kind != MedicationPriceKind.maxWholesale ||
              item.amount != maxPrice.amount,
        ))
          maxPrice,
      ];

      medications[index] = existing.copyWith(
        prices: mergedPrices,
        localRepresentative:
            existing.localRepresentative ??
                _nullableString(record['local_representative']),
        lastReviewed:
            existing.lastReviewed.isAfter(publishedDate)
                ? existing.lastReviewed
                : publishedDate,
      );
    }
  }

  static int? _findBestMatch(
    List<Medication> medications, {
    required String name,
    required String activeIngredient,
    required String? atcCode,
    required String strengthOrPackage,
    required String? holder,
  }) {
    final incomingName = _normalize(name);
    final incomingActive = _normalize(activeIngredient);
    final incomingAtc = _normalize(atcCode ?? '');
    final incomingStrength = _normalize(
      _extractStrength(strengthOrPackage),
    );
    final incomingHolder = _normalize(holder ?? '');

    int? bestIndex;
    var bestScore = -1;
    var bestCount = 0;

    for (var i = 0; i < medications.length; i++) {
      final candidate = medications[i];
      final candidateAtc = _normalize(candidate.atcCode ?? '');

      if (incomingAtc.isNotEmpty &&
          candidateAtc.isNotEmpty &&
          incomingAtc != candidateAtc) {
        continue;
      }

      final candidateName = _normalize(candidate.name);
      final candidateActive =
          _normalize(candidate.activeIngredient);
      final candidateHolder = _normalize(
        candidate.marketingAuthorizationHolder ?? '',
      );
      final candidateStrength = _normalize(
        [
          candidate.strength,
          candidate.packageDescription ?? '',
          candidate.name,
        ].join(' '),
      );

      var score = 0;

      if (incomingName.isNotEmpty) {
        if (candidateName == incomingName) {
          score += 8;
        } else if (candidateName.startsWith('$incomingName ') ||
            incomingName.startsWith('$candidateName ')) {
          score += 6;
        } else {
          continue;
        }
      }

      if (incomingAtc.isNotEmpty &&
          candidateAtc == incomingAtc) {
        score += 4;
      }

      if (incomingActive.isNotEmpty &&
          candidateActive == incomingActive) {
        score += 4;
      }

      if (incomingStrength.isNotEmpty &&
          candidateStrength.contains(incomingStrength)) {
        score += 3;
      }

      if (incomingHolder.isNotEmpty &&
          candidateHolder.isNotEmpty &&
          (candidateHolder.contains(incomingHolder) ||
              incomingHolder.contains(candidateHolder))) {
        score += 1;
      }

      if (score > bestScore) {
        bestScore = score;
        bestIndex = i;
        bestCount = 1;
      } else if (score == bestScore) {
        bestCount++;
      }
    }

    if (bestIndex == null || bestScore < 6 || bestCount != 1) {
      return null;
    }
    return bestIndex;
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

  static bool _isValidHumanMedicineRecord(
    Map<String, dynamic> record,
  ) {
    final id = _nullableString(record['id']);
    final name = _nullableString(record['name']);
    final approval = _nullableString(record['authorization_number']);
    if (id == null || name == null || approval == null) return false;

    final normalizedName = _normalize(name);
    final holder = _normalize(record['holder']?.toString() ?? '');
    final manufacturer =
        _normalize(record['manufacturer']?.toString() ?? '');

    if (normalizedName == holder && holder.isNotEmpty) return false;
    if (normalizedName == manufacturer && manufacturer.isNotEmpty) {
      return false;
    }

    const technicalNames = {
      'naziv',
      'naziv lijeka',
      'proizvodac',
      'nositelj odobrenja',
      'nije navedeno',
      'nepoznato',
    };
    if (technicalNames.contains(normalizedName)) return false;
    if (_looksLikeLegalEntity(name)) return false;

    final evidence = [
      record['active_ingredient'],
      record['form'],
      record['atc_code'],
      record['package'],
      record['rx_status'],
    ].any((value) => _nullableString(value) != null);
    return evidence;
  }

  static bool _looksLikeLegalEntity(String value) {
    final normalized = _normalize(value);
    return RegExp(
      r'\b(?:d o o|d d|j d o o|obrt|ustanova|limited|ltd|gmbh|s a|b v)\b',
    ).hasMatch(normalized);
  }

  static bool? _requiresPrescription(String? value) {
    final normalized = value?.toUpperCase().trim() ?? '';
    if (normalized.isEmpty) return null;
    if (normalized.contains('BEZ RECEPTA') ||
        normalized == 'BR' ||
        normalized.startsWith('BR ')) {
      return false;
    }
    if (normalized.contains('NA RECEPT') ||
        normalized == 'R' ||
        normalized.startsWith('R/')) {
      return true;
    }
    if (normalized == 'RS' || normalized.startsWith('RS ')) {
      return true;
    }
    return null;
  }

  static String _normalize(String value) {
    return value
        .toLowerCase()
        .replaceAll('č', 'c')
        .replaceAll('ć', 'c')
        .replaceAll('ž', 'z')
        .replaceAll('š', 's')
        .replaceAll('đ', 'd')
        .replaceAll(RegExp(r'[^a-z0-9%]+'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  static String _categoryForAtc(String? atc) {
    final first = (atc ?? '').trim().toUpperCase();
    if (first.isEmpty) return 'Neklasificirano';

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
      'V' => 'Razni pripravci (ATK V)',
      _ => 'Neklasificirano',
    };
  }

  static String _extractStrength(String package) {
    final match = RegExp(
      r'(\d+(?:[.,]\d+)?\s*(?:mg|g|µg|mcg|ml|mmol|IU|i\.j\.|%)(?:\s*/\s*\d+(?:[.,]\d+)?\s*(?:ml|g))?)',
      caseSensitive: false,
    ).firstMatch(package);
    return match?.group(1)?.trim() ?? '';
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
