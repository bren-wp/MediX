# Changelog

Sve značajne promjene MediX projekta dokumentiraju se u ovoj datoteci.

## [0.3.4] - u razvoju

### Dodano
- potpuno uređivanje postojećeg terapijskog plana: lijek, opis doze, dani i vremena
- sigurna Android release-signing konfiguracija koja automatski koristi privatni keystore samo kada je dostupan
- eksplicitna HALMED provenance oznaka da naziv lijeka dolazi iz službenog stupca `Naziv`

### Poboljšano
- vremena terapije se nakon odabira odmah sortiraju kronološki
- izmjene terapije prolaze istu normalizaciju i validaciju kao novi unos te ponovno sinkroniziraju lokalne podsjetnike
- validator odbija dodatne sumnjive identitete lijekova poput URL/e-mail, brojčanih i interpunkcijskih placeholder zapisa
- HALMED sinkronizacijski identitet i User-Agent ažurirani su za v0.3.4 ciklus
- uklonjeni su preostali generički Flutter TODO komentari iz Android release konfiguracije

### Testovi
- pokrivena uspješna izmjena terapije i zaštita od nevaljanog uređivanja bez mutacije postojećeg plana

## [0.3.3] - 2026-10-03

### Dodano
- terapijski raspored po danima u tjednu s Android podsjetnicima koji prate odabrane dane
- stvarni dnevni prikaz terapije u kalendaru
- CKD-EPI 2021 race-free kreatininska eGFR jednadžba za odrasle
- testovi kliničkih izračuna, tjednog rasporeda terapije i sinkronizacije verzije aplikacije

### Poboljšano
- potpuno ispoliran početni ekran i responzivni gridovi za uže Android zaslone
- jedinstveni empty-state sustav i jasniji error/retry tokovi
- searchable kategorije, djelatne tvari te proizvođači/nositelji s manje dupliciranog UI koda
- cjenik koristi lazy prikaz, retry, clear-search i vidljiv službeni izvor
- detalj lijeka prikazuje izvor podataka i datum zadnje provjere
- MKB-10 više ne pada na skraćeni zamjenski katalog kada službeni lokalni asset nije dostupan
- ATK i MediX Smart ispravno obrađuju zapise s više ATK šifri
- originalni MELD vraća zaokruženi rezultat u rasponu 6–40
- interakcijski picker ima clear-search, broj rezultata i prazan rezultat
- sigurniji tok otvaranja ljekarni i potvrda prije brisanja terapije
- stabilnije prebacivanje donje navigacije bez nepotrebne rekonstrukcije ekrana

### Uklonjeno
- demo-only ekran "Bolesti i stanja"
- produkcijski demo katalog i tihi fallback na izmišljene lijekove
- zastarjelo `Medication.isDemo` polje
- duplicirani kataloški UI za kategorije, djelatne tvari i proizvođače

## [0.3.2] - 2026-10-02

### Dodano
- filter po stvarnom HALMED statusu lijeka na tržištu
- filter po HALMED statusu nestašice
- regulatorni statusi prekida opskrbe i nestašice vidljivi su izravno na kartici i detalju lijeka

### Poboljšano
- ATK skupina V prikazuje se kao zasebna skupina umjesto generičkog "ostalo"
- ATK filter i izbornik ispravno obrađuju HALMED zapise s više ATK šifri
- release-candidate i data-sync workflowi sada prate buduće `feat/medix-pro-v*` razvojne grane bez ručnog prepisivanja verzije

## [0.3.1] - 2026-10-02

### Dodano
- napredni filteri baze lijekova: režim izdavanja, lista, cijena, ATK, oblik i nositelj/proizvođač
- sortiranje po nazivu, djelatnoj tvari, ATK šifri i cijeni
- usporedba 2 do 4 lijeka i pakiranja jedan uz drugi
- funkcionalno otvaranje ljekarni u Android aplikaciji za karte
- interaktivni profesionalni edukacijski moduli
- zaseban ekran sigurnosti i privatnosti

### Poboljšano
- HALMED javni registar postavljen kao primarni izvor identiteta lijeka; HZZO i cjenovni podaci služe kao enrichment
- automatske data-quality provjere blokiraju pravne osobe kao nazive lijekova, duplicate identitete, nevaljane ATK zapise i loše placeholdere
- detaljni HALMED podaci o načinu izdavanja, propisivanju, mjestu izdavanja i statusu lijeka prikazuju se odvojeno
- pretraživ odabir lijekova u modulu interakcija
- nedostajući interaction podatak više se ne prikazuje kao negativan rezultat
- uklonjeni neaktivni jezik/tema izbornici
- gumb za dijeljenje zamijenjen funkcionalnim kopiranjem strukturiranog sažetka lijeka
- bolja navigacija između pretrage i usporedbe

## [0.3.0] - 2026-10-02

### Dodano
- profesionalni MediX Android workspace za lijekove
- objedinjeni katalog lijekova i pakiranja
- MediX Smart pretraga
- ATK preglednik
- MKB-10 lokalni registar s 39.559 zapisa
- klinički kalkulatori: BMI, BSA, eGFR MDRD, CHA₂DS₂-VASc, HAS-BLED, GCS, MELD, PERC i Wells PE
- lokalni podsjetnici za terapiju
- marketinški README i novi Android adaptive icon
- APK + AAB release pipeline
- automatsko GitHub Release izdavanje s binarnim assetima i SHA-256 sumama

### Poboljšano
- detalj lijeka
- pretraga i klasifikacija
- prikaz cijena i pakiranja
- organizacija profesionalnih alata
- privatnost bez obveznog korisničkog računa
