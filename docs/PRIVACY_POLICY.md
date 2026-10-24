# Politika privatnosti aplikacije MediX

**Datum primjene:** 25. listopada 2026.  
**Aplikacija:** MediX za Android (`com.brendigo.medix`)  
**Razvojni programer:** Brendigo, Rijeka, Hrvatska  
**Kontakt za privatnost:** info@brendigo.com

Ova se politika odnosi na aplikaciju MediX, a ne na sve ostale usluge Brendiga.

## Podaci koje aplikacija pohranjuje

U privatnu pohranu aplikacije na vašem Android uređaju mogu se spremiti omiljeni i nedavno pregledani lijekovi te unosi terapije: identifikator lijeka, opis doze, dani, vrijeme podsjetnika i status terapije. Aplikacija pamti i završetak uvodnog prikaza. Ne traži korisnički račun, e-poštu, ime ni dijagnozu.

Terapijski podaci mogu predstavljati osjetljive zdravstvene podatke. **Trenutačna verzija koristi SharedPreferences i nema zasebnu enkripciju na razini aplikacije.** Pohrana ostaje u privatnom prostoru aplikacije; Android automatska sigurnosna kopija podataka aplikacije je isključena.

## Izvanmrežni katalog i mrežna komunikacija

HALMED, HZZO i cjenovni zapisi ugrađeni su u aplikaciju za izvanmrežni pregled. MediX ne šalje terapije, favorite ni dijagnoze na svoj poslužitelj. Projekt ne sadrži SDK za oglašavanje ili praćenje analitike.

Poveznice na službene mrežne izvore lijekova nisu prikazane u korisničkom sučelju. Ako korisnik sam pokrene prikaz pravnih dokumenata ili pretragu ljekarni putem karata, otvorit će se druga aplikacija ili preglednik s vlastitim pravilima privatnosti. MediX uz te radnje ne šalje spremljenu terapiju.

## Obavijesti

Dozvola za obavijesti traži se samo kada korisnik uključi podsjetnike. MediX ne zahtijeva posebnu Android dozvolu za točne alarme. Podsjetnici se obrađuju lokalno i mogu kasniti ovisno o Android sustavu, bateriji i postavkama uređaja. Tekst podsjetnika ne sadrži naziv lijeka, opis doze ni druge osobne zdravstvene podatke. Podsjetnici imaju oznaku **privatno** (Android VISIBILITY_PRIVATE), pa sustav skriva osjetljiv sadržaj na sigurnom zaključanom zaslonu. Sama neutralna obavijest o vremenu terapije može biti vidljiva; ponašanje ovisi o uređaju i Androidovim postavkama.

## Izvoz i dijeljenje

Na korisnikov zahtjev MediX izrađuje ZIP s PDF sažecima terapije, omiljenih lijekova i podataka o aplikaciji. Izvoz se privremeno sprema u predmemoriju aplikacije; korisnik sam bira primatelja putem Android dijeljenja. Primatelj može imati vlastita pravila pohrane i prijenosa podataka.

ZIP datoteke starije od 24 sata uklanjaju se **pri izradi sljedećeg izvoza**, a Android može ranije očistiti predmemoriju. Nije zajamčeno automatsko brisanje točno nakon 24 sata.

## Brisanje i zadržavanje

Unosi ostaju na uređaju dok ih korisnik ne promijeni ili izbriše, odnosno dok ne ukloni aplikaciju. Brisanje aplikacije u pravilu uklanja njezine privatne podatke, ali ne može ukloniti datoteke koje je korisnik ranije podijelio drugim aplikacijama.

## Sigurnost i pitanja

MediX ograničava FileProvider na direktorij izvoza, onemogućuje nezaštićeni HTTP promet i isključuje automatsku Android sigurnosnu kopiju aplikacije. Nijedno rješenje ne jamči apsolutnu sigurnost na otključanom ili kompromitiranom uređaju.

Aplikacija je informativni alat, a djeca je trebaju koristiti uz nadzor odgovornih osoba. Primjenjivi su važeći propisi o privatnosti i zaštiti podataka, uključujući GDPR kada je primjenjiv. Za pitanja: **info@brendigo.com**.

Izmjenama aplikacije može se ažurirati ova politika i njezin datum.
