import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/medix_theme.dart';
import '../../core/localization/medix_localizations.dart';
import '../../models/medication.dart';
import '../../models/medication_access.dart';
import '../../models/medication_price.dart';
import '../../state/medix_state.dart';
import '../../widgets/medix_page.dart';
import 'medication_access_panel.dart';

class MedicationDetailScreen extends StatefulWidget {
  const MedicationDetailScreen({
    required this.medication,
    required this.state,
    super.key,
  });

  final Medication medication;
  final MedixState state;

  @override
  State<MedicationDetailScreen> createState() =>
      _MedicationDetailScreenState();
}

class _MedicationDetailScreenState extends State<MedicationDetailScreen> {
  @override
  void initState() {
    super.initState();
    widget.state.markViewed(widget.medication.id);
  }

  Future<void> _copySummary() async {
    final medication = widget.medication;
    final access = MedicationAccessInfo.fromMedication(medication);
    final lines = <String>[
      medication.name,
      if (medication.compactSubtitle != null)
        medication.compactSubtitle!,
      if (medication.activeIngredient.trim().isNotEmpty)
        'Djelatna tvar: ' + medication.activeIngredient,
      if (medication.atcCode != null)
        'ATK: ' + medication.atcCode!,
      'Izdavanje: ' + medication.dispensingLabel,
      if (medication.prescribingMode != null)
        'Propisivanje: ' + medication.prescribingMode!,
      if (medication.dispensingPlace != null)
        'Mjesto izdavanja: ' + medication.dispensingPlace!,
      if (medication.packageDescription != null)
        'Pakiranje: ' + medication.packageDescription!,
      if (access.copayment != null)
        'Potvrđena HZZO doplata za pakiranje: ' +
            access.copayment!.formatted,
      if (access.wholesalePrice != null)
        'Najviša veleprodajna cijena (nije maloprodajna): ' +
            access.wholesalePrice!.formatted,
      'Izvor podataka o lijeku: ' + medication.sourceLabel,
      if (access.hasConfirmedHzzoList)
        'HZZO lista: ' + (medication.hzzoListSource ?? 'HZZO'),
      if (access.hasConfirmedHzzoList &&
          medication.hzzoListEffectiveDate != null)
        'HZZO lista u primjeni od: ' +
            medication.hzzoListEffectiveDate!
                .toIso8601String()
                .split('T').first,
      'Zadnja provjera: ' +
          medication.lastReviewed.toIso8601String().split('T').first,
      'Iznosi nisu osobna cijena u ljekarni; '
          'pokriće dopunskog osiguranja potrebno je potvrditi.',
    ];

    await Clipboard.setData(
      ClipboardData(text: lines.join('\n')),
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Podaci o lijeku kopirani su u međuspremnik.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final medication = widget.medication;

    return AnimatedBuilder(
      animation: widget.state,
      builder: (context, _) {
        final favorite = widget.state.isFavorite(medication.id);

        return MedixPage(
          safeArea: false,
          appBar: AppBar(
            title: Text(medication.name),
            actions: [
              IconButton(
                tooltip: 'Kopiraj sažetak',
                onPressed: _copySummary,
                icon: const Icon(Icons.content_copy_rounded),
              ),
              IconButton(
                tooltip: favorite
                    ? 'Ukloni iz favorita'
                    : 'Dodaj u favorite',
                onPressed: () {
                  widget.state.toggleFavorite(medication.id);
                },
                icon: Icon(
                  favorite ? Icons.favorite : Icons.favorite_border,
                ),
                color: favorite ? MedixColors.danger : null,
              ),
            ],
          ),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            children: [
              _Hero(medication: medication),
              const SizedBox(height: 12),
              _Badges(medication: medication),
              const SizedBox(height: 12),
              MedicationAccessPanel(medication: medication),
              const SizedBox(height: 12),
              _OverviewSection(medication: medication),
              const SizedBox(height: 12),
              if (_hasOfficialMetadata(medication)) ...[
                ExpansionTile(
                  tilePadding: const EdgeInsets.symmetric(horizontal: 12),
                  title: Text(
                    MedixLocalizations.of(context).t('professionalDetails'),
                  ),
                  leading: const Icon(Icons.fact_check_outlined),
                  children: [_MetadataSection(medication: medication)],
                ),
                const SizedBox(height: 10),
              ],
              if (MedicationAccessInfo.verifiedPrices(medication).isNotEmpty) ...[
                ExpansionTile(
                  tilePadding: const EdgeInsets.symmetric(horizontal: 12),
                  title: Text(
                    MedixLocalizations.of(context).t('accessPriceDetails'),
                  ),
                  leading: const Icon(Icons.price_check_outlined),
                  children: [_PriceSection(medication: medication)],
                ),
                const SizedBox(height: 12),
              ],
              _ExpandableSection(
                icon: Icons.medical_services_outlined,
                title: 'Za što se koristi?',
                bullets: medication.uses,
              ),
              _ExpandableSection(
                icon: Icons.science_outlined,
                title: 'Kako djeluje?',
                body: medication.summary,
              ),
              _ExpandableSection(
                icon: Icons.schedule_rounded,
                title: 'Doziranje',
                body: medication.dosageGuidance,
                color: MedixColors.success,
              ),
              _ExpandableSection(
                icon: Icons.favorite_rounded,
                title: 'Nuspojave',
                bullets: medication.sideEffects,
                color: MedixColors.danger,
              ),
              _ExpandableSection(
                icon: Icons.warning_amber_rounded,
                title: 'Upozorenja',
                bullets: medication.warnings,
                color: MedixColors.warning,
              ),
              const SizedBox(height: 4),
              const MedixSectionCard(
                accent: MedixColors.warning,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MedixIconBubble(
                      icon: Icons.health_and_safety_outlined,
                      color: MedixColors.warning,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'MediX je informativni alat. Ne postavlja dijagnozu, ne propisuje terapiju i ne zamjenjuje službenu uputu o lijeku, liječnika ili ljekarnika.',
                        style: TextStyle(
                          color: MedixColors.textSecondary,
                          height: 1.45,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  bool _hasOfficialMetadata(Medication medication) {
    return medication.atcCode != null ||
        medication.authorizationNumber != null ||
        medication.marketingAuthorizationHolder != null ||
        medication.manufacturer != null ||
        medication.localRepresentative != null ||
        medication.route != null ||
        medication.packageDescription != null ||
        medication.dispensingStatus != null ||
        medication.prescribingMode != null ||
        medication.dispensingPlace != null ||
        medication.marketStatus != null ||
        medication.shortageStatus != null ||
        medication.isOnHzzoList;
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.medication});

  final Medication medication;

  @override
  Widget build(BuildContext context) {
    return MedixSectionCard(
      accent: MedixColors.primary,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const MedixIconBubble(
            icon: Icons.medication_outlined,
            color: MedixColors.cyan,
            size: 54,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  medication.name,
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                    height: 1.2,
                  ),
                ),
                if (medication.compactSubtitle != null) ...[
                  const SizedBox(height: 5),
                  Text(
                    medication.compactSubtitle!,
                    style: const TextStyle(
                      color: MedixColors.textSecondary,
                      fontSize: 13,
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

class _Badges extends StatelessWidget {
  const _Badges({required this.medication});

  final Medication medication;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 7,
      runSpacing: 7,
      children: [
        _Badge(
          icon: medication.requiresPrescription == true
              ? Icons.description_outlined
              : medication.requiresPrescription == false
                  ? Icons.add_circle_outline
                  : Icons.help_outline_rounded,
          label: medication.requiresPrescription == true
              ? 'Na recept'
              : medication.requiresPrescription == false
                  ? 'Bez recepta'
                  : 'Izdavanje: —',
          color: medication.requiresPrescription == true
              ? MedixColors.primary
              : medication.requiresPrescription == false
                  ? MedixColors.success
                  : MedixColors.textSecondary,
        ),
        _Badge(
          icon: Icons.category_outlined,
          label: medication.category,
          color: MedixColors.primary,
        ),
        if (medication.atcCode != null)
          _Badge(
            icon: Icons.tag_rounded,
            label: 'ATK ${medication.atcCode}',
            color: MedixColors.cyan,
          ),
        if (medication.marketState ==
            MedicationMarketState.temporaryInterruption)
          const _Badge(
            icon: Icons.pause_circle_outline_rounded,
            label: 'Privremeni prekid opskrbe',
            color: MedixColors.warning,
          )
        else if (medication.marketState ==
            MedicationMarketState.notMarketed)
          const _Badge(
            icon: Icons.remove_circle_outline_rounded,
            label: 'Nije stavljeno u promet',
            color: MedixColors.textSecondary,
          ),
        if (medication.shortageState ==
            MedicationShortageState.reported)
          const _Badge(
            icon: Icons.warning_amber_rounded,
            label: 'Prijavljena nestašica',
            color: MedixColors.danger,
          ),
        if (medication.isOnHzzoList)
          _Badge(
            icon: Icons.verified_outlined,
            label: medication.reimbursementStatus ==
                    ReimbursementStatus.basic
                ? 'Osnovna lista'
                : 'Dopunska lista',
            color: MedixColors.success,
          ),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .15),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: .35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _OverviewSection extends StatelessWidget {
  const _OverviewSection({required this.medication});

  final Medication medication;

  @override
  Widget build(BuildContext context) {
    return MedixSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Opis lijeka',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 9),
          Text(
            medication.summary,
            style: const TextStyle(
              color: MedixColors.textSecondary,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 12),
          if (medication.activeIngredient.trim().isNotEmpty)
            _InfoRow(
              label: 'Djelatna tvar',
              value: medication.activeIngredient,
            ),
          if (medication.compactSubtitle != null)
            _InfoRow(
              label: 'Oblik i jačina',
              value: medication.compactSubtitle!,
            ),
        ],
      ),
    );
  }
}

class _MetadataSection extends StatelessWidget {
  const _MetadataSection({required this.medication});

  final Medication medication;

  @override
  Widget build(BuildContext context) {
    final reviewed = medication.lastReviewed;
    final reviewedLabel =
        '${reviewed.day.toString().padLeft(2, '0')}.'
        '${reviewed.month.toString().padLeft(2, '0')}.'
        '${reviewed.year}.';

    final rows = <(String, String)>[
      if (medication.atcCode != null) ('ATK šifra', medication.atcCode!),
      if (medication.authorizationNumber != null)
        ('Broj odobrenja', medication.authorizationNumber!),
      if (medication.marketingAuthorizationHolder != null)
        ('Nositelj odobrenja', medication.marketingAuthorizationHolder!),
      if (medication.manufacturer != null)
        ('Proizvođač', medication.manufacturer!),
      if (medication.localRepresentative != null)
        ('Lokalni predstavnik', medication.localRepresentative!),
      if (medication.dispensingStatus != null)
        ('Način izdavanja', medication.dispensingStatus!),
      if (medication.prescribingMode != null)
        ('Način propisivanja', medication.prescribingMode!),
      if (medication.dispensingPlace != null)
        ('Mjesto izdavanja', medication.dispensingPlace!),
      if (medication.route != null)
        ('Način primjene', medication.route!),
      if (medication.packageDescription != null)
        ('Pakiranje', medication.packageDescription!),
      if (medication.marketStatus != null)
        ('Status lijeka na tržištu', medication.marketStatus!),
      if (medication.shortageStatus != null)
        ('Status nestašice', medication.shortageStatus!),
      if (medication.hzzoGuidelineCode != null)
        ('Oznaka smjernice', medication.hzzoGuidelineCode!),
      if (medication.sourceLabel.trim().isNotEmpty)
        ('Izvor podataka', medication.sourceLabel),
      ('Zadnja provjera', reviewedLabel),
    ];

    return MedixSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              MedixIconBubble(
                icon: Icons.fact_check_outlined,
                color: MedixColors.cyan,
                size: 38,
              ),
              SizedBox(width: 10),
              Text(
                'Podaci o lijeku',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...rows.map(
            (row) => _InfoRow(label: row.$1, value: row.$2),
          ),
        ],
      ),
    );
  }
}

class _PriceSection extends StatelessWidget {
  const _PriceSection({required this.medication});

  final Medication medication;

  @override
  Widget build(BuildContext context) {
    return MedixSectionCard(
      accent: MedixColors.success,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              MedixIconBubble(
                icon: Icons.euro_rounded,
                color: MedixColors.success,
                size: 38,
              ),
              SizedBox(width: 10),
              Text(
                'Cijene i doplate',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...MedicationAccessInfo.verifiedPrices(medication).map(
            (price) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: MedixColors.backgroundAlt,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: MedixColors.borderSoft),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _priceLabel(price.kind),
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        Text(
                          price.formatted,
                          style: const TextStyle(
                            color: MedixColors.success,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Vrijedi od ${price.validFrom.day}.${price.validFrom.month}.${price.validFrom.year}.',
                      style: const TextStyle(
                        color: MedixColors.textMuted,
                        fontSize: 10,
                      ),
                    ),
                    if (price.note != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        price.note!,
                        style: const TextStyle(
                          color: MedixColors.textSecondary,
                          fontSize: 10,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          const Text(
            'Doplata, referentni iznos, najviša evidentirana veleprodajna cijena i maloprodajna cijena nisu isti podatak. MediX ih prikazuje odvojeno kada su dostupni.',
            style: TextStyle(
              color: MedixColors.textSecondary,
              fontSize: 11,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  String _priceLabel(MedicationPriceKind kind) {
    return switch (kind) {
      MedicationPriceKind.hzzoCopay => 'Doplata',
      MedicationPriceKind.hzzoReimbursement => 'Referentni iznos',
      MedicationPriceKind.maxWholesale =>
        'Najviša dozvoljena cijena na veliko',
      MedicationPriceKind.pharmacyRetail => 'Maloprodajna cijena ljekarne',
    };
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 118,
            child: Text(
              label,
              style: const TextStyle(
                color: MedixColors.textMuted,
                fontSize: 11,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: MedixColors.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExpandableSection extends StatelessWidget {
  const _ExpandableSection({
    required this.icon,
    required this.title,
    this.body,
    this.bullets = const [],
    this.color = MedixColors.cyan,
  });

  final IconData icon;
  final String title;
  final String? body;
  final List<String> bullets;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          collapsedBackgroundColor: MedixColors.surface,
          backgroundColor: MedixColors.surface,
          tilePadding: const EdgeInsets.symmetric(horizontal: 14),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: const BorderSide(color: MedixColors.borderSoft),
          ),
          collapsedShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: const BorderSide(color: MedixColors.borderSoft),
          ),
          leading: MedixIconBubble(
            icon: icon,
            color: color,
            size: 34,
          ),
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
          children: [
            if (body != null)
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  body!,
                  style: const TextStyle(
                    color: MedixColors.textSecondary,
                    height: 1.45,
                  ),
                ),
              ),
            ...bullets.map(
              (bullet) => Padding(
                padding: const EdgeInsets.only(top: 7),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Icon(
                        Icons.circle,
                        size: 5,
                        color: color,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        bullet,
                        style: const TextStyle(
                          color: MedixColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
