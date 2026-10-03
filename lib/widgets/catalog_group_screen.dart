import 'package:flutter/material.dart';

import '../core/theme/medix_theme.dart';
import '../models/medication.dart';
import '../state/medix_state.dart';
import '../features/medications/medication_detail_screen.dart';
import 'medication_tile.dart';
import 'medix_page.dart';

class MedixCatalogGroupScreen extends StatefulWidget {
  const MedixCatalogGroupScreen({
    required this.title,
    required this.state,
    required this.groups,
    required this.icon,
    required this.color,
    required this.countLabel,
    super.key,
  });

  final String title;
  final MedixState state;
  final Map<String, List<Medication>> groups;
  final IconData icon;
  final Color color;
  final String Function(int count) countLabel;

  @override
  State<MedixCatalogGroupScreen> createState() =>
      _MedixCatalogGroupScreenState();
}

class _MedixCatalogGroupScreenState
    extends State<MedixCatalogGroupScreen> {
  final controller = TextEditingController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = controller.text.trim().toLowerCase();
    final keys = widget.groups.keys
        .where(
          (item) =>
              query.isEmpty || item.toLowerCase().contains(query),
        )
        .toList(growable: false)
      ..sort(
        (a, b) => a.toLowerCase().compareTo(b.toLowerCase()),
      );

    return MedixPage(
      appBar: AppBar(title: Text(widget.title)),
      safeArea: false,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: controller,
              onChanged: (_) => setState(() {}),
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Pretraži...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: controller.text.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Očisti pretragu',
                        onPressed: () {
                          controller.clear();
                          setState(() {});
                        },
                        icon: const Icon(Icons.close_rounded),
                      ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '${keys.length} grupa',
                style: const TextStyle(
                  color: MedixColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          Expanded(
            child: keys.isEmpty
                ? MedixEmptyState(
                    icon: Icons.search_off_rounded,
                    title: 'Nema podudarnih grupa',
                    message:
                        'Promijenite pojam pretrage ili ga očistite.',
                    actionLabel: 'Očisti pretragu',
                    onAction: () {
                      controller.clear();
                      setState(() {});
                    },
                  )
                : ListView.separated(
                    padding:
                        const EdgeInsets.fromLTRB(16, 0, 16, 28),
                    itemCount: keys.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: 9),
                    itemBuilder: (context, index) {
                      final name = keys[index];
                      final medications = widget.groups[name]!;
                      return MedixSectionCard(
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => _CatalogGroupDetail(
                              title: name,
                              medications: medications,
                              state: widget.state,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            MedixIconBubble(
                              icon: widget.icon,
                              color: widget.color,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    widget.countLabel(
                                      medications.length,
                                    ),
                                    style: const TextStyle(
                                      color:
                                          MedixColors.textSecondary,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.chevron_right_rounded,
                              color: MedixColors.textMuted,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _CatalogGroupDetail extends StatelessWidget {
  const _CatalogGroupDetail({
    required this.title,
    required this.medications,
    required this.state,
  });

  final String title;
  final List<Medication> medications;
  final MedixState state;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: state,
      builder: (context, _) => MedixPage(
        appBar: AppBar(title: Text(title)),
        safeArea: false,
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 28),
          itemCount: medications.length,
          separatorBuilder: (_, __) => const SizedBox(height: 9),
          itemBuilder: (context, index) {
            final medication = medications[index];
            return MedicationTile(
              medication: medication,
              isFavorite: state.isFavorite(medication.id),
              onFavorite: () =>
                  state.toggleFavorite(medication.id),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => MedicationDetailScreen(
                    medication: medication,
                    state: state,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
