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
    final archive = Archive();
    final therapyPdf = await _therapyPdf(state);
    final favoritesPdf = await _favoritesPdf(state);
    final appPdf = await _appInfoPdf();

    archive.addFile(ArchiveFile.bytes('therapy-plan.pdf', therapyPdf));
    archive.addFile(ArchiveFile.bytes('favorites.pdf', favoritesPdf));
    archive.addFile(ArchiveFile.bytes('medix-app-info.pdf', appPdf));

    return ZipEncoder().encodeBytes(archive);
  }

  Future<String> createZipFile(MedixState state) async {
    final bytes = await buildZip(state);
    final directory = await getTemporaryDirectory();
    final timestamp = DateTime.now().toUtc().toIso8601String()
        .replaceAll(':', '-')
        .replaceAll('.', '-');
    final file = File(
      '${directory.path}/MediX-export-$timestamp.zip',
    );
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }

  Future<bool> exportAndShare(MedixState state) async {
    final path = await createZipFile(state);
    return await _navigationChannel.invokeMethod<bool>(
          'shareFile',
          <String, String>{
            'path': path,
            'mimeType': 'application/zip',
            'title': 'MediX data export',
          },
        ) ??
        false;
  }

  Future<Uint8List> _therapyPdf(MedixState state) async {
    final document = pw.Document(
      title: 'MediX Therapy Plan',
      author: 'Brendigo',
      creator: 'MediX ${MedixAppInfo.displayVersion}',
    );

    document.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        build: (_) => <pw.Widget>[
          _heading('MediX Therapy Plan'),
          _meta(),
          pw.SizedBox(height: 18),
          if (state.therapy.isEmpty)
            pw.Text('No therapy entries are saved on this device.')
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
                    pw.Text('Dose: ${entry.doseDescription}'),
                    pw.Text('Times: ${entry.times.join(', ')}'),
                    pw.Text(
                      'Weekdays: ${entry.weekdays.join(', ')}',
                    ),
                    pw.Text(
                      'Reminder status: ${entry.isActive ? 'active' : 'paused'}',
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

  Future<Uint8List> _favoritesPdf(MedixState state) async {
    final document = pw.Document(
      title: 'MediX Favorites',
      author: 'Brendigo',
      creator: 'MediX ${MedixAppInfo.displayVersion}',
    );

    document.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        build: (_) => <pw.Widget>[
          _heading('MediX Favorites'),
          _meta(),
          pw.SizedBox(height: 18),
          if (state.favorites.isEmpty)
            pw.Text('No favorite medicines are saved on this device.')
          else
            pw.TableHelper.fromTextArray(
              headers: const ['Medicine', 'Active ingredient', 'ATC'],
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

  Future<Uint8List> _appInfoPdf() async {
    final document = pw.Document(
      title: 'MediX App Information',
      author: 'Brendigo',
      creator: 'MediX ${MedixAppInfo.displayVersion}',
    );

    document.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        build: (_) => <pw.Widget>[
          _heading('MediX App Information'),
          _meta(),
          pw.SizedBox(height: 18),
          pw.Text('Author: Brendigo'),
          pw.Text('Package: com.brendigo.medix'),
          pw.Text('Privacy: https://brendigo.com/politika-privatnosti/'),
          pw.Text('Terms: https://brendigo.com/uvjeti-koristenja/'),
          pw.SizedBox(height: 16),
          pw.Text(
            'This export is generated locally on the device. It contains only the MediX data selected by the export feature and is not uploaded by MediX.',
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
          'MediX is not a medical device and does not diagnose, treat, cure or prevent any medical condition. Consult a qualified healthcare professional for medical advice, diagnosis or treatment.',
          style: const pw.TextStyle(fontSize: 9),
        ),
      );
}
