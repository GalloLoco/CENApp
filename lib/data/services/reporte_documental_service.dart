import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';
import 'graficas_service.dart';
import 'dart:async';
import 'dart:math' as math;
import '../services/file_storage_service.dart';

FileStorageService fileStorageService = FileStorageService();

class ReporteDocumentalService {
  static const double ancho = 500;
  static const double alto = 300;

  /// Genera un reporte en formato PDF
  static Future<String> generarReportePDF({
    required String titulo,
    required String subtitulo,
    required Map<String, dynamic> datos,
    required List<Map<String, dynamic>> tablas,
    required List<Uint8List> graficas,
    required Map<String, dynamic> metadatos,
  }) async {
    final stopwatch = Stopwatch()..start();
    final pdf = pw.Document(
      creator: 'CENApp',
      author: metadatos['autor'] ?? 'Sistema CENApp',
      title: titulo,
      subject: subtitulo,
    );

    // Cargar fuente personalizada para soporte completo de caracteres en español
    final font = await rootBundle.load("assets/openSans.ttf");
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

          // Agregar gráficas recibidas como parámetro
          if (graficas.isNotEmpty) {
            for (var i = 0; i < graficas.length; i++) {
              widgets.add(
                pw.Header(
                  level: 2,
                  text: i == 0
                      ? 'Distribución de Uso de Vivienda'
                      : 'Distribución de Tipos de Topografía',
                  textStyle: pw.TextStyle(
                      font: ttf, fontSize: 13, fontWeight: pw.FontWeight.bold),
                ),
              );

              // Añadir espacio para el gráfico (será implementado por GraficasService)
              if (datos.containsKey('usosVivienda') && i == 0) {
                Map<String, int> datosUsos = {};

                datos['usosVivienda']['estadisticas'].forEach((uso, stats) {
                  if (stats['conteo'] > 0) {
                    datosUsos[uso] = stats['conteo'];
                  }
                });

                if (datosUsos.isNotEmpty) {
                  widgets.add(
                    GraficasService.crearGraficoCircularPDF(
                      datos: datosUsos,
                      titulo: 'Distribución de Uso de Vivienda',
                      ancho: ancho - 40, // Ajustar ancho según margen
                      alto: 300,
                    ),
                  );
                }
              } else if (datos.containsKey('topografia') && i == 1) {
                Map<String, int> datosTopografia = {};

                datos['topografia']['estadisticas'].forEach((tipo, stats) {
                  if (stats['conteo'] > 0) {
                    datosTopografia[tipo] = stats['conteo'];
                  }
                });

                if (datosTopografia.isNotEmpty) {
                  widgets.add(
                    GraficasService.crearGraficoBarrasPDF(
                      datos: datosTopografia,
                      titulo: 'Distribución de Tipos de Topografía',
                      ancho: ancho - 40, // Ajustar ancho según margen
                      alto: 300,
                    ),
                  );
                }
              }

              widgets.add(pw.SizedBox(height: 20));
            }
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
    // 4. Preparar directorio para guardar
    try {
      print("📄 [PDF] Preparando directorio para guardar");
      final directory = await fileStorageService.obtenerDirectorioDescargas();
      final outputDir = Directory('${directory.path}/cenapp/reportes');
      if (!await outputDir.exists()) {
        await outputDir.create(recursive: true);
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final String filePath =
          '${outputDir.path}/reporte_uso_vivienda_$timestamp.pdf';
      print("📄 [PDF] Ruta de destino: $filePath");

      // 5. Convertir PDF a bytes en un isolate separado para no bloquear la UI
      print("📄 [PDF] Exportando PDF a bytes...");
      final Uint8List pdfBytes = await compute(_exportarPDFaBytes, pdf);
      print("📄 [PDF] PDF exportado a bytes: ${pdfBytes.length} bytes");

      // 6. NUEVO: Escribir archivo con manejo explícito de recursos
      print("📄 [PDF] Escribiendo archivo en disco con flush explícito...");

      // Usar RandomAccessFile para control explícito
      RandomAccessFile? fileHandle;
      try {
        final file = File(filePath);

        // Abrir con modo write y truncar el archivo si existe
        fileHandle = await file.open(mode: FileMode.write);

        // Escribir bytes
        await fileHandle.writeFrom(pdfBytes);

        // CRÍTICO: Forzar vaciado de caché y sincronización con almacenamiento físico
        await fileHandle.flush();
        await fileHandle
            .setPosition(0); // Volver al inicio del archivo para verificación

        // Verificar que lo que se escribió corresponde al tamaño esperado
        final fileLength = await fileHandle.length();
        print("📄 [PDF] Longitud verificada del archivo: $fileLength bytes");

        if (fileLength != pdfBytes.length) {
          throw Exception(
              "Discrepancia de tamaño: esperado ${pdfBytes.length}, obtenido $fileLength");
        }

        // Forzar sincronización con sistema de archivos
        await fileHandle.flush();
      } catch (e) {
        print("❌ [PDF] Error al escribir archivo: $e");
        rethrow;
      } finally {
        // CRÍTICO: Cerrar el manejador de archivo en cualquier caso
        if (fileHandle != null) {
          try {
            await fileHandle.close();
            print("📄 [PDF] Manejador de archivo cerrado correctamente");
          } catch (closeError) {
            print("⚠️ [PDF] Error al cerrar manejador: $closeError");
          }
        }
      }

      // 7. IMPORTANTE: Verificación adicional con el sistema operativo
      print("📄 [PDF] Realizando verificación adicional...");

      // Pequeña pausa para permitir que el SO termine cualquier operación pendiente
      await Future.delayed(Duration(milliseconds: 200));

      // Verificar nuevamente desde el sistema de archivos
      bool archivoVerificado =
          await _verificarArchivoEnSistema(filePath, pdfBytes.length);

      if (!archivoVerificado) {
        throw Exception(
            "Verificación final fallida: el archivo no puede ser confirmado por el sistema");
      }

      print(
          "✅ [PDF] Archivo creado, verificado y sincronizado correctamente en ${stopwatch.elapsedMilliseconds}ms");
      return filePath;
    } catch (e) {
      print("❌ [PDF] ERROR en generación de PDF: $e");
      rethrow;
    }
  }

  /// Verificación rigurosa con el sistema de archivos
  static Future<bool> _verificarArchivoEnSistema(
      String filePath, int tamanoEsperado) async {
    try {
      // 1. Verificar existencia con acceso al sistema de archivos
      final file = File(filePath);
      if (!await file.exists()) {
        print("❌ [PDF] El archivo no existe en la verificación final");
        return false;
      }

      // 2. Verificar tamaño
      final tamanoReal = await file.length();
      if (tamanoReal != tamanoEsperado) {
        print(
            "❌ [PDF] Discrepancia de tamaño en verificación final: esperado $tamanoEsperado, obtenido $tamanoReal");
        return false;
      }

      // 3. CRÍTICO: Intentar abrir y leer una porción para confirmar que es accesible
      try {
        final randomAccessFile = await file.open(mode: FileMode.read);
        try {
          final Uint8List bytes = Uint8List(math.min(1024, tamanoEsperado));
          
          await randomAccessFile.readInto(bytes);

          // Verificar que son datos válidos de PDF
          if (bytes.length >= 4) {
            // Los archivos PDF comienzan con %PDF
            if (bytes[0] == 0x25 && // %
                bytes[1] == 0x50 && // P
                bytes[2] == 0x44 && // D
                bytes[3] == 0x46) {
              // F
              print("✅ [PDF] Verificación de firma PDF correcta");
            } else {
              print("⚠️ [PDF] Advertencia: Firma PDF no detectada");
            }
          }
        } finally {
          // CRÍTICO: Cerrar el archivo de lectura
          await randomAccessFile.close();
        }
      } catch (e) {
        print("❌ [PDF] Error en prueba de lectura: $e");
        return false;
      }

      print(
          "✅ [PDF] Archivo completamente verificado en sistema de archivos: $filePath");
      return true;
    } catch (e) {
      print("❌ [PDF] Error en verificación rigurosa: $e");
      return false;
    }
  }

  /// Función para exportar PDF a bytes en un isolate separado
  static Future<Uint8List> _exportarPDFaBytes(pw.Document pdf) async {
    // Esta función se ejecutará en un isolate separado
    try {
      return await pdf.save();
    } catch (e) {
      print("❌ [PDF-Isolate] Error al exportar PDF: $e");
      rethrow;
    }
  }

  /// Genera un reporte en formato DOCX (Word)
  /// Nota: Esta función es un placeholder. Para una implementación real,
  /// se necesitaría una biblioteca para generar documentos DOCX como docx.
  ///
  ///
  /*static Future<String> generarReporteDOCX({
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
  }*/
}
