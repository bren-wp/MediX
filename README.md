<p align="center">
  <img src="docs/assets/medix-logo.webp" alt="MediX" width="420">
</p>

<h1 align="center">MediX — lijekovi, interakcije i klinički alati na jednom mjestu</h1>

<p align="center">
  Moderna Android aplikacija s opsežnim katalogom lijekova za Hrvatsku, dizajnirana za liječnike, farmaceute, zdravstvene djelatnike, studente i korisnike kojima trebaju brze, strukturirane informacije o lijekovima.
</p>

<p align="center">
  <strong>Android</strong> · <strong>Flutter</strong> · <strong>MediX 0.3.5</strong> · <strong>Bez obvezne registracije</strong> · <strong>Offline-first katalog</strong>
</p>

<p align="center">
  <img src="docs/assets/medix-readme-cover.webp" alt="MediX aplikacija" width="100%">
</p>

## 💊 Profesionalna baza lijekova, napravljena za brz rad

MediX spaja katalog lijekova i pakiranja, detalje proizvoda, ATK klasifikaciju, cijene i doplate, interakcije, paralelne lijekove, terapiju, podsjetnike, MKB-10 i kliničke kalkulatore u jedno pregledno sučelje.

Identitet lijeka dolazi iz javne **HALMED Baze lijekova**. **HZZO** se koristi kao dodatni sloj za listu, doplate, smjernice i druge refundacijske podatke, a službeni cjenovni izvor kao zaseban enrichment. Sinkronizacija prolazi automatske provjere kvalitete prije nego što se generirani katalog smije spremiti u repozitorij.

Aplikacija je razvijena kao **hrvatska profesionalna alternativa klasičnim bazama lijekova**, ali s modernijim UX-om, snažnom pretragom i vizualnim sustavom koji je od početka dizajniran za MediX.

### ⚡ Što MediX donosi

| | Modul | Što radi |
|---|---|---|
| 🔎 | **Napredna pretraga lijekova** | Naziv, djelatna tvar, ATK, pakiranje, nositelj, režim izdavanja, status tržišta, nestašica, lista i cjenovni filteri |
| ✨ | **MediX Smart** | Pametna pretraga prirodnim upitom bez generiranja terapijskih preporuka |
| 💊 | **Detalj lijeka** | Djelatna tvar, jačina, oblik, pakiranje, ATK, režim izdavanja, cijene i doplate |
| ↔️ | **Usporedba lijekova** | Usporedba 2–4 lijeka/pakiranja jedan uz drugi bez automatskog rangiranja |
| 🔄 | **Paralelni i srodni lijekovi** | Grupiranje proizvoda prema djelatnoj tvari |
| ⚠️ | **Interakcije** | Pretraživ odabir lijekova; nedostajući podatak nikada se ne prikazuje kao “nema interakcije” |
| 🧮 | **Klinički alati** | BMI, BSA, eGFR, CHA₂DS₂-VASc, HAS-BLED, GCS, MELD, PERC i Wells PE |
| 🧬 | **ATK klasifikacija** | Pregled lijekova po ATK šiframa |
| 🩺 | **MKB-10** | Lokalni pretraživi registar s 39.559 zapisa |
| 📅 | **Moja terapija** | Lokalni plan po danima u tjednu, kalendar i Android podsjetnici |
| ❤️ | **Favoriti** | Brzi pristup često korištenim lijekovima |
| 🤰 | **Posebne skupine** | Trudnoća i dojenje, djeca i starije osobe |
| 💶 | **Cijene i pakiranja** | Pretraživ pregled raspoloživih cjenovnih i paketnih zapisa |
| 🏥 | **Ljekarne** | Otvaranje pretrage ljekarni u Android aplikaciji za karte |
| 🎓 | **Edukacija** | Interaktivni vodiči o zapisima lijekova, sigurnosti, usporedbi i kalkulatorima |

## 🧠 MediX Smart

Umjesto da korisnik mora znati točan naziv proizvoda, MediX Smart razumije strukturirane upite poput:

- `paracetamol 500 mg`
- `na recept`
- `bez recepta`
- `ATK C09`

Rezultati se rangiraju iz lokalnog kataloga prema nazivu, djelatnoj tvari, ATK šifri, kategoriji, pakiranju i farmaceutskom obliku. Klasična pretraga dodatno omogućuje kombiniranje režima izdavanja, HALMED statusa na tržištu, statusa nestašice, statusa HZZO liste, cijene, ATK skupine, oblika i nositelja/proizvođača.

## 🧮 Klinički alati

MediX 0.3.5 uključuje devet brzih kalkulatora i bodovnih sustava:

**BMI · BSA Mosteller · eGFR CKD-EPI 2021 · CHA₂DS₂-VASc · HAS-BLED · Glasgow Coma Scale · originalni MELD · PERC · Wells PE**

Alati su napravljeni kao pomoćni profesionalni izračuni. Rezultat sam po sebi nije dijagnoza niti terapijska preporuka.

## 📚 ATK + MKB-10

MediX objedinjuje farmakološku i dijagnostičku klasifikaciju:

- pretraživ ATK pregled s povezanim lijekovima i djelatnim tvarima
- **39.559 MKB-10 zapisa** u lokalnoj bazi
- trenutna pretraga bez čekanja mreže
- jednostavno prebacivanje ATK ↔ MKB-10

## 🌍 Jezici i postavke

MediX 0.3.5 uvodi **24 podržana jezika** s engleskim kao primarnim jezikom aplikacije. Hrvatski je dostupan iz Postavki, a odabrani jezik ostaje spremljen lokalno na uređaju.

Postavke objedinjuju jezik, dozvole podsjetnika, lokalni PDF→ZIP izvoz, sigurnost i privatnost, pravne poveznice, verziju aplikacije i autora **Brendigo**.

## 📦 Privatni PDF → ZIP izvoz

Korisnik može izraditi lokalnu ZIP arhivu koja sadrži PDF dokumente za terapijski plan, favorite i podatke o aplikaciji. Izvoz se generira u privremenoj memoriji aplikacije i dijeli kroz Androidov sustav za dijeljenje, bez zahtjeva za širokim pristupom datotekama.

## 🔐 Privatnost bez nepotrebnog računa

MediX ne zahtijeva obveznu prijavu ili registraciju. Favoriti, nedavno pregledani lijekovi, terapija i podsjetnici ostaju lokalno na uređaju.

## 🎨 MediX Design System

MediX koristi vlastiti dark navy/cyan identitet:

- duboka navy pozadina
- cyan i electric-blue akcijski naglasci
- capsule-plus brand mark
- kompaktne profesionalne kartice
- jasna hijerarhija podataka
- Android-first responzivni layout

Dizajn nije generički medical template — cijeli vizualni jezik pripada MediX brendu.

## ✅ Google Play production baseline

- Android 16 / **target API 36**
- privatni upload keystore ostaje izvan repozitorija
- zaseban `Google Play production AAB` workflow zahtijeva GitHub Secrets i provjerava potpis AAB-a
- `android:allowBackup="false"` za lokalne terapijske podatke
- cleartext promet je isključen
- FileProvider izlaže samo privremene export datoteke
- javna politika privatnosti: https://brendigo.com/politika-privatnosti/
- uvjeti korištenja: https://brendigo.com/uvjeti-koristenja/

MediX je zdravstvena informacijska aplikacija, nije medicinski uređaj i ne postavlja dijagnozu niti zamjenjuje zdravstvenog stručnjaka.

## 📦 Android buildovi

CI pipeline provjerava kod i generira:

- **APK** — direktna instalacija i testiranje na Android uređajima
- **AAB** — Android App Bundle za distribucijski pipeline

Release candidate build prolazi `flutter analyze`, testove, release APK i release AAB korake prije objave artefakata.

Privatni produkcijski keystore učitava se samo kada je lokalno ili u CI okruženju dostupan `android/key.properties`. Bez privatnog ključa release-candidate pipeline namjerno koristi postojeći debug signing kako bi build ostao provjerljiv bez pohrane tajni u repozitorij.

> Produkcijsko potpisivanje za trgovinu zahtijeva privatni release keystore. Privatni ključevi se ne pohranjuju u repozitorij.

## 🛠️ Tehnologija

- Flutter / Dart
- Android package: `com.brendigo.medix`
- lokalna pohrana favorita, terapije i jezičnih postavki
- lokalne Android obavijesti i tjedni raspored podsjetnika
- uređivanje postojećih terapijskih planova bez brisanja unosa
- lokalni PDF→ZIP izvoz bez cloud uploada
- 24 jezika s engleskim kao primarnim
- verzionirani offline katalozi
- automatizirane provjere kvalitete, provjera izvora službenog naziva lijeka i build pipeline

## 🧭 Smjer razvoja

MediX se razvija prema jednoj aplikaciji za profesionalni rad s lijekovima: **širi katalog, bogatiji detalji lijeka, naprednije interakcije, posebna doziranja, sigurnosni moduli, edukacija i još više kliničkih alata** — bez napuštanja MediX dizajna.

---

<p align="center">
  <strong>MediX 0.3.5</strong><br>
  Vaš vodič kroz lijekove.
</p>
