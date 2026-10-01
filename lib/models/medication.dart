class Medication {
  const Medication({
    required this.id,
    required this.name,
    required this.activeIngredient,
    required this.strength,
    required this.form,
    required this.category,
    required this.requiresPrescription,
    required this.summary,
    required this.uses,
    required this.dosageGuidance,
    required this.sideEffects,
    required this.warnings,
    required this.sourceLabel,
    required this.lastReviewed,
  });

  final String id;
  final String name;
  final String activeIngredient;
  final String strength;
  final String form;
  final String category;
  final bool requiresPrescription;
  final String summary;
  final List<String> uses;
  final String dosageGuidance;
  final List<String> sideEffects;
  final List<String> warnings;
  final String sourceLabel;
  final DateTime lastReviewed;

  String get subtitle => '$strength · $form';
}
