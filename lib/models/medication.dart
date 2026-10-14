import 'medication_price.dart';

enum ReimbursementStatus {
  none,
  basic,
  supplementary,
}

enum MedicationMarketState {
  marketed,
  notMarketed,
  temporaryInterruption,
  unknown,
}

enum MedicationShortageState {
  reported,
  noneReported,
  unknown,
}

class Medication {
  const Medication({
    required this.id,
    required this.name,
    required this.activeIngredient,
    required this.strength,
    required this.form,
    required this.category,
    required this.requiresPrescription,
    required this.summary,
    required this.uses,
    required this.dosageGuidance,
    required this.sideEffects,
    required this.warnings,
    required this.sourceLabel,
    required this.lastReviewed,
    this.atcCode,
    this.authorizationNumber,
    this.marketingAuthorizationHolder,
    this.manufacturer,
    this.localRepresentative,
    this.route,
    this.packageDescription,
    this.dispensingStatus,
    this.prescribingMode,
    this.dispensingPlace,
    this.marketStatus,
    this.reimbursementStatus = ReimbursementStatus.none,
    this.hzzoGuidelineCode,
    this.hzzoListSource,
    this.hzzoListEffectiveDate,
    this.prices = const [],
    this.smpcUrl,
    this.patientLeafletUrl,
    this.officialRecordUrl,
    this.shortageStatus,
  });

  final String id;
  final String name;
  final String activeIngredient;
  final String strength;
  final String form;
  final String category;
  final bool? requiresPrescription;
  final String summary;
  final List<String> uses;
  final String dosageGuidance;
  final List<String> sideEffects;
  final List<String> warnings;
  final String sourceLabel;
  final DateTime lastReviewed;

  final String? atcCode;
  final String? authorizationNumber;
  final String? marketingAuthorizationHolder;
  final String? manufacturer;
  final String? localRepresentative;
  final String? route;
  final String? packageDescription;
  final String? dispensingStatus;
  final String? prescribingMode;
  final String? dispensingPlace;
  final String? marketStatus;
  final ReimbursementStatus reimbursementStatus;
  final String? hzzoGuidelineCode;
  /// Source for a confirmed HZZO list match, never an inferred policy.
  final String? hzzoListSource;
  /// Effective date of the matched published list, when provided by HZZO.
  final DateTime? hzzoListEffectiveDate;
  final List<MedicationPrice> prices;
  final String? smpcUrl;
  final String? patientLeafletUrl;
  final String? officialRecordUrl;
  final String? shortageStatus;

  static bool _hasUsefulValue(String value) {
    final normalized = value.trim().toLowerCase();
    return normalized.isNotEmpty &&
        normalized != 'nije navedeno' &&
        normalized != 'nepoznato' &&
        normalized != 'doza' &&
        normalized != 'lijek';
  }

  String? get compactSubtitle {
    final parts = <String>[
      if (_hasUsefulValue(strength)) strength.trim(),
      if (_hasUsefulValue(form) &&
          form.trim().toLowerCase() != strength.trim().toLowerCase())
        form.trim(),
    ];
    return parts.isEmpty ? null : parts.join(' · ');
  }

  String get subtitle =>
      compactSubtitle ?? 'Podaci o pakiranju nisu dostupni';

  String get dispensingLabel {
    // The original text is retained in the professional metadata, but it
    // must not be advertised as confirmed when the source is ambiguous.
    if (requiresPrescription == null) {
      return 'Način izdavanja nije potvrđen';
    }
    final raw = dispensingStatus?.trim();
    if (raw != null && raw.isNotEmpty) return raw;
    return requiresPrescription! ? 'na recept' : 'bez recepta';
  }

  MedicationMarketState get marketState {
    final normalized = (marketStatus ?? '').trim().toLowerCase();
    if (normalized.isEmpty || normalized == '-') {
      return MedicationMarketState.unknown;
    }
    if (normalized.contains('privremeni prekid')) {
      return MedicationMarketState.temporaryInterruption;
    }
    if (normalized.contains('nije stavljeno u promet')) {
      return MedicationMarketState.notMarketed;
    }
    if (normalized.contains('stavljeno u promet')) {
      return MedicationMarketState.marketed;
    }
    return MedicationMarketState.unknown;
  }

  MedicationShortageState get shortageState {
    final normalized = (shortageStatus ?? '').trim().toLowerCase();
    if (normalized.isEmpty || normalized == '-') {
      return MedicationShortageState.unknown;
    }
    if (normalized.contains('nema nestašice')) {
      return MedicationShortageState.noneReported;
    }
    if (normalized.contains('nestašic')) {
      return MedicationShortageState.reported;
    }
    return MedicationShortageState.unknown;
  }

  bool get isOnHzzoList =>
      reimbursementStatus == ReimbursementStatus.basic ||
      reimbursementStatus == ReimbursementStatus.supplementary;

  MedicationPrice? get hzzoCopay {
    for (final price in prices) {
      if (price.kind == MedicationPriceKind.hzzoCopay) {
        return price;
      }
    }
    return null;
  }

  MedicationPrice? get maxWholesalePrice {
    for (final price in prices) {
      if (price.kind == MedicationPriceKind.maxWholesale) {
        return price;
      }
    }
    return null;
  }

  Medication copyWith({
    String? id,
    String? name,
    String? activeIngredient,
    String? strength,
    String? form,
    String? category,
    bool? requiresPrescription,
    bool clearPrescriptionStatus = false,
    String? summary,
    List<String>? uses,
    String? dosageGuidance,
    List<String>? sideEffects,
    List<String>? warnings,
    String? sourceLabel,
    DateTime? lastReviewed,
    String? atcCode,
    String? authorizationNumber,
    String? marketingAuthorizationHolder,
    String? manufacturer,
    String? localRepresentative,
    String? route,
    String? packageDescription,
    String? dispensingStatus,
    String? prescribingMode,
    String? dispensingPlace,
    String? marketStatus,
    ReimbursementStatus? reimbursementStatus,
    String? hzzoGuidelineCode,
    String? hzzoListSource,
    DateTime? hzzoListEffectiveDate,
    List<MedicationPrice>? prices,
    String? smpcUrl,
    String? patientLeafletUrl,
    String? officialRecordUrl,
    String? shortageStatus,
  }) {
    return Medication(
      id: id ?? this.id,
      name: name ?? this.name,
      activeIngredient: activeIngredient ?? this.activeIngredient,
      strength: strength ?? this.strength,
      form: form ?? this.form,
      category: category ?? this.category,
      requiresPrescription: clearPrescriptionStatus
          ? null
          : (requiresPrescription ?? this.requiresPrescription),
      summary: summary ?? this.summary,
      uses: uses ?? this.uses,
      dosageGuidance: dosageGuidance ?? this.dosageGuidance,
      sideEffects: sideEffects ?? this.sideEffects,
      warnings: warnings ?? this.warnings,
      sourceLabel: sourceLabel ?? this.sourceLabel,
      lastReviewed: lastReviewed ?? this.lastReviewed,
      atcCode: atcCode ?? this.atcCode,
      authorizationNumber:
          authorizationNumber ?? this.authorizationNumber,
      marketingAuthorizationHolder:
          marketingAuthorizationHolder ?? this.marketingAuthorizationHolder,
      manufacturer: manufacturer ?? this.manufacturer,
      localRepresentative:
          localRepresentative ?? this.localRepresentative,
      route: route ?? this.route,
      packageDescription:
          packageDescription ?? this.packageDescription,
      dispensingStatus: dispensingStatus ?? this.dispensingStatus,
      prescribingMode: prescribingMode ?? this.prescribingMode,
      dispensingPlace: dispensingPlace ?? this.dispensingPlace,
      marketStatus: marketStatus ?? this.marketStatus,
      reimbursementStatus:
          reimbursementStatus ?? this.reimbursementStatus,
      hzzoGuidelineCode: hzzoGuidelineCode ?? this.hzzoGuidelineCode,
      hzzoListSource: hzzoListSource ?? this.hzzoListSource,
      hzzoListEffectiveDate:
          hzzoListEffectiveDate ?? this.hzzoListEffectiveDate,
      prices: prices ?? this.prices,
      smpcUrl: smpcUrl ?? this.smpcUrl,
      patientLeafletUrl: patientLeafletUrl ?? this.patientLeafletUrl,
      officialRecordUrl: officialRecordUrl ?? this.officialRecordUrl,
      shortageStatus: shortageStatus ?? this.shortageStatus,
    );
  }
}
