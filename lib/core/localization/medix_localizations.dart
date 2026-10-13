import 'package:flutter/material.dart';

class MedixLanguage {
  const MedixLanguage(this.code, this.nativeName);

  final String code;
  final String nativeName;
}

abstract final class MedixLanguages {
  static const primaryCode = 'en';

  static const supported = <MedixLanguage>[
    MedixLanguage('en', 'English'),
    MedixLanguage('hr', 'Hrvatski'),
    MedixLanguage('de', 'Deutsch'),
    MedixLanguage('fr', 'Français'),
    MedixLanguage('es', 'Español'),
    MedixLanguage('it', 'Italiano'),
    MedixLanguage('pt', 'Português'),
    MedixLanguage('nl', 'Nederlands'),
    MedixLanguage('pl', 'Polski'),
    MedixLanguage('cs', 'Čeština'),
    MedixLanguage('sk', 'Slovenčina'),
    MedixLanguage('sl', 'Slovenščina'),
    MedixLanguage('hu', 'Magyar'),
    MedixLanguage('ro', 'Română'),
    MedixLanguage('bg', 'Български'),
    MedixLanguage('el', 'Ελληνικά'),
    MedixLanguage('tr', 'Türkçe'),
    MedixLanguage('uk', 'Українська'),
    MedixLanguage('ru', 'Русский'),
    MedixLanguage('sv', 'Svenska'),
    MedixLanguage('da', 'Dansk'),
    MedixLanguage('no', 'Norsk'),
    MedixLanguage('fi', 'Suomi'),
    MedixLanguage('lt', 'Lietuvių'),
  ];

  static bool isSupported(String code) =>
      supported.any((language) => language.code == code);

  static String normalize(String? code) =>
      code != null && isSupported(code) ? code : primaryCode;

  static List<Locale> get locales =>
      supported.map((language) => Locale(language.code)).toList(growable: false);
}

class MedixLocalizations {
  const MedixLocalizations(this.locale);

  final Locale locale;

  static MedixLocalizations of(BuildContext context) =>
      Localizations.of<MedixLocalizations>(context, MedixLocalizations) ??
      const MedixLocalizations(Locale('en'));

  static const delegate = _MedixLocalizationsDelegate();

  String t(String key) {
    final language = _translations[locale.languageCode] ?? _translations['en']!;
    return language[key] ?? _translations['en']![key] ?? key;
  }

  static const _translations = <String, Map<String, String>>{
    'en': {
      'home': 'Home',
      'search': 'Search',
      'therapy': 'Therapy',
      'favorites': 'Favorites',
      'more': 'More',
      'settings': 'Settings',
      'language': 'Language',
      'languageSubtitle': 'Choose the language used across MediX',
      'export': 'Export my MediX data',
      'exportSubtitle': 'Create a ZIP archive with PDF summaries of therapy, favorites and app information',
      'privacy': 'Privacy policy',
      'terms': 'Terms of use',
      'author': 'Author',
      'notifications': 'Reminder permissions',
      'notificationsSubtitle': 'Allow Android notifications used only for therapy reminders',
      'about': 'About MediX',
      'legal': 'Legal & privacy',
      'professionalTools': 'Professional tools',
      'therapySafety': 'Therapy & safety',
      'additional': 'More from MediX',
      'officialSources': 'Official data sources',
      'officialSourcesSubtitle': 'HALMED, HZZO and official pricing sources',
      'securityPrivacy': 'Security & privacy',
      'securityPrivacySubtitle': 'Privacy-first design with no mandatory account',
      'exportReady': 'Your ZIP export is ready to share.',
      'exportFailed': 'The export could not be created.',
      'openFailed': 'This link could not be opened on this device.',
      'loading': 'Loading verified medicine data…',
      'dataErrorTitle': 'Verified data could not be loaded',
      'dataErrorBody': 'MediX never replaces official medicine records with demo data. Check the installation and try again.',
      'retry': 'Try again',
      'skip': 'Skip',
      'next': 'Next',
      'start': 'Start MediX',
      'onboarding1Title': 'Verified medicine data, ready when you need it',
      'onboarding1Body': 'Search official medicine records, reimbursement details and pricing information in a fast professional workspace.',
      'onboarding2Title': 'Safer therapy review',
      'onboarding2Body': 'Compare medicines, review known interaction data and keep uncertainty visible instead of guessing.',
      'onboarding3Title': 'Your therapy, organized privately',
      'onboarding3Body': 'Keep favorites, therapy schedules and reminders on your device without a mandatory account.',
      'allMedicines': 'All medicines',
      'prescription': 'Prescription',
      'otc': 'Non-prescription',
      'marketed': 'On market',
      'ingredients': 'Active ingredients',
      'manufacturers': 'Manufacturers',
      'quickTools': 'Professional shortcuts',
      'categories': 'Medicine categories',
      'viewAll': 'View all',
      'recent': 'Recently viewed',
      'database': 'From the verified database',
      'searchHint': 'Name, ingredient, ATC, package…',
      'privacyTitle': 'Security & privacy',
      'privacyNoAccount': 'No mandatory account',
      'privacyNoAccountBody': 'Core MediX features work without registration or sign-in.',
      'privacyLocal': 'Private local data',
      'privacyLocalBody': 'Favorites, recent medicines, therapy and language preferences are stored on your device.',
      'privacyReminders': 'Purpose-limited reminders',
      'privacyRemindersBody': 'Notification and alarm permissions are used only for therapy reminders you choose to enable.',
      'privacyMedical': 'Health information',
      'privacyMedicalBody': 'MediX does not require a diagnosis to browse the medicine database. Therapy entries stay on your device.',
      'privacyPermissions': 'Minimum permissions',
      'privacyPermissionsBody': 'MediX requests only permissions required by a feature you actively use.',
      'aboutTitle': 'About MediX',
      'aboutTagline': 'Professional medicine intelligence for clear, confident navigation of verified data.',
      'medicalDisclaimer': 'MediX is not a medical device and does not diagnose, treat, cure or prevent any medical condition. Consult a qualified healthcare professional for medical advice, diagnosis or treatment.',
      'byBrendigo': 'Designed and developed by Brendigo.',
    },
    'hr': {
      'home': 'Početna', 'search': 'Pretraga', 'therapy': 'Terapija', 'favorites': 'Favoriti', 'more': 'Više',
      'settings': 'Postavke', 'language': 'Jezik', 'languageSubtitle': 'Odaberite jezik koji MediX koristi u sučelju',
      'export': 'Izvezi moje MediX podatke', 'exportSubtitle': 'Izradite ZIP arhivu s PDF sažecima terapije, favorita i podataka o aplikaciji',
      'privacy': 'Politika privatnosti', 'terms': 'Uvjeti korištenja', 'author': 'Autor',
      'notifications': 'Dozvole podsjetnika', 'notificationsSubtitle': 'Dopustite Android obavijesti koje se koriste samo za podsjetnike terapije',
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
      'privacyReminders': 'Namjenski podsjetnici', 'privacyRemindersBody': 'Dozvole za obavijesti i alarme koriste se samo za podsjetnike terapije koje sami uključite.',
      'privacyMedical': 'Zdravstveni podaci', 'privacyMedicalBody': 'Za pregled baze nije potreban unos dijagnoze. Unosi terapije ostaju na uređaju.',
      'privacyPermissions': 'Minimalne dozvole', 'privacyPermissionsBody': 'MediX traži samo dozvole potrebne funkciji koju aktivno koristite.',
      'aboutTitle': 'O aplikaciji MediX', 'aboutTagline': 'Profesionalna baza i alati za jasan rad s provjerenim podacima o lijekovima.',
      'medicalDisclaimer': 'MediX nije medicinski uređaj i ne postavlja dijagnozu, ne liječi, ne izliječi niti sprječava zdravstvena stanja. Za medicinski savjet, dijagnozu ili liječenje obratite se kvalificiranom zdravstvenom stručnjaku.',
      'byBrendigo': 'Dizajn i razvoj: Brendigo.',
    },
    'de': {'home':'Start','search':'Suche','therapy':'Therapie','favorites':'Favoriten','more':'Mehr','settings':'Einstellungen','language':'Sprache','export':'MediX-Daten exportieren','privacy':'Datenschutz','terms':'Nutzungsbedingungen','about':'Über MediX','author':'Autor','retry':'Erneut versuchen','skip':'Überspringen','next':'Weiter','start':'MediX starten'},
    'fr': {'home':'Accueil','search':'Recherche','therapy':'Traitement','favorites':'Favoris','more':'Plus','settings':'Paramètres','language':'Langue','export':'Exporter mes données MediX','privacy':'Politique de confidentialité','terms':'Conditions d’utilisation','about':'À propos de MediX','author':'Auteur','retry':'Réessayer','skip':'Ignorer','next':'Suivant','start':'Démarrer MediX'},
    'es': {'home':'Inicio','search':'Buscar','therapy':'Terapia','favorites':'Favoritos','more':'Más','settings':'Ajustes','language':'Idioma','export':'Exportar mis datos de MediX','privacy':'Política de privacidad','terms':'Términos de uso','about':'Acerca de MediX','author':'Autor','retry':'Reintentar','skip':'Omitir','next':'Siguiente','start':'Iniciar MediX'},
    'it': {'home':'Home','search':'Cerca','therapy':'Terapia','favorites':'Preferiti','more':'Altro','settings':'Impostazioni','language':'Lingua','export':'Esporta i miei dati MediX','privacy':'Informativa sulla privacy','terms':'Termini di utilizzo','about':'Informazioni su MediX','author':'Autore','retry':'Riprova','skip':'Salta','next':'Avanti','start':'Avvia MediX'},
    'pt': {'home':'Início','search':'Pesquisa','therapy':'Terapia','favorites':'Favoritos','more':'Mais','settings':'Definições','language':'Idioma','export':'Exportar os meus dados MediX','privacy':'Política de privacidade','terms':'Termos de utilização','about':'Sobre o MediX','author':'Autor','retry':'Tentar novamente','skip':'Saltar','next':'Seguinte','start':'Iniciar MediX'},
    'nl': {'home':'Home','search':'Zoeken','therapy':'Therapie','favorites':'Favorieten','more':'Meer','settings':'Instellingen','language':'Taal','export':'Mijn MediX-gegevens exporteren','privacy':'Privacybeleid','terms':'Gebruiksvoorwaarden','about':'Over MediX','author':'Auteur','retry':'Opnieuw proberen','skip':'Overslaan','next':'Volgende','start':'MediX starten'},
    'pl': {'home':'Start','search':'Szukaj','therapy':'Terapia','favorites':'Ulubione','more':'Więcej','settings':'Ustawienia','language':'Język','export':'Eksportuj moje dane MediX','privacy':'Polityka prywatności','terms':'Warunki korzystania','about':'O MediX','author':'Autor','retry':'Spróbuj ponownie','skip':'Pomiń','next':'Dalej','start':'Uruchom MediX'},
    'cs': {'home':'Domů','search':'Hledat','therapy':'Terapie','favorites':'Oblíbené','more':'Více','settings':'Nastavení','language':'Jazyk','export':'Exportovat data MediX','privacy':'Zásady ochrany osobních údajů','terms':'Podmínky použití','about':'O MediX','author':'Autor','retry':'Zkusit znovu','skip':'Přeskočit','next':'Další','start':'Spustit MediX'},
    'sk': {'home':'Domov','search':'Hľadať','therapy':'Terapia','favorites':'Obľúbené','more':'Viac','settings':'Nastavenia','language':'Jazyk','export':'Exportovať údaje MediX','privacy':'Zásady ochrany súkromia','terms':'Podmienky používania','about':'O MediX','author':'Autor','retry':'Skúsiť znova','skip':'Preskočiť','next':'Ďalej','start':'Spustiť MediX'},
    'sl': {'home':'Domov','search':'Iskanje','therapy':'Terapija','favorites':'Priljubljeno','more':'Več','settings':'Nastavitve','language':'Jezik','export':'Izvozi moje podatke MediX','privacy':'Pravilnik o zasebnosti','terms':'Pogoji uporabe','about':'O MediX','author':'Avtor','retry':'Poskusi znova','skip':'Preskoči','next':'Naprej','start':'Začni MediX'},
    'hu': {'home':'Kezdőlap','search':'Keresés','therapy':'Terápia','favorites':'Kedvencek','more':'Továbbiak','settings':'Beállítások','language':'Nyelv','export':'MediX-adatok exportálása','privacy':'Adatvédelmi irányelvek','terms':'Felhasználási feltételek','about':'A MediX névjegye','author':'Szerző','retry':'Újra','skip':'Kihagyás','next':'Tovább','start':'MediX indítása'},
    'ro': {'home':'Acasă','search':'Căutare','therapy':'Terapie','favorites':'Favorite','more':'Mai multe','settings':'Setări','language':'Limbă','export':'Exportă datele mele MediX','privacy':'Politica de confidențialitate','terms':'Termeni de utilizare','about':'Despre MediX','author':'Autor','retry':'Încearcă din nou','skip':'Omite','next':'Înainte','start':'Pornește MediX'},
    'bg': {'home':'Начало','search':'Търсене','therapy':'Терапия','favorites':'Любими','more':'Още','settings':'Настройки','language':'Език','export':'Експорт на моите MediX данни','privacy':'Политика за поверителност','terms':'Условия за ползване','about':'За MediX','author':'Автор','retry':'Опитай отново','skip':'Пропусни','next':'Напред','start':'Стартирай MediX'},
    'el': {'home':'Αρχική','search':'Αναζήτηση','therapy':'Θεραπεία','favorites':'Αγαπημένα','more':'Περισσότερα','settings':'Ρυθμίσεις','language':'Γλώσσα','export':'Εξαγωγή δεδομένων MediX','privacy':'Πολιτική απορρήτου','terms':'Όροι χρήσης','about':'Σχετικά με το MediX','author':'Δημιουργός','retry':'Δοκιμή ξανά','skip':'Παράλειψη','next':'Επόμενο','start':'Έναρξη MediX'},
    'tr': {'home':'Ana Sayfa','search':'Ara','therapy':'Tedavi','favorites':'Favoriler','more':'Daha Fazla','settings':'Ayarlar','language':'Dil','export':'MediX verilerimi dışa aktar','privacy':'Gizlilik politikası','terms':'Kullanım koşulları','about':'MediX hakkında','author':'Geliştirici','retry':'Tekrar dene','skip':'Atla','next':'İleri','start':'MediX’i başlat'},
    'uk': {'home':'Головна','search':'Пошук','therapy':'Терапія','favorites':'Обране','more':'Більше','settings':'Налаштування','language':'Мова','export':'Експортувати мої дані MediX','privacy':'Політика конфіденційності','terms':'Умови використання','about':'Про MediX','author':'Автор','retry':'Спробувати знову','skip':'Пропустити','next':'Далі','start':'Запустити MediX'},
    'ru': {'home':'Главная','search':'Поиск','therapy':'Терапия','favorites':'Избранное','more':'Ещё','settings':'Настройки','language':'Язык','export':'Экспортировать мои данные MediX','privacy':'Политика конфиденциальности','terms':'Условия использования','about':'О MediX','author':'Автор','retry':'Повторить','skip':'Пропустить','next':'Далее','start':'Запустить MediX'},
    'sv': {'home':'Hem','search':'Sök','therapy':'Behandling','favorites':'Favoriter','more':'Mer','settings':'Inställningar','language':'Språk','export':'Exportera mina MediX-data','privacy':'Integritetspolicy','terms':'Användarvillkor','about':'Om MediX','author':'Utvecklare','retry':'Försök igen','skip':'Hoppa över','next':'Nästa','start':'Starta MediX'},
    'da': {'home':'Hjem','search':'Søg','therapy':'Behandling','favorites':'Favoritter','more':'Mere','settings':'Indstillinger','language':'Sprog','export':'Eksportér mine MediX-data','privacy':'Privatlivspolitik','terms':'Brugsvilkår','about':'Om MediX','author':'Udvikler','retry':'Prøv igen','skip':'Spring over','next':'Næste','start':'Start MediX'},
    'no': {'home':'Hjem','search':'Søk','therapy':'Behandling','favorites':'Favoritter','more':'Mer','settings':'Innstillinger','language':'Språk','export':'Eksporter mine MediX-data','privacy':'Personvernregler','terms':'Bruksvilkår','about':'Om MediX','author':'Utvikler','retry':'Prøv igjen','skip':'Hopp over','next':'Neste','start':'Start MediX'},
    'fi': {'home':'Koti','search':'Haku','therapy':'Hoito','favorites':'Suosikit','more':'Lisää','settings':'Asetukset','language':'Kieli','export':'Vie MediX-tietoni','privacy':'Tietosuojakäytäntö','terms':'Käyttöehdot','about':'Tietoja MediXistä','author':'Tekijä','retry':'Yritä uudelleen','skip':'Ohita','next':'Seuraava','start':'Käynnistä MediX'},
    'lt': {'home':'Pradžia','search':'Paieška','therapy':'Terapija','favorites':'Mėgstami','more':'Daugiau','settings':'Nustatymai','language':'Kalba','export':'Eksportuoti mano MediX duomenis','privacy':'Privatumo politika','terms':'Naudojimo sąlygos','about':'Apie MediX','author':'Autorius','retry':'Bandyti dar kartą','skip':'Praleisti','next':'Toliau','start':'Paleisti MediX'},
  };
}

class _MedixLocalizationsDelegate extends LocalizationsDelegate<MedixLocalizations> {
  const _MedixLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      MedixLanguages.isSupported(locale.languageCode);

  @override
  Future<MedixLocalizations> load(Locale locale) async =>
      MedixLocalizations(locale);

  @override
  bool shouldReload(_MedixLocalizationsDelegate old) => false;
}
