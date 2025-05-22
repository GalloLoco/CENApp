import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
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
          if (graficas.isNotEmpty || datos.isNotEmpty) {
              // Usar el nuevo método para determinar qué gráficos generar según el tipo de reporte
              List<pw.Widget> graficosEspecificos = _generarGraficosParaReporte(datos, graficas, metadatos);
  
              // Agregar los gráficos generados al documento PDF
              widgets.addAll(graficosEspecificos);
  

              //widgets.add(pw.SizedBox(height: 5));
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
List<pw.Widget> _generarGraficosParaReporte(
    Map<String, dynamic> datos, 
    List<Uint8List> graficas,
    Map<String, dynamic> metadatos) {
  
  List<pw.Widget> widgets = [];
  
  // Determinar qué tipo de reporte es basándose en el título o subtítulo
  String? titulo = metadatos['titulo'] as String?;
  
  if (titulo?.contains('Resumen General') == true) {
    // Es un reporte de resumen general, generar gráficos específicos
    widgets.addAll(_generarGraficosResumenGeneral(datos, graficas));
  } else if (titulo?.contains('Uso de Vivienda') == true || titulo?.contains('Topografía') == true) {
    // Es un reporte de uso de vivienda y topografía
    widgets.addAll(_generarGraficosUsoViviendaTopografia(datos, graficas));
  }else if (titulo?.contains('Sistema Estructural') == true) {
    // Es un reporte de sistema estructural
  widgets.addAll(_generarGraficosSistemaEstructural(datos, graficas));

  } else if (titulo?.contains('Material Dominante') == true) {
  // Es un reporte de material dominante
  widgets.addAll(_generarGraficosMaterialDominante(datos, graficas));
}else if (titulo?.contains('Evaluación de Daños') == true) {
    //  Es un reporte de evaluación de daños
    widgets.addAll(_generarGraficosEvaluacionDanos(datos, graficas));
  }else if (titulo?.contains('Reporte Completo') == true || titulo?.contains('Análisis Integral') == true) {
  // Es un reporte completo, generar todos los gráficos de todas las secciones
  widgets.addAll(_generarGraficosReporteCompleto(datos, graficas));
}
  else {
    // Reporte genérico, usar gráficos genéricos
    widgets.addAll(_generarGraficosGenericos(datos, graficas));
  }
  
  return widgets;
}

List<pw.Widget> _generarGraficosReporteCompleto(
    Map<String, dynamic> datos, 
    List<Uint8List> graficas) {
  
  List<pw.Widget> widgets = [];
  
  // === SECCIÓN 1: RESUMEN GENERAL ===
  widgets.add(_crearSeparadorSeccion('DISTRIBUCIÓN GEOGRÁFICA Y TEMPORAL'));
  
  if (datos['resumenGeneral']?['distribucionGeografica']?['ciudades']?.isNotEmpty == true) {
    widgets.add(
      pw.Header(
        level: 2,
        text: 'Distribución de Evaluaciones por Ciudad',
        textStyle: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold),
      ),
    );
    
    widgets.add(
      GraficasService.crearGraficoBarrasHorizontalesPDF(
        datos: Map<String, int>.from(datos['resumenGeneral']['distribucionGeografica']['ciudades']),
        titulo: 'Cantidad de Inmuebles Evaluados por Ciudad',
        ancho: 500,
        alto: 300,
      ),
    );
    
    widgets.add(pw.SizedBox(height: 20));
    
    // Mapa de áreas geográficas
    widgets.add(
      pw.Header(
        level: 2,
        text: 'Distribución Geográfica de Evaluaciones',
        textStyle: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold),
      ),
    );
    
    widgets.add(
      GraficasService.crearGraficoMapaAreasPDF(
        datos: Map<String, Map<String, int>>.from(datos['resumenGeneral']['distribucionGeografica']),
        titulo: 'Distribución por Áreas Geográficas',
        ancho: 500,
        alto: 350,
      ),
    );
    
    widgets.add(pw.SizedBox(height: 30));
  }
  
  // === SECCIÓN 2: USO DE VIVIENDA Y TOPOGRAFÍA ===
  widgets.add(_crearSeparadorSeccion('USO DE VIVIENDA Y TOPOGRAFÍA'));
  
  // Gráfico de uso de vivienda
  if (datos['usoTopografia']?['usosVivienda']?['estadisticas']?.isNotEmpty == true) {
    widgets.add(
      pw.Header(
        level: 2,
        text: 'Distribución de Uso de Vivienda',
        textStyle: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold),
      ),
    );
    
    Map<String, int> datosUsos = {};
    datos['usoTopografia']['usosVivienda']['estadisticas'].forEach((uso, stats) {
      if (stats['conteo'] > 0) {
        datosUsos[uso] = stats['conteo'];
      }
    });
    
    if (datosUsos.isNotEmpty) {
      widgets.add(
        GraficasService.crearGraficoCircularPDF(
          datos: datosUsos,
          titulo: 'Distribución de Uso de Vivienda',
          ancho: 500,
          alto: 300,
        ),
      );
    }
    
    widgets.add(pw.SizedBox(height: 20));
  }
  
  // Gráfico de topografía
  if (datos['usoTopografia']?['topografia']?['estadisticas']?.isNotEmpty == true) {
    widgets.add(
      pw.Header(
        level: 2,
        text: 'Distribución de Tipos de Topografía',
        textStyle: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold),
      ),
    );
    
    Map<String, int> datosTopografia = {};
    datos['usoTopografia']['topografia']['estadisticas'].forEach((tipo, stats) {
      if (stats['conteo'] > 0) {
        datosTopografia[tipo] = stats['conteo'];
      }
    });
    
    if (datosTopografia.isNotEmpty) {
      widgets.add(
        GraficasService.crearGraficoBarrasPDF(
          datos: datosTopografia,
          titulo: 'Distribución de Tipos de Topografía',
          ancho: 500,
          alto: 300,
        ),
      );
    }
    
    widgets.add(pw.SizedBox(height: 30));
  }
  
  // === SECCIÓN 3: MATERIAL DOMINANTE ===
  widgets.add(_crearSeparadorSeccion('MATERIAL DOMINANTE DE CONSTRUCCIÓN'));
  
  if (datos['materialDominante']?['conteoMateriales']?.isNotEmpty == true) {
    Map<String, int> datosMateriales = {};
    datos['materialDominante']['conteoMateriales'].forEach((material, conteo) {
      if (conteo > 0) {
        datosMateriales[material] = conteo;
      }
    });
    
    if (datosMateriales.isNotEmpty) {
      widgets.add(
        pw.Header(
          level: 2,
          text: 'Distribución de Materiales Dominantes',
          textStyle: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold),
        ),
      );
      
      widgets.add(
        GraficasService.crearGraficoCircularPDF(
          datos: datosMateriales,
          titulo: 'Distribución por Material Predominante',
          ancho: 500,
          alto: 300,
        ),
      );
      
      widgets.add(pw.SizedBox(height: 20));
      
      widgets.add(
        pw.Header(
          level: 2,
          text: 'Comparativa de Materiales por Frecuencia',
          textStyle: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold),
        ),
      );
      
      widgets.add(
        GraficasService.crearGraficoBarrasHorizontalesPDF(
          datos: datosMateriales,
          titulo: 'Cantidad de Inmuebles por Material Predominante',
          ancho: 500,
          alto: 300,
        ),
      );
      
      widgets.add(pw.SizedBox(height: 30));
    }
  }
  
  // === SECCIÓN 4: SISTEMA ESTRUCTURAL ===
  widgets.add(_crearSeparadorSeccion('SISTEMA ESTRUCTURAL'));
  
  final List<Map<String, String>> categoriasSistema = [
    {'id': 'direccionX', 'titulo': 'Dirección X'},
    {'id': 'direccionY', 'titulo': 'Dirección Y'},
    {'id': 'murosMamposteria', 'titulo': 'Muros de Mampostería'},
    {'id': 'sistemasPiso', 'titulo': 'Sistemas de Piso'},
    {'id': 'sistemasTecho', 'titulo': 'Sistemas de Techo'},
    {'id': 'cimentacion', 'titulo': 'Cimentación'},
  ];
  
  for (var categoria in categoriasSistema) {
    String id = categoria['id']!;
    String titulo = categoria['titulo']!;
    
    if (datos['sistemaEstructural']?['estadisticas']?[id]?.isNotEmpty == true) {
      Map<String, int> datosCategoria = {};
      datos['sistemaEstructural']['estadisticas'][id].forEach((elemento, stats) {
        datosCategoria[elemento] = stats['conteo'];
      });
      
      widgets.add(
        pw.Header(
          level: 2,
          text: 'Distribución de Elementos: $titulo',
          textStyle: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold),
        ),
      );
      
      widgets.add(
        GraficasService.crearGraficoBarrasHorizontalesPDF(
          datos: datosCategoria,
          titulo: 'Frecuencia de Elementos en $titulo',
          ancho: 500,
          alto: 300,
        ),
      );
      
      widgets.add(pw.SizedBox(height: 20));
    }
  }
  
  widgets.add(pw.SizedBox(height: 10));
  
  // === SECCIÓN 5: EVALUACIÓN DE DAÑOS ===
  widgets.add(_crearSeparadorSeccion('EVALUACIÓN DE DAÑOS Y RIESGOS'));
  
  final List<Map<String, dynamic>> configuracionRubros = [
    {'id': 'geotecnicos', 'titulo': 'Daños Geotécnicos', 'tipo': 'barras'},
    {'id': 'losas', 'titulo': 'Daños en Losas', 'tipo': 'barras'},
    {'id': 'sistemaEstructuralDeficiente', 'titulo': 'Calidad del Sistema Estructural', 'tipo': 'circular'},
    {'id': 'techoPesado', 'titulo': 'Tipo de Techo por Peso', 'tipo': 'circular'},
    {'id': 'murosDelgados', 'titulo': 'Refuerzo en Muros', 'tipo': 'circular'},
    {'id': 'irregularidadPlanta', 'titulo': 'Geometría en Planta', 'tipo': 'circular'},
    {'id': 'nivelDano', 'titulo': 'Nivel de Daño Estructural', 'tipo': 'barras'},
  ];
  
  for (var config in configuracionRubros) {
    String id = config['id'];
    String titulo = config['titulo'];
    String tipo = config['tipo'];
    
    if (datos['evaluacionDanos']?['estadisticas']?[id]?.isNotEmpty == true) {
      Map<String, int> datosRubro = {};
      datos['evaluacionDanos']['estadisticas'][id].forEach((condicion, stats) {
        int conteo = stats['conteo'] ?? 0;
        if (conteo > 0) {
          datosRubro[condicion] = conteo;
        }
      });
      
      if (datosRubro.isNotEmpty) {
        widgets.add(
          pw.Header(
            level: 2,
            text: titulo,
            textStyle: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold),
          ),
        );
        
        if (tipo == 'circular') {
          widgets.add(
            GraficasService.crearGraficoCircularPDF(
              datos: datosRubro,
              titulo: 'Distribución de $titulo',
              ancho: 500,
              alto: 300,
            ),
          );
        } else {
          widgets.add(
            GraficasService.crearGraficoBarrasHorizontalesPDF(
              datos: datosRubro,
              titulo: 'Frecuencia de $titulo',
              ancho: 500,
              alto: 300,
            ),
          );
        }
        
        widgets.add(pw.SizedBox(height: 20));
      }
    }
  }
  
  // Gráfico de resumen de riesgos
  if (datos['evaluacionDanos']?['resumenRiesgos'] != null) {
    Map<String, dynamic> resumenRiesgos = datos['evaluacionDanos']['resumenRiesgos'];
    
    Map<String, int> datosRiesgo = {
      'Riesgo Alto': resumenRiesgos['riesgoAlto'] ?? 0,
      'Riesgo Medio': resumenRiesgos['riesgoMedio'] ?? 0,
      'Riesgo Bajo': resumenRiesgos['riesgoBajo'] ?? 0,
    };
    
    // Filtrar valores cero
    datosRiesgo.removeWhere((key, value) => value == 0);
    
    if (datosRiesgo.isNotEmpty) {
      widgets.add(
        pw.Header(
          level: 1,
          text: 'Resumen General de Riesgos',
          textStyle: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
        ),
      );
      
      widgets.add(
        GraficasService.crearGraficoCircularPDF(
          datos: datosRiesgo,
          titulo: 'Distribución General de Niveles de Riesgo',
          ancho: 500,
          alto: 300,
        ),
      );
      
      widgets.add(pw.SizedBox(height: 20));
    }
  }
  
  return widgets;
  
}
/// Crea un separador visual entre secciones del reporte completo
pw.Widget _crearSeparadorSeccion(String tituloSeccion) {
  return pw.Container(
    margin: pw.EdgeInsets.symmetric(vertical: 20),
    padding: pw.EdgeInsets.all(12),
    decoration: pw.BoxDecoration(
      color: PdfColors.blueAccent,
      borderRadius: pw.BorderRadius.circular(8),
    ),
    child: pw.Center(
      child: pw.Text(
        tituloSeccion,
        style: pw.TextStyle(
          fontSize: 16,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.white,
        ),
      ),
    ),
  );
}





List<pw.Widget> _generarGraficosEvaluacionDanos(
    Map<String, dynamic> datos, 
    List<Uint8List> graficas) {
  
  List<pw.Widget> widgets = [];
  
  // Configuración de rubros con sus tipos de gráfico preferidos
  final List<Map<String, dynamic>> configuracionRubros = [
    {
      'id': 'geotecnicos',
      'titulo': 'Daños Geotécnicos',
      'tipo': 'barras',
      'descripcion': 'Problemas relacionados con el suelo y cimientos',
    },
    {
      'id': 'losas',
      'titulo': 'Daños en Losas',
      'tipo': 'barras',
      'descripcion': 'Daños estructurales en elementos horizontales',
    },
    {
      'id': 'sistemaEstructuralDeficiente',
      'titulo': 'Calidad del Sistema Estructural',
      'tipo': 'circular',
      'descripcion': 'Evaluación de la resistencia del sistema estructural',
    },
    {
      'id': 'techoPesado',
      'titulo': 'Tipo de Techo por Peso',
      'tipo': 'circular',
      'descripcion': 'Clasificación según el peso del sistema de techo',
    },
    {
      'id': 'murosDelgados',
      'titulo': 'Refuerzo en Muros',
      'tipo': 'circular',
      'descripcion': 'Análisis del refuerzo en muros de mampostería',
    },
    {
      'id': 'irregularidadPlanta',
      'titulo': 'Geometría en Planta',
      'tipo': 'circular',
      'descripcion': 'Evaluación de la regularidad geométrica',
    },
    {
      'id': 'nivelDano',
      'titulo': 'Nivel de Daño Estructural',
      'tipo': 'barras',
      'descripcion': 'Clasificación general del estado de daños',
    },
  ];
  
  // Para cada rubro, generar su gráfico correspondiente
  for (var config in configuracionRubros) {
    String id = config['id'];
    String titulo = config['titulo'];
    String tipo = config['tipo'];
    String descripcion = config['descripcion'];
    
    // Verificar si hay datos para este rubro
    if (datos['estadisticas']?.containsKey(id) == true && 
        datos['estadisticas'][id].isNotEmpty) {
      
      // Convertir los datos al formato esperado por el servicio de gráficas
      Map<String, int> datosGrafico = {};
      datos['estadisticas'][id].forEach((condicion, stats) {
        int conteo = stats['conteo'] ?? 0;
        if (conteo > 0) { // Solo incluir elementos con datos
          datosGrafico[condicion] = conteo;
        }
      });
      
      // Solo generar gráfico si hay datos significativos
      if (datosGrafico.isNotEmpty) {
        // Añadir encabezado
        widgets.add(
          pw.Header(
            level: 2,
            text: titulo,
            textStyle: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold),
          ),
        );
        
        // Añadir descripción
        widgets.add(
          pw.Paragraph(
            text: descripcion,
            style: pw.TextStyle(
              fontSize: 10,
              fontStyle: pw.FontStyle.italic,
              color: PdfColors.grey700,
            ),
          ),
        );
        
        widgets.add(pw.SizedBox(height: 10));
        
        // Crear el gráfico según el tipo especificado
        if (tipo == 'circular') {
          widgets.add(
            GraficasService.crearGraficoCircularPDF(
              datos: datosGrafico,
              titulo: 'Distribución de $titulo',
              ancho: 500,
              alto: 300,
            ),
          );
        } else {
          widgets.add(
            GraficasService.crearGraficoBarrasHorizontalesPDF(
              datos: datosGrafico,
              titulo: 'Frecuencia de $titulo',
              ancho: 500,
              alto: 300,
            ),
          );
        }
        
        // Añadir estadísticas clave
        widgets.add(pw.SizedBox(height: 10));
        widgets.add(
          _construirEstadisticasClaveDanos(datos['estadisticas'][id], datos['totalFormatos']),
        );
        
        widgets.add(pw.SizedBox(height: 25));
      }
    }
  }
  
  // Gráfico especial para resumen de riesgos
  if (datos.containsKey('resumenRiesgos')) {
    Map<String, dynamic> resumenRiesgos = datos['resumenRiesgos'];
    
    Map<String, int> datosRiesgo = {
      'Riesgo Alto': resumenRiesgos['riesgoAlto'] ?? 0,
      'Riesgo Medio': resumenRiesgos['riesgoMedio'] ?? 0,
      'Riesgo Bajo': resumenRiesgos['riesgoBajo'] ?? 0,
    };
    
    // Filtrar valores cero
    datosRiesgo.removeWhere((key, value) => value == 0);
    
    // Solo mostrar si hay datos significativos
    if (datosRiesgo.isNotEmpty) {
      widgets.add(
        pw.Header(
          level: 1,
          text: 'Resumen General de Riesgos',
          textStyle: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
        ),
      );
      
      widgets.add(
        pw.Paragraph(
          text: 'Clasificación general de inmuebles según su nivel de riesgo estructural combinado.',
          style: pw.TextStyle(
            fontSize: 10,
            fontStyle: pw.FontStyle.italic,
            color: PdfColors.grey700,
          ),
        ),
      );
      
      widgets.add(pw.SizedBox(height: 10));
      
      widgets.add(
        GraficasService.crearGraficoCircularPDF(
          datos: datosRiesgo,
          titulo: 'Distribución General de Niveles de Riesgo',
          ancho: 500,
          alto: 300,
        ),
      );
      
      // Añadir interpretación de riesgos
      widgets.add(pw.SizedBox(height: 10));
      widgets.add(
        _construirInterpretacionRiesgos(resumenRiesgos, datos['totalFormatos']),
      );
      
      widgets.add(pw.SizedBox(height: 25));
    }
  }
  
  return widgets;
}

/// Construye un widget con estadísticas claves para una categoría de daños
pw.Widget _construirEstadisticasClaveDanos(Map<String, dynamic> estadisticas, int totalFormatos) {
  // Encontrar la condición más común
  String condicionMasComun = '';
  int maxConteo = 0;
  
  estadisticas.forEach((condicion, stats) {
    if (stats['conteo'] > maxConteo) {
      maxConteo = stats['conteo'];
      condicionMasComun = condicion;
    }
  });
  
  // Calcular el porcentaje de la condición más común
  double porcentajeMasComun = totalFormatos > 0 ? (maxConteo / totalFormatos) * 100 : 0;
  
  // Contar total de casos con problemas vs sin problemas
  int casosConProblemas = 0;
  int casosSinProblemas = 0;
  
  estadisticas.forEach((condicion, stats) {
    int conteo = stats['conteo'] ?? 0;
    
    // Determinar si es una condición problemática
    if (condicion.toLowerCase().contains('sin') || 
        condicion.toLowerCase().contains('regular') ||
        condicion.toLowerCase().contains('adecuado') ||
        condicion.toLowerCase().contains('ligero') ||
        condicion.toLowerCase().contains('reforzado')) {
      casosSinProblemas += conteo;
    } else {
      casosConProblemas += conteo;
    }
  });
  
  return pw.Container(
    margin: pw.EdgeInsets.symmetric(vertical: 5),
    padding: pw.EdgeInsets.all(8),
    decoration: pw.BoxDecoration(
      color: PdfColors.grey50,
      borderRadius: pw.BorderRadius.circular(5),
      border: pw.Border.all(color: PdfColors.grey300),
    ),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Estadísticas clave:',
          style: pw.TextStyle(
            fontWeight: pw.FontWeight.bold,
            fontSize: 9,
            color: PdfColors.blueGrey800,
          ),
        ),
        pw.SizedBox(height: 3),
        pw.Text(
          '• Condición más frecuente: $condicionMasComun (${porcentajeMasComun.toStringAsFixed(1)}%)',
          style: pw.TextStyle(fontSize: 8),
        ),
        if (casosConProblemas > 0 || casosSinProblemas > 0) ...[
          pw.Text(
            '• Casos con problemas: $casosConProblemas (${((casosConProblemas / totalFormatos) * 100).toStringAsFixed(1)}%)',
            style: pw.TextStyle(fontSize: 8, color: PdfColors.red700),
          ),
          pw.Text(
            '• Casos sin problemas: $casosSinProblemas (${((casosSinProblemas / totalFormatos) * 100).toStringAsFixed(1)}%)',
            style: pw.TextStyle(fontSize: 8, color: PdfColors.green700),
          ),
        ],
      ],
    ),
  );
}

/// Construye interpretación de los niveles de riesgo
pw.Widget _construirInterpretacionRiesgos(Map<String, dynamic> resumenRiesgos, int totalFormatos) {
  int riesgoAlto = resumenRiesgos['riesgoAlto'] ?? 0;
  int riesgoMedio = resumenRiesgos['riesgoMedio'] ?? 0;
  int riesgoBajo = resumenRiesgos['riesgoBajo'] ?? 0;
  
  return pw.Container(
    margin: pw.EdgeInsets.symmetric(vertical: 10),
    padding: pw.EdgeInsets.all(12),
    decoration: pw.BoxDecoration(
      color: PdfColors.amber50,
      borderRadius: pw.BorderRadius.circular(8),
      border: pw.Border.all(color: PdfColors.amber300),
    ),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Interpretación de Riesgos:',
          style: pw.TextStyle(
            fontWeight: pw.FontWeight.bold,
            fontSize: 10,
            color: PdfColors.amber900,
          ),
        ),
        pw.SizedBox(height: 8),
        
        // Riesgo Alto
        if (riesgoAlto > 0) ...[
          pw.Row(
            children: [
              pw.Container(
                width: 8,
                height: 8,
                decoration: pw.BoxDecoration(
                  color: PdfColors.red,
                  shape: pw.BoxShape.circle,
                ),
              ),
              pw.SizedBox(width: 5),
              pw.Expanded(
                child: pw.Text(
                  'Riesgo Alto ($riesgoAlto inmuebles): Requieren intervención inmediata. Incluye colapsos totales, daños severos y elementos estructurales críticos.',
                  style: pw.TextStyle(fontSize: 8),
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 4),
        ],
        
        // Riesgo Medio
        if (riesgoMedio > 0) ...[
          pw.Row(
            children: [
              pw.Container(
                width: 8,
                height: 8,
                decoration: pw.BoxDecoration(
                  color: PdfColors.orange,
                  shape: pw.BoxShape.circle,
                ),
              ),
              pw.SizedBox(width: 5),
              pw.Expanded(
                child: pw.Text(
                  'Riesgo Medio ($riesgoMedio inmuebles): Requieren refuerzo o reparación. Incluye daños medios y sistemas estructurales deficientes.',
                  style: pw.TextStyle(fontSize: 8),
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 4),
        ],
        
        // Riesgo Bajo
        if (riesgoBajo > 0) ...[
          pw.Row(
            children: [
              pw.Container(
                width: 8,
                height: 8,
                decoration: pw.BoxDecoration(
                  color: PdfColors.green,
                  shape: pw.BoxShape.circle,
                ),
              ),
              pw.SizedBox(width: 5),
              pw.Expanded(
                child: pw.Text(
                  'Riesgo Bajo ($riesgoBajo inmuebles): Requieren monitoreo preventivo. Incluye daños ligeros y vulnerabilidades menores.',
                  style: pw.TextStyle(fontSize: 8),
                ),
              ),
            ],
          ),
        ],
      ],
    ),
  );
}

// Método para generar gráficos específicos del reporte de material dominante
List<pw.Widget> _generarGraficosMaterialDominante(
    Map<String, dynamic> datos, 
    List<Uint8List> graficas) {
  
  List<pw.Widget> widgets = [];
  
  // Gráfico circular de distribución de materiales
  if (datos.containsKey('conteoMateriales') && 
      datos['conteoMateriales'].isNotEmpty) {
    
    widgets.add(
      pw.Header(
        level: 2,
        text: 'Distribución de Materiales Dominantes',
        textStyle: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold),
      ),
    );
    
    Map<String, int> datosMateriales = {};
    datos['conteoMateriales'].forEach((material, conteo) {
      if (conteo > 0) {
        datosMateriales[material] = conteo;
      }
    });
    
    if (datosMateriales.isNotEmpty) {
      widgets.add(
        GraficasService.crearGraficoCircularPDF(
          datos: datosMateriales,
          titulo: 'Distribución por Material Predominante',
          ancho: 500,
          alto: 300,
        ),
      );
      
      // Añadir también un gráfico de barras para mejor visualización
      widgets.add(pw.SizedBox(height: 20));
      
      widgets.add(
        pw.Header(
          level: 2,
          text: 'Comparativa de Materiales por Frecuencia',
          textStyle: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold),
        ),
      );
      
      widgets.add(
        GraficasService.crearGraficoBarrasHorizontalesPDF(
          datos: datosMateriales,
          titulo: 'Cantidad de Inmuebles por Material Predominante',
          ancho: 500,
          alto: 300,
        ),
      );
    }
    
    widgets.add(pw.SizedBox(height: 20));
  }
  
  return widgets;
}
// Graficos sistema estructural
List<pw.Widget> _generarGraficosSistemaEstructural(
    Map<String, dynamic> datos, 
    List<Uint8List> graficas) {
  
  List<pw.Widget> widgets = [];
  
  // Categorías a incluir en los gráficos
  final List<Map<String, String>> categorias = [
    {'id': 'direccionX', 'titulo': 'Dirección X'},
    {'id': 'direccionY', 'titulo': 'Dirección Y'},
    {'id': 'murosMamposteria', 'titulo': 'Muros de Mampostería'},
    {'id': 'sistemasPiso', 'titulo': 'Sistemas de Piso'},
    {'id': 'sistemasTecho', 'titulo': 'Sistemas de Techo'},
    {'id': 'cimentacion', 'titulo': 'Cimentación'},
  ];
  
  // Para cada categoría, generar un gráfico
  for (var categoria in categorias) {
    String id = categoria['id']!;
    String titulo = categoria['titulo']!;
    
    // Verificar si hay datos para esta categoría
    if (datos['estadisticas']?[id] != null && 
        datos['estadisticas'][id].isNotEmpty) {
      
      // Convertir los datos al formato esperado por el servicio de gráficas
      Map<String, int> datosGrafico = {};
      datos['estadisticas'][id].forEach((elemento, stats) {
        datosGrafico[elemento] = stats['conteo'];
      });
      
      // Añadir encabezado
      widgets.add(
        pw.Header(
          level: 2,
          text: 'Distribución de Elementos: $titulo',
          textStyle: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold),
        ),
      );
      
      // Crear y añadir el gráfico
      widgets.add(
        GraficasService.crearGraficoBarrasHorizontalesPDF(
          datos: datosGrafico,
          titulo: 'Frecuencia de Elementos en $titulo',
          ancho: 500,
          alto: 300,
        ),
      );
      
      widgets.add(pw.SizedBox(height: 20));
    }
  }
  
  return widgets;
}
// Método para generar gráficos específicos del reporte de resumen general
List<pw.Widget> _generarGraficosResumenGeneral(
    Map<String, dynamic> datos, 
    List<Uint8List> graficas) {
  
  List<pw.Widget> widgets = [];
  
  // Gráfico 1: Distribución geográfica por ciudades
  if (datos.containsKey('distribucionGeografica') && 
      datos['distribucionGeografica'].containsKey('ciudades') &&
      datos['distribucionGeografica']['ciudades'].isNotEmpty) {
    
    widgets.add(
      pw.Header(
        level: 2,
        text: 'Distribución de Evaluaciones por Ciudad',
        textStyle: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold),
      ),
    );
    
    widgets.add(
      GraficasService.crearGraficoBarrasHorizontalesPDF(
        datos: datos['distribucionGeografica']['ciudades'],
        titulo: 'Cantidad de Inmuebles Evaluados por Ciudad',
        ancho: 500,
        alto: 300,
      ),
    );
    
    widgets.add(pw.SizedBox(height: 20));
  }
  
  // Gráfico 2: Mapa de áreas (colonias)
  if (datos.containsKey('distribucionGeografica')) {
    widgets.add(
      pw.Header(
        level: 2,
        text: 'Distribución Geográfica de Evaluaciones',
        textStyle: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold),
      ),
    );
    
    widgets.add(
      GraficasService.crearGraficoMapaAreasPDF(
        datos: datos['distribucionGeografica'],
        titulo: 'Distribución por Áreas Geográficas',
        ancho: 500,
        alto: 350,
      ),
    );
    
    widgets.add(pw.SizedBox(height: 20));
  }
  
  // Gráfico 3: Tendencia temporal (líneas)
  /*if (datos.containsKey('distribucionTemporal') && 
      datos['distribucionTemporal'].containsKey('meses') &&
      datos['distribucionTemporal']['meses'].isNotEmpty) {
    
    widgets.add(
      pw.Header(
        level: 2,
        text: 'Evolución Temporal de Evaluaciones',
        textStyle: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold),
      ),
    );
    
    
    
    widgets.add(pw.SizedBox(height: 20));
  }*/
  
  return widgets;
}

// Método para generar gráficos específicos del reporte de uso y topografía
List<pw.Widget> _generarGraficosUsoViviendaTopografia(
    Map<String, dynamic> datos, 
    List<Uint8List> graficas) {
  
  List<pw.Widget> widgets = [];
  
  // Gráfico de uso de vivienda
  if (datos.containsKey('usosVivienda') && 
      datos['usosVivienda'].containsKey('estadisticas')) {
    
    widgets.add(
      pw.Header(
        level: 2,
        text: 'Distribución de Uso de Vivienda',
        textStyle: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold),
      ),
    );
    
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
          ancho: 500,
          alto: 300,
        ),
      );
    }
    
    widgets.add(pw.SizedBox(height: 20));
  }
  
  // Gráfico de topografía
  if (datos.containsKey('topografia') && 
      datos['topografia'].containsKey('estadisticas')) {
    
    widgets.add(
      pw.Header(
        level: 2,
        text: 'Distribución de Tipos de Topografía',
        textStyle: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold),
      ),
    );
    
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
          ancho: 500,
          alto: 300,
        ),
      );
    }
    
    widgets.add(pw.SizedBox(height: 20));
  }
  
  return widgets;
}

// Método para generar gráficos genéricos (fallback)
List<pw.Widget> _generarGraficosGenericos(
    Map<String, dynamic> datos, 
    List<Uint8List> graficas) {
  
  List<pw.Widget> widgets = [];
  
  // Si hay gráficas proporcionadas como placeholders, intentar generar gráficos genéricos
  for (var i = 0; i < graficas.length; i++) {
    widgets.add(
      pw.Header(
        level: 2,
        text: 'Gráfico ${i + 1}',
        textStyle: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold),
      ),
    );
    
    // Este es un gráfico genérico de barras, se puede personalizar según los datos disponibles
    widgets.add(
      pw.Container(
        width: 500,
        height: 300,
        alignment: pw.Alignment.center,
        child: pw.Text('Gráfico no disponible para este tipo de reporte'),
      ),
    );
    
    widgets.add(pw.SizedBox(height: 20));
  }
  
  return widgets;
}
