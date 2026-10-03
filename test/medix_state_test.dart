import 'package:flutter_test/flutter_test.dart';
import 'support/medication_fixtures.dart';
import 'package:medix/state/medix_state.dart';

void main() {
  group('MedixState', () {
    late MedixState state;

    setUp(() {
      state = MedixState(repository: buildTestRepository());
    });

    tearDown(() {
      state.dispose();
    });

    test('toggles favorites', () {
      state.toggleFavorite('paracetamol-500');

      expect(state.isFavorite('paracetamol-500'), isTrue);
      expect(state.favorites, hasLength(1));

      state.toggleFavorite('paracetamol-500');

      expect(state.isFavorite('paracetamol-500'), isFalse);
      expect(state.favorites, isEmpty);
    });

    test('ignores invalid medication ids in local state', () {
      state.toggleFavorite('missing');
      state.markViewed('missing');

      expect(state.favorites, isEmpty);
      expect(state.recent, isEmpty);
    });

    test('keeps most recent medication first without duplicates', () {
      state.markViewed('paracetamol-500');
      state.markViewed('ibuprofen-400');
      state.markViewed('paracetamol-500');

      expect(state.recent, hasLength(2));
      expect(state.recent.first.id, 'paracetamol-500');
    });

    test('adds and normalizes therapy plan', () {
      state.addTherapy(
        medicationId: 'paracetamol-500',
        doseDescription: ' 1 tableta ',
        times: const ['20:00', '08:00', '08:00', ''],
      );

      expect(state.therapy, hasLength(1));
      expect(state.therapy.first.doseDescription, '1 tableta');
      expect(state.therapy.first.times, const ['08:00', '20:00']);
      expect(state.therapy.first.isActive, isTrue);
    });

    test('normalizes therapy weekdays', () {
      state.addTherapy(
        medicationId: 'paracetamol-500',
        doseDescription: '1 tableta',
        times: const ['08:00'],
        weekdays: const [5, 1, 5, 3, 9],
      );

      expect(state.therapy.single.weekdays, const [1, 3, 5]);
    });

    test('does not add invalid therapy plan', () {
      state.addTherapy(
        medicationId: 'missing',
        doseDescription: '1 tableta',
        times: const ['08:00'],
      );

      expect(state.therapy, isEmpty);
    });

    test('toggles and removes therapy plan', () {
      state.addTherapy(
        medicationId: 'ibuprofen-400',
        doseDescription: '1 tableta',
        times: const ['09:00'],
      );

      final id = state.therapy.single.id;
      state.toggleTherapy(id);

      expect(state.therapy.single.isActive, isFalse);

      state.removeTherapy(id);

      expect(state.therapy, isEmpty);
    });
  });
}
