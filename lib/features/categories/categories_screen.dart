import 'package:flutter/material.dart';

import '../../core/theme/medix_theme.dart';
import '../../models/medication.dart';
import '../../state/medix_state.dart';
import '../../widgets/medication_tile.dart';
import '../medications/medication_detail_screen.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({
    required this.state,
    super.key,
  });

  final MedixState state;

  @override
  Widget build(BuildContext context) {
    final categories = state.repository.categories;

    return Scaffold(
      appBar: AppBar(title: const Text('Kategorije lijekova')),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(18, 4, 18, 30),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final category = categories[index];
          final items = state.repository.byCategory(category);

          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: const BorderSide(color: Color(0xFF173C61)),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 8,
              ),
              leading: const Icon(
                Icons.category_outlined,
                color: MedixColors.cyan,
              ),
              title: Text(
                category,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              subtitle: Text('${items.length} zapisa'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => CategoryMedicationScreen(
                      title: category,
                      medications: items,
                      state: state,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class CategoryMedicationScreen extends StatelessWidget {
  const CategoryMedicationScreen({
    required this.title,
    required this.medications,
    required this.state,
    super.key,
  });

  final String title;
  final List<Medication> medications;
  final MedixState state;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: state,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(title: Text(title)),
          body: ListView.separated(
            padding: const EdgeInsets.fromLTRB(18, 4, 18, 30),
            itemCount: medications.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final medication = medications[index];

              return MedicationTile(
                medication: medication,
                isFavorite: state.isFavorite(medication.id),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => MedicationDetailScreen(
                        medication: medication,
                        state: state,
                      ),
                    ),
                  );
                },
                onFavorite: () => state.toggleFavorite(medication.id),
              );
            },
          ),
        );
      },
    );
  }
}
