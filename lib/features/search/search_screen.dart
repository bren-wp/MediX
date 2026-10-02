import 'package:flutter/material.dart';

import '../../core/theme/medix_theme.dart';
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
        .map(
          (item) =>
              item.marketingAuthorizationHolder ??
              item.manufacturer ??
              '',
        )
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

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.state,
      builder: (context, _) {
        final effectiveQuery = query.copyWith(text: controller.text);
        final results = applyMedicationQuery(
          widget.state.repository.medications,
          effectiveQuery,
        );

        return MedixPage(
          safeArea: false,
          appBar: AppBar(
            title: const Text('Pretraga lijekova'),
            actions: [
              IconButton(
                tooltip: 'Usporedi lijekove',
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
                tooltip: 'Sortiranje',
                initialValue: query.sort,
                onSelected: _setSort,
                icon: const Icon(Icons.sort_rounded),
                itemBuilder: (_) => const [
                  PopupMenuItem(
                    value: MedicationSort.nameAsc,
                    child: Text('Naziv A – Ž'),
                  ),
                  PopupMenuItem(
                    value: MedicationSort.ingredientAsc,
                    child: Text('Djelatna tvar A – Ž'),
                  ),
                  PopupMenuItem(
                    value: MedicationSort.atcAsc,
                    child: Text('ATK šifra'),
                  ),
                  PopupMenuItem(
                    value: MedicationSort.priceAsc,
                    child: Text('Cijena: niža prvo'),
                  ),
                  PopupMenuItem(
                    value: MedicationSort.priceDesc,
                    child: Text('Cijena: viša prvo'),
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
                    hintText:
                        'Naziv, djelatna tvar, ATK, pakiranje...',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: controller.text.isEmpty
                        ? null
                        : IconButton(
                            tooltip: 'Očisti pretragu',
                            onPressed: () {
                              controller.clear();
                              setState(() {});
                            },
                            icon: const Icon(Icons.close_rounded),
                          ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 2, 16, 6),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _resultLabel(results.length),
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
                            ? 'Filteri · ' +
                                _activeFilterCount(query).toString()
                            : 'Filteri',
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
                    ? _EmptyResults(
                        onReset: () {
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
        _dispensingLabel(current.dispensing),
        () => setState(
          () => query = query.copyWith(
            dispensing: DispensingFilter.all,
          ),
        ),
      );
    }

    if (current.reimbursement != ReimbursementFilter.all) {
      addChip(
        _reimbursementLabel(current.reimbursement),
        () => setState(
          () => query = query.copyWith(
            reimbursement: ReimbursementFilter.all,
          ),
        ),
      );
    }

    if (current.price != PriceFilter.all) {
      addChip(
        _priceLabel(current.price),
        () => setState(
          () => query = query.copyWith(price: PriceFilter.all),
        ),
      );
    }

    if (current.market != MarketFilter.all) {
      addChip(
        _marketLabel(current.market),
        () => setState(
          () => query = query.copyWith(market: MarketFilter.all),
        ),
      );
    }

    if (current.shortage != ShortageFilter.all) {
      addChip(
        _shortageLabel(current.shortage),
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

  String _resultLabel(int count) {
    if (count == 1) return '1 rezultat';
    return '$count rezultata';
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
    final bottom = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(18, 18, 18, 18 + bottom),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Napredni filteri',
                    style: TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: _reset,
                  child: const Text('Poništi'),
                ),
              ],
            ),
            const SizedBox(height: 4),
            const Text(
              'Kombinirajte više kriterija za precizan pregled kataloga.',
              style: TextStyle(
                color: MedixColors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 18),
            const _SectionLabel('Režim izdavanja'),
            SegmentedButton<DispensingFilter>(
              showSelectedIcon: false,
              segments: const [
                ButtonSegment(
                  value: DispensingFilter.all,
                  label: Text('Sve'),
                ),
                ButtonSegment(
                  value: DispensingFilter.prescription,
                  label: Text('Recept'),
                ),
                ButtonSegment(
                  value: DispensingFilter.otc,
                  label: Text('Bez recepta'),
                ),
                ButtonSegment(
                  value: DispensingFilter.unknown,
                  label: Text('Nije navedeno'),
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
              label: 'Status liste',
              value: value.reimbursement,
              items: ReimbursementFilter.values,
              itemLabel: _reimbursementLabel,
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
              label: 'Cijena',
              value: value.price,
              items: PriceFilter.values,
              itemLabel: _priceLabel,
              onChanged: (next) {
                setState(
                  () => value = value.copyWith(price: next),
                );
              },
            ),
            const SizedBox(height: 12),
            _Dropdown<MarketFilter>(
              label: 'Status na tržištu',
              value: value.market,
              items: MarketFilter.values,
              itemLabel: _marketLabel,
              onChanged: (next) {
                setState(
                  () => value = value.copyWith(market: next),
                );
              },
            ),
            const SizedBox(height: 12),
            _Dropdown<ShortageFilter>(
              label: 'Nestašica',
              value: value.shortage,
              items: ShortageFilter.values,
              itemLabel: _shortageLabel,
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
                  const InputDecoration(labelText: 'ATK skupina'),
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('Sve ATK skupine'),
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
                  const InputDecoration(labelText: 'Farmaceutski oblik'),
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('Svi oblici'),
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
              decoration: const InputDecoration(
                labelText: 'Nositelj / proizvođač',
              ),
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('Svi'),
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
                label: const Text('Primijeni filtere'),
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

class _EmptyResults extends StatelessWidget {
  const _EmptyResults({required this.onReset});

  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const MedixIconBubble(
              icon: Icons.search_off_rounded,
              color: MedixColors.cyan,
              size: 72,
            ),
            const SizedBox(height: 16),
            const Text(
              'Nema podudarnih lijekova',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 7),
            const Text(
              'Promijenite upit ili uklonite dio filtera.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: MedixColors.textSecondary,
              ),
            ),
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed: onReset,
              icon: const Icon(Icons.restart_alt_rounded),
              label: const Text('Poništi pretragu i filtere'),
            ),
          ],
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

String _dispensingLabel(DispensingFilter value) {
  return switch (value) {
    DispensingFilter.all => 'Svi režimi',
    DispensingFilter.prescription => 'Na recept',
    DispensingFilter.otc => 'Bez recepta',
    DispensingFilter.unknown => 'Režim nije naveden',
  };
}

String _reimbursementLabel(ReimbursementFilter value) {
  return switch (value) {
    ReimbursementFilter.all => 'Svi statusi',
    ReimbursementFilter.listed => 'Na listi',
    ReimbursementFilter.basic => 'Osnovna lista',
    ReimbursementFilter.supplementary => 'Dopunska lista',
    ReimbursementFilter.notListed => 'Nije na listi',
  };
}

String _priceLabel(PriceFilter value) {
  return switch (value) {
    PriceFilter.all => 'Sve cijene',
    PriceFilter.anyPrice => 'Ima cjenovni podatak',
    PriceFilter.copay => 'Ima doplatu',
    PriceFilter.wholesale => 'Ima veleprodajnu cijenu',
  };
}

String _marketLabel(MarketFilter value) {
  return switch (value) {
    MarketFilter.all => 'Svi tržišni statusi',
    MarketFilter.marketed => 'Stavljeno u promet',
    MarketFilter.notMarketed => 'Nije stavljeno u promet',
    MarketFilter.temporaryInterruption => 'Privremeni prekid opskrbe',
    MarketFilter.unknown => 'Status tržišta nije naveden',
  };
}

String _shortageLabel(ShortageFilter value) {
  return switch (value) {
    ShortageFilter.all => 'Svi statusi nestašice',
    ShortageFilter.reported => 'Prijavljena nestašica',
    ShortageFilter.noneReported => 'Nema evidentirane nestašice',
    ShortageFilter.unknown => 'Status nestašice nije naveden',
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
