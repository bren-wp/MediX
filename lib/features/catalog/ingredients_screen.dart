import 'package:flutter/material.dart';

import '../../core/theme/medix_theme.dart';
import '../../models/medication.dart';
import '../../state/medix_state.dart';
import '../../widgets/catalog_group_screen.dart';

class IngredientsScreen extends StatelessWidget {
  const IngredientsScreen({
    required this.state,
    super.key,
  });

  final MedixState state;

  @override
  Widget build(BuildContext context) {
    final groups = <String, List<Medication>>{};
    for (final medication in state.repository.medications) {
      final ingredient = medication.activeIngredient.trim();
      if (ingredient.isEmpty) continue;
      groups.putIfAbsent(ingredient, () => []).add(medication);
    }

    return MedixCatalogGroupScreen(
      title: 'Djelatne tvari',
      state: state,
      groups: groups,
      icon: Icons.hub_outlined,
      color: MedixColors.cyan,
      countLabel: (count) =>
          count == 1 ? '1 zapis' : '$count zapisa',
    );
  }
}
