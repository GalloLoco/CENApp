// lib/data/reportes/resumen_completo_excel.dart

import 'dart:io';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xlsio;
import 'package:syncfusion_officechart/officechart.dart';

import 'package:syncfusion_flutter_xlsio/xlsio.dart'; // Para ExcelCFType
import 'package:intl/intl.dart';
import '../services/file_storage_service.dart';

/// Servicio optimizado para generar reportes Excel completos consolidados usando Syncfusion
/// Combina todos los análisis existentes en un solo documento integral:
/// 1. Resumen General (distribución geográfica y temporal)
/// 2. Uso de Vivienda y Topografía
/// 3. Material Dominante de Construcción
/// 4. Sistema Estructural
/// 5. Evaluación de Daños
///
/// Reutiliza métodos y estructuras de los archivos base para máxima eficiencia
class ExcelReporteCompletoConsolidadoV2 {
  final FileStorageService _fileService = FileStorageService();

  // Constantes para estilos y formato - Unificadas para consistencia
  static const String FONT_NAME = 'Calibri';
  static const int HEADER_FONT_SIZE = 18; // Ligeramente más grande para reporte completo
  static const int SUBTITLE_FONT_SIZE = 16;
  static const int SECTION_FONT_SIZE = 14; // Más prominente para secciones principales
  static const int SUBSECTION_FONT_SIZE = 12;
  static const int NORMAL_FONT_SIZE = 10;

  // Paleta de colores diferenciada por sección para mejor organización visual
  static const String COLOR_HEADER = '#1B4F72'; // Azul marino principal
  static const String COLOR_SUBTITLE = '#2E86AB';

  // Colores por sección para diferenciación visual
  static const String COLOR_RESUMEN_GENERAL = '#70AD47'; // Verde
  static const String COLOR_USO_TOPOGRAFIA = '#9BC2E6'; // Azul claro
  static const String COLOR_MATERIAL_DOMINANTE = '#FFC000'; // Amarillo/Naranja
  static const String COLOR_SISTEMA_ESTRUCTURAL = '#4472C4'; // Azul estructural
  static const String COLOR_EVALUACION_DANOS = '#FF6B6B'; // Rojo para riesgos

  /// Genera reporte completo consolidado que incluye todos los análisis
  /// Optimizado para reutilizar código y mantener consistencia visual
  Future<String> generarReporteCompletoConsolidado({
    required String titulo,
    required String subtitulo,
    required Map<String, dynamic> datosCompletos,
    required List<Map<String, dynamic>> tablas,
    required Map<String, dynamic> metadatos,
    Directory? directorio,
  }) async {
    try {
      print('📊 [EXCEL-COMPLETO-V2] Iniciando generación consolidada: $titulo');

      // Crear nuevo libro de Excel con múltiples hojas
      final xlsio.Workbook workbook = xlsio.Workbook();

      // === HOJA 1: RESUMEN EJECUTIVO ===
      final xlsio.Worksheet sheetResumen = workbook.worksheets[0];
      sheetResumen.name = 'Resumen Ejecutivo';
      await _crearHojaResumenEjecutivo(
          sheetResumen, titulo, subtitulo, datosCompletos, metadatos);

      // === HOJA 2: RESUMEN GENERAL ===
      final xlsio.Worksheet sheetGeneral = workbook.worksheets.add();
      sheetGeneral.name = 'Resumen General';
      await _crearHojaResumenGeneral(sheetGeneral, datosCompletos, metadatos);

      // === HOJA 3: USO Y TOPOGRAFÍA ===
      final xlsio.Worksheet sheetUsoTopo = workbook.worksheets.add();
      sheetUsoTopo.name = 'Uso y Topografía';
      await _crearHojaUsoTopografia(sheetUsoTopo, datosCompletos, metadatos);

      // === HOJA 4: MATERIAL DOMINANTE ===
      final xlsio.Worksheet sheetMaterial = workbook.worksheets.add();
      sheetMaterial.name = 'Material Dominante';
      await _crearHojaMaterialDominante(sheetMaterial, datosCompletos, metadatos);

      // === HOJA 5: SISTEMA ESTRUCTURAL ===
      final xlsio.Worksheet sheetEstructural = workbook.worksheets.add();
      sheetEstructural.name = 'Sistema Estructural';
      await _crearHojaSistemaEstructural(sheetEstructural, datosCompletos, metadatos);

      // === HOJA 6: EVALUACIÓN DE DAÑOS ===
      final xlsio.Worksheet sheetDanos = workbook.worksheets.add();
      sheetDanos.name = 'Evaluación Daños';
      await _crearHojaEvaluacionDanos(sheetDanos, datosCompletos, metadatos);

      // Guardar archivo
      final String rutaArchivo = await _guardarArchivo(workbook, titulo, directorio);

      // Liberar recursos
      workbook.dispose();

      print('✅ [EXCEL-COMPLETO-V2] Reporte consolidado generado exitosamente: $rutaArchivo');
      return rutaArchivo;
    } catch (e) {
      print('❌ [EXCEL-COMPLETO-V2] Error al generar reporte consolidado: $e');
      throw Exception('Error al generar reporte Excel completo: $e');
    }
  }

  // ============================================================================
  // HOJA 1: RESUMEN EJECUTIVO
  // ============================================================================

  /// Crea la hoja de resumen ejecutivo con indicadores clave de todos los análisis
  Future<void> _crearHojaResumenEjecutivo(
    xlsio.Worksheet sheet,
    String titulo,
    String subtitulo,
    Map<String, dynamic> datosCompletos,
    Map<String, dynamic> metadatos,
  ) async {
    _configurarAnchoColumnas(sheet);
    int fila = 1;

    // Encabezado principal
    fila = _crearEncabezadoPrincipal(sheet, titulo, subtitulo, metadatos, fila);
    fila += 2;

    // Dashboard visual con métricas clave
    fila = await _crearDashboardEjecutivo(sheet, datosCompletos, metadatos, fila);
    fila += 2;

    // Resumen por secciones
    fila = _crearResumenPorSecciones(sheet, datosCompletos, metadatos, fila);
    fila += 2;

    // Conclusiones y recomendaciones principales
    _crearConclusionesEjecutivas(sheet, datosCompletos, metadatos, fila);
  }

  /// Crea dashboard visual con métricas clave de todos los análisis
  Future<int> _crearDashboardEjecutivo(
    xlsio.Worksheet sheet,
    Map<String, dynamic> datosCompletos,
    Map<String, dynamic> metadatos,
    int filaInicial,
  ) async {
    int fila = filaInicial;

    // Título del dashboard
    _aplicarEstiloSeccion(sheet, fila, 'DASHBOARD EJECUTIVO', COLOR_HEADER);
    fila++;

    // Extraer métricas clave de cada sección - CORREGIDO con rutas apropiadas
    final int totalFormatos = metadatos['totalFormatos'] ?? 0;

    // Métricas de resumen general - CORREGIDO
    final ciudadesCubiertas = datosCompletos['resumenGeneral']?['distribucionGeografica']?['ciudades']?.length ?? 0;

    // Métricas de uso y topografía - CORREGIDO
    final usosPredominantes = _contarElementosConDatos(
        datosCompletos['usoTopografia']?['usosVivienda']?['estadisticas'] ?? {});

    // Métricas de material dominante - CORREGIDO
    final materialesDominantes = _contarMateriales(datosCompletos['materialDominante']?['conteoMateriales'] ?? {});

    // Métricas de riesgos - CORREGIDO
    final riesgoAlto = datosCompletos['evaluacionDanos']?['resumenRiesgos']?['riesgoAlto'] ?? 0;
    final riesgoMedio = datosCompletos['evaluacionDanos']?['resumenRiesgos']?['riesgoMedio'] ?? 0;

    // Crear tarjetas de métricas en formato grid
    final List<Map<String, dynamic>> metricasClave = [
      {
        'titulo': 'Total Evaluaciones',
        'valor': '$totalFormatos',
        'subtitulo': 'Inmuebles analizados',
        'color': COLOR_RESUMEN_GENERAL,
        'icono': '📊'
      },
      {
        'titulo': 'Cobertura Geográfica',
        'valor': '$ciudadesCubiertas',
        'subtitulo': 'Ciudades evaluadas',
        'color': COLOR_RESUMEN_GENERAL,
        'icono': '🗺️'
      },
      {
        'titulo': 'Diversidad de Uso',
        'valor': '$usosPredominantes',
        'subtitulo': 'Tipos identificados',
        'color': COLOR_USO_TOPOGRAFIA,
        'icono': '🏠'
      },
      {
        'titulo': 'Tipos de Material',
        'valor': '$materialesDominantes',
        'subtitulo': 'Materiales analizados',
        'color': COLOR_MATERIAL_DOMINANTE,
        'icono': '🧱'
      },
      {
        'titulo': 'Riesgo Alto',
        'valor': '$riesgoAlto',
        'subtitulo': '${totalFormatos > 0 ? (riesgoAlto / totalFormatos * 100).toStringAsFixed(1) : 0}% del total',
        'color': COLOR_EVALUACION_DANOS,
        'icono': '⚠️'
      },
      {
        'titulo': 'Riesgo Medio',
        'valor': '$riesgoMedio',
        'subtitulo': '${totalFormatos > 0 ? (riesgoMedio / totalFormatos * 100).toStringAsFixed(1) : 0}% del total',
        'color': COLOR_EVALUACION_DANOS,
        'icono': '⚡'
      },
    ];

    // Crear grid de métricas (3x2)
    for (int i = 0; i < metricasClave.length; i += 3) {
      for (int j = 0; j < 3 && (i + j) < metricasClave.length; j++) {
        final metrica = metricasClave[i + j];
        int col = 1 + (j * 2);

        _crearTarjetaMetrica(sheet, fila, col, metrica);
      }
      fila += 3; // Espacio para cada fila de tarjetas
    }

    return fila;
  }

  /// Crea una tarjeta de métrica individual
  void _crearTarjetaMetrica(
    xlsio.Worksheet sheet,
    int fila,
    int col,
    Map<String, dynamic> metrica,
  ) {
    // Fondo de la tarjeta (2 columnas x 2 filas)
    final xlsio.Range rangoTarjeta = sheet.getRangeByIndex(fila, col, fila + 1, col + 1);
    rangoTarjeta.cellStyle.backColor = metrica['color'];
    rangoTarjeta.cellStyle.borders.all.lineStyle = xlsio.LineStyle.medium;
    rangoTarjeta.cellStyle.borders.all.color = '#FFFFFF';

    // Icono y título
    sheet.getRangeByIndex(fila, col).setText('${metrica['icono']} ${metrica['titulo']}');
    sheet.getRangeByIndex(fila, col).cellStyle.fontSize = 11;
    sheet.getRangeByIndex(fila, col).cellStyle.fontColor = '#FFFFFF';
    sheet.getRangeByIndex(fila, col).cellStyle.bold = true;

    // Valor principal
    sheet.getRangeByIndex(fila, col + 1).setText(metrica['valor']);
    sheet.getRangeByIndex(fila, col + 1).cellStyle.fontSize = 16;
    sheet.getRangeByIndex(fila, col + 1).cellStyle.fontColor = '#FFFFFF';
    sheet.getRangeByIndex(fila, col + 1).cellStyle.bold = true;
    sheet.getRangeByIndex(fila, col + 1).cellStyle.hAlign = xlsio.HAlignType.center;

    // Subtítulo
    final xlsio.Range rangoSubtitulo = sheet.getRangeByIndex(fila + 1, col, fila + 1, col + 1);
    rangoSubtitulo.merge();
    rangoSubtitulo.setText(metrica['subtitulo']);
    rangoSubtitulo.cellStyle.fontSize = 9;
    rangoSubtitulo.cellStyle.fontColor = '#FFFFFF';
    rangoSubtitulo.cellStyle.hAlign = xlsio.HAlignType.center;
  }

  // ============================================================================
  // HOJA 2: RESUMEN GENERAL (Reutiliza lógica de resumen_general_excel.dart)
  // ============================================================================

  /// Crea la hoja de resumen general con distribución geográfica y temporal
  Future<void> _crearHojaResumenGeneral(
    xlsio.Worksheet sheet,
    Map<String, dynamic> datosCompletos,
    Map<String, dynamic> metadatos,
  ) async {
    _configurarAnchoColumnas(sheet);
    int fila = 1;

    // Encabezado de sección
    fila = _crearEncabezadoSeccion(sheet, 'RESUMEN GENERAL',
        'Distribución Geográfica y Temporal de Evaluaciones', metadatos, fila);
    fila += 2;

    // Filtros aplicados
    fila = _crearSeccionFiltros(sheet, metadatos, fila);
    fila += 2;

    // Resumen estadístico para resumen general
    fila = _crearResumenEstadisticoGeneral(sheet, datosCompletos, metadatos, fila);
    fila += 2;

    // Análisis distribución geográfica con gráfico
    fila = await _crearAnalisisDistribucionGeografica(sheet, datosCompletos, fila);
    fila += 2;

    // Análisis distribución temporal con gráfico
    fila = await _crearAnalisisDistribucionTemporal(sheet, datosCompletos, fila);
  }

  // ============================================================================
  // HOJA 3: USO Y TOPOGRAFÍA (Reutiliza lógica de usovivienda_topografico_excel.dart)
  // ============================================================================

  /// Crea la hoja de uso de vivienda y topografía
  Future<void> _crearHojaUsoTopografia(
    xlsio.Worksheet sheet,
    Map<String, dynamic> datosCompletos,
    Map<String, dynamic> metadatos,
  ) async {
    _configurarAnchoColumnas(sheet);
    int fila = 1;

    // Encabezado de sección
    fila = _crearEncabezadoSeccion(
        sheet,
        'USO DE VIVIENDA Y TOPOGRAFÍA',
        'Análisis de Patrones de Uso y Características Topográficas',
        metadatos,
        fila);
    fila += 2;

    // Resumen estadístico específico
    fila = _crearResumenEstadisticoUsoTopografia(sheet, datosCompletos, metadatos, fila);
    fila += 2;

    // Análisis uso de vivienda con gráfico
    fila = await _crearAnalisisUsoVivienda(sheet, datosCompletos, fila);
    fila += 2;

    // Análisis topografía con gráfico
    fila = await _crearAnalisisTopografia(sheet, datosCompletos, fila);
  }

  // ============================================================================
  // HOJA 4: MATERIAL DOMINANTE (Reutiliza lógica de material_dominante_excel.dart)
  // ============================================================================

  /// Crea la hoja de material dominante de construcción
  Future<void> _crearHojaMaterialDominante(
    xlsio.Worksheet sheet,
    Map<String, dynamic> datosCompletos,
    Map<String, dynamic> metadatos,
  ) async {
    _configurarAnchoColumnas(sheet);
    int fila = 1;

    // Encabezado de sección
    fila = _crearEncabezadoSeccion(
        sheet,
        'MATERIAL DOMINANTE DE CONSTRUCCIÓN',
        'Análisis de Materiales Predominantes y Resistencia Estructural',
        metadatos,
        fila);
    fila += 2;

    // Resumen estadístico específico
    fila = _crearResumenEstadisticoMaterial(sheet, datosCompletos, metadatos, fila);
    fila += 2;

    // Análisis material dominante con gráfico
    fila = await _crearAnalisisMaterialDominante(sheet, datosCompletos, fila);
    fila += 2;

    // Análisis resistencia estructural con gráfico
    fila = await _crearAnalisisResistenciaEstructural(sheet, datosCompletos, fila);
  }

  // ============================================================================
  // HOJA 5: SISTEMA ESTRUCTURAL (Reutiliza lógica de sistema_estructural_reporte_excel.dart)
  // ============================================================================

  /// Crea la hoja de sistema estructural
  Future<void> _crearHojaSistemaEstructural(
    xlsio.Worksheet sheet,
    Map<String, dynamic> datosCompletos,
    Map<String, dynamic> metadatos,
  ) async {
    _configurarAnchoColumnas(sheet);
    int fila = 1;

    // Encabezado de sección
    fila = _crearEncabezadoSeccion(
        sheet,
        'SISTEMA ESTRUCTURAL',
        'Análisis de Elementos Estructurales y Configuraciones',
        metadatos,
        fila);
    fila += 2;

    // Resumen estadístico específico
    fila = _crearResumenEstadisticoEstructural(sheet, datosCompletos, metadatos, fila);
    fila += 2;

    // Análisis dirección X con gráfico
    fila = await _crearAnalisisDireccionX(sheet, datosCompletos, fila);
    fila += 2;

    // Análisis dirección Y con gráfico
    fila = await _crearAnalisisDireccionY(sheet, datosCompletos, fila);
    fila += 2;

    // Análisis muros de mampostería con gráfico
    fila = await _crearAnalisisMurosMamposteria(sheet, datosCompletos, fila);
  }

  // ============================================================================
  // HOJA 6: EVALUACIÓN DE DAÑOS (Reutiliza lógica de evaluacion_danos_excel.dart)
  // ============================================================================

  /// Crea la hoja de evaluación de daños
  Future<void> _crearHojaEvaluacionDanos(
    xlsio.Worksheet sheet,
    Map<String, dynamic> datosCompletos,
    Map<String, dynamic> metadatos,
  ) async {
    _configurarAnchoColumnas(sheet);
    int fila = 1;

    // Encabezado de sección
    fila = _crearEncabezadoSeccion(sheet, 'EVALUACIÓN DE DAÑOS',
        'Análisis de Riesgos y Daños Estructurales', metadatos, fila);
    fila += 2;

    // Resumen estadístico específico
    fila = _crearResumenEstadisticoDanos(sheet, datosCompletos, metadatos, fila);
    fila += 2;

    // Análisis daños geotécnicos con gráfico
    fila = await _crearAnalisisDanosGeotecnicos(sheet, datosCompletos, fila);
    fila += 2;

    // Análisis nivel de daño con gráfico
    fila = await _crearAnalisisNivelDano(sheet, datosCompletos, fila);
  }

  // ============================================================================
  // MÉTODOS AUXILIARES REUTILIZABLES
  // ============================================================================

  /// Configura anchos de columna estándar para todas las hojas
  void _configurarAnchoColumnas(xlsio.Worksheet sheet) {
    sheet.getRangeByIndex(1, 1, 100, 1).columnWidth = 30; // Columna A
    sheet.getRangeByIndex(1, 2, 100, 2).columnWidth = 15; // Columna B
    sheet.getRangeByIndex(1, 3, 100, 3).columnWidth = 15; // Columna C
    sheet.getRangeByIndex(1, 4, 100, 4).columnWidth = 25; // Columna D
    sheet.getRangeByIndex(1, 5, 100, 5).columnWidth = 20; // Columna E
    sheet.getRangeByIndex(1, 6, 100, 6).columnWidth = 20; // Columna F
  }

  /// Crea encabezado principal del reporte completo
  int _crearEncabezadoPrincipal(
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

  /// Crea encabezado de sección específica
  int _crearEncabezadoSeccion(
    xlsio.Worksheet sheet,
    String tituloSeccion,
    String descripcion,
    Map<String, dynamic> metadatos,
    int filaInicial,
  ) {
    int fila = filaInicial;

    // Título de sección
    final xlsio.Range rangoTitulo = sheet.getRangeByIndex(fila, 1, fila, 6);
    rangoTitulo.merge();
    rangoTitulo.setText(tituloSeccion);
    rangoTitulo.cellStyle.fontSize = SECTION_FONT_SIZE.toDouble();
    rangoTitulo.cellStyle.fontName = FONT_NAME;
    rangoTitulo.cellStyle.bold = true;
    rangoTitulo.cellStyle.hAlign = xlsio.HAlignType.center;
    rangoTitulo.cellStyle.backColor = _obtenerColorSeccion(tituloSeccion);
    rangoTitulo.cellStyle.fontColor = '#FFFFFF';
    fila++;

    // Descripción
    final xlsio.Range rangoDescripcion = sheet.getRangeByIndex(fila, 1, fila, 6);
    rangoDescripcion.merge();
    rangoDescripcion.setText(descripcion);
    rangoDescripcion.cellStyle.fontSize = NORMAL_FONT_SIZE.toDouble();
    rangoDescripcion.cellStyle.fontName = FONT_NAME;
    rangoDescripcion.cellStyle.hAlign = xlsio.HAlignType.center;
    rangoDescripcion.cellStyle.backColor = '#F8F9FA';

    return fila;
  }

  /// Obtiene el color específico para cada sección
  String _obtenerColorSeccion(String tituloSeccion) {
    if (tituloSeccion.contains('RESUMEN GENERAL')) return COLOR_RESUMEN_GENERAL;
    if (tituloSeccion.contains('USO') || tituloSeccion.contains('TOPOGRAFÍA'))
      return COLOR_USO_TOPOGRAFIA;
    if (tituloSeccion.contains('MATERIAL')) return COLOR_MATERIAL_DOMINANTE;
    if (tituloSeccion.contains('ESTRUCTURAL')) return COLOR_SISTEMA_ESTRUCTURAL;
    if (tituloSeccion.contains('DAÑOS') || tituloSeccion.contains('EVALUACIÓN'))
      return COLOR_EVALUACION_DANOS;
    return COLOR_HEADER; // Por defecto
  }

  /// Aplica estilo de sección con color personalizable
  void _aplicarEstiloSeccion(xlsio.Worksheet sheet, int fila, String titulo, String color) {
    final xlsio.Range rango = sheet.getRangeByIndex(fila, 1, fila, 6);
    rango.merge();
    rango.setText(titulo);
    rango.cellStyle.fontSize = SUBSECTION_FONT_SIZE.toDouble();
    rango.cellStyle.fontName = FONT_NAME;
    rango.cellStyle.bold = true;
    rango.cellStyle.hAlign = xlsio.HAlignType.left;
    rango.cellStyle.backColor = color;
    rango.cellStyle.fontColor = '#FFFFFF';
    rango.cellStyle.borders.all.lineStyle = xlsio.LineStyle.thin;
  }

  /// Cuenta elementos con datos para métricas
  int _contarElementosConDatos(Map<String, dynamic> estadisticas) {
    if (estadisticas.isEmpty) return 0;
    return estadisticas.values.where((stats) {
      if (stats is Map && stats.containsKey('conteo')) {
        return (stats['conteo'] as int? ?? 0) > 0;
      }
      return false;
    }).length;
  }

  // ============================================================================
  // MÉTODOS ESPECÍFICOS PARA CADA ANÁLISIS (simplificados para reutilización)
  // ============================================================================

  /// Crea sección de filtros aplicados (común para todas las hojas)
  int _crearSeccionFiltros(
    xlsio.Worksheet sheet,
    Map<String, dynamic> metadatos,
    int filaInicial,
  ) {
    int fila = filaInicial;

    _aplicarEstiloSeccion(sheet, fila, 'FILTROS APLICADOS', '#6C757D');
    fila++;

    final List<List<String>> filtros = [
      ['Nombre inmueble:', metadatos['nombreInmueble'] ?? 'Todos'],
      ['Período:', '${metadatos['fechaInicio']} - ${metadatos['fechaFin']}'],
      ['Usuario creador:', metadatos['usuarioCreador'] ?? 'Todos'],
      ['Total formatos:', '${metadatos['totalFormatos']}'],
    ];

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

  // ============================================================================
  // MÉTODOS PLACEHOLDER PARA ANÁLISIS ESPECÍFICOS
  // (En una implementación completa, estos reutilizarían código de los archivos base)
  // ============================================================================

  /// Resumen estadístico general (reutiliza lógica de resumen_general_excel.dart)
  int _crearResumenEstadisticoGeneral(xlsio.Worksheet sheet,
      Map<String, dynamic> datos, Map<String, dynamic> metadatos, int fila) {
    _aplicarEstiloSeccion(sheet, fila, 'RESUMEN ESTADÍSTICO GENERAL', COLOR_RESUMEN_GENERAL);
    fila++;

    final int totalFormatos = metadatos['totalFormatos'] ?? 0;
    // CORREGIDO: Acceso a los datos de resumen general
    final ciudadesCubiertas = datos['resumenGeneral']?['distribucionGeografica']?['ciudades']?.length ?? 0;
    final periodosCubiertos = datos['resumenGeneral']?['distribucionTemporal']?['meses']?.length ?? 0;

    _crearTablaResumen(sheet, fila, [
      ['Total de inmuebles evaluados', '$totalFormatos', '100% de la muestra'],
      ['Ciudades cubiertas', '$ciudadesCubiertas', 'Cobertura geográfica'],
      ['Períodos analizados', '$periodosCubiertos', 'Cobertura temporal'],
    ]);

    return fila + 4; // 3 filas de datos + 1 encabezado
  }

  /// Resumen estadístico uso y topografía
  int _crearResumenEstadisticoUsoTopografia(xlsio.Worksheet sheet,
      Map<String, dynamic> datos, Map<String, dynamic> metadatos, int fila) {
    _aplicarEstiloSeccion(sheet, fila, 'RESUMEN ESTADÍSTICO USO Y TOPOGRAFÍA', COLOR_USO_TOPOGRAFIA);
    fila++;

    final int totalFormatos = metadatos['totalFormatos'] ?? 0;
    // CORREGIDO: Acceso a los datos de uso y topografía
    final tiposUso = _contarElementosConDatos(datos['usoTopografia']?['usosVivienda']?['estadisticas'] ?? {});
    final tiposTopografia = _contarElementosConDatos(datos['usoTopografia']?['topografia']?['estadisticas'] ?? {});

    _crearTablaResumen(sheet, fila, [
      ['Total inmuebles evaluados', '$totalFormatos', '100% de la muestra'],
      ['Tipos de uso identificados', '$tiposUso', 'Diversidad de uso'],
      ['Tipos de topografía', '$tiposTopografia', 'Variedad topográfica'],
    ]);

    return fila + 4;
  }

  /// Resumen estadístico material dominante
  int _crearResumenEstadisticoMaterial(xlsio.Worksheet sheet,
      Map<String, dynamic> datos, Map<String, dynamic> metadatos, int fila) {
    _aplicarEstiloSeccion(sheet, fila, 'RESUMEN ESTADÍSTICO MATERIAL DOMINANTE', COLOR_MATERIAL_DOMINANTE);
    fila++;

    final int totalFormatos = metadatos['totalFormatos'] ?? 0;
    // CORREGIDO: Acceso a los datos de material dominante
    final tiposMaterial = _contarMateriales(datos['materialDominante']?['conteoMateriales'] ?? {});
    final materialPredominante = _encontrarPredominante(datos['materialDominante']?['conteoMateriales'] ?? {});

    _crearTablaResumen(sheet, fila, [
      ['Total inmuebles evaluados', '$totalFormatos', '100% de la muestra'],
      ['Tipos de material identificados', '$tiposMaterial', 'Diversidad de materiales'],
      ['Material predominante', materialPredominante, 'Más frecuente'],
    ]);

    return fila + 4;
  }

  /// Resumen estadístico sistema estructural
  int _crearResumenEstadisticoEstructural(xlsio.Worksheet sheet,
      Map<String, dynamic> datos, Map<String, dynamic> metadatos, int fila) {
    _aplicarEstiloSeccion(sheet, fila, 'RESUMEN ESTADÍSTICO SISTEMA ESTRUCTURAL', COLOR_SISTEMA_ESTRUCTURAL);
    fila++;

    final int totalFormatos = metadatos['totalFormatos'] ?? 0;
    // CORREGIDO: Acceso a los datos de sistema estructural
    final categoriasEstructurales = _contarCategoriasEstructurales(datos['sistemaEstructural']?['estadisticas'] ?? {});

    _crearTablaResumen(sheet, fila, [
      ['Total inmuebles evaluados', '$totalFormatos', '100% de la muestra'],
      ['Categorías estructurales analizadas', '$categoriasEstructurales', 'Elementos evaluados'],
      ['Cobertura de análisis', '${(categoriasEstructurales / 6 * 100).toStringAsFixed(1)}%', 'Completitud estructural'],
    ]);

    return fila + 4;
  }

  /// Resumen estadístico evaluación de daños
  int _crearResumenEstadisticoDanos(xlsio.Worksheet sheet,
      Map<String, dynamic> datos, Map<String, dynamic> metadatos, int fila) {
    _aplicarEstiloSeccion(sheet, fila, 'RESUMEN ESTADÍSTICO EVALUACIÓN DE DAÑOS', COLOR_EVALUACION_DANOS);
    fila++;

    final int totalFormatos = metadatos['totalFormatos'] ?? 0;
    // CORREGIDO: Acceso a los datos de evaluación de daños
    final resumenRiesgos = datos['evaluacionDanos']?['resumenRiesgos'] ?? {};
    final riesgoAlto = resumenRiesgos['riesgoAlto'] ?? 0;
    final riesgoMedio = resumenRiesgos['riesgoMedio'] ?? 0;

    _crearTablaResumen(sheet, fila, [
      ['Total inmuebles evaluados', '$totalFormatos', '100% de la muestra'],
      ['Inmuebles riesgo alto', '$riesgoAlto', '${totalFormatos > 0 ? (riesgoAlto / totalFormatos * 100).toStringAsFixed(1) : 0}% - Intervención inmediata'],
      ['Inmuebles riesgo medio', '$riesgoMedio', '${totalFormatos > 0 ? (riesgoMedio / totalFormatos * 100).toStringAsFixed(1) : 0}% - Refuerzo programado'],
    ]);

    return fila + 4;
  }

  // ============================================================================
  // MÉTODOS DE ANÁLISIS CON GRÁFICOS (simplificados para eficiencia)
  // ============================================================================

  /// Análisis distribución geográfica con gráfico
  Future<int> _crearAnalisisDistribucionGeografica(xlsio.Worksheet sheet,
      Map<String, dynamic> datos, int filaInicial) async {
    int fila = filaInicial;

    _aplicarEstiloSeccion(sheet, fila, 'DISTRIBUCIÓN GEOGRÁFICA', COLOR_RESUMEN_GENERAL);
    fila++;

    // CORREGIDO: Verificar datos de distribución geográfica
    if (!datos.containsKey('resumenGeneral') ||
        !datos['resumenGeneral'].containsKey('distribucionGeografica') ||
        datos['resumenGeneral']['distribucionGeografica']['ciudades'] == null) {
      sheet.getRangeByIndex(fila, 1).setText('No hay datos de distribución geográfica disponibles');
      return fila + 1;
    }

    // CORREGIDO: Acceso a datos de ciudades
    Map<String, int> ciudades = Map<String, int>.from(datos['resumenGeneral']['distribucionGeografica']['ciudades']);
    List<MapEntry<String, int>> ciudadesOrdenadas = ciudades.entries
        .where((entry) => entry.value > 0)
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final posicionesGraficos = _crearTablaCiudades(sheet, fila, ciudadesOrdenadas);
    fila = posicionesGraficos['filaFinal']! + 2;

    if (ciudadesOrdenadas.isNotEmpty) {
      fila = await _crearGraficoBarras(sheet, fila, posicionesGraficos,
          'Distribución por Ciudad', 'Ciudad', 'Cantidad');
    }

    return fila;
  }

  /// Análisis distribución temporal con gráfico
  Future<int> _crearAnalisisDistribucionTemporal(xlsio.Worksheet sheet,
      Map<String, dynamic> datos, int filaInicial) async {
    int fila = filaInicial;

    _aplicarEstiloSeccion(sheet, fila, 'DISTRIBUCIÓN TEMPORAL', COLOR_RESUMEN_GENERAL);
    fila++;

    // CORREGIDO: Verificar datos de distribución temporal
    if (!datos.containsKey('resumenGeneral') ||
        !datos['resumenGeneral'].containsKey('distribucionTemporal') ||
        datos['resumenGeneral']['distribucionTemporal']['meses'] == null) {
      sheet.getRangeByIndex(fila, 1).setText('No hay datos de distribución temporal disponibles');
      return fila + 1;
    }

    // CORREGIDO: Acceso a datos de meses
    Map<String, int> meses = Map<String, int>.from(datos['resumenGeneral']['distribucionTemporal']['meses']);
    List<MapEntry<String, int>> mesesOrdenados = meses.entries.where((entry) => entry.value > 0).toList()
      ..sort((a, b) {
        try {
          final fechaA = DateFormat('MM/yyyy').parse(a.key);
          final fechaB = DateFormat('MM/yyyy').parse(b.key);
          return fechaA.compareTo(fechaB);
        } catch (e) {
          return a.key.compareTo(b.key);
        }
      });

    final posicionesGraficos = _crearTablaMeses(sheet, fila, mesesOrdenados);
    fila = posicionesGraficos['filaFinal']! + 2;

    if (mesesOrdenados.isNotEmpty) {
      fila = await _crearGraficoBarras(sheet, fila, posicionesGraficos,
          'Distribución Temporal', 'Período', 'Cantidad');
    }

    return fila;
  }

  /// Análisis uso de vivienda con gráfico
  Future<int> _crearAnalisisUsoVivienda(xlsio.Worksheet sheet,
      Map<String, dynamic> datos, int filaInicial) async {
    int fila = filaInicial;

    _aplicarEstiloSeccion(sheet, fila, 'USO DE VIVIENDA', COLOR_USO_TOPOGRAFIA);
    fila++;

    // CORREGIDO: Verificar datos de uso de vivienda
    if (!datos.containsKey('usoTopografia') ||
        !datos['usoTopografia'].containsKey('usosVivienda') ||
        datos['usoTopografia']['usosVivienda']['estadisticas'] == null) {
      sheet.getRangeByIndex(fila, 1).setText('No hay datos de uso de vivienda disponibles');
      return fila + 1;
    }

    // CORREGIDO: Acceso a estadísticas de usos
    Map<String, dynamic> estadisticasUsos = datos['usoTopografia']['usosVivienda']['estadisticas'];
    List<MapEntry<String, dynamic>> usosOrdenados = estadisticasUsos.entries
        .where((entry) => entry.value['conteo'] > 0)
        .toList()
      ..sort((a, b) => b.value['conteo'].compareTo(a.value['conteo']));

    final posicionesGraficos = _crearTablaUsos(sheet, fila, usosOrdenados);
    fila = posicionesGraficos['filaFinal']! + 2;

    if (usosOrdenados.isNotEmpty) {
      fila = await _crearGraficoBarras(sheet, fila, posicionesGraficos,
          'Distribución de Uso de Vivienda', 'Tipo de Uso', 'Cantidad');
    }

    return fila;
  }

  /// Análisis topografía con gráfico
  Future<int> _crearAnalisisTopografia(xlsio.Worksheet sheet,
      Map<String, dynamic> datos, int filaInicial) async {
    int fila = filaInicial;

    _aplicarEstiloSeccion(sheet, fila, 'TOPOGRAFÍA', COLOR_USO_TOPOGRAFIA);
    fila++;

    // CORREGIDO: Verificar datos de topografía
    if (!datos.containsKey('usoTopografia') ||
        !datos['usoTopografia'].containsKey('topografia') ||
        datos['usoTopografia']['topografia']['estadisticas'] == null) {
      sheet.getRangeByIndex(fila, 1).setText('No hay datos de topografía disponibles');
      return fila + 1;
    }

    // CORREGIDO: Acceso a estadísticas de topografía
    Map<String, dynamic> estadisticasTopografia = datos['usoTopografia']['topografia']['estadisticas'];
    List<MapEntry<String, dynamic>> topografiaOrdenada = estadisticasTopografia.entries
        .where((entry) => entry.value['conteo'] > 0)
        .toList()
      ..sort((a, b) => b.value['conteo'].compareTo(a.value['conteo']));

    final posicionesGraficos = _crearTablaTopografia(sheet, fila, topografiaOrdenada);
    fila = posicionesGraficos['filaFinal']! + 2;

    if (topografiaOrdenada.isNotEmpty) {
      fila = await _crearGraficoBarras(sheet, fila, posicionesGraficos,
          'Distribución de Topografía', 'Tipo de Topografía', 'Cantidad');
    }

    return fila;
  }

  /// Análisis material dominante con gráfico
  Future<int> _crearAnalisisMaterialDominante(xlsio.Worksheet sheet,
      Map<String, dynamic> datos, int filaInicial) async {
    int fila = filaInicial;

    _aplicarEstiloSeccion(sheet, fila, 'MATERIAL DOMINANTE', COLOR_MATERIAL_DOMINANTE);
    fila++;

    // CORREGIDO: Verificar datos de material dominante
    if (!datos.containsKey('materialDominante') ||
        !datos['materialDominante'].containsKey('conteoMateriales') ||
        datos['materialDominante']['conteoMateriales'].isEmpty) {
      sheet.getRangeByIndex(fila, 1).setText('No hay datos de material dominante disponibles');
      return fila + 1;
    }

    // CORREGIDO: Acceso a conteo de materiales
    Map<String, int> conteoMateriales = Map<String, int>.from(datos['materialDominante']['conteoMateriales']);
    List<MapEntry<String, int>> materialesOrdenados = conteoMateriales.entries
        .where((entry) => entry.value > 0)
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final posicionesGraficos = _crearTablaMateriales(sheet, fila, materialesOrdenados);
    fila = posicionesGraficos['filaFinal']! + 2;

    if (materialesOrdenados.isNotEmpty) {
      fila = await _crearGraficoBarras(sheet, fila, posicionesGraficos,
          'Distribución de Material Dominante', 'Material', 'Cantidad');
    }

    return fila;
  }

  /// Análisis resistencia estructural con gráfico
  Future<int> _crearAnalisisResistenciaEstructural(xlsio.Worksheet sheet,
      Map<String, dynamic> datos, int filaInicial) async {
    int fila = filaInicial;

    _aplicarEstiloSeccion(sheet, fila, 'RESISTENCIA ESTRUCTURAL', COLOR_MATERIAL_DOMINANTE);
    fila++;

    // Clasificar materiales por resistencia
    Map<String, List<String>> clasificacionResistencia = {
      'Alta Resistencia': ['Concreto'],
      'Media-Alta Resistencia': ['Ladrillo'],
      'Baja Resistencia': ['Adobe'],
      'Resistencia Variable': ['Madera/Lámina/Otros'],
    };

    // CORREGIDO: Acceso a conteo de materiales
    Map<String, int> conteoMateriales = Map<String, int>.from(datos['materialDominante']?['conteoMateriales'] ?? {});
    Map<String, int> resistenciaTotales = {};

    for (var entry in clasificacionResistencia.entries) {
      int totalNivel = 0;
      for (String material in entry.value) {
        totalNivel += conteoMateriales[material] ?? 0;
      }
      if (totalNivel > 0) {
        resistenciaTotales[entry.key] = totalNivel;
      }
    }

    final posicionesGraficos = _crearTablaResistencia(sheet, fila, resistenciaTotales);
    fila = posicionesGraficos['filaFinal']! + 2;

    if (resistenciaTotales.isNotEmpty) {
      fila = await _crearGraficoBarras(sheet, fila, posicionesGraficos,
          'Distribución por Resistencia', 'Nivel de Resistencia', 'Cantidad');
    }

    return fila;
  }

  /// Análisis dirección X con gráfico
  Future<int> _crearAnalisisDireccionX(xlsio.Worksheet sheet,
      Map<String, dynamic> datos, int filaInicial) async {
    return await _crearAnalisisEstructural(sheet, datos, filaInicial, 'direccionX', 'DIRECCIÓN X');
  }

  /// Análisis dirección Y con gráfico
  Future<int> _crearAnalisisDireccionY(xlsio.Worksheet sheet,
      Map<String, dynamic> datos, int filaInicial) async {
    return await _crearAnalisisEstructural(sheet, datos, filaInicial, 'direccionY', 'DIRECCIÓN Y');
  }

  /// Análisis muros de mampostería con gráfico
  Future<int> _crearAnalisisMurosMamposteria(xlsio.Worksheet sheet,
      Map<String, dynamic> datos, int filaInicial) async {
    return await _crearAnalisisEstructural(sheet, datos, filaInicial, 'murosMamposteria', 'MUROS DE MAMPOSTERÍA');
  }

  /// Método genérico para análisis estructural
  Future<int> _crearAnalisisEstructural(
      xlsio.Worksheet sheet,
      Map<String, dynamic> datos,
      int filaInicial,
      String categoria,
      String titulo) async {
    int fila = filaInicial;

    _aplicarEstiloSeccion(sheet, fila, titulo, COLOR_SISTEMA_ESTRUCTURAL);
    fila++;

    // CORREGIDO: Verificar datos de sistema estructural
    if (!datos.containsKey('sistemaEstructural') ||
        !datos['sistemaEstructural'].containsKey('estadisticas') ||
        !datos['sistemaEstructural']['estadisticas'].containsKey(categoria)) {
      sheet.getRangeByIndex(fila, 1).setText('No hay datos de $titulo disponibles');
      return fila + 1;
    }

    // CORREGIDO: Acceso a estadísticas de categoría específica
    Map<String, dynamic> estadisticasCategoria = datos['sistemaEstructural']['estadisticas'][categoria];
    List<MapEntry<String, dynamic>> elementosOrdenados = estadisticasCategoria.entries
        .where((entry) => entry.value['conteo'] > 0)
        .toList()
      ..sort((a, b) => b.value['conteo'].compareTo(a.value['conteo']));

    final posicionesGraficos = _crearTablaElementosEstructurales(sheet, fila, elementosOrdenados, titulo);
    fila = posicionesGraficos['filaFinal']! + 2;

    if (elementosOrdenados.isNotEmpty) {
      fila = await _crearGraficoBarras(sheet, fila, posicionesGraficos,
          'Distribución $titulo', 'Elemento', 'Cantidad');
    }

    return fila;
  }

  /// Análisis daños geotécnicos con gráfico
  Future<int> _crearAnalisisDanosGeotecnicos(xlsio.Worksheet sheet,
      Map<String, dynamic> datos, int filaInicial) async {
    int fila = filaInicial;

    _aplicarEstiloSeccion(sheet, fila, 'DAÑOS GEOTÉCNICOS', COLOR_EVALUACION_DANOS);
    fila++;

    // CORREGIDO: Verificar datos de daños geotécnicos
    if (!datos.containsKey('evaluacionDanos') ||
        !datos['evaluacionDanos'].containsKey('estadisticas') ||
        !datos['evaluacionDanos']['estadisticas'].containsKey('geotecnicos')) {
      sheet.getRangeByIndex(fila, 1).setText('No hay datos de daños geotécnicos disponibles');
      return fila + 1;
    }

    // CORREGIDO: Acceso a estadísticas geotécnicas
    Map<String, dynamic> estadisticasGeotecnicos = datos['evaluacionDanos']['estadisticas']['geotecnicos'];
    List<MapEntry<String, dynamic>> danosOrdenados = estadisticasGeotecnicos.entries
        .where((entry) => entry.value['conteo'] > 0)
        .toList()
      ..sort((a, b) => b.value['conteo'].compareTo(a.value['conteo']));

    final posicionesGraficos = _crearTablaDanos(sheet, fila, danosOrdenados);
    fila = posicionesGraficos['filaFinal']! + 2;

    if (danosOrdenados.isNotEmpty) {
      fila = await _crearGraficoBarras(sheet, fila, posicionesGraficos,
          'Distribución Daños Geotécnicos', 'Tipo de Daño', 'Cantidad');
    }

    return fila;
  }

  /// Análisis nivel de daño con gráfico
  Future<int> _crearAnalisisNivelDano(xlsio.Worksheet sheet,
      Map<String, dynamic> datos, int filaInicial) async {
    int fila = filaInicial;

    _aplicarEstiloSeccion(sheet, fila, 'NIVEL DE DAÑO', COLOR_EVALUACION_DANOS);
    fila++;

    // CORREGIDO: Verificar datos de nivel de daño
    if (!datos.containsKey('evaluacionDanos') ||
        !datos['evaluacionDanos'].containsKey('estadisticas') ||
        !datos['evaluacionDanos']['estadisticas'].containsKey('nivelDano')) {
      sheet.getRangeByIndex(fila, 1).setText('No hay datos de nivel de daño disponibles');
      return fila + 1;
    }

    // CORREGIDO: Acceso a estadísticas de nivel de daño
    Map<String, dynamic> estadisticasNivelDano = datos['evaluacionDanos']['estadisticas']['nivelDano'];
    List<MapEntry<String, dynamic>> nivelesOrdenados = estadisticasNivelDano.entries
        .where((entry) => entry.value['conteo'] > 0)
        .toList();

    // Ordenar por severidad
    final ordenSeveridad = ['Colapso total', 'Daño severo', 'Daño medio', 'Daño ligero', 'Sin daño aparente'];
    nivelesOrdenados.sort((a, b) {
      int indexA = ordenSeveridad.indexOf(a.key);
      int indexB = ordenSeveridad.indexOf(b.key);
      if (indexA == -1) indexA = 999;
      if (indexB == -1) indexB = 999;
      return indexA.compareTo(indexB);
    });

    final posicionesGraficos = _crearTablaNivelesDano(sheet, fila, nivelesOrdenados);
    fila = posicionesGraficos['filaFinal']! + 2;

    if (nivelesOrdenados.isNotEmpty) {
      fila = await _crearGraficoBarras(sheet, fila, posicionesGraficos,
          'Distribución Nivel de Daño', 'Nivel', 'Cantidad');
    }

    return fila;
  }

  // ============================================================================
  // MÉTODOS DE CREACIÓN DE TABLAS ESPECÍFICAS
  // ============================================================================

  /// Crea tabla de resumen genérica
  void _crearTablaResumen(xlsio.Worksheet sheet, int filaInicial, List<List<String>> datos) {
    int fila = filaInicial;

    // Encabezados
    sheet.getRangeByIndex(fila, 1).setText('Concepto');
    sheet.getRangeByIndex(fila, 2).setText('Valor');
    sheet.getRangeByIndex(fila, 3).setText('Observación');

    final xlsio.Range rangoHeader = sheet.getRangeByIndex(fila, 1, fila, 3);
    rangoHeader.cellStyle.bold = true;
    rangoHeader.cellStyle.backColor = '#6C757D';
    rangoHeader.cellStyle.fontColor = '#FFFFFF';
    rangoHeader.cellStyle.borders.all.lineStyle = xlsio.LineStyle.thin;
    fila++;

    // Datos
    for (int i = 0; i < datos.length; i++) {
      sheet.getRangeByIndex(fila, 1).setText(datos[i][0]);
      sheet.getRangeByIndex(fila, 2).setText(datos[i][1]);
      sheet.getRangeByIndex(fila, 3).setText(datos[i][2]);

      String bgColor = fila % 2 == 0 ? '#F2F2F2' : '#FFFFFF';
      final xlsio.Range rangoFila = sheet.getRangeByIndex(fila, 1, fila, 3);
      rangoFila.cellStyle.backColor = bgColor;
      rangoFila.cellStyle.borders.all.lineStyle = xlsio.LineStyle.thin;

      fila++;
    }
  }

  /// Crea tabla de ciudades
  Map<String, int> _crearTablaCiudades(xlsio.Worksheet sheet, int filaInicial,
      List<MapEntry<String, int>> datos) {
    int fila = filaInicial;

    // Encabezados
    sheet.getRangeByIndex(fila, 1).setText('Ciudad');
    sheet.getRangeByIndex(fila, 2).setText('Cantidad');
    sheet.getRangeByIndex(fila, 3).setText('Porcentaje');

    final xlsio.Range rangoHeader = sheet.getRangeByIndex(fila, 1, fila, 3);
    rangoHeader.cellStyle.bold = true;
    rangoHeader.cellStyle.backColor = COLOR_RESUMEN_GENERAL;
    rangoHeader.cellStyle.fontColor = '#FFFFFF';
    fila++;

    int filaGraficaInicio = fila;
    int total = datos.fold(0, (sum, entry) => sum + entry.value);

    // Datos
    for (var entry in datos) {
      double porcentaje = total > 0 ? (entry.value / total) * 100 : 0;
      sheet.getRangeByIndex(fila, 1).setText(entry.key);
      sheet.getRangeByIndex(fila, 2).setNumber(entry.value.toDouble());
      sheet.getRangeByIndex(fila, 3).setText('${porcentaje.toStringAsFixed(1)}%');
      fila++;
    }

    return {
      'filaFinal': fila - 1,
      'filaGraficaInicio': filaGraficaInicio,
      'filaGraficaFin': fila,
      'columnaGraficaInicio': 1,
      'columnaGraficaFin': 2,
    };
  }

  /// Método genérico para crear tablas con datos que tienen conteo
  /// Método genérico para crear tablas con datos que tienen conteo
  Map<String, int> _crearTablaConConteo(xlsio.Worksheet sheet, int filaInicial,
      List<MapEntry<String, dynamic>> datos, String titulo, String color) {
    int fila = filaInicial;

    // Encabezados
    sheet.getRangeByIndex(fila, 1).setText(titulo);
    sheet.getRangeByIndex(fila, 2).setText('Cantidad');
    sheet.getRangeByIndex(fila, 3).setText('Porcentaje');

    final xlsio.Range rangoHeader = sheet.getRangeByIndex(fila, 1, fila, 3);
    rangoHeader.cellStyle.bold = true;
    rangoHeader.cellStyle.backColor = color;
    rangoHeader.cellStyle.fontColor = '#FFFFFF';
    fila++;

    int filaGraficaInicio = fila;
    int total = datos.fold(
        0, (sum, entry) => sum + (entry.value['conteo'] as int? ?? 0));

    // Datos
    for (var entry in datos) {
      int conteo = entry.value['conteo'] as int? ?? 0;
      double porcentaje = total > 0 ? (conteo / total) * 100 : 0;
      sheet.getRangeByIndex(fila, 1).setText(entry.key);
      sheet.getRangeByIndex(fila, 2).setNumber(conteo.toDouble());
      sheet
          .getRangeByIndex(fila, 3)
          .setText('${porcentaje.toStringAsFixed(1)}%');
      fila++;
    }

    return {
      'filaFinal': fila - 1,
      'filaGraficaInicio': filaGraficaInicio,
      'filaGraficaFin': fila,
      'columnaGraficaInicio': 1,
      'columnaGraficaFin': 2,
    };
  }

  // ============================================================================
  // MÉTODO DE CREACIÓN DE GRÁFICOS UNIFICADO
  // ============================================================================

  /// Crea gráfico de barras reutilizable para todas las secciones
  Future<int> _crearGraficoBarras(
    Worksheet sheet,
    int filaInicial,
    Map<String, int> posicionesGraficos,
    String titulo,
    String etiquetaEjeX,
    String etiquetaEjeY,
  ) async {
    try {
      // Asegurar que existe la colección de gráficos
      sheet.charts ??= ChartCollection(sheet);
      final ChartCollection charts = sheet.charts as ChartCollection;
      final Chart chart = charts.add();

      // Configuración del gráfico
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
      chart.linePatternColor = "#2F4F4F";
      chart.plotArea.linePattern = ExcelChartLinePattern.dashDot;
      chart.plotArea.linePatternColor = '#0000FF';

      return filaInicial + 16;
    } catch (e) {
      print('⚠️ [EXCEL-COMPLETO-V2] Error al crear gráfico: $e');
      sheet.getRangeByIndex(filaInicial, 1).setText('Gráfico no disponible');
      return filaInicial + 1;
    }
  }

  // ============================================================================
  // MÉTODOS DE RESUMEN Y CONCLUSIONES
  // ============================================================================

  /// Crea resumen por secciones en la hoja ejecutiva
  int _crearResumenPorSecciones(
    xlsio.Worksheet sheet,
    Map<String, dynamic> datosCompletos,
    Map<String, dynamic> metadatos,
    int filaInicial,
  ) {
    int fila = filaInicial;

    _aplicarEstiloSeccion(
        sheet, fila, 'RESUMEN POR SECCIONES DE ANÁLISIS', COLOR_HEADER);
    fila++;

    // Crear tabla de resumen consolidado
    final List<List<String>> resumenSecciones = [
      [
        'Resumen General',
        '${datosCompletos['resumenGeneral']?['distribucionGeografica']?['ciudades']?.length ?? 0} ciudades',
        'Cobertura geográfica y temporal de evaluaciones'
      ],
      [
        'Uso y Topografía',
        '${_contarElementosConDatos(datosCompletos['usoTopografia']?['usosVivienda']?['estadisticas'] ?? {})} usos identificados',
        'Patrones de uso de vivienda y características del terreno'
      ],
      [
        'Material Dominante',
        '${_encontrarPredominante(datosCompletos['materialDominante']?['conteoMateriales'] ?? {})}',
        'Material de construcción más frecuente'
      ],
      [
        'Sistema Estructural',
        '${_contarCategoriasEstructurales(datosCompletos['sistemaEstructural']?['estadisticas'] ?? {})} categorías analizadas',
        'Elementos estructurales y configuraciones'
      ],
      [
        'Evaluación de Daños',
        '${datosCompletos['evaluacionDanos']?['resumenRiesgos']?['riesgoAlto'] ?? 0} inmuebles riesgo alto',
        'Análisis de riesgos y daños estructurales'
      ],
    ];

    // Crear tabla con formato especial
    _crearTablaResumenSecciones(sheet, fila, resumenSecciones);

    return fila + resumenSecciones.length + 1; // +1 para encabezado
  }

  /// Crea tabla de resumen de secciones con formato especial
  void _crearTablaResumenSecciones(
      xlsio.Worksheet sheet, int filaInicial, List<List<String>> datos) {
    int fila = filaInicial;

    // Encabezados
    sheet.getRangeByIndex(fila, 1).setText('Sección de Análisis');
    sheet.getRangeByIndex(fila, 2).setText('Métrica Clave');
    sheet.getRangeByIndex(fila, 3, fila, 4).merge();
    sheet.getRangeByIndex(fila, 3).setText('Descripción');

    final xlsio.Range rangoHeader = sheet.getRangeByIndex(fila, 1, fila, 4);
    rangoHeader.cellStyle.bold = true;
    rangoHeader.cellStyle.backColor = COLOR_HEADER;
    rangoHeader.cellStyle.fontColor = '#FFFFFF';
    rangoHeader.cellStyle.borders.all.lineStyle = xlsio.LineStyle.thin;
    fila++;

    // Datos con colores diferenciados por sección
    final List<String> coloresSeccion = [
      COLOR_RESUMEN_GENERAL,
      COLOR_USO_TOPOGRAFIA,
      COLOR_MATERIAL_DOMINANTE,
      COLOR_SISTEMA_ESTRUCTURAL,
      COLOR_EVALUACION_DANOS,
    ];

    for (int i = 0; i < datos.length; i++) {
      sheet.getRangeByIndex(fila, 1).setText(datos[i][0]);
      sheet.getRangeByIndex(fila, 2).setText(datos[i][1]);
      sheet.getRangeByIndex(fila, 3, fila, 4).merge();
      sheet.getRangeByIndex(fila, 3).setText(datos[i][2]);

      // Aplicar color específico de la sección
      final xlsio.Range rangoFila = sheet.getRangeByIndex(fila, 1, fila, 4);
      rangoFila.cellStyle.backColor = coloresSeccion[i % coloresSeccion.length];
      rangoFila.cellStyle.fontColor = '#FFFFFF';
      rangoFila.cellStyle.borders.all.lineStyle = xlsio.LineStyle.thin;

      fila++;
    }
  }

  /// Crea conclusiones ejecutivas
  void _crearConclusionesEjecutivas(
    xlsio.Worksheet sheet,
    Map<String, dynamic> datosCompletos,
    Map<String, dynamic> metadatos,
    int filaInicial,
  ) {
    int fila = filaInicial;

    _aplicarEstiloSeccion(
        sheet, fila, 'CONCLUSIONES Y RECOMENDACIONES EJECUTIVAS', COLOR_HEADER);
    fila++;

    // Generar conclusiones automáticas basadas en datos
    final List<String> conclusionesEjecutivas =
        _generarConclusionesAutomaticas(datosCompletos, metadatos);

    for (String conclusion in conclusionesEjecutivas) {
      final xlsio.Range rangoConclusion =
          sheet.getRangeByIndex(fila, 1, fila, 6);
      rangoConclusion.merge();
      rangoConclusion.setText('• $conclusion');
      rangoConclusion.cellStyle.backColor = '#F8F9FA';
      rangoConclusion.cellStyle.wrapText = true;
      rangoConclusion.cellStyle.borders.all.lineStyle = xlsio.LineStyle.thin;
      fila++;
    }
  }

  // ============================================================================
  // MÉTODOS AUXILIARES DE CÁLCULO Y ANÁLISIS
  // ============================================================================
  /// Guarda el archivo Excel en el sistema - Idéntico al archivo base
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

      // Generar nombre de archivo único
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final nombreLimpio = _limpiarNombreArchivo(titulo);
      final nombreArchivo = '${nombreLimpio}_${timestamp}.xlsx';
      final rutaCompleta = '${directorioReportes.path}/$nombreArchivo';

      // Guardar el workbook
      final List<int> bytes = workbook.saveAsStream();
      final File archivo = File(rutaCompleta);
      await archivo.writeAsBytes(bytes);

      // Verificar que el archivo se guardó correctamente
      if (await archivo.exists() && await archivo.length() > 0) {
        print(
            '✅ [EXCEL-RESUMEN-V2] Archivo guardado: $rutaCompleta (${await archivo.length()} bytes)');
        return rutaCompleta;
      } else {
        throw Exception('El archivo no se guardó correctamente');
      }
    } catch (e) {
      print('❌ [EXCEL-RESUMEN-V2] Error al guardar archivo: $e');
      throw Exception('Error al guardar archivo Excel: $e');
    }
  }

  /// Limpia el nombre del archivo para el sistema - Idéntico al archivo base
  String _limpiarNombreArchivo(String nombre) {
    return nombre
        .toLowerCase()
        .replaceAll(' ', '_')
        .replaceAll(RegExp(r'[^a-z0-9_]'), '')
        .replaceAll(RegExp(r'_+'), '_')
        .trim();
  }
  /// Genera conclusiones automáticas basadas en los datos
  List<String> _generarConclusionesAutomaticas(
      Map<String, dynamic> datosCompletos, Map<String, dynamic> metadatos) {
    List<String> conclusiones = [];
    final int totalFormatos = metadatos['totalFormatos'] ?? 0;

    // Conclusión sobre cobertura
    final ciudadesCubiertas =
        datosCompletos['resumenGeneral']?['distribucionGeografica']?['ciudades']?.length ?? 0;
    conclusiones.add(
        'Se evaluaron $totalFormatos inmuebles distribuidos en $ciudadesCubiertas ciudades, '
        'proporcionando una cobertura geográfica ${ciudadesCubiertas > 3 ? 'amplia' : 'focalizada'} del área de estudio.');

    // Conclusión sobre uso predominante
    final usoPredominante = _encontrarPredominante(
        datosCompletos['usoTopografia']?['usosVivienda']?['estadisticas'] ?? {});
    if (usoPredominante != 'No determinado') {
      conclusiones.add(
          'El uso predominante identificado es "$usoPredominante", '
          'lo que indica un patrón de ocupación ${usoPredominante.toLowerCase().contains('vivienda') ? 'residencial' : 'especializado'} en la zona.');
    }

    // Conclusión sobre material dominante
    final materialPredominante =
        _encontrarPredominante(datosCompletos['materialDominante']?['conteoMateriales'] ?? {});
    if (materialPredominante != 'No determinado') {
      String nivelResistencia =
          _determinarResistenciaMaterial(materialPredominante);
      conclusiones.add(
          'El material de construcción predominante es "$materialPredominante", '
          'clasificado como de $nivelResistencia, lo que ${nivelResistencia.contains('Alta') ? 'favorece' : 'requiere atención para'} la resistencia estructural.');
    }

    // Conclusión sobre riesgos
    final resumenRiesgos = datosCompletos['evaluacionDanos']?['resumenRiesgos'] ?? {};
    final riesgoAlto = resumenRiesgos['riesgoAlto'] ?? 0;
    final riesgoMedio = resumenRiesgos['riesgoMedio'] ?? 0;

    if (riesgoAlto > 0) {
      double porcentajeRiesgoAlto =
          totalFormatos > 0 ? (riesgoAlto / totalFormatos) * 100 : 0;
      conclusiones.add(
          'Se identificaron $riesgoAlto inmuebles con riesgo alto (${porcentajeRiesgoAlto.toStringAsFixed(1)}%), '
          'requiriendo intervención ${porcentajeRiesgoAlto > 10 ? 'urgente y prioritaria' : 'inmediata pero focalizada'}.');
    }

    // Recomendación estratégica
    if (riesgoAlto + riesgoMedio > totalFormatos * 0.3) {
      conclusiones.add(
          'Se recomienda implementar un programa integral de refuerzo estructural '
          'debido al alto porcentaje de inmuebles con riesgo medio-alto identificados.');
    } else {
      conclusiones.add(
          'El nivel general de riesgo es manejable con un programa de monitoreo preventivo '
          'y intervenciones específicas en los casos críticos identificados.');
    }

    return conclusiones;
  }

  

  


 
 

  // ============================================================================
  // MÉTODOS AUXILIARES DE CÁLCULO (CORREGIDOS)
  // ============================================================================

  /// Encuentra el elemento predominante en un mapa de estadísticas
  String _encontrarPredominante(Map<String, dynamic> estadisticas) {
    if (estadisticas.isEmpty) return 'No determinado';

    String predominante = 'No determinado';
    int maxConteo = 0;

    estadisticas.forEach((key, value) {
      int conteo = 0;
      if (value is Map && value.containsKey('conteo')) {
        conteo = value['conteo'] as int? ?? 0;
      } else if (value is int) {
        conteo = value;
      }

      if (conteo > maxConteo) {
        maxConteo = conteo;
        predominante = key;
      }
    });

    return predominante;
  }

  /// Cuenta materiales únicos
  int _contarMateriales(Map<String, dynamic> materiales) {
    return materiales.entries
        .where((entry) => (entry.value as int? ?? 0) > 0)
        .length;
  }

  /// Cuenta categorías estructurales con datos (CORREGIDO)
  int _contarCategoriasEstructurales(Map<String, dynamic> estadisticas) {
    final categorias = [
      'direccionX',
      'direccionY',
      'murosMamposteria',
      'sistemasPiso',
      'sistemasTecho',
      'cimentacion'
    ];
    int conteo = 0;

    for (String categoria in categorias) {
      if (estadisticas.containsKey(categoria) &&
          estadisticas[categoria] != null) {
        Map<String, dynamic> datosCategoria = estadisticas[categoria];
        if (datosCategoria.values
            .any((stats) => (stats['conteo'] as int? ?? 0) > 0)) {
          conteo++;
        }
      }
    }

    return conteo;
  }

  /// Determina el nivel de resistencia de un material
  String _determinarResistenciaMaterial(String material) {
    final resistenciaPorMaterial = {
      'Concreto': 'Alta Resistencia',
      'Ladrillo': 'Media-Alta Resistencia',
      'Adobe': 'Baja Resistencia',
      'Madera/Lámina/Otros': 'Resistencia Variable',
      'No determinado': 'Sin Clasificar',
    };

    return resistenciaPorMaterial[material] ?? 'Sin Clasificar';
  }

  // ============================================================================
  // MÉTODOS RESUMEN ESTADÍSTICO ESPECÍFICOS (CORREGIDOS)
  // ============================================================================


  
  

  
 

  // ============================================================================
  // MÉTODOS PLACEHOLDER PARA TABLAS ESPECÍFICAS
  // ============================================================================

  /// Crea tabla de meses
  Map<String, int> _crearTablaMeses(xlsio.Worksheet sheet, int filaInicial,
      List<MapEntry<String, int>> datos) {
    return _crearTablaGenerica(
        sheet, filaInicial, datos, 'Período', COLOR_RESUMEN_GENERAL);
  }

  /// Crea tabla de usos
  Map<String, int> _crearTablaUsos(xlsio.Worksheet sheet, int filaInicial,
      List<MapEntry<String, dynamic>> datos) {
    return _crearTablaConConteo(
        sheet, filaInicial, datos, 'Tipo de Uso', COLOR_USO_TOPOGRAFIA);
  }

  /// Crea tabla de topografía
  Map<String, int> _crearTablaTopografia(xlsio.Worksheet sheet, int filaInicial,
      List<MapEntry<String, dynamic>> datos) {
    return _crearTablaConConteo(
        sheet, filaInicial, datos, 'Tipo de Topografía', COLOR_USO_TOPOGRAFIA);
  }

  /// Crea tabla de materiales
  Map<String, int> _crearTablaMateriales(xlsio.Worksheet sheet, int filaInicial,
      List<MapEntry<String, int>> datos) {
    return _crearTablaGenerica(
        sheet, filaInicial, datos, 'Material', COLOR_MATERIAL_DOMINANTE);
  }

  /// Crea tabla de resistencia
  Map<String, int> _crearTablaResistencia(
      xlsio.Worksheet sheet, int filaInicial, Map<String, int> datos) {
    List<MapEntry<String, int>> datosOrdenados = datos.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return _crearTablaGenerica(sheet, filaInicial, datosOrdenados,
        'Nivel de Resistencia', COLOR_MATERIAL_DOMINANTE);
  }

  /// Crea tabla de elementos estructurales
  Map<String, int> _crearTablaElementosEstructurales(
      xlsio.Worksheet sheet,
      int filaInicial,
      List<MapEntry<String, dynamic>> datos,
      String categoria) {
    return _crearTablaConConteo(sheet, filaInicial, datos,
        'Elemento $categoria', COLOR_SISTEMA_ESTRUCTURAL);
  }

  /// Crea tabla de daños
  Map<String, int> _crearTablaDanos(xlsio.Worksheet sheet, int filaInicial,
      List<MapEntry<String, dynamic>> datos) {
    return _crearTablaConConteo(
        sheet, filaInicial, datos, 'Tipo de Daño', COLOR_EVALUACION_DANOS);
  }

  /// Crea tabla de niveles de daño
  Map<String, int> _crearTablaNivelesDano(xlsio.Worksheet sheet,
      int filaInicial, List<MapEntry<String, dynamic>> datos) {
    return _crearTablaConConteo(
        sheet, filaInicial, datos, 'Nivel de Daño', COLOR_EVALUACION_DANOS);
  }

  /// Método genérico para crear tablas con datos simples
  Map<String, int> _crearTablaGenerica(
    xlsio.Worksheet sheet,
    int filaInicial,
    List<MapEntry<String, int>> datos,
    String titulo,
    String color,
  ) {
    int fila = filaInicial;

    // Encabezados
    sheet.getRangeByIndex(fila, 1).setText(titulo);
    sheet.getRangeByIndex(fila, 2).setText('Cantidad');
    sheet.getRangeByIndex(fila, 3).setText('Porcentaje');

    final xlsio.Range rangoHeader = sheet.getRangeByIndex(fila, 1, fila, 3);
    rangoHeader.cellStyle
      ..bold = true
      ..backColor = color
      ..fontColor = '#FFFFFF'
      ..borders.all.lineStyle = xlsio.LineStyle.thin;

    fila++;

    // Marca inicio de rango para la gráfica
    final int filaGraficaInicio = fila;
    final int total = datos.fold(0, (sum, entry) => sum + entry.value);

    // Filas de datos
    for (var entry in datos) {
      final int conteo = entry.value;
      final double porcentaje = total > 0 ? (conteo / total) * 100 : 0.0;

      sheet.getRangeByIndex(fila, 1).setText(entry.key);
      sheet.getRangeByIndex(fila, 2).setNumber(conteo.toDouble());
      sheet
          .getRangeByIndex(fila, 3)
          .setText('${porcentaje.toStringAsFixed(1)}%');

      // Alternar color de fondo y añadir bordes
      final String bgColor = fila.isEven ? '#F2F2F2' : '#FFFFFF';
      sheet.getRangeByIndex(fila, 1, fila, 3).cellStyle
        ..backColor = bgColor
        ..borders.all.lineStyle = xlsio.LineStyle.thin;

      fila++;
    }

    // Marca fin de rango para la gráfica
    final int filaGraficaFin = fila;

    return {
      'filaFinal': fila - 1,
      'filaGraficaInicio': filaGraficaInicio,
      'filaGraficaFin': filaGraficaFin,
      'columnaGraficaInicio': 1,
      'columnaGraficaFin': 2,
    };
  }
  }