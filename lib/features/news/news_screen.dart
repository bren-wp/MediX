import 'package:flutter/material.dart';

import '../../core/theme/medix_theme.dart';
import '../../widgets/medix_page.dart';

class NewsScreen extends StatelessWidget {
  const NewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const topics = [
      (
        Icons.medication_outlined,
        'Farmakologija',
        'Mehanizmi djelovanja, klase lijekova i praktični sažeci.'
      ),
      (
        Icons.health_and_safety_outlined,
        'Sigurnost lijekova',
        'Kontraindikacije, nuspojave, interakcije i posebna upozorenja.'
      ),
      (
        Icons.stethoscope_outlined,
        'Klinička praksa',
        'Sažeti materijali za brži rad u ambulanti i ljekarni.'
      ),
      (
        Icons.school_outlined,
        'MediX edukacija',
        'Tematski moduli za liječnike, farmaceute i studente.'
      ),
    ];

    return MedixPage(
      appBar: AppBar(title: const Text('Edukacija i novosti')),
      safeArea: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        children: [
          const MedixSectionCard(
            accent: MedixColors.warning,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MedixIconBubble(
                  icon: Icons.school_rounded,
                  color: MedixColors.warning,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Profesionalni sadržaj u MediX-u organiziran je po temama kako bi informacije bile dostupne bez napuštanja aplikacije.',
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
          for (final topic in topics)
            Padding(
              padding: const EdgeInsets.only(bottom: 9),
              child: MedixSectionCard(
                child: Row(
                  children: [
                    MedixIconBubble(
                      icon: topic.$1,
                      color: MedixColors.cyan,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            topic.$2,
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            topic.$3,
                            style: const TextStyle(
                              color: MedixColors.textSecondary,
                              fontSize: 12,
                              height: 1.35,
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
              ),
            ),
        ],
      ),
    );
  }
}
