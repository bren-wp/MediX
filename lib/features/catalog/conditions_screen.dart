import 'package:flutter/material.dart';

import '../../core/theme/medix_theme.dart';
import '../../models/medication.dart';
import '../../state/medix_state.dart';
import '../../widgets/medication_tile.dart';
import '../../widgets/medix_page.dart';
import '../medications/medication_detail_screen.dart';

class ConditionsScreen extends StatelessWidget {
  const ConditionsScreen({required this.state, super.key});

  final MedixState state;

  @override
  Widget build(BuildContext context) {
    final groups = <String, List<Medication>>{};
    for (final medication in state.repository.medications) {
      for (final use in medication.uses) {
        groups.putIfAbsent(use, () => []).add(medication);
      }
    }
    final conditions = groups.keys.toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

    return MedixPage(
      appBar: AppBar(title: const Text('Bolesti i stanja')),
      safeArea: false,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        itemCount: conditions.length,
        separatorBuilder: (_, __) => const SizedBox(height: 9),
        itemBuilder: (context, index) {
          final condition = conditions[index];
          final medications = groups[condition]!;
          final color = _colorFor(index);
          return MedixSectionCard(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => _ConditionDetail(
                  condition: condition,
                  medications: medications,
                  state: state,
                ),
              ),
            ),
            child: Row(
              children: [
                MedixIconBubble(
                  icon: _iconFor(index),
                  color: color,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    condition,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                ),
                Text(
                  '${medications.length}',
                  style: const TextStyle(
                    color: MedixColors.textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 5),
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

  IconData _iconFor(int index) {
    const icons = [
      Icons.favorite_rounded,
      Icons.thermostat_rounded,
      Icons.air_rounded,
      Icons.healing_rounded,
      Icons.psychology_alt_outlined,
      Icons.water_drop_outlined,
      Icons.health_and_safety_outlined,
    ];
    return icons[index % icons.length];
  }

  Color _colorFor(int index) {
    const colors = [
      MedixColors.danger,
      MedixColors.warning,
      MedixColors.cyan,
      MedixColors.purple,
      MedixColors.primary,
      MedixColors.success,
    ];
    return colors[index % colors.length];
  }
}

class _ConditionDetail extends StatelessWidget {
  const _ConditionDetail({
    required this.condition,
    required this.medications,
    required this.state,
  });

  final String condition;
  final List<Medication> medications;
  final MedixState state;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: state,
      builder: (context, _) => MedixPage(
        appBar: AppBar(title: Text(condition)),
        safeArea: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
          children: [
            const MedixSectionCard(
              accent: MedixColors.warning,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MedixIconBubble(
                    icon: Icons.info_outline_rounded,
                    color: MedixColors.warning,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Prikaz povezuje lijekove s indikacijama navedenima u njihovom podatkovnom zapisu. Ne predstavlja preporuku terapije niti dijagnozu.',
                      style: TextStyle(
                        color: MedixColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            ...medications.map(
              (medication) => Padding(
                padding: const EdgeInsets.only(bottom: 9),
                child: MedicationTile(
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
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
