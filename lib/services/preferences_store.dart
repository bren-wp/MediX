import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/therapy_entry.dart';

class MedixStoredState {
  const MedixStoredState({
    required this.favoriteIds,
    required this.recentIds,
    required this.therapy,
    required this.onboardingCompleted,
  });

  final Set<String> favoriteIds;
  final List<String> recentIds;
  final List<TherapyEntry> therapy;
  final bool onboardingCompleted;
}

abstract interface class MedixPersistence {
  Future<MedixStoredState> load();
  Future<void> saveFavorites(Set<String> ids);
  Future<void> saveRecent(List<String> ids);
  Future<void> saveTherapy(List<TherapyEntry> therapy);
  Future<void> setOnboardingCompleted(bool value);
}

class MedixPreferences implements MedixPersistence {
  static const _favoritesKey = 'medix.favorite_ids.v1';
  static const _recentKey = 'medix.recent_ids.v1';
  static const _therapyKey = 'medix.therapy.v1';
  static const _onboardingKey = 'medix.onboarding_completed.v1';

  @override
  Future<MedixStoredState> load() async {
    final prefs = await SharedPreferences.getInstance();
    final favorites =
        prefs.getStringList(_favoritesKey)?.toSet() ?? <String>{};
    final recent = prefs.getStringList(_recentKey) ?? <String>[];
    final therapyRaw = prefs.getString(_therapyKey);
    final therapy = <TherapyEntry>[];

    if (therapyRaw != null && therapyRaw.isNotEmpty) {
      try {
        final decoded = jsonDecode(therapyRaw);
        if (decoded is List) {
          for (final item in decoded) {
            if (item is! Map) continue;
            final map = Map<String, dynamic>.from(item);
            final id = map['id']?.toString() ?? '';
            final medicationId = map['medication_id']?.toString() ?? '';
            final dose = map['dose']?.toString() ?? '';
            final rawTimes = map['times'];
            final times = rawTimes is List
                ? rawTimes.map((e) => e.toString()).toList()
                : <String>[];
            final rawWeekdays = map['weekdays'];
            final weekdays = rawWeekdays is List
                ? (rawWeekdays
                      .map((e) => int.tryParse(e.toString()))
                      .whereType<int>()
                      .where((day) => day >= 1 && day <= 7)
                      .toSet()
                      .toList()
                  ..sort())
                : <int>[1, 2, 3, 4, 5, 6, 7];

            if (id.isEmpty ||
                medicationId.isEmpty ||
                dose.isEmpty ||
                times.isEmpty) {
              continue;
            }

            therapy.add(
              TherapyEntry(
                id: id,
                medicationId: medicationId,
                doseDescription: dose,
                times: times,
                weekdays: weekdays.isEmpty
                    ? const [1, 2, 3, 4, 5, 6, 7]
                    : weekdays,
                isActive: map['active'] != false,
              ),
            );
          }
        }
      } catch (_) {
        // Corrupt local preferences must not prevent the app from starting.
      }
    }

    return MedixStoredState(
      favoriteIds: favorites,
      recentIds: recent,
      therapy: therapy,
      onboardingCompleted: prefs.getBool(_onboardingKey) ?? false,
    );
  }

  @override
  Future<void> saveFavorites(Set<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    final values = ids.toList()..sort();
    await prefs.setStringList(_favoritesKey, values);
  }

  @override
  Future<void> saveRecent(List<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_recentKey, ids);
  }

  @override
  Future<void> saveTherapy(List<TherapyEntry> therapy) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(
      therapy
          .map(
            (entry) => <String, dynamic>{
              'id': entry.id,
              'medication_id': entry.medicationId,
              'dose': entry.doseDescription,
              'times': entry.times,
              'weekdays': entry.weekdays,
              'active': entry.isActive,
            },
          )
          .toList(),
    );
    await prefs.setString(_therapyKey, encoded);
  }

  @override
  Future<void> setOnboardingCompleted(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingKey, value);
  }
}
