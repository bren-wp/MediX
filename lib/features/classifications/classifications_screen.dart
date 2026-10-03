import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/medix_theme.dart';
import '../../models/medication.dart';
import '../../state/medix_state.dart';
import '../../widgets/medication_tile.dart';
import '../../widgets/medix_page.dart';
import '../medications/medication_detail_screen.dart';

enum _ClassificationMode { atc, icd10 }

class ClassificationsScreen extends StatefulWidget {
  const ClassificationsScreen({
    required this.state,
    super.key,
  });

  final MedixState state;

  @override
  State<ClassificationsScreen> createState() =>
      _ClassificationsScreenState();
}

class _ClassificationsScreenState extends State<ClassificationsScreen> {
  final queryController = TextEditingController();
  _ClassificationMode mode = _ClassificationMode.atc;
  late final Future<List<_IcdRecord>> icdRecords = _loadIcd10();

  @override
  void dispose() {
    queryController.dispose();
    super.dispose();
  }

  Future<List<_IcdRecord>> _loadIcd10() async {
    final raw = await rootBundle.loadString('assets/data/icd10.json');
    final decoded = jsonDecode(raw);
    if (decoded is! Map) {
      throw const FormatException('Neispravan MKB-10 katalog.');
    }

    final records = decoded['records'];
    if (records is! List || records.isEmpty) {
      throw const FormatException('MKB-10 katalog je prazan.');
    }

    final parsed = records
        .whereType<Map>()
        .map(
          (item) => _IcdRecord(
            code: item['code']?.toString().trim() ?? '',
            title: item['title']?.toString().trim() ?? '',
          ),
        )
        .where((item) => item.code.isNotEmpty && item.title.isNotEmpty)
        .toList(growable: false);

    if (parsed.isEmpty) {
      throw const FormatException(
        'MKB-10 katalog nema valjane zapise.',
      );
    }
    return parsed;
  }

  @override
  Widget build(BuildContext context) {
    final query = queryController.text.trim().toLowerCase();

    return MedixPage(
      safeArea: false,
      appBar: AppBar(title: const Text('ATK i MKB-10')),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
            child: Column(
              children: [
                SegmentedButton<_ClassificationMode>(
                  segments: const [
                    ButtonSegment(
                      value: _ClassificationMode.atc,
                      icon: Icon(Icons.medication_outlined),
                      label: Text('ATK'),
                    ),
                    ButtonSegment(
                      value: _ClassificationMode.icd10,
                      icon: Icon(Icons.health_and_safety_outlined),
                      label: Text('MKB-10'),
                    ),
                  ],
                  selected: {mode},
                  onSelectionChanged: (selection) {
                    setState(() => mode = selection.first);
                  },
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: queryController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: mode == _ClassificationMode.atc
                        ? 'ATK šifra, lijek ili djelatna tvar...'
                        : 'MKB-10 šifra ili naziv...',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: queryController.text.isEmpty
                        ? null
                        : IconButton(
                            tooltip: 'Očisti pretragu',
                            onPressed: () {
                              queryController.clear();
                              setState(() {});
                            },
                            icon: const Icon(
                              Icons.close_rounded,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: mode == _ClassificationMode.atc
                ? _AtcBrowser(
                    state: widget.state,
                    query: query,
                  )
                : FutureBuilder<List<_IcdRecord>>(
                    future: icdRecords,
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return MedixEmptyState(
                          icon: Icons.error_outline_rounded,
                          title: 'MKB-10 katalog nije učitan',
                          message:
                              'MediX neće prikazati skraćene ili zamjenske dijagnostičke podatke kada provjereni lokalni katalog nije dostupan.',
                          color: MedixColors.warning,
                        );
                      }
                      if (!snapshot.hasData) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      final records = snapshot.data!
                          .where((item) {
                            if (query.isEmpty) return true;
                            return item.code.toLowerCase().contains(query) ||
                                item.title.toLowerCase().contains(query);
                          })
                          .toList(growable: false);

                      if (records.isEmpty) {
                        return const MedixEmptyState(
                          icon: Icons.search_off_rounded,
                          title: 'Nema podudarnih MKB-10 zapisa',
                          message:
                              'Promijenite MKB-10 šifru ili naziv u pretrazi.',
                        );
                      }

                      return ListView.separated(
                        padding:
                            const EdgeInsets.fromLTRB(16, 4, 16, 28),
                        itemCount: records.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final item = records[index];
                          return MedixSectionCard(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  constraints:
                                      const BoxConstraints(minWidth: 58),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 9,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: MedixColors.primary
                                        .withValues(alpha: .14),
                                    borderRadius:
                                        BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    item.code,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: MedixColors.cyan,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    item.title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      height: 1.35,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _AtcBrowser extends StatelessWidget {
  const _AtcBrowser({
    required this.state,
    required this.query,
  });

  final MedixState state;
  final String query;

  @override
  Widget build(BuildContext context) {
    final groups = <String, List<Medication>>{};
    for (final medication in state.repository.medications) {
      final rawCodes = medication.atcCode?.trim() ?? '';
      if (rawCodes.isEmpty) continue;

      for (final rawCode in rawCodes.split(RegExp(r'[;,]'))) {
        final code = rawCode.trim().toUpperCase();
        if (code.isEmpty) continue;
        groups.putIfAbsent(code, () => []).add(medication);
      }
    }

    final codes = groups.keys.where((code) {
      if (query.isEmpty) return true;
      final medications = groups[code]!;
      final haystack = [
        code,
        ...medications.map((m) => m.name),
        ...medications.map((m) => m.activeIngredient),
      ].join(' ').toLowerCase();
      return haystack.contains(query);
    }).toList()
      ..sort();

    if (codes.isEmpty) {
      return const MedixEmptyState(
        icon: Icons.search_off_rounded,
        title: 'Nema podudarnih ATK zapisa',
        message:
            'Promijenite ATK šifru, naziv lijeka ili djelatnu tvar.',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
      itemCount: codes.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final code = codes[index];
        final medications = groups[code]!;
        final ingredients = medications
            .map((item) => item.activeIngredient)
            .toSet()
            .take(3)
            .join(', ');

        return MedixSectionCard(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => _AtcDetail(
                code: code,
                medications: medications,
                state: state,
              ),
            ),
          ),
          child: Row(
            children: [
              Container(
                constraints: const BoxConstraints(minWidth: 68),
                padding:
                    const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
                decoration: BoxDecoration(
                  color: MedixColors.cyan.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  code,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: MedixColors.cyan,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ingredients,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${medications.length} lijekova/pakiranja',
                      style: const TextStyle(
                        color: MedixColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: MedixColors.textMuted,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _AtcDetail extends StatelessWidget {
  const _AtcDetail({
    required this.code,
    required this.medications,
    required this.state,
  });

  final String code;
  final List<Medication> medications;
  final MedixState state;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: state,
      builder: (context, _) => MedixPage(
        safeArea: false,
        appBar: AppBar(title: Text('ATK $code')),
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 28),
          itemCount: medications.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final medication = medications[index];
            return MedicationTile(
              medication: medication,
              isFavorite: state.isFavorite(medication.id),
              onFavorite: () => state.toggleFavorite(medication.id),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => MedicationDetailScreen(
                    medication: medication,
                    state: state,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _IcdRecord {
  const _IcdRecord({
    required this.code,
    required this.title,
  });

  final String code;
  final String title;
}
