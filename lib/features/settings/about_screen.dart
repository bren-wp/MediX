import 'package:flutter/material.dart';

import '../../core/theme/medix_theme.dart';
import '../../widgets/medix_brand.dart';
import '../../widgets/medix_page.dart';
import 'sources_screen.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MedixPage(
      appBar: AppBar(title: const Text('O aplikaciji')),
      safeArea: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 28),
        children: [
          const MedixBrand(centered: true),
          const SizedBox(height: 18),
          const Text(
            'Verzija 0.2.0',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: MedixColors.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 18),
          const MedixSectionCard(
            child: Text(
              'MediX je informativna aplikacija za pregled podataka o lijekovima. Ne postavlja dijagnozu, ne propisuje terapiju i ne zamjenjuje službenu uputu, liječnika ili ljekarnika.',
              style: TextStyle(
                color: MedixColors.textSecondary,
                height: 1.45,
              ),
            ),
          ),
          const SizedBox(height: 10),
          MedixSectionCard(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const SourcesScreen(),
              ),
            ),
            child: const Row(
              children: [
                MedixIconBubble(
                  icon: Icons.source_outlined,
                  color: MedixColors.cyan,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Službeni izvori podataka',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
                Icon(Icons.chevron_right_rounded),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
