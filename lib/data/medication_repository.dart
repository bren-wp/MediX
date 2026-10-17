import 'dart:convert';

import 'dispensing_status_parser.dart';
import 'official_price_validation.dart';
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
    final publishedEffectiveDate = OfficialPriceValidation.officialDate(
      sourceMap['effective_date'],
    );
    // Absence of a source date must not fabricate a dated HZZO copayment.
    final effectiveDate = publishedEffectiveDate ??
        DateTime.tryParse(decoded['generated_at']?.toString() ?? '') ??
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

      final basicList = _asBool(record['basic_list']);
      final supplementaryList = _asBool(record['supplementary_list']);
      // The lists are mutually exclusive for a specific product record.
      // Simultaneously claiming both lists is contradictory, not evidence
      // that the basic list should win.
      final reimbursementStatus = basicList == supplementaryList
          ? ReimbursementStatus.none
          : basicList
              ? ReimbursementStatus.basic
              : ReimbursementStatus.supplementary;
      final copay = OfficialPriceValidation.euro(record['copay_eur']);
      final prices = <MedicationPrice>[
        if (reimbursementStatus == ReimbursementStatus.supplementary &&
            copay != null &&
            publishedEffectiveDate != null)
          MedicationPrice(
            amount: copay,
            currency: 'EUR',
            kind: MedicationPriceKind.hzzoCopay,
            source: sourceName,
            validFrom: publishedEffectiveDate,
            note: 'Doplata za originalno pakiranje.',
          ),
      ];

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
              DispensingStatusParser.requiresPrescription(
                record['rx_status']?.toString(),
              ),
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
          hzzoListSource: reimbursementStatus != ReimbursementStatus.none
              ? sourceName
              : null,
          hzzoListEffectiveDate:
              reimbursementStatus != ReimbursementStatus.none
                  ? publishedEffectiveDate
                  : null,
          prices: prices,
          officialRecordUrl: sourceUrl,
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
              DispensingStatusParser.requiresPrescription(
                record['rx_status']?.toString(),
              ),
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
          smpcUrl: _nullableString(record['smpc_url']),
          patientLeafletUrl:
              _nullableString(record['patient_leaflet_url']),
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
    // Index trade-name prefixes once. The previous startup compared each
    // HZZO/price row against every HALMED medicine, causing tens of millions
    // of synchronous comparisons and Android startup stalls.
    final matchIndex = _MedicineMatchIndex(medications);

    _mergeReimbursementCatalog(
      medications,
      reimbursementJson,
      matchIndex,
    );
    _mergePriceCatalog(
      medications,
      priceJson,
      matchIndex,
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
    _MedicineMatchIndex matchIndex,
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
        matchIndex: matchIndex,
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
        hzzoListSource: incoming.reimbursementStatus !=
                ReimbursementStatus.none
            ? incoming.hzzoListSource
            : null,
        hzzoListEffectiveDate: incoming.reimbursementStatus !=
                ReimbursementStatus.none
            ? incoming.hzzoListEffectiveDate
            : null,
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
    _MedicineMatchIndex matchIndex,
  ) {
    // Wholesale catalog is optional enrichment, not an app startup gate.
    // Malformed snapshots must not crash the main HALMED medicine catalog.
    Map<String, dynamic> decoded;
    try {
      final value = jsonDecode(rawJson);
      if (value is! Map<String, dynamic>) return;
      decoded = value;
    } on FormatException {
      return;
    }

    final source = decoded['source'];
    final sourceMap = source is Map<String, dynamic>
        ? source
        : <String, dynamic>{};
    final sourceName =
        sourceMap['name']?.toString() ?? 'price-catalog';
    final publishedDate = OfficialPriceValidation.officialDate(
      sourceMap['published_date'],
    );
    // A price without its actual source date has unknown validity; never
    // fabricate a publication date and present it as a verified price.
    if (publishedDate == null) return;
    final currency = sourceMap['currency']?.toString().trim().toUpperCase();
    if (currency != null && currency.isNotEmpty && currency != 'EUR') {
      return;
    }

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
      final price = OfficialPriceValidation.euro(record['max_wholesale_eur']);
      final recordCurrency =
          record['currency']?.toString().trim().toUpperCase();
      if (recordCurrency != null &&
          recordCurrency.isNotEmpty &&
          recordCurrency != 'EUR') {
        continue;
      }

      if (name.isEmpty || price == null) {
        continue;
      }

      final index = _findBestMatch(
        medications,
        name: name,
        activeIngredient: active,
        atcCode: atc,
        strengthOrPackage: package,
        holder: _nullableString(record['holder']),
        matchIndex: matchIndex,
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
    required _MedicineMatchIndex matchIndex,
  }) {
    final incomingName = _normalize(name);
    final incomingActive = _normalize(activeIngredient);
    final incomingAtc = _normalize(atcCode ?? '');
    final incomingStrength = _normalize(
      _extractStrength(strengthOrPackage),
    );
    final incomingPackCount = _extractPackCount(strengthOrPackage);
    final incomingHolder = _normalize(holder ?? '');

    // A matching trade name or ATC alone is not a valid package identity.
    // Without an explicit ingredient, strength and pack unit count from
    // the secondary source, the attachment must remain unverified.
    if (incomingName.isEmpty ||
        incomingActive.isEmpty ||
        incomingStrength.isEmpty ||
        incomingPackCount == null) {
      return null;
    }

    int? bestIndex;
    var bestScore = -1;
    var bestCount = 0;

    // All valid prefix/equality matches share the first normalized name
    // token. Search that bounded bucket, then preserve the full strict
    // strength/pack/ingredient/ATC and ambiguity checks unchanged.
    for (final i in matchIndex.candidates(incomingName)) {
      final candidate = medications[i];

      // Most catalog entries do not share a trade name. Reject them
      // before parsing pharmaceutical strengths and package quantities.
      final candidateName = _normalize(candidate.name);
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

      final candidateAtc = _normalize(candidate.atcCode ?? '');
      if (incomingAtc.isNotEmpty &&
          candidateAtc.isNotEmpty &&
          incomingAtc != candidateAtc) {
        continue;
      }

      final candidateActive = _normalize(candidate.activeIngredient);
      // Identical brand/strength/ATC is not enough when active ingredients
      // disagree (especially for combination medicines).
      if (candidateActive.isEmpty || incomingActive != candidateActive) {
        continue;
      }
      final candidateHolder = _normalize(
        candidate.marketingAuthorizationHolder ?? '',
      );
      final candidateDescription = [
        candidate.strength,
        candidate.packageDescription ?? '',
        candidate.name,
      ].join(' ');
      final candidateStrength = _normalize(
        _extractStrength(candidateDescription),
      );
      final candidatePackCount =
          _extractPackCount(candidate.packageDescription ?? '');

      // Never transfer the copayment or package price across different
      // strengths or known package quantities. A name/ATC match alone
      // is insufficient evidence for a price tied to a specific pack.
      if (incomingStrength != candidateStrength ||
          incomingPackCount != candidatePackCount) {
        continue;
      }

      if (incomingAtc.isNotEmpty &&
          candidateAtc == incomingAtc) {
        score += 4;
      }

      score += 4; // Identical active ingredient is mandatory above.

      if (incomingStrength.isNotEmpty &&
          incomingStrength == candidateStrength) {
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

  /// Extract a clearly expressed count of dosage units in a pack.
  ///
  /// Unknown packaging is left unmatched; never infer a tablet count
  /// from a strength, volume or authorization number.
  static String? _extractPackCount(String description) {
    final normalized = _normalize(description);
    final match = RegExp(
      r'\b(\d{1,4})\s*(?:tableta|tablete|tableti|tbl|kapsula|kapsule|'
      r'caps|ampula|ampule|cepica|flastera|flasteri|vrecica|vrecice|'
      r'bočica|bocica|bocice|komada|kom)\b',
    ).firstMatch(normalized);
    return match?.group(1);
  }

  static String _extractStrength(String package) {
    final match = RegExp(
      r'(\d+(?:[.,]\d+)?\s*(?:mg|g|µg|mcg|ml|mmol|IU|i\.j\.|%)(?:\s*/\s*\d+(?:[.,]\d+)?\s*(?:ml|g))?)',
      caseSensitive: false,
    ).firstMatch(package);
    return match?.group(1)?.trim() ?? '';
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

/// Read-only index over stable HALMED medicine names used by both enrichment
/// passes. Copy-with enrichment never changes trade names, so indices remain
/// valid after attaching price or reimbursement data.
class _MedicineMatchIndex {
  _MedicineMatchIndex(List<Medication> medications) {
    for (var i = 0; i < medications.length; i++) {
      final normalized = MedicationRepository._normalize(medications[i].name);
      if (normalized.isEmpty) continue;
      _byFirstNameToken.putIfAbsent(
        _firstToken(normalized),
        () => <int>[],
      ).add(i);
    }
  }

  final Map<String, List<int>> _byFirstNameToken = <String, List<int>>{};

  Iterable<int> candidates(String normalizedName) =>
      _byFirstNameToken[_firstToken(normalizedName)] ?? const <int>[];

  static String _firstToken(String normalizedName) =>
      normalizedName.split(' ').first;
}
