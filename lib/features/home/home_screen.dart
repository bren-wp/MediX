import 'package:flutter/material.dart';

import '../../core/theme/medix_theme.dart';
import '../../models/medication.dart';
import '../../state/medix_state.dart';
import '../../widgets/medication_tile.dart';
import '../../widgets/medix_brand.dart';
import '../interactions/interactions_screen.dart';
import '../medications/medication_detail_screen.dart';
import '../therapy/therapy_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    required this.state,
    required this.onSearchRequested,
    required this.onCategoriesRequested,
    super.key,
  });

  final MedixState state;
  final VoidCallback onSearchRequested;
  final VoidCallback onCategoriesRequested;

  void _openMedication(BuildContext context, Medication medication) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => MedicationDetailScreen(
          medication: medication,
          state: state,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: state,
      builder: (context, _) {
        final displayed = state.recent.isEmpty
            ? state.repository.medications.take(3).toList()
            : state.recent.take(3).toList();

        return SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 20, 18, 34),
            children: [
              const MedixBrand(),
              const SizedBox(height: 28),
              const Text(
                'Brz pristup informacijama o lijekovima.',
                style: TextStyle(
                  fontSize: 27,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.7,
                ),
              ),
              const SizedBox(height: 9),
              const Text(
                'Bez prijave. Bez registracije. Podaci i izvori moraju ostati jasni i provjerljivi.',
                style: TextStyle(
                  color: MedixColors.textSecondary,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 20),
              InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: onSearchRequested,
                child: IgnorePointer(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Pretraži lijek ili djelatnu tvar...',
                      prefixIcon: const Icon(Icons.search),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 1.42,
                children: [
                  _QuickCard(
                    icon: Icons.medication_outlined,
                    title: 'Svi lijekovi',
                    subtitle: '${state.repository.medications.length} demo zapisa',
                    onTap: onSearchRequested,
                  ),
                  _QuickCard(
                    icon: Icons.grid_view_rounded,
                    title: 'Kategorije',
                    subtitle: '${state.repository.categories.length} skupina',
                    onTap: onCategoriesRequested,
                  ),
                  _QuickCard(
                    icon: Icons.hub_outlined,
                    title: 'Interakcije',
                    subtitle: 'Provjeri dva lijeka',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => InteractionsScreen(state: state),
                        ),
                      );
                    },
                  ),
                  _QuickCard(
                    icon: Icons.event_available_outlined,
                    title: 'Moja terapija',
                    subtitle: 'Plan i vremena',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => TherapyScreen(state: state),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 28),
              Text(
                state.recent.isEmpty ? 'Izdvojeni lijekovi' : 'Nedavno pregledano',
                style: const TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              ...displayed.map(
                (medication) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: MedicationTile(
                    medication: medication,
                    isFavorite: state.isFavorite(medication.id),
                    onTap: () => _openMedication(context, medication),
                    onFavorite: () => state.toggleFavorite(medication.id),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0x2214D8EA),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0x4414D8EA)),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.health_and_safety_outlined,
                      color: MedixColors.cyan,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Demo medicinski sadržaj služi razvoju aplikacije. Produkcijska baza mora koristiti validirane i verzionirane izvore.',
                        style: TextStyle(
                          color: MedixColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _QuickCard extends StatelessWidget {
  const _QuickCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: const BorderSide(color: Color(0xFF173C61)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: MedixColors.cyan, size: 28),
              const Spacer(),
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: const TextStyle(
                  color: MedixColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
