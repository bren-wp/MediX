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

  /// Only a valid, explicit calendar date can be treated as an official
  /// effective or publication date. Dart normalizes some impossible dates
  /// (e.g. February 30), so checking tryParse alone is not sufficient.
  static DateTime? officialDate(Object? raw) {
    final value = raw?.toString().trim() ?? '';
    if (!RegExp(r'^\d{4}-\d{2}-\d{2}
}
).hasMatch(value)) return null;
    final date = DateTime.tryParse(value);
    if (date == null ||
        date.year.toString().padLeft(4, '0') != value.substring(0, 4) ||
        date.month.toString().padLeft(2, '0') != value.substring(5, 7) ||
        date.day.toString().padLeft(2, '0') != value.substring(8, 10)) {
      return null;
    }
    return date;
  }

  static String publishedDate(Object? raw) {
    final value = raw?.toString().trim() ?? '';
    return officialDate(raw) == null
        ? 'Datum objave nije potvrđen'
        : value;
  }
}
