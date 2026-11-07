import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/quote.dart';

class PdfService {
  static Future<void> generateAndPrint(Quote quote) async {
    final pdf = pw.Document();

    final logoData = await rootBundle.load('assets/images/logo_completo.png');
    final logoImage = pw.MemoryImage(logoData.buffer.asUint8List());

    final formatCurrency = (double value) {
      final str = value.toStringAsFixed(0);
      return '\$ ${str.replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';
    };

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Image(logoImage, height: 50),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                      'COTIZACIÓN',
                      style: pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.black,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      quote.quoteNumber,
                      style: const pw.TextStyle(
                          fontSize: 14, color: PdfColors.grey700),
                    ),
                    pw.SizedBox(height: 2),
                    pw.Text(
                      'Fecha: ${quote.createdAt.day}/${quote.createdAt.month}/${quote.createdAt.year}',
                      style: const pw.TextStyle(
                          fontSize: 12, color: PdfColors.grey700),
                    ),
                  ],
                ),
              ],
            ),
            if (quote.title != null && quote.title!.isNotEmpty) ...[
              pw.SizedBox(height: 16),
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey100,
                  border: pw.Border.all(color: PdfColors.grey300, width: 0.5),
                ),
                child: pw.Text(
                  quote.title!,
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.black,
                  ),
                ),
              ),
            ],
            if (quote.description != null && quote.description!.isNotEmpty) ...[
              pw.SizedBox(height: 16),
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey50,
                  border: pw.Border.all(color: PdfColors.grey300, width: 0.5),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'DESCRIPCIÓN / NOTAS',
                      style: pw.TextStyle(
                        fontSize: 9,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.grey700,
                        letterSpacing: 1.2,
                      ),
                    ),
                    pw.SizedBox(height: 6),
                    pw.Text(
                      quote.description!,
                      style: const pw.TextStyle(fontSize: 10),
                    ),
                  ],
                ),
              ),
            ],
            pw.Divider(color: PdfColors.black, thickness: 1),
            pw.SizedBox(height: 20),
            pw.Text(
              'DATOS DEL CLIENTE',
              style: pw.TextStyle(
                fontSize: 10,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.grey700,
                letterSpacing: 1.2,
              ),
            ),
            pw.SizedBox(height: 8),
            pw.Text(
              quote.clientName,
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
            ),
            if (quote.clientTaxId != null)
              pw.Text(
                'NIT / CC: ${quote.clientTaxId}',
                style:
                    const pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
              ),
            pw.SizedBox(height: 32),
            pw.Text(
              'DETALLE DE PRODUCTOS Y SERVICIOS',
              style: pw.TextStyle(
                fontSize: 10,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.grey700,
                letterSpacing: 1.2,
              ),
            ),
            pw.SizedBox(height: 8),
            pw.TableHelper.fromTextArray(
              headers: [
                'Producto',
                'Proveedor',
                'Cant.',
                'V. Unitario',
                'Total'
              ],
              headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                fontSize: 10,
                color: PdfColors.white,
              ),
              headerDecoration: const pw.BoxDecoration(color: PdfColors.black),
              cellStyle: const pw.TextStyle(fontSize: 10),
              cellAlignments: {
                0: pw.Alignment.centerLeft,
                1: pw.Alignment.centerLeft,
                2: pw.Alignment.center,
                3: pw.Alignment.centerRight,
                4: pw.Alignment.centerRight,
              },
              border: null,
              oddRowDecoration:
                  const pw.BoxDecoration(color: PdfColors.grey100),
              data: quote.items.map((item) {
                return [
                  item.productName,
                  item.supplier ?? '-',
                  item.quantity.toStringAsFixed(0),
                  formatCurrency(item.unitPrice),
                  formatCurrency(item.total),
                ];
              }).toList(),
            ),
            pw.SizedBox(height: 20),
            pw.Container(
              alignment: pw.Alignment.centerRight,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text(
                    'TOTAL COTIZADO',
                    style: pw.TextStyle(
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.grey700,
                      letterSpacing: 1.2,
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    formatCurrency(quote.grandTotal),
                    style: pw.TextStyle(
                        fontSize: 24, fontWeight: pw.FontWeight.bold),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 40),
            pw.Divider(color: PdfColors.grey400, thickness: 0.5),
            pw.SizedBox(height: 8),
            pw.Text(
              'Orbital Engineering Solutions SAS',
              style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
            ),
            pw.Text(
              'orbitalsolutions2@gmail.com',
              style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
            ),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }
}
