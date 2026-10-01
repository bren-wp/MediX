import 'package:flutter_test/flutter_test.dart';
import 'package:medix/data/medication_repository.dart';
import 'package:medix/models/drug_interaction.dart';

void main() {
  group('MedicationRepository', () {
    final repository = MedicationRepository.demo();

    test('searches by medication name', () {
      final results = repository.search('paracetamol');

      expect(results, isNotEmpty);
      expect(results.first.name, 'Paracetamol');
    });

    test('searches by category or use', () {
      expect(repository.search('alergij'), isNotEmpty);
      expect(repository.search('temperatura'), isNotEmpty);
    });

    test('finds configured interaction in either direction', () {
      final direct = repository.interactionBetween('warfarin', 'ibuprofen-400');
      final reverse = repository.interactionBetween('ibuprofen-400', 'warfarin');

      expect(direct?.severity, InteractionSeverity.significant);
      expect(reverse?.severity, InteractionSeverity.significant);
    });

    test('returns null when demo interaction is not configured', () {
      final result = repository.interactionBetween(
        'paracetamol-500',
        'loratadine-10',
      );

      expect(result, isNull);
    });
  });
}
