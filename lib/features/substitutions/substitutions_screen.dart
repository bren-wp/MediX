import 'package:flutter/material.dart';

import '../../core/theme/medix_theme.dart';
import '../../models/medication.dart';
import '../../state/medix_state.dart';
import '../../widgets/medication_tile.dart';
import '../../widgets/medix_page.dart';
import '../medications/medication_detail_screen.dart';

class SubstitutionsScreen extends StatefulWidget {
  const SubstitutionsScreen({required this.state, super.key});
  final MedixState state;

  @override
  State<SubstitutionsScreen> createState() => _SubstitutionsScreenState();
}

class _SubstitutionsScreenState extends State<SubstitutionsScreen> {
  final controller = TextEditingController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = controller.text.trim().toLowerCase();
    final baseMatches = query.isEmpty
        ? <Medication>[]
        : widget.state.repository.medications.where((m) {
            return m.name.toLowerCase().contains(query) ||
                m.activeIngredient.toLowerCase().contains(query);
          }).toList();

    final ingredients =
        baseMatches.map((m) => m.activeIngredient.toLowerCase()).toSet();
    final matches = query.isEmpty
        ? <Medication>[]
        : widget.state.repository.medications.where((m) {
            return ingredients.contains(m.activeIngredient.toLowerCase());
          }).toList();

    return AnimatedBuilder(
      animation: widget.state,
      builder: (context, _) => MedixPage(
        appBar: AppBar(
          title: const Text('Paralelni i srodni lijekovi'),
        ),
        safeArea: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
          children: [
            TextField(
              controller: controller,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                hintText: 'Upiši lijek ili djelatnu tvar...',
                prefixIcon: Icon(Icons.search_rounded),
              ),
            ),
            const SizedBox(height: 12),
            const MedixSectionCard(
              accent: MedixColors.warning,
              child: Text(
                'Ovaj ekran prikazuje zapise s istom djelatnom tvari iz baze. Ne tvrdi da su lijekovi međusobno zamjenjivi u konkretnom slučaju. Zamjenu treba potvrditi liječnik ili ljekarnik.',
                style: TextStyle(
                  color: MedixColors.textSecondary,
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 14),
            if (query.isEmpty)
              const MedixSectionCard(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MedixIconBubble(
                      icon: Icons.search_rounded,
                      color: MedixColors.cyan,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Upišite naziv lijeka ili djelatnu tvar. MediX će zatim prikazati zapise s istom djelatnom tvari.',
                        style: TextStyle(
                          color: MedixColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else if (matches.isEmpty)
              const MedixSectionCard(
                child: Row(
                  children: [
                    MedixIconBubble(
                      icon: Icons.search_off_rounded,
                      color: MedixColors.textMuted,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Nema podudarnih zapisa za ovaj pojam.',
                        style: TextStyle(
                          color: MedixColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else ...[
              Text(
                '${matches.length} povezanih zapisa',
                style: const TextStyle(
                  color: MedixColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              ...matches.map(
                (medication) => Padding(
                  padding: const EdgeInsets.only(bottom: 9),
                  child: MedicationTile(
                    medication: medication,
                    isFavorite:
                        widget.state.isFavorite(medication.id),
                    onFavorite: () =>
                        widget.state.toggleFavorite(medication.id),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => MedicationDetailScreen(
                          medication: medication,
                          state: widget.state,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
