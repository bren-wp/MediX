import 'package:flutter/material.dart';

import '../../core/localization/medix_localizations.dart';
import '../../core/theme/medix_theme.dart';
import '../../models/medication.dart';
import '../../services/platform_navigation.dart';
import '../../widgets/medix_page.dart';

/// Open only source-provided documents from recognized public authorities.
/// A generic register link is not presented as a medicine-specific PDF.
class MedicationDocumentsPanel extends StatelessWidget {
  const MedicationDocumentsPanel({required this.medication, super.key});

  final Medication medication;

  static const halmedRegisterUrl =
      'https://www.halmed.hr/Lijekovi/Baza-lijekova/';

  static bool isTrustedSourceUrl(String? value) {
    if (value == null || value.trim().isEmpty) return false;
    final uri = Uri.tryParse(value.trim());
    if (uri == null ||
        uri.scheme.toLowerCase() != 'https' ||
        uri.userInfo.isNotEmpty ||
        uri.hasPort) {
      return false;
    }
    final host = uri.host.toLowerCase();
    return host == 'halmed.hr' ||
        host.endsWith('.halmed.hr') ||
        host == 'ema.europa.eu' ||
        host.endsWith('.ema.europa.eu') ||
        host == 'hzzo.hr' ||
        host.endsWith('.hzzo.hr');
  }

  Future<void> _open(BuildContext context, String url) async {
    var opened = false;
    try {
      opened = await MedixPlatformNavigation.openExternalUrl(url);
    } catch (_) {
      // Missing external handlers should not interrupt medicine browsing.
    }
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(MedixLocalizations.of(context).t('openFailed'))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = MedixLocalizations.of(context);
    final leaf = medication.patientLeafletUrl;
    final smpc = medication.smpcUrl;
    final record = medication.officialRecordUrl;

    return MedixSectionCard(
      accent: MedixColors.cyan,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc.t('medicineDocumentsTitle'),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 7),
          Text(
            loc.t('medicineDocumentsIntro'),
            style: const TextStyle(
              color: MedixColors.textSecondary,
              fontSize: 11,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 9),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              if (isTrustedSourceUrl(leaf))
                OutlinedButton.icon(
                  onPressed: () => _open(context, leaf!),
                  icon: const Icon(Icons.description_outlined, size: 18),
                  label: Text(loc.t('medicinePatientLeaflet')),
                ),
              if (isTrustedSourceUrl(smpc))
                OutlinedButton.icon(
                  onPressed: () => _open(context, smpc!),
                  icon: const Icon(Icons.medical_information_outlined, size: 18),
                  label: Text(loc.t('medicineProfessionalSummary')),
                ),
              if (isTrustedSourceUrl(record) && record != halmedRegisterUrl)
                TextButton.icon(
                  onPressed: () => _open(context, record!),
                  icon: const Icon(Icons.open_in_new_rounded, size: 17),
                  label: Text(loc.t('medicineOfficialSource')),
                ),
              TextButton.icon(
                onPressed: () => _open(context, halmedRegisterUrl),
                icon: const Icon(Icons.search_rounded, size: 17),
                label: Text(loc.t('medicineHalmedRegister')),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
