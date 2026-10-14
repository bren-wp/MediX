import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:medix/data/dispensing_status_parser.dart';
import 'package:medix/data/medication_query.dart';
import 'package:medix/data/medication_repository.dart';

void main() {
  test('recognizes documented dispensing codes BR/BRX/R/RS', () {
    const variants = <String, bool>{
      'BR': false,
      'BRX': false,
      'BR - Bez recepta, u ljekarni': false,
      'BRX - Bez recepta, u ljekarni i specijaliziranoj prodavaonici':
          false,
      'R': true,
      'RS': true,
      'R - Na recept, u ljekarni': true,
      'RS - Izdavanje na recept po preporuci specijalista': true,
      'R/RS': true,
    };
    for (final entry in variants.entries) {
      expect(
        DispensingStatusParser.requiresPrescription(entry.key),
        entry.value,
        reason: 'Documented status: ${entry.key}',
      );
    }
  });

  test('recognizes explicit ordinary language without guessing codes', () {
    const trueValues = [
      'Izdaje se na recept u ljekarni',
      'Samo uz recept liječnika',
      'na recept',
    ];
    const falseValues = [
      'Bez recepta',
      'u ljekarni bez recepta',
      'OTC',
    ];
    for (final value in trueValues) {
      expect(DispensingStatusParser.requiresPrescription(value), isTrue,
          reason: value);
    }
    for (final value in falseValues) {
      expect(DispensingStatusParser.requiresPrescription(value), isFalse,
          reason: value);
    }
  });

  test('negated and conflicting source statuses stay unknown, never OTC', () {
    for (final value in [
      'ne izdaje se bez recepta',
      'Ne smije se izdavati bez recepta',
      'nije bez recepta',
      'ne izdaje se na recept',
      'BRX - na recept',
      'RS - bez recepta',
      'na recept i bez recepta',
      'BR - na recept',
      '',
      ' ',
      'nepoznato',
      'lijek u prometu',
      'NR', // HZZO prescribing abbreviation is not an OTC code.
    ]) {
      expect(DispensingStatusParser.requiresPrescription(value), isNull,
          reason: 'Must not guess dispensing status from $value');
    }
    expect(DispensingStatusParser.requiresPrescription(null), isNull);
  });

  test('official import and filtering agree on the conservative status', () {
    final rows = <Map<String, Object?>>[
      for (final entry in const [
        ('otc', 'BRX'),
        ('rx', 'RS'),
        ('ambiguous', 'RS - bez recepta'),
        ('negated', 'ne izdaje se bez recepta'),
      ])
        {
          'id': entry.$1,
          'name': 'Lijek ${entry.$1}',
          'active_ingredient': 'testna tvar',
          'authorization_number': 'HR-H-${entry.$1}',
          'rx_status': entry.$2,
          'atc_code': 'A01AA01',
          'strength': '10 mg',
          'form': 'tablete',
        },
    ];
    final repository = MedicationRepository.fromHalmedJson(
      jsonEncode({'source': {'name': 'HALMED test'}, 'records': rows}),
    );
    final data = {for (final m in repository.medications) m.id: m};
    expect(data['otc']!.requiresPrescription, isFalse);
    expect(data['rx']!.requiresPrescription, isTrue);
    expect(data['ambiguous']!.requiresPrescription, isNull);
    expect(data['negated']!.requiresPrescription, isNull);
    expect(data['ambiguous']!.dispensingLabel,
        'Način izdavanja nije potvrđen');

    Iterable<String> ids(DispensingFilter filter) =>
        applyMedicationQuery(
          repository.medications,
          MedicationQuery(dispensing: filter),
        ).map((m) => m.id);

    expect(ids(DispensingFilter.prescription), ['rx']);
    expect(ids(DispensingFilter.otc), ['otc']);
    expect(ids(DispensingFilter.unknown),
        containsAllInOrder(['ambiguous', 'negated']));
  });
}
