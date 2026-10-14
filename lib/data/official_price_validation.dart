/// Conservative display validation for official wholesale price snapshots.
///
/// These records represent published maximum wholesale EUR values, not
/// pharmacy retail prices or a patient's reimbursement entitlement.
class OfficialPriceValidation {
  const OfficialPriceValidation._();

  static double? euro(Object? raw) {
    if (raw == null || raw is bool) return null;
    final value = raw is num
        ? raw.toDouble()
        : double.tryParse(
            raw.toString().trim().replaceAll(',', '.'),
          );
    if (value == null || !value.isFinite || value < 0) return null;
    return value;
  }

  static String publishedDate(Object? raw) {
    final value = raw?.toString().trim() ?? '';
    final date = DateTime.tryParse(value);
    if (date == null ||
        !RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value) ||
        date.year.toString().padLeft(4, '0') != value.substring(0, 4) ||
        date.month.toString().padLeft(2, '0') != value.substring(5, 7) ||
        date.day.toString().padLeft(2, '0') != value.substring(8, 10)) {
      return 'Datum objave nije potvrđen';
    }
    return value;
  }
}
