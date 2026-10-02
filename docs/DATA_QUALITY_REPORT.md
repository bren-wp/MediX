# MediX Data Quality Report

Tehnički izvještaj generiran iz službenih podatkovnih sinkronizacija.

- HALMED generirano: 2026-10-02T01:16:35.678890+00:00
- Prihvaćeni HALMED zapisi: 4462
- Jedinstveni nazivi: 4461
- Jedinstvene djelatne tvari: 1042
- Jedinstvene ATK šifre: 878
- Na recept: 4014
- Bez recepta (OTC): 448
- Bez poznatog režima izdavanja: 0
- Stavljeno u promet: 3037
- Nije stavljeno u promet: 1063
- Privremeni prekid opskrbe: 64
- Bez poznatog tržišnog statusa: 298
- Prijavljena nestašica: 0
- Bez evidentirane nestašice: 2843
- Bez poznatog statusa nestašice: 1619
- Bez ATK: 1
- Bez pakiranja: 0
- Odbačeni HALMED zapisi: 1882
- HZZO enrichment zapisi: 3901
- Cjenovni zapisi: 5341

## Razlozi odbacivanja

- `legal_entity_as_name`: 24
- `missing_authorization_number`: 1597
- `missing_name`: 1
- `revoked_authorization`: 260

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
