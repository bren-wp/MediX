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
      throw const FormatException('Neispravan format službenog kataloga.');
    }

    final source = decoded['source'];
    final sourceMap = source is Map<String, dynamic>
        ? source
        : <String, dynamic>{};
    final sourceName =
        sourceMap['name']?.toString() ?? 'Službeni izvor';
    final sourceUrl = sourceMap['url']?.toString();
    final effectiveDate = DateTime.tryParse(
          sourceMap['effective_date']?.toString() ?? '',
        ) ??
        DateTime(2026, 10, 1);

    final rawRecords = decoded['records'];
    if (rawRecords is! List || rawRecords.isEmpty) {
      throw const FormatException('Službeni katalog nema zapisa.');
    }

    final medications = <Medication>[];

    for (final rawRecord in rawRecords) {
      if (rawRecord is! Map) {
        continue;
      }

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
            note:
                'Doplata za originalno pakiranje prema HZZO zapisu; nije maloprodajna cijena ljekarne.',
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
          category:
              record['category']?.toString().trim().isNotEmpty == true
                  ? record['category'].toString().trim()
                  : 'Ostali lijekovi',
          requiresPrescription:
              _requiresPrescription(record['rx_status']?.toString()),
          summary:
              'Službeni administrativni zapis lijeka iz HZZO kataloga. Kliničke informacije poput indikacija, kontraindikacija, nuspojava i potpunog doziranja moraju biti povezane s regulatornom dokumentacijom konkretnog lijeka.',
          uses: const [],
          dosageGuidance:
              'Za doziranje provjerite službenu uputu konkretnog lijeka ili se obratite liječniku odnosno ljekarniku.',
          sideEffects: const [],
          warnings: const [
            'Podaci HZZO liste nisu zamjena za službenu uputu o lijeku.',
          ],
          sourceLabel: sourceUrl == null
              ? sourceName
              : '$sourceName — $sourceUrl',
          lastReviewed: effectiveDate,
          atcCode: _nullableString(record['atc_code']),
          marketingAuthorizationHolder:
              _nullableString(record['holder']),
          route: _nullableString(record['route']),
          packageDescription: _nullableString(record['package']),
          reimbursementStatus: reimbursementStatus,
          hzzoGuidelineCode:
              _nullableString(record['guideline']),
          prices: prices,
          officialRecordUrl: sourceUrl,
          isDemo: false,
        ),
      );
    }

    if (medications.isEmpty) {
      throw const FormatException(
        'Službeni katalog ne sadrži valjane zapise.',
      );
    }

    return MedicationRepository(
      medications: medications,
      interactions: const [],
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

  static bool _requiresPrescription(String? value) {
    final normalized = value?.toUpperCase().trim() ?? '';
    if (normalized.isEmpty) return false;
    return normalized.startsWith('R') ||
        normalized.contains('RECEPT');
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
