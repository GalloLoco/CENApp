import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'graficas_service.dart';

class ReporteDocumentalService {
  /// Genera un reporte en formato PDF
  static Future<String> generarReportePDF({
    required String titulo,
    required String subtitulo,
    required Map<String, dynamic> datos,
    required List<Map<String, dynamic>> tablas,
    required List<Uint8List> graficas,
    required Map<String, dynamic> metadatos,
  }) async {
    final pdf = pw.Document(
      creator: 'CENApp',
      author: metadatos['autor'] ?? 'Sistema CENApp',
      title: titulo,
      subject: subtitulo,
    );

    // Cargar fuente personalizada para soporte completo de caracteres en español
    final font = await rootBundle.load("assets/fonts/OpenSans-Regular.ttf");
    final ttf = pw.Font.ttf(font);

    // Definir estilos
    final estiloTitulo = pw.TextStyle(
      font: ttf,
      fontSize: 18,
      fontWeight: pw.FontWeight.bold,
    );

    final estiloSubtitulo = pw.TextStyle(
      font: ttf,
      fontSize: 14,
      fontWeight: pw.FontWeight.bold,
      color: PdfColors.blueAccent,
    );

    final estiloNormal = pw.TextStyle(
      font: ttf,
      fontSize: 11,
    );

    final estiloEncabezadoTabla = pw.TextStyle(
      font: ttf,
      fontSize: 10,
      fontWeight: pw.FontWeight.bold,
      color: PdfColors.white,
    );

    final estiloFilaTabla = pw.TextStyle(
      font: ttf,
      fontSize: 9,
    );

    // Definir fecha de generación
    final fechaGeneracion =
        DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now());

    // Función de encabezado de página
    pw.Widget Function(pw.Context) encabezado = (context) {
      return pw.Container(
        alignment: pw.Alignment.center,
        margin: const pw.EdgeInsets.only(bottom: 10),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            pw.Text(titulo, style: estiloTitulo),
            pw.SizedBox(height: 5),
            pw.Text(subtitulo, style: estiloSubtitulo),
            pw.SizedBox(height: 3),
            pw.Text('Generado el $fechaGeneracion', style: estiloNormal),
            pw.Divider(thickness: 1),
          ],
        ),
      );
    };

    // Función de pie de página
    pw.Widget Function(pw.Context) piePagina = (context) {
      return pw.Container(
        alignment: pw.Alignment.centerRight,
        margin: const pw.EdgeInsets.only(top: 10),
        child: pw.Text(
          'Página ${context.pageNumber} de ${context.pagesCount}',
          style: pw.TextStyle(font: ttf, fontSize: 9, color: PdfColors.grey),
        ),
      );
    };

    // Construir páginas del PDF
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.all(20),
        header: encabezado,
        footer: piePagina,
        build: (context) {
          final List<pw.Widget> widgets = [];

          // Contenido principal
          widgets.add(pw.Header(
            level: 1,
            text: 'Resumen de Análisis',
            textStyle: estiloSubtitulo,
          ));

          // Información de filtros aplicados
          widgets.add(pw.Paragraph(
            text: 'Filtros aplicados:',
            style: pw.TextStyle(
                font: ttf, fontSize: 11, fontWeight: pw.FontWeight.bold),
          ));

          // Tabla de filtros
          final List<List<String>> filasFiltros = [];

          if (metadatos.containsKey('nombreInmueble') &&
              metadatos['nombreInmueble'] != null &&
              metadatos['nombreInmueble'].isNotEmpty) {
            filasFiltros
                .add(['Nombre del inmueble:', metadatos['nombreInmueble']]);
          }

          if (metadatos.containsKey('fechaInicio') &&
              metadatos['fechaInicio'] != null) {
            filasFiltros.add(['Fecha inicio:', metadatos['fechaInicio']]);
          }

          if (metadatos.containsKey('fechaFin') &&
              metadatos['fechaFin'] != null) {
            filasFiltros.add(['Fecha fin:', metadatos['fechaFin']]);
          }

          if (metadatos.containsKey('usuarioCreador') &&
              metadatos['usuarioCreador'] != null &&
              metadatos['usuarioCreador'].isNotEmpty) {
            filasFiltros.add(['Usuario creador:', metadatos['usuarioCreador']]);
          }

          if (metadatos.containsKey('ubicaciones') &&
              metadatos['ubicaciones'] != null &&
              metadatos['ubicaciones'].isNotEmpty) {
            final List<Map<String, dynamic>> ubicaciones =
                metadatos['ubicaciones'];
            for (int i = 0; i < ubicaciones.length; i++) {
              final ubi = ubicaciones[i];
              String ubicacionStr = '${ubi['municipio']}, ${ubi['ciudad']}';
              if (ubi['colonia'] != null) {
                ubicacionStr += ', ${ubi['colonia']}';
              }
              filasFiltros.add(['Ubicación ${i + 1}:', ubicacionStr]);
            }
          }

          if (filasFiltros.isNotEmpty) {
            widgets.add(
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300),
                children: filasFiltros.map((fila) {
                  return pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: pw.EdgeInsets.all(4),
                        child: pw.Text(fila[0],
                            style: pw.TextStyle(
                                font: ttf,
                                fontSize: 10,
                                fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(4),
                        child: pw.Text(fila[1],
                            style: pw.TextStyle(font: ttf, fontSize: 10)),
                      ),
                    ],
                  );
                }).toList(),
              ),
            );
          }

          widgets.add(pw.SizedBox(height: 15));

          // Resumen general
          widgets.add(pw.Paragraph(
            text:
                'El análisis se realizó sobre ${metadatos['totalFormatos']} formato(s) que cumplieron con los criterios de búsqueda.',
            style: estiloNormal,
          ));

          widgets.add(pw.SizedBox(height: 15));

          // Agregar tablas de estadísticas
          for (var tabla in tablas) {
            widgets.add(
              pw.Header(
                level: 2,
                text: tabla['titulo'],
                textStyle: pw.TextStyle(
                    font: ttf, fontSize: 13, fontWeight: pw.FontWeight.bold),
              ),
            );

            if (tabla['descripcion'] != null) {
              widgets.add(
                pw.Paragraph(
                  text: tabla['descripcion'],
                  style: estiloNormal,
                ),
              );
            }

            // Crear la tabla con encabezados
            final List<String> encabezados = tabla['encabezados'];
            final List<List<dynamic>> filas = tabla['filas'];

            widgets.add(
              pw.Table(
                border: pw.TableBorder.all(),
                tableWidth: pw.TableWidth.max,
                columnWidths: {
                  0: pw.FlexColumnWidth(2),
                  for (int i = 1; i < encabezados.length; i++)
                    i: pw.FlexColumnWidth(1),
                },
                children: [
                  // Encabezados
                  pw.TableRow(
                    decoration: pw.BoxDecoration(
                      color: PdfColors.blueAccent,
                    ),
                    children: encabezados
                        .map((e) => pw.Padding(
                              padding: pw.EdgeInsets.all(4),
                              child: pw.Text(e,
                                  style: estiloEncabezadoTabla,
                                  textAlign: pw.TextAlign.center),
                            ))
                        .toList(),
                  ),
                  // Filas de datos
                  ...filas
                      .map((fila) => pw.TableRow(
                            children: fila
                                .map((celda) => pw.Padding(
                                      padding: pw.EdgeInsets.all(4),
                                      child: pw.Text(celda.toString(),
                                          style: estiloFilaTabla,
                                          textAlign: celda is num
                                              ? pw.TextAlign.right
                                              : pw.TextAlign.left),
                                    ))
                                .toList(),
                          ))
                      .toList(),
                ],
              ),
            );

            widgets.add(pw.SizedBox(height: 10));
          }

          // Agregar gráficas
          // Agregar gráficas
          if (datosEstadisticos.containsKey('usosVivienda') &&
              datosEstadisticos['usosVivienda'].isNotEmpty) {
            Map<String, int> datosUsos = {};
            datosEstadisticos['usosVivienda']['frecuencias']
                .forEach((uso, conteo) {
              datosUsos[uso] = conteo;
            });

            widgets.add(
              GraficasService.crearGraficoCircularPDF(
                datos: datosUsos,
                titulo: 'Distribución de Uso de Vivienda',
                ancho: 500,
                alto: 300,
              ),
            );
          }

          if (datosEstadisticos.containsKey('topografia') &&
              datosEstadisticos['topografia'].isNotEmpty) {
            Map<String, int> datosTopografia = {};
            datosEstadisticos['topografia']['frecuencias']
                .forEach((tipo, conteo) {
              datosTopografia[tipo] = conteo;
            });

            widgets.add(
              GraficasService.crearGraficoBarrasPDF(
                datos: datosTopografia,
                titulo: 'Distribución de Tipos de Topografía',
                ancho: 500,
                alto: 300,
              ),
            );
          }

          // Conclusiones
          if (metadatos.containsKey('conclusiones') &&
              metadatos['conclusiones'] != null) {
            widgets.add(
              pw.Header(
                level: 1,
                text: 'Conclusiones',
                textStyle: estiloSubtitulo,
              ),
            );

            widgets.add(
              pw.Paragraph(
                text: metadatos['conclusiones'],
                style: estiloNormal,
              ),
            );
          }

          return widgets;
        },
      ),
    );

    // Guardar el archivo PDF
    final directory = await getApplicationDocumentsDirectory();
    final outputDir = Directory('${directory.path}/cenapp/reportes');
    if (!await outputDir.exists()) {
      await outputDir.create(recursive: true);
    }

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final String filePath =
        '${outputDir.path}/reporte_uso_vivienda_$timestamp.pdf';

    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());

    return filePath;
  }

  /// Genera un reporte en formato DOCX (Word)
  /// Nota: Esta función es un placeholder. Para una implementación real,
  /// se necesitaría una biblioteca para generar documentos DOCX como docx.
  static Future<String> generarReporteDOCX({
    required String titulo,
    required String subtitulo,
    required Map<String, dynamic> datos,
    required List<Map<String, dynamic>> tablas,
    required List<Uint8List> graficas,
    required Map<String, dynamic> metadatos,
  }) async {
    // En una implementación real, aquí usaríamos una biblioteca como docx
    // Por ahora, solo retornamos un mensaje indicando que no está implementado

    // Placeholder: crear un archivo de texto con un mensaje
    final directory = await getApplicationDocumentsDirectory();
    final outputDir = Directory('${directory.path}/cenapp/reportes');
    if (!await outputDir.exists()) {
      await outputDir.create(recursive: true);
    }

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final String filePath =
        '${outputDir.path}/reporte_uso_vivienda_$timestamp.txt';

    final file = File(filePath);
    await file.writeAsString('Reporte DOCX pendiente de implementación');

    return filePath;
  }
}
