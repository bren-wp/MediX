import 'package:flutter/material.dart';

import '../../core/localization/medix_localizations.dart';
import '../../core/theme/medix_theme.dart';
import '../../widgets/medix_page.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = MedixLocalizations.of(context);
    final cards = [
      (Icons.person_off_outlined, MedixColors.cyan, loc.t('privacyNoAccount'), loc.t('privacyNoAccountBody')),
      (Icons.phone_android_outlined, MedixColors.primary, loc.t('privacyLocal'), loc.t('privacyLocalBody')),
      (Icons.notifications_active_outlined, MedixColors.warning, loc.t('privacyReminders'), loc.t('privacyRemindersBody')),
      (Icons.medical_information_outlined, MedixColors.success, loc.t('privacyMedical'), loc.t('privacyMedicalBody')),
      (Icons.security_outlined, MedixColors.purple, loc.t('privacyPermissions'), loc.t('privacyPermissionsBody')),
    ];

    return MedixPage(
      safeArea: false,
      appBar: AppBar(title: Text(loc.t('privacyTitle'))),
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        itemCount: cards.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final card = cards[index];
          return MedixSectionCard(
            accent: card.$2,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MedixIconBubble(icon: card.$1, color: card.$2),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        card.$3,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        card.$4,
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
        },
      ),
    );
  }
}
