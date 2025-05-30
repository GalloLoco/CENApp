// lib/data/reportes/resumen_general_excel.dart

import 'dart:io';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xlsio;
import 'package:syncfusion_officechart/officechart.dart';

import 'package:syncfusion_flutter_xlsio/xlsio.dart'; // Ensure this import is added for ExcelCFType
import 'package:intl/intl.dart';
import '../services/file_storage_service.dart';

/// Servicio optimizado para generar reportes de Resumen General Excel usando Syncfusion
/// Basado en la estructura de usovivienda_topografico_Excel.dart
/// Adaptado para mostrar distribución geográfica y temporal de evaluaciones
class ExcelReporteServiceResumenGeneralV2 {
  final FileStorageService _fileService = FileStorageService();

  // Constantes para estilos y formato - Idénticas al archivo base
  static const String FONT_NAME = 'Calibri';
  static const int HEADER_FONT_SIZE = 16;
  static const int SUBTITLE_FONT_SIZE = 14;
  static const int SECTION_FONT_SIZE = 12;
  static const int NORMAL_FONT_SIZE = 10;

  // Colores corporativos en formato Excel (RGB) - Idénticos al archivo base
  static const String COLOR_HEADER = '#1F4E79';
  static const String COLOR_SUBTITLE = '#2F5F8F';
  static const String COLOR_SECTION = '#70AD47';
  static const String COLOR_TABLE_HEADER = '#9BC2E6';

  /// Genera reporte de Resumen General con distribución geográfica y temporal
  /// Incluye gráficos de barras similares a la versión PDF
  /// Mantiene la misma estructura que el archivo base usovivienda_topografico_Excel.dart
  Future<String> generarReporteResumenGeneral({
    required String titulo,
    required String subtitulo,
    required Map<String, dynamic> datos,
    required List<Map<String, dynamic>> tablas,
    required Map<String, dynamic> metadatos,
    Directory? directorio,
  }) async {
    try {
      print('📊 [EXCEL-RESUMEN-V2] Iniciando generación con Syncfusion: $titulo');

      // Crear nuevo libro de Excel - Idéntico al archivo base
      final xlsio.Workbook workbook = xlsio.Workbook();

      // Crear hoja principal - Idéntico al archivo base
      final xlsio.Worksheet sheet = workbook.worksheets[0];
      sheet.name = 'Resumen General';

      // Configurar anchos de columna óptimos - Idéntico al archivo base
      _configurarAnchoColumnas(sheet);

      int filaActual = 1; // Syncfusion usa base 1

      // === SECCIÓN 1: ENCABEZADO === - Estructura idéntica
      filaActual =
          _crearEncabezado(sheet, titulo, subtitulo, metadatos, filaActual);
      filaActual += 2;

      // === SECCIÓN 2: FILTROS APLICADOS === - Estructura idéntica
      filaActual = _crearSeccionFiltros(sheet, metadatos, filaActual);
      filaActual += 2;

      // === SECCIÓN 3: RESUMEN ESTADÍSTICO === - Adaptado para resumen general
      filaActual =
          _crearResumenEstadistico(sheet, datos, metadatos, filaActual);
      filaActual += 2;

      // === SECCIÓN 4: ANÁLISIS DISTRIBUCIÓN GEOGRÁFICA CON GRÁFICO === - Adaptado
      filaActual = await _crearAnalisisDistribucionGeografica(sheet, datos, filaActual);
      filaActual += 2;

      // === SECCIÓN 5: ANÁLISIS DISTRIBUCIÓN TEMPORAL CON GRÁFICO === - Adaptado
      filaActual = await _crearAnalisisDistribucionTemporal(sheet, datos, filaActual);
      filaActual += 2;

      // === SECCIÓN 6: CONCLUSIONES === - Estructura idéntica
      _crearSeccionConclusiones(sheet, datos, metadatos, filaActual);

      // Guardar archivo - Idéntico al archivo base
      final String rutaArchivo =
          await _guardarArchivo(workbook, titulo, directorio);

      // Liberar recursos - Idéntico al archivo base
      workbook.dispose();

      print('✅ [EXCEL-RESUMEN-V2] Reporte generado exitosamente: $rutaArchivo');
      return rutaArchivo;
    } catch (e) {
      print('❌ [EXCEL-RESUMEN-V2] Error al generar reporte: $e');
      throw Exception('Error al generar reporte Excel: $e');
    }
  }

  /// Configura los anchos de columna óptimos para el reporte
  /// Idéntico al archivo base
  void _configurarAnchoColumnas(xlsio.Worksheet sheet) {
    sheet.getRangeByIndex(1, 1, 100, 1).columnWidth = 30; // Columna A
    sheet.getRangeByIndex(1, 2, 100, 2).columnWidth = 15; // Columna B
    sheet.getRangeByIndex(1, 3, 100, 3).columnWidth = 15; // Columna C
    sheet.getRangeByIndex(1, 4, 100, 4).columnWidth = 25; // Columna D
    sheet.getRangeByIndex(1, 5, 100, 5).columnWidth = 20; // Columna E
    sheet.getRangeByIndex(1, 6, 100, 6).columnWidth = 20; // Columna F
  }

  /// Crea el encabezado del reporte con formato profesional
  /// Idéntico al archivo base
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
    final String fechaGeneracion =
        DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now());
    final xlsio.Range rangoFecha = sheet.getRangeByIndex(fila, 1, fila, 6);
    rangoFecha.merge();
    rangoFecha.setText('Generado el: $fechaGeneracion');
    rangoFecha.cellStyle.fontSize = NORMAL_FONT_SIZE.toDouble();
    rangoFecha.cellStyle.fontName = FONT_NAME;
    rangoFecha.cellStyle.hAlign = xlsio.HAlignType.center;
    rangoFecha.cellStyle.backColor = '#E7E6E6';

    return fila;
  }

  /// Crea la sección de filtros aplicados
  /// Idéntico al archivo base
  int _crearSeccionFiltros(
    xlsio.Worksheet sheet,
    Map<String, dynamic> metadatos,
    int filaInicial,
  ) {
    int fila = filaInicial;

    // Título de sección
    _aplicarEstiloSeccion(sheet, fila, 'FILTROS APLICADOS');
    fila++;

    // Lista de filtros
    final List<List<String>> filtros = [
      ['Nombre inmueble:', metadatos['nombreInmueble'] ?? 'Todos'],
      ['Período:', '${metadatos['fechaInicio']} - ${metadatos['fechaFin']}'],
      ['Usuario creador:', metadatos['usuarioCreador'] ?? 'Todos'],
      ['Total formatos:', '${metadatos['totalFormatos']}'],
    ];

    // Agregar ubicaciones si existen
    if (metadatos['ubicaciones'] != null &&
        metadatos['ubicaciones'].isNotEmpty) {
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

  /// Crea el resumen estadístico general - ADAPTADO para resumen general
  int _crearResumenEstadistico(
    xlsio.Worksheet sheet,
    Map<String, dynamic> datos,
    Map<String, dynamic> metadatos,
    int filaInicial,
  ) {
    int fila = filaInicial;

    // Título de sección
    _aplicarEstiloSeccion(sheet, fila, 'RESUMEN ESTADÍSTICO GENERAL');
    fila++;

    final int totalFormatos = metadatos['totalFormatos'] ?? 0;

    // Calcular estadísticas específicas para resumen general
    int ciudadesCubiertas = 0;
    int coloniasCubiertas = 0;
    int periodosCubiertos = 0;
    
    // Extraer datos de distribución geográfica y temporal
    if (datos['distribucionGeografica']?['ciudades'] != null) {
      ciudadesCubiertas = datos['distribucionGeografica']['ciudades'].length;
    }
    
    if (datos['distribucionGeografica']?['colonias'] != null) {
      coloniasCubiertas = datos['distribucionGeografica']['colonias'].length;
    }
    
    if (datos['distribucionTemporal']?['meses'] != null) {
      periodosCubiertos = datos['distribucionTemporal']['meses'].length;
    }

    // Crear tabla de resumen - Estructura idéntica al archivo base
    _crearTablaResumen(sheet, fila, [
      ['Total de inmuebles evaluados', '$totalFormatos', '100% de la muestra'],
      ['Ciudades cubiertas', '$ciudadesCubiertas', 'Cobertura geográfica'],
      ['Colonias identificadas', '$coloniasCubiertas', 'Distribución local'],
      ['Períodos analizados', '$periodosCubiertos', 'Cobertura temporal'],
      [
        'Promedio mensual',
        periodosCubiertos > 0 ? '${(totalFormatos / periodosCubiertos).toStringAsFixed(1)}' : '0',
        'Evaluaciones por período'
      ],
    ]);

    return fila + 6; // 5 filas de datos + 1 encabezado
  }

  /// Crea el análisis de distribución geográfica con gráfico de barras - ADAPTADO
  Future<int> _crearAnalisisDistribucionGeografica(
    xlsio.Worksheet sheet,
    Map<String, dynamic> datos,
    int filaInicial,
  ) async {
    int fila = filaInicial;

    // Título de sección
    _aplicarEstiloSeccion(sheet, fila, 'ANÁLISIS DETALLADO DE DISTRIBUCIÓN GEOGRÁFICA');
    fila++;

    // Verificar si hay datos de ciudades
    if (!datos.containsKey('distribucionGeografica') ||
        !datos['distribucionGeografica'].containsKey('ciudades')) {
      sheet
          .getRangeByIndex(fila, 1)
          .setText('No hay datos de distribución geográfica disponibles');
      return fila + 1;
    }

    Map<String, int> ciudades =
        Map<String, int>.from(datos['distribucionGeografica']['ciudades']);

    // Preparar datos para la tabla y el gráfico - Filtrar ciudades con datos
    List<MapEntry<String, int>> ciudadesOrdenadas = ciudades.entries
        .where((entry) => entry.value > 0)
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    int totalCiudades = ciudadesOrdenadas.fold(
        0, (sum, entry) => sum + entry.value);

    // Crear tabla de datos - Estructura similar al archivo base
    final posicionesGraficos = _crearTablaCiudades(sheet, fila, ciudadesOrdenadas, totalCiudades);
    final int filaFinal = posicionesGraficos['filaFinal']!;
    fila = filaFinal;
    fila += 2;

    // Crear gráfico de barras - Idéntico al archivo base
    if (ciudadesOrdenadas.isNotEmpty) {
      fila = await _crearGraficoBarras(
          sheet,
          fila,
          posicionesGraficos,
          'Distribución de Evaluaciones por Ciudad',
          'Ciudad',
          'Cantidad de Evaluaciones');
    }

    return fila;
  }

  /// Crea el análisis de distribución temporal con gráfico de barras - ADAPTADO
  Future<int> _crearAnalisisDistribucionTemporal(
    xlsio.Worksheet sheet,
    Map<String, dynamic> datos,
    int filaInicial,
  ) async {
    int fila = filaInicial;

    // Título de sección
    _aplicarEstiloSeccion(sheet, fila, 'ANÁLISIS DETALLADO DE DISTRIBUCIÓN TEMPORAL');
    fila++;

    // Verificar si hay datos temporales
    if (!datos.containsKey('distribucionTemporal') ||
        !datos['distribucionTemporal'].containsKey('meses')) {
      sheet
          .getRangeByIndex(fila, 1)
          .setText('No hay datos de distribución temporal disponibles');
      return fila + 1;
    }

    Map<String, int> meses =
        Map<String, int>.from(datos['distribucionTemporal']['meses']);

    // Preparar datos - Ordenar cronológicamente
    List<MapEntry<String, int>> mesesOrdenados = meses.entries
        .where((entry) => entry.value > 0)
        .toList()
      ..sort((a, b) {
        try {
          final fechaA = DateFormat('MM/yyyy').parse(a.key);
          final fechaB = DateFormat('MM/yyyy').parse(b.key);
          return fechaA.compareTo(fechaB);
        } catch (e) {
          return a.key.compareTo(b.key);
        }
      });

    int totalMeses = mesesOrdenados.fold(
        0, (sum, entry) => sum + entry.value);

    // Mapeo de características temporales
    Map<String, String> caracteristicasMeses = {
      'Alta actividad': 'Período de mayor concentración de evaluaciones',
      'Actividad normal': 'Período con actividad estándar de evaluaciones',
      'Baja actividad': 'Período con menor concentración de evaluaciones',
    };

    // Crear tabla de datos - Estructura similar al archivo base
    final posicionesGraficos = _crearTablaMeses(sheet, fila, mesesOrdenados,
        totalMeses, caracteristicasMeses);
    final int filaFinal = posicionesGraficos['filaFinal']!;
    fila = filaFinal;
    fila += 2;

    // Crear gráfico de barras - Idéntico al archivo base
    if (mesesOrdenados.isNotEmpty) {
      fila = await _crearGraficoBarras(
          sheet,
          fila,
          posicionesGraficos,
          'Distribución Temporal de Evaluaciones',
          'Período (MM/YYYY)',
          'Cantidad de Evaluaciones');
    }

    return fila;
  }

  /// Crea sección de conclusiones y comparativas - Estructura idéntica
  void _crearSeccionConclusiones(
    xlsio.Worksheet sheet,
    Map<String, dynamic> datos,
    Map<String, dynamic> metadatos,
    int filaInicial,
  ) {
    int fila = filaInicial;

    // Título de sección
    _aplicarEstiloSeccion(sheet, fila, 'COMPARATIVA Y CONCLUSIONES');
    fila++;

    // Análisis comparativo
    final xlsio.Range rangoAnalisis = sheet.getRangeByIndex(fila, 1, fila, 3);
    rangoAnalisis.merge();
    rangoAnalisis.setText('ANÁLISIS COMPARATIVO');
    rangoAnalisis.cellStyle.bold = true;
    rangoAnalisis.cellStyle.backColor = '#FFE2CC';
    fila++;

    // Encontrar elementos predominantes - Adaptado para resumen general
    String ciudadPredominante =
        _encontrarPredominanteCiudad(datos['distribucionGeografica']?['ciudades'] ?? {});
    String mesPredominante =
        _encontrarPredominanteMes(datos['distribucionTemporal']?['meses'] ?? {});

    sheet.getRangeByIndex(fila, 1).setText('Ciudad predominante:');
    sheet.getRangeByIndex(fila, 1).cellStyle.bold = true;
    sheet.getRangeByIndex(fila, 2, fila, 3).merge();
    sheet.getRangeByIndex(fila, 2).setText(ciudadPredominante);
    fila++;

    sheet.getRangeByIndex(fila, 1).setText('Mes más activo:');
    sheet.getRangeByIndex(fila, 1).cellStyle.bold = true;
    sheet.getRangeByIndex(fila, 2, fila, 3).merge();
    sheet.getRangeByIndex(fila, 2).setText(mesPredominante);
    fila += 2;

    // Conclusiones
    final xlsio.Range rangoConclusiones =
        sheet.getRangeByIndex(fila, 1, fila, 3);
    rangoConclusiones.merge();
    rangoConclusiones.setText('CONCLUSIONES:');
    rangoConclusiones.cellStyle.bold = true;
    rangoConclusiones.cellStyle.backColor = '#FFF2CC';
    fila++;

    String conclusiones =
        metadatos['conclusiones'] ?? 'No hay conclusiones disponibles.';
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

  // === MÉTODOS AUXILIARES === (Estructura idéntica al archivo base, adaptando datos)

  /// Aplica estilo de sección (título destacado) - Idéntico
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

  /// Crea tabla de resumen con formato - Idéntico
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

  /// Crea tabla de ciudades con formato - ADAPTADO
  Map<String, int> _crearTablaCiudades(xlsio.Worksheet sheet, int filaInicial,
      List<MapEntry<String, int>> datos, int total) {
    int fila = filaInicial;

    //Rango para grafica
    int filaGraficaInicio = 0;
    int filaGraficaFin = 0;
    int columnaGraficaInicio = 0;
    int columnaGraficaFin = 0;

    // Encabezados
    sheet.getRangeByIndex(fila, 1).setText('Ciudad');
    sheet.getRangeByIndex(fila, 2).setText('Cantidad');
    sheet.getRangeByIndex(fila, 3).setText('Porcentaje');
    sheet.getRangeByIndex(fila, 4).setText('Clasificación');
    filaGraficaInicio = fila;
    columnaGraficaInicio = 1;

    final xlsio.Range rangoHeader = sheet.getRangeByIndex(fila, 1, fila, 4);
    rangoHeader.cellStyle.bold = true;
    rangoHeader.cellStyle.backColor = COLOR_TABLE_HEADER;
    rangoHeader.cellStyle.fontColor = '#FFFFFF';
    rangoHeader.cellStyle.borders.all.lineStyle = xlsio.LineStyle.thin;
    fila++;

    // Datos
    for (int i = 0; i < datos.length; i++) {
      var entry = datos[i];
      String ciudad = entry.key;
      int conteo = entry.value;
      double porcentaje = total > 0 ? (conteo / total) * 100 : 0;

      String clasificacion = '';
      if (i == 0)
        clasificacion = 'Ciudad principal';
      else if (porcentaje > 20)
        clasificacion = 'Ciudad significativa';
      else if (porcentaje > 10)
        clasificacion = 'Ciudad moderada';
      else
        clasificacion = 'Ciudad menor';

      sheet.getRangeByIndex(fila, 1).setText(ciudad);
      sheet.getRangeByIndex(fila, 2).setNumber(conteo.toDouble());
      sheet
          .getRangeByIndex(fila, 3)
          .setText('${porcentaje.toStringAsFixed(1)}%');
      sheet.getRangeByIndex(fila, 4).setText(clasificacion);

      // Alternar colores
      String bgColor = fila % 2 == 0 ? '#F2F2F2' : '#FFFFFF';
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
    sheet.getRangeByIndex(fila, 4).setText('Todas las ciudades');

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

  /// Crea tabla de meses con características - ADAPTADO
  Map<String, int> _crearTablaMeses(
      xlsio.Worksheet sheet,
      int filaInicial,
      List<MapEntry<String, int>> datos,
      int total,
      Map<String, String> caracteristicas) {
    int fila = filaInicial;
    //Rango para grafica
    int filaGraficaInicio = 0;
    int filaGraficaFin = 0;
    int columnaGraficaInicio = 0;
    int columnaGraficaFin = 0;

    // Encabezados
    sheet.getRangeByIndex(fila, 1).setText('Período (MM/YYYY)');
    sheet.getRangeByIndex(fila, 2).setText('Cantidad');
    sheet.getRangeByIndex(fila, 3).setText('Porcentaje');
    sheet.getRangeByIndex(fila, 4, fila, 5).merge();
    sheet.getRangeByIndex(fila, 4).setText('Tendencia');
    filaGraficaInicio = fila;
    columnaGraficaInicio = 1;

    final xlsio.Range rangoHeader = sheet.getRangeByIndex(fila, 1, fila, 5);
    rangoHeader.cellStyle.bold = true;
    rangoHeader.cellStyle.backColor = '#A9D18E';
    rangoHeader.cellStyle.fontColor = '#FFFFFF';
    rangoHeader.cellStyle.borders.all.lineStyle = xlsio.LineStyle.thin;
    fila++;

    // Calcular promedio mensual para determinar tendencias
    double promedioMensual = total > 0 ? total / datos.length : 0;

    // Datos
    for (int i = 0; i < datos.length; i++) {
      var entry = datos[i];
      String mes = entry.key;
      int conteo = entry.value;
      double porcentaje = total > 0 ? (conteo / total) * 100 : 0;
      
      String tendencia = '';
      if (conteo > promedioMensual * 1.2) {
        tendencia = 'Alta actividad';
      } else if (conteo > promedioMensual * 0.8) {
        tendencia = 'Actividad normal';
      } else {
        tendencia = 'Baja actividad';
      }

      sheet.getRangeByIndex(fila, 1).setText(mes);
      sheet.getRangeByIndex(fila, 2).setNumber(conteo.toDouble());
      sheet
          .getRangeByIndex(fila, 3)
          .setText('${porcentaje.toStringAsFixed(1)}%');
      sheet.getRangeByIndex(fila, 4, fila, 5).merge();
      sheet.getRangeByIndex(fila, 4).setText(tendencia);
      sheet.getRangeByIndex(fila, 4).cellStyle.wrapText = true;

      // Alternar colores
      String bgColor = fila % 2 == 0 ? '#F2F2F2' : '#FFFFFF';
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
    sheet
        .getRangeByIndex(fila, 4)
        .setText('Todos los períodos analizados');

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

  /// Crea un gráfico de barras similar al PDF - Idéntico al archivo base
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
      print('⚠️ [EXCEL-RESUMEN-V2] Error al crear gráfico: $e');
      sheet.getRangeByIndex(filaInicial, 1).setText('Gráfico no disponible');
      return filaInicial + 1;
    }
  }

  /// Encuentra la ciudad predominante en las estadísticas - ADAPTADO
  String _encontrarPredominanteCiudad(Map<String, dynamic> ciudades) {
    if (ciudades.isEmpty) return 'No determinada';

    String predominante = 'No determinada';
    int maxConteo = 0;

    ciudades.forEach((key, value) {
      int conteo = value is int ? value : 0;
      if (conteo > maxConteo) {
        maxConteo = conteo;
        predominante = key;
      }
    });

    return predominante;
  }

  /// Encuentra el mes predominante en las estadísticas - ADAPTADO
  String _encontrarPredominanteMes(Map<String, dynamic> meses) {
    if (meses.isEmpty) return 'No determinado';

    String predominante = 'No determinado';
    int maxConteo = 0;

    meses.forEach((key, value) {
      int conteo = value is int ? value : 0;
      if (conteo > maxConteo) {
        maxConteo = conteo;
        predominante = key;
      }
    });

    return predominante;
  }

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

  // === MÉTODOS ADICIONALES DE UTILIDAD === (Idénticos al archivo base)

  /// Aplica formato condicional a un rango - Idéntico
  void _aplicarFormatoCondicional(
    xlsio.Worksheet sheet,
    int filaInicio,
    int columnaInicio,
    int filaFin,
    int columnaFin,
    double valorLimite,
    String colorAlto,
    String colorBajo,
  ) {
    final xlsio.Range rango =
        sheet.getRangeByIndex(filaInicio, columnaInicio, filaFin, columnaFin);

    // Crear formato condicional
    final xlsio.ConditionalFormats formats = rango.conditionalFormats;
    final xlsio.ConditionalFormat format1 = formats.addCondition();

    // Condición para valores altos
    format1.formatType = ExcelCFType.cellValue;
    format1.operator = ExcelComparisonOperator.greater;
    format1.firstFormula = valorLimite.toString();
    format1.backColor = colorAlto;

    // Condición para valores bajos
    final xlsio.ConditionalFormat format2 = formats.addCondition();
    format2.formatType = ExcelCFType.cellValue;
    format2.operator = ExcelComparisonOperator.lessOrEqual;
    format2.firstFormula = valorLimite.toString();
    format2.backColor = colorBajo;
  }

  /// Crea un resumen visual con iconos - Adaptado para resumen general
  Future<void> _crearResumenVisual(
    xlsio.Worksheet sheet,
    int filaInicial,
    Map<String, dynamic> estadisticas,
  ) async {
    int fila = filaInicial;

    // Título
    final xlsio.Range rangoTitulo = sheet.getRangeByIndex(fila, 1, fila, 4);
    rangoTitulo.merge();
    rangoTitulo.setText('RESUMEN VISUAL');
    rangoTitulo.cellStyle.bold = true;
    rangoTitulo.cellStyle.fontSize = 12;
    rangoTitulo.cellStyle.backColor = '#4472C4';
    rangoTitulo.cellStyle.fontColor = '#FFFFFF';
    fila++;

    // Indicadores con formato visual - Adaptados para resumen general
    final List<Map<String, dynamic>> indicadores = [
      {
        'titulo': 'Total Evaluados',
        'valor': estadisticas['totalFormatos'] ?? 0,
        'icono': '📊',
        'color': '#4472C4'
      },
      {
        'titulo': 'Ciudad Principal',
        'valor': _encontrarPredominanteCiudad(
            estadisticas['distribucionGeografica']?['ciudades'] ?? {}),
        'icono': '🏙️',
        'color': '#70AD47'
      },
      {
        'titulo': 'Mes Más Activo',
        'valor': _encontrarPredominanteMes(
            estadisticas['distribucionTemporal']?['meses'] ?? {}),
        'icono': '📅',
        'color': '#FFC000'
      },
    ];

    // Crear tarjetas visuales
    for (int i = 0; i < indicadores.length; i++) {
      var indicador = indicadores[i];
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

      // Aplicar color de fondo
      final xlsio.Range rangoTarjeta =
          sheet.getRangeByIndex(fila, col, fila + 1, col + 1);
      rangoTarjeta.cellStyle.backColor = indicador['color'];
      rangoTarjeta.cellStyle.fontColor = '#FFFFFF';
      rangoTarjeta.cellStyle.borders.all.lineStyle = xlsio.LineStyle.thin;
    }
  }

  /// Valida los datos antes de procesarlos - Adaptado para resumen general
  bool _validarDatos(Map<String, dynamic> datos) {
    // Verificar estructura básica para resumen general
    if (!datos.containsKey('distribucionGeografica') ||
        !datos.containsKey('distribucionTemporal')) {
      print('⚠️ [EXCEL-RESUMEN-V2] Estructura de datos incompleta');
      return false;
    }

    // Verificar que hay datos de ciudades o temporal
    if (datos['distribucionGeografica']['ciudades'] == null ||
        datos['distribucionTemporal']['meses'] == null) {
      print('⚠️ [EXCEL-RESUMEN-V2] No hay datos de distribución disponibles');
      return false;
    }

    return true;
  }
}