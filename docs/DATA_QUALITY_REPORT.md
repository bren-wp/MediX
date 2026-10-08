# MediX Data Quality Report

Tehnički izvještaj generiran iz službenih podatkovnih sinkronizacija.

- HALMED generirano: 2026-10-08T11:20:44.776286+00:00
- Prihvaćeni HALMED zapisi: 4469
- Jedinstveni nazivi: 4468
- Jedinstvene djelatne tvari: 1043
- Jedinstvene ATK šifre: 878
- Na recept: 4021
- Bez recepta (OTC): 448
- Bez poznatog režima izdavanja: 0
- Stavljeno u promet: 3040
- Nije stavljeno u promet: 1070
- Privremeni prekid opskrbe: 64
- Bez poznatog tržišnog statusa: 295
- Prijavljena nestašica: 0
- Bez evidentirane nestašice: 2852
- Bez poznatog statusa nestašice: 1617
- Bez ATK: 1
- Bez pakiranja: 0
- Odbačeni HALMED zapisi: 1883
- HZZO enrichment zapisi: 3769
- Cjenovni zapisi: 5341

## Razlozi odbacivanja

- `legal_entity_as_name`: 24
- `missing_authorization_number`: 1601
- `missing_name`: 1
- `revoked_authorization`: 257

## Aktivne zaštite

- naziv lijeka mora postojati
- broj odobrenja mora postojati
- naziv ne smije biti jednak nositelju ili proizvođaču
- pravna osoba ne smije biti identitet lijeka
- tehnički/header placeholderi nisu dopušteni kao naziv
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
