import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:medix/data/medication_repository.dart';
import 'package:medix/models/medication.dart';
import 'package:medix/models/medication_price.dart';

void main() {
  String halmedCatalog({
    String ingredient = 'djelatna tvar alfa',
    String strength = '500 mg',
    String package = '500 mg 30 tableta',
  }) =>
      jsonEncode({
        'source': {'name': 'HALMED test'},
        'records': [
          {
            'id': 'halmed-pack',
            'name': 'Medicin 500 mg tablete',
            'authorization_number': 'HR-H-1234',
            'active_ingredient': ingredient,
            'strength': strength,
            'form': 'tablete',
            'atc_code': 'A01AA01',
            'package': package,
          },
        ],
      });

  String hzzoCatalog({
    String ingredient = 'djelatna tvar alfa',
    String strength = '500 mg',
    String package = '500 mg 30 tableta',
    bool basic = false,
    bool supplementary = true,
    Object? copay = 4.25,
  }) =>
      jsonEncode({
        'source': {
          'name': 'HZZO test',
          'effective_date': '2026-10-01',
        },
        'records': [
          {
            'id': 'hzzo-record',
            'name': 'Medicin',
            'active_ingredient': ingredient,
            'atc_code': 'A01AA01',
            'strength': strength,
            'package': package,
            'basic_list': basic,
            'supplementary_list': supplementary,
            'copay_eur': copay,
          },
        ],
      });

  String priceCatalog({
    String ingredient = 'djelatna tvar alfa',
    String package = 'Medicin 500 mg 30 tableta',
    String? currency,
  }) =>
      jsonEncode({
        'source': {
          'name': 'HALMED price test',
          'published_date': '2026-06-18',
          'currency': 'EUR',
        },
        'records': [
          {
            'name': 'Medicin',
            'active_ingredient': ingredient,
            'atc_code': 'A01AA01',
            'name_and_package': package,
            'max_wholesale_eur': 23,
            if (currency != null) 'currency': currency,
          },
        ],
      });

  Medication merged({
    String? halmed,
    String? hzzo,
    String? wholesale,
  }) =>
      MedicationRepository.fromBundledCatalogs(
        halmedJson: halmed ?? halmedCatalog(),
        reimbursementJson: hzzo ?? hzzoCatalog(),
        priceJson: wholesale ?? priceCatalog(),
      ).medications.single;

  test('fully matched source records retain verified list and both prices',
      () {
    final medicine = merged();
    expect(medicine.reimbursementStatus, ReimbursementStatus.supplementary);
    expect(medicine.hzzoCopay?.amount, 4.25);
    expect(medicine.maxWholesalePrice?.amount, 23);
    expect(medicine.prices, hasLength(2));
  });

  test('same trade name and ATC never override disagreeing active ingredient',
      () {
    final medicine = merged(
      hzzo: hzzoCatalog(ingredient: 'djelatna tvar beta'),
      wholesale: priceCatalog(ingredient: 'djelatna tvar beta'),
    );
    expect(medicine.reimbursementStatus, ReimbursementStatus.none);
    expect(medicine.hzzoCopay, isNull);
    expect(medicine.maxWholesalePrice, isNull);
    expect(medicine.prices, isEmpty);
  });

  test('incomplete secondary pack is not enough to claim copay or price',
      () {
    final medicine = merged(
      hzzo: hzzoCatalog(package: '500 mg'),
      wholesale: priceCatalog(package: 'Medicin 500 mg'),
    );
    expect(medicine.reimbursementStatus, ReimbursementStatus.none);
    expect(medicine.prices, isEmpty);
  });

  test('missing secondary strength is not assumed from trade name',
      () {
    final medicine = merged(
      hzzo: hzzoCatalog(strength: '', package: '30 tableta'),
      wholesale: priceCatalog(package: 'Medicin 30 tableta'),
    );
    expect(medicine.reimbursementStatus, ReimbursementStatus.none);
    expect(medicine.prices, isEmpty);
  });

  test('contradictory HZZO basic and supplementary flags remain unverified',
      () {
    final medicine = merged(
      hzzo: hzzoCatalog(basic: true, supplementary: true),
      wholesale: '{}',
    );
    expect(medicine.reimbursementStatus, ReimbursementStatus.none);
    expect(medicine.hzzoCopay, isNull);
    expect(medicine.hzzoListEffectiveDate, isNull);
    expect(medicine.prices, isEmpty);
  });

  test('basic list does not invent supplementary copayment', () {
    final medicine = merged(
      hzzo: hzzoCatalog(basic: true, supplementary: false, copay: 9.5),
      wholesale: '{}',
    );
    expect(medicine.reimbursementStatus, ReimbursementStatus.basic);
    expect(medicine.hzzoCopay, isNull);
    expect(medicine.prices, isEmpty);
  });

  test('record-level currency mismatch cannot attach a wholesale amount',
      () {
    final medicine = merged(
      hzzo: '{}',
      wholesale: priceCatalog(currency: 'HRK'),
    );
    expect(medicine.maxWholesalePrice, isNull);
    expect(medicine.prices, isEmpty);
  });

  test('duplicate HALMED pack candidates stay ambiguous', () {
    final halmed = jsonEncode({
      'source': {'name': 'HALMED test'},
      'records': [
        for (final id in ['first', 'second'])
          {
            'id': id,
            'name': 'Medicin 500 mg tablete',
            'authorization_number': 'HR-H-' + id,
            'active_ingredient': 'djelatna tvar alfa',
            'strength': '500 mg',
            'form': 'tablete',
            'atc_code': 'A01AA01',
            'package': '500 mg 30 tableta',
          },
      ],
    });
    final catalog = MedicationRepository.fromBundledCatalogs(
      halmedJson: halmed,
      reimbursementJson: hzzoCatalog(),
      priceJson: priceCatalog(),
    );
    expect(catalog.medications, hasLength(2));
    for (final medicine in catalog.medications) {
      expect(medicine.reimbursementStatus, ReimbursementStatus.none);
      expect(medicine.prices, isEmpty);
    }
  });
}
