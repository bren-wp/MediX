import 'package:flutter/material.dart';

import '../../core/theme/medix_theme.dart';
import '../../state/medix_state.dart';
import '../../widgets/medix_page.dart';

class TherapyCalendarScreen extends StatefulWidget {
  const TherapyCalendarScreen({required this.state, super.key});

  final MedixState state;

  @override
  State<TherapyCalendarScreen> createState() => _TherapyCalendarScreenState();
}

class _TherapyCalendarScreenState extends State<TherapyCalendarScreen> {
  DateTime selected = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final month = DateTime(selected.year, selected.month);
    final days = DateUtils.getDaysInMonth(month.year, month.month);
    final firstWeekday = DateTime(month.year, month.month, 1).weekday;
    final cells = <int?>[
      ...List<int?>.filled(firstWeekday - 1, null),
      ...List<int>.generate(days, (i) => i + 1),
    ];

    return AnimatedBuilder(
      animation: widget.state,
      builder: (context, _) => MedixPage(
        appBar: AppBar(title: const Text('Kalendar terapije')),
        safeArea: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
          children: [
            MedixSectionCard(
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => setState(() {
                          selected = DateTime(selected.year, selected.month - 1, 1);
                        }),
                        icon: const Icon(Icons.chevron_left_rounded),
                      ),
                      Expanded(
                        child: Text(
                          _monthLabel(selected),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => setState(() {
                          selected = DateTime(selected.year, selected.month + 1, 1);
                        }),
                        icon: const Icon(Icons.chevron_right_rounded),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Row(
                    children: [
                      _DayLabel('P'),
                      _DayLabel('U'),
                      _DayLabel('S'),
                      _DayLabel('Č'),
                      _DayLabel('P'),
                      _DayLabel('S'),
                      _DayLabel('N'),
                    ],
                  ),
                  const SizedBox(height: 4),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: cells.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                      mainAxisSpacing: 4,
                      crossAxisSpacing: 4,
                    ),
                    itemBuilder: (context, index) {
                      final day = cells[index];
                      if (day == null) return const SizedBox.shrink();
                      final isSelected = selected.day == day &&
                          selected.month == month.month &&
                          selected.year == month.year;
                      return InkWell(
                        borderRadius: BorderRadius.circular(999),
                        onTap: () => setState(() {
                          selected = DateTime(month.year, month.month, day);
                        }),
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? MedixColors.primary
                                : Colors.transparent,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '$day',
                            style: TextStyle(
                              fontWeight:
                                  isSelected ? FontWeight.w900 : FontWeight.w500,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Plan za ${selected.day}.${selected.month}.${selected.year}.',
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 10),
            if (widget.state.therapy.isEmpty)
              const MedixSectionCard(
                child: Text(
                  'Nema spremljene terapije. Dodajte lijekove u odjeljku Terapija.',
                  style: TextStyle(color: MedixColors.textSecondary),
                ),
              )
            else
              ...widget.state.therapy.map((entry) {
                final medication = widget.state.medicationById(entry.medicationId);
                if (medication == null) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(bottom: 9),
                  child: MedixSectionCard(
                    child: Row(
                      children: [
                        MedixIconBubble(
                          icon: entry.isActive
                              ? Icons.check_circle_rounded
                              : Icons.pause_circle_outline,
                          color: entry.isActive
                              ? MedixColors.success
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
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Text(
                                '${entry.doseDescription} · ${entry.times.join(' / ')}',
                                style: const TextStyle(
                                  color: MedixColors.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  String _monthLabel(DateTime date) {
    const months = [
      'Siječanj','Veljača','Ožujak','Travanj','Svibanj','Lipanj',
      'Srpanj','Kolovoz','Rujan','Listopad','Studeni','Prosinac',
    ];
    return '${months[date.month - 1]} ${date.year}.';
  }
}

class _DayLabel extends StatelessWidget {
  const _DayLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: MedixColors.textSecondary,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
