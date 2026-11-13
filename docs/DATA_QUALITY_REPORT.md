# MediX Data Quality Report

Tehnički izvještaj generiran iz službenih podatkovnih sinkronizacija.

- HALMED generirano: 2026-11-13T12:09:02.544225+00:00
- Prihvaćeni HALMED zapisi: 4490
- Jedinstveni nazivi: 4489
- Jedinstvene djelatne tvari: 1043
- Jedinstvene ATK šifre: 878
- Na recept: 4041
- Bez recepta (OTC): 449
- Bez poznatog režima izdavanja: 0
- Stavljeno u promet: 3050
- Nije stavljeno u promet: 1078
- Privremeni prekid opskrbe: 66
- Bez poznatog tržišnog statusa: 296
- Prijavljena nestašica: 0
- Bez evidentirane nestašice: 2870
- Bez poznatog statusa nestašice: 1620
- Bez ATK: 1
- Bez pakiranja: 0
- Odbačeni HALMED zapisi: 1880
- HZZO enrichment zapisi: 4043
- Cjenovni zapisi: 5341

## Razlozi odbacivanja

- `legal_entity_as_name`: 26
- `missing_authorization_number`: 1606
- `missing_name`: 1
- `revoked_authorization`: 247

## Aktivne zaštite

- naziv lijeka mora postojati
- broj odobrenja mora postojati
- naziv ne smije biti jednak nositelju ili proizvođaču
- pravna osoba ne smije biti identitet lijeka
- tehnički/header placeholderi nisu dopušteni kao naziv
- URL/e-mail, brojčani i interpunkcijski placeholderi nisu dopušteni kao naziv
- izvor naziva mora biti eksplicitno vezan uz službeni HALMED stupac `Naziv`
- ATK je validiran kada je naveden
- duplicate ID i duplicate identitet zaustavljaju validaciju
- regresijski zapis `A1 d.o.o.` ne smije postojati
- izvorni `doza · doza` placeholder zaustavlja validaciju
- broj HALMED zapisa ne smije pasti ispod sigurnosnog minimuma
- HZZO i cijene ostaju enrichment slojevi

Ovaj izvještaj ne tvrdi potpunu pokrivenost svih mogućih tržišnih i
centralizirano odobrenih zapisa izvan onoga što je dohvaćeno javnim HALMED
workflowom. README/UI ne smiju koristiti tvrdnju „svi lijekovi” bez zasebne
potvrde pokrivenosti.
