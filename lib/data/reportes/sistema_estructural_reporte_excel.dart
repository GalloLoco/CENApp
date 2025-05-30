// lib/data/reportes/sistema_estructural_reporte_excel.dart

import 'dart:io';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xlsio;
import 'package:syncfusion_officechart/officechart.dart';

import 'package:syncfusion_flutter_xlsio/xlsio.dart'; // Ensure this import is added for ExcelCFType
import 'package:intl/intl.dart';
import '../services/file_storage_service.dart';

/// Servicio optimizado para generar reportes Excel de Sistema Estructural usando Syncfusion
/// Basado en la estructura del servicio de Uso de Vivienda y Topografía
/// Versión específica para análisis de elementos estructurales
class ExcelReporteServiceSistemaEstructuralV2 {
  final FileStorageService _fileService = FileStorageService();

  // Constantes para estilos y formato (reutilizadas del servicio base)
  static const String FONT_NAME = 'Calibri';
  static const int HEADER_FONT_SIZE = 16;
  static const int SUBTITLE_FONT_SIZE = 14;
  static const int SECTION_FONT_SIZE = 12;
  static const int NORMAL_FONT_SIZE = 10;

  // Colores corporativos específicos para sistema estructural
  static const String COLOR_HEADER = '#1F4E79';
  static const String COLOR_SUBTITLE = '#2F5F8F';
  static const String COLOR_SECTION = '#4472C4'; // Azul estructural
  static const String COLOR_TABLE_HEADER = '#9BC2E6';

  /// Genera reporte de Sistema Estructural
  /// Incluye gráficos de barras similares a la versión PDF pero adaptados para elementos estructurales
  Future<String> generarReporteSistemaEstructural({
    required String titulo,
    required String subtitulo,
    required Map<String, dynamic> datos,
    required List<Map<String, dynamic>> tablas,
    required Map<String, dynamic> metadatos,
    Directory? directorio,
  }) async {
    try {
      print('📊 [EXCEL-SISTEMA-V2] Iniciando generación con Syncfusion: $titulo');

      // Crear nuevo libro de Excel
      final xlsio.Workbook workbook = xlsio.Workbook();

      // Crear hoja principal
      final xlsio.Worksheet sheet = workbook.worksheets[0];
      sheet.name = 'Sistema Estructural';

      // Configurar anchos de columna óptimos
      _configurarAnchoColumnas(sheet);

      int filaActual = 1; // Syncfusion usa base 1

      // === SECCIÓN 1: ENCABEZADO ===
      filaActual = _crearEncabezado(sheet, titulo, subtitulo, metadatos, filaActual);
      filaActual += 2;

      // === SECCIÓN 2: FILTROS APLICADOS ===
      filaActual = _crearSeccionFiltros(sheet, metadatos, filaActual);
      filaActual += 2;

      // === SECCIÓN 3: RESUMEN ESTADÍSTICO ===
      filaActual = _crearResumenEstadistico(sheet, datos, metadatos, filaActual);
      filaActual += 2;

      // === SECCIÓN 4: ANÁLISIS DIRECCIÓN X CON GRÁFICO ===
      filaActual = await _crearAnalisisDireccionX(sheet, datos, filaActual);
      filaActual += 2;

      // === SECCIÓN 5: ANÁLISIS DIRECCIÓN Y CON GRÁFICO ===
      filaActual = await _crearAnalisisDireccionY(sheet, datos, filaActual);
      filaActual += 2;

      // === SECCIÓN 6: ANÁLISIS MUROS DE MAMPOSTERÍA CON GRÁFICO ===
      filaActual = await _crearAnalisisMurosMamposteria(sheet, datos, filaActual);
      filaActual += 2;

      // === SECCIÓN 7: ANÁLISIS SISTEMAS DE PISO CON GRÁFICO ===
      filaActual = await _crearAnalisisSistemasPiso(sheet, datos, filaActual);
      filaActual += 2;

      // === SECCIÓN 8: ANÁLISIS SISTEMAS DE TECHO CON GRÁFICO ===
      filaActual = await _crearAnalisisSistemasTecho(sheet, datos, filaActual);
      filaActual += 2;

      // === SECCIÓN 9: ANÁLISIS CIMENTACIÓN CON GRÁFICO ===
      filaActual = await _crearAnalisisCimentacion(sheet, datos, filaActual);
      filaActual += 2;

      // === SECCIÓN 10: CONCLUSIONES ===
      _crearSeccionConclusiones(sheet, datos, metadatos, filaActual);

      // Guardar archivo
      final String rutaArchivo = await _guardarArchivo(workbook, titulo, directorio);

      // Liberar recursos
      workbook.dispose();

      print('✅ [EXCEL-SISTEMA-V2] Reporte generado exitosamente: $rutaArchivo');
      return rutaArchivo;
    } catch (e) {
      print('❌ [EXCEL-SISTEMA-V2] Error al generar reporte: $e');
      throw Exception('Error al generar reporte Excel Sistema Estructural: $e');
    }
  }

  /// Configura los anchos de columna óptimos para el reporte (idéntico al base)
  void _configurarAnchoColumnas(xlsio.Worksheet sheet) {
    sheet.getRangeByIndex(1, 1, 100, 1).columnWidth = 30; // Columna A
    sheet.getRangeByIndex(1, 2, 100, 2).columnWidth = 15; // Columna B
    sheet.getRangeByIndex(1, 3, 100, 3).columnWidth = 15; // Columna C
    sheet.getRangeByIndex(1, 4, 100, 4).columnWidth = 25; // Columna D
    sheet.getRangeByIndex(1, 5, 100, 5).columnWidth = 20; // Columna E
    sheet.getRangeByIndex(1, 6, 100, 6).columnWidth = 20; // Columna F
  }

  /// Crea el encabezado del reporte (idéntico al base)
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

  /// Crea la sección de filtros aplicados (idéntico al base)
  int _crearSeccionFiltros(
    xlsio.Worksheet sheet,
    Map<String, dynamic> metadatos,
    int filaInicial,
  ) {
    int fila = filaInicial;

    // Título de sección
    _aplicarEstiloSeccion(sheet, fila, 'FILTROS APLICADOS');
    fila++;

    // Lista de filtros (idéntica al base)
    final List<List<String>> filtros = [
      ['Nombre inmueble:', metadatos['nombreInmueble'] ?? 'Todos'],
      ['Período:', '${metadatos['fechaInicio']} - ${metadatos['fechaFin']}'],
      ['Usuario creador:', metadatos['usuarioCreador'] ?? 'Todos'],
      ['Total formatos:', '${metadatos['totalFormatos']}'],
    ];

    // Agregar ubicaciones si existen
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

    // Escribir filtros
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

  /// Crea el resumen estadístico general adaptado para sistema estructural
  int _crearResumenEstadistico(
    xlsio.Worksheet sheet,
    Map<String, dynamic> datos,
    Map<String, dynamic> metadatos,
    int filaInicial,
  ) {
    int fila = filaInicial;

    // Título de sección
    _aplicarEstiloSeccion(sheet, fila, 'RESUMEN ESTADÍSTICO SISTEMA ESTRUCTURAL');
    fila++;

    final int totalFormatos = metadatos['totalFormatos'] ?? 0;

    // Calcular estadísticas específicas del sistema estructural
    int totalElementosRegistrados = 0;
    int categoriasConElementos = 0;
    
    // Categorías principales del sistema estructural
    final List<String> categorias = [
      'direccionX', 'direccionY', 'murosMamposteria', 
      'sistemasPiso', 'sistemasTecho', 'cimentacion'
    ];

    // Contar elementos por categoría
    if (datos['estadisticas'] != null) {
      for (String categoria in categorias) {
        if (datos['estadisticas'].containsKey(categoria)) {
          Map<String, dynamic> estadisticasCategoria = datos['estadisticas'][categoria];
          if (estadisticasCategoria.isNotEmpty) {
            categoriasConElementos++;
            totalElementosRegistrados += estadisticasCategoria.values
                .fold(0, (sum, stats) => sum + (stats['conteo'] as int? ?? 0));
          }
        }
      }
    }

    // Calcular promedio de elementos por inmueble
    double promedioElementosPorInmueble = totalFormatos > 0 
        ? totalElementosRegistrados / totalFormatos 
        : 0.0;

    // Crear tabla de resumen
    _crearTablaResumen(sheet, fila, [
      ['Total de inmuebles evaluados', '$totalFormatos', '100% de la muestra estructural'],
      ['Categorías estructurales analizadas', '$categoriasConElementos', 'de 6 categorías principales'],
      ['Total elementos registrados', '$totalElementosRegistrados', 'Suma de todos los elementos estructurales'],
      ['Promedio elementos por inmueble', '${promedioElementosPorInmueble.toStringAsFixed(1)}', 'Diversidad estructural promedio'],
      ['Cobertura de análisis', '${((categoriasConElementos / categorias.length) * 100).toStringAsFixed(1)}%', 'Completitud del análisis estructural'],
    ]);

    return fila + 6; // 5 filas de datos + 1 encabezado
  }

  /// Crea el análisis de Dirección X con gráfico de barras
  Future<int> _crearAnalisisDireccionX(
    xlsio.Worksheet sheet,
    Map<String, dynamic> datos,
    int filaInicial,
  ) async {
    int fila = filaInicial;

    // Título de sección
    _aplicarEstiloSeccion(sheet, fila, 'ANÁLISIS DETALLADO - DIRECCIÓN X');
    fila++;

    // Verificar si hay datos
    if (!datos.containsKey('estadisticas') ||
        !datos['estadisticas'].containsKey('direccionX')) {
      sheet.getRangeByIndex(fila, 1).setText('No hay datos de dirección X disponibles');
      return fila + 1;
    }

    Map<String, dynamic> estadisticasDireccionX = datos['estadisticas']['direccionX'];

    // Preparar datos para la tabla y el gráfico
    List<MapEntry<String, dynamic>> elementosOrdenados = estadisticasDireccionX.entries
        .where((entry) => entry.value['conteo'] > 0)
        .toList()
      ..sort((a, b) => b.value['conteo'].compareTo(a.value['conteo']));

    int totalElementos = elementosOrdenados.fold(
        0, (sum, entry) => sum + entry.value['conteo'] as int);

    // Crear tabla de datos con características específicas de dirección X
    final posicionesGraficos = _crearTablaElementosEstructurales(
        sheet, fila, elementosOrdenados, totalElementos, 'Dirección X',
        _obtenerCaracteristicasDireccionX());
    final int filaFinal = posicionesGraficos['filaFinal']!;
    fila = filaFinal;
    fila += 2;

    // Crear gráfico de barras
    if (elementosOrdenados.isNotEmpty) {
      fila = await _crearGraficoBarras(
          sheet,
          fila,
          posicionesGraficos,
          'Distribución de Elementos Estructurales - Dirección X',
          'Tipo de Elemento',
          'Cantidad de Inmuebles');
    }

    return fila;
  }

  /// Crea el análisis de Dirección Y con gráfico de barras
  Future<int> _crearAnalisisDireccionY(
    xlsio.Worksheet sheet,
    Map<String, dynamic> datos,
    int filaInicial,
  ) async {
    int fila = filaInicial;

    // Título de sección
    _aplicarEstiloSeccion(sheet, fila, 'ANÁLISIS DETALLADO - DIRECCIÓN Y');
    fila++;

    // Verificar si hay datos
    if (!datos.containsKey('estadisticas') ||
        !datos['estadisticas'].containsKey('direccionY')) {
      sheet.getRangeByIndex(fila, 1).setText('No hay datos de dirección Y disponibles');
      return fila + 1;
    }

    Map<String, dynamic> estadisticasDireccionY = datos['estadisticas']['direccionY'];

    // Preparar datos
    List<MapEntry<String, dynamic>> elementosOrdenados = estadisticasDireccionY.entries
        .where((entry) => entry.value['conteo'] > 0)
        .toList()
      ..sort((a, b) => b.value['conteo'].compareTo(a.value['conteo']));

    int totalElementos = elementosOrdenados.fold(
        0, (sum, entry) => sum + entry.value['conteo'] as int);

    // Crear tabla de datos
    final posicionesGraficos = _crearTablaElementosEstructurales(
        sheet, fila, elementosOrdenados, totalElementos, 'Dirección Y',
        _obtenerCaracteristicasDireccionY());
    final int filaFinal = posicionesGraficos['filaFinal']!;
    fila = filaFinal;
    fila += 2;

    // Crear gráfico de barras
    if (elementosOrdenados.isNotEmpty) {
      fila = await _crearGraficoBarras(
          sheet,
          fila,
          posicionesGraficos,
          'Distribución de Elementos Estructurales - Dirección Y',
          'Tipo de Elemento',
          'Cantidad de Inmuebles');
    }

    return fila;
  }

  /// Crea el análisis de Muros de Mampostería con gráfico de barras
  Future<int> _crearAnalisisMurosMamposteria(
    xlsio.Worksheet sheet,
    Map<String, dynamic> datos,
    int filaInicial,
  ) async {
    int fila = filaInicial;

    // Título de sección
    _aplicarEstiloSeccion(sheet, fila, 'ANÁLISIS DETALLADO - MUROS DE MAMPOSTERÍA');
    fila++;

    // Verificar si hay datos
    if (!datos.containsKey('estadisticas') ||
        !datos['estadisticas'].containsKey('murosMamposteria')) {
      sheet.getRangeByIndex(fila, 1).setText('No hay datos de muros de mampostería disponibles');
      return fila + 1;
    }

    Map<String, dynamic> estadisticasMuros = datos['estadisticas']['murosMamposteria'];

    // Preparar datos
    List<MapEntry<String, dynamic>> elementosOrdenados = estadisticasMuros.entries
        .where((entry) => entry.value['conteo'] > 0)
        .toList()
      ..sort((a, b) => b.value['conteo'].compareTo(a.value['conteo']));

    int totalElementos = elementosOrdenados.fold(
        0, (sum, entry) => sum + entry.value['conteo'] as int);

    // Crear tabla de datos
    final posicionesGraficos = _crearTablaElementosEstructurales(
        sheet, fila, elementosOrdenados, totalElementos, 'Muros de Mampostería',
        _obtenerCaracteristicasMuros());
    final int filaFinal = posicionesGraficos['filaFinal']!;
    fila = filaFinal;
    fila += 2;

    // Crear gráfico de barras
    if (elementosOrdenados.isNotEmpty) {
      fila = await _crearGraficoBarras(
          sheet,
          fila,
          posicionesGraficos,
          'Distribución de Muros de Mampostería',
          'Tipo de Muro',
          'Cantidad de Inmuebles');
    }

    return fila;
  }

  /// Crea el análisis de Sistemas de Piso con gráfico de barras
  Future<int> _crearAnalisisSistemasPiso(
    xlsio.Worksheet sheet,
    Map<String, dynamic> datos,
    int filaInicial,
  ) async {
    int fila = filaInicial;

    // Título de sección
    _aplicarEstiloSeccion(sheet, fila, 'ANÁLISIS DETALLADO - SISTEMAS DE PISO');
    fila++;

    // Verificar si hay datos
    if (!datos.containsKey('estadisticas') ||
        !datos['estadisticas'].containsKey('sistemasPiso')) {
      sheet.getRangeByIndex(fila, 1).setText('No hay datos de sistemas de piso disponibles');
      return fila + 1;
    }

    Map<String, dynamic> estadisticasPiso = datos['estadisticas']['sistemasPiso'];

    // Preparar datos
    List<MapEntry<String, dynamic>> elementosOrdenados = estadisticasPiso.entries
        .where((entry) => entry.value['conteo'] > 0)
        .toList()
      ..sort((a, b) => b.value['conteo'].compareTo(a.value['conteo']));

    int totalElementos = elementosOrdenados.fold(
        0, (sum, entry) => sum + entry.value['conteo'] as int);

    // Crear tabla de datos
    final posicionesGraficos = _crearTablaElementosEstructurales(
        sheet, fila, elementosOrdenados, totalElementos, 'Sistemas de Piso',
        _obtenerCaracteristicasPiso());
    final int filaFinal = posicionesGraficos['filaFinal']!;
    fila = filaFinal;
    fila += 2;

    // Crear gráfico de barras
    if (elementosOrdenados.isNotEmpty) {
      fila = await _crearGraficoBarras(
          sheet,
          fila,
          posicionesGraficos,
          'Distribución de Sistemas de Piso',
          'Tipo de Sistema',
          'Cantidad de Inmuebles');
    }

    return fila;
  }

  /// Crea el análisis de Sistemas de Techo con gráfico de barras
  Future<int> _crearAnalisisSistemasTecho(
    xlsio.Worksheet sheet,
    Map<String, dynamic> datos,
    int filaInicial,
  ) async {
    int fila = filaInicial;

    // Título de sección
    _aplicarEstiloSeccion(sheet, fila, 'ANÁLISIS DETALLADO - SISTEMAS DE TECHO');
    fila++;

    // Verificar si hay datos
    if (!datos.containsKey('estadisticas') ||
        !datos['estadisticas'].containsKey('sistemasTecho')) {
      sheet.getRangeByIndex(fila, 1).setText('No hay datos de sistemas de techo disponibles');
      return fila + 1;
    }

    Map<String, dynamic> estadisticasTecho = datos['estadisticas']['sistemasTecho'];

    // Preparar datos
    List<MapEntry<String, dynamic>> elementosOrdenados = estadisticasTecho.entries
        .where((entry) => entry.value['conteo'] > 0)
        .toList()
      ..sort((a, b) => b.value['conteo'].compareTo(a.value['conteo']));

    int totalElementos = elementosOrdenados.fold(
        0, (sum, entry) => sum + entry.value['conteo'] as int);

    // Crear tabla de datos
    final posicionesGraficos = _crearTablaElementosEstructurales(
        sheet, fila, elementosOrdenados, totalElementos, 'Sistemas de Techo',
        _obtenerCaracteristicasTecho());
    final int filaFinal = posicionesGraficos['filaFinal']!;
    fila = filaFinal;
    fila += 2;

    // Crear gráfico de barras
    if (elementosOrdenados.isNotEmpty) {
      fila = await _crearGraficoBarras(
          sheet,
          fila,
          posicionesGraficos,
          'Distribución de Sistemas de Techo',
          'Tipo de Sistema',
          'Cantidad de Inmuebles');
    }

    return fila;
  }

  /// Crea el análisis de Cimentación con gráfico de barras
  Future<int> _crearAnalisisCimentacion(
    xlsio.Worksheet sheet,
    Map<String, dynamic> datos,
    int filaInicial,
  ) async {
    int fila = filaInicial;

    // Título de sección
    _aplicarEstiloSeccion(sheet, fila, 'ANÁLISIS DETALLADO - CIMENTACIÓN');
    fila++;

    // Verificar si hay datos
    if (!datos.containsKey('estadisticas') ||
        !datos['estadisticas'].containsKey('cimentacion')) {
      sheet.getRangeByIndex(fila, 1).setText('No hay datos de cimentación disponibles');
      return fila + 1;
    }

    Map<String, dynamic> estadisticasCimentacion = datos['estadisticas']['cimentacion'];

    // Preparar datos
    List<MapEntry<String, dynamic>> elementosOrdenados = estadisticasCimentacion.entries
        .where((entry) => entry.value['conteo'] > 0)
        .toList()
      ..sort((a, b) => b.value['conteo'].compareTo(a.value['conteo']));

    int totalElementos = elementosOrdenados.fold(
        0, (sum, entry) => sum + entry.value['conteo'] as int);

    // Crear tabla de datos
    final posicionesGraficos = _crearTablaElementosEstructurales(
        sheet, fila, elementosOrdenados, totalElementos, 'Cimentación',
        _obtenerCaracteristicasCimentacion());
    final int filaFinal = posicionesGraficos['filaFinal']!;
    fila = filaFinal;
    fila += 2;

    // Crear gráfico de barras
    if (elementosOrdenados.isNotEmpty) {
      fila = await _crearGraficoBarras(
          sheet,
          fila,
          posicionesGraficos,
          'Distribución de Tipos de Cimentación',
          'Tipo de Cimentación',
          'Cantidad de Inmuebles');
    }

    return fila;
  }

  /// Crea sección de conclusiones y comparativas
  void _crearSeccionConclusiones(
    xlsio.Worksheet sheet,
    Map<String, dynamic> datos,
    Map<String, dynamic> metadatos,
    int filaInicial,
  ) {
    int fila = filaInicial;

    // Título de sección
    _aplicarEstiloSeccion(sheet, fila, 'COMPARATIVA Y CONCLUSIONES ESTRUCTURALES');
    fila++;

    // Análisis comparativo
    final xlsio.Range rangoAnalisis = sheet.getRangeByIndex(fila, 1, fila, 3);
    rangoAnalisis.merge();
    rangoAnalisis.setText('ANÁLISIS COMPARATIVO SISTEMA ESTRUCTURAL');
    rangoAnalisis.cellStyle.bold = true;
    rangoAnalisis.cellStyle.backColor = '#FFE2CC';
    fila++;

    // Encontrar elementos predominantes de cada categoría
    List<String> elementosPredominantes = _encontrarElementosPredominantes(datos);

    // Mostrar elementos predominantes
    for (String elemento in elementosPredominantes) {
      sheet.getRangeByIndex(fila, 1, fila, 3).merge();
      sheet.getRangeByIndex(fila, 1).setText(elemento);
      sheet.getRangeByIndex(fila, 1).cellStyle.backColor = '#F0F8FF';
      fila++;
    }

    fila += 1;

    // Conclusiones
    final xlsio.Range rangoConclusiones = sheet.getRangeByIndex(fila, 1, fila, 3);
    rangoConclusiones.merge();
    rangoConclusiones.setText('CONCLUSIONES TÉCNICAS:');
    rangoConclusiones.cellStyle.bold = true;
    rangoConclusiones.cellStyle.backColor = '#FFF2CC';
    fila++;

    String conclusiones = metadatos['conclusiones'] ?? 
        'Análisis del sistema estructural completado. Se identificaron los elementos predominantes en cada categoría para optimizar las estrategias de evaluación y refuerzo estructural.';
    
    List<String> lineasConclusiones = conclusiones
        .split('\n')
        .where((linea) => linea.trim().isNotEmpty)
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

  // === MÉTODOS AUXILIARES ESPECÍFICOS PARA SISTEMA ESTRUCTURAL ===

  /// Obtiene características específicas de dirección X
  Map<String, String> _obtenerCaracteristicasDireccionX() {
    return {
      'Marcos de concreto': 'Sistema rígido con alta resistencia lateral',
      'Muros de concreto': 'Estructura monolítica resistente a cargas',
      'Muros confinados': 'Buena resistencia sísmica y económico',
      'Muros de adobe o bahareque': 'Material vulnerable, requiere refuerzo',
      'Otros': 'Requiere evaluación específica',
    };
  }

  /// Obtiene características específicas de dirección Y
  Map<String, String> _obtenerCaracteristicasDireccionY() {
    return {
      'Marcos de concreto': 'Continuidad estructural en ambas direcciones',
      'Muros de concreto': 'Distribución uniforme de rigidez',
      'Muros confinados': 'Resistencia adecuada en dirección transversal',
      'Muros de adobe o bahareque': 'Vulnerabilidad crítica bidireccional',
      'Otros': 'Evaluación detallada requerida',
    };
  }

  /// Obtiene características específicas de muros de mampostería
  Map<String, String> _obtenerCaracteristicasMuros() {
    return {
      'Ladrillo recocido con mortero cemento': 'Alta resistencia y durabilidad',
      'Ladrillo recocido con mortero cal': 'Resistencia media, flexible',
      'Block de concreto con mortero cemento': 'Buena resistencia estructural',
      'Adobe': 'Baja resistencia, vulnerable a humedad',
      'Piedra': 'Alta resistencia pero comportamiento frágil',
      'Otros': 'Características variables según material',
    };
  }

  /// Obtiene características específicas de sistemas de piso
  Map<String, String> _obtenerCaracteristicasPiso() {
    return {
      'Losa maciza': 'Distribución uniforme de cargas, alta rigidez',
      'Losa reticular': 'Optimización de materiales, buena resistencia',
      'Vigueta y bovedilla': 'Sistema prefabricado económico',
      'Madera': 'Flexible, requiere mantenimiento constante',
      'Lámina': 'Temporal, baja resistencia estructural',
      'Otros': 'Evaluación específica necesaria',
    };
  }

  /// Obtiene características específicas de sistemas de techo
  Map<String, String> _obtenerCaracteristicasTecho() {
    return {
      'Losa maciza': 'Máxima resistencia y durabilidad',
      'Losa reticular': 'Balance peso-resistencia óptimo',
      'Vigueta y bovedilla': 'Solución económica estándar',
      'Teja': 'Tradicional, requiere soporte adecuado',
      'Lámina': 'Ligero pero vulnerable a viento',
      'Madera': 'Natural pero requiere tratamiento',
      'Otros': 'Características según especificación',
    };
  }

  /// Obtiene características específicas de cimentación
  Map<String, String> _obtenerCaracteristicasCimentacion() {
    return {
      'Zapatas aisladas': 'Adecuada para suelos resistentes',
      'Zapatas corridas': 'Distribución lineal de cargas',
      'Losa de cimentación': 'Ideal para suelos blandos',
      'Pilotes': 'Solución para suelos problemáticos',
      'Mampostería de piedra': 'Tradicional, depende de la calidad',
      'Otros': 'Requiere análisis geotécnico específico',
    };
  }

  /// Encuentra elementos predominantes de cada categoría estructural
  List<String> _encontrarElementosPredominantes(Map<String, dynamic> datos) {
    List<String> predominantes = [];
    
    // Categorías a analizar
    final Map<String, String> categorias = {
      'direccionX': 'Dirección X predominante',
      'direccionY': 'Dirección Y predominante',
      'murosMamposteria': 'Mampostería predominante',
      'sistemasPiso': 'Sistema de piso predominante',
      'sistemasTecho': 'Sistema de techo predominante',
      'cimentacion': 'Cimentación predominante',
    };

    if (datos.containsKey('estadisticas')) {
      categorias.forEach((categoriaId, descripcion) {
        if (datos['estadisticas'].containsKey(categoriaId)) {
          Map<String, dynamic> estadisticasCategoria = datos['estadisticas'][categoriaId];
          
          // Encontrar el elemento más común
          String elementoPredominante = '';
          int maxConteo = 0;
          
          estadisticasCategoria.forEach((elemento, stats) {
            int conteo = stats['conteo'] ?? 0;
            if (conteo > maxConteo) {
              maxConteo = conteo;
              elementoPredominante = elemento;
            }
          });
          
          if (elementoPredominante.isNotEmpty) {
            predominantes.add('$descripcion: $elementoPredominante ($maxConteo casos)');
          }
        }
      });
    }

    return predominantes;
  }

  /// Aplica estilo de sección (título destacado)
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

  /// Crea tabla de resumen con formato (idéntico al base)
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

  /// Crea tabla de elementos estructurales con formato específico
  Map<String, int> _crearTablaElementosEstructurales(
      xlsio.Worksheet sheet, 
      int filaInicial,
      List<MapEntry<String, dynamic>> datos, 
      int total,
      String tipoElemento,
      Map<String, String> caracteristicas) {
    int fila = filaInicial;

    // Rangos para gráfica
    int filaGraficaInicio = 0;
    int filaGraficaFin = 0;
    int columnaGraficaInicio = 0;
    int columnaGraficaFin = 0;

    // Encabezados específicos para elementos estructurales
    sheet.getRangeByIndex(fila, 1).setText('Elemento Estructural');
    sheet.getRangeByIndex(fila, 2).setText('Cantidad');
    sheet.getRangeByIndex(fila, 3).setText('Porcentaje');
    sheet.getRangeByIndex(fila, 4, fila, 5).merge();
    sheet.getRangeByIndex(fila, 4).setText('Características Técnicas');
    filaGraficaInicio = fila;
    columnaGraficaInicio = 1;

    final xlsio.Range rangoHeader = sheet.getRangeByIndex(fila, 1, fila, 5);
    rangoHeader.cellStyle.bold = true;
    rangoHeader.cellStyle.backColor = COLOR_TABLE_HEADER;
    rangoHeader.cellStyle.fontColor = '#FFFFFF';
    rangoHeader.cellStyle.borders.all.lineStyle = xlsio.LineStyle.thin;
    fila++;

    // Datos de elementos estructurales
    for (int i = 0; i < datos.length; i++) {
      var entry = datos[i];
      String elemento = entry.key;
      int conteo = entry.value['conteo'];
      double porcentaje = total > 0 ? (conteo / total) * 100 : 0;
      String caracteristica = caracteristicas[elemento] ?? 'Consultar especificaciones técnicas específicas';

      // Determinar observaciones técnicas
      String observacion = '';
      if (i == 0) observacion = 'Sistema predominante';
      else if (porcentaje > 25) observacion = 'Uso significativo';
      else if (porcentaje > 10) observacion = 'Uso moderado';
      else observacion = 'Uso menor';

      sheet.getRangeByIndex(fila, 1).setText(elemento);
      sheet.getRangeByIndex(fila, 2).setNumber(conteo.toDouble());
      sheet.getRangeByIndex(fila, 3).setText('${porcentaje.toStringAsFixed(1)}%');
      sheet.getRangeByIndex(fila, 4, fila, 5).merge();
      sheet.getRangeByIndex(fila, 4).setText('$caracteristica. $observacion');
      sheet.getRangeByIndex(fila, 4).cellStyle.wrapText = true;

      // Alternar colores con consideraciones técnicas
      String bgColor = '#FFFFFF';
      if (elemento.toLowerCase().contains('adobe') || elemento.toLowerCase().contains('bahareque')) {
        bgColor = '#FFE8E8'; // Rojo para elementos vulnerables
      } else if (elemento.toLowerCase().contains('concreto') || elemento.toLowerCase().contains('losa')) {
        bgColor = '#E8F5E8'; // Verde para elementos resistentes
      } else {
        bgColor = fila % 2 == 0 ? '#F2F2F2' : '#FFFFFF';
      }
      
      final xlsio.Range rangoFila = sheet.getRangeByIndex(fila, 1, fila, 5);
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
    sheet.getRangeByIndex(fila, 4).setText('Suma de todos los elementos en $tipoElemento');

    final xlsio.Range rangoTotal = sheet.getRangeByIndex(fila, 1, fila, 5);
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

  /// Crea un gráfico de barras (idéntico al formato base pero adaptado para elementos estructurales)
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

      // Configura tu gráfico
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
      print('⚠️ [EXCEL-SISTEMA-V2] Error al crear gráfico: $e');
      sheet.getRangeByIndex(filaInicial, 1).setText('Gráfico no disponible');
      return filaInicial + 1;
    }
  }

  /// Guarda el archivo Excel en el sistema (idéntico al base)
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
        print('✅ [EXCEL-SISTEMA-V2] Archivo guardado: $rutaCompleta (${await archivo.length()} bytes)');
        return rutaCompleta;
      } else {
        throw Exception('El archivo no se guardó correctamente');
      }
    } catch (e) {
      print('❌ [EXCEL-SISTEMA-V2] Error al guardar archivo: $e');
      throw Exception('Error al guardar archivo Excel: $e');
    }
  }

  /// Limpia el nombre del archivo para el sistema (idéntico al base)
  String _limpiarNombreArchivo(String nombre) {
    return nombre
        .toLowerCase()
        .replaceAll(' ', '_')
        .replaceAll(RegExp(r'[^a-z0-9_]'), '')
        .replaceAll(RegExp(r'_+'), '_')
        .trim();
  }
}