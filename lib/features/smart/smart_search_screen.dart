import 'package:flutter/material.dart';

import '../../core/theme/medix_theme.dart';
import '../../models/medication.dart';
import '../../state/medix_state.dart';
import '../../widgets/medication_tile.dart';
import '../../widgets/medix_page.dart';
import '../medications/medication_detail_screen.dart';

class SmartSearchScreen extends StatefulWidget {
  const SmartSearchScreen({
    required this.state,
    super.key,
  });

  final MedixState state;

  @override
  State<SmartSearchScreen> createState() => _SmartSearchScreenState();
}

class _SmartSearchScreenState extends State<SmartSearchScreen> {
  final controller = TextEditingController();
  String submittedQuery = '';
  List<Medication> results = const [];

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _submit([String? preset]) {
    final query = (preset ?? controller.text).trim();
    if (query.isEmpty) return;
    controller.text = query;
    final found = _smartSearch(widget.state.repository.medications, query);
    setState(() {
      submittedQuery = query;
      results = found;
    });
  }

  List<Medication> _smartSearch(
    List<Medication> medications,
    String rawQuery,
  ) {
    final query = rawQuery.toLowerCase();
    final wantsRx = query.contains('na recept') ||
        query.contains('receptni') ||
        query.contains('recept');
    final wantsOtc = query.contains('bez recepta') ||
        query.contains('otc');

    final atcMatch = RegExp(
      r'\batk\s*[:\-]?\s*([a-z][0-9]{2}[a-z0-9]*)',
      caseSensitive: false,
    ).firstMatch(rawQuery);
    final requestedAtc = atcMatch?.group(1)?.toUpperCase();

    const stopWords = <String>{
      'lijek',
      'lijekovi',
      'lijekova',
      'koji',
      'koje',
      'za',
      'na',
      'bez',
      'recept',
      'recepta',
      'pronađi',
      'pronadi',
      'pokaži',
      'pokazi',
      'mi',
      'atc',
      'sve',
    };

    final tokens = query
        .replaceAll(RegExp(r'[^a-z0-9čćžšđ]+'), ' ')
        .split(' ')
        .where((token) => token.length >= 2 && !stopWords.contains(token))
        .toList(growable: false);

    final scored = <(Medication, int)>[];
    for (final medication in medications) {
      if (wantsRx && medication.requiresPrescription != true) continue;
      if (wantsOtc && medication.requiresPrescription != false) continue;
      if (requestedAtc != null &&
          !(medication.atcCode ?? '').toUpperCase().startsWith(requestedAtc)) {
        continue;
      }

      final name = medication.name.toLowerCase();
      final ingredient = medication.activeIngredient.toLowerCase();
      final category = medication.category.toLowerCase();
      final atc = (medication.atcCode ?? '').toLowerCase();
      final package = (medication.packageDescription ?? '').toLowerCase();
      final form = medication.form.toLowerCase();

      var score = 0;
      for (final token in tokens) {
        if (name.startsWith(token)) {
          score += 12;
        } else if (name.contains(token)) {
          score += 9;
        }
        if (ingredient.startsWith(token)) {
          score += 10;
        } else if (ingredient.contains(token)) {
          score += 7;
        }
        if (atc.startsWith(token)) score += 9;
        if (category.contains(token)) score += 5;
        if (package.contains(token)) score += 3;
        if (form.contains(token)) score += 2;
      }

      if (tokens.isEmpty || score > 0) {
        scored.add((medication, score));
      }
    }

    scored.sort((a, b) {
      final byScore = b.$2.compareTo(a.$2);
      if (byScore != 0) return byScore;
      return a.$1.name.toLowerCase().compareTo(b.$1.name.toLowerCase());
    });

    return scored.take(150).map((item) => item.$1).toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.state,
      builder: (context, _) => MedixPage(
        safeArea: false,
        appBar: AppBar(title: const Text('MediX Smart')),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 28),
          children: [
            const MedixSectionCard(
              accent: MedixColors.cyan,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MedixIconBubble(
                    icon: Icons.auto_awesome_rounded,
                    color: MedixColors.cyan,
                    size: 48,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pretražujte kao što razmišljate',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 17,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'Upišite naziv, djelatnu tvar, ATK šifru, klasu ili kombinaciju uvjeta. MediX Smart rangira rezultate iz lokalnog kataloga bez generiranja terapijskih preporuka.',
                          style: TextStyle(
                            color: MedixColors.textSecondary,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _submit(),
              decoration: InputDecoration(
                hintText: 'npr. antibiotici na recept, ATK C09...',
                prefixIcon: const Icon(Icons.chat_bubble_outline_rounded),
                suffixIcon: IconButton(
                  onPressed: _submit,
                  icon: const Icon(Icons.arrow_upward_rounded),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 7,
              runSpacing: 7,
              children: [
                for (final suggestion in const [
                  'paracetamol 500 mg',
                  'antibiotici na recept',
                  'ATK C09',
                  'lijekovi za alergiju',
                ])
                  ActionChip(
                    label: Text(suggestion),
                    onPressed: () => _submit(suggestion),
                  ),
              ],
            ),
            if (submittedQuery.isNotEmpty) ...[
              const SizedBox(height: 18),
              Text(
                results.isEmpty
                    ? 'Nema rezultata za “$submittedQuery”'
                    : '${results.length} najboljih rezultata za “$submittedQuery”',
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 10),
              ...results.map(
                (medication) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: MedicationTile(
                    medication: medication,
                    isFavorite:
                        widget.state.isFavorite(medication.id),
                    onFavorite: () =>
                        widget.state.toggleFavorite(medication.id),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => MedicationDetailScreen(
                          medication: medication,
                          state: widget.state,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
