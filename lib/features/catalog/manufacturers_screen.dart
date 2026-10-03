import 'package:flutter/material.dart';

import '../../core/theme/medix_theme.dart';
import '../../models/medication.dart';
import '../../state/medix_state.dart';
import '../../widgets/catalog_group_screen.dart';

class ManufacturersScreen extends StatelessWidget {
  const ManufacturersScreen({
    required this.state,
    super.key,
  });

  final MedixState state;

  @override
  Widget build(BuildContext context) {
    final groups = <String, List<Medication>>{};
    for (final medication in state.repository.medications) {
      final manufacturer = medication.manufacturer?.trim();
      final holder =
          medication.marketingAuthorizationHolder?.trim();
      final name = manufacturer?.isNotEmpty == true
          ? manufacturer!
          : holder?.isNotEmpty == true
              ? holder!
              : null;
      if (name == null) continue;
      groups.putIfAbsent(name, () => []).add(medication);
    }

    return MedixCatalogGroupScreen(
      title: 'Proizvođači i nositelji',
      state: state,
      groups: groups,
      icon: Icons.apartment_rounded,
      color: MedixColors.primary,
      countLabel: (count) =>
          count == 1 ? '1 lijek/pakiranje' : '$count lijekova/pakiranja',
    );
  }
}
