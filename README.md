<p align="center">
  <img src="docs/assets/medix-logo.webp" alt="MediX" width="420">
</p>

<h1 align="center">MediX — lijekovi, interakcije i klinički alati na jednom mjestu</h1>

<p align="center">
  Moderna Android baza lijekova za Hrvatsku, dizajnirana za liječnike, farmaceute, zdravstvene djelatnike, studente i korisnike kojima trebaju brze, strukturirane informacije o lijekovima.
</p>

<p align="center">
  <strong>Android</strong> · <strong>Flutter</strong> · <strong>MediX 0.3.0</strong> · <strong>Bez obvezne registracije</strong> · <strong>Offline-first katalog</strong>
</p>

<p align="center">
  <img src="docs/assets/medix-readme-cover.webp" alt="MediX aplikacija" width="100%">
</p>

## 💊 Profesionalna baza lijekova, napravljena za brz rad

MediX spaja katalog lijekova i pakiranja, detalje proizvoda, ATK klasifikaciju, cijene i doplate, interakcije, paralelne lijekove, terapiju, podsjetnike, MKB-10 i kliničke kalkulatore u jedno pregledno sučelje.

Aplikacija je razvijena kao **hrvatska profesionalna alternativa klasičnim bazama lijekova**, ali s modernijim UX-om, snažnom pretragom i vizualnim sustavom koji je od početka dizajniran za MediX.

### ⚡ Što MediX donosi

| | Modul | Što radi |
|---|---|---|
| 🔎 | **Brza pretraga lijekova** | Pretraga po nazivu, djelatnoj tvari, ATK šifri, kategoriji, pakiranju i nositelju |
| ✨ | **MediX Smart** | Pametna pretraga prirodnim upitom bez generiranja terapijskih preporuka |
| 💊 | **Detalj lijeka** | Djelatna tvar, jačina, oblik, pakiranje, ATK, režim izdavanja, cijene i doplate |
| 🔄 | **Paralelni i srodni lijekovi** | Grupiranje i usporedba lijekova prema djelatnoj tvari |
| ⚠️ | **Interakcije** | Modul za provjeru kombinacija lijekova i upozorenja |
| 🧮 | **Klinički alati** | BMI, BSA, eGFR, CHA₂DS₂-VASc, HAS-BLED, GCS, MELD, PERC i Wells PE |
| 🧬 | **ATK klasifikacija** | Pregled lijekova po ATK šiframa |
| 🩺 | **MKB-10** | Lokalni pretraživi registar s 39.559 zapisa |
| 📅 | **Moja terapija** | Lokalno spremljen plan terapije, kalendar i Android podsjetnici |
| ❤️ | **Favoriti** | Brzi pristup često korištenim lijekovima |
| 🤰 | **Posebne skupine** | Trudnoća i dojenje, djeca i starije osobe |
| 💶 | **Cijene i pakiranja** | Pretraživ pregled raspoloživih cjenovnih i paketnih zapisa |
| 🏥 | **Ljekarne** | Pripremljen lokacijski modul za ljekarne u blizini |
| 🎓 | **Edukacija** | Farmakologija, sigurnost lijekova i profesionalni edukacijski moduli |

## 🧠 MediX Smart

Umjesto da korisnik mora znati točan naziv proizvoda, MediX Smart razumije strukturirane upite poput:

- `paracetamol 500 mg`
- `antibiotici na recept`
- `ATK C09`
- `lijekovi za alergiju`

Rezultati se rangiraju iz lokalnog kataloga prema nazivu, djelatnoj tvari, ATK šifri, kategoriji, pakiranju i farmaceutskom obliku.

## 🧮 Klinički alati

MediX 0.3.0 uključuje devet brzih kalkulatora i bodovnih sustava:

**BMI · BSA Mosteller · eGFR MDRD · CHA₂DS₂-VASc · HAS-BLED · Glasgow Coma Scale · MELD · PERC · Wells PE**

Alati su napravljeni kao pomoćni profesionalni izračuni. Rezultat sam po sebi nije dijagnoza niti terapijska preporuka.

## 📚 ATK + MKB-10

MediX objedinjuje farmakološku i dijagnostičku klasifikaciju:

- pretraživ ATK pregled s povezanim lijekovima i djelatnim tvarima
- **39.559 MKB-10 zapisa** u lokalnoj bazi
- trenutna pretraga bez čekanja mreže
- jednostavno prebacivanje ATK ↔ MKB-10

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

## 📦 Android buildovi

CI pipeline provjerava kod i generira:

- **APK** — direktna instalacija i testiranje na Android uređajima
- **AAB** — Android App Bundle za distribucijski pipeline

Release candidate build prolazi `flutter analyze`, testove, release APK i release AAB korake prije objave artefakata.

> Produkcijsko potpisivanje za trgovinu zahtijeva privatni release keystore. Privatni ključevi se ne pohranjuju u repozitorij.

## 🛠️ Tehnologija

- Flutter / Dart
- Android package: `com.brendigo.medix`
- lokalna pohrana favorita i terapije
- lokalne Android obavijesti i dnevni podsjetnici
- verzionirani offline katalozi
- automatizirane provjere kvalitete i build pipeline

## 🧭 Smjer razvoja

MediX se razvija prema jednoj aplikaciji za profesionalni rad s lijekovima: **širi katalog, bogatiji detalji lijeka, naprednije interakcije, posebna doziranja, sigurnosni moduli, edukacija i još više kliničkih alata** — bez napuštanja MediX dizajna.

---

<p align="center">
  <strong>MediX 0.3.0</strong><br>
  Vaš vodič kroz lijekove.
</p>
