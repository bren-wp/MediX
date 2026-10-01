import 'package:flutter/material.dart';

import '../../core/theme/medix_theme.dart';
import '../../data/official_sources.dart';
import '../../widgets/medix_page.dart';

class NewsScreen extends StatelessWidget {
  const NewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MedixPage(
      appBar: AppBar(title: const Text('Vijesti i savjeti')),
      safeArea: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        children: [
          const MedixSectionCard(
            child: Text(
              'MediX će ovdje prikazivati provjerene regulatorne i zdravstveno-informacijske objave. Trenutno je feed ograničen na službene izvore kako se ne bi prikazivale neprovjerene medicinske vijesti.',
              style: TextStyle(
                color: MedixColors.textSecondary,
                height: 1.45,
              ),
            ),
          ),
          const SizedBox(height: 14),
          ...OfficialSources.all.map(
            (source) => Padding(
              padding: const EdgeInsets.only(bottom: 9),
              child: MedixSectionCard(
                child: Row(
                  children: [
                    const MedixIconBubble(
                      icon: Icons.verified_outlined,
                      color: MedixColors.cyan,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            source.name,
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            source.purpose,
                            style: const TextStyle(
                              color: MedixColors.textSecondary,
                              fontSize: 12,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
