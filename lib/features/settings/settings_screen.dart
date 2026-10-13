import 'package:flutter/material.dart';

import '../../core/app_info.dart';
import '../../core/localization/medix_localizations.dart';
import '../../core/theme/medix_theme.dart';
import '../../services/medix_export_service.dart';
import '../../services/platform_navigation.dart';
import '../../state/medix_state.dart';
import '../../widgets/medix_page.dart';
import 'about_screen.dart';
import 'privacy_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({required this.state, super.key});
  final MedixState state;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool exporting = false;
  bool requestingNotifications = false;

  Future<void> _export() async {
    if (exporting) return;
    setState(() => exporting = true);
    final loc = MedixLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final shared = await MedixExportService().exportAndShare(widget.state);
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text(shared ? loc.t('exportReady') : loc.t('exportFailed'))),
      );
    } catch (_) {
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(loc.t('exportFailed'))));
    } finally {
      if (mounted) setState(() => exporting = false);
    }
  }

  Future<void> _requestNotifications() async {
    if (requestingNotifications) return;
    setState(() => requestingNotifications = true);
    final allowed = await widget.state.requestReminderPermissions();
    if (!mounted) return;
    setState(() => requestingNotifications = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          allowed
              ? (Localizations.localeOf(context).languageCode == 'hr'
                  ? 'Dozvole podsjetnika su uključene.'
                  : 'Therapy reminder permissions are enabled.')
              : (Localizations.localeOf(context).languageCode == 'hr'
                  ? 'Dozvole podsjetnika nisu odobrene.'
                  : 'Reminder permissions were not granted.'),
        ),
      ),
    );
  }

  Future<void> _openUrl(String url) async {
    final opened = await MedixPlatformNavigation.openExternalUrl(url);
    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(MedixLocalizations.of(context).t('openFailed'))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = MedixLocalizations.of(context);
    return MedixPage(
      safeArea: false,
      appBar: AppBar(title: Text(loc.t('settings'))),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 30),
        children: [
          MedixSectionCard(
            accent: MedixColors.cyan,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const MedixIconBubble(icon: Icons.translate_rounded, color: MedixColors.cyan),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(loc.t('language'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
                          const SizedBox(height: 4),
                          Text(loc.t('languageSubtitle'), style: const TextStyle(color: MedixColors.textSecondary, height: 1.35)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  initialValue: widget.state.localeCode,
                  isExpanded: true,
                  decoration: const InputDecoration(prefixIcon: Icon(Icons.language_rounded)),
                  items: MedixLanguages.supported
                      .map((language) => DropdownMenuItem<String>(
                            value: language.code,
                            child: Text(language.nativeName),
                          ))
                      .toList(growable: false),
                  onChanged: (value) {
                    if (value != null) widget.state.setLocale(value);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          _Action(
            icon: Icons.notifications_active_outlined,
            color: MedixColors.warning,
            title: loc.t('notifications'),
            subtitle: loc.t('notificationsSubtitle'),
            busy: requestingNotifications,
            onTap: requestingNotifications ? null : _requestNotifications,
          ),
          _Action(
            icon: Icons.archive_outlined,
            color: MedixColors.success,
            title: loc.t('export'),
            subtitle: loc.t('exportSubtitle'),
            busy: exporting,
            onTap: exporting ? null : _export,
          ),
          _Action(
            icon: Icons.shield_outlined,
            color: MedixColors.success,
            title: loc.t('securityPrivacy'),
            subtitle: loc.t('securityPrivacySubtitle'),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const PrivacyScreen()),
            ),
          ),
          _Action(
            icon: Icons.info_outline_rounded,
            color: MedixColors.primary,
            title: loc.t('about'),
            subtitle: 'MediX ${MedixAppInfo.displayVersion} · Brendigo',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const AboutScreen()),
            ),
          ),
          const SizedBox(height: 14),
          const Divider(),
          TextButton.icon(
            onPressed: () => _openUrl('https://brendigo.com/politika-privatnosti/'),
            icon: const Icon(Icons.open_in_new_rounded, size: 17),
            label: Text(loc.t('privacy')),
          ),
          TextButton.icon(
            onPressed: () => _openUrl('https://brendigo.com/uvjeti-koristenja/'),
            icon: const Icon(Icons.open_in_new_rounded, size: 17),
            label: Text(loc.t('terms')),
          ),
          const SizedBox(height: 12),
          Text(
            '${loc.t('author')}: Brendigo',
            textAlign: TextAlign.center,
            style: const TextStyle(color: MedixColors.textSecondary, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(
            'MediX ${MedixAppInfo.displayVersion}',
            textAlign: TextAlign.center,
            style: const TextStyle(color: MedixColors.textMuted, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _Action extends StatelessWidget {
  const _Action({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.busy = false,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: MedixSectionCard(
        onTap: onTap,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            MedixIconBubble(icon: icon, color: color, size: 40),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(color: MedixColors.textSecondary, fontSize: 11, height: 1.3),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (busy)
              const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2))
            else
              const Icon(Icons.chevron_right_rounded, color: MedixColors.textMuted),
          ],
        ),
      ),
    );
  }
}
