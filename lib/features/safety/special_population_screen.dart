import 'package:flutter/material.dart';

import '../../core/theme/medix_theme.dart';
import '../../widgets/medix_page.dart';

enum SpecialPopulation {
  pregnancy,
  children,
  olderAdults,
}

class SpecialPopulationScreen extends StatelessWidget {
  const SpecialPopulationScreen({
    required this.population,
    super.key,
  });

  final SpecialPopulation population;

  @override
  Widget build(BuildContext context) {
    final data = switch (population) {
      SpecialPopulation.pregnancy => (
          'Trudnoća i dojenje',
          Icons.pregnant_woman_rounded,
          MedixColors.purple,
          <(IconData, String)>[
            (Icons.health_and_safety_outlined, 'Sigurnost lijeka provjerava se za svaki konkretni proizvod.'),
            (Icons.warning_amber_rounded, 'Ne prekidajte propisanu terapiju bez stručnog savjeta.'),
            (Icons.description_outlined, 'Provjerite službenu uputu i sažetak opisa svojstava lijeka.'),
            (Icons.support_agent_rounded, 'Za individualnu procjenu obratite se liječniku ili ljekarniku.'),
          ],
        ),
      SpecialPopulation.children => (
          'Djeca',
          Icons.child_care_rounded,
          MedixColors.warning,
          <(IconData, String)>[
            (Icons.straighten_rounded, 'Doziranje u djece može ovisiti o dobi, tjelesnoj masi i proizvodu.'),
            (Icons.medication_liquid_rounded, 'Farmaceutski oblik i jačina moraju odgovarati uputi.'),
            (Icons.warning_amber_rounded, 'Lijekove držite izvan pogleda i dohvata djece.'),
            (Icons.description_outlined, 'Uvijek koristite službene informacije konkretnog lijeka.'),
          ],
        ),
      SpecialPopulation.olderAdults => (
          'Starije osobe',
          Icons.elderly_rounded,
          MedixColors.cyan,
          <(IconData, String)>[
            (Icons.hub_outlined, 'Kod više lijekova posebno je važno provjeriti interakcije.'),
            (Icons.monitor_heart_outlined, 'Doziranje može ovisiti o funkciji bubrega, jetre i drugim stanjima.'),
            (Icons.list_alt_rounded, 'Ažurirani popis terapije olakšava stručnu provjeru.'),
            (Icons.support_agent_rounded, 'Promjene terapije uskladite sa zdravstvenim stručnjakom.'),
          ],
        ),
    };

    return MedixPage(
      appBar: AppBar(title: Text(data.$1)),
      safeArea: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        children: [
          MedixSectionCard(
            accent: data.$3,
            child: Column(
              children: [
                MedixIconBubble(
                  icon: data.$2,
                  color: data.$3,
                  size: 66,
                ),
                const SizedBox(height: 12),
                Text(
                  data.$1,
                  style: const TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 7),
                const Text(
                  'Sigurnosni vodič za pregled službenih informacija — ne individualni medicinski savjet.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: MedixColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          ...data.$4.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 9),
              child: MedixSectionCard(
                child: Row(
                  children: [
                    MedixIconBubble(
                      icon: item.$1,
                      color: data.$3,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        item.$2,
                        style: const TextStyle(height: 1.35),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
