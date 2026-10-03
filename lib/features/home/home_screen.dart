import 'package:flutter/material.dart';

import '../../core/theme/medix_theme.dart';
import '../../models/medication.dart';
import '../../state/medix_state.dart';
import '../../widgets/medication_tile.dart';
import '../../widgets/medix_brand.dart';
import '../../widgets/medix_page.dart';
import '../catalog/ingredients_screen.dart';
import '../catalog/manufacturers_screen.dart';
import '../catalog/medication_collection_screen.dart';
import '../classifications/classifications_screen.dart';
import '../clinical/clinical_tools_screen.dart';
import '../categories/categories_screen.dart';
import '../interactions/interactions_screen.dart';
import '../medications/medication_detail_screen.dart';
import '../smart/smart_search_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    required this.state,
    required this.onSearchRequested,
    super.key,
  });

  final MedixState state;
  final VoidCallback onSearchRequested;

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

  void _push(BuildContext context, Widget screen) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: state,
      builder: (context, _) {
        final displayed = state.recent.isEmpty
            ? state.repository.medications.take(4).toList()
            : state.recent.take(4).toList();
        final categories = state.repository.categories.take(6).toList();

        return MedixPage(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
            children: [
              const Align(
                alignment: Alignment.center,
                child: MedixBrand(),
              ),
              const SizedBox(height: 18),
              Semantics(
                button: true,
                label: 'Pretraži lijekove',
                child: MedixSectionCard(
                  onTap: onSearchRequested,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.search_rounded,
                        color: MedixColors.textSecondary,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Naziv, djelatna tvar, ATK, pakiranje...',
                          style: TextStyle(
                            color: MedixColors.textMuted,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      MedixIconBubble(
                        icon: Icons.tune_rounded,
                        color: MedixColors.cyan,
                        size: 34,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              LayoutBuilder(
                builder: (context, constraints) {
                  final columns =
                      constraints.maxWidth < 430 ? 2 : 3;
                  return GridView.count(
                    crossAxisCount: columns,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    shrinkWrap: true,
                    physics:
                        const NeverScrollableScrollPhysics(),
                    childAspectRatio:
                        columns == 2 ? 1.45 : .92,
                    children: [
                  _HomeAction(
                    icon: Icons.medication_rounded,
                    title: 'Svi lijekovi',
                    subtitle: 'A – Ž',
                    color: MedixColors.cyan,
                    onTap: onSearchRequested,
                  ),
                  _HomeAction(
                    icon: Icons.description_outlined,
                    title: 'Na recept',
                    color: MedixColors.primary,
                    onTap: () => _push(
                      context,
                      MedicationCollectionScreen(
                        title: 'Lijekovi na recept',
                        state: state,
                        filter: (m) => m.requiresPrescription == true,
                        description:
                            'Prikaz lijekova čiji lokalni zapis označava izdavanje na recept.',
                      ),
                    ),
                  ),
                  _HomeAction(
                    icon: Icons.shopping_cart_outlined,
                    title: 'Bez recepta',
                    color: MedixColors.warning,
                    onTap: () => _push(
                      context,
                      MedicationCollectionScreen(
                        title: 'Lijekovi bez recepta',
                        state: state,
                        filter: (m) => m.requiresPrescription == false,
                        description:
                            'Prikaz lijekova čiji lokalni zapis označava izdavanje bez recepta.',
                      ),
                    ),
                  ),
                  _HomeAction(
                    icon: Icons.inventory_2_outlined,
                    title: 'U prometu',
                    subtitle: 'HALMED',
                    color: MedixColors.success,
                    onTap: () => _push(
                      context,
                      MedicationCollectionScreen(
                        title: 'Lijekovi u prometu',
                        state: state,
                        filter: (m) =>
                            m.marketState ==
                            MedicationMarketState.marketed,
                        description:
                            'Prikaz zapisa čiji HALMED status navodi da je lijek stavljen u promet.',
                      ),
                    ),
                  ),
                  _HomeAction(
                    icon: Icons.hub_outlined,
                    title: 'Djelatne tvari',
                    color: MedixColors.primary,
                    onTap: () => _push(
                      context,
                      IngredientsScreen(state: state),
                    ),
                  ),
                  _HomeAction(
                    icon: Icons.apartment_rounded,
                    title: 'Proizvođači',
                    color: MedixColors.cyanSoft,
                    onTap: () => _push(
                      context,
                      ManufacturersScreen(state: state),
                    ),
                  ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 22),
              const Text(
                'Brzi stručni alati',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 9),
              LayoutBuilder(
                builder: (context, constraints) {
                  final columns =
                      constraints.maxWidth < 360 ? 1 : 2;
                  return GridView.count(
                    crossAxisCount: columns,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    shrinkWrap: true,
                    physics:
                        const NeverScrollableScrollPhysics(),
                    childAspectRatio:
                        columns == 1 ? 4.3 : 2.1,
                    children: [
                  _ProfessionalAction(
                    icon: Icons.auto_awesome_rounded,
                    title: 'MediX Smart',
                    subtitle: 'Pametna pretraga',
                    color: MedixColors.cyan,
                    onTap: () => _push(
                      context,
                      SmartSearchScreen(state: state),
                    ),
                  ),
                  _ProfessionalAction(
                    icon: Icons.hub_outlined,
                    title: 'Interakcije',
                    subtitle: 'Provjera terapije',
                    color: MedixColors.danger,
                    onTap: () => _push(
                      context,
                      InteractionsScreen(state: state),
                    ),
                  ),
                  _ProfessionalAction(
                    icon: Icons.calculate_outlined,
                    title: 'Klinički alati',
                    subtitle: '9 kalkulatora',
                    color: MedixColors.primary,
                    onTap: () => _push(
                      context,
                      const ClinicalToolsScreen(),
                    ),
                  ),
                  _ProfessionalAction(
                    icon: Icons.account_tree_outlined,
                    title: 'ATK i MKB-10',
                    subtitle: 'Klasifikacije',
                    color: MedixColors.purple,
                    onTap: () => _push(
                      context,
                      ClassificationsScreen(state: state),
                    ),
                  ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Popularne kategorije',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => _push(
                      context,
                      CategoriesScreen(state: state),
                    ),
                    child: const Text('Prikaži sve'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LayoutBuilder(
                builder: (context, constraints) {
                  final columns =
                      constraints.maxWidth < 430 ? 2 : 3;
                  return GridView.builder(
                    shrinkWrap: true,
                    physics:
                        const NeverScrollableScrollPhysics(),
                    itemCount: categories.length,
                    gridDelegate:
                        SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      childAspectRatio:
                          columns == 2 ? 1.5 : 1.06,
                    ),
                    itemBuilder: (context, index) {
                  final category = categories[index];
                  return _CategoryCard(
                    title: category,
                    color: _categoryColor(index),
                    icon: _categoryIcon(index),
                    onTap: () => _push(
                      context,
                      MedicationCollectionScreen(
                        title: category,
                        state: state,
                        filter: (m) => m.category == category,
                      ),
                    ),
                  );
                    },
                  );
                },
              ),
              const SizedBox(height: 22),
              Text(
                state.recent.isEmpty
                    ? 'Izdvojeni lijekovi'
                    : 'Nedavno pregledano',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              ...displayed.map(
                (medication) => Padding(
                  padding: const EdgeInsets.only(bottom: 9),
                  child: MedicationTile(
                    medication: medication,
                    isFavorite: state.isFavorite(medication.id),
                    onTap: () => _openMedication(context, medication),
                    onFavorite: () => state.toggleFavorite(medication.id),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static Color _categoryColor(int index) {
    const colors = [
      MedixColors.danger,
      MedixColors.primary,
      MedixColors.success,
      MedixColors.warning,
      MedixColors.purple,
      MedixColors.cyan,
    ];
    return colors[index % colors.length];
  }

  static IconData _categoryIcon(int index) {
    const icons = [
      Icons.medication_rounded,
      Icons.health_and_safety_rounded,
      Icons.local_hospital_outlined,
      Icons.favorite_rounded,
      Icons.spa_outlined,
      Icons.air_rounded,
    ];
    return icons[index % icons.length];
  }
}

class _HomeAction extends StatelessWidget {
  const _HomeAction({
    required this.icon,
    required this.title,
    required this.onTap,
    required this.color,
    this.subtitle,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return MedixSectionCard(
      onTap: onTap,
      padding: const EdgeInsets.all(10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          MedixIconBubble(
            icon: icon,
            color: color,
            size: 40,
          ),
          const SizedBox(height: 8),
          Text(
            title,
            maxLines: 2,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              height: 1.1,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle!,
              style: const TextStyle(
                color: MedixColors.textSecondary,
                fontSize: 9,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return MedixSectionCard(
      onTap: onTap,
      padding: const EdgeInsets.all(10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 29),
          const SizedBox(height: 7),
          Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}


class _ProfessionalAction extends StatelessWidget {
  const _ProfessionalAction({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return MedixSectionCard(
      onTap: onTap,
      padding: const EdgeInsets.all(11),
      child: Row(
        children: [
          MedixIconBubble(
            icon: icon,
            color: color,
            size: 38,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: MedixColors.textSecondary,
                    fontSize: 9,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
