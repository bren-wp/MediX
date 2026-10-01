# Upravljanje medicinskim podacima

MediX je visokoodgovoran informacijski proizvod. Medicinski sadržaj mora biti sljediv do izvora.

## Obvezni metapodaci zapisa

Svaki produkcijski zapis treba imati najmanje:

- identifikator izvora
- naziv izvora
- verziju ili datum dokumenta
- vrijeme uvoza
- vrijeme zadnje provjere
- status provjere
- regulatorni ili drugi službeni identifikator kada postoji

## Pravila

1. Generirani tekst nije autoritativni medicinski izvor.
2. Ručno uređeni sažeci moraju imati vezu na izvorni dokument.
3. Izmjena izvora mora stvoriti novu verziju, ne nevidljivo prepisati prethodnu.
4. Interakcije lijekova zahtijevaju posebno verificiran podatkovni izvor.
5. Aplikacija ne smije prikazati demo podatak kao službenu informaciju.
6. Nedostupnost podatka mora biti prikazana kao nedostupnost, a ne popunjena pretpostavkom.
7. Korisniku mora biti jasno da aplikacija ne zamjenjuje liječnika, ljekarnika ili službenu uputu o lijeku.

## Demo repozitorij

Trenutni `MedicationRepository.demo()` služi isključivo za razvoj funkcionalnosti i dizajna. Nije produkcijska medicinska baza.
