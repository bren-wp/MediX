import 'package:flutter/material.dart';

import '../../core/theme/medix_theme.dart';
import '../../state/medix_state.dart';
import '../../widgets/medix_brand.dart';
import '../../widgets/medix_page.dart';
import '../classifications/classifications_screen.dart';
import '../clinical/clinical_tools_screen.dart';
import '../interactions/interactions_screen.dart';
import '../news/news_screen.dart';
import '../pharmacies/pharmacies_screen.dart';
import '../prices/price_catalog_screen.dart';
import '../safety/special_population_screen.dart';
import '../smart/smart_search_screen.dart';
import '../substitutions/substitutions_screen.dart';
import '../therapy/calendar_screen.dart';
import 'about_screen.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({
    required this.state,
    super.key,
  });

  final MedixState state;

  void _push(BuildContext context, Widget screen) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MedixPage(
      appBar: AppBar(title: const Text('Više')),
      safeArea: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 28),
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: MedixBrand(compact: true),
          ),
          const SizedBox(height: 18),
          const _SectionTitle('Profesionalni alati'),
          _MenuItem(
            icon: Icons.auto_awesome_rounded,
            title: 'MediX Smart',
            subtitle: 'Pametna pretraga lijekova prirodnim upitom',
            color: MedixColors.cyan,
            onTap: () => _push(
              context,
              SmartSearchScreen(state: state),
            ),
          ),
          _MenuItem(
            icon: Icons.hub_outlined,
            title: 'Provjera interakcija',
            subtitle: 'Usporedite lijekove i terapiju',
            color: MedixColors.danger,
            onTap: () => _push(
              context,
              InteractionsScreen(state: state),
            ),
          ),
          _MenuItem(
            icon: Icons.calculate_outlined,
            title: 'Klinički alati',
            subtitle: 'BMI, BSA, eGFR, GCS, CHA₂DS₂-VASc i više',
            color: MedixColors.primary,
            onTap: () => _push(
              context,
              const ClinicalToolsScreen(),
            ),
          ),
          _MenuItem(
            icon: Icons.account_tree_outlined,
            title: 'ATK i MKB-10',
            subtitle: 'Klasifikacije lijekova i dijagnoza',
            color: MedixColors.purple,
            onTap: () => _push(
              context,
              ClassificationsScreen(state: state),
            ),
          ),
          _MenuItem(
            icon: Icons.swap_horiz_rounded,
            title: 'Paralelni i srodni lijekovi',
            subtitle: 'Pregled po djelatnoj tvari',
            color: MedixColors.success,
            onTap: () => _push(
              context,
              SubstitutionsScreen(state: state),
            ),
          ),
          _MenuItem(
            icon: Icons.euro_rounded,
            title: 'Cijene i pakiranja',
            subtitle: 'Pretraživ pregled dostupnih cjenovnih zapisa',
            color: MedixColors.success,
            onTap: () => _push(
              context,
              const PriceCatalogScreen(),
            ),
          ),
          const SizedBox(height: 10),
          const _SectionTitle('Terapija i sigurnost'),
          _MenuItem(
            icon: Icons.calendar_month_outlined,
            title: 'Kalendar terapije',
            subtitle: 'Dnevni raspored i lokalni podsjetnici',
            color: MedixColors.primary,
            onTap: () => _push(
              context,
              TherapyCalendarScreen(state: state),
            ),
          ),
          _MenuItem(
            icon: Icons.pregnant_woman_rounded,
            title: 'Trudnoća i dojenje',
            subtitle: 'Brzi pregled posebnih upozorenja',
            color: MedixColors.purple,
            onTap: () => _push(
              context,
              const SpecialPopulationScreen(
                population: SpecialPopulation.pregnancy,
              ),
            ),
          ),
          _MenuItem(
            icon: Icons.child_care_rounded,
            title: 'Djeca',
            subtitle: 'Pedijatrijski sigurnosni pregled',
            color: MedixColors.warning,
            onTap: () => _push(
              context,
              const SpecialPopulationScreen(
                population: SpecialPopulation.children,
              ),
            ),
          ),
          _MenuItem(
            icon: Icons.elderly_rounded,
            title: 'Starije osobe',
            subtitle: 'Politerapija i posebna upozorenja',
            color: MedixColors.cyan,
            onTap: () => _push(
              context,
              const SpecialPopulationScreen(
                population: SpecialPopulation.olderAdults,
              ),
            ),
          ),
          const SizedBox(height: 10),
          const _SectionTitle('Dodatno'),
          _MenuItem(
            icon: Icons.local_pharmacy_outlined,
            title: 'Ljekarne u blizini',
            subtitle: 'Lokacijski modul',
            color: MedixColors.success,
            onTap: () => _push(
              context,
              const PharmaciesScreen(),
            ),
          ),
          _MenuItem(
            icon: Icons.school_outlined,
            title: 'Edukacija i novosti',
            subtitle: 'Stručni sadržaj unutar MediX iskustva',
            color: MedixColors.warning,
            onTap: () => _push(
              context,
              const NewsScreen(),
            ),
          ),
          _MenuItem(
            icon: Icons.language_rounded,
            title: 'Jezik',
            subtitle: 'Hrvatski',
            color: MedixColors.primary,
            onTap: () {},
          ),
          _MenuItem(
            icon: Icons.dark_mode_outlined,
            title: 'Tema',
            subtitle: 'MediX Dark',
            color: MedixColors.cyan,
            onTap: () {},
          ),
          _MenuItem(
            icon: Icons.shield_outlined,
            title: 'Sigurnost i privatnost',
            subtitle: 'Lokalna terapija i favoriti · bez obveznog računa',
            color: MedixColors.success,
            onTap: () {},
          ),
          _MenuItem(
            icon: Icons.info_outline_rounded,
            title: 'O aplikaciji',
            subtitle: 'MediX 0.3.0',
            color: MedixColors.primary,
            onTap: () => _push(
              context,
              const AboutScreen(),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 0, 2, 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          color: MedixColors.textSecondary,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: MedixSectionCard(
        onTap: onTap,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            MedixIconBubble(
              icon: icon,
              color: color,
              size: 40,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: MedixColors.textSecondary,
                      fontSize: 11,
                      height: 1.25,
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
      ),
    );
  }
}
