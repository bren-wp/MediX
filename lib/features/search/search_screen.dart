import 'package:flutter/material.dart';

import '../../core/theme/medix_theme.dart';
import '../../models/medication.dart';
import '../../state/medix_state.dart';
import '../../widgets/medication_tile.dart';
import '../medications/medication_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({
    required this.state,
    super.key,
  });

  final MedixState state;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final controller = TextEditingController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void openMedication(Medication medication) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => MedicationDetailScreen(
          medication: medication,
          state: widget.state,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.state,
      builder: (context, _) {
        final results = widget.state.repository.search(controller.text);

        return Scaffold(
          appBar: AppBar(title: const Text('Pretraga lijekova')),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 4, 18, 14),
                child: TextField(
                  controller: controller,
                  onChanged: (_) => setState(() {}),
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: 'Naziv, djelatna tvar, kategorija...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: controller.text.isEmpty
                        ? null
                        : IconButton(
                            tooltip: 'Očisti',
                            onPressed: () {
                              controller.clear();
                              setState(() {});
                            },
                            icon: const Icon(Icons.close),
                          ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Row(
                  children: [
                    Text(
                      '${results.length} rezultata',
                      style: const TextStyle(
                        color: MedixColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: results.isEmpty
                    ? const Center(
                        child: Text(
                          'Nema pronađenih lijekova.',
                          style: TextStyle(
                            color: MedixColors.textSecondary,
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(
                          18,
                          0,
                          18,
                          30,
                        ),
                        itemCount: results.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final medication = results[index];
                          return MedicationTile(
                            medication: medication,
                            isFavorite: widget.state.isFavorite(
                              medication.id,
                            ),
                            onTap: () => openMedication(medication),
                            onFavorite: () {
                              widget.state.toggleFavorite(
                                medication.id,
                              );
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
