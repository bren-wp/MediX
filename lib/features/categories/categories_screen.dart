import 'package:flutter/material.dart';

import '../../core/theme/medix_theme.dart';
import '../../models/medication.dart';
import '../../state/medix_state.dart';
import '../../widgets/catalog_group_screen.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({
    required this.state,
    super.key,
  });

  final MedixState state;

  @override
  Widget build(BuildContext context) {
    final groups = <String, List<Medication>>{
      for (final category in state.repository.categories)
        category: state.repository.byCategory(category),
    };

    return MedixCatalogGroupScreen(
      title: 'Kategorije lijekova',
      state: state,
      groups: groups,
      icon: Icons.category_outlined,
      color: MedixColors.primary,
      countLabel: (count) =>
          count == 1 ? '1 zapis' : '$count zapisa',
    );
  }
}
