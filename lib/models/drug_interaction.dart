enum InteractionSeverity {
  caution,
  significant,
}

class DrugInteraction {
  const DrugInteraction({
    required this.firstMedicationId,
    required this.secondMedicationId,
    required this.severity,
    required this.summary,
    required this.guidance,
  });

  final String firstMedicationId;
  final String secondMedicationId;
  final InteractionSeverity severity;
  final String summary;
  final String guidance;

  bool matches(String a, String b) {
    return (firstMedicationId == a && secondMedicationId == b) ||
        (firstMedicationId == b && secondMedicationId == a);
  }
}
