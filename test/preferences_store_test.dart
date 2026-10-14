import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:medix/services/preferences_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

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
