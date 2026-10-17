import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:medix/data/medication_repository.dart';
import 'package:medix/models/medication_price.dart';

void main() {
  final halmed = jsonEncode({
    'source': {'name': 'HALMED test'},
    'records': [
      {
        'id': 'medicin-30',
        'name': 'Medicin 500 mg tablete',
        'authorization_number': 'HR-H-1234',
        'active_ingredient': 'aktivna tvar',
        'strength': '500 mg',
        'form': 'tablete',
        'atc_code': 'A01AA01',
        'package': '500 mg 30 tableta',
      },
    ],
  });

  String priceCatalog({
    Object? date = '2026-06-18',
    Object? amount = 23,
    String? currency,
  }) =>
      jsonEncode({
        'source': {
          'name': 'Published wholesale test',
          if (date != null) 'published_date': date,
          if (currency != null) 'currency': currency,
        },
        'records': [
          {
            'name': 'Medicin',
            'active_ingredient': 'aktivna tvar',
            'atc_code': 'A01AA01',
            'name_and_package': 'Medicin 500 mg 30 tableta',
            'max_wholesale_eur': amount,
          },
        ],
      });

  List<MedicationPrice> importedPrices(String priceJson) =>
      MedicationRepository.fromBundledCatalogs(
        halmedJson: halmed,
        reimbursementJson: '{}',
        priceJson: priceJson,
      ).medications.single.prices;

  test('dated EUR wholesale snapshot enriches the correctly matched pack',
      () {
    final prices = importedPrices(priceCatalog(amount: '23,50'));
    expect(prices, hasLength(1));
    expect(prices.single.kind, MedicationPriceKind.maxWholesale);
    expect(prices.single.amount, 23.5);
    expect(prices.single.currency, 'EUR');
    expect(prices.single.validFrom, DateTime(2026, 6, 18));
  });

  test('unknown and impossible publication dates never create priced data',
      () {
    for (final date in <Object?>[
      null,
      '',
      'unknown',
      '2026-02-30',
      '2026-13-01',
      '2026-6-18',
      '2026-06-18T00:00:00Z',
    ]) {
      expect(importedPrices(priceCatalog(date: date)), isEmpty,
          reason: 'Unverified publication date: $date');
    }
  });

  test('rejects unusable amounts or contradictory source currency', () {
    for (final amount in <Object?>[
      null,
      true,
      -0.5,
      'NaN',
      'Infinity',
      'unknown',
      '23 HRK',
    ]) {
      expect(importedPrices(priceCatalog(amount: amount)), isEmpty,
          reason: 'Invalid wholesale value: $amount');
    }
    expect(importedPrices(priceCatalog(currency: 'HRK')), isEmpty);
    expect(importedPrices(priceCatalog(amount: 0)), hasLength(1));
  });

  test('invalid optional wholesale JSON cannot crash HALMED catalog', () {
    expect(importedPrices('{'), isEmpty);
    expect(importedPrices('[]'), isEmpty);
  });

  test('invalid HZZO effective date never confirms a dated copay', () {
    for (final date in ['2026-02-30', '2026-10-01T00:00:00Z']) {
      final hzzoJson = jsonEncode({
        'source': {'name': 'HZZO test', 'effective_date': date},
        'records': [
          {
            'id': 'hzzo-invalid-date',
            'name': 'Medicin',
            'active_ingredient': 'aktivna tvar',
            'supplementary_list': true,
            'copay_eur': 6.5,
          },
        ],
      });
      final medicine =
          MedicationRepository.fromOfficialJson(hzzoJson).medications.single;
      expect(medicine.hzzoListEffectiveDate, isNull);
      expect(medicine.prices, isEmpty);
    }
  });
}
