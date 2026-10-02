import 'package:flutter/material.dart';

import '../../core/theme/medix_theme.dart';
import '../../data/medication_query.dart';
import '../../models/medication.dart';
import '../../state/medix_state.dart';
import '../../widgets/medix_page.dart';
import '../medications/medication_detail_screen.dart';

class MedicationCompareScreen extends StatefulWidget {
  const MedicationCompareScreen({
    required this.state,
    super.key,
  });

  final MedixState state;

  @override
  State<MedicationCompareScreen> createState() =>
      _MedicationCompareScreenState();
}

class _MedicationCompareScreenState
    extends State<MedicationCompareScreen> {
  final controller = TextEditingController();
  final List<Medication> selected = [];

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _toggle(Medication medication) {
    setState(() {
      final index = selected.indexWhere(
        (item) => item.id == medication.id,
      );
      if (index >= 0) {
        selected.removeAt(index);
        return;
      }

      if (selected.length < 4) {
        selected.add(medication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Za jedan pregled možete odabrati najviše 4 lijeka.',
            ),
          ),
        );
      }
    });
  }

  void _openComparison() {
    if (selected.length < 2) return;

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _ComparisonResultScreen(
          state: widget.state,
          medications: List<Medication>.unmodifiable(selected),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final results = applyMedicationQuery(
      widget.state.repository.medications,
      MedicationQuery(text: controller.text),
    ).take(120).toList(growable: false);

    return MedixPage(
      safeArea: false,
      appBar: AppBar(
        title: const Text('Usporedba lijekova'),
      ),
      floatingActionButton: selected.length >= 2
          ? FloatingActionButton.extended(
              onPressed: _openComparison,
              icon: const Icon(Icons.compare_arrows_rounded),
              label: Text(
                'Usporedi ' + selected.length.toString(),
              ),
            )
          : null,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
            child: TextField(
              controller: controller,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText:
                    'Pretraži naziv, djelatnu tvar ili ATK...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: controller.text.isEmpty
                    ? null
                    : IconButton(
                        onPressed: () {
                          controller.clear();
                          setState(() {});
                        },
                        icon: const Icon(Icons.close_rounded),
                      ),
              ),
            ),
          ),
          if (selected.isNotEmpty)
            SizedBox(
              height: 48,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: selected
                    .map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(right: 7),
                        child: InputChip(
                          avatar: const Icon(
                            Icons.medication_outlined,
                            size: 17,
                          ),
                          label: Text(item.name),
                          onDeleted: () => _toggle(item),
                        ),
                      ),
                    )
                    .toList(growable: false),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 5, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    selected.length < 2
                        ? 'Odaberite još ' +
                            (2 - selected.length).toString() +
                            ' lijek(a)'
                        : selected.length.toString() +
                            '/4 odabrano',
                    style: const TextStyle(
                      color: MedixColors.textSecondary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (selected.isNotEmpty)
                  TextButton(
                    onPressed: () => setState(selected.clear),
                    child: const Text('Očisti'),
                  ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
              itemCount: results.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final medication = results[index];
                final isSelected = selected.any(
                  (item) => item.id == medication.id,
                );

                return MedixSectionCard(
                  accent:
                      isSelected ? MedixColors.cyan : null,
                  onTap: () => _toggle(medication),
                  child: Row(
                    children: [
                      MedixIconBubble(
                        icon: Icons.medication_outlined,
                        color: isSelected
                            ? MedixColors.cyan
                            : MedixColors.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              medication.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              medication.subtitle,
                              style: const TextStyle(
                                color:
                                    MedixColors.textSecondary,
                                fontSize: 11,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              medication.activeIngredient,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: MedixColors.textMuted,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Checkbox(
                        value: isSelected,
                        onChanged: (_) => _toggle(medication),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ComparisonResultScreen extends StatelessWidget {
  const _ComparisonResultScreen({
    required this.state,
    required this.medications,
  });

  final MedixState state;
  final List<Medication> medications;

  @override
  Widget build(BuildContext context) {
    return MedixPage(
      safeArea: false,
      appBar: AppBar(title: const Text('Usporedba')),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 28),
        children: [
          const MedixSectionCard(
            accent: MedixColors.cyan,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MedixIconBubble(
                  icon: Icons.compare_arrows_rounded,
                  color: MedixColors.cyan,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Usporedba prikazuje administrativne i paketne podatke jedan uz drugi. Ne određuje koji je lijek prikladniji za pojedinog pacijenta.',
                    style: TextStyle(
                      color: MedixColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: _ComparisonTable(
              medications: medications,
              onOpen: (medication) {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => MedicationDetailScreen(
                      medication: medication,
                      state: state,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ComparisonTable extends StatelessWidget {
  const _ComparisonTable({
    required this.medications,
    required this.onOpen,
  });

  final List<Medication> medications;
  final ValueChanged<Medication> onOpen;

  @override
  Widget build(BuildContext context) {
    const labelWidth = 132.0;
    const valueWidth = 190.0;

    final rows = <_ComparisonRow>[
      _ComparisonRow(
        'Djelatna tvar',
        (m) => m.activeIngredient,
      ),
      _ComparisonRow('Jačina', (m) => _valueOrDash(m.strength)),
      _ComparisonRow('Oblik', (m) => _valueOrDash(m.form)),
      _ComparisonRow('ATK', (m) => m.atcCode ?? '—'),
      _ComparisonRow(
        'Izdavanje',
        (m) => m.dispensingLabel,
      ),
      _ComparisonRow(
        'Propisivanje',
        (m) => m.prescribingMode ?? '—',
      ),
      _ComparisonRow(
        'Mjesto izdavanja',
        (m) => m.dispensingPlace ?? '—',
      ),
      _ComparisonRow(
        'Lista',
        (m) => _reimbursement(m.reimbursementStatus),
      ),
      _ComparisonRow(
        'Pakiranje',
        (m) => m.packageDescription ?? '—',
      ),
      _ComparisonRow(
        'Nositelj',
        (m) => m.marketingAuthorizationHolder ?? '—',
      ),
      _ComparisonRow(
        'Proizvođač',
        (m) => m.manufacturer ?? '—',
      ),
      _ComparisonRow(
        'Način primjene',
        (m) => m.route ?? '—',
      ),
      _ComparisonRow(
        'Doplata',
        (m) => m.hzzoCopay?.formatted ?? '—',
      ),
      _ComparisonRow(
        'Veleprodajna cijena',
        (m) => m.maxWholesalePrice?.formatted ?? '—',
      ),
      _ComparisonRow(
        'Broj odobrenja',
        (m) => m.authorizationNumber ?? '—',
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: MedixColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: MedixColors.borderSoft),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                width: labelWidth,
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Text(
                    'Podatak',
                    style: TextStyle(
                      color: MedixColors.textSecondary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
              ...medications.map(
                (medication) => SizedBox(
                  width: valueWidth,
                  child: InkWell(
                    onTap: () => onOpen(medication),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            medication.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: MedixColors.cyan,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 3),
                          const Text(
                            'Otvori detalj',
                            style: TextStyle(
                              color: MedixColors.textMuted,
                              fontSize: 9,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 1),
          ...rows.indexed.map(
            (entry) => _buildRow(
              entry.$2,
              labelWidth,
              valueWidth,
              shaded: entry.$1.isOdd,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(
    _ComparisonRow row,
    double labelWidth,
    double valueWidth, {
    required bool shaded,
  }) {
    final background = shaded
        ? MedixColors.backgroundAlt.withValues(alpha: .55)
        : Colors.transparent;

    return Container(
      color: background,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: labelWidth,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                row.label,
                style: const TextStyle(
                  color: MedixColors.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          ...medications.map(
            (medication) => SizedBox(
              width: valueWidth,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  row.value(medication),
                  style: const TextStyle(
                    fontSize: 11,
                    height: 1.35,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ComparisonRow {
  const _ComparisonRow(this.label, this.value);

  final String label;
  final String Function(Medication medication) value;
}

String _valueOrDash(String value) {
  final trimmed = value.trim();
  return trimmed.isEmpty ||
          trimmed.toLowerCase() == 'nije navedeno' ||
          trimmed.toLowerCase() == 'lijek' ||
          trimmed.toLowerCase() == 'doza'
      ? '—'
      : trimmed;
}

String _reimbursement(ReimbursementStatus status) {
  return switch (status) {
    ReimbursementStatus.none => 'Nije na listi',
    ReimbursementStatus.basic => 'Osnovna lista',
    ReimbursementStatus.supplementary => 'Dopunska lista',
  };
}
