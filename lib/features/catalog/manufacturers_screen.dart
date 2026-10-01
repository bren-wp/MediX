import 'package:flutter/material.dart';

import '../../core/theme/medix_theme.dart';
import '../../models/medication.dart';
import '../../state/medix_state.dart';
import '../../widgets/medication_tile.dart';
import '../../widgets/medix_page.dart';
import '../medications/medication_detail_screen.dart';

class ManufacturersScreen extends StatelessWidget {
  const ManufacturersScreen({required this.state, super.key});

  final MedixState state;

  @override
  Widget build(BuildContext context) {
    final groups = <String, List<Medication>>{};
    for (final medication in state.repository.medications) {
      final holder = medication.manufacturer ??
          medication.marketingAuthorizationHolder ??
          'Nositelj nije naveden u lokalnom zapisu';
      groups.putIfAbsent(holder, () => []).add(medication);
    }
    final names = groups.keys.toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

    return MedixPage(
      appBar: AppBar(title: const Text('Proizvođači i nositelji')),
      safeArea: false,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        itemCount: names.length,
        separatorBuilder: (_, __) => const SizedBox(height: 9),
        itemBuilder: (context, index) {
          final name = names[index];
          final medications = groups[name]!;
          return MedixSectionCard(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => _ManufacturerDetail(
                  name: name,
                  medications: medications,
                  state: state,
                ),
              ),
            ),
            child: Row(
              children: [
                const MedixIconBubble(
                  icon: Icons.apartment_rounded,
                  color: MedixColors.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${medications.length} lijekova/pakiranja',
                        style: const TextStyle(
                          color: MedixColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: MedixColors.textMuted,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ManufacturerDetail extends StatelessWidget {
  const _ManufacturerDetail({
    required this.name,
    required this.medications,
    required this.state,
  });

  final String name;
  final List<Medication> medications;
  final MedixState state;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: state,
      builder: (context, _) => MedixPage(
        appBar: AppBar(title: Text(name)),
        safeArea: false,
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
          itemCount: medications.length,
          separatorBuilder: (_, __) => const SizedBox(height: 9),
          itemBuilder: (context, index) {
            final medication = medications[index];
            return MedicationTile(
              medication: medication,
              isFavorite: state.isFavorite(medication.id),
              onFavorite: () => state.toggleFavorite(medication.id),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => MedicationDetailScreen(
                    medication: medication,
                    state: state,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
