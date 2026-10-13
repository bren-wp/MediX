import 'package:flutter/material.dart';

import '../../core/app_info.dart';
import '../../core/localization/medix_localizations.dart';
import '../../core/theme/medix_theme.dart';
import '../../state/medix_state.dart';
import '../../widgets/medix_brand.dart';
import '../../widgets/medix_page.dart';
import '../classifications/classifications_screen.dart';
import '../clinical/clinical_tools_screen.dart';
import '../compare/medication_compare_screen.dart';
import '../interactions/interactions_screen.dart';
import '../news/news_screen.dart';
import '../pharmacies/pharmacies_screen.dart';
import '../prices/price_catalog_screen.dart';
import '../safety/special_population_screen.dart';
import '../smart/smart_search_screen.dart';
import '../substitutions/substitutions_screen.dart';
import '../therapy/calendar_screen.dart';
import 'about_screen.dart';
import 'privacy_screen.dart';
import 'sources_screen.dart';
import 'settings_screen.dart';

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
    final loc = MedixLocalizations.of(context);
    final hr = Localizations.localeOf(context).languageCode == 'hr';
    return MedixPage(
      appBar: AppBar(title: Text(loc.t('more'))),
      safeArea: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 28),
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: MedixBrand(compact: true),
          ),
          const SizedBox(height: 18),
          _SectionTitle(loc.t('professionalTools')),
          _MenuItem(
            icon: Icons.auto_awesome_rounded,
            title: 'MediX Smart',
            subtitle: hr
                ? 'Pametna pretraga lijekova prirodnim upitom'
                : 'Smart medicine search with natural-language queries',
            color: MedixColors.cyan,
            onTap: () => _push(
              context,
              SmartSearchScreen(state: state),
            ),
          ),
          _MenuItem(
            icon: Icons.hub_outlined,
            title: hr ? 'Provjera interakcija' : 'Interaction checker',
            subtitle: hr
                ? 'Usporedite lijekove i terapiju'
                : 'Review medicines and therapy together',
            color: MedixColors.danger,
            onTap: () => _push(
              context,
              InteractionsScreen(state: state),
            ),
          ),
          _MenuItem(
            icon: Icons.compare_arrows_rounded,
            title: hr ? 'Usporedba lijekova' : 'Compare medicines',
            subtitle: hr
                ? 'Usporedite 2 do 4 lijeka i pakiranja'
                : 'Compare 2 to 4 medicines and packages',
            color: MedixColors.cyan,
            onTap: () => _push(
              context,
              MedicationCompareScreen(state: state),
            ),
          ),
          _MenuItem(
            icon: Icons.calculate_outlined,
            title: hr ? 'Klinički alati' : 'Clinical tools',
            subtitle: hr
                ? 'BMI, BSA, eGFR, GCS, CHA₂DS₂-VASc i više'
                : 'BMI, BSA, eGFR, GCS, CHA₂DS₂-VASc and more',
            color: MedixColors.primary,
            onTap: () => _push(
              context,
              const ClinicalToolsScreen(),
            ),
          ),
          _MenuItem(
            icon: Icons.account_tree_outlined,
            title: hr ? 'ATK i MKB-10' : 'ATC & ICD-10',
            subtitle: hr
                ? 'Klasifikacije lijekova i dijagnoza'
                : 'Medicine and diagnosis classifications',
            color: MedixColors.purple,
            onTap: () => _push(
              context,
              ClassificationsScreen(state: state),
            ),
          ),
          _MenuItem(
            icon: Icons.swap_horiz_rounded,
            title: hr ? 'Paralelni i srodni lijekovi' : 'Related medicines',
            subtitle: hr
                ? 'Pregled po djelatnoj tvari'
                : 'Explore medicines by active ingredient',
            color: MedixColors.success,
            onTap: () => _push(
              context,
              SubstitutionsScreen(state: state),
            ),
          ),
          _MenuItem(
            icon: Icons.euro_rounded,
            title: hr ? 'Cijene i pakiranja' : 'Prices & packages',
            subtitle: hr
                ? 'Pretraživ pregled dostupnih cjenovnih zapisa'
                : 'Search available pricing records',
            color: MedixColors.success,
            onTap: () => _push(
              context,
              const PriceCatalogScreen(),
            ),
          ),
          const SizedBox(height: 10),
          _SectionTitle(loc.t('therapySafety')),
          _MenuItem(
            icon: Icons.calendar_month_outlined,
            title: hr ? 'Kalendar terapije' : 'Therapy calendar',
            subtitle: hr
                ? 'Dnevni raspored i podsjetnici na uređaju'
                : 'Daily schedule and on-device reminders',
            color: MedixColors.primary,
            onTap: () => _push(
              context,
              TherapyCalendarScreen(state: state),
            ),
          ),
          _MenuItem(
            icon: Icons.pregnant_woman_rounded,
            title: hr ? 'Trudnoća i dojenje' : 'Pregnancy & breastfeeding',
            subtitle: hr
                ? 'Brzi pregled posebnih upozorenja'
                : 'Focused safety considerations',
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
            title: hr ? 'Djeca' : 'Children',
            subtitle: hr
                ? 'Pedijatrijski sigurnosni pregled'
                : 'Pediatric safety overview',
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
            title: hr ? 'Starije osobe' : 'Older adults',
            subtitle: hr
                ? 'Politerapija i posebna upozorenja'
                : 'Polypharmacy and safety considerations',
            color: MedixColors.cyan,
            onTap: () => _push(
              context,
              const SpecialPopulationScreen(
                population: SpecialPopulation.olderAdults,
              ),
            ),
          ),
          const SizedBox(height: 10),
          _SectionTitle(loc.t('additional')),
          _MenuItem(
            icon: Icons.local_pharmacy_outlined,
            title: hr ? 'Ljekarne u blizini' : 'Nearby pharmacies',
            subtitle: hr
                ? 'Otvori pretragu ljekarni u aplikaciji za karte'
                : 'Open a pharmacy search in your maps app',
            color: MedixColors.success,
            onTap: () => _push(
              context,
              const PharmaciesScreen(),
            ),
          ),
          _MenuItem(
            icon: Icons.school_outlined,
            title: hr ? 'Edukacija i vodiči' : 'Education & guides',
            subtitle: hr
                ? 'Kratki vodiči za sigurnije korištenje MediX alata'
                : 'Practical guides for getting more from MediX',
            color: MedixColors.warning,
            onTap: () => _push(
              context,
              const NewsScreen(),
            ),
          ),
          _MenuItem(
            icon: Icons.settings_outlined,
            title: loc.t('settings'),
            subtitle: loc.t('languageSubtitle'),
            color: MedixColors.primary,
            onTap: () => _push(
              context,
              SettingsScreen(state: state),
            ),
          ),
          _MenuItem(
            icon: Icons.shield_outlined,
            title: loc.t('securityPrivacy'),
            subtitle: loc.t('securityPrivacySubtitle'),
            color: MedixColors.success,
            onTap: () => _push(
              context,
              const PrivacyScreen(),
            ),
          ),
          _MenuItem(
            icon: Icons.verified_user_outlined,
            title: loc.t('officialSources'),
            subtitle: loc.t('officialSourcesSubtitle'),
            color: MedixColors.cyan,
            onTap: () => _push(
              context,
              const SourcesScreen(),
            ),
          ),
          _MenuItem(
            icon: Icons.info_outline_rounded,
            title: loc.t('about'),
            subtitle: 'MediX ${MedixAppInfo.version}',
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
