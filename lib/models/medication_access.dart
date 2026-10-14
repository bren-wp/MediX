import 'medication.dart';
import 'medication_price.dart';

/// Presentation-safe summary of official reimbursement and price records.
///
/// A missing HZZO match never proves that a product is excluded from coverage.
/// Nor does a supplementary-insurance policy guarantee a zero-euro copayment.
class MedicationAccessInfo {
  const MedicationAccessInfo._({
    required this.prescriptionRequired,
    required this.reimbursementStatus,
    required this.copayment,
    required this.retailPrice,
    required this.wholesalePrice,
  });

  final bool? prescriptionRequired;
  final ReimbursementStatus reimbursementStatus;
  final MedicationPrice? copayment;
  final MedicationPrice? retailPrice;
  final MedicationPrice? wholesalePrice;

  /// The same conservative validation must govern both the summary and
  /// the expandable list; hidden prices must not reappear in another view.
  static bool isDisplayablePrice(
    Medication medication,
    MedicationPrice price,
  ) =>
      price.currency.toUpperCase() == 'EUR' &&
      price.amount.isFinite &&
      price.amount >= 0 &&
      (price.kind != MedicationPriceKind.hzzoCopay ||
          medication.reimbursementStatus ==
              ReimbursementStatus.supplementary);

  static List<MedicationPrice> verifiedPrices(Medication medication) =>
      medication.prices
          .where((price) => isDisplayablePrice(medication, price))
          .toList(growable: false);

  static MedicationAccessInfo fromMedication(Medication medication) {
    MedicationPrice? validPrice(MedicationPriceKind kind) {
      for (final price in medication.prices) {
        if (price.kind == kind && isDisplayablePrice(medication, price)) {
          return price;
        }
      }
      return null;
    }

    return MedicationAccessInfo._(
      prescriptionRequired: medication.requiresPrescription,
      reimbursementStatus: medication.reimbursementStatus,
      // HZZO copay is shown only when the matched medicine is explicitly
      // assigned to the supplementary reimbursement list.
      copayment: medication.reimbursementStatus ==
              ReimbursementStatus.supplementary
          ? validPrice(MedicationPriceKind.hzzoCopay)
          : null,
      retailPrice: validPrice(MedicationPriceKind.pharmacyRetail),
      wholesalePrice: validPrice(MedicationPriceKind.maxWholesale),
    );
  }

  bool get hasConfirmedHzzoList =>
      reimbursementStatus != ReimbursementStatus.none;
}
