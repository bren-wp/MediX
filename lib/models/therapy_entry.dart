class TherapyEntry {
  /// Accept valid clock values only and keep them in canonical HH:mm form.
  static final RegExp _clockPattern = RegExp(r'^(\d{1,2}):(\d{2})$');

  static List<String> normalizeTimes(Iterable<String> values) {
    final normalized = <String>{};
    for (final raw in values) {
      final match = _clockPattern.firstMatch(raw.trim());
      if (match == null) continue;
      final hour = int.tryParse(match.group(1)!);
      final minute = int.tryParse(match.group(2)!);
      if (hour == null || minute == null ||
          hour > 23 || minute > 59) {
        continue;
      }
      normalized.add(
        hour.toString().padLeft(2, '0') +
            ':' +
            minute.toString().padLeft(2, '0'),
      );
    }
    return normalized.toList()..sort();
  }

  const TherapyEntry({
    required this.id,
    required this.medicationId,
    required this.doseDescription,
    required this.times,
    this.weekdays = const [1, 2, 3, 4, 5, 6, 7],
    this.isActive = true,
  });

  final String id;
  final String medicationId;
  final String doseDescription;
  final List<String> times;

  /// ISO weekday numbers: Monday = 1, Sunday = 7.
  final List<int> weekdays;
  final bool isActive;

  bool appliesTo(DateTime date) => weekdays.contains(date.weekday);

  bool get repeatsEveryDay =>
      weekdays.length == 7 &&
      weekdays.toSet().containsAll(const [1, 2, 3, 4, 5, 6, 7]);

  TherapyEntry copyWith({
    String? doseDescription,
    List<String>? times,
    List<int>? weekdays,
    bool? isActive,
  }) {
    return TherapyEntry(
      id: id,
      medicationId: medicationId,
      doseDescription: doseDescription ?? this.doseDescription,
      times: times ?? this.times,
      weekdays: weekdays ?? this.weekdays,
      isActive: isActive ?? this.isActive,
    );
  }
}
