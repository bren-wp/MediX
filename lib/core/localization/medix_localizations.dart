import 'package:flutter/material.dart';

/// MediX 1.0.0 uses Croatian exclusively in its user interface.
/// The official source names and raw regulatory data remain unchanged.
class MedixLanguage {
  const MedixLanguage(this.code, this.nativeName);
  final String code;
  final String nativeName;
}

abstract final class MedixLanguages {
  static const primaryCode = 'hr';
  static const supported = <MedixLanguage>[
    MedixLanguage('hr', 'Hrvatski'),
  ];

  static bool isSupported(String code) => code == primaryCode;

  static String normalize(String? code) => primaryCode;

  static List<Locale> get locales => const [Locale('hr')];
}

class MedixLocalizations {
  const MedixLocalizations(this.locale);
  final Locale locale;

  static MedixLocalizations of(BuildContext context) =>
      Localizations.of<MedixLocalizations>(context, MedixLocalizations) ??
      const MedixLocalizations(Locale('hr'));

  static const delegate = _MedixLocalizationsDelegate();

  String t(String key) => _translations[key] ?? key;

  String tArgs(String key, Map<String, Object> values) {
    var value = t(key);
    for (final entry in values.entries) {
      value = value.replaceAll('{' + entry.key + '}', entry.value.toString());
    }
    return value;
  }

  static const _translations = <String, String>{

      'accessHzzoEffective': 'U primjeni od',
      'accessHzzoDateUnknown': 'Datum primjene nije potvrđen',
      'quickAll': 'Svi',
      'quickPrescription': 'Na recept',
      'quickOtc': 'Bez recepta',
      'quickBasicList': 'Osnovna HZZO',
      'quickSupplementaryList': 'Dopunska HZZO',
      'quickCopay': 'Potvrđena doplata',
      'sortName': 'Naziv lijeka A–Ž',
      'sortIngredient': 'Djelatna tvar A–Ž',
      'sortAtc': 'ATK šifra',
      'sortCopayAsc': 'HZZO doplata: niža prvo',
      'sortCopayDesc': 'HZZO doplata: viša prvo',
      'sortWholesaleAsc': 'Veleprodajna cijena: niža prvo',
      'sortWholesaleDesc': 'Veleprodajna cijena: viša prvo',
      'medicineDocumentsTitle': 'Službene informacije o lijeku',
      'medicineDocumentsIntro': 'Otvorite službene dokumente kada su dostupni. Ako nema izravne upute, potražite točan naziv i jačinu lijeka u HALMED bazi.',
      'medicinePatientLeaflet': 'Uputa o lijeku',
      'medicineProfessionalSummary': 'Sažetak opisa svojstava lijeka',
      'medicineOfficialSource': 'Službeni izvor',
      'medicineHalmedRegister': 'Pretraži HALMED bazu',
      'accessTitle': 'Recept i cijena lijeka',
      'accessPrescriptionLabel': 'Može li se kupiti bez recepta?',
      'accessPrescriptionRequired': 'Izdaje se na recept prema zapisu o lijeku.',
      'accessWithoutPrescription': 'Može se izdati bez recepta prema zapisu o lijeku.',
      'accessUnverified': 'Režim izdavanja nije potvrđen; provjerite s ljekarnikom.',
      'accessMandatoryLabel': 'Obvezno zdravstveno osiguranje HZZO-a',
      'accessBasicCoverage': 'Osnovna lista: HZZO pokriva lijek uz ispunjene uvjete propisivanja i osiguranja.',
      'accessSupplementaryList': 'Dopunska lista HZZO-a: moguća je doplata za lijek.',
      'accessUnknownCoverage': 'Nema potvrđenog HZZO podudaranja za ovaj lijek i pakiranje; pokriće nije utvrđeno.',
      'accessCopaymentLabel': 'HZZO doplata za originalno pakiranje',
      'accessCopaymentChip': 'HZZO doplata:',
      'accessNotAvailable': 'Iznos nije potvrđen',
      'accessSupplementaryInsuranceLabel': 'Uz dopunsko zdravstveno osiguranje',
      'accessPolicyVaries': 'Stvarni trošak ovisi o ugovorenoj polici i pokriću. Ne može se pretpostaviti 0 €.',
      'accessRetailLabel': 'Ljekarnička cijena bez refundacije',
      'accessRetailUnavailable': 'Nije dostupna u službenim offline podacima; pitajte ljekarnu.',
      'accessWholesaleLabel': 'Evidentirana najviša veleprodajna cijena (nije maloprodajna)',
      'accessDisclaimer': 'HZZO lista, dopunsko osiguranje i veleprodajna ili maloprodajna cijena nisu isti podaci. Iznosi se odnose na upareno pakiranje i datum izvora, ne na osobni račun u ljekarni.',
      'accessOfficialHzzo': 'Otvori službene HZZO liste lijekova',
      'professionalDetails': 'Stručni i regulatorni podaci',
      'accessPriceDetails': 'Detaljni službeni cjenovni podaci',
      'searchTitle': 'Pretraga lijekova',
      'compareMedicines': 'Usporedi lijekove',
      'sort': 'Sortiranje',
      'clearSearch': 'Očisti pretragu',
      'filters': 'Filteri',
      'noResultsTitle': 'Nema podudarnih lijekova',
      'noResultsBody': 'Promijenite upit ili uklonite jedan ili više filtera.',
      'resetSearch': 'Poništi pretragu i filtere',
      'results': '{count} rezultata',
      'resultOne': '1 rezultat',
      'advancedFilters': 'Napredni filteri',
      'filterDescription': 'Kombinirajte više kriterija za precizan pregled kataloga.',
      'reset': 'Poništi',
      'dispensing': 'Režim izdavanja',
      'all': 'Sve',
      'unknown': 'Nije navedeno',
      'listStatus': 'Status liste',
      'price': 'Cijena',
      'marketStatus': 'Status na tržištu',
      'shortage': 'Nestašica',
      'atcGroup': 'ATK skupina',
      'allAtc': 'Sve ATK skupine',
      'form': 'Farmaceutski oblik',
      'allForms': 'Svi oblici',
      'holderManufacturer': 'Nositelj odobrenja / proizvođač',
      'applyFilters': 'Primijeni filtere',
      'therapyTitle': 'Moja terapija',
      'addTherapy': 'Dodaj terapiju',
      'noTherapyTitle': 'Još nema spremljene terapije',
      'noTherapyBody': 'Dodajte lijek, opis doze, raspored i vrijeme podsjetnika.',
      'therapyNotice': 'Plan terapije ostaje na ovom uređaju. Dozvola za obavijesti potrebna je samo za podsjetnike, a Android ih može odgoditi.',
      'editTherapy': 'Uredi terapiju',
      'removeTherapy': 'Obriši terapiju',
      'removeTherapyQuestion': 'Ukloniti ovu terapiju?',
      'removeTherapyBody': 'Ovaj unos i njegovi podsjetnici bit će uklonjeni s uređaja.',
      'cancel': 'Odustani',
      'remove': 'Ukloni',
      'remindersDenied': 'Terapija je aktivna, ali Android obavijesti nisu odobrene.',
      'therapyFormIntro': 'Unesite raspored prema uputi liječnika ili ljekarnika. Najprije izričito odaberite lijek i pakiranje.',
      'therapyChooseMedicine': 'Odaberite lijek i pakiranje',
      'therapyMedicineSearchHint': 'Naziv, djelatna tvar, ATK ili pakiranje',
      'therapyMedicineSearchHelp': 'Upišite naziv lijeka ili djelatnu tvar za odabir odgovarajućeg pakiranja.',
      'therapyMedicineRecent': 'Nedavno pregledani i omiljeni lijekovi',
      'therapyMedicineNoResults': 'Nema podudaranja. Provjerite naziv ili suzite upit.',
      'therapyMedicineRefine': 'Prikazano prvih 100 rezultata. Suzite upit za precizniji odabir.',
      'medicine': 'Lijek',
      'doseDescription': 'Opis doze',
      'doseExample': 'npr. 1 tableta',
      'days': 'Dani uzimanja',
      'selectDay': 'Odaberite barem jedan dan.',
      'times': 'Vrijeme uzimanja',
      'addTime': 'Dodaj vrijeme',
      'noTime': 'Još nije dodano vrijeme.',
      'saveTherapy': 'Spremi terapiju',
      'saveChanges': 'Spremi promjene',
      'therapyInvalid': 'Odaberite lijek, opišite dozu, dane i dodajte vrijeme.',
      'therapySaveFailed': 'Terapiju nije moguće spremiti. Provjerite podatke.',
      'therapySavedNoNotifications': 'Terapija je spremljena, ali Android obavijesti nisu odobrene.',
      'everyDay': 'Svaki dan',
      'favoritesEmptyTitle': 'Još nema favorita',
      'favoritesEmptyBody': 'Dodirnite srce na lijeku kako bi vam uvijek bio nadohvat ruke.',
      'home': 'Početna', 'search': 'Pretraga', 'therapy': 'Terapija', 'favorites': 'Favoriti', 'more': 'Više',
      'settings': 'Postavke', 'language': 'Jezik', 'languageSubtitle': 'Odaberite jezik koji MediX koristi u sučelju',
      'export': 'Izvezi moje MediX podatke', 'exportSubtitle': 'Izradite ZIP arhivu s PDF sažecima terapije, favorita i podataka o aplikaciji',
      'privacy': 'Politika privatnosti', 'terms': 'Uvjeti korištenja', 'author': 'Autor',
      'notifications': 'Dozvole podsjetnika', 'notificationsSubtitle': 'Dopustite Android obavijesti koje se koriste samo za podsjetnike terapije',
      'remindersEnabled': 'Dozvole podsjetnika su uključene.',
      'remindersPermissionDenied': 'Dozvole podsjetnika nisu odobrene.',
      'about': 'O aplikaciji MediX', 'legal': 'Pravno i privatnost', 'professionalTools': 'Profesionalni alati',
      'therapySafety': 'Terapija i sigurnost', 'additional': 'Još iz MediX-a',
      'officialSources': 'Službeni izvori podataka', 'officialSourcesSubtitle': 'HALMED, HZZO i službeni cjenovni izvori',
      'securityPrivacy': 'Sigurnost i privatnost', 'securityPrivacySubtitle': 'Privatnost bez obveznog korisničkog računa',
      'exportReady': 'ZIP izvoz je spreman za dijeljenje.', 'exportFailed': 'Izvoz nije moguće izraditi.',
      'openFailed': 'Poveznicu nije moguće otvoriti na ovom uređaju.', 'loading': 'Učitavanje provjerenih podataka o lijekovima…',
      'dataErrorTitle': 'Provjereni podaci nisu učitani', 'dataErrorBody': 'MediX nikada ne zamjenjuje službene lijekove demo podacima. Provjerite instalaciju i pokušajte ponovno.',
      'retry': 'Pokušaj ponovno', 'skip': 'Preskoči', 'next': 'Dalje', 'start': 'Započni',
      'onboarding1Title': 'Provjereni podaci o lijekovima uvijek pri ruci', 'onboarding1Body': 'Pretražujte službene zapise lijekova, HZZO podatke i cijene u brzom profesionalnom sučelju.',
      'onboarding2Title': 'Sigurniji pregled terapije', 'onboarding2Body': 'Usporedite lijekove, provjerite poznate interakcije i jasno vidite kada podatak nije dostupan.',
      'onboarding3Title': 'Vaša terapija, privatno organizirana', 'onboarding3Body': 'Favoriti, terapija i podsjetnici ostaju na vašem uređaju bez obveznog računa.',
      'allMedicines': 'Svi lijekovi', 'prescription': 'Na recept', 'otc': 'Bez recepta', 'marketed': 'U prometu',
      'ingredients': 'Djelatne tvari', 'manufacturers': 'Proizvođači', 'quickTools': 'Brzi stručni alati',
      'categories': 'Kategorije lijekova', 'viewAll': 'Prikaži sve', 'recent': 'Nedavno pregledano',
      'database': 'Iz provjerene baze', 'searchHint': 'Naziv, djelatna tvar, ATK, pakiranje…',
      'privacyTitle': 'Sigurnost i privatnost', 'privacyNoAccount': 'Bez obveznog računa',
      'privacyNoAccountBody': 'Ključne MediX funkcije rade bez registracije ili prijave.',
      'privacyLocal': 'Privatni lokalni podaci', 'privacyLocalBody': 'Favoriti, nedavni lijekovi, terapija i jezične postavke čuvaju se na uređaju.',
      'privacyReminders': 'Namjenski podsjetnici', 'privacyRemindersBody': 'Podsjetnici prikazuju neutralan tekst bez naziva lijeka ili doze. Detalji ostaju u aplikaciji, a osjetljiv sadržaj skriva se na sigurnom zaključanom zaslonu.',
      'privacyMedical': 'Zdravstveni podaci', 'privacyMedicalBody': 'Za pregled baze nije potreban unos dijagnoze. Unosi terapije ostaju na uređaju.',
      'privacyPermissions': 'Minimalne dozvole', 'privacyPermissionsBody': 'MediX traži samo dozvole potrebne funkciji koju aktivno koristite.',
      'aboutTitle': 'O aplikaciji MediX', 'aboutTagline': 'Profesionalna baza i alati za jasan rad s provjerenim podacima o lijekovima.',
      'medicalDisclaimer': 'MediX nije medicinski uređaj i ne postavlja dijagnozu, ne liječi, ne izliječi niti sprječava zdravstvena stanja. Za medicinski savjet, dijagnozu ili liječenje obratite se kvalificiranom zdravstvenom stručnjaku.',
      'byBrendigo': 'Dizajn i razvoj: Brendigo.',
  };
}

class _MedixLocalizationsDelegate
    extends LocalizationsDelegate<MedixLocalizations> {
  const _MedixLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      MedixLanguages.isSupported(locale.languageCode);

  @override
  Future<MedixLocalizations> load(Locale locale) async =>
      const MedixLocalizations(Locale('hr'));

  @override
  bool shouldReload(_MedixLocalizationsDelegate old) => false;
}
