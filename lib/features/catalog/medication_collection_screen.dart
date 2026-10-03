import 'package:flutter/material.dart';

import '../../core/theme/medix_theme.dart';
import '../../models/medication.dart';
import '../../state/medix_state.dart';
import '../../widgets/medication_tile.dart';
import '../../widgets/medix_page.dart';
import '../medications/medication_detail_screen.dart';

typedef MedicationFilter = bool Function(Medication medication);

class MedicationCollectionScreen extends StatelessWidget {
  const MedicationCollectionScreen({
    required this.title,
    required this.state,
    required this.filter,
    super.key,
    this.description,
  });

  final String title;
  final MedixState state;
  final MedicationFilter filter;
  final String? description;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: state,
      builder: (context, _) {
        final medications = state.repository.medications
            .where(filter)
            .toList(growable: false);
        final hasDescription =
            description != null && description!.trim().isNotEmpty;

        return MedixPage(
          appBar: AppBar(title: Text(title)),
          safeArea: false,
          child: medications.isEmpty
              ? Column(
                  children: [
                    if (hasDescription)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          16,
                          12,
                          16,
                          0,
                        ),
                        child: MedixSectionCard(
                          child: Text(
                            description!,
                            style: const TextStyle(
                              color: MedixColors.textSecondary,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ),
                    const Expanded(
                      child: MedixEmptyState(
                        icon: Icons.inventory_2_outlined,
                        title: 'Nema zapisa',
                        message:
                            'U trenutnom provjerenom katalogu nema zapisa za ovaj kriterij.',
                      ),
                    ),
                  ],
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(
                    16,
                    12,
                    16,
                    28,
                  ),
                  itemCount:
                      medications.length + (hasDescription ? 1 : 0),
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: 9),
                  itemBuilder: (context, index) {
                    if (hasDescription && index == 0) {
                      return MedixSectionCard(
                        child: Text(
                          description!,
                          style: const TextStyle(
                            color: MedixColors.textSecondary,
                            height: 1.4,
                          ),
                        ),
                      );
                    }

                    final medicationIndex =
                        index - (hasDescription ? 1 : 0);
                    final medication =
                        medications[medicationIndex];

                    return MedicationTile(
                      medication: medication,
                      isFavorite: state.isFavorite(medication.id),
                      onFavorite: () =>
                          state.toggleFavorite(medication.id),
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
        );
      },
    );
  }
}
