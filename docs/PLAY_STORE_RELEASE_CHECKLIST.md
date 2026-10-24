# MediX 1.0.3 — kontrolni popis za Google Play

**Android paket:** `com.brendigo.medix`  
**Verzija:** `1.0.3` · **versionCode:** `26`

## Automatski provjerljivo

- [x] Ciljani Android API 36 (uvjet za nove prijave od 31. kolovoza 2026.).
- [x] Android podatkovna sigurnosna kopija onemogućena, nezaštićeni HTTP promet isključen.
- [x] Nema posebne dozvole za točne alarme; lokalni podsjetnici koriste manje invazivno zakazivanje.
- [x] Hrvatski je jedini jezik aplikacije; pravni dokumenti i medicinsko upozorenje dostupni su na hrvatskom.
- [x] Nisu prikazane vanjske poveznice na službene izvore lijekova u kliničkim ekranima.
- [ ] Potvrditi završne testove, Flutter analizu, audit i APK/AAB release artefakte za verziju 1.0.3 na točnom commitu.
- [ ] Testirati pokretanje, terapiju, izvoz, 320 px i veliki font na fizičkim Android uređajima.

## Potpisivanje

**GitHub javno izdanje može koristiti razvojni (debug) potpis. Takav AAB nije potvrđeno spreman za Play.**

Workflow `.github/workflows/play-production-build.yml` zahtijeva privatne GitHub Secrets:

- `MEDIX_UPLOAD_KEYSTORE_BASE64`
- `MEDIX_UPLOAD_KEY_ALIAS`
- `MEDIX_UPLOAD_KEY_PASSWORD`
- `MEDIX_UPLOAD_STORE_PASSWORD`

- [ ] Konfigurirati privatni upload ključ (nikada ga ne spremati u repozitorij).
- [ ] Ručno pokrenuti **Google Play production AAB** i potvrditi uspjeh provjere potpisa.
- [ ] Učitati tako potpisani AAB u Play Console.

## Zdravstvena pravila i sigurnost

- [ ] Popuniti **Health apps declaration**, uključujući kategorije liječenja/praćenja terapije i stručne referentne alate prema stvarnim funkcijama.
- [ ] Provjeriti regulatornu klasifikaciju pojedinih kliničkih kalkulatora i tvrdnji; sama napomena ne daje automatsko oslobođenje od medicinskih propisa.
- [ ] Popuniti **Data safety** na temelju stvarnih dozvola, lokalne pohrane i dijeljenja datoteka.
- [ ] Potvrditi javno dostupnu hrvatsku [Politiku privatnosti](PRIVACY_POLICY.md).
- [ ] U opis trgovine uključiti medicinsko upozorenje: MediX nije medicinski uređaj, ne postavlja dijagnozu i ne zamjenjuje liječnika ni ljekarnika.
- [ ] Unijeti odgovarajuću dobnu kategoriju, ocjenu sadržaja i kontakt podatke.

## Prikaz i objava

- [ ] Pripremiti stvarne snimke zaslona iz izdanja 1.0.3, ne ilustracije.
- [ ] Provjeriti 16 KB poravnanje i izvješće Play pre-launch testova.
- [ ] Provjeriti tablet, pejzažni prikaz, povećane fontove, pristupačnost i otvorene izbornike.
- [ ] Provjeriti da se `versionCode=26` još nije koristio na toj istoj Play Console aplikaciji.
- [ ] Pokrenuti testno izdanje prije produkcijske distribucije.

**Završna objava dopuštena je tek nakon svih neoznačenih stavki.**
