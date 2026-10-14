import 'package:flutter/material.dart';

import '../../core/localization/medix_localizations.dart';
import '../../core/theme/medix_theme.dart';
import '../../models/medication.dart';
import '../../models/medication_access.dart';
import '../../models/medication_price.dart';
import '../../services/platform_navigation.dart';
import '../../widgets/medix_page.dart';

/// One concise answer for both clinical professionals and medicine consumers.
/// All displayed amounts are read from a named, dated source; no personal
/// insurance benefits or pharmacy checkout prices are estimated.
class MedicationAccessPanel extends StatelessWidget {
  const MedicationAccessPanel({required this.medication, super.key});

  final Medication medication;

  static const officialHzzoListUrl =
      'https://hzzo.hr/zdravstvena-zastita/objavljene-liste-lijekova';

  @override
  Widget build(BuildContext context) {
    final loc = MedixLocalizations.of(context);
    final info = MedicationAccessInfo.fromMedication(medication);
    final copayment = info.copayment;
    final pharmacyPrice = info.retailPrice;
    final wholesale = info.wholesalePrice;

    final dispensing = switch (info.prescriptionRequired) {
      true => loc.t('accessPrescriptionRequired'),
      false => loc.t('accessWithoutPrescription'),
      null => loc.t('accessUnverified'),
    };

    final coverage = switch (info.reimbursementStatus) {
      ReimbursementStatus.basic => loc.t('accessBasicCoverage'),
      ReimbursementStatus.supplementary =>
        loc.t('accessSupplementaryList'),
      ReimbursementStatus.none => loc.t('accessUnknownCoverage'),
    };

    return MedixSectionCard(
      accent: MedixColors.cyan,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const MedixIconBubble(
                icon: Icons.medical_information_outlined,
                color: MedixColors.cyan,
                size: 38,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  loc.t('accessTitle'),
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _AccessRow(
            icon: Icons.receipt_long_outlined,
            title: loc.t('accessPrescriptionLabel'),
            value: dispensing,
          ),
          _AccessRow(
            icon: Icons.health_and_safety_outlined,
            title: loc.t('accessMandatoryLabel'),
            value: coverage,
          ),
          _AccessRow(
            icon: Icons.euro_rounded,
            title: loc.t('accessCopaymentLabel'),
            value: copayment?.formatted ?? loc.t('accessNotAvailable'),
            supporting: copayment != null
                ? '${copayment.source} · ${_date(copayment.validFrom)}'
                : null,
          ),
          _AccessRow(
            icon: Icons.shield_outlined,
            title: loc.t('accessSupplementaryInsuranceLabel'),
            value: loc.t('accessPolicyVaries'),
          ),
          _AccessRow(
            icon: Icons.local_pharmacy_outlined,
            title: loc.t('accessRetailLabel'),
            value: pharmacyPrice?.formatted ??
                loc.t('accessRetailUnavailable'),
            supporting: pharmacyPrice != null
                ? '${pharmacyPrice.source} · ${_date(pharmacyPrice.validFrom)}'
                : null,
          ),
          if (wholesale != null)
            _AccessRow(
              icon: Icons.inventory_2_outlined,
              title: loc.t('accessWholesaleLabel'),
              value: wholesale.formatted,
              supporting: '${wholesale.source} · ${_date(wholesale.validFrom)}',
            ),
          const SizedBox(height: 6),
          Text(
            loc.t('accessDisclaimer'),
            style: const TextStyle(
              color: MedixColors.textSecondary,
              fontSize: 11,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 5),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () async {
                final opened = await MedixPlatformNavigation.openExternalUrl(
                  officialHzzoListUrl,
                );
                if (!opened && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(loc.t('openFailed'))),
                  );
                }
              },
              icon: const Icon(Icons.open_in_new_rounded, size: 17),
              label: Text(loc.t('accessOfficialHzzo')),
            ),
          ),
        ],
      ),
    );
  }

  static String _date(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}.'
      '${date.month.toString().padLeft(2, '0')}.'
      '${date.year}.';
}

class _AccessRow extends StatelessWidget {
  const _AccessRow({
    required this.icon,
    required this.title,
    required this.value,
    this.supporting,
  });

  final IconData icon;
  final String title;
  final String value;
  final String? supporting;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 11),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: MedixColors.cyan, size: 19),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: MedixColors.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    color: MedixColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    height: 1.35,
                  ),
                ),
                if (supporting != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    supporting!,
                    style: const TextStyle(
                      color: MedixColors.textMuted,
                      fontSize: 10,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
