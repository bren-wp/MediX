import 'package:flutter_test/flutter_test.dart';
import 'package:medix/data/medication_comparison.dart';
import 'package:medix/models/medication.dart';
import 'package:medix/models/medication_price.dart';

import 'support/medication_fixtures.dart';

void main() {
  MedicationPrice price(
    MedicationPriceKind kind,
    double amount, {
    String currency = 'EUR',
  }) =>
      MedicationPrice(
        amount: amount,
        currency: currency,
        kind: kind,
        source: 'official test',
        validFrom: DateTime(2026, 10, 1),
      );

  test('comparison rejects copayment on Basic List and unknown HZZO status',
      () {
    final medicine = testMedication(
      id: 'basic',
      name: 'Test medicine',
      ingredient: 'Active',
    );
    final invalidBasic = medicine.copyWith(
      reimbursementStatus: ReimbursementStatus.basic,
      prices: [price(MedicationPriceKind.hzzoCopay, 4.25)],
    );
    final unmatched = medicine.copyWith(
      reimbursementStatus: ReimbursementStatus.none,
      prices: [price(MedicationPriceKind.hzzoCopay, 4.25)],
    );
    expect(MedicationComparisonData.copayment(invalidBasic), '—');
    expect(MedicationComparisonData.copayment(unmatched), '—');
    expect(MedicationComparisonData.reimbursement(unmatched),
        'HZZO status nije potvrđen');
    expect(MedicationComparisonData.reimbursement(invalidBasic),
        'Osnovna lista HZZO-a');
  });

  test('comparison keeps wholesale and HZZO copayment separate', () {
    final medicine = testMedication(
      id: 'supplementary',
      name: 'Test medicine',
      ingredient: 'Active',
    ).copyWith(
      reimbursementStatus: ReimbursementStatus.supplementary,
      prices: [
        price(MedicationPriceKind.hzzoCopay, 2.50),
        price(MedicationPriceKind.maxWholesale, 17.30),
      ],
      hzzoListEffectiveDate: DateTime(2026, 10, 1),
    );
    expect(MedicationComparisonData.copayment(medicine), '2,50 EUR');
    expect(MedicationComparisonData.wholesale(medicine), '17,30 EUR');
    expect(MedicationComparisonData.sourceDate(medicine), '01.10.2026.');
  });

  test('comparison hides malformed and non-EUR prices and unknown list date',
      () {
    final medicine = testMedication(
      id: 'invalid',
      name: 'Test medicine',
      ingredient: 'Active',
    ).copyWith(
      reimbursementStatus: ReimbursementStatus.supplementary,
      prices: [
        price(MedicationPriceKind.hzzoCopay, 3, currency: 'HRK'),
        price(MedicationPriceKind.maxWholesale, double.infinity),
        price(MedicationPriceKind.maxWholesale, -5),
      ],
    );
    expect(MedicationComparisonData.copayment(medicine), '—');
    expect(MedicationComparisonData.wholesale(medicine), '—');
    expect(MedicationComparisonData.sourceDate(medicine),
        'Datum primjene nije potvrđen');
    expect(MedicationComparisonData.sourceDate(medicine.copyWith(
        reimbursementStatus: ReimbursementStatus.none)), '—');
  });
}
