import 'package:flutter/material.dart';

import '../../core/theme/medix_theme.dart';
import '../../models/drug_interaction.dart';
import '../../models/medication.dart';
import '../../state/medix_state.dart';

class InteractionsScreen extends StatefulWidget {
  const InteractionsScreen({
    required this.state,
    super.key,
  });

  final MedixState state;

  @override
  State<InteractionsScreen> createState() => _InteractionsScreenState();
}

class _InteractionsScreenState extends State<InteractionsScreen> {
  String? firstId;
  String? secondId;

  @override
  Widget build(BuildContext context) {
    final medications = widget.state.repository.medications;
    final interaction = firstId != null && secondId != null
        ? widget.state.repository.interactionBetween(
            firstId!,
            secondId!,
          )
        : null;
    final checked =
        firstId != null && secondId != null && firstId != secondId;

    return Scaffold(
      appBar: AppBar(title: const Text('Provjera interakcija')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 6, 18, 32),
        children: [
          const Text(
            'Odaberite dva lijeka',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 7),
          const Text(
            'Modul je informativan. Rezultat ne smije biti jedina osnova za promjenu terapije.',
            style: TextStyle(
              color: MedixColors.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          _MedicationDropdown(
            label: 'Prvi lijek',
            value: firstId,
            medications: medications,
            onChanged: (value) {
              setState(() => firstId = value);
            },
          ),
          const SizedBox(height: 12),
          _MedicationDropdown(
            label: 'Drugi lijek',
            value: secondId,
            medications: medications,
            onChanged: (value) {
              setState(() => secondId = value);
            },
          ),
          const SizedBox(height: 18),
          if (firstId != null && firstId == secondId)
            const _ResultCard(
              icon: Icons.info_outline,
              title: 'Odaberite dva različita lijeka',
              body: 'Za provjeru su potrebna dva različita zapisa.',
              accent: MedixColors.warning,
            )
          else if (checked && interaction == null)
            const _ResultCard(
              icon: Icons.check_circle_outline,
              title: 'Nema interakcije u demo bazi',
              body:
                  'To ne znači da interakcija ne postoji. Demo skup nije potpuna klinička baza i ne smije se koristiti za medicinsku odluku.',
              accent: MedixColors.success,
            )
          else if (interaction != null)
            _ResultCard(
              icon: Icons.warning_amber_rounded,
              title: severityTitle(interaction.severity),
              body: '${interaction.summary}\n\n${interaction.guidance}',
              accent: MedixColors.danger,
            ),
          const SizedBox(height: 18),
          const _ResultCard(
            icon: Icons.storage_outlined,
            title: 'Produkcijski zahtjev',
            body:
                'Interakcije u javnom izdanju moraju dolaziti iz licenciranog ili službenog, verzioniranog i provjerljivog izvora podataka.',
            accent: MedixColors.cyan,
          ),
        ],
      ),
    );
  }

  String severityTitle(InteractionSeverity severity) {
    switch (severity) {
      case InteractionSeverity.caution:
        return 'Potreban oprez';
      case InteractionSeverity.significant:
        return 'Moguća značajna interakcija';
    }
  }
}

class _MedicationDropdown extends StatelessWidget {
  const _MedicationDropdown({
    required this.label,
    required this.value,
    required this.medications,
    required this.onChanged,
  });

  final String label;
  final String? value;
  final List<Medication> medications;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.medication_outlined),
      ),
      items: medications
          .map(
            (medication) => DropdownMenuItem<String>(
              value: medication.id,
              child: Text(
                '${medication.name} · ${medication.strength}',
              ),
            ),
          )
          .toList(),
      onChanged: onChanged,
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
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: accent.withValues(alpha: 0.45),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: accent, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: accent,
                    fontWeight: FontWeight.w800,
                    fontSize: 17,
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
