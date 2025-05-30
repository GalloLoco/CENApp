// lib/data/reportes/evaluacion_danos_excel.dart

import 'dart:io';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xlsio;
import 'package:syncfusion_officechart/officechart.dart';

import 'package:syncfusion_flutter_xlsio/xlsio.dart'; // Ensure this import is added for ExcelCFType
import 'package:intl/intl.dart';
import '../services/file_storage_service.dart';

/// Servicio optimizado para generar reportes Excel de Evaluación de Daños usando Syncfusion
/// Versión específica para análisis de daños estructurales y riesgos
/// Basado en el diseño y formato de ExcelReporteServiceUsoViviendaV2
class ExcelReporteServiceEvaluacionDanosV2 {
  final FileStorageService _fileService = FileStorageService();

  // Constantes para estilos y formato (mantenemos misma estructura)
  static const String FONT_NAME = 'Calibri';
  static const int HEADER_FONT_SIZE = 16;
  static const int SUBTITLE_FONT_SIZE = 14;
  static const int SECTION_FONT_SIZE = 12;
  static const int NORMAL_FONT_SIZE = 10;

  // Colores corporativos específicos para evaluación de daños
  static const String COLOR_HEADER = '#C5504B'; // Rojo para riesgos
  static const String COLOR_SUBTITLE = '#D75442';
  static const String COLOR_SECTION = '#FF6B6B'; // Rojo más claro para secciones
  static const String COLOR_TABLE_HEADER = '#FFB3B3';

  /// Genera reporte de Evaluación de Daños estructurales
  /// Incluye análisis de riesgos y gráficos de barras similares a la versión PDF
  Future<String> generarReporteEvaluacionDanos({
    required String titulo,
    required String subtitulo,
    required Map<String, dynamic> datos,
    required List<Map<String, dynamic>> tablas,
    required Map<String, dynamic> metadatos,
    Directory? directorio,
  }) async {
    try {
      print('📊 [EXCEL-DAÑOS-V2] Iniciando generación con Syncfusion: $titulo');

      // Crear nuevo libro de Excel
      final xlsio.Workbook workbook = xlsio.Workbook();

      // Crear hoja principal
      final xlsio.Worksheet sheet = workbook.worksheets[0];
      sheet.name = 'Evaluación de Daños';

      // Configurar anchos de columna óptimos
      _configurarAnchoColumnas(sheet);

      int filaActual = 1; // Syncfusion usa base 1

      // === SECCIÓN 1: ENCABEZADO ===
      filaActual = _crearEncabezado(sheet, titulo, subtitulo, metadatos, filaActual);
      filaActual += 2;

      // === SECCIÓN 2: FILTROS APLICADOS ===
      filaActual = _crearSeccionFiltros(sheet, metadatos, filaActual);
      filaActual += 2;

      // === SECCIÓN 3: RESUMEN ESTADÍSTICO DE RIESGOS ===
      filaActual = _crearResumenEstadistico(sheet, datos, metadatos, filaActual);
      filaActual += 2;

      // === SECCIÓN 4: ANÁLISIS DAÑOS GEOTÉCNICOS CON GRÁFICO ===
      filaActual = await _crearAnalisisDanosGeotecnicos(sheet, datos, filaActual);
      filaActual += 2;

      // === SECCIÓN 5: ANÁLISIS NIVEL DE DAÑO CON GRÁFICO ===
      filaActual = await _crearAnalisisNivelDano(sheet, datos, filaActual);
      filaActual += 2;

      // === SECCIÓN 6: CONCLUSIONES Y RECOMENDACIONES ===
      _crearSeccionConclusiones(sheet, datos, metadatos, filaActual);

      // Guardar archivo
      final String rutaArchivo = await _guardarArchivo(workbook, titulo, directorio);

      // Liberar recursos
      workbook.dispose();

      print('✅ [EXCEL-DAÑOS-V2] Reporte generado exitosamente: $rutaArchivo');
      return rutaArchivo;
    } catch (e) {
      print('❌ [EXCEL-DAÑOS-V2] Error al generar reporte: $e');
      throw Exception('Error al generar reporte Excel: $e');
    }
  }

  /// Configura los anchos de columna óptimos para el reporte (igual que uso/topografía)
  void _configurarAnchoColumnas(xlsio.Worksheet sheet) {
    sheet.getRangeByIndex(1, 1, 100, 1).columnWidth = 30; // Columna A
    sheet.getRangeByIndex(1, 2, 100, 2).columnWidth = 15; // Columna B
    sheet.getRangeByIndex(1, 3, 100, 3).columnWidth = 15; // Columna C
    sheet.getRangeByIndex(1, 4, 100, 4).columnWidth = 25; // Columna D
    sheet.getRangeByIndex(1, 5, 100, 5).columnWidth = 20; // Columna E
    sheet.getRangeByIndex(1, 6, 100, 6).columnWidth = 20; // Columna F
  }

  /// Crea el encabezado del reporte con formato profesional (adaptado para daños)
  int _crearEncabezado(
    xlsio.Worksheet sheet,
    String titulo,
    String subtitulo,
    Map<String, dynamic> metadatos,
    int filaInicial,
  ) {
    int fila = filaInicial;

    // Título principal
    final xlsio.Range rangoTitulo = sheet.getRangeByIndex(fila, 1, fila, 6);
    rangoTitulo.merge();
    rangoTitulo.setText(titulo.toUpperCase());
    rangoTitulo.cellStyle.fontSize = HEADER_FONT_SIZE.toDouble();
    rangoTitulo.cellStyle.fontName = FONT_NAME;
    rangoTitulo.cellStyle.bold = true;
    rangoTitulo.cellStyle.hAlign = xlsio.HAlignType.center;
    rangoTitulo.cellStyle.backColor = COLOR_HEADER;
    rangoTitulo.cellStyle.fontColor = '#FFFFFF';
    fila++;

    // Subtítulo
    final xlsio.Range rangoSubtitulo = sheet.getRangeByIndex(fila, 1, fila, 6);
    rangoSubtitulo.merge();
    rangoSubtitulo.setText(subtitulo);
    rangoSubtitulo.cellStyle.fontSize = SUBTITLE_FONT_SIZE.toDouble();
    rangoSubtitulo.cellStyle.fontName = FONT_NAME;
    rangoSubtitulo.cellStyle.bold = true;
    rangoSubtitulo.cellStyle.hAlign = xlsio.HAlignType.center;
    rangoSubtitulo.cellStyle.backColor = COLOR_SUBTITLE;
    rangoSubtitulo.cellStyle.fontColor = '#FFFFFF';
    fila++;

    // Fecha de generación
    final String fechaGeneracion = DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now());
    final xlsio.Range rangoFecha = sheet.getRangeByIndex(fila, 1, fila, 6);
    rangoFecha.merge();
    rangoFecha.setText('Generado el: $fechaGeneracion');
    rangoFecha.cellStyle.fontSize = NORMAL_FONT_SIZE.toDouble();
    rangoFecha.cellStyle.fontName = FONT_NAME;
    rangoFecha.cellStyle.hAlign = xlsio.HAlignType.center;
    rangoFecha.cellStyle.backColor = '#E7E6E6';

    return fila;
  }

  /// Crea la sección de filtros aplicados (igual estructura que uso/topografía)
  int _crearSeccionFiltros(
    xlsio.Worksheet sheet,
    Map<String, dynamic> metadatos,
    int filaInicial,
  ) {
    int fila = filaInicial;

    // Título de sección
    _aplicarEstiloSeccion(sheet, fila, 'FILTROS APLICADOS');
    fila++;

    // Lista de filtros (misma estructura)
    final List<List<String>> filtros = [
      ['Nombre inmueble:', metadatos['nombreInmueble'] ?? 'Todos'],
      ['Período:', '${metadatos['fechaInicio']} - ${metadatos['fechaFin']}'],
      ['Usuario creador:', metadatos['usuarioCreador'] ?? 'Todos'],
      ['Total formatos:', '${metadatos['totalFormatos']}'],
    ];

    // Agregar ubicaciones si existen (igual lógica)
    if (metadatos['ubicaciones'] != null && metadatos['ubicaciones'].isNotEmpty) {
      final List<Map<String, dynamic>> ubicaciones = metadatos['ubicaciones'];
      for (int i = 0; i < ubicaciones.length && i < 3; i++) {
        final ubi = ubicaciones[i];
        String ubicacionStr = '${ubi['municipio']}, ${ubi['ciudad']}';
        if (ubi['colonia'] != null && ubi['colonia'].isNotEmpty) {
          ubicacionStr += ', ${ubi['colonia']}';
        }
        filtros.add(['Ubicación ${i + 1}:', ubicacionStr]);
      }
    }

    // Escribir filtros (misma estructura)
    for (var filtro in filtros) {
      sheet.getRangeByIndex(fila, 1).setText(filtro[0]);
      sheet.getRangeByIndex(fila, 1).cellStyle.bold = true;
      sheet.getRangeByIndex(fila, 1).cellStyle.backColor = '#F2F2F2';

      sheet.getRangeByIndex(fila, 2, fila, 3).merge();
      sheet.getRangeByIndex(fila, 2).setText(filtro[1]);
      sheet.getRangeByIndex(fila, 2).cellStyle.backColor = '#FAFAFA';

      fila++;
    }

    return fila;
  }

  /// Crea el resumen estadístico general específico para daños
  int _crearResumenEstadistico(
    xlsio.Worksheet sheet,
    Map<String, dynamic> datos,
    Map<String, dynamic> metadatos,
    int filaInicial,
  ) {
    int fila = filaInicial;

    // Título de sección
    _aplicarEstiloSeccion(sheet, fila, 'RESUMEN ESTADÍSTICO DE EVALUACIÓN DE DAÑOS');
    fila++;

    final int totalFormatos = metadatos['totalFormatos'] ?? 0;

    // Calcular estadísticas específicas de daños
    int totalRiesgosIdentificados = 0;
    int categoriasDanosDistintas = 0;
    
    // Extraer datos del resumen de riesgos
    Map<String, dynamic> resumenRiesgos = datos['resumenRiesgos'] ?? {};
    int riesgoAlto = resumenRiesgos['riesgoAlto'] ?? 0;
    int riesgoMedio = resumenRiesgos['riesgoMedio'] ?? 0;
    int riesgoBajo = resumenRiesgos['riesgoBajo'] ?? 0;
    
    totalRiesgosIdentificados = riesgoAlto + riesgoMedio + riesgoBajo;
    
    // Contar categorías con datos
    if (datos['estadisticas'] != null) {
      Map<String, dynamic> estadisticas = datos['estadisticas'];
      categoriasDanosDistintas = estadisticas.values
          .where((stats) => stats != null && stats.isNotEmpty)
          .length;
    }

    // Crear tabla de resumen específica para daños
    _crearTablaResumen(sheet, fila, [
      ['Total de inmuebles evaluados', '$totalFormatos', '100% de la muestra'],
      ['Inmuebles con riesgo alto', '$riesgoAlto', '${totalFormatos > 0 ? (riesgoAlto / totalFormatos * 100).toStringAsFixed(1) : 0}% - Intervención inmediata'],
      ['Inmuebles con riesgo medio', '$riesgoMedio', '${totalFormatos > 0 ? (riesgoMedio / totalFormatos * 100).toStringAsFixed(1) : 0}% - Refuerzo programado'],
      ['Inmuebles con riesgo bajo', '$riesgoBajo', '${totalFormatos > 0 ? (riesgoBajo / totalFormatos * 100).toStringAsFixed(1) : 0}% - Monitoreo preventivo'],
      ['Categorías de daños analizadas', '$categoriasDanosDistintas', 'Tipos de evaluación estructural'],
      ['Total riesgos identificados', '$totalRiesgosIdentificados', 'Suma de todos los niveles de riesgo'],
    ]);

    return fila + 7; // 6 filas de datos + 1 encabezado
  }

  /// Crea el análisis de daños geotécnicos con gráfico de barras
  Future<int> _crearAnalisisDanosGeotecnicos(
    xlsio.Worksheet sheet,
    Map<String, dynamic> datos,
    int filaInicial,
  ) async {
    int fila = filaInicial;

    // Título de sección
    _aplicarEstiloSeccion(sheet, fila, 'ANÁLISIS DETALLADO DE DAÑOS GEOTÉCNICOS');
    fila++;

    // Verificar si hay datos geotécnicos
    if (!datos.containsKey('estadisticas') ||
        !datos['estadisticas'].containsKey('geotecnicos')) {
      sheet.getRangeByIndex(fila, 1).setText('No hay datos de daños geotécnicos disponibles');
      return fila + 1;
    }

    Map<String, dynamic> estadisticasGeotecnicos = datos['estadisticas']['geotecnicos'];

    // Preparar datos para la tabla y el gráfico
    List<MapEntry<String, dynamic>> danosOrdenados = estadisticasGeotecnicos.entries
        .where((entry) => entry.value['conteo'] > 0)
        .toList()
      ..sort((a, b) => b.value['conteo'].compareTo(a.value['conteo']));

    int totalDanos = danosOrdenados.fold(
        0, (sum, entry) => sum + entry.value['conteo'] as int);

    // Crear tabla de datos específica para daños geotécnicos
    final posicionesGraficos = _crearTablaDanosGeotecnicos(sheet, fila, danosOrdenados, totalDanos);
    final int filaFinal = posicionesGraficos['filaFinal']!;
    fila = filaFinal;
    fila += 2;

    // Crear gráfico de barras
    if (danosOrdenados.isNotEmpty) {
      fila = await _crearGraficoBarras(
          sheet,
          fila,
          posicionesGraficos,
          'Distribución de Daños Geotécnicos',
          'Tipo de Daño Geotécnico',
          'Cantidad de Inmuebles Afectados');
    }

    return fila;
  }

  /// Crea el análisis de nivel de daño con gráfico de barras
  Future<int> _crearAnalisisNivelDano(
    xlsio.Worksheet sheet,
    Map<String, dynamic> datos,
    int filaInicial,
  ) async {
    int fila = filaInicial;

    // Título de sección
    _aplicarEstiloSeccion(sheet, fila, 'ANÁLISIS DETALLADO DE NIVEL DE DAÑO');
    fila++;

    // Verificar si hay datos de nivel de daño
    if (!datos.containsKey('estadisticas') ||
        !datos['estadisticas'].containsKey('nivelDano')) {
      sheet.getRangeByIndex(fila, 1).setText('No hay datos de nivel de daño disponibles');
      return fila + 1;
    }

    Map<String, dynamic> estadisticasNivelDano = datos['estadisticas']['nivelDano'];

    // Preparar datos ordenados por severidad
    List<MapEntry<String, dynamic>> nivelesOrdenados = estadisticasNivelDano.entries
        .where((entry) => entry.value['conteo'] > 0)
        .toList();

    // Ordenar por severidad (colapso total primero)
    final ordenSeveridad = [
      'Colapso total',
      'Daño severo', 
      'Daño medio',
      'Daño ligero',
      'Sin daño aparente'
    ];

    nivelesOrdenados.sort((a, b) {
      int indexA = ordenSeveridad.indexOf(a.key);
      int indexB = ordenSeveridad.indexOf(b.key);
      if (indexA == -1) indexA = 999;
      if (indexB == -1) indexB = 999;
      return indexA.compareTo(indexB);
    });

    int totalNiveles = nivelesOrdenados.fold(
        0, (sum, entry) => sum + entry.value['conteo'] as int);

    // Mapeo de acciones y urgencia por nivel
    Map<String, Map<String, String>> accionesPorNivel = {
      'Colapso total': {
        'urgencia': 'INMEDIATA',
        'accion': 'Evacuación y demolición controlada'
      },
      'Daño severo': {
        'urgencia': '24-48 HORAS',
        'accion': 'Refuerzo urgente y apuntalamiento'
      },
      'Daño medio': {
        'urgencia': '1-2 SEMANAS',
        'accion': 'Reparación estructural programada'
      },
      'Daño ligero': {
        'urgencia': '1-3 MESES',
        'accion': 'Mantenimiento preventivo'
      },
      'Sin daño aparente': {
        'urgencia': 'MONITOREO',
        'accion': 'Inspección periódica'
      },
    };

    // Crear tabla de datos específica para nivel de daño
    final posicionesGraficos = _crearTablaNivelDano(sheet, fila, nivelesOrdenados,
        totalNiveles, accionesPorNivel);
    final int filaFinal = posicionesGraficos['filaFinal']!;
    fila = filaFinal;
    fila += 2;

    // Crear gráfico de barras
    if (nivelesOrdenados.isNotEmpty) {
      fila = await _crearGraficoBarras(
          sheet,
          fila,
          posicionesGraficos,
          'Distribución de Niveles de Daño Estructural',
          'Nivel de Daño',
          'Cantidad de Inmuebles');
    }

    return fila;
  }

  /// Crea sección de conclusiones y recomendaciones específicas para daños
  void _crearSeccionConclusiones(
    xlsio.Worksheet sheet,
    Map<String, dynamic> datos,
    Map<String, dynamic> metadatos,
    int filaInicial,
  ) {
    int fila = filaInicial;

    // Título de sección
    _aplicarEstiloSeccion(sheet, fila, 'RECOMENDACIONES DE INTERVENCIÓN Y CONCLUSIONES');
    fila++;

    // Análisis de prioridades basado en datos
    final xlsio.Range rangoAnalisis = sheet.getRangeByIndex(fila, 1, fila, 3);
    rangoAnalisis.merge();
    rangoAnalisis.setText('ANÁLISIS DE PRIORIDADES DE INTERVENCIÓN');
    rangoAnalisis.cellStyle.bold = true;
    rangoAnalisis.cellStyle.backColor = '#FFE2CC';
    fila++;

    // Extraer datos de riesgo
    Map<String, dynamic> resumenRiesgos = datos['resumenRiesgos'] ?? {};
    int riesgoAlto = resumenRiesgos['riesgoAlto'] ?? 0;
    int riesgoMedio = resumenRiesgos['riesgoMedio'] ?? 0;
    int riesgoBajo = resumenRiesgos['riesgoBajo'] ?? 0;
    int totalFormatos = metadatos['totalFormatos'] ?? 0;

    // Encontrar elementos críticos
    String nivelCritico = _encontrarNivelCritico(datos['estadisticas']?['nivelDano'] ?? {});
    String danoGeotecnicoPredominante = _encontrarPredominante(datos['estadisticas']?['geotecnicos'] ?? {});

    sheet.getRangeByIndex(fila, 1).setText('Inmuebles críticos (riesgo alto):');
    sheet.getRangeByIndex(fila, 1).cellStyle.bold = true;
    sheet.getRangeByIndex(fila, 2, fila, 3).merge();
    sheet.getRangeByIndex(fila, 2).setText('$riesgoAlto inmuebles (${totalFormatos > 0 ? (riesgoAlto / totalFormatos * 100).toStringAsFixed(1) : 0}%)');
    fila++;

    sheet.getRangeByIndex(fila, 1).setText('Nivel de daño predominante:');
    sheet.getRangeByIndex(fila, 1).cellStyle.bold = true;
    sheet.getRangeByIndex(fila, 2, fila, 3).merge();
    sheet.getRangeByIndex(fila, 2).setText(nivelCritico);
    fila++;

    sheet.getRangeByIndex(fila, 1).setText('Problema geotécnico principal:');
    sheet.getRangeByIndex(fila, 1).cellStyle.bold = true;
    sheet.getRangeByIndex(fila, 2, fila, 3).merge();
    sheet.getRangeByIndex(fila, 2).setText(danoGeotecnicoPredominante);
    fila += 2;

    // Recomendaciones específicas
    final xlsio.Range rangoConclusiones = sheet.getRangeByIndex(fila, 1, fila, 3);
    rangoConclusiones.merge();
    rangoConclusiones.setText('RECOMENDACIONES PRIORITARIAS:');
    rangoConclusiones.cellStyle.bold = true;
    rangoConclusiones.cellStyle.backColor = '#FFF2CC';
    fila++;

    String conclusiones = metadatos['conclusiones'] ?? 'Se requiere implementar acciones prioritarias para inmuebles de alto riesgo y programa de monitoreo para el resto.';
    List<String> lineasConclusiones = conclusiones
        .split('\n')
        .where((linea) => linea.trim().isNotEmpty)
        .take(5) // Limitar a 5 líneas principales
        .toList();

    for (String linea in lineasConclusiones) {
      final xlsio.Range rangoLinea = sheet.getRangeByIndex(fila, 1, fila, 6);
      rangoLinea.merge();
      rangoLinea.setText(linea.trim());
      rangoLinea.cellStyle.backColor = '#FFF9E6';
      rangoLinea.cellStyle.wrapText = true;
      fila++;
    }
  }

  // === MÉTODOS AUXILIARES ESPECÍFICOS PARA DAÑOS ===

  /// Aplica estilo de sección (igual que uso/topografía pero con colores de daños)
  void _aplicarEstiloSeccion(xlsio.Worksheet sheet, int fila, String titulo) {
    final xlsio.Range rango = sheet.getRangeByIndex(fila, 1, fila, 6);
    rango.merge();
    rango.setText(titulo);
    rango.cellStyle.fontSize = SECTION_FONT_SIZE.toDouble();
    rango.cellStyle.fontName = FONT_NAME;
    rango.cellStyle.bold = true;
    rango.cellStyle.hAlign = xlsio.HAlignType.left;
    rango.cellStyle.backColor = COLOR_SECTION;
    rango.cellStyle.fontColor = '#FFFFFF';
    rango.cellStyle.borders.all.lineStyle = xlsio.LineStyle.thin;
  }

  /// Crea tabla de resumen con formato (igual estructura que uso/topografía)
  void _crearTablaResumen(
      xlsio.Worksheet sheet, int filaInicial, List<List<String>> datos) {
    int fila = filaInicial;

    // Encabezados
    sheet.getRangeByIndex(fila, 1).setText('Concepto');
    sheet.getRangeByIndex(fila, 2).setText('Valor');
    sheet.getRangeByIndex(fila, 3).setText('Observación');

    final xlsio.Range rangoHeader = sheet.getRangeByIndex(fila, 1, fila, 3);
    rangoHeader.cellStyle.bold = true;
    rangoHeader.cellStyle.backColor = COLOR_SECTION;
    rangoHeader.cellStyle.fontColor = '#FFFFFF';
    rangoHeader.cellStyle.borders.all.lineStyle = xlsio.LineStyle.thin;
    fila++;

    // Datos
    for (int i = 0; i < datos.length; i++) {
      sheet.getRangeByIndex(fila, 1).setText(datos[i][0]);
      sheet.getRangeByIndex(fila, 2).setText(datos[i][1]);
      sheet.getRangeByIndex(fila, 3).setText(datos[i][2]);

      // Alternar colores de fila
      String bgColor = fila % 2 == 0 ? '#F2F2F2' : '#FFFFFF';
      final xlsio.Range rangoFila = sheet.getRangeByIndex(fila, 1, fila, 3);
      rangoFila.cellStyle.backColor = bgColor;
      rangoFila.cellStyle.borders.all.lineStyle = xlsio.LineStyle.thin;

      fila++;
    }
  }

  /// Crea tabla de daños geotécnicos con formato específico
  Map<String, int> _crearTablaDanosGeotecnicos(xlsio.Worksheet sheet, int filaInicial,
      List<MapEntry<String, dynamic>> datos, int total) {
    int fila = filaInicial;

    // Rango para gráfica
    int filaGraficaInicio = 0;
    int filaGraficaFin = 0;
    int columnaGraficaInicio = 0;
    int columnaGraficaFin = 0;

    // Encabezados específicos para daños geotécnicos
    sheet.getRangeByIndex(fila, 1).setText('Tipo de Daño Geotécnico');
    sheet.getRangeByIndex(fila, 2).setText('Inmuebles Afectados');
    sheet.getRangeByIndex(fila, 3).setText('Porcentaje');
    sheet.getRangeByIndex(fila, 4).setText('Nivel de Gravedad');
    filaGraficaInicio = fila;
    columnaGraficaInicio = 1;

    final xlsio.Range rangoHeader = sheet.getRangeByIndex(fila, 1, fila, 4);
    rangoHeader.cellStyle.bold = true;
    rangoHeader.cellStyle.backColor = COLOR_TABLE_HEADER;
    rangoHeader.cellStyle.fontColor = '#FFFFFF';
    rangoHeader.cellStyle.borders.all.lineStyle = xlsio.LineStyle.thin;
    fila++;

    // Mapeo de gravedad para daños geotécnicos
    Map<String, String> gravedadDanos = {
      'Grietas en el terreno': 'ALTA',
      'Hundimientos': 'CRÍTICA',
      'Inclinación del edificio': 'CRÍTICA',
    };

    // Datos
    for (int i = 0; i < datos.length; i++) {
      var entry = datos[i];
      String dano = entry.key;
      int conteo = entry.value['conteo'];
      double porcentaje = total > 0 ? (conteo / total) * 100 : 0;
      String gravedad = gravedadDanos[dano] ?? 'MEDIA';

      sheet.getRangeByIndex(fila, 1).setText(dano);
      sheet.getRangeByIndex(fila, 2).setNumber(conteo.toDouble());
      sheet.getRangeByIndex(fila, 3).setText('${porcentaje.toStringAsFixed(1)}%');
      sheet.getRangeByIndex(fila, 4).setText(gravedad);

      // Color según gravedad
      String bgColor = '#FFFFFF';
      if (gravedad == 'CRÍTICA') bgColor = '#FFE8E8';
      else if (gravedad == 'ALTA') bgColor = '#FFF2CC';
      else bgColor = fila % 2 == 0 ? '#F2F2F2' : '#FFFFFF';
      
      final xlsio.Range rangoFila = sheet.getRangeByIndex(fila, 1, fila, 4);
      rangoFila.cellStyle.backColor = bgColor;
      rangoFila.cellStyle.borders.all.lineStyle = xlsio.LineStyle.thin;

      fila++;
    }
    
    filaGraficaFin = fila;
    columnaGraficaFin = 2;

    // Fila de total
    sheet.getRangeByIndex(fila, 1).setText('TOTAL');
    sheet.getRangeByIndex(fila, 2).setNumber(total.toDouble());
    sheet.getRangeByIndex(fila, 3).setText('100%');
    sheet.getRangeByIndex(fila, 4).setText('Suma de todos los daños');

    final xlsio.Range rangoTotal = sheet.getRangeByIndex(fila, 1, fila, 4);
    rangoTotal.cellStyle.bold = true;
    rangoTotal.cellStyle.backColor = '#D9E2F3';
    rangoTotal.cellStyle.borders.all.lineStyle = xlsio.LineStyle.thin;

    return {
      'filaFinal': fila,
      'filaGraficaInicio': filaGraficaInicio,
      'filaGraficaFin': filaGraficaFin,
      'columnaGraficaInicio': columnaGraficaInicio,
      'columnaGraficaFin': columnaGraficaFin,
    };
  }

  /// Crea tabla de nivel de daño con características específicas
  Map<String, int> _crearTablaNivelDano(
      xlsio.Worksheet sheet,
      int filaInicial,
      List<MapEntry<String, dynamic>> datos,
      int total,
      Map<String, Map<String, String>> accionesPorNivel) {
    int fila = filaInicial;
    
    // Rango para gráfica
    int filaGraficaInicio = 0;
    int filaGraficaFin = 0;
    int columnaGraficaInicio = 0;
    int columnaGraficaFin = 0;

    // Encabezados específicos para nivel de daño
    sheet.getRangeByIndex(fila, 1).setText('Nivel de Daño');
    sheet.getRangeByIndex(fila, 2).setText('Cantidad');
    sheet.getRangeByIndex(fila, 3).setText('Porcentaje');
    sheet.getRangeByIndex(fila, 4, fila, 5).merge();
    sheet.getRangeByIndex(fila, 4).setText('Tiempo de Respuesta');
    sheet.getRangeByIndex(fila, 6).setText('Acción Requerida');
    filaGraficaInicio = fila;
    columnaGraficaInicio = 1;

    final xlsio.Range rangoHeader = sheet.getRangeByIndex(fila, 1, fila, 6);
    rangoHeader.cellStyle.bold = true;
    rangoHeader.cellStyle.backColor = '#FFB3B3';
    rangoHeader.cellStyle.fontColor = '#FFFFFF';
    rangoHeader.cellStyle.borders.all.lineStyle = xlsio.LineStyle.thin;
    fila++;

    // Datos
    for (int i = 0; i < datos.length; i++) {
      var entry = datos[i];
      String nivel = entry.key;
      int conteo = entry.value['conteo'];
      double porcentaje = total > 0 ? (conteo / total) * 100 : 0;
      
      Map<String, String> info = accionesPorNivel[nivel] ?? {
        'urgencia': 'EVALUAR',
        'accion': 'Consultar especialista técnico'
      };

      sheet.getRangeByIndex(fila, 1).setText(nivel);
      sheet.getRangeByIndex(fila, 2).setNumber(conteo.toDouble());
      sheet.getRangeByIndex(fila, 3).setText('${porcentaje.toStringAsFixed(1)}%');
      sheet.getRangeByIndex(fila, 4, fila, 5).merge();
      sheet.getRangeByIndex(fila, 4).setText(info['urgencia']!);
      sheet.getRangeByIndex(fila, 6).setText(info['accion']!);
      sheet.getRangeByIndex(fila, 6).cellStyle.wrapText = true;

      // Color según severidad del daño
      String bgColor = '#FFFFFF';
      if (nivel.contains('Colapso')) bgColor = '#FFE8E8';
      else if (nivel.contains('severo')) bgColor = '#FFF2CC';
      else if (nivel.contains('medio')) bgColor = '#FFF9E6';
      else if (nivel.contains('ligero')) bgColor = '#F0F8FF';
      else bgColor = '#E8F5E8'; // Sin daño aparente
      
      final xlsio.Range rangoFila = sheet.getRangeByIndex(fila, 1, fila, 6);
      rangoFila.cellStyle.backColor = bgColor;
      rangoFila.cellStyle.borders.all.lineStyle = xlsio.LineStyle.thin;

      fila++;
    }
    
    filaGraficaFin = fila;
    columnaGraficaFin = 2;

    // Fila de total
    sheet.getRangeByIndex(fila, 1).setText('TOTAL');
    sheet.getRangeByIndex(fila, 2).setNumber(total.toDouble());
    sheet.getRangeByIndex(fila, 3).setText('100%');
    sheet.getRangeByIndex(fila, 4, fila, 5).merge();
    sheet.getRangeByIndex(fila, 4).setText('TODOS LOS NIVELES');
    sheet.getRangeByIndex(fila, 6).setText('Plan integral de evaluación');

    final xlsio.Range rangoTotal = sheet.getRangeByIndex(fila, 1, fila, 6);
    rangoTotal.cellStyle.bold = true;
    rangoTotal.cellStyle.backColor = '#E2EFDA';
    rangoTotal.cellStyle.borders.all.lineStyle = xlsio.LineStyle.thin;

    return {
      'filaFinal': fila,
      'filaGraficaInicio': filaGraficaInicio,
      'filaGraficaFin': filaGraficaFin,
      'columnaGraficaInicio': columnaGraficaInicio,
      'columnaGraficaFin': columnaGraficaFin,
    };
  }

  /// Crea un gráfico de barras específico para daños (igual estructura que uso/topografía)
  Future<int> _crearGraficoBarras(
    Worksheet sheet,
    int filaInicial,
    Map<String, int> posicionesGraficos,
    String titulo,
    String etiquetaEjeX,
    String etiquetaEjeY,
  ) async {
    try {
      // Si no hay ninguna colección, créala
      sheet.charts ??= ChartCollection(sheet);
      // Ahora charts nunca será null
      final ChartCollection charts = sheet.charts as ChartCollection;
      // Añade un nuevo gráfico
      final Chart chart = charts.add();

      // Configura el gráfico específico para daños
      chart.chartType = ExcelChartType.bar;
      chart.topRow = filaInicial;
      chart.leftColumn = 1;
      chart.bottomRow = filaInicial + 15;
      chart.rightColumn = 6;

      chart.dataRange = sheet.getRangeByIndex(
        posicionesGraficos['filaGraficaInicio']!,
        posicionesGraficos['columnaGraficaInicio']!,
        posicionesGraficos['filaGraficaFin']! - 1,
        posicionesGraficos['columnaGraficaFin']!,
      );

      chart.chartTitle = titulo;
      chart.chartTitleArea.bold = true;
      chart.chartTitleArea.size = 12;

      final serie = chart.series[0];
      serie.dataLabels
        ..isValue = true
        ..textArea.bold = false
        ..textArea.size = 10
        ..textArea.fontName = 'Arial';

      chart.legend!.position = ExcelLegendPosition.bottom;
      chart.linePattern = ExcelChartLinePattern.dashDot;
      chart.linePatternColor = "#8B0000"; // Rojo más oscuro para daños
      chart.plotArea.linePattern = ExcelChartLinePattern.dashDot;
      chart.plotArea.linePatternColor = '#FF0000'; // Rojo para daños

      return filaInicial + 16;
    } catch (e) {
      print('⚠️ [EXCEL-DAÑOS-V2] Error al crear gráfico: $e');
      sheet.getRangeByIndex(filaInicial, 1).setText('Gráfico no disponible');
      return filaInicial + 1;
    }
  }

  /// Encuentra el nivel crítico predominante en las estadísticas de daños
  String _encontrarNivelCritico(Map<String, dynamic> estadisticasNivel) {
    if (estadisticasNivel.isEmpty) return 'No determinado';

    String nivelCritico = 'No determinado';
    int maxConteo = 0;

    // Priorizar niveles críticos
    final prioridad = [
      'Colapso total',
      'Daño severo',
      'Daño medio',
      'Daño ligero',
      'Sin daño aparente'
    ];

    for (String nivel in prioridad) {
      if (estadisticasNivel.containsKey(nivel)) {
        int conteo = estadisticasNivel[nivel]['conteo'] ?? 0;
        if (conteo > 0) {
          return nivel; // Retornar el primer nivel crítico encontrado
        }
      }
    }

    // Si no hay niveles críticos, buscar el más común
    estadisticasNivel.forEach((key, value) {
      int conteo = value['conteo'] ?? 0;
      if (conteo > maxConteo) {
        maxConteo = conteo;
        nivelCritico = key;
      }
    });

    return nivelCritico;
  }

  /// Encuentra el elemento predominante en las estadísticas (igual que uso/topografía)
  String _encontrarPredominante(Map<String, dynamic> estadisticas) {
    if (estadisticas.isEmpty) return 'No determinado';

    String predominante = 'No determinado';
    int maxConteo = 0;

    estadisticas.forEach((key, value) {
      int conteo = value['conteo'] ?? 0;
      if (conteo > maxConteo) {
        maxConteo = conteo;
        predominante = key;
      }
    });

    return predominante;
  }

  /// Guarda el archivo Excel en el sistema (igual que uso/topografía)
  Future<String> _guardarArchivo(
    xlsio.Workbook workbook,
    String titulo,
    Directory? directorio,
  ) async {
    try {
      // Obtener directorio de destino
      final directorioFinal =
          directorio ?? await _fileService.obtenerDirectorioDescargas();

      // Crear subdirectorio para reportes Excel
      final directorioReportes =
          Directory('${directorioFinal.path}/cenapp/reportes_excel');
      if (!await directorioReportes.exists()) {
        await directorioReportes.create(recursive: true);
      }

      // Generar nombre de archivo único específico para daños
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final nombreLimpio = _limpiarNombreArchivo(titulo);
      final nombreArchivo = 'evaluacion_danos_${nombreLimpio}_${timestamp}.xlsx';
      final rutaCompleta = '${directorioReportes.path}/$nombreArchivo';

      // Guardar el workbook
      final List<int> bytes = workbook.saveAsStream();
      final File archivo = File(rutaCompleta);
      await archivo.writeAsBytes(bytes);

      // Verificar que el archivo se guardó correctamente
      if (await archivo.exists() && await archivo.length() > 0) {
        print(
            '✅ [EXCEL-DAÑOS-V2] Archivo guardado: $rutaCompleta (${await archivo.length()} bytes)');
        return rutaCompleta;
      } else {
        throw Exception('El archivo no se guardó correctamente');
      }
    } catch (e) {
      print('❌ [EXCEL-DAÑOS-V2] Error al guardar archivo: $e');
      throw Exception('Error al guardar archivo Excel: $e');
    }
  }

  /// Limpia el nombre del archivo para el sistema (igual que uso/topografía)
  String _limpiarNombreArchivo(String nombre) {
    return nombre
        .toLowerCase()
        .replaceAll(' ', '_')
        .replaceAll(RegExp(r'[^a-z0-9_]'), '')
        .replaceAll(RegExp(r'_+'), '_')
        .trim();
  }

  // === MÉTODOS ADICIONALES DE UTILIDAD ESPECÍFICOS PARA DAÑOS ===

  /// Aplica formato condicional a un rango específico para niveles de riesgo
  void _aplicarFormatoCondicionalRiesgos(
    xlsio.Worksheet sheet,
    int filaInicio,
    int columnaInicio,
    int filaFin,
    int columnaFin,
    double valorLimiteAlto,
    double valorLimiteMedio,
  ) {
    final xlsio.Range rango =
        sheet.getRangeByIndex(filaInicio, columnaInicio, filaFin, columnaFin);

    // Crear formato condicional para riesgo alto
    final xlsio.ConditionalFormats formats = rango.conditionalFormats;
    final xlsio.ConditionalFormat formatAlto = formats.addCondition();

    // Condición para riesgo alto
    formatAlto.formatType = ExcelCFType.cellValue;
    formatAlto.operator = ExcelComparisonOperator.greater;
    formatAlto.firstFormula = valorLimiteAlto.toString();
    formatAlto.backColor = '#FFE8E8'; // Rojo claro

    // Condición para riesgo medio
    final xlsio.ConditionalFormat formatMedio = formats.addCondition();
    formatMedio.formatType = ExcelCFType.cellValue;
    formatMedio.operator = ExcelComparisonOperator.between;
    formatMedio.firstFormula = valorLimiteMedio.toString();
    formatMedio.secondFormula = valorLimiteAlto.toString();
    formatMedio.backColor = '#FFF2CC'; // Amarillo claro
  }

  /// Crea un resumen visual con iconos específicos para daños
  Future<void> _crearResumenVisualDanos(
    xlsio.Worksheet sheet,
    int filaInicial,
    Map<String, dynamic> estadisticas,
  ) async {
    int fila = filaInicial;

    // Título
    final xlsio.Range rangoTitulo = sheet.getRangeByIndex(fila, 1, fila, 4);
    rangoTitulo.merge();
    rangoTitulo.setText('RESUMEN VISUAL DE RIESGOS');
    rangoTitulo.cellStyle.bold = true;
    rangoTitulo.cellStyle.fontSize = 12;
    rangoTitulo.cellStyle.backColor = '#C5504B';
    rangoTitulo.cellStyle.fontColor = '#FFFFFF';
    fila++;

    // Indicadores específicos para daños con formato visual
    final List<Map<String, dynamic>> indicadoresDanos = [
      {
        'titulo': 'Riesgo Crítico',
        'valor': estadisticas['resumenRiesgos']?['riesgoAlto'] ?? 0,
        'icono': '⚠️',
        'color': '#FF6B6B'
      },
      {
        'titulo': 'Daño Severo',
        'valor': estadisticas['estadisticas']?['nivelDano']?['Daño severo']?['conteo'] ?? 0,
        'icono': '🏚️',
        'color': '#FF9F43'
      },
      {
        'titulo': 'Problemas Geotécnicos',
        'valor': _contarProblemasGeotecnicos(estadisticas['estadisticas']?['geotecnicos'] ?? {}),
        'icono': '🌍',
        'color': '#FFA502'
      },
    ];

    // Crear tarjetas visuales específicas para daños
    for (int i = 0; i < indicadoresDanos.length; i++) {
      var indicador = indicadoresDanos[i];
      int col = 1 + (i * 2);

      // Icono y título
      sheet.getRangeByIndex(fila, col).setText(indicador['icono']);
      sheet.getRangeByIndex(fila, col).cellStyle.fontSize = 20;
      sheet.getRangeByIndex(fila, col + 1).setText(indicador['titulo']);
      sheet.getRangeByIndex(fila, col + 1).cellStyle.bold = true;

      // Valor
      sheet.getRangeByIndex(fila + 1, col, fila + 1, col + 1).merge();
      sheet
          .getRangeByIndex(fila + 1, col)
          .setText(indicador['valor'].toString());
      sheet.getRangeByIndex(fila + 1, col).cellStyle.fontSize = 14;
      sheet.getRangeByIndex(fila + 1, col).cellStyle.bold = true;

      // Aplicar color de fondo específico para daños
      final xlsio.Range rangoTarjeta =
          sheet.getRangeByIndex(fila, col, fila + 1, col + 1);
      rangoTarjeta.cellStyle.backColor = indicador['color'];
      rangoTarjeta.cellStyle.fontColor = '#FFFFFF';
      rangoTarjeta.cellStyle.borders.all.lineStyle = xlsio.LineStyle.thin;
    }
  }

  /// Cuenta problemas geotécnicos totales
  int _contarProblemasGeotecnicos(Map<String, dynamic> geotecnicos) {
    int totalProblemas = 0;
    geotecnicos.forEach((key, value) {
      totalProblemas += value['conteo'] as int? ?? 0;
    });
    return totalProblemas;
  }

  /// Valida los datos específicos para daños antes de procesarlos
  bool _validarDatosDanos(Map<String, dynamic> datos) {
    // Verificar estructura básica para evaluación de daños
    if (!datos.containsKey('estadisticas') ||
        !datos.containsKey('resumenRiesgos')) {
      print('⚠️ [EXCEL-DAÑOS-V2] Estructura de datos incompleta');
      return false;
    }

    // Verificar que hay estadísticas de daños
    if (datos['estadisticas'] == null ||
        (datos['estadisticas']['geotecnicos'] == null &&
         datos['estadisticas']['nivelDano'] == null)) {
      print('⚠️ [EXCEL-DAÑOS-V2] No hay estadísticas de daños disponibles');
      return false;
    }

    return true;
  }
}