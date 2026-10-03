import 'package:medix/data/medication_repository.dart';
import 'package:medix/models/drug_interaction.dart';
import 'package:medix/models/medication.dart';

Medication testMedication({
  required String id,
  required String name,
  required String ingredient,
  String strength = '500 mg',
  String form = 'tablete',
  String category = 'Test',
  bool? prescription = false,
  List<String> uses = const [],
}) {
  return Medication(
    id: id,
    name: name,
    activeIngredient: ingredient,
    strength: strength,
    form: form,
    category: category,
    requiresPrescription: prescription,
    summary: 'Testni zapis.',
    uses: uses,
    dosageGuidance: 'Testna uputa.',
    sideEffects: const [],
    warnings: const [],
    sourceLabel: 'test',
    lastReviewed: DateTime(2026, 10, 3),
    isDemo: false,
  );
}

MedicationRepository buildTestRepository() {
  return MedicationRepository(
    medications: [
      testMedication(
        id: 'paracetamol-500',
        name: 'Paracetamol',
        ingredient: 'Paracetamol',
        category: 'Protiv bolova i temperature',
        uses: const ['Bol', 'Povišena tjelesna temperatura'],
      ),
      testMedication(
        id: 'ibuprofen-400',
        name: 'Ibuprofen',
        ingredient: 'Ibuprofen',
        strength: '400 mg',
        category: 'Protiv bolova i upale',
      ),
      testMedication(
        id: 'warfarin',
        name: 'Varfarin',
        ingredient: 'Varfarin',
        strength: '5 mg',
        category: 'Antikoagulansi',
        prescription: true,
      ),
      testMedication(
        id: 'loratadine-10',
        name: 'Loratadin',
        ingredient: 'Loratadin',
        strength: '10 mg',
        category: 'Alergije',
        uses: const ['Simptomi alergije'],
      ),
    ],
    interactions: const [
      DrugInteraction(
        firstMedicationId: 'warfarin',
        secondMedicationId: 'ibuprofen-400',
        severity: InteractionSeverity.significant,
        summary: 'Testna interakcija.',
        guidance: 'Testna smjernica.',
      ),
    ],
  );
}
