import 'package:flutter/material.dart';

import '../../core/theme/medix_theme.dart';
import '../../core/localization/medix_localizations.dart';
import '../../models/therapy_entry.dart';
import '../../state/medix_state.dart';
import '../../widgets/medix_page.dart';
import 'therapy_medicine_picker.dart';

class TherapyScreen extends StatelessWidget {
  const TherapyScreen({
    required this.state,
    super.key,
  });

  final MedixState state;

  Future<void> _addTherapy(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: MedixColors.surface,
      builder: (_) => _TherapyEditorSheet(state: state),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: state,
      builder: (context, _) {
        final loc = MedixLocalizations.of(context);
        final entries = state.therapy;
        return MedixPage(
          safeArea: false,
          appBar: AppBar(
            title: Text(loc.t('therapyTitle')),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _addTherapy(context),
            icon: const Icon(Icons.add_rounded),
            label: Text(loc.t('addTherapy')),
          ),
          child: entries.isEmpty
              ? MedixEmptyState(
                  icon: Icons.event_available_outlined,
                  title: loc.t('noTherapyTitle'),
                  message: loc.t('noTherapyBody'),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                  itemCount: entries.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return const Padding(
                        padding: EdgeInsets.only(bottom: 14),
                        child: _LocalDataNotice(),
                      );
                    }
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _TherapyCard(
                        entry: entries[index - 1],
                        state: state,
                      ),
                    );
                  },
                ),
        );
      },
    );
  }
}

class _LocalDataNotice extends StatelessWidget {
  const _LocalDataNotice();

  @override
  Widget build(BuildContext context) {
    final loc = MedixLocalizations.of(context);
    return MedixSectionCard(
      accent: MedixColors.cyan,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const MedixIconBubble(
            icon: Icons.notifications_active_outlined,
            color: MedixColors.cyan,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              loc.t('therapyNotice'),
              style: const TextStyle(
                color: MedixColors.textSecondary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TherapyCard extends StatelessWidget {
  const _TherapyCard({
    required this.entry,
    required this.state,
  });

  final TherapyEntry entry;
  final MedixState state;

  Future<void> _edit(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: MedixColors.surface,
      builder: (_) => _TherapyEditorSheet(
        state: state,
        entry: entry,
      ),
    );
  }

  Future<void> _confirmRemove(BuildContext context) async {
    final shouldRemove = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(MedixLocalizations.of(dialogContext).t('removeTherapyQuestion')),
        content: Text(
          MedixLocalizations.of(dialogContext).t('removeTherapyBody'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(MedixLocalizations.of(dialogContext).t('cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(MedixLocalizations.of(dialogContext).t('remove')),
          ),
        ],
      ),
    );

    if (shouldRemove == true) {
      state.removeTherapy(entry.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = MedixLocalizations.of(context);
    final hr = Localizations.localeOf(context).languageCode == 'hr';
    final medication = state.medicationById(entry.medicationId);
    if (medication == null) {
      return const SizedBox.shrink();
    }

    return MedixSectionCard(
      accent: entry.isActive ? MedixColors.primary : MedixColors.textMuted,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MedixIconBubble(
            icon: Icons.medication_outlined,
            color: entry.isActive
                ? MedixColors.cyan
                : MedixColors.textMuted,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  medication.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  entry.doseDescription,
                  style: const TextStyle(
                    color: MedixColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  _weekdaySummary(entry.weekdays, hr: hr),
                  style: const TextStyle(
                    color: MedixColors.cyanSoft,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 9),
                Wrap(
                  spacing: 7,
                  runSpacing: 7,
                  children: entry.times
                      .map(
                        (time) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: MedixColors.cyan.withValues(alpha: .10),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: MedixColors.cyan.withValues(alpha: .25),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.schedule_rounded,
                                size: 14,
                                color: MedixColors.cyan,
                              ),
                              const SizedBox(width: 5),
                              Text(time),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
          Column(
            children: [
              Switch(
                value: entry.isActive,
                onChanged: (nextValue) async {
                  if (nextValue && !entry.isActive) {
                    final allowed =
                        await state.requestReminderPermissions();
                    if (!allowed && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            loc.t('remindersDenied'),
                          ),
                        ),
                      );
                    }
                  }
                  state.toggleTherapy(entry.id);
                },
              ),
              IconButton(
                tooltip: loc.t('editTherapy'),
                onPressed: () => _edit(context),
                icon: const Icon(Icons.edit_outlined),
                color: MedixColors.cyan,
              ),
              IconButton(
                tooltip: loc.t('removeTherapy'),
                onPressed: () => _confirmRemove(context),
                icon: const Icon(Icons.delete_outline),
                color: MedixColors.danger,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TherapyEditorSheet extends StatefulWidget {
  const _TherapyEditorSheet({
    required this.state,
    this.entry,
  });

  final MedixState state;
  final TherapyEntry? entry;

  @override
  State<_TherapyEditorSheet> createState() => _TherapyEditorSheetState();
}

class _TherapyEditorSheetState extends State<_TherapyEditorSheet> {
  final doseController = TextEditingController();
  final List<TimeOfDay> times = <TimeOfDay>[];
  final Set<int> weekdays = <int>{};
  String? medicationId;

  bool get isEditing => widget.entry != null;

  @override
  void initState() {
    super.initState();
    final entry = widget.entry;
    if (entry != null) {
      medicationId = entry.medicationId;
      doseController.text = entry.doseDescription;
      weekdays.addAll(entry.weekdays);
      times.addAll(entry.times.map(_parseTime).whereType<TimeOfDay>());
    } else {
      weekdays.addAll(const [1, 2, 3, 4, 5, 6, 7]);
      // A new therapy must not default to the first medicine in the database.
    }
  }

  TimeOfDay? _parseTime(String value) {
    final parts = value.split(':');
    if (parts.length != 2) return null;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null ||
        minute == null ||
        hour < 0 ||
        hour > 23 ||
        minute < 0 ||
        minute > 59) {
      return null;
    }
    return TimeOfDay(hour: hour, minute: minute);
  }

  @override
  void dispose() {
    doseController.dispose();
    super.dispose();
  }

  Future<void> _chooseMedication() async {
    final selected = await showTherapyMedicinePicker(context, widget.state);
    if (!mounted || selected == null) return;
    setState(() => medicationId = selected);
  }

  Future<void> _addTime() async {
    final selected = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 8, minute: 0),
    );
    if (selected == null || !mounted) {
      return;
    }

    final alreadyExists = times.any(
      (item) =>
          item.hour == selected.hour &&
          item.minute == selected.minute,
    );
    if (!alreadyExists) {
      setState(() {
        times.add(selected);
        times.sort(
          (a, b) => (a.hour * 60 + a.minute)
              .compareTo(b.hour * 60 + b.minute),
        );
      });
    }
  }

  String _formatTime(BuildContext context, TimeOfDay time) {
    return MaterialLocalizations.of(context).formatTimeOfDay(
      time,
      alwaysUse24HourFormat: true,
    );
  }

  Future<void> _save() async {
    if (medicationId == null ||
        doseController.text.trim().isEmpty ||
        times.isEmpty ||
        weekdays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(MedixLocalizations.of(context).t('therapyInvalid')),
        ),
      );
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    final therapyState = widget.state;
    final formattedTimes =
        times.map((time) => _formatTime(context, time)).toList();

    final entry = widget.entry;
    final saved = entry == null
        ? (() {
            widget.state.addTherapy(
              medicationId: medicationId!,
              doseDescription: doseController.text,
              times: formattedTimes,
              weekdays: weekdays.toList()..sort(),
            );
            return true;
          })()
        : widget.state.updateTherapy(
            therapyId: entry.id,
            medicationId: medicationId!,
            doseDescription: doseController.text,
            times: formattedTimes,
            weekdays: weekdays.toList()..sort(),
          );

    if (!saved) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(MedixLocalizations.of(context).t('therapySaveFailed')),
        ),
      );
      return;
    }

    // Persist immediately. Android's notification permission prompt must
    // not delay or prevent saving an otherwise valid personal therapy plan.
    final warning = MedixLocalizations.of(context)
        .t('therapySavedNoNotifications');
    Navigator.of(context).pop();
    final allowed = await therapyState.requestReminderPermissions();
    if (!allowed && messenger.mounted) {
      messenger.showSnackBar(SnackBar(content: Text(warning)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = MedixLocalizations.of(context);
    final hr = Localizations.localeOf(context).languageCode == 'hr';
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(18, 20, 18, 18 + bottomInset),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isEditing ? loc.t('editTherapy') : loc.t('addTherapy'),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              loc.t('therapyFormIntro'),
              style: const TextStyle(
                color: MedixColors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                key: const Key('therapyMedicineSelect'),
                onPressed: _chooseMedication,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 14,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.medication_outlined),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            medicationId == null
                                ? loc.t('therapyChooseMedicine')
                                : widget.state.medicationById(medicationId!)?.name ??
                                    loc.t('therapyChooseMedicine'),
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (medicationId != null)
                            Text(
                              [
                                widget.state.medicationById(medicationId!)?.strength ?? '',
                                widget.state.medicationById(medicationId!)?.packageDescription ?? '',
                              ].where((v) => v.isNotEmpty).join(' · '),
                              style: const TextStyle(
                                color: MedixColors.textSecondary,
                                fontSize: 11,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: doseController,
              decoration: InputDecoration(
                labelText: loc.t('doseDescription'),
                hintText: loc.t('doseExample'),
                prefixIcon: const Icon(Icons.medication_liquid_outlined),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              loc.t('days'),
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 7,
              runSpacing: 7,
              children: List.generate(7, (index) {
                final day = index + 1;
                return FilterChip(
                  label: Text(_weekdayShortLabel(day, hr: hr)),
                  selected: weekdays.contains(day),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        weekdays.add(day);
                      } else {
                        weekdays.remove(day);
                      }
                    });
                  },
                );
              }),
            ),
            if (weekdays.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 7),
                child: Text(
                  loc.t('selectDay'),
                  style: const TextStyle(
                    color: MedixColors.warning,
                    fontSize: 11,
                  ),
                ),
              ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Text(
                    loc.t('times'),
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
                TextButton.icon(
                  onPressed: _addTime,
                  icon: const Icon(Icons.add_alarm),
                  label: Text(loc.t('addTime')),
                ),
              ],
            ),
            if (times.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  loc.t('noTime'),
                  style: const TextStyle(
                    color: MedixColors.textSecondary,
                  ),
                ),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: List.generate(times.length, (index) {
                  final time = times[index];
                  return InputChip(
                    label: Text(_formatTime(context, time)),
                    onDeleted: () =>
                        setState(() => times.removeAt(index)),
                  );
                }),
              ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.check_rounded),
                label: Text(isEditing ? loc.t('saveChanges') : loc.t('saveTherapy')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


String _weekdayShortLabel(int weekday, {required bool hr}) {
  return switch (weekday) {
    1 => hr ? 'Pon' : 'Mon',
    2 => hr ? 'Uto' : 'Tue',
    3 => hr ? 'Sri' : 'Wed',
    4 => hr ? 'Čet' : 'Thu',
    5 => hr ? 'Pet' : 'Fri',
    6 => hr ? 'Sub' : 'Sat',
    7 => hr ? 'Ned' : 'Sun',
    _ => '—',
  };
}

String _weekdaySummary(List<int> weekdays, {required bool hr}) {
  final normalized = weekdays
      .where((day) => day >= 1 && day <= 7)
      .toSet()
      .toList()
    ..sort();

  if (normalized.length == 7) {
    return hr ? 'Svaki dan' : 'Every day';
  }
  return normalized.map((day) => _weekdayShortLabel(day, hr: hr)).join(', ');
}
