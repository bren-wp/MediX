import 'package:flutter/material.dart';

import '../../core/theme/medix_theme.dart';
import '../../models/therapy_entry.dart';
import '../../state/medix_state.dart';

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
        return Scaffold(
          appBar: AppBar(
            title: const Text('Moja terapija'),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _addTherapy(context),
            icon: const Icon(Icons.add),
            label: const Text('Dodaj terapiju'),
          ),
          body: state.therapy.isEmpty
              ? const _EmptyTherapy()
              : ListView(
                  padding: const EdgeInsets.fromLTRB(18, 8, 18, 96),
                  children: [
                    const _LocalDataNotice(),
                    const SizedBox(height: 16),
                    ...state.therapy.map(
                      (entry) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
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

class _EmptyTherapy extends StatelessWidget {
  const _EmptyTherapy();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: const Color(0x22168DFF),
                borderRadius: BorderRadius.circular(28),
              ),
              child: const Icon(
                Icons.event_available_outlined,
                size: 44,
                color: MedixColors.cyan,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Nema spremljene terapije',
              style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Dodajte lijek, opis doze i vrijeme uzimanja. Plan je za sada spremljen samo tijekom trenutne sesije aplikacije.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: MedixColors.textSecondary,
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LocalDataNotice extends StatelessWidget {
  const _LocalDataNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0x2214D8EA),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0x4414D8EA)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lock_outline, color: MedixColors.cyan),
          SizedBox(width: 11),
          Expanded(
            child: Text(
              'MediX ne zahtijeva račun. Trajna lokalna pohrana i OS podsjetnici bit će dodani kao zaseban sloj.',
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

  @override
  Widget build(BuildContext context) {
    final medication = state.medicationById(entry.medicationId);
    if (medication == null) {
      return const SizedBox.shrink();
    }

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: BorderSide(
          color: entry.isActive
              ? const Color(0xFF173C61)
              : const Color(0xFF273546),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0x22168DFF),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(
                Icons.medication_outlined,
                color: entry.isActive
                    ? MedixColors.cyan
                    : MedixColors.textSecondary,
              ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    medication.name,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    entry.doseDescription,
                    style: const TextStyle(
                      color: MedixColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 10),
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
                              color: const Color(0x2214D8EA),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.schedule,
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
                  onChanged: (_) => state.toggleTherapy(entry.id),
                ),
                IconButton(
                  tooltip: 'Obriši terapiju',
                  onPressed: () => state.removeTherapy(entry.id),
                  icon: const Icon(Icons.delete_outline),
                  color: MedixColors.danger,
                ),
              ],
            ),
          ],
        ),
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
      (item) => item.hour == selected.hour && item.minute == selected.minute,
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

  void _save() {
    if (medicationId == null ||
        doseController.text.trim().isEmpty ||
        times.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Odaberite lijek, opišite dozu i dodajte vrijeme.'),
        ),
      );
      return;
    }

    final formattedTimes = times
        .map((time) => _formatTime(context, time))
        .toList();

    widget.state.addTherapy(
      medicationId: medicationId!,
      doseDescription: doseController.text,
      times: formattedTimes,
    );
    Navigator.of(context).pop();
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
                fontWeight: FontWeight.w800,
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
                        '${medication.name} · ${medication.strength}',
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (value) => setState(() => medicationId = value),
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
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Vrijeme uzimanja',
                    style: TextStyle(fontWeight: FontWeight.w700),
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
                  style: TextStyle(color: MedixColors.textSecondary),
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
                    onDeleted: () => setState(() => times.removeAt(index)),
                  );
                }),
              ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.check),
                label: const Text('Spremi terapiju'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
