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
    try {
      final raw = await rootBundle.loadString('assets/data/icd10.json');
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return _fallbackChapters;
      final records = decoded['records'];
      if (records is! List || records.isEmpty) {
        return _fallbackChapters;
      }

      return records
          .whereType<Map>()
          .map(
            (item) => _IcdRecord(
              code: item['code']?.toString() ?? '',
              title: item['title']?.toString() ?? '',
            ),
          )
          .where((item) => item.code.isNotEmpty && item.title.isNotEmpty)
          .toList(growable: false);
    } catch (_) {
      return _fallbackChapters;
    }
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
      final code = medication.atcCode?.trim();
      if (code == null || code.isEmpty) continue;
      groups.putIfAbsent(code, () => []).add(medication);
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

const _fallbackChapters = <_IcdRecord>[
  _IcdRecord(code: 'A00-B99', title: 'Zarazne i parazitarne bolesti'),
  _IcdRecord(code: 'C00-D48', title: 'Novotvorine'),
  _IcdRecord(
    code: 'D50-D89',
    title: 'Bolesti krvi, krvotvornog i imunosnog sustava',
  ),
  _IcdRecord(
    code: 'E00-E90',
    title: 'Endokrine bolesti, prehrana i metabolizam',
  ),
  _IcdRecord(
    code: 'F00-F99',
    title: 'Mentalni poremećaji i poremećaji ponašanja',
  ),
  _IcdRecord(code: 'G00-G99', title: 'Bolesti živčanog sustava'),
  _IcdRecord(code: 'H00-H59', title: 'Bolesti oka i očnih adneksa'),
  _IcdRecord(code: 'H60-H95', title: 'Bolesti uha i mastoidnog nastavka'),
  _IcdRecord(code: 'I00-I99', title: 'Bolesti cirkulacijskog sustava'),
  _IcdRecord(code: 'J00-J99', title: 'Bolesti dišnoga sustava'),
  _IcdRecord(code: 'K00-K93', title: 'Bolesti probavnoga sustava'),
  _IcdRecord(code: 'L00-L99', title: 'Bolesti kože i potkožnoga tkiva'),
  _IcdRecord(
    code: 'M00-M99',
    title: 'Bolesti mišićno-koštanog sustava i vezivnoga tkiva',
  ),
  _IcdRecord(code: 'N00-N99', title: 'Bolesti genitourinarnog sustava'),
  _IcdRecord(code: 'O00-O99', title: 'Trudnoća, porođaj i babinje'),
  _IcdRecord(
    code: 'P00-P96',
    title: 'Određena stanja nastala u perinatalnom razdoblju',
  ),
  _IcdRecord(
    code: 'Q00-Q99',
    title: 'Prirođene malformacije i kromosomske abnormalnosti',
  ),
  _IcdRecord(
    code: 'R00-R99',
    title: 'Simptomi, znakovi i abnormalni nalazi',
  ),
  _IcdRecord(
    code: 'S00-T98',
    title: 'Ozljede, otrovanja i ostale posljedice vanjskih uzroka',
  ),
  _IcdRecord(code: 'U00-U89', title: 'Šifre za posebne namjene'),
  _IcdRecord(
    code: 'V01-Y98',
    title: 'Vanjski uzroci morbiditeta i mortaliteta',
  ),
  _IcdRecord(
    code: 'Z00-Z99',
    title: 'Čimbenici koji utječu na stanje zdravlja i kontakt sa zdravstvenom službom',
  ),
];
