import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/medication_repository.dart';
import '../models/medication.dart';
import '../models/therapy_entry.dart';
import '../services/preferences_store.dart';
import '../services/notification_service.dart';

class MedixState extends ChangeNotifier {
  MedixState({
    required this.repository,
    this.persistence,
    this.reminders,
  });

  final MedicationRepository repository;
  final MedixPersistence? persistence;
  final TherapyReminderScheduler? reminders;

  final Set<String> _favoriteIds = <String>{};
  final List<String> _recentIds = <String>[];
  final List<TherapyEntry> _therapy = <TherapyEntry>[];
  bool _onboardingCompleted = false;

  Set<String> get favoriteIds => Set.unmodifiable(_favoriteIds);
  List<TherapyEntry> get therapy => List.unmodifiable(_therapy);
  bool get onboardingCompleted => _onboardingCompleted;

  Future<void> restore() async {
    final storage = persistence;
    if (storage == null) return;

    final stored = await storage.load();
    final validMedicationIds =
        repository.medications.map((item) => item.id).toSet();

    _favoriteIds
      ..clear()
      ..addAll(
        stored.favoriteIds.where(validMedicationIds.contains),
      );

    _recentIds
      ..clear()
      ..addAll(
        stored.recentIds.where(validMedicationIds.contains).take(8),
      );

    _therapy
      ..clear()
      ..addAll(
        stored.therapy.where(
          (entry) => validMedicationIds.contains(entry.medicationId),
        ),
      );

    _onboardingCompleted = stored.onboardingCompleted;
    notifyListeners();
    _syncReminders();
  }

  Future<bool> requestReminderPermissions() async {
    final scheduler = reminders;
    if (scheduler == null) return false;
    return scheduler.requestPermissions();
  }

  Future<void> completeOnboarding() async {
    if (_onboardingCompleted) return;
    _onboardingCompleted = true;
    notifyListeners();
    final storage = persistence;
    if (storage != null) {
      await storage.setOnboardingCompleted(true);
    }
  }

  List<Medication> get favorites {
    return repository.medications
        .where((item) => _favoriteIds.contains(item.id))
        .toList();
  }

  List<Medication> get recent {
    final byId = {
      for (final medication in repository.medications)
        medication.id: medication,
    };

    return _recentIds
        .map((id) => byId[id])
        .whereType<Medication>()
        .toList(growable: false);
  }

  Medication? medicationById(String id) {
    for (final medication in repository.medications) {
      if (medication.id == id) {
        return medication;
      }
    }
    return null;
  }

  bool isFavorite(String medicationId) {
    return _favoriteIds.contains(medicationId);
  }

  void toggleFavorite(String medicationId) {
    if (medicationById(medicationId) == null) return;

    if (!_favoriteIds.remove(medicationId)) {
      _favoriteIds.add(medicationId);
    }
    notifyListeners();

    final storage = persistence;
    if (storage != null) {
      unawaited(storage.saveFavorites(_favoriteIds));
    }
  }

  void markViewed(String medicationId) {
    if (medicationById(medicationId) == null) return;

    _recentIds.remove(medicationId);
    _recentIds.insert(0, medicationId);
    if (_recentIds.length > 8) {
      _recentIds.removeLast();
    }
    notifyListeners();

    final storage = persistence;
    if (storage != null) {
      unawaited(storage.saveRecent(_recentIds));
    }
  }

  void addTherapy({
    required String medicationId,
    required String doseDescription,
    required List<String> times,
    List<int> weekdays = const [1, 2, 3, 4, 5, 6, 7],
  }) {
    final normalizedTimes = times
        .map((time) => time.trim())
        .where((time) => time.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
    final normalizedWeekdays = weekdays
        .where((day) => day >= 1 && day <= 7)
        .toSet()
        .toList()
      ..sort();

    if (medicationById(medicationId) == null ||
        doseDescription.trim().isEmpty ||
        normalizedTimes.isEmpty ||
        normalizedWeekdays.isEmpty) {
      return;
    }

    final id = 'therapy-${DateTime.now().microsecondsSinceEpoch}';
    _therapy.add(
      TherapyEntry(
        id: id,
        medicationId: medicationId,
        doseDescription: doseDescription.trim(),
        times: normalizedTimes,
        weekdays: normalizedWeekdays,
      ),
    );
    notifyListeners();
    _saveTherapy();
    _syncReminders();
  }

  void toggleTherapy(String therapyId) {
    final index = _therapy.indexWhere((entry) => entry.id == therapyId);
    if (index == -1) {
      return;
    }

    final current = _therapy[index];
    _therapy[index] = current.copyWith(isActive: !current.isActive);
    notifyListeners();
    _saveTherapy();
    _syncReminders();
  }

  void removeTherapy(String therapyId) {
    final previousLength = _therapy.length;
    _therapy.removeWhere((entry) => entry.id == therapyId);
    if (_therapy.length != previousLength) {
      notifyListeners();
      _saveTherapy();
      _syncReminders();
    }
  }

  void _syncReminders() {
    final scheduler = reminders;
    if (scheduler != null) {
      unawaited(
        scheduler.syncTherapy(
          therapy: List<TherapyEntry>.unmodifiable(_therapy),
          medicationById: medicationById,
        ),
      );
    }
  }

  void _saveTherapy() {
    final storage = persistence;
    if (storage != null) {
      unawaited(storage.saveTherapy(_therapy));
    }
  }
}
