class TherapyEntry {
  const TherapyEntry({
    required this.id,
    required this.medicationId,
    required this.doseDescription,
    required this.times,
    this.isActive = true,
  });

  final String id;
  final String medicationId;
  final String doseDescription;
  final List<String> times;
  final bool isActive;

  TherapyEntry copyWith({
    String? doseDescription,
    List<String>? times,
    bool? isActive,
  }) {
    return TherapyEntry(
      id: id,
      medicationId: medicationId,
      doseDescription: doseDescription ?? this.doseDescription,
      times: times ?? this.times,
      isActive: isActive ?? this.isActive,
    );
  }
}
