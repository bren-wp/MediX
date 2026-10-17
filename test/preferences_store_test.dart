import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:medix/services/preferences_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('corrupted entry does not erase later valid private therapy records',
      () async {
    SharedPreferences.setMockInitialValues({
      'medix.therapy.v1': jsonEncode([
        {'bad': 'record'},
        {1: 'non-string key'},
        {
          'id': 'safe',
          'medication_id': 'paracetamol-500',
          'dose': '1 tablet',
          'times': ['08:00'],
        },
        {
          'id': 'safe',
          'medication_id': 'ibuprofen-400',
          'dose': '2 tablets',
          'times': ['09:00'],
        },
        {
          'id': 'other',
          'medication_id': 'ibuprofen-400',
          'dose': '1 tablet',
          'times': ['18:00', 12, null],
        },
      ]),
    });

    final stored = await MedixPreferences().load();
    expect(stored.therapy.map((entry) => entry.id), ['safe', 'other']);
    expect(stored.therapy.last.times, ['18:00']);
    expect(stored.therapy.first.medicationId, 'paracetamol-500');
  });

  test('malformed overall therapy JSON does not stop other settings loading',
      () async {
    SharedPreferences.setMockInitialValues({
      'medix.therapy.v1': '{invalid',
      'medix.favorite_ids.v1': ['paracetamol-500'],
      'medix.locale.v1': 'hr',
    });

    final stored = await MedixPreferences().load();
    expect(stored.therapy, isEmpty);
    expect(stored.favoriteIds, contains('paracetamol-500'));
    expect(stored.localeCode, 'hr');
  });

  test('restores only valid, canonical therapy times', () async {
    SharedPreferences.setMockInitialValues({
      'medix.therapy.v1': jsonEncode([
        {
          'id': 'therapy-1',
          'medication_id': 'paracetamol-500',
          'dose': '1 tablet',
          'times': ['8:00', '08:00', '23:59', '24:00', 'not-a-time'],
          'weekdays': [1, 3, 5],
        },
        {
          'id': 'therapy-invalid',
          'medication_id': 'paracetamol-500',
          'dose': '1 tablet',
          'times': ['99:99'],
        },
      ]),
    });

    final restored = await MedixPreferences().load();

    expect(restored.therapy, hasLength(1));
    expect(restored.therapy.single.times, const ['08:00', '23:59']);
    expect(restored.therapy.single.weekdays, const [1, 3, 5]);
  });
}
