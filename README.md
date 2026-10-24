<p align="center">
  <img src="docs/assets/medix-logo.webp" alt="MediX logotip" width="300">
</p>

<h1 align="center">MediX — Lijekovi, terapija i medicinski podaci na jednom mjestu</h1>

<p align="center">Profesionalna Android aplikacija na hrvatskom jeziku za pregled lijekova, terapije, cijena i zdravstvenih informacija.</p>

<p align="center"><strong>💊 Katalog lijekova</strong> · <strong>🔎 Napredna pretraga</strong> · <strong>📅 Plan terapije</strong> · <strong>🔐 Privatnost</strong></p>

<p align="center">
  <a href="https://github.com/bren-wp/MediX/releases/latest"><strong>Preuzmi MediX za Android →</strong></a>
</p>

<p align="center">
  <img src="docs/assets/medix-readme-cover.webp" alt="MediX — prikaz vizualnog identiteta" width="100%">
</p>

## Što nudi MediX?

MediX objedinjavanjem dostupnih zapisa HALMED-a i HZZO-a olakšava pregled podataka o lijekovima. Aplikacija uključuje:

- Pretragu naziva, djelatnih tvari, ATK šifri, oblika i pakiranja uz kombiniranje filtara.
- Regulatorne podatke, status izdavanja, HZZO osnovnu i dopunsku listu te provjerene iznose za konkretna pakiranja gdje su dostupni.
- Jasno razdvajanje veleprodajnih cijena, HZZO doplata i nepoznatih maloprodajnih cijena.
- Usporedbu lijekova, popise favorita i osobni plan terapije s lokalnim podsjetnicima.
- Kliničke orijentacijske kalkulatore, klasifikacije i dodatne alate.

**Cijene i pokriće nisu osobna ponuda ljekarne.** Ako identitet, jačina, pakiranje ili datum izvora nisu potvrđeni, MediX ne prikazuje izmišljene podatke. Nedostajući podatak nije dokaz da lijek nije dostupan ili da se ništa ne doplaćuje.

## Jednostavno dodavanje terapije

Za novi plan otvorite **Terapija → Dodaj terapiju → Odaberite lijek i pakiranje**. Po nazivu, djelatnoj tvari, ATK oznaci ili pakiranju pronađite točan zapis. Aplikacija više ne odabire prvi lijek iz kataloga automatski. Omiljeni i nedavno pregledani lijekovi prikazuju se kao prijedlozi. Unesite dozu, dane i vrijeme prema uputi liječnika ili ljekarnika. Plan se sprema lokalno i kada dozvola za podsjetnike nije odobrena.

## Hrvatski jezik

Izdanje **1.0.0** prikazuje korisničko sučelje, obavijesti i PDF izvještaje na hrvatskom jeziku, uključujući prvo pokretanje. Službeni nazivi lijekova i regulatorni nazivi iz izvornog kataloga nisu umjetno prevođeni.

**Nazivi lijekova, djelatne tvari, jačine, pakiranja i ostali medicinski podaci ostaju vidljivi.** Vanjske poveznice na službene izvore lijekova uklonjene su iz korisničkog sučelja. **Podrijetlo, datumi i regulatorni metapodaci ostaju dostupni** kako bi korisnik mogao procijeniti starost i pouzdanost podataka. Pravni dokumenti (politika privatnosti i uvjeti) ostaju javno dostupni.

## Privatnost i pouzdanost

- Katalog lijekova radi izvanmrežno; nema obvezne registracije, oglasa ni sustava praćenja.
- Terapija i favoriti ostaju lokalno, u privatnom prostoru aplikacije. **Zasebna enkripcija terapije nije implementirana.**
- Automatski Android backup za podatke aplikacije je isključen.
- Podsjetnici prikazuju samo neutralnu poruku bez naziva lijeka i doze. Androidova oznaka privatnosti skriva sadržaj na sigurnom zaključanom zaslonu; posebno dopuštenje za točne alarme nije potrebno.
- Izvoz podataka korisnik pokreće samostalno, a ZIP sadrži PDF dokumente na hrvatskom jeziku.

## Performanse i provjere

Učitavanje JSON kataloga obavlja se izvan glavne Flutter dretve, podaci se povezuju uz provjeru identiteta pakiranja, a nepotrebne UI kartice učitavaju se po potrebi. Automatski CI uključuje Flutter analizu, testove, provjeru stvarnih ugrađenih kataloga i audit dosegljivosti produkcijskog Dart koda.

## Izrada Android aplikacije

Potrebni su Flutter SDK, Android SDK i kompatibilni JDK.

```bash
flutter pub get
flutter analyze
flutter test
flutter build apk --release
flutter build appbundle --release
```

**Važno za Google Play:** javni GitHub APK/AAB mogu biti potpisani razvojnim ključem. Za Play Console potreban je AAB iz zasebnog workflowa **Google Play production AAB**, potpisan privatnim upload ključem; zatim su obvezni pregled politike za zdravstvene aplikacije, Data safety, provjere sadržaja i fizičkih uređaja. Više u [kontrolnom popisu](docs/PLAY_STORE_RELEASE_CHECKLIST.md).

## Službeni katalog i odgovornost

Podaci o lijekovima potječu iz objavljenih HALMED/HZZO zapisa, ali mogu biti zastarjeli ili nepotpuni. Aplikacija nije medicinski uređaj i ne zamjenjuje savjet liječnika ili ljekarnika. Nepostojanje prikazane interakcije nije dokaz sigurnosti kombinacije.

## Brendigo

Razvoj: **Brendigo** · [brendigo.com](https://brendigo.com) · info@brendigo.com

Poveznica na [brendigo.com](https://brendigo.com) dostupna je i unutar aplikacije na zaslonu **O aplikaciji MediX**.

[Politika privatnosti](docs/PRIVACY_POLICY.md) · [Uvjeti korištenja](docs/TERMS_OF_USE.md) · [Izdanja](https://github.com/bren-wp/MediX/releases)
