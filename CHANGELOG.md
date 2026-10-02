# Changelog

Sve značajne promjene MediX projekta dokumentiraju se u ovoj datoteci.

## [0.3.2] - u razvoju

### Dodano
- filter po stvarnom HALMED statusu lijeka na tržištu
- filter po HALMED statusu nestašice
- regulatorni statusi prekida opskrbe i nestašice vidljivi su izravno na kartici i detalju lijeka

### Poboljšano
- ATK skupina V prikazuje se kao zasebna skupina umjesto generičkog "ostalo"
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
