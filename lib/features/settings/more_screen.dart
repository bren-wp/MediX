import 'package:flutter/material.dart';

import '../../core/theme/medix_theme.dart';
import '../../state/medix_state.dart';
import '../../widgets/medix_brand.dart';
import '../../widgets/medix_page.dart';
import '../interactions/interactions_screen.dart';
import '../news/news_screen.dart';
import '../pharmacies/pharmacies_screen.dart';
import '../prices/price_catalog_screen.dart';
import '../safety/special_population_screen.dart';
import '../substitutions/substitutions_screen.dart';
import '../therapy/calendar_screen.dart';
import 'about_screen.dart';
import 'sources_screen.dart';

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
          _MenuItem(
            icon: Icons.hub_outlined,
            title: 'Provjera interakcija',
            subtitle: 'Usporedi odabrane lijekove',
            onTap: () => _push(
              context,
              InteractionsScreen(state: state),
            ),
          ),
          _MenuItem(
            icon: Icons.calendar_month_outlined,
            title: 'Kalendar terapije',
            subtitle: 'Pregled plana po danima',
            onTap: () => _push(
              context,
              TherapyCalendarScreen(state: state),
            ),
          ),
          _MenuItem(
            icon: Icons.swap_horiz_rounded,
            title: 'Zamjene lijekova',
            subtitle: 'Pregled po istoj djelatnoj tvari',
            onTap: () => _push(
              context,
              SubstitutionsScreen(state: state),
            ),
          ),
          _MenuItem(
            icon: Icons.pregnant_woman_rounded,
            title: 'Trudnoća i dojenje',
            subtitle: 'Sigurnosni vodič',
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
            subtitle: 'Sigurnosni vodič',
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
            subtitle: 'Sigurnosni vodič',
            onTap: () => _push(
              context,
              const SpecialPopulationScreen(
                population: SpecialPopulation.olderAdults,
              ),
            ),
          ),
          _MenuItem(
            icon: Icons.euro_rounded,
            title: 'Cjenik lijekova',
            subtitle: 'HALMED 2026 · najviše cijene na veliko',
            onTap: () => _push(
              context,
              const PriceCatalogScreen(),
            ),
          ),
          _MenuItem(
            icon: Icons.local_pharmacy_outlined,
            title: 'Ljekarne u blizini',
            subtitle: 'Lokacijski modul',
            onTap: () => _push(
              context,
              const PharmaciesScreen(),
            ),
          ),
          _MenuItem(
            icon: Icons.newspaper_rounded,
            title: 'Vijesti i savjeti',
            subtitle: 'Službeni i provjereni izvori',
            onTap: () => _push(
              context,
              const NewsScreen(),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Postavke i podaci',
            style: TextStyle(
              fontSize: 14,
              color: MedixColors.textSecondary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          _MenuItem(
            icon: Icons.source_outlined,
            title: 'Službeni izvori',
            subtitle: 'HZZO, HALMED i eLijekovi',
            onTap: () => _push(
              context,
              const SourcesScreen(),
            ),
          ),
          _MenuItem(
            icon: Icons.language_rounded,
            title: 'Jezik',
            subtitle: 'Hrvatski',
            onTap: () {},
          ),
          _MenuItem(
            icon: Icons.dark_mode_outlined,
            title: 'Tema',
            subtitle: 'Tamna',
            onTap: () {},
          ),
          _MenuItem(
            icon: Icons.shield_outlined,
            title: 'Sigurnost i privatnost',
            subtitle: 'Bez obveznog korisničkog računa',
            onTap: () {},
          ),
          _MenuItem(
            icon: Icons.info_outline_rounded,
            title: 'O aplikaciji',
            subtitle: 'MediX 0.2.0',
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

class _MenuItem extends StatelessWidget {
  const _MenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
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
              color: MedixColors.primary,
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
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
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
      ),
    );
  }
}
