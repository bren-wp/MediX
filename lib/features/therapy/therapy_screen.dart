import 'package:flutter/material.dart';

import '../../core/theme/medix_theme.dart';
import '../../models/therapy_entry.dart';
import '../../state/medix_state.dart';
import '../../widgets/medix_page.dart';

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
      builder: (_) => _AddTherapySheet(state: state),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: state,
      builder: (context, _) {
        return MedixPage(
          safeArea: false,
          appBar: AppBar(
            title: const Text('Moja terapija'),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _addTherapy(context),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Dodaj terapiju'),
          ),
          child: state.therapy.isEmpty
              ? const MedixEmptyState(
                  icon: Icons.event_available_outlined,
                  title: 'Nema spremljene terapije',
                  message:
                      'Dodajte lijek, opis doze i vrijeme uzimanja. Plan se čuva lokalno na uređaju i može koristiti Android podsjetnike.',
                )
              : ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                  children: [
                    const _LocalDataNotice(),
                    const SizedBox(height: 14),
                    ...state.therapy.map(
                      (entry) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _TherapyCard(
                          entry: entry,
                          state: state,
                        ),
                      ),
                    ),
                  ],
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
    return const MedixSectionCard(
      accent: MedixColors.cyan,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MedixIconBubble(
            icon: Icons.notifications_active_outlined,
            color: MedixColors.cyan,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Terapija ostaje lokalno na uređaju. Android obavijesti i alarm dozvole traže se tek kada korisnik spremi ili aktivira podsjetnik.',
              style: TextStyle(
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

  Future<void> _confirmRemove(BuildContext context) async {
    final shouldRemove = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Ukloniti terapiju?'),
        content: const Text(
          'Ovaj unos i njegovi lokalni podsjetnici bit će uklonjeni.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Odustani'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Ukloni'),
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
                  _weekdaySummary(entry.weekdays),
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
                        const SnackBar(
                          content: Text(
                            'Terapija je aktivna, ali Android obavijesti nisu odobrene.',
                          ),
                        ),
                      );
                    }
                  }
                  state.toggleTherapy(entry.id);
                },
              ),
              IconButton(
                tooltip: 'Obriši terapiju',
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

class _AddTherapySheet extends StatefulWidget {
  const _AddTherapySheet({
    required this.state,
  });

  final MedixState state;

  @override
  State<_AddTherapySheet> createState() => _AddTherapySheetState();
}

class _AddTherapySheetState extends State<_AddTherapySheet> {
  final doseController = TextEditingController();
  final List<TimeOfDay> times = <TimeOfDay>[];
  final Set<int> weekdays = <int>{1, 2, 3, 4, 5, 6, 7};
  String? medicationId;

  @override
  void initState() {
    super.initState();
    if (widget.state.repository.medications.isNotEmpty) {
      medicationId = widget.state.repository.medications.first.id;
    }
  }

  @override
  void dispose() {
    doseController.dispose();
    super.dispose();
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
      setState(() => times.add(selected));
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
        const SnackBar(
          content: Text(
            'Odaberite lijek, opišite dozu, dane i dodajte vrijeme.',
          ),
        ),
      );
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    final notificationsAllowed =
        await widget.state.requestReminderPermissions();

    if (!mounted) return;

    final formattedTimes =
        times.map((time) => _formatTime(context, time)).toList();

    widget.state.addTherapy(
      medicationId: medicationId!,
      doseDescription: doseController.text,
      times: formattedTimes,
      weekdays: weekdays.toList()..sort(),
    );

    Navigator.of(context).pop();

    if (!notificationsAllowed) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text(
            'Terapija je spremljena, ali Android obavijesti nisu odobrene.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final medications = widget.state.repository.medications;

    return Padding(
      padding: EdgeInsets.fromLTRB(18, 20, 18, 18 + bottomInset),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Dodaj terapiju',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 7),
            const Text(
              'Unesite plan prema uputi liječnika, ljekarnika ili službenoj uputi lijeka.',
              style: TextStyle(
                color: MedixColors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              initialValue: medicationId,
              decoration: const InputDecoration(
                labelText: 'Lijek',
                prefixIcon: Icon(Icons.medication_outlined),
              ),
              items: medications
                  .map(
                    (medication) => DropdownMenuItem<String>(
                      value: medication.id,
                      child: Text(
                        medication.compactSubtitle == null
                            ? medication.name
                            : '${medication.name} · '
                                '${medication.compactSubtitle}',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (value) =>
                  setState(() => medicationId = value),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: doseController,
              decoration: const InputDecoration(
                labelText: 'Opis doze',
                hintText: 'npr. 1 tableta',
                prefixIcon: Icon(Icons.medication_liquid_outlined),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Dani uzimanja',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 7,
              runSpacing: 7,
              children: List.generate(7, (index) {
                final day = index + 1;
                return FilterChip(
                  label: Text(_weekdayShortLabel(day)),
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
              const Padding(
                padding: EdgeInsets.only(top: 7),
                child: Text(
                  'Odaberite barem jedan dan.',
                  style: TextStyle(
                    color: MedixColors.warning,
                    fontSize: 11,
                  ),
                ),
              ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Vrijeme uzimanja',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
                TextButton.icon(
                  onPressed: _addTime,
                  icon: const Icon(Icons.add_alarm),
                  label: const Text('Dodaj vrijeme'),
                ),
              ],
            ),
            if (times.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  'Još nije dodano vrijeme.',
                  style: TextStyle(
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
                label: const Text('Spremi terapiju'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


String _weekdayShortLabel(int weekday) {
  return switch (weekday) {
    1 => 'Pon',
    2 => 'Uto',
    3 => 'Sri',
    4 => 'Čet',
    5 => 'Pet',
    6 => 'Sub',
    7 => 'Ned',
    _ => '—',
  };
}

String _weekdaySummary(List<int> weekdays) {
  final normalized = weekdays
      .where((day) => day >= 1 && day <= 7)
      .toSet()
      .toList()
    ..sort();

  if (normalized.length == 7) {
    return 'Svaki dan';
  }
  return normalized.map(_weekdayShortLabel).join(', ');
}
