import 'package:flutter/material.dart';

import '../../core/app_info.dart';
import '../../core/localization/medix_localizations.dart';
import '../../core/theme/medix_theme.dart';
import '../../widgets/medix_brand.dart';
import '../../widgets/medix_page.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = MedixLocalizations.of(context);
    return MedixPage(
      appBar: AppBar(title: Text(loc.t('aboutTitle'))),
      safeArea: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 28),
        children: [
          const MedixBrand(centered: true),
          const SizedBox(height: 12),
          Text(
            loc.t('aboutTagline'),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: MedixColors.textSecondary,
              fontSize: 14,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'MediX ${MedixAppInfo.displayVersion} · Brendigo',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: MedixColors.cyanSoft,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 18),
          MedixSectionCard(
            accent: MedixColors.cyan,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const MedixIconBubble(
                  icon: Icons.auto_awesome_rounded,
                  color: MedixColors.cyan,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    stateCopy(context),
                    style: const TextStyle(
                      color: MedixColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          MedixSectionCard(
            accent: MedixColors.warning,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const MedixIconBubble(
                  icon: Icons.health_and_safety_outlined,
                  color: MedixColors.warning,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    loc.t('medicalDisclaimer'),
                    style: const TextStyle(
                      color: MedixColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          MedixSectionCard(
            child: Row(
              children: [
                const MedixIconBubble(
                  icon: Icons.lock_outline_rounded,
                  color: MedixColors.success,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    loc.t('privacyNoAccountBody'),
                    style: const TextStyle(
                      color: MedixColors.textSecondary,
                      height: 1.45,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Text(
            loc.t('byBrendigo'),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: MedixColors.textMuted,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  String stateCopy(BuildContext context) {
    final hr = Localizations.localeOf(context).languageCode == 'hr';
    return hr
        ? 'MediX spaja provjerene podatke o lijekovima, naprednu pretragu, terapiju, klasifikacije, cijene i profesionalne kliničke alate u jedno moderno Android iskustvo.'
        : 'MediX brings verified medicine data, advanced search, therapy planning, classifications, pricing and professional clinical tools into one focused Android experience.';
  }
}
