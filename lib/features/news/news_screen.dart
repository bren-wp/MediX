import 'package:flutter/material.dart';

import '../../core/theme/medix_theme.dart';
import '../../widgets/medix_page.dart';

class NewsScreen extends StatelessWidget {
  const NewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MedixPage(
      appBar: AppBar(title: const Text('Edukacija i vodiči')),
      safeArea: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        children: [
          const MedixSectionCard(
            accent: MedixColors.warning,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MedixIconBubble(
                  icon: Icons.school_rounded,
                  color: MedixColors.warning,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Kratki profesionalni vodiči pomažu u snalaženju kroz podatke o lijekovima i MediX alate. Ne zamjenjuju kliničke smjernice ili individualnu procjenu.',
                    style: TextStyle(
                      color: MedixColors.textSecondary,
                      height: 1.45,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          for (final module in _modules)
            Padding(
              padding: const EdgeInsets.only(bottom: 9),
              child: MedixSectionCard(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => _EducationDetailScreen(
                      module: module,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    MedixIconBubble(
                      icon: module.icon,
                      color: module.color,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            module.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            module.subtitle,
                            style: const TextStyle(
                              color: MedixColors.textSecondary,
                              fontSize: 12,
                              height: 1.35,
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
            ),
        ],
      ),
    );
  }
}

class _EducationDetailScreen extends StatelessWidget {
  const _EducationDetailScreen({
    required this.module,
  });

  final _EducationModule module;

  @override
  Widget build(BuildContext context) {
    return MedixPage(
      safeArea: false,
      appBar: AppBar(title: Text(module.title)),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        children: [
          MedixSectionCard(
            accent: module.color,
            child: Column(
              children: [
                MedixIconBubble(
                  icon: module.icon,
                  color: module.color,
                  size: 62,
                ),
                const SizedBox(height: 12),
                Text(
                  module.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  module.intro,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: MedixColors.textSecondary,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          ...module.sections.map(
            (section) => Padding(
              padding: const EdgeInsets.only(bottom: 9),
              child: MedixSectionCard(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MedixIconBubble(
                      icon: Icons.check_rounded,
                      color: module.color,
                      size: 36,
                    ),
                    const SizedBox(width: 11),
                    Expanded(
                      child: Text(
                        section,
                        style: const TextStyle(
                          color: MedixColors.textSecondary,
                          height: 1.45,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const MedixSectionCard(
            accent: MedixColors.warning,
            child: Text(
              'Kod odluka o terapiji koristite podatke za konkretni lijek i klinički kontekst pacijenta. Edukacijski modul nije terapijska preporuka.',
              style: TextStyle(
                color: MedixColors.textSecondary,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EducationModule {
  const _EducationModule({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.intro,
    required this.sections,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final String intro;
  final List<String> sections;
}

const _modules = <_EducationModule>[
  _EducationModule(
    icon: Icons.medication_outlined,
    color: MedixColors.cyan,
    title: 'Čitanje zapisa lijeka',
    subtitle:
        'Kako povezati naziv, djelatnu tvar, oblik, jačinu, pakiranje i ATK.',
    intro:
        'Jedan naziv lijeka može imati više jačina, oblika i pakiranja. MediX zato podatke prikazuje po konkretnom zapisu.',
    sections: [
      'Naziv proizvoda i djelatna tvar nisu isto: djelatna tvar omogućuje grupiranje srodnih proizvoda.',
      'Jačina, farmaceutski oblik i pakiranje ključni su za razlikovanje zapisa istog lijeka.',
      'ATK šifra služi za anatomsko-terapijsko-kemijsku klasifikaciju i olakšava pregled srodnih skupina.',
      'Kod usporedbe uvijek provjerite konkretno pakiranje i dostupne administrativne podatke.',
    ],
  ),
  _EducationModule(
    icon: Icons.health_and_safety_outlined,
    color: MedixColors.danger,
    title: 'Sigurnost lijekova',
    subtitle:
        'Kako tumačiti upozorenja, nuspojave i nedostajuće podatke.',
    intro:
        'Sigurnosne informacije moraju se tumačiti za konkretni lijek, pacijenta i terapijski kontekst.',
    sections: [
      'Odsutnost podatka u aplikaciji nije potvrda da kontraindikacija, nuspojava ili interakcija ne postoji.',
      'Kod više istodobnih lijekova posebno provjerite interakcije i dupliciranje djelatnih tvari.',
      'Trudnoća, dojenje, dječja dob, starija dob te funkcija bubrega i jetre mogu mijenjati sigurnosnu procjenu.',
      'Promjenu propisane terapije treba uskladiti sa zdravstvenim stručnjakom.',
    ],
  ),
  _EducationModule(
    icon: Icons.compare_arrows_rounded,
    color: MedixColors.primary,
    title: 'Usporedba i paralelni lijekovi',
    subtitle:
        'Kako koristiti MediX usporedbu bez zaključivanja da je jedan proizvod “bolji”.',
    intro:
        'Usporedba služi za brži pregled administrativnih i paketnih razlika između odabranih zapisa.',
    sections: [
      'Usporedite djelatnu tvar, jačinu, oblik, ATK, pakiranje, nositelja i dostupne cijene.',
      'Ista djelatna tvar ne znači automatski da su svi proizvodi zamjenjivi u svakoj situaciji.',
      'Cjenovni podaci različitih vrsta prikazuju se odvojeno kako se doplata ne bi zamijenila s maloprodajnom ili veleprodajnom cijenom.',
      'Za individualnu zamjenu lijeka potrebna je odgovarajuća stručna procjena.',
    ],
  ),
  _EducationModule(
    icon: Icons.calculate_outlined,
    color: MedixColors.purple,
    title: 'Klinički kalkulatori',
    subtitle:
        'Pravilna uporaba pomoćnih izračuna i bodovnih sustava.',
    intro:
        'Kalkulator automatizira aritmetiku, ali ne zamjenjuje provjeru ulaznih podataka ni kliničko tumačenje.',
    sections: [
      'Prije izračuna provjerite jedinice mjere i jesu li ulazni podaci aktualni.',
      'Bodovni sustav treba koristiti samo u populaciji i situaciji za koju je namijenjen.',
      'Rezultat se tumači uz simptome, nalaze, druge bolesti, terapiju i važeći protokol.',
      'MediX prikazuje izračun bez automatskog propisivanja ili promjene terapije.',
    ],
  ),
];
