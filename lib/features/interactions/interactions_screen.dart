import 'package:flutter/material.dart';

import '../../core/theme/medix_theme.dart';
import '../../data/medication_query.dart';
import '../../models/drug_interaction.dart';
import '../../models/medication.dart';
import '../../state/medix_state.dart';
import '../../widgets/medix_page.dart';

class InteractionsScreen extends StatefulWidget {
  const InteractionsScreen({
    required this.state,
    super.key,
  });

  final MedixState state;

  @override
  State<InteractionsScreen> createState() =>
      _InteractionsScreenState();
}

class _InteractionsScreenState extends State<InteractionsScreen> {
  String? firstId;
  String? secondId;

  Future<void> _pickFirst() async {
    final id = await _pickMedication(
      context,
      state: widget.state,
      title: 'Prvi lijek',
      excludedId: secondId,
    );
    if (id != null && mounted) {
      setState(() => firstId = id);
    }
  }

  Future<void> _pickSecond() async {
    final id = await _pickMedication(
      context,
      state: widget.state,
      title: 'Drugi lijek',
      excludedId: firstId,
    );
    if (id != null && mounted) {
      setState(() => secondId = id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final first = firstId == null
        ? null
        : widget.state.medicationById(firstId!);
    final second = secondId == null
        ? null
        : widget.state.medicationById(secondId!);

    final interaction = first != null && second != null
        ? widget.state.repository.interactionBetween(
            first.id,
            second.id,
          )
        : null;

    final checked = first != null && second != null;
    final hasDataset =
        widget.state.repository.interactions.isNotEmpty;

    return MedixPage(
      safeArea: false,
      appBar: AppBar(title: const Text('Provjera interakcija')),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 32),
        children: [
          const MedixSectionCard(
            accent: MedixColors.danger,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MedixIconBubble(
                  icon: Icons.hub_outlined,
                  color: MedixColors.danger,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Odaberite dva lijeka za provjeru. Rezultat je informativan i ne smije biti jedina osnova za promjenu terapije.',
                    style: TextStyle(
                      color: MedixColors.textSecondary,
                      height: 1.45,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _SelectedMedicationCard(
            number: '1',
            label: 'Prvi lijek',
            medication: first,
            onTap: _pickFirst,
            onClear: first == null
                ? null
                : () => setState(() => firstId = null),
          ),
          const SizedBox(height: 10),
          Center(
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: MedixColors.primary.withValues(alpha: .12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add_rounded,
                color: MedixColors.cyan,
              ),
            ),
          ),
          const SizedBox(height: 10),
          _SelectedMedicationCard(
            number: '2',
            label: 'Drugi lijek',
            medication: second,
            onTap: _pickSecond,
            onClear: second == null
                ? null
                : () => setState(() => secondId = null),
          ),
          const SizedBox(height: 16),
          if (checked && interaction != null)
            _ResultCard(
              icon: Icons.warning_amber_rounded,
              title: _severityTitle(interaction.severity),
              body:
                  interaction.summary + '\n\n' + interaction.guidance,
              accent: MedixColors.danger,
            )
          else if (checked && !hasDataset)
            const _ResultCard(
              icon: Icons.shield_outlined,
              title: 'Klinička baza interakcija nije aktivirana',
              body:
                  'MediX za ovu kombinaciju ne prikazuje negativan rezultat jer u ovom buildu nije učitana potpuna licencirana baza interakcija. Odsutnost rezultata zato ne znači da interakcija ne postoji.',
              accent: MedixColors.warning,
            )
          else if (checked)
            const _ResultCard(
              icon: Icons.info_outline_rounded,
              title: 'Nema zapisa u aktivnoj bazi',
              body:
                  'Za odabranu kombinaciju nema pronađenog zapisa. To nije potvrda da je kombinacija bez interakcija; procijenite cjelokupnu terapiju i klinički kontekst.',
              accent: MedixColors.warning,
            ),
          const SizedBox(height: 12),
          const MedixSectionCard(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MedixIconBubble(
                  icon: Icons.medical_information_outlined,
                  color: MedixColors.cyan,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'MediX nikada ne pretvara nedostajući podatak u poruku “nema interakcije”. Provjera je pouzdana samo u opsegu aktivnog i provjerenog kliničkog skupa podataka.',
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
  }

  String _severityTitle(InteractionSeverity severity) {
    return switch (severity) {
      InteractionSeverity.caution => 'Potreban oprez',
      InteractionSeverity.significant =>
        'Moguća značajna interakcija',
    };
  }
}

class _SelectedMedicationCard extends StatelessWidget {
  const _SelectedMedicationCard({
    required this.number,
    required this.label,
    required this.medication,
    required this.onTap,
    this.onClear,
  });

  final String number;
  final String label;
  final Medication? medication;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return MedixSectionCard(
      onTap: onTap,
      accent:
          medication == null ? null : MedixColors.primary,
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: MedixColors.primary.withValues(alpha: .16),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              number,
              style: const TextStyle(
                color: MedixColors.cyan,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: medication == null
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: const TextStyle(
                          color: MedixColors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 3),
                      const Text(
                        'Dodirnite za odabir lijeka',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        medication!.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        medication!.subtitle,
                        style: const TextStyle(
                          color: MedixColors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
          ),
          if (onClear != null)
            IconButton(
              tooltip: 'Ukloni',
              onPressed: onClear,
              icon: const Icon(Icons.close_rounded),
            )
          else
            const Icon(
              Icons.chevron_right_rounded,
              color: MedixColors.textMuted,
            ),
        ],
      ),
    );
  }
}

Future<String?> _pickMedication(
  BuildContext context, {
  required MedixState state,
  required String title,
  String? excludedId,
}) {
  return showModalBottomSheet<String>(
    context: context,
    useSafeArea: true,
    isScrollControlled: true,
    backgroundColor: MedixColors.surface,
    builder: (_) => _MedicationPicker(
      state: state,
      title: title,
      excludedId: excludedId,
    ),
  );
}

class _MedicationPicker extends StatefulWidget {
  const _MedicationPicker({
    required this.state,
    required this.title,
    this.excludedId,
  });

  final MedixState state;
  final String title;
  final String? excludedId;

  @override
  State<_MedicationPicker> createState() =>
      _MedicationPickerState();
}

class _MedicationPickerState extends State<_MedicationPicker> {
  final controller = TextEditingController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final results = applyMedicationQuery(
      widget.state.repository.medications,
      MedicationQuery(text: controller.text),
    )
        .where((item) => item.id != widget.excludedId)
        .take(100)
        .toList(growable: false);

    return SizedBox(
      height: MediaQuery.sizeOf(context).height * .82,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: controller,
                  autofocus: true,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    hintText:
                        'Naziv, djelatna tvar, ATK...',
                    prefixIcon: Icon(Icons.search_rounded),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
              itemCount: results.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: 7),
              itemBuilder: (context, index) {
                final medication = results[index];
                return MedixSectionCard(
                  onTap: () => Navigator.of(context).pop(
                    medication.id,
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      const MedixIconBubble(
                        icon: Icons.medication_outlined,
                        color: MedixColors.cyan,
                        size: 38,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              medication.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              medication.subtitle,
                              style: const TextStyle(
                                color:
                                    MedixColors.textSecondary,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
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

class _ResultCard extends StatelessWidget {
  const _ResultCard({
    required this.icon,
    required this.title,
    required this.body,
    required this.accent,
  });

  final IconData icon;
  final String title;
  final String body;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return MedixSectionCard(
      accent: accent,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MedixIconBubble(
            icon: icon,
            color: accent,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: accent,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  body,
                  style: const TextStyle(
                    color: MedixColors.textSecondary,
                    height: 1.4,
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
