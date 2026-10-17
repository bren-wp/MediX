import 'dart:io';
import 'package:archive/archive.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../core/app_info.dart';
import '../state/medix_state.dart';

class MedixExportService {
  static const _navigationChannel =
      MethodChannel('com.brendigo.medix/navigation');

  Future<Uint8List> buildZip(MedixState state) async {
    // Embedded, locally bundled Lato has Croatian č, ć, đ, š and ž glyphs.
    // No network font fetch is performed during an export.
    final font = pw.Font.ttf(
      await rootBundle.load('assets/fonts/Lato-Regular.ttf'),
    );
    final archive = Archive();
    final therapyPdf = await _therapyPdf(state, font);
    final favoritesPdf = await _favoritesPdf(state, font);
    final appPdf = await _appInfoPdf(font);

    archive.addFile(ArchiveFile.bytes('therapy-plan.pdf', therapyPdf));
    archive.addFile(ArchiveFile.bytes('favorites.pdf', favoritesPdf));
    archive.addFile(ArchiveFile.bytes('medix-app-info.pdf', appPdf));

    return ZipEncoder().encodeBytes(archive);
  }

  Future<String> createZipFile(MedixState state) async {
    final bytes = await buildZip(state);
    final cache = await getTemporaryDirectory();
    final directory = Directory('${cache.path}/medix-exports');
    await directory.create(recursive: true);
    await _removeOldExports(directory);
    final timestamp = DateTime.now().toUtc().microsecondsSinceEpoch;
    final file = File('${directory.path}/MediX-export-$timestamp.zip');
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }

  Future<void> _removeOldExports(Directory directory) async {
    final cutoff = DateTime.now().subtract(const Duration(hours: 24));
    await for (final entry in directory.list(followLinks: false)) {
      if (entry is! File ||
          !entry.uri.pathSegments.last.startsWith('MediX-export-') ||
          !entry.path.endsWith('.zip')) {
        continue;
      }
      try {
        final modified = await entry.lastModified();
        if (modified.isBefore(cutoff)) {
          await entry.delete();
        }
      } on FileSystemException {
        // A failed cache cleanup must never destroy an export request.
      }
    }
  }

  Future<bool> exportAndShare(MedixState state) async {
    final path = await createZipFile(state);
    return await _navigationChannel.invokeMethod<bool>(
          'shareFile',
          <String, String>{'path': path},
        ) ??
        false;
  }

  Future<Uint8List> _therapyPdf(MedixState state, pw.Font font) async {
    final document = pw.Document(
      title: 'MediX — Plan terapije',
      author: 'Brendigo',
      creator: 'MediX ${MedixAppInfo.displayVersion}',
    );

    document.addPage(
      pw.MultiPage(
        theme: pw.ThemeData.withFont(base: font, bold: font),
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        build: (_) => <pw.Widget>[
          _heading('MediX — Plan terapije'),
          _meta(),
          pw.SizedBox(height: 18),
          if (state.therapy.isEmpty)
            pw.Text('Na ovom uređaju nema spremljenih terapija.')
          else
            ...state.therapy.map((entry) {
              final medication = state.medicationById(entry.medicationId);
              return pw.Container(
                margin: const pw.EdgeInsets.only(bottom: 12),
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey400),
                  borderRadius: pw.BorderRadius.circular(6),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      medication?.name ?? entry.medicationId,
                      style: pw.TextStyle(
                        fontSize: 13,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text('Doza: ${entry.doseDescription}'),
                    pw.Text('Vrijeme uzimanja: ${entry.times.join(', ')}'),
                    pw.Text(
                      'Dani u tjednu: ${entry.weekdays.join(', ')}',
                    ),
                    pw.Text(
                      'Podsjetnik: ${entry.isActive ? 'uključen' : 'pauziran'}',
                    ),
                  ],
                ),
              );
            }),
          pw.SizedBox(height: 16),
          _disclaimer(),
        ],
      ),
    );

    return document.save();
  }

  Future<Uint8List> _favoritesPdf(MedixState state, pw.Font font) async {
    final document = pw.Document(
      title: 'MediX — Omiljeni lijekovi',
      author: 'Brendigo',
      creator: 'MediX ${MedixAppInfo.displayVersion}',
    );

    document.addPage(
      pw.MultiPage(
        theme: pw.ThemeData.withFont(base: font, bold: font),
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        build: (_) => <pw.Widget>[
          _heading('MediX — Omiljeni lijekovi'),
          _meta(),
          pw.SizedBox(height: 18),
          if (state.favorites.isEmpty)
            pw.Text('Na ovom uređaju nema spremljenih omiljenih lijekova.')
          else
            pw.TableHelper.fromTextArray(
              headers: const ['Lijek', 'Djelatna tvar', 'ATK'],
              data: state.favorites
                  .map(
                    (medication) => [
                      medication.name,
                      medication.activeIngredient,
                      medication.atcCode ?? '-',
                    ],
                  )
                  .toList(),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              cellStyle: const pw.TextStyle(fontSize: 9),
            ),
          pw.SizedBox(height: 16),
          _disclaimer(),
        ],
      ),
    );

    return document.save();
  }

  Future<Uint8List> _appInfoPdf(pw.Font font) async {
    final document = pw.Document(
      title: 'MediX — Podaci o aplikaciji',
      author: 'Brendigo',
      creator: 'MediX ${MedixAppInfo.displayVersion}',
    );

    document.addPage(
      pw.MultiPage(
        theme: pw.ThemeData.withFont(base: font, bold: font),
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        build: (_) => <pw.Widget>[
          _heading('MediX — Podaci o aplikaciji'),
          _meta(),
          pw.SizedBox(height: 18),
          pw.Text('Autor: Brendigo'),
          pw.Text('Paket: com.brendigo.medix'),
          pw.Text('Privatnost: ${MedixAppInfo.privacyPolicyUrl}'),
          pw.Text('Uvjeti korištenja: ${MedixAppInfo.termsOfUseUrl}'),
          pw.SizedBox(height: 16),
          pw.Text(
            'Ovaj se izvoz izrađuje lokalno na uređaju i sadrži samo odabrane MediX podatke. Aplikacija ih ne šalje na poslužitelj.',
          ),
          pw.SizedBox(height: 16),
          _disclaimer(),
        ],
      ),
    );

    return document.save();
  }

  pw.Widget _heading(String text) => pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 22,
          fontWeight: pw.FontWeight.bold,
        ),
      );

  pw.Widget _meta() => pw.Text(
        'MediX ${MedixAppInfo.displayVersion} · Brendigo · '
        '${DateTime.now().toUtc().toIso8601String()}',
        style: const pw.TextStyle(
          fontSize: 9,
          color: PdfColors.grey700,
        ),
      );

  pw.Widget _disclaimer() => pw.Container(
        padding: const pw.EdgeInsets.all(10),
        color: PdfColors.grey200,
        child: pw.Text(
          'MediX nije medicinski uređaj i ne postavlja dijagnoze, ne propisuje terapiju niti liječi bolesti. Za medicinske odluke obratite se liječniku ili ljekarniku.',
          style: const pw.TextStyle(fontSize: 9),
        ),
      );
}
