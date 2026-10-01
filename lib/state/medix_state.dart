import 'package:flutter/foundation.dart';

import '../data/medication_repository.dart';
import '../models/medication.dart';

class MedixState extends ChangeNotifier {
  MedixState({required this.repository});

  final MedicationRepository repository;

  final Set<String> _favoriteIds = <String>{};
  final List<String> _recentIds = <String>[];

  Set<String> get favoriteIds => Set.unmodifiable(_favoriteIds);

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
}
