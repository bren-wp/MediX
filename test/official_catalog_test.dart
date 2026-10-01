import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:medix/data/medication_repository.dart';
import 'package:medix/models/medication.dart';
import 'package:medix/models/medication_price.dart';

void main() {
  group('Official medicine catalog', () {
    test('maps HZZO administrative fields and copay', () {
      final json = jsonEncode({
        'source': {
          'name': 'HZZO test',
          'url': 'https://example.test',
          'effective_date': '2026-10-01',
        },
        'records': [
          {
            'id': 'hzzo-test-1',
            'name': 'Test lijek',
            'active_ingredient': 'testna tvar',
            'strength': '10 mg',
            'form': 'tablete',
            'category': 'Test kategorija',
            'rx_status': 'R',
            'atc_code': 'A01AA01',
            'holder': 'Test Pharma d.o.o.',
            'route': 'oralno',
            'package': '10 mg, 30 tableta',
            'guideline': 'RS01',
            'basic_list': false,
            'supplementary_list': true,
            'copay_eur': 4.25,
          },
        ],
      });

      final repository = MedicationRepository.fromOfficialJson(json);
      final medication = repository.medications.single;

      expect(medication.id, 'hzzo-test-1');
      expect(medication.requiresPrescription, isTrue);
      expect(medication.atcCode, 'A01AA01');
      expect(
        medication.reimbursementStatus,
        ReimbursementStatus.supplementary,
      );
      expect(medication.isDemo, isFalse);
      expect(medication.prices, hasLength(1));
      expect(
        medication.prices.single.kind,
        MedicationPriceKind.hzzoCopay,
      );
      expect(medication.prices.single.amount, 4.25);
    });

    test('rejects an empty official catalog', () {
      final json = jsonEncode({
        'source': {
          'name': 'HZZO test',
          'effective_date': '2026-10-01',
        },
        'records': [],
      });

      expect(
        () => MedicationRepository.fromOfficialJson(json),
        throwsFormatException,
      );
    });
  });
}
