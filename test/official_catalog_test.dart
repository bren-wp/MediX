import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:medix/data/medication_repository.dart';
import 'package:medix/models/medication.dart';
import 'package:medix/models/medication_price.dart';

import 'support/medication_fixtures.dart';

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
      expect(medication.prices, hasLength(1));
      expect(
        medication.prices.single.kind,
        MedicationPriceKind.hzzoCopay,
      );
      expect(medication.prices.single.amount, 4.25);
    });


    test('maps HALMED identity and detailed dispensing metadata', () {
      final json = jsonEncode({
        'generated_at': '2026-10-02T00:00:00Z',
        'source': {
          'name': 'HALMED test',
          'url': 'https://example.test/halmed',
        },
        'records': [
          {
            'id': 'halmed-test-1',
            'name': 'Testmed 500 mg tablete',
            'authorization_number': 'HR-H-123',
            'active_ingredient': 'testna tvar',
            'strength': '500 mg',
            'form': 'tablete',
            'atc_code': 'N02BE01',
            'holder': 'Test Pharma d.o.o.',
            'manufacturer': 'Factory GmbH',
            'rx_status': 'na recept',
            'prescribing_mode': 'neponovljivi recept',
            'dispensing_place': 'u ljekarni',
            'market_status': 'stavljeno u promet',
          },
        ],
      });

      final medication =
          MedicationRepository.fromHalmedJson(json).medications.single;

      expect(medication.name, 'Testmed 500 mg tablete');
      expect(medication.activeIngredient, 'testna tvar');
      expect(medication.dispensingStatus, 'na recept');
      expect(medication.prescribingMode, 'neponovljivi recept');
      expect(medication.dispensingPlace, 'u ljekarni');
      expect(medication.marketStatus, 'stavljeno u promet');
      expect(medication.requiresPrescription, isTrue);
    });

    test('rejects holder/company rows as medicine identities', () {
      final json = jsonEncode({
        'source': {'name': 'HALMED test'},
        'records': [
          {
            'id': 'bad-1',
            'name': 'A1 d.o.o.',
            'authorization_number': 'HR-H-999',
            'active_ingredient': 'x',
            'holder': 'A1 d.o.o.',
            'form': 'tablete',
          },
        ],
      });

      expect(
        () => MedicationRepository.fromHalmedJson(json),
        throwsFormatException,
      );
    });

    test('builds compact subtitle without duplicate placeholders', () {
      final medication = testMedication(
        id: 'subtitle-test',
        name: 'Testmed',
        ingredient: 'testna tvar',
      );

      expect(medication.compactSubtitle, '500 mg · tablete');

      final onlyForm = medication.copyWith(
        strength: 'doza',
        form: 'tablete',
      );
      expect(onlyForm.compactSubtitle, 'tablete');

      final unknown = medication.copyWith(
        strength: 'nije navedeno',
        form: 'lijek',
      );
      expect(unknown.compactSubtitle, isNull);
      expect(
        unknown.subtitle,
        'Podaci o pakiranju nisu dostupni',
      );
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
