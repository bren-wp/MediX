import 'package:flutter/material.dart';

import '../../core/theme/medix_theme.dart';
import '../../models/medication.dart';
import '../../state/medix_state.dart';
import '../../widgets/medication_tile.dart';
import '../../widgets/medix_brand.dart';
import '../../widgets/medix_page.dart';
import '../catalog/conditions_screen.dart';
import '../catalog/ingredients_screen.dart';
import '../catalog/manufacturers_screen.dart';
import '../catalog/medication_collection_screen.dart';
import '../categories/categories_screen.dart';
import '../medications/medication_detail_screen.dart';

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
              InkWell(
                onTap: onSearchRequested,
                borderRadius: BorderRadius.circular(15),
                child: IgnorePointer(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Pretraži lijek, djelatnu tvar, bolest...',
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: Container(
                        margin: const EdgeInsets.all(7),
                        width: 36,
                        decoration: BoxDecoration(
                          color: MedixColors.primary.withValues(alpha: .16),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.tune_rounded,
                          size: 19,
                          color: MedixColors.cyan,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              GridView.count(
                crossAxisCount: 3,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: .92,
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
                        filter: (m) => m.requiresPrescription,
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
                        filter: (m) => !m.requiresPrescription,
                        description:
                            'Prikaz lijekova čiji lokalni zapis označava izdavanje bez recepta.',
                      ),
                    ),
                  ),
                  _HomeAction(
                    icon: Icons.stethoscope_rounded,
                    title: 'Bolesti i stanja',
                    color: MedixColors.cyan,
                    onTap: () => _push(
                      context,
                      ConditionsScreen(state: state),
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
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: categories.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 1.06,
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
      Icons.gastroenterology_outlined,
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
