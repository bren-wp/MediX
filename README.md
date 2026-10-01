# MediX

**MediX** je mobilna aplikacija za brz, pregledan i pouzdan pristup informacijama o lijekovima — **bez registracije i bez prijave**.

> Trenutna verzija repozitorija je razvojni prototip `0.1.0`. Medicinski zapisi u prototipu su jasno označeni kao demo podaci i nisu zamjena za službenu uputu, liječnika ili ljekarnika.

## Što već radi

- moderna MediX dark tema
- početni ekran bez auth flowa
- pretraga po nazivu, djelatnoj tvari, kategoriji i tekstu indikacije
- kategorije lijekova
- detalj lijeka
- lokalni favoriti unutar trenutne sesije
- nedavno pregledani lijekovi
- Moja terapija: lijek, opis doze, vremena, aktiviranje i brisanje tijekom sesije
- osnovni demonstracijski modul interakcija
- oznaka izvora i zadnje revizije podatka
- CI: `flutter analyze`, `flutter test` i Android debug smoke build

## Smjer proizvoda

Planirano:

- trajna lokalna pohrana favorita
- trajna lokalna pohrana terapije i favorita
- lokalni OS podsjetnici
- kalendar terapije
- barkod / DataMatrix skeniranje
- pregled djelatnih tvari
- proizvođači
- bolesti i stanja
- službeni dokumenti
- offline cache
- verzionirana sinkronizacija medicinskih podataka
- hrvatski kao primarni jezik uz kasniju višejezičnost
- Android i iOS produkcijski pipeline

## Privatnost po dizajnu

Osnovna aplikacija ne zahtijeva račun. Favoriti, terapija, podsjetnici i postavke ciljano ostaju lokalni na uređaju. Eventualna buduća cloud sinkronizacija mora biti zasebna, dobrovoljna funkcija.

## Tehnologija

- Flutter / Dart
- Material 3
- bez vanjskih runtime paketa u početnom skeletonu
- modularna struktura po domenama

## Lokalno pokretanje

Instaliraj aktualni Flutter stable i pokreni:

```bash
flutter pub get
flutter run
```

Ako repozitorij još nema generirane platform host foldere, napravi ih jednom:

```bash
flutter create --org com.brendigo.medix --project-name medix --platforms=android,ios .
```

Provjere:

```bash
flutter analyze
flutter test
```

## Struktura

```text
lib/
  app/
  core/
  data/
  features/
  models/
  state/
  widgets/
test/
docs/
.github/workflows/
```

## Medicinski podaci

Produkcijska verzija mora koristiti provjerljive, verzionirane i pravno dopuštene izvore. Svaki zapis mora moći prikazati izvor i datum revizije.

Više:

- [Arhitektura](docs/ARCHITECTURE.md)
- [Branding](docs/BRANDING.md)
- [Upravljanje medicinskim podacima](docs/DATA_GOVERNANCE.md)

## Status

Aktivni razvoj.
