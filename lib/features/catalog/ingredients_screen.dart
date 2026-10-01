import 'package:flutter/material.dart';

import '../../core/theme/medix_theme.dart';
import '../../models/medication.dart';
import '../../state/medix_state.dart';
import '../../widgets/medication_tile.dart';
import '../../widgets/medix_page.dart';
import '../medications/medication_detail_screen.dart';

class IngredientsScreen extends StatelessWidget {
  const IngredientsScreen({required this.state, super.key});

  final MedixState state;

  @override
  Widget build(BuildContext context) {
    final groups = <String, List<Medication>>{};
    for (final medication in state.repository.medications) {
      groups.putIfAbsent(medication.activeIngredient, () => []).add(medication);
    }
    final ingredients = groups.keys.toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

    return MedixPage(
      appBar: AppBar(title: const Text('Djelatne tvari')),
      safeArea: false,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        itemCount: ingredients.length,
        separatorBuilder: (_, __) => const SizedBox(height: 9),
        itemBuilder: (context, index) {
          final ingredient = ingredients[index];
          final medications = groups[ingredient]!;
          return MedixSectionCard(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => _IngredientDetail(
                  ingredient: ingredient,
                  medications: medications,
                  state: state,
                ),
              ),
            ),
            child: Row(
              children: [
                const MedixIconBubble(
                  icon: Icons.hub_outlined,
                  color: MedixColors.cyan,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ingredient,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${medications.length} ${medications.length == 1 ? 'zapis' : 'zapisa'}',
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

class _IngredientDetail extends StatelessWidget {
  const _IngredientDetail({
    required this.ingredient,
    required this.medications,
    required this.state,
  });

  final String ingredient;
  final List<Medication> medications;
  final MedixState state;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: state,
      builder: (context, _) => MedixPage(
        appBar: AppBar(title: Text(ingredient)),
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
