import 'package:flutter/foundation.dart';

import '../data/medication_repository.dart';
import '../models/medication.dart';
import '../models/therapy_entry.dart';

class MedixState extends ChangeNotifier {
  MedixState({required this.repository});

  final MedicationRepository repository;

  final Set<String> _favoriteIds = <String>{};
  final List<String> _recentIds = <String>[];
  final List<TherapyEntry> _therapy = <TherapyEntry>[];

  Set<String> get favoriteIds => Set.unmodifiable(_favoriteIds);

  List<TherapyEntry> get therapy => List.unmodifiable(_therapy);

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
    if (!_favoriteIds.remove(medicationId)) {
      _favoriteIds.add(medicationId);
    }
    notifyListeners();
  }

  void markViewed(String medicationId) {
    _recentIds.remove(medicationId);
    _recentIds.insert(0, medicationId);
    if (_recentIds.length > 8) {
      _recentIds.removeLast();
    }
    notifyListeners();
  }

  void addTherapy({
    required String medicationId,
    required String doseDescription,
    required List<String> times,
  }) {
    final normalizedTimes = times
        .map((time) => time.trim())
        .where((time) => time.isNotEmpty)
        .toSet()
        .toList()
      ..sort();

    if (medicationById(medicationId) == null ||
        doseDescription.trim().isEmpty ||
        normalizedTimes.isEmpty) {
      return;
    }

    final id = 'therapy-${DateTime.now().microsecondsSinceEpoch}';
    _therapy.add(
      TherapyEntry(
        id: id,
        medicationId: medicationId,
        doseDescription: doseDescription.trim(),
        times: normalizedTimes,
      ),
    );
    notifyListeners();
  }

  void toggleTherapy(String therapyId) {
    final index = _therapy.indexWhere((entry) => entry.id == therapyId);
    if (index == -1) {
      return;
    }

    final current = _therapy[index];
    _therapy[index] = current.copyWith(isActive: !current.isActive);
    notifyListeners();
  }

  void removeTherapy(String therapyId) {
    final previousLength = _therapy.length;
    _therapy.removeWhere((entry) => entry.id == therapyId);
    if (_therapy.length != previousLength) {
      notifyListeners();
    }
  }
}
