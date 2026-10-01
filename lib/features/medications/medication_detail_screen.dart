import 'package:flutter/material.dart';

import '../../core/theme/medix_theme.dart';
import '../../models/medication.dart';
import '../../state/medix_state.dart';

class MedicationDetailScreen extends StatefulWidget {
  const MedicationDetailScreen({
    required this.medication,
    required this.state,
    super.key,
  });

  final Medication medication;
  final MedixState state;

  @override
  State<MedicationDetailScreen> createState() =>
      _MedicationDetailScreenState();
}

class _MedicationDetailScreenState
    extends State<MedicationDetailScreen> {
  @override
  void initState() {
    super.initState();
    widget.state.markViewed(widget.medication.id);
  }

  @override
  Widget build(BuildContext context) {
    final medication = widget.medication;

    return AnimatedBuilder(
      animation: widget.state,
      builder: (context, _) {
        final favorite = widget.state.isFavorite(medication.id);

        return Scaffold(
          appBar: AppBar(
            title: Text(medication.name),
            actions: [
              IconButton(
                tooltip: favorite
                    ? 'Ukloni iz favorita'
                    : 'Dodaj u favorite',
                onPressed: () {
                  widget.state.toggleFavorite(medication.id);
                },
                icon: Icon(
                  favorite ? Icons.favorite : Icons.favorite_border,
                ),
                color: favorite ? MedixColors.danger : null,
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 32),
            children: [
              _Hero(medication: medication),
              const SizedBox(height: 16),
              _Notice(
                icon: Icons.verified_user_outlined,
                title: 'Izvor i sigurnost podataka',
                text:
                    '${medication.sourceLabel}. Zadnja demo revizija: '
                    '${medication.lastReviewed.day}.'
                    '${medication.lastReviewed.month}.'
                    '${medication.lastReviewed.year}.',
              ),
              const SizedBox(height: 16),
              _Section(
                icon: Icons.info_outline,
                title: 'Opis',
                body: medication.summary,
              ),
              _Section(
                icon: Icons.medical_services_outlined,
                title: 'Primjena',
                bullets: medication.uses,
              ),
              _Section(
                icon: Icons.schedule_outlined,
                title: 'Doziranje',
                body: medication.dosageGuidance,
              ),
              _Section(
                icon: Icons.monitor_heart_outlined,
                title: 'Nuspojave',
                bullets: medication.sideEffects,
              ),
              _Section(
                icon: Icons.warning_amber_rounded,
                title: 'Upozorenja',
                bullets: medication.warnings,
              ),
              const _Notice(
                icon: Icons.health_and_safety_outlined,
                title: 'Važna napomena',
                text:
                    'MediX je informativni alat i nije zamjena za dijagnozu, propisivanje terapije, službenu uputu o lijeku ili savjet liječnika odnosno ljekarnika.',
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.medication});

  final Medication medication;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: const BorderSide(color: Color(0xFF173C61)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.medication_rounded,
              size: 62,
              color: MedixColors.cyan,
            ),
            const SizedBox(height: 18),
            Text(
              medication.name,
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.7,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              medication.subtitle,
              style: const TextStyle(
                color: MedixColors.textSecondary,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Djelatna tvar: ${medication.activeIngredient}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.icon,
    required this.title,
    this.body,
    this.bullets = const [],
  });

  final IconData icon;
  final String title;
  final String? body;
  final List<String> bullets;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFF173C61)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: MedixColors.cyan),
                  const SizedBox(width: 10),
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 17,
                    ),
                  ),
                ],
              ),
              if (body != null) ...[
                const SizedBox(height: 12),
                Text(
                  body!,
                  style: const TextStyle(
                    color: MedixColors.textSecondary,
                    height: 1.45,
                  ),
                ),
              ],
              if (bullets.isNotEmpty) ...[
                const SizedBox(height: 10),
                ...bullets.map(
                  (bullet) => Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 7),
                          child: Icon(
                            Icons.circle,
                            size: 5,
                            color: MedixColors.cyan,
                          ),
                        ),
                        const SizedBox(width: 9),
                        Expanded(
                          child: Text(
                            bullet,
                            style: const TextStyle(
                              color: MedixColors.textSecondary,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Notice extends StatelessWidget {
  const _Notice({
    required this.icon,
    required this.title,
    required this.text,
  });

  final IconData icon;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0x2014D8EA),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0x5514D8EA)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: MedixColors.cyan),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 5),
                Text(
                  text,
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
