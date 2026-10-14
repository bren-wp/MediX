import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:medix/data/medication_repository.dart';
import 'package:medix/models/medication.dart';

void main() {
  Map<String, Object?> halmedRecord(
    String id,
    String name,
    String strength,
    String package,
  ) => {
        'id': id,
        'name': name,
        'authorization_number': 'HR-H-$id',
        'active_ingredient': 'aktivna tvar',
        'strength': strength,
        'form': 'tablete',
        'atc_code': 'A01AA01',
        'package': package,
      };

  String halmed(List<Map<String, Object?>> records) =>
      jsonEncode({'source': {'name': 'HALMED test'}, 'records': records});

  String hzzo({
    String strength = '500 mg',
    String package = '500 mg 30 tableta',
  }) =>
      jsonEncode({
        'source': {'name': 'HZZO test', 'effective_date': '2026-10-01'},
        'records': [
          {
            'id': 'hzzo-record',
            'name': 'Medicin',
            'active_ingredient': 'aktivna tvar',
            'atc_code': 'A01AA01',
            'strength': strength,
            'package': package,
            'supplementary_list': true,
            'basic_list': false,
            'copay_eur': 6.50,
          },
        ],
      });

  String wholesale(String package) => jsonEncode({
        'source': {
          'name': 'HALMED prices',
          'published_date': '2026-06-18',
        },
        'records': [
          {
            'name': 'Medicin',
            'active_ingredient': 'aktivna tvar',
            'atc_code': 'A01AA01',
            'name_and_package': package,
            'max_wholesale_eur': 23,
          },
        ],
      });

  test('copayment and price follow the exact known strength and pack count',
      () {
    final repo = MedicationRepository.fromBundledCatalogs(
      halmedJson: halmed([
        halmedRecord('low', 'Medicin 250 mg tablete', '250 mg',
            '250 mg 30 tableta'),
        halmedRecord('wrong-pack', 'Medicin 500 mg tablete', '500 mg',
            '500 mg 20 tableta'),
        halmedRecord('correct', 'Medicin 500 mg tablete', '500 mg',
            '500 mg 30 tableta'),
      ]),
      reimbursementJson: hzzo(),
      priceJson: wholesale('Medicin 500 mg 30 tableta'),
    );

    final byId = {for (final medicine in repo.medications) medicine.id: medicine};
    for (final id in const ['low', 'wrong-pack']) {
      expect(byId[id]!.reimbursementStatus, ReimbursementStatus.none);
      expect(byId[id]!.hzzoCopay, isNull);
      expect(byId[id]!.maxWholesalePrice, isNull);
    }
    expect(byId['correct']!.reimbursementStatus,
        ReimbursementStatus.supplementary);
    expect(byId['correct']!.hzzoCopay?.amount, 6.50);
    expect(byId['correct']!.maxWholesalePrice?.amount, 23);
  });

  test('does not guess a pack match when HALMED strength or pack is absent',
      () {
    final repo = MedicationRepository.fromBundledCatalogs(
      halmedJson: halmed([
        halmedRecord('missing', 'Medicin', '', ''),
      ]),
      reimbursementJson: hzzo(),
      priceJson: wholesale('Medicin 500 mg 30 tableta'),
    );

    final medicine = repo.medications.single;
    expect(medicine.reimbursementStatus, ReimbursementStatus.none);
    expect(medicine.hzzoCopay, isNull);
    expect(medicine.maxWholesalePrice, isNull);
  });

  test('rejects mismatching strength even when names and ATC match', () {
    final repo = MedicationRepository.fromBundledCatalogs(
      halmedJson: halmed([
        halmedRecord('low', 'Medicin 250 mg tablete', '250 mg',
            '250 mg 30 tableta'),
      ]),
      reimbursementJson: hzzo(),
      priceJson: wholesale('Medicin 500 mg 30 tableta'),
    );

    expect(repo.medications.single.prices, isEmpty);
    expect(repo.medications.single.reimbursementStatus,
        ReimbursementStatus.none);
  });
}
