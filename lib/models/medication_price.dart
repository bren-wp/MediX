enum MedicationPriceKind {
  hzzoCopay,
  hzzoReimbursement,
  maxWholesale,
  pharmacyRetail,
}

class MedicationPrice {
  const MedicationPrice({
    required this.amount,
    required this.currency,
    required this.kind,
    required this.source,
    required this.validFrom,
    this.validUntil,
    this.note,
  });

  final double amount;
  final String currency;
  final MedicationPriceKind kind;
  final String source;
  final DateTime validFrom;
  final DateTime? validUntil;
  final String? note;

  String get formatted =>
      '${amount.toStringAsFixed(2).replaceAll('.', ',')} ${currency}';
}
