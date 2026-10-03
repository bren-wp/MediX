import 'package:flutter_test/flutter_test.dart';
import 'package:medix/models/therapy_entry.dart';

void main() {
  test('therapy entry applies only to configured weekdays', () {
    const entry = TherapyEntry(
      id: 'therapy-1',
      medicationId: 'med-1',
      doseDescription: '1 tableta',
      times: ['08:00'],
      weekdays: [1, 3, 5],
    );

    expect(entry.appliesTo(DateTime(2026, 10, 5)), isTrue);
    expect(entry.appliesTo(DateTime(2026, 10, 6)), isFalse);
    expect(entry.appliesTo(DateTime(2026, 10, 7)), isTrue);
    expect(entry.repeatsEveryDay, isFalse);
  });

  test('default therapy entry repeats every day', () {
    const entry = TherapyEntry(
      id: 'therapy-2',
      medicationId: 'med-1',
      doseDescription: '1 tableta',
      times: ['08:00'],
    );

    expect(entry.repeatsEveryDay, isTrue);
    for (var weekday = 1; weekday <= 7; weekday++) {
      final date = DateTime(2026, 10, 5 + weekday - 1);
      expect(entry.appliesTo(date), isTrue);
    }
  });
}
