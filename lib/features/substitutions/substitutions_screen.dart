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
        appBar: AppBar(title: const Text('Zamjene lijekova')),
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
            ...matches.map(
              (medication) => Padding(
                padding: const EdgeInsets.only(bottom: 9),
                child: MedicationTile(
                  medication: medication,
                  isFavorite: widget.state.isFavorite(medication.id),
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
        ),
      ),
    );
  }
}
