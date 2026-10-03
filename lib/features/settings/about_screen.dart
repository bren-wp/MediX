import 'package:flutter/material.dart';

import '../../core/app_info.dart';
import '../../core/theme/medix_theme.dart';
import '../../widgets/medix_brand.dart';
import '../../widgets/medix_page.dart';

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
            'Verzija ${MedixAppInfo.displayVersion}',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: MedixColors.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 18),
          const MedixSectionCard(
            accent: MedixColors.cyan,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Profesionalna baza lijekova za Hrvatsku',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'MediX je namijenjen zdravstvenim djelatnicima, farmaceutima, studentima medicine i zdravstvenih znanosti te korisnicima koji trebaju brz i strukturiran pregled lijekova, pakiranja, cijena, klasifikacija, interakcija i terapije.',
                  style: TextStyle(
                    color: MedixColors.textSecondary,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          const MedixSectionCard(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MedixIconBubble(
                  icon: Icons.verified_user_outlined,
                  color: MedixColors.success,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Medicinski sadržaj u aplikaciji služi kao informacijska podrška. Kliničku odluku uvijek treba donijeti zdravstveni stručnjak prema stanju pacijenta i aktualnoj dokumentaciji konkretnog lijeka.',
                    style: TextStyle(
                      color: MedixColors.textSecondary,
                      height: 1.45,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          const MedixSectionCard(
            child: Row(
              children: [
                MedixIconBubble(
                  icon: Icons.lock_outline_rounded,
                  color: MedixColors.cyan,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Bez obvezne registracije. Favoriti, terapija i podsjetnici ostaju lokalno na uređaju.',
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
}
