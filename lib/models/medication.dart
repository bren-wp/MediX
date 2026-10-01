import 'medication_price.dart';

enum ReimbursementStatus {
  none,
  basic,
  supplementary,
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
    this.route,
    this.packageDescription,
    this.reimbursementStatus = ReimbursementStatus.none,
    this.hzzoGuidelineCode,
    this.prices = const [],
    this.smpcUrl,
    this.patientLeafletUrl,
    this.officialRecordUrl,
    this.shortageStatus,
    this.isDemo = true,
  });

  final String id;
  final String name;
  final String activeIngredient;
  final String strength;
  final String form;
  final String category;
  final bool requiresPrescription;
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
  final String? route;
  final String? packageDescription;
  final ReimbursementStatus reimbursementStatus;
  final String? hzzoGuidelineCode;
  final List<MedicationPrice> prices;
  final String? smpcUrl;
  final String? patientLeafletUrl;
  final String? officialRecordUrl;
  final String? shortageStatus;
  final bool isDemo;

  String get subtitle => '$strength · $form';

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
}
