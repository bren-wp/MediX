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
        final medications =
            state.repository.medications.where(filter).toList(growable: false);

        return MedixPage(
          appBar: AppBar(title: Text(title)),
          safeArea: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
            children: [
              if (description != null) ...[
                MedixSectionCard(
                  child: Text(
                    description!,
                    style: const TextStyle(
                      color: MedixColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
              ],
              if (medications.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 80),
                  child: Center(
                    child: Text(
                      'Nema zapisa u trenutnoj lokalnoj bazi.',
                      style: TextStyle(color: MedixColors.textSecondary),
                    ),
                  ),
                )
              else
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
        );
      },
    );
  }
}
