import 'package:flutter/material.dart';

import '../../core/theme/medix_theme.dart';
import '../../core/localization/medix_localizations.dart';
import '../../data/medication_query.dart';
import '../../models/medication.dart';
import '../../state/medix_state.dart';
import '../../widgets/medication_tile.dart';
import '../../widgets/medix_page.dart';
import '../compare/medication_compare_screen.dart';
import '../medications/medication_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({
    required this.state,
    super.key,
  });

  final MedixState state;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final controller = TextEditingController();
  MedicationQuery query = const MedicationQuery();

  late final List<String> forms;
  late final List<String> holders;
  late final List<String> atcGroups;

  @override
  void initState() {
    super.initState();

    forms = widget.state.repository.medications
        .map((item) => item.form.trim())
        .where((item) => item.isNotEmpty)
        .toSet()
        .toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

    holders = widget.state.repository.medications
        .expand(
          (item) => [
            item.marketingAuthorizationHolder,
            item.manufacturer,
          ],
        )
        .whereType<String>()
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toSet()
        .toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

    atcGroups = widget.state.repository.medications
        .expand(
          (item) => (item.atcCode ?? '')
              .toUpperCase()
              .split(RegExp(r'[;,]'))
              .map((code) => code.trim())
              .where((code) => code.isNotEmpty),
        )
        .map((code) => code.substring(0, 1))
        .toSet()
        .toList()
      ..sort();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _openMedication(Medication medication) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => MedicationDetailScreen(
          medication: medication,
          state: widget.state,
        ),
      ),
    );
  }

  Future<void> _openFilters() async {
    final next = await showModalBottomSheet<MedicationQuery>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: MedixColors.surface,
      builder: (_) => _FilterSheet(
        initial: query,
        forms: forms,
        holders: holders,
        atcGroups: atcGroups,
      ),
    );

    if (next != null && mounted) {
      setState(() => query = next);
    }
  }

  void _setSort(MedicationSort sort) {
    setState(() => query = query.copyWith(sort: sort));
  }

  void _setQuickFilter({
    DispensingFilter dispensing = DispensingFilter.all,
    ReimbursementFilter reimbursement = ReimbursementFilter.all,
    PriceFilter price = PriceFilter.all,
  }) {
    setState(() {
      query = query.copyWith(
        dispensing: dispensing,
        reimbursement: reimbursement,
        price: price,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.state,
      builder: (context, _) {
        final loc = MedixLocalizations.of(context);
        final effectiveQuery = query.copyWith(text: controller.text);
        final results = applyMedicationQuery(
          widget.state.repository.medications,
          effectiveQuery,
        );

        return MedixPage(
          safeArea: false,
          appBar: AppBar(
            title: Text(loc.t('searchTitle')),
            actions: [
              IconButton(
                tooltip: loc.t('compareMedicines'),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => MedicationCompareScreen(
                        state: widget.state,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.compare_arrows_rounded),
              ),
              PopupMenuButton<MedicationSort>(
                tooltip: loc.t('sort'),
                initialValue: query.sort,
                onSelected: _setSort,
                icon: const Icon(Icons.sort_rounded),
                itemBuilder: (_) => [
                  PopupMenuItem(
                    value: MedicationSort.nameAsc,
                    child: Text(loc.t('sortName')),
                  ),
                  PopupMenuItem(
                    value: MedicationSort.ingredientAsc,
                    child: Text(loc.t('sortIngredient')),
                  ),
                  PopupMenuItem(
                    value: MedicationSort.atcAsc,
                    child: Text(loc.t('sortAtc')),
                  ),
                  PopupMenuItem(
                    value: MedicationSort.copayAsc,
                    child: Text(loc.t('sortCopayAsc')),
                  ),
                  PopupMenuItem(
                    value: MedicationSort.copayDesc,
                    child: Text(loc.t('sortCopayDesc')),
                  ),
                  PopupMenuItem(
                    value: MedicationSort.wholesaleAsc,
                    child: Text(loc.t('sortWholesaleAsc')),
                  ),
                  PopupMenuItem(
                    value: MedicationSort.wholesaleDesc,
                    child: Text(loc.t('sortWholesaleDesc')),
                  ),
                ],
              ),
            ],
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 6, 16, 8),
                child: TextField(
                  controller: controller,
                  onChanged: (_) => setState(() {}),
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: loc.t('searchHint'),
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: controller.text.isEmpty
                        ? null
                        : IconButton(
                            tooltip: loc.t('clearSearch'),
                            onPressed: () {
                              controller.clear();
                              setState(() {});
                            },
                            icon: const Icon(Icons.close_rounded),
                          ),
                  ),
                ),
              ),
              SizedBox(
                height: 46,
                child: ListView(
                  key: const Key('medicationQuickFilters'),
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    _quickChoice(
                      loc.t('quickAll'),
                      query.dispensing == DispensingFilter.all &&
                          query.reimbursement == ReimbursementFilter.all &&
                          query.price == PriceFilter.all,
                      () => _setQuickFilter(),
                    ),
                    _quickChoice(
                      loc.t('quickPrescription'),
                      query.dispensing == DispensingFilter.prescription,
                      () => _setQuickFilter(
                        dispensing: query.dispensing ==
                                DispensingFilter.prescription
                            ? DispensingFilter.all
                            : DispensingFilter.prescription,
                      ),
                    ),
                    _quickChoice(
                      loc.t('quickOtc'),
                      query.dispensing == DispensingFilter.otc,
                      () => _setQuickFilter(
                        dispensing: query.dispensing == DispensingFilter.otc
                            ? DispensingFilter.all
                            : DispensingFilter.otc,
                      ),
                    ),
                    _quickChoice(
                      loc.t('quickBasicList'),
                      query.reimbursement == ReimbursementFilter.basic,
                      () => _setQuickFilter(
                        reimbursement: query.reimbursement ==
                                ReimbursementFilter.basic
                            ? ReimbursementFilter.all
                            : ReimbursementFilter.basic,
                      ),
                    ),
                    _quickChoice(
                      loc.t('quickSupplementaryList'),
                      query.reimbursement == ReimbursementFilter.supplementary,
                      () => _setQuickFilter(
                        reimbursement: query.reimbursement ==
                                ReimbursementFilter.supplementary
                            ? ReimbursementFilter.all
                            : ReimbursementFilter.supplementary,
                      ),
                    ),
                    _quickChoice(
                      loc.t('quickCopay'),
                      query.price == PriceFilter.copay,
                      () => _setQuickFilter(
                        price: query.price == PriceFilter.copay
                            ? PriceFilter.all
                            : PriceFilter.copay,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 2, 16, 6),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        results.length == 1
                            ? loc.t('resultOne')
                            : loc.tArgs('results', {'count': results.length}),
                        style: const TextStyle(
                          color: MedixColors.textSecondary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    FilledButton.tonalIcon(
                      onPressed: _openFilters,
                      icon: Icon(
                        query.hasFilters
                            ? Icons.filter_alt_rounded
                            : Icons.filter_alt_outlined,
                        size: 18,
                      ),
                      label: Text(
                        query.hasFilters
                            ? '${loc.t('filters')} · ${_activeFilterCount(query)}'
                            : loc.t('filters'),
                      ),
                    ),
                  ],
                ),
              ),
              if (query.hasFilters)
                SizedBox(
                  height: 43,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: _activeChips(query),
                  ),
                ),
              const SizedBox(height: 4),
              Expanded(
                child: results.isEmpty
                    ? MedixEmptyState(
                        icon: Icons.search_off_rounded,
                        title: loc.t('noResultsTitle'),
                        message: loc.t('noResultsBody'),
                        actionLabel: loc.t('resetSearch'),
                        onAction: () {
                          controller.clear();
                          setState(() {
                            query = const MedicationQuery();
                          });
                        },
                      )
                    : ListView.separated(
                        padding:
                            const EdgeInsets.fromLTRB(16, 4, 16, 30),
                        itemCount: results.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 9),
                        itemBuilder: (context, index) {
                          final medication = results[index];
                          return MedicationTile(
                            medication: medication,
                            isFavorite: widget.state.isFavorite(
                              medication.id,
                            ),
                            onTap: () =>
                                _openMedication(medication),
                            onFavorite: () {
                              widget.state.toggleFavorite(
                                medication.id,
                              );
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _quickChoice(String label, bool selected, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 7),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        visualDensity: VisualDensity.compact,
        labelStyle: const TextStyle(fontSize: 12),
      ),
    );
  }

  List<Widget> _activeChips(MedicationQuery current) {
    final chips = <Widget>[];

    void addChip(String label, VoidCallback onDeleted) {
      chips.add(
        Padding(
          padding: const EdgeInsets.only(right: 7),
          child: InputChip(
            label: Text(label),
            onDeleted: onDeleted,
            deleteIcon: const Icon(Icons.close_rounded, size: 16),
          ),
        ),
      );
    }

    if (current.dispensing != DispensingFilter.all) {
      addChip(
        _dispensingLabel(current.dispensing, hr: Localizations.localeOf(context).languageCode == 'hr'),
        () => setState(
          () => query = query.copyWith(
            dispensing: DispensingFilter.all,
          ),
        ),
      );
    }

    if (current.reimbursement != ReimbursementFilter.all) {
      addChip(
        _reimbursementLabel(current.reimbursement, hr: Localizations.localeOf(context).languageCode == 'hr'),
        () => setState(
          () => query = query.copyWith(
            reimbursement: ReimbursementFilter.all,
          ),
        ),
      );
    }

    if (current.price != PriceFilter.all) {
      addChip(
        _priceLabel(current.price, hr: Localizations.localeOf(context).languageCode == 'hr'),
        () => setState(
          () => query = query.copyWith(price: PriceFilter.all),
        ),
      );
    }

    if (current.market != MarketFilter.all) {
      addChip(
        _marketLabel(current.market, hr: Localizations.localeOf(context).languageCode == 'hr'),
        () => setState(
          () => query = query.copyWith(market: MarketFilter.all),
        ),
      );
    }

    if (current.shortage != ShortageFilter.all) {
      addChip(
        _shortageLabel(current.shortage, hr: Localizations.localeOf(context).languageCode == 'hr'),
        () => setState(
          () => query = query.copyWith(shortage: ShortageFilter.all),
        ),
      );
    }

    if (current.atcGroup != null) {
      addChip(
        'ATK ' + current.atcGroup!,
        () => setState(
          () => query = query.copyWith(clearAtcGroup: true),
        ),
      );
    }

    if (current.form != null) {
      addChip(
        current.form!,
        () => setState(
          () => query = query.copyWith(clearForm: true),
        ),
      );
    }

    if (current.holder != null) {
      addChip(
        current.holder!,
        () => setState(
          () => query = query.copyWith(clearHolder: true),
        ),
      );
    }

    return chips;
  }

}

class _FilterSheet extends StatefulWidget {
  const _FilterSheet({
    required this.initial,
    required this.forms,
    required this.holders,
    required this.atcGroups,
  });

  final MedicationQuery initial;
  final List<String> forms;
  final List<String> holders;
  final List<String> atcGroups;

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late MedicationQuery value;

  @override
  void initState() {
    super.initState();
    value = widget.initial;
  }

  void _reset() {
    setState(() {
      value = value.clearFilters();
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = MedixLocalizations.of(context);
    final hr = Localizations.localeOf(context).languageCode == 'hr';
    final bottom = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(18, 18, 18, 18 + bottom),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    loc.t('advancedFilters'),
                    style: TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: _reset,
                  child: Text(loc.t('reset')),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              loc.t('filterDescription'),
              style: TextStyle(
                color: MedixColors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 18),
            _SectionLabel(loc.t('dispensing')),
            SegmentedButton<DispensingFilter>(
              showSelectedIcon: false,
              segments: [
                ButtonSegment(
                  value: DispensingFilter.all,
                  label: Text(loc.t('all')),
                ),
                ButtonSegment(
                  value: DispensingFilter.prescription,
                  label: Text(loc.t('prescription')),
                ),
                ButtonSegment(
                  value: DispensingFilter.otc,
                  label: Text(loc.t('otc')),
                ),
                ButtonSegment(
                  value: DispensingFilter.unknown,
                  label: Text(loc.t('unknown')),
                ),
              ],
              selected: {value.dispensing},
              onSelectionChanged: (selection) {
                setState(
                  () => value = value.copyWith(
                    dispensing: selection.first,
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            _Dropdown<ReimbursementFilter>(
              label: loc.t('listStatus'),
              value: value.reimbursement,
              items: ReimbursementFilter.values,
              itemLabel: (item) => _reimbursementLabel(item, hr: hr),
              onChanged: (next) {
                setState(
                  () => value = value.copyWith(
                    reimbursement: next,
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            _Dropdown<PriceFilter>(
              label: loc.t('price'),
              value: value.price,
              items: PriceFilter.values,
              itemLabel: (item) => _priceLabel(item, hr: hr),
              onChanged: (next) {
                setState(
                  () => value = value.copyWith(price: next),
                );
              },
            ),
            const SizedBox(height: 12),
            _Dropdown<MarketFilter>(
              label: loc.t('marketStatus'),
              value: value.market,
              items: MarketFilter.values,
              itemLabel: (item) => _marketLabel(item, hr: hr),
              onChanged: (next) {
                setState(
                  () => value = value.copyWith(market: next),
                );
              },
            ),
            const SizedBox(height: 12),
            _Dropdown<ShortageFilter>(
              label: loc.t('shortage'),
              value: value.shortage,
              items: ShortageFilter.values,
              itemLabel: (item) => _shortageLabel(item, hr: hr),
              onChanged: (next) {
                setState(
                  () => value = value.copyWith(shortage: next),
                );
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String?>(
              key: ValueKey(value.atcGroup),
              initialValue: value.atcGroup,
              isExpanded: true,
              decoration:
                  InputDecoration(labelText: loc.t('atcGroup')),
              items: [
                DropdownMenuItem<String?>(
                  value: null,
                  child: Text(loc.t('allAtc')),
                ),
                ...widget.atcGroups.map(
                  (group) => DropdownMenuItem<String?>(
                    value: group,
                    child: Text(
                      '$group · ' + _atcGroupLabel(group),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
              onChanged: (next) {
                setState(
                  () => value = next == null
                      ? value.copyWith(clearAtcGroup: true)
                      : value.copyWith(atcGroup: next),
                );
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String?>(
              key: ValueKey(value.form),
              initialValue: value.form,
              isExpanded: true,
              decoration:
                  InputDecoration(labelText: loc.t('form')),
              items: [
                DropdownMenuItem<String?>(
                  value: null,
                  child: Text(loc.t('allForms')),
                ),
                ...widget.forms.map(
                  (form) => DropdownMenuItem<String?>(
                    value: form,
                    child: Text(
                      form,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
              onChanged: (next) {
                setState(
                  () => value = next == null
                      ? value.copyWith(clearForm: true)
                      : value.copyWith(form: next),
                );
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String?>(
              key: ValueKey(value.holder),
              initialValue: value.holder,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: loc.t('holderManufacturer'),
              ),
              items: [
                DropdownMenuItem<String?>(
                  value: null,
                  child: Text(loc.t('all')),
                ),
                ...widget.holders.map(
                  (holder) => DropdownMenuItem<String?>(
                    value: holder,
                    child: Text(
                      holder,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
              onChanged: (next) {
                setState(
                  () => value = next == null
                      ? value.copyWith(clearHolder: true)
                      : value.copyWith(holder: next),
                );
              },
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => Navigator.of(context).pop(value),
                icon: const Icon(Icons.check_rounded),
                label: Text(loc.t('applyFilters')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Dropdown<T> extends StatelessWidget {
  const _Dropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
  });

  final String label;
  final T value;
  final List<T> items;
  final String Function(T value) itemLabel;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      key: ValueKey(value),
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(labelText: label),
      items: items
          .map(
            (item) => DropdownMenuItem<T>(
              value: item,
              child: Text(itemLabel(item)),
            ),
          )
          .toList(),
      onChanged: (next) {
        if (next != null) onChanged(next);
      },
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          color: MedixColors.textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

int _activeFilterCount(MedicationQuery query) {
  var count = 0;
  if (query.dispensing != DispensingFilter.all) count++;
  if (query.reimbursement != ReimbursementFilter.all) count++;
  if (query.price != PriceFilter.all) count++;
  if (query.market != MarketFilter.all) count++;
  if (query.shortage != ShortageFilter.all) count++;
  if (query.atcGroup != null) count++;
  if (query.form != null) count++;
  if (query.holder != null) count++;
  return count;
}

String _dispensingLabel(DispensingFilter value, {required bool hr}) {
  return switch (value) {
    DispensingFilter.all => hr ? 'Svi režimi' : 'All dispensing modes',
    DispensingFilter.prescription => hr ? 'Na recept' : 'Prescription',
    DispensingFilter.otc => hr ? 'Bez recepta' : 'Non-prescription',
    DispensingFilter.unknown => hr ? 'Režim nije naveden' : 'Not specified',
  };
}

String _reimbursementLabel(ReimbursementFilter value, {required bool hr}) {
  return switch (value) {
    ReimbursementFilter.all => hr ? 'Svi statusi' : 'All statuses',
    ReimbursementFilter.listed => hr ? 'Na listi' : 'Listed',
    ReimbursementFilter.basic => hr ? 'Osnovna lista' : 'Basic list',
    ReimbursementFilter.supplementary => hr ? 'Dopunska lista' : 'Supplementary list',
    ReimbursementFilter.unverified =>
      hr ? 'HZZO status nije potvrđen' : 'HZZO status unverified',
  };
}

String _priceLabel(PriceFilter value, {required bool hr}) {
  return switch (value) {
    PriceFilter.all => hr ? 'Sve cijene' : 'All prices',
    PriceFilter.anyPrice =>
      hr ? 'Ima provjeren cjenovni podatak' : 'Has validated price data',
    PriceFilter.copay =>
      hr ? 'Potvrđena HZZO doplata' : 'Verified HZZO copayment',
    PriceFilter.wholesale =>
      hr ? 'Ima veleprodajnu cijenu' : 'Has wholesale price',
  };
}

String _marketLabel(MarketFilter value, {required bool hr}) {
  return switch (value) {
    MarketFilter.all => hr ? 'Svi tržišni statusi' : 'All market statuses',
    MarketFilter.marketed => hr ? 'Stavljeno u promet' : 'Marketed',
    MarketFilter.notMarketed => hr ? 'Nije stavljeno u promet' : 'Not marketed',
    MarketFilter.temporaryInterruption => hr ? 'Privremeni prekid opskrbe' : 'Temporary supply interruption',
    MarketFilter.unknown => hr ? 'Status tržišta nije naveden' : 'Market status not specified',
  };
}

String _shortageLabel(ShortageFilter value, {required bool hr}) {
  return switch (value) {
    ShortageFilter.all => hr ? 'Svi statusi nestašice' : 'All shortage statuses',
    ShortageFilter.reported => hr ? 'Prijavljena nestašica' : 'Reported shortage',
    ShortageFilter.noneReported => hr ? 'Nema evidentirane nestašice' : 'No recorded shortage',
    ShortageFilter.unknown => hr ? 'Status nestašice nije naveden' : 'Shortage status not specified',
  };
}

String _atcGroupLabel(String group) {
  return switch (group) {
    'A' => 'Probavni sustav i metabolizam',
    'B' => 'Krv i krvotvorni organi',
    'C' => 'Srce i krvožilni sustav',
    'D' => 'Dermatološki lijekovi',
    'G' => 'Mokraćni i spolni sustav',
    'H' => 'Hormonski lijekovi',
    'J' => 'Antiinfektivni lijekovi',
    'L' => 'Antineoplastici i imunomodulatori',
    'M' => 'Mišićno-koštani sustav',
    'N' => 'Živčani sustav',
    'P' => 'Antiparazitici',
    'R' => 'Dišni sustav',
    'S' => 'Osjetila',
    'V' => 'Razni pripravci',
    _ => 'Neklasificirano',
  };
}
