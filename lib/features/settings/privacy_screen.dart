import 'package:flutter/material.dart';

import '../../core/theme/medix_theme.dart';
import '../../widgets/medix_page.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MedixPage(
      safeArea: false,
      appBar: AppBar(title: const Text('Sigurnost i privatnost')),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        children: const [
          _PrivacyCard(
            icon: Icons.person_off_outlined,
            color: MedixColors.cyan,
            title: 'Bez obveznog računa',
            body:
                'MediX ne zahtijeva registraciju ili prijavu za korištenje baze lijekova, favorita, terapije i stručnih alata.',
          ),
          SizedBox(height: 10),
          _PrivacyCard(
            icon: Icons.phone_android_outlined,
            color: MedixColors.primary,
            title: 'Lokalni podaci',
            body:
                'Favoriti, nedavno pregledani lijekovi, spremljena terapija i postavke čuvaju se lokalno na uređaju.',
          ),
          SizedBox(height: 10),
          _PrivacyCard(
            icon: Icons.notifications_active_outlined,
            color: MedixColors.warning,
            title: 'Podsjetnici',
            body:
                'Android dozvole za obavijesti i alarme koriste se samo za podsjetnike terapije koje korisnik sam aktivira.',
          ),
          SizedBox(height: 10),
          _PrivacyCard(
            icon: Icons.medical_information_outlined,
            color: MedixColors.success,
            title: 'Medicinski podaci',
            body:
                'MediX ne traži unos dijagnoze kako bi baza lijekova radila. Podaci koje korisnik upiše u plan terapije ostaju dio lokalnog plana na uređaju.',
          ),
          SizedBox(height: 10),
          _PrivacyCard(
            icon: Icons.security_outlined,
            color: MedixColors.purple,
            title: 'Načelo minimalnih dozvola',
            body:
                'Aplikacija traži samo dozvole koje su potrebne aktiviranoj funkciji. Nepotrebne dozvole ne traže se unaprijed.',
          ),
        ],
      ),
    );
  }
}

class _PrivacyCard extends StatelessWidget {
  const _PrivacyCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return MedixSectionCard(
      accent: color,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MedixIconBubble(
            icon: icon,
            color: color,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  body,
                  style: const TextStyle(
                    color: MedixColors.textSecondary,
                    height: 1.45,
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
