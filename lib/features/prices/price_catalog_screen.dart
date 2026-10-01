import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/medix_theme.dart';
import '../../widgets/medix_page.dart';

class PriceCatalogScreen extends StatefulWidget {
  const PriceCatalogScreen({super.key});

  @override
  State<PriceCatalogScreen> createState() => _PriceCatalogScreenState();
}

class _PriceCatalogScreenState extends State<PriceCatalogScreen> {
  final controller = TextEditingController();
  late final Future<_PriceCatalog> catalog = _loadCatalog();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<_PriceCatalog> _loadCatalog() async {
    final raw = await rootBundle.loadString(
      'assets/data/halmed_prices_2026.json',
    );
    final decoded = jsonDecode(raw);
    if (decoded is! Map) {
      throw const FormatException('Neispravan HALMED cjenik.');
    }
    final map = Map<String, dynamic>.from(decoded);
    final source = map['source'] is Map
        ? Map<String, dynamic>.from(map['source'] as Map)
        : <String, dynamic>{};
    final rawRecords = map['records'];
    final records = <_PriceRecord>[];

    if (rawRecords is List) {
      for (final item in rawRecords) {
        if (item is! Map) continue;
        final row = Map<String, dynamic>.from(item);
        final name = row['name']?.toString().trim() ?? '';
        final package = row['name_and_package']?.toString().trim() ?? '';
        if (name.isEmpty || package.isEmpty) continue;

        records.add(
          _PriceRecord(
            name: name,
            package: package,
            ingredient: row['active_ingredient']?.toString().trim() ?? '',
            atc: row['atc_code']?.toString().trim() ?? '',
            authorizationNumber:
                row['authorization_number']?.toString().trim() ?? '',
            holder: row['holder']?.toString().trim() ?? '',
            price: _number(row['max_wholesale_eur']),
            note: row['note']?.toString().trim() ?? '',
          ),
        );
      }
    }

    return _PriceCatalog(
      records: records,
      sourceName:
          source['name']?.toString() ?? 'HALMED / Narodne novine',
      publishedDate:
          source['published_date']?.toString() ?? '2026-06-18',
    );
  }

  static double? _number(Object? value) {
    if (value is num) return value.toDouble();
    return double.tryParse(
      value?.toString().replaceAll(',', '.').trim() ?? '',
    );
  }

  @override
  Widget build(BuildContext context) {
    return MedixPage(
      appBar: AppBar(title: const Text('Cijene i pakiranja')),
      safeArea: false,
      child: FutureBuilder<_PriceCatalog>(
        future: catalog,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Službeni HALMED cjenik trenutno nije učitan.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: MedixColors.textSecondary),
                ),
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!;
          final query = controller.text.trim().toLowerCase();
          final filtered = query.isEmpty
              ? data.records
              : data.records.where((row) {
                  final haystack = [
                    row.name,
                    row.package,
                    row.ingredient,
                    row.atc,
                    row.authorizationNumber,
                    row.holder,
                  ].join(' ').toLowerCase();
                  return haystack.contains(query);
                }).toList();

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
            children: [
              TextField(
                controller: controller,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  hintText: 'Naziv, djelatna tvar, ATK, broj odobrenja...',
                  prefixIcon: Icon(Icons.search_rounded),
                ),
              ),
              const SizedBox(height: 10),
              MedixSectionCard(
                accent: MedixColors.success,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const MedixIconBubble(
                      icon: Icons.euro_rounded,
                      color: MedixColors.success,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Ažurirano: ${data.publishedDate}\n'
                        'Prikazane vrijednosti odnose se na evidentirane cijene pakiranja i nisu nužno maloprodajne cijene ljekarni.',
                        style: const TextStyle(
                          color: MedixColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '${filtered.length} zapisa',
                style: const TextStyle(
                  color: MedixColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              ...filtered.take(300).map(
                    (row) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _PriceCard(row: row),
                    ),
                  ),
              if (filtered.length > 300)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Za brži prikaz prikazano je prvih 300 rezultata. Suzi pretragu za precizniji rezultat.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: MedixColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _PriceCard extends StatelessWidget {
  const _PriceCard({required this.row});

  final _PriceRecord row;

  @override
  Widget build(BuildContext context) {
    return MedixSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const MedixIconBubble(
                icon: Icons.medication_outlined,
                color: MedixColors.cyan,
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      row.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      row.ingredient,
                      style: const TextStyle(
                        color: MedixColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                row.price == null
                    ? '—'
                    : '${row.price!.toStringAsFixed(2).replaceAll('.', ',')} €',
                style: const TextStyle(
                  color: MedixColors.success,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            row.package,
            style: const TextStyle(
              color: MedixColors.textSecondary,
              fontSize: 11,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 7,
            runSpacing: 5,
            children: [
              if (row.atc.isNotEmpty)
                _MetaChip('ATK ${row.atc}'),
              if (row.authorizationNumber.isNotEmpty)
                _MetaChip(row.authorizationNumber),
              if (row.holder.isNotEmpty)
                _MetaChip(row.holder),
            ],
          ),
          if (row.note.isNotEmpty) ...[
            const SizedBox(height: 7),
            Text(
              row.note,
              style: const TextStyle(
                color: MedixColors.warning,
                fontSize: 10,
                height: 1.3,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 240),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: MedixColors.surfaceElevated,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: MedixColors.textSecondary,
          fontSize: 9,
        ),
      ),
    );
  }
}

class _PriceCatalog {
  const _PriceCatalog({
    required this.records,
    required this.sourceName,
    required this.publishedDate,
  });

  final List<_PriceRecord> records;
  final String sourceName;
  final String publishedDate;
}

class _PriceRecord {
  const _PriceRecord({
    required this.name,
    required this.package,
    required this.ingredient,
    required this.atc,
    required this.authorizationNumber,
    required this.holder,
    required this.price,
    required this.note,
  });

  final String name;
  final String package;
  final String ingredient;
  final String atc;
  final String authorizationNumber;
  final String holder;
  final double? price;
  final String note;
}
