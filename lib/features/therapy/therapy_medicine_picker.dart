import 'package:flutter/material.dart';

import '../../core/localization/medix_localizations.dart';
import '../../core/theme/medix_theme.dart';
import '../../models/medication.dart';
import '../../state/medix_state.dart';

/// Never silently choose a medicine for a new therapy entry.
Future<String?> showTherapyMedicinePicker(
  BuildContext context,
  MedixState state,
) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: MedixColors.surface,
    builder: (context) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.82,
      minChildSize: 0.45,
      maxChildSize: 0.96,
      builder: (context, controller) => _Picker(
        state: state,
        scrollController: controller,
      ),
    ),
  );
}

class _Picker extends StatefulWidget {
  const _Picker({required this.state, required this.scrollController});

  final MedixState state;
  final ScrollController scrollController;

  @override
  State<_Picker> createState() => _PickerState();
}

class _PickerState extends State<_Picker> {
  static const _previewLimit = 100;
  static final RegExp _nonLetters = RegExp(r'[^a-z0-9]+');
  final search = TextEditingController();
  late final List<_SearchableMedication> searchable;

  @override
  void initState() {
    super.initState();
    searchable = [
      for (final medicine in widget.state.repository.medications)
        _SearchableMedication(medicine),
    ];
  }

  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

  List<Medication> _results() {
    final tokens = _normalize(search.text)
        .split(' ')
        .where((token) => token.isNotEmpty)
        .toList(growable: false);
    if (tokens.isEmpty) {
      final suggestions = <String, Medication>{};
      for (final medicine in [
        ...widget.state.recent,
        ...widget.state.favorites,
      ]) {
        suggestions.putIfAbsent(medicine.id, () => medicine);
        if (suggestions.length >= 16) break;
      }
      return suggestions.values.toList(growable: false);
    }
    final matches = <Medication>[];
    for (final candidate in searchable) {
      if (tokens.every(candidate.text.contains)) {
        matches.add(candidate.medication);
        if (matches.length >= _previewLimit) break;
      }
    }
    return matches;
  }

  @override
  Widget build(BuildContext context) {
    final loc = MedixLocalizations.of(context);
    final candidates = _results();
    final hasQuery = search.text.trim().isNotEmpty;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        16, 14, 16, MediaQuery.viewInsetsOf(context).bottom + 12,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: MedixColors.textMuted,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            loc.t('therapyChooseMedicine'),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            key: const Key('therapyMedicineSearch'),
            controller: search,
            textInputAction: TextInputAction.search,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: loc.t('therapyMedicineSearchHint'),
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: hasQuery
                  ? IconButton(
                      tooltip: loc.t('clearSearch'),
                      onPressed: () => setState(search.clear),
                      icon: const Icon(Icons.close_rounded),
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 10),
          if (!hasQuery && candidates.isNotEmpty)
            Text(
              loc.t('therapyMedicineRecent'),
              style: const TextStyle(color: MedixColors.textSecondary),
            ),
          if (hasQuery && candidates.length >= _previewLimit)
            Text(
              loc.t('therapyMedicineRefine'),
              style: const TextStyle(
                color: MedixColors.textSecondary,
                fontSize: 12,
              ),
            ),
          const SizedBox(height: 4),
          Expanded(
            child: candidates.isEmpty
                ? Center(
                    child: Text(
                      loc.t(hasQuery
                          ? 'therapyMedicineNoResults'
                          : 'therapyMedicineSearchHelp'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: MedixColors.textSecondary,
                      ),
                    ),
                  )
                : ListView.separated(
                    key: const Key('therapyMedicineResults'),
                    controller: widget.scrollController,
                    itemCount: candidates.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final medicine = candidates[index];
                      final subtitle = [
                        medicine.activeIngredient,
                        medicine.strength,
                        medicine.packageDescription ?? '',
                      ].where((part) => part.trim().isNotEmpty).join(' · ');
                      return ListTile(
                        key: ValueKey('medicine-pick-' + medicine.id),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 4,
                        ),
                        leading: const Icon(
                          Icons.medication_outlined,
                          color: MedixColors.cyan,
                        ),
                        title: Text(
                          medicine.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          subtitle,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () => Navigator.of(context).pop(medicine.id),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  static String _normalize(String input) {
    var normalized = input.toLowerCase();
    const chars = <String, String>{
      'č': 'c', 'ć': 'c', 'đ': 'd', 'š': 's', 'ž': 'z',
    };
    for (final entry in chars.entries) {
      normalized = normalized.replaceAll(entry.key, entry.value);
    }
    return normalized.replaceAll(_nonLetters, ' ').trim();
  }
}

class _SearchableMedication {
  _SearchableMedication(this.medication)
      : text = _PickerState._normalize([
          medication.name,
          medication.activeIngredient,
          medication.strength,
          medication.atcCode ?? '',
          medication.form,
          medication.packageDescription ?? '',
        ].join(' '));

  final Medication medication;
  final String text;
}
