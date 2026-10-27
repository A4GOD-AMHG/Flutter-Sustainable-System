import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' show Rect;

import 'package:flutter/services.dart' show rootBundle;
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

/// Guarda [bytes] como [fileName] y lo abre con la app del sistema.
///
/// Devuelve `false` si no se pudo abrir (p. ej. no hay visor de PDF).
Future<bool> saveAndLaunchFile(List<int> bytes, String fileName) async {
  // getExternalStorageDirectory solo existe en Android; en el resto se usa documentos.
  final dir = (Platform.isAndroid ? await getExternalStorageDirectory() : null) ??
      await getApplicationDocumentsDirectory();
  final file = File('${dir.path}/$fileName');
  await file.writeAsBytes(bytes, flush: true);
  final result = await OpenFilex.open(file.path);
  return result.type == ResultType.done;
}

Future<Uint8List> readImageData(String name) async {
  final data = await rootBundle.load('assets/images/$name');
  return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
}

/// Escribe bloques de texto uno tras otro, saltando de página cuando no caben.
class _PdfCursor {
  _PdfCursor(this.document) : page = document.pages.add();

  final PdfDocument document;
  PdfPage page;
  double top = 30;

  Rect _bounds(double y) => Rect.fromLTWH(
      0, y, page.getClientSize().width, page.getClientSize().height);

  void newPage() {
    page = document.pages.add();
    top = 30;
  }

  void write(PdfTextElement element, {bool breakPage = true}) {
    final result = element.draw(page: page, bounds: _bounds(top))!;
    page = result.page;
    if (breakPage && page.getClientSize().height - 30 <= result.bounds.bottom) {
      newPage();
    } else {
      top = result.bounds.bottom + 30;
    }
  }
}

/// Genera el informe PDF de sostenibilidad de una evaluación.
Future<List<int>> buildSustainabilityReport({
  required List<String> metricsNames,
  required List<Map<String, Map<int, List>>> metrics,
  required List<int> values,
  required int total,
  required String clasification,
}) async {
  final document = PdfDocument();
  final cursor = _PdfCursor(document);

  cursor.page.graphics.drawImage(
    PdfBitmap(await readImageData('icon.png')),
    const Rect.fromLTWH(230, 30, 100, 100),
  );
  cursor.page.graphics.drawString('Sostenibilidad del Software',
      PdfStandardFont(PdfFontFamily.timesRoman, 85),
      bounds: Rect.fromLTWH(0, 250, cursor.page.getClientSize().width,
          cursor.page.getClientSize().height),
      format: PdfStringFormat(alignment: PdfTextAlignment.center));

  cursor.newPage();
  final result = StringBuffer();

  for (int i = 0; i < metrics.length; i++) {
    final factors = metrics[i].entries.toList();
    result.write(
        "${i == 0 ? '' : '. '}Al analizar la métrica ${metricsNames[i].toLowerCase()}");

    cursor.write(PdfTextElement(
        text: '${metricsNames[i]} (${values[i]} puntos)',
        font: PdfStandardFont(PdfFontFamily.timesRoman, 18,
            style: PdfFontStyle.bold),
        format: PdfStringFormat(alignment: PdfTextAlignment.justify)));

    for (int j = 0; j < factors.length; j++) {
      final options = factors[j].value.entries.toList();
      final selectedOption = options.firstWhere((element) => element.value[1]);
      result.write("; en cuanto a, ${factors[j].key.toLowerCase()};");

      cursor.write(PdfTextElement(
        text: '· ${factors[j].key} (${selectedOption.key} puntos)',
        font: PdfStandardFont(PdfFontFamily.timesRoman, 14,
            style: PdfFontStyle.italic),
        format: PdfStringFormat(
            alignment: PdfTextAlignment.justify, paragraphIndent: 8),
      ));

      for (final option in options) {
        final isLast = i == metrics.length - 1 && j == factors.length - 1;
        if (option.value[1]) {
          result.write(
              " ${option.value[0].toLowerCase()}(${option.key} puntos)${isLast ? '.' : ''}");
        }
        cursor.write(PdfTextElement(
          font: PdfStandardFont(
            PdfFontFamily.timesRoman,
            12,
            style: option.value[1] ? PdfFontStyle.underline : null,
          ),
          format: PdfStringFormat(
              alignment: PdfTextAlignment.justify, paragraphIndent: 16),
          text: '- ${option.value[0]}: ${option.key}',
        ));
      }
    }
  }

  cursor.newPage();
  final bodyFont = PdfStandardFont(PdfFontFamily.timesRoman, 12);
  final justify = PdfStringFormat(alignment: PdfTextAlignment.justify);
  cursor.write(
      PdfTextElement(
          font: PdfStandardFont(PdfFontFamily.timesRoman, 14),
          format: justify,
          text: 'Por lo Tanto:'),
      breakPage: false);
  cursor.write(
      PdfTextElement(font: bodyFont, format: justify, text: result.toString()),
      breakPage: false);
  cursor.write(
      PdfTextElement(
          font: bodyFont,
          format: justify,
          text:
              'Con un total de $total puntos se concluye que este software es $clasification.'),
      breakPage: false);

  final bytes = await document.save();
  document.dispose();
  return bytes;
}
