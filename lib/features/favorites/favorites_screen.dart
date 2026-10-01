import 'package:flutter/material.dart';

import '../../core/theme/medix_theme.dart';
import '../../state/medix_state.dart';
import '../../widgets/medication_tile.dart';
import '../medications/medication_detail_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({
    required this.state,
    super.key,
  });

  final MedixState state;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: state,
      builder: (context, _) {
        final favorites = state.favorites;

        return Scaffold(
          appBar: AppBar(title: const Text('Favoriti')),
          body: favorites.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(30),
                    child: Text(
                      'Još nema favorita. Dodajte lijek dodirom na ikonu srca.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: MedixColors.textSecondary),
                    ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(18, 4, 18, 30),
                  itemCount: favorites.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final medication = favorites[index];

                    return MedicationTile(
                      medication: medication,
                      isFavorite: true,
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
