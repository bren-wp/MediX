import '../models/medication.dart';
import '../models/medication_access.dart';

/// Reuse the medicine detail screen's verified pricing rules in comparisons.
///
/// A missing HZZO match is *not* evidence that a medicine is excluded from
/// coverage. Wholesale prices are never interpreted as pharmacy retail prices.
class MedicationComparisonData {
  const MedicationComparisonData._();

  static String copayment(Medication medication) =>
      MedicationAccessInfo.fromMedication(medication).copayment?.formatted ??
      '—';

  static String wholesale(Medication medication) =>
      MedicationAccessInfo.fromMedication(medication)
          .wholesalePrice
          ?.formatted ??
      '—';

  static String reimbursement(Medication medication) {
    return switch (medication.reimbursementStatus) {
      ReimbursementStatus.basic => 'Osnovna lista HZZO-a',
      ReimbursementStatus.supplementary => 'Dopunska lista HZZO-a',
      ReimbursementStatus.none => 'HZZO status nije potvrđen',
    };
  }

  static String sourceDate(Medication medication) {
    if (!medication.isOnHzzoList) return '—';
    final date = medication.hzzoListEffectiveDate;
    if (date == null) return 'Datum primjene nije potvrđen';
    return '${date.day.toString().padLeft(2, '0')}.'
        '${date.month.toString().padLeft(2, '0')}.'
        '${date.year}.';
  }
}
