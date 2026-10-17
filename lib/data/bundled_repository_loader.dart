import 'dart:convert';
import 'dart:isolate';

import 'package:flutter/services.dart';

import 'medication_repository.dart';

/// Read the official offline snapshots as bytes. Transfer the buffers and
/// perform all UTF-8 decoding, JSON parsing and cross-catalog matching in a
/// short-lived worker isolate. The Flutter UI remains responsive while the
/// initial medicine catalog is being prepared.
///
/// TransferableTypedData avoids copying large immutable JSON strings through
/// the main isolate. Isolate.run returns the completed repository as the
/// worker exits, so temporary JSON maps can be reclaimed.
Future<MedicationRepository> loadBundledMedicineRepository() async {
  Future<TransferableTypedData> loadBytes(String assetPath) async {
    final data = await rootBundle.load(assetPath);
    return TransferableTypedData.fromList([
      data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
    ]);
  }

  // Load sequentially to avoid concurrently decoding or retaining three
  // multi-megabyte ByteData allocations on memory-constrained devices.
  final halmed = await loadBytes('assets/data/halmed_catalog.json');
  final hzzo = await loadBytes('assets/data/medications_official.json');
  final prices = await loadBytes('assets/data/halmed_prices_2026.json');

  return Isolate.run(() {
    String decode(TransferableTypedData data) =>
        utf8.decode(data.materialize().asUint8List());

    return MedicationRepository.fromBundledCatalogs(
      halmedJson: decode(halmed),
      reimbursementJson: decode(hzzo),
      priceJson: decode(prices),
    );
  }, debugName: 'MediX catalog loader');
}
