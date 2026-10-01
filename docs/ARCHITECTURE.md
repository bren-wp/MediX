# MediX arhitektura

## Trenutni slojevi

- `models/` — domenski modeli
- `data/` — repozitoriji i izvori podataka
- `state/` — aplikacijsko stanje
- `features/` — korisničke funkcionalnosti i ekrani
- `widgets/` — zajedničke UI komponente
- `core/` — tema i zajednička infrastruktura

## Ciljana produkcijska arhitektura

Mobilna aplikacija ne bi trebala sadržavati jedinu kopiju medicinske baze. Ciljani sustav:

1. službeni/licencirani izvori
2. importer i normalizacija
3. verzionirana centralna baza
4. read-only API za aplikaciju
5. lokalni cache
6. aplikacija s jasnim prikazom izvora i vremena zadnje sinkronizacije

## Entiteti

Planirana jezgra:

- medication
- active ingredient
- medicinal product
- pharmaceutical form
- strength
- manufacturer / marketing authorisation holder
- ATC classification
- indication
- contraindication
- warning
- side effect
- interaction
- document
- source
- source revision

## Privatnost

Aplikacija nema obveznu registraciju. Favoriti, terapija i podsjetnici projektirani su kao lokalni podaci. Ako se kasnije uvede sinkronizacija između uređaja, mora biti zasebna opcionalna funkcija uz eksplicitnu korisničku odluku.

## Sljedeći tehnički koraci

- trajna lokalna pohrana favorita i terapije
- modul podsjetnika i lokalnih notifikacija
- verzionirani JSON/API adapter
- importer službenih podataka
- robusniji testovi
- pristupačnost
- generirani Android/iOS host projekti i release pipeline
