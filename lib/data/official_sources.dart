class OfficialDataSource {
  const OfficialDataSource({
    required this.id,
    required this.name,
    required this.url,
    required this.purpose,
    required this.authority,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final String url;
  final String purpose;
  final String authority;
  final DateTime updatedAt;
}

abstract final class OfficialSources {
  static final hzzoBasicList = OfficialDataSource(
    id: 'hzzo-basic-2026-10-01',
    name: 'HZZO Osnovna lista lijekova',
    url:
        'https://hzzo.hr/sites/default/files/web_OLL%20po%20dijelovima_stupa%20na%20snagu%2001_10_2026.xlsx',
    purpose: 'Status na Osnovnoj listi, pakiranja, propisivanje i HZZO podaci',
    authority: 'Hrvatski zavod za zdravstveno osiguranje',
    updatedAt: DateTime(2026, 10, 1),
  );

  static final hzzoSupplementaryList = OfficialDataSource(
    id: 'hzzo-supplementary-2026-10-01',
    name: 'HZZO Dopunska lista lijekova',
    url:
        'https://hzzo.hr/sites/default/files/web_DLL%20po%20dijelovima_stupa%20na%20snagu%2001_10_2026.xlsx',
    purpose: 'Status na Dopunskoj listi i iznos doplate/sudjelovanja',
    authority: 'Hrvatski zavod za zdravstveno osiguranje',
    updatedAt: DateTime(2026, 10, 1),
  );

  static final eLijekovi = OfficialDataSource(
    id: 'elijekovi',
    name: 'eLijekovi',
    url: 'https://elijekovi-hzzo.gov.hr/',
    purpose:
        'Nacionalna baza lijekova dostupnih u Republici Hrvatskoj, neovisno o HZZO listi',
    authority: 'HZZO / Ministarstvo zdravstva / HALMED',
    updatedAt: DateTime(2026, 10, 1),
  );

  static final halmedPrices = OfficialDataSource(
    id: 'halmed-prices-2026',
    name: 'HALMED / Narodne novine – cijene lijekova 2026.',
    url:
        'https://narodne-novine.nn.hr/clanci/sluzbeni/2026_06_64_783.html',
    purpose:
        'Najviša dozvoljena cijena lijeka na veliko; nije maloprodajna ljekarnička cijena',
    authority: 'Agencija za lijekove i medicinske proizvode',
    updatedAt: DateTime(2026, 6, 18),
  );

  static List<OfficialDataSource> get all => [
        hzzoBasicList,
        hzzoSupplementaryList,
        eLijekovi,
        halmedPrices,
      ];
}
