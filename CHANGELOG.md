# Changelog

Sve značajne promjene MediX projekta dokumentiraju se u ovoj datoteci.

## [0.3.15] - 2026-10-17

### Provjereni HZZO datumi i veleprodajne cijene
- odbacuju se nevaljani ili nepostojeći kalendarski datumi (npr. 30. veljače) u izvoru HZZO liste
- veleprodajna cijena bez provjerenog datuma objave više se ne povezuje s lijekom uz izmišljeni zamjenski datum
- neispravan ili oštećen pomoćni cjenovni katalog ne ruši HALMED katalog
- cijene s neispravnim iznosima ili izričito proturječnom valutom ne ulaze u prikaz
- HZZO doplate i veleprodajne cijene koriste jedinstvenu konzervativnu validaciju numeričkih vrijednosti
- uklonjen je duplicirani parser novčanih vrijednosti
- prošireni su regresijski testovi za nedostajuće datume, nevaljane podatke i uspješan službeni uvoz

## [0.3.14] - 2026-10-14

### Jednostavnija i dosljednija pretraga lijekova
- brzi filtri za recept, bezreceptno izdavanje, HZZO osnovnu/dopunsku listu i potvrđene doplate mogu se kombinirati
- promjena jednog brzog filtra više ne poništava ostale liječničke kriterije niti napredne filtre
- ponovni dodir aktivnog filtra uklanja samo taj filtar
- gumb „Svi” uklanja i napredne filtre, ali čuva uneseni pojam pretrage i sortiranje
- aktivnost „Svi” točno odražava sve aktivne kriterije, ne samo tri brza polja

### Pristupačniji početni ekran Android aplikacije
- šest glavnih poveznica, četiri profesionalna alata i kategorije sada koriste visinu kartica prilagođenu dostupnoj širini i veličini teksta
- manje rizika od okomito odrezanih naslova pri povećanom Android tekstu i na mobitelima širine 320 px
- navigacija i postojeća funkcionalnost kartica ostaju sačuvane

### Regresijske provjere
- testovi provjeravaju kombiniranje recepata, HZZO statusa i cijena bez gubitka naprednih kriterija
- widget test provjerava istodobno aktivne brze filtre, samostalno uklanjanje i resetiranje
- widget test otvara pretragu s početnog ekrana i otkriva RenderFlex preljeve na 320 px uz velik tekst
- obvezni flutter analyze, testovi, Dart audit i Android APK/AAB prije spajanja i objave

## [0.3.13] - 2026-10-14

### Sigurnije prepoznavanje izdavanja lijekova
- uvoz HALMED i HZZO zapisa sada koristi zajednički parser statusa izdavanja, bez duplicirane heuristike
- podržane službene oznake `BR` i `BRX` za bezreceptno izdavanje te `R` i `RS` za izdavanje na recept
- podržan jasan tekst "bez recepta", "na recept" i "uz recept", uz zadržavanje izvornog statusa u stručnim metapodacima
- negirani, proturječni ili neprepoznati tekstovi ostaju **nepotvrđeni**, umjesto da se lijek pogrešno svrsta u bezreceptne
- kod nepotvrđenog statusa usporedba i kopirani sažetak prikazuju da izdavanje nije potvrđeno
- postojeći brzi filtri i profesionalna pretraga koriste isti konzervativni podatak o izdavanju

### Kvaliteta i provjere
- testovi za `BR/BRX/R/RS`, jasno napisane režime izdavanja, negacije, kontradikcije i nepoznate oznake
- integracijski test pretraživanja HALMED zapisa s potvrđenim i nepotvrđenim statusima
- postojeće provjere HZZO doplata, pakiranja, cjenika i službenih izvora ostaju aktivne
- obvezan Flutter analyze, svi testovi, Dart dead-code audit i Android APK/AAB build prije izdanja

## [0.3.12] - 2026-10-14

### Sigurna usporedba lijekova
- usporedba 2–4 lijeka koristi istu validaciju HZZO doplate i veleprodajne cijene kao detalj lijeka
- doplata se ne prikazuje bez potvrđenog podudaranja s Dopunskom listom HZZO-a
- nepotvrđen HZZO status nije prikazan kao tvrdnja da lijek nije na listi
- usporedba navodi datum primjene HZZO liste kada je potvrđen, uz zaseban tekst za nedostajući datum
- nazivi stupaca jasno razlikuju doplatu po originalnom pakiranju od najviše cijene na veliko
- pretraga odabira lijekova za usporedbu koristi indeksirana polja kataloga

### Pouzdaniji zasebni cjenik
- odbacuju se negativni, ne-konačni i nevažeći iznosi; ostaju označeni kao nedostupni
- datum objave izvora ne pretpostavlja se ako nedostaje ili je nevaljan
- iznosi su označeni kao cijene *na veliko*, ne kao osobni trošak ili maloprodajna cijena
- normalizirani tekst zapisa priprema se jednom pri učitavanju cjenika radi bržeg ponovnog pretraživanja
- dotjerana tipografija i prikaz cijene na manjim ekranima

### Provjere
- regresijski testovi za usporedbu HZZO osnovne i dopunske liste, nevaljane cijene te datume
- regresijski testovi validacije izvora, EUR iznosa i prikaza datuma objave cjenika
- prije spajanja provjeriti Flutter analyze, sve testove, Dart audit i Android APK/AAB buildove

## [0.3.11] - 2026-10-14

### Brža pretraga iz kataloga lijekova
- normalizirani pretraživi tekst svakog lijeka izračunava se jednom pri otvaranju pretrage, ne iznova pri svakom slovu
- tekst upita rastavlja se na riječi samo jednom po pretraživanju
- postojeći kriteriji, ATK pretraga, dijakritici, cijene i sigurnosni filtri zadržavaju isto ponašanje
- indeksi koriste identitet zapisa i mogu sigurno pretraživati dodatni zapis koji nije unaprijed indeksiran

### Provjerljivi HZZO izvori i datumi
- nakon točnog povezivanja lijeka i pakiranja prikazuje se izvor potvrđene HZZO liste i datum primjene iz službenih podataka
- zapis bez službenog datuma primjene ne dobiva izmišljeni datum HZZO doplate
- HZZO status bez potvrđenog datuma jasno označava da datum nije potvrđen
- kopirani sažetak lijeka sadrži HZZO izvor i datum primjene kada postoje
- uklonjena pogreška oblikovanja u sastavu ekrana detalja lijeka

### Provjere
- testovi uspoređuju indeksiranu i uobičajenu pretragu kroz dijakritike, ATK, lijekove, napredne filtre i sortiranje
- testovi provjeravaju slučajeve bez HZZO datuma te prijenos HZZO izvora isključivo na sigurno upareno pakiranje
- Flutter analiza, svi testovi, Dart reachability audit i Android APK/AAB build obvezni su prije objave

## [0.3.10] - 2026-10-14

### Brža pretraga za liječnike i pacijente
- novi brzi filtri jednim dodirom: svi, lijekovi na recept, bez recepta, osnovna i dopunska HZZO lista, potvrđene doplate
- filtri se kombiniraju s tekstualnom pretragom i postojećim naprednim filtrima, bez otvaranja dodatnog izbornika
- naziv neprovjerenog HZZO statusa više ne tvrdi da lijek nije na listi

### Cijene bez pogrešnih usporedbi
- HZZO doplate i veleprodajne cijene sortiraju se zasebno, uz smjer od manjeg ili većeg iznosa
- filtri cijena koriste iste validacije EUR iznosa i HZZO statusa kao detalj lijeka
- nepotvrđeni, negativni i ne-konačni iznosi nisu kvalificirani za prikaz kao dostupna cijena u pretrazi
- nedostupne cijene uvijek su iza potvrđenih za odabranu vrstu cijene

### Stabilnost, jezici i testiranje
- obrada pogreške pri otvaranju HZZO poveznice ne prekida pregled lijeka
- hrvatske i engleske oznake brzih filtara i odvojenog sortiranja
- regresijski testovi provjeravaju neuspoređivanje doplate i veleprodajne cijene, neprovjeren HZZO status, validaciju valuta, brze filtre i nedostupan preglednik

## [0.3.9] - 2026-10-14

### Pouzdanost podataka o cijenama i doplatama
- HZZO doplata i HALMED veleprodajna cijena više se ne povezuju s drugim poznatim jačinama ili brojem jedinica pakiranja
- neprovjerljiva poznata jačina ili broj jedinica zaustavljaju uparivanje, umjesto prenošenja cijene na pogrešno pakiranje
- prvo se uspoređuje naziv lijeka pa tek potom obrađuju jačina i pakiranje kako bi uparivanje bilo učinkovitije
- nevaljani negativni i ne-konačni ulazni iznosi ne uvoze se kao cijene
- prošireni detalj i kopirani sažetak koriste istu validaciju dostupnih iznosa kao početni cjenovni pregled

### Službeni dokumenti
- izravne poveznice na uputu o lijeku i sažetak opisa svojstava lijeka kada ih službeni izvor dostavlja
- provjera HTTPS-a i dopuštenih službenih domena prije prikazivanja poveznice
- jasna poveznica na HALMED bazu za ručnu provjeru kada izravan dokument nije dostupan
- podržana polja za dokumente u HALMED parseru bez generiranja ili izmišljanja PDF datoteka
- engleski i hrvatski nazivi službenih dokumenata uz postojeći fallback

### Testovi
- regresijski slučajevi za različitu jačinu, količinu pakiranja i nepotpuna HALMED polja
- testiranje odbijanja sumnjivih URL-ova i prikaza dostupnih dokumenata
- CI analiza, testovi, audit koda te Android APK/AAB buildovi obvezni su prije objave

## [0.3.8] - 2026-10-14

### Jednostavniji profesionalni pregled lijekova
- najvažnije informacije na početku detalja: izdavanje na recept ili bez recepta, HZZO status i službeno potvrđena doplata
- različiti pojmovi jasno odvojeni: Osnovna/Dopunska lista HZZO-a, obvezno i dopunsko zdravstveno osiguranje
- nepoznati status liste ne znači automatski da lijek nije pokriven
- maloprodajna i najviša veleprodajna cijena prikazuju se odvojeno, bez izmišljenih iznosa i jamstava o osobnom iznosu za plaćanje
- provjerena HZZO doplata može biti vidljiva već u rezultatu pretrage
- direktna poveznica na HZZO službene liste lijekova za dodatnu provjeru

### UI/UX i pristupačnost
- uklonjena nepotrebno velika dekorativna ilustracija u detaljima lijeka
- regulatorni/stručni i dodatni cjenovni podaci grupirani u proširive sekcije
- engleski i hrvatski tekstovi o osiguranju i plaćanju, uz postojeći engleski fallback

### Validacija i testovi
- validacija cijena i valute prije prikaza, bez implicitnog izračuna cijene s dopunskim osiguranjem
- regresijski testovi zabrane prikaza HZZO doplate za nepoznate i pogrešne statuse lista
- widget test sa scenarijem nepoznate pokrivenosti i OTC lijeka

## [0.3.7] - 2026-10-14

### Terapija i podsjetnici
- serijalizirane obnove Android alarma kako brze izmjene ili brisanje terapije ne bi vratile zastarjele rasporede
- stroga normalizacija vremena na HH:mm pri unosu i obnovi lokalno spremljenih terapija
- nakon odobrenja dozvola ponovno se usklađuju postojeći podsjetnici
- ekran terapije sada lijeno prikazuje stavke velikog rasporeda

### Korisničko iskustvo i performanse
- status dozvola podsjetnika koristi centralizirane engleske i hrvatske poruke uz engleski fallback za ostale jezike
- Postavke se oporavljaju i od pogreške Android servisa za dozvole
- pronalaženje lijeka po ID-u koristi predizgrađeni indeks umjesto prolaska cijelog kataloga

### Privatnost i pravni sadržaj
- dodani posebni, javno dostupni MediX dokumenti o privatnosti i uvjetima korištenja, povezani s Postavkama, README-om i PDF izvozom
- lokalna pohrana zdravstvenih podataka i ograničenja dijeljenja objašnjeni bez tvrdnji o nepostojećoj aplikacijskoj enkripciji

### Regresijske provjere
- valjanost i sortiranje vremena, uključujući odbacivanje nevaljanih vrijednosti
- sprječavanje istodobne sinkronizacije alarma pri brzim promjenama
- obnova vremenskih zapisa iz SharedPreferences
- ispravnost lokalizacije poruka dozvola

## [0.3.6] - 2026-10-13

### Privatnost i sigurnost
- FileProvider više ne dijeli cijelu predmemoriju nego isključivo direktorij MediX ZIP izvoza
- Android dijeljenje verificira kanonsku putanju, naziv i ekstenziju ZIP-a i odbija druge datoteke
- automatsko čišćenje prethodnih izvoza starijih od 24 sata bez pristupa drugim privremenim datotekama
- HTTPS je obavezan za poveznice koje MediX otvara izvana
- uklonjeni su nepotrebni parametri iz Flutter/Android mosta za dijeljenje datoteka

### Korisničko iskustvo i sadržaj
- README redizajniran kao premium produktna prezentacija na engleskom jeziku
- iskorišteni su postojeći originalni MediX vizualni materijali bez izmišljenih screenshotova
- preciznije su predstavljena ograničenja interakcija i jezične podrške

### Provjere
- CI audit dostupnosti svih produkcijskih Dart izvora iz `lib/main.dart` nadopunjuje `flutter analyze`
- regresijski testovi izolacije izvoza, FileProvider konfiguracije i zaštite osjetljivih terapijskih podataka
- widget testovi za klik kroz Postavke → Privatnost i promjenu jezika

## [0.3.5] - 2026-10-13

### Dodano
- Postavke s trajnim odabirom jezika, dozvolama podsjetnika, izvozom, pravnim poveznicama i Brendigo autorstvom
- 24 podržana jezika s engleskim kao primarnim jezikom aplikacije
- lokalni izvoz terapije, favorita i podataka o aplikaciji u PDF dokumente unutar ZIP arhive
- Android FileProvider dijeljenje exporta bez široke storage dozvole
- zaseban Google Play production AAB workflow s privatnim upload keystoreom iz GitHub Secrets
- zasebna Android themed monochrome launcher ikona

### Poboljšano
- Android build cilja API 36
- cloud backup lokalne terapije je isključen, a cleartext promet zabranjen
- onboarding, glavna navigacija, početni discovery i ključne postavke koriste lokalizacijski sloj
- About i Privacy sadržaj zamijenjen je produkcijskim, marketinški uređenim tekstom
- medicinski disclaimer usklađen je s Google Play smjernicama za zdravstvene aplikacije
- CI više ne regenerira Android host projekt prije smoke builda
- launcher adaptive ikona dodatno je ispolirana

### Testovi
- provjera da je engleski primaran i da je dostupno više od 20 jezika
- provjera lokalnog ZIP izvoza s tri valjana PDF dokumenta
- provjera promjene i normalizacije spremljenog jezika

## [0.3.4] - 2026-10-09

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
