// lib/data/reportes/material_dominante_excel.dart

import 'dart:io';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xlsio;
import 'package:syncfusion_officechart/officechart.dart';

import 'package:syncfusion_flutter_xlsio/xlsio.dart'; // Ensure this import is added for ExcelCFType
import 'package:intl/intl.dart';
import '../services/file_storage_service.dart';

/// Servicio optimizado para generar reportes Excel de Material Dominante usando Syncfusion
/// Versión 2.0 - Implementación limpia y modular basada en la estructura de uso y topografía
class ExcelReporteMaterialDominanteV2 {
  final FileStorageService _fileService = FileStorageService();

  // Constantes para estilos y formato (idénticas al archivo base)
  static const String FONT_NAME = 'Calibri';
  static const int HEADER_FONT_SIZE = 16;
  static const int SUBTITLE_FONT_SIZE = 14;
  static const int SECTION_FONT_SIZE = 12;
  static const int NORMAL_FONT_SIZE = 10;

  // Colores corporativos en formato Excel (RGB) - mismo esquema
  static const String COLOR_HEADER = '#1F4E79';
  static const String COLOR_SUBTITLE = '#2F5F8F';
  static const String COLOR_SECTION = '#70AD47';
  static const String COLOR_TABLE_HEADER = '#9BC2E6';

  /// Genera reporte de Material Dominante de Construcción
  /// Incluye gráficos de barras similares a la versión PDF pero con datos de materiales
  Future<String> generarReporteMaterialDominante({
    required String titulo,
    required String subtitulo,
    required Map<String, dynamic> datos,
    required List<Map<String, dynamic>> tablas,
    required Map<String, dynamic> metadatos,
    Directory? directorio,
  }) async {
    try {
      print('📊 [EXCEL-MATERIAL-V2] Iniciando generación con Syncfusion: $titulo');

      // Crear nuevo libro de Excel
      final xlsio.Workbook workbook = xlsio.Workbook();

      // Crear hoja principal
      final xlsio.Worksheet sheet = workbook.worksheets[0];
      sheet.name = 'Material Dominante';

      // Configurar anchos de columna óptimos
      _configurarAnchoColumnas(sheet);

      int filaActual = 1; // Syncfusion usa base 1

      // === SECCIÓN 1: ENCABEZADO ===
      filaActual =
          _crearEncabezado(sheet, titulo, subtitulo, metadatos, filaActual);
      filaActual += 2;

      // === SECCIÓN 2: FILTROS APLICADOS ===
      filaActual = _crearSeccionFiltros(sheet, metadatos, filaActual);
      filaActual += 2;

      // === SECCIÓN 3: RESUMEN ESTADÍSTICO ===
      filaActual =
          _crearResumenEstadistico(sheet, datos, metadatos, filaActual);
      filaActual += 2;

      // === SECCIÓN 4: ANÁLISIS MATERIAL DOMINANTE CON GRÁFICO ===
      filaActual = await _crearAnalisisMaterialDominante(sheet, datos, filaActual);
      filaActual += 2;

      // === SECCIÓN 5: ANÁLISIS RESISTENCIA ESTRUCTURAL CON GRÁFICO ===
      filaActual = await _crearAnalisisResistencia(sheet, datos, filaActual);
      filaActual += 2;

      // === SECCIÓN 6: CONCLUSIONES ===
      _crearSeccionConclusiones(sheet, datos, metadatos, filaActual);

      // Guardar archivo
      final String rutaArchivo =
          await _guardarArchivo(workbook, titulo, directorio);

      // Liberar recursos
      workbook.dispose();

      print('✅ [EXCEL-MATERIAL-V2] Reporte generado exitosamente: $rutaArchivo');
      return rutaArchivo;
    } catch (e) {
      print('❌ [EXCEL-MATERIAL-V2] Error al generar reporte: $e');
      throw Exception('Error al generar reporte Excel: $e');
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

  /// Crea el encabezado del reporte con formato profesional (idéntico al base)
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

  /// Crea la sección de filtros aplicados (idéntica al base)
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

  /// Crea el resumen estadístico general adaptado para material dominante
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

    // Calcular estadísticas específicas de material dominante
    int tiposMaterialIdentificados = 0;
    int totalMaterialesDeterminados = 0;
    String materialPredominante = 'No determinado';
    int cantidadPredominante = 0;
    
    if (datos['conteoMateriales'] != null) {
      Map<String, int> conteoMateriales = Map<String, int>.from(datos['conteoMateriales']);
      
      // Contar tipos de materiales con al menos un registro
      tiposMaterialIdentificados = conteoMateriales.values.where((conteo) => conteo > 0).length;
      
      // Total de materiales determinados (suma de todos los conteos)
      totalMaterialesDeterminados = conteoMateriales.values.fold(0, (sum, conteo) => sum + conteo);
      
      // Encontrar material predominante
      if (conteoMateriales.isNotEmpty) {
        final entryPredominante = conteoMateriales.entries
            .where((entry) => entry.value > 0)
            .fold<MapEntry<String, int>?>(null, (prev, curr) => 
                prev == null || curr.value > prev.value ? curr : prev);
        
        if (entryPredominante != null) {
          materialPredominante = entryPredominante.key;
          cantidadPredominante = entryPredominante.value;
        }
      }
    }

    // Crear tabla de resumen
    _crearTablaResumen(sheet, fila, [
      ['Total de inmuebles evaluados', '$totalFormatos', '100% de la muestra'],
      ['Tipos de material identificados', '$tiposMaterialIdentificados', 'Diversidad de materiales'],
      [
        'Inmuebles con material determinado',
        '$totalMaterialesDeterminados',
        'Claridad en identificación'
      ],
      [
        'Material predominante',
        materialPredominante,
        '$cantidadPredominante inmuebles'
      ],
      [
        'Tasa de identificación',
        '${totalFormatos > 0 ? (totalMaterialesDeterminados / totalFormatos * 100).toStringAsFixed(1) : 0}%',
        'Eficiencia del análisis'
      ],
    ]);

    return fila + 6; // 5 filas de datos + 1 encabezado
  }

  /// Crea el análisis de material dominante con gráfico de barras
  Future<int> _crearAnalisisMaterialDominante(
    xlsio.Worksheet sheet,
    Map<String, dynamic> datos,
    int filaInicial,
  ) async {
    int fila = filaInicial;

    // Título de sección
    _aplicarEstiloSeccion(sheet, fila, 'ANÁLISIS DETALLADO DE MATERIAL DOMINANTE');
    fila++;

    // Verificar si hay datos
    if (!datos.containsKey('conteoMateriales') || 
        datos['conteoMateriales'].isEmpty) {
      sheet
          .getRangeByIndex(fila, 1)
          .setText('No hay datos de material dominante disponibles');
      return fila + 1;
    }

    Map<String, int> conteoMateriales = Map<String, int>.from(datos['conteoMateriales']);

    // Preparar datos para la tabla y el gráfico
    List<MapEntry<String, int>> materialesOrdenados = conteoMateriales.entries
        .where((entry) => entry.value > 0)
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    int totalMateriales = materialesOrdenados.fold(
        0, (sum, entry) => sum + entry.value);

    // Crear tabla de datos
    final posicionesGraficos = _crearTablaMateriales(sheet, fila, materialesOrdenados, totalMateriales);
    final int filaFinal = posicionesGraficos['filaFinal']!;
    fila = filaFinal;
    fila += 2;

    // Crear gráfico de barras
    if (materialesOrdenados.isNotEmpty) {
      fila = await _crearGraficoBarras(
          sheet,
          fila,
          posicionesGraficos,
          'Distribución de Material Dominante',
          'Tipo de Material',
          'Cantidad de Inmuebles');
    }

    return fila;
  }

  /// Crea el análisis de resistencia estructural con gráfico de barras
  Future<int> _crearAnalisisResistencia(
    xlsio.Worksheet sheet,
    Map<String, dynamic> datos,
    int filaInicial,
  ) async {
    int fila = filaInicial;

    // Título de sección
    _aplicarEstiloSeccion(sheet, fila, 'ANÁLISIS DE RESISTENCIA ESTRUCTURAL');
    fila++;

    // Verificar si hay datos
    if (!datos.containsKey('conteoMateriales') || 
        datos['conteoMateriales'].isEmpty) {
      sheet
          .getRangeByIndex(fila, 1)
          .setText('No hay datos suficientes para análisis de resistencia');
      return fila + 1;
    }

    Map<String, int> conteoMateriales = Map<String, int>.from(datos['conteoMateriales']);

    // Clasificar materiales por resistencia (basado en el PDF)
    Map<String, List<String>> clasificacionResistencia = {
      'Alta Resistencia': ['Concreto'],
      'Media-Alta Resistencia': ['Ladrillo'],
      'Baja Resistencia': ['Adobe'],
      'Resistencia Variable': ['Madera/Lámina/Otros'],
      'Sin Clasificar': ['No determinado'],
    };

    // Calcular totales por nivel de resistencia
    Map<String, int> resistenciaTotales = {};
    for (var entry in clasificacionResistencia.entries) {
      String nivelResistencia = entry.key;
      List<String> materialesEnNivel = entry.value;
      
      int totalNivel = 0;
      for (String material in materialesEnNivel) {
        if (conteoMateriales.containsKey(material)) {
          totalNivel += conteoMateriales[material]!;
        }
      }
      
      if (totalNivel > 0) {
        resistenciaTotales[nivelResistencia] = totalNivel;
      }
    }

    // Crear tabla de datos de resistencia
    final posicionesGraficos = _crearTablaResistencia(sheet, fila, resistenciaTotales, 
        conteoMateriales.values.fold(0, (sum, val) => sum + val));
    final int filaFinal = posicionesGraficos['filaFinal']!;
    fila = filaFinal;
    fila += 2;

    // Crear gráfico de barras
    if (resistenciaTotales.isNotEmpty) {
      fila = await _crearGraficoBarras(
          sheet,
          fila,
          posicionesGraficos,
          'Distribución por Nivel de Resistencia',
          'Nivel de Resistencia',
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
    _aplicarEstiloSeccion(sheet, fila, 'COMPARATIVA Y CONCLUSIONES');
    fila++;

    // Análisis comparativo
    final xlsio.Range rangoAnalisis = sheet.getRangeByIndex(fila, 1, fila, 3);
    rangoAnalisis.merge();
    rangoAnalisis.setText('ANÁLISIS COMPARATIVO DE MATERIALES');
    rangoAnalisis.cellStyle.bold = true;
    rangoAnalisis.cellStyle.backColor = '#FFE2CC';
    fila++;

    // Encontrar elemento predominante y características
    String materialPredominante = _encontrarMaterialPredominante(datos['conteoMateriales'] ?? {});
    String nivelResistenciaPredominante = _determinarResistencia(materialPredominante);

    sheet.getRangeByIndex(fila, 1).setText('Material predominante:');
    sheet.getRangeByIndex(fila, 1).cellStyle.bold = true;
    sheet.getRangeByIndex(fila, 2, fila, 3).merge();
    sheet.getRangeByIndex(fila, 2).setText(materialPredominante);
    fila++;

    sheet.getRangeByIndex(fila, 1).setText('Nivel de resistencia:');
    sheet.getRangeByIndex(fila, 1).cellStyle.bold = true;
    sheet.getRangeByIndex(fila, 2, fila, 3).merge();
    sheet.getRangeByIndex(fila, 2).setText(nivelResistenciaPredominante);
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

  // === MÉTODOS AUXILIARES ===

  /// Aplica estilo de sección (título destacado) - idéntico al base
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

  /// Crea tabla de resumen con formato (idéntica al base)
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

  /// Crea tabla de materiales con formato
  Map<String, int> _crearTablaMateriales(xlsio.Worksheet sheet, int filaInicial,
      List<MapEntry<String, int>> datos, int total) {
    int fila = filaInicial;

    // Rango para gráfica
    int filaGraficaInicio = 0;
    int filaGraficaFin = 0;
    int columnaGraficaInicio = 0;
    int columnaGraficaFin = 0;

    // Encabezados
    sheet.getRangeByIndex(fila, 1).setText('Material');
    sheet.getRangeByIndex(fila, 2).setText('Cantidad');
    sheet.getRangeByIndex(fila, 3).setText('Porcentaje');
    sheet.getRangeByIndex(fila, 4).setText('Características');
    filaGraficaInicio = fila;
    columnaGraficaInicio = 1;

    final xlsio.Range rangoHeader = sheet.getRangeByIndex(fila, 1, fila, 4);
    rangoHeader.cellStyle.bold = true;
    rangoHeader.cellStyle.backColor = COLOR_TABLE_HEADER;
    rangoHeader.cellStyle.fontColor = '#FFFFFF';
    rangoHeader.cellStyle.borders.all.lineStyle = xlsio.LineStyle.thin;
    fila++;

    // Mapeo de características de materiales (del PDF)
    Map<String, String> caracteristicasMateriales = {
      'Ladrillo': 'Resistente a compresión, buen aislamiento',
      'Concreto': 'Alta resistencia, versatilidad estructural',
      'Adobe': 'Económico, vulnerable a humedad',
      'Madera/Lámina/Otros': 'Flexible, requiere mantenimiento',
      'No determinado': 'Requiere evaluación específica',
    };

    // Datos
    for (int i = 0; i < datos.length; i++) {
      var entry = datos[i];
      String material = entry.key;
      int conteo = entry.value;
      double porcentaje = total > 0 ? (conteo / total) * 100 : 0;
      String caracteristicas = caracteristicasMateriales[material] ?? 'Sin especificar';

      sheet.getRangeByIndex(fila, 1).setText(material);
      sheet.getRangeByIndex(fila, 2).setNumber(conteo.toDouble());
      sheet
          .getRangeByIndex(fila, 3)
          .setText('${porcentaje.toStringAsFixed(1)}%');
      sheet.getRangeByIndex(fila, 4).setText(caracteristicas);

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
    sheet.getRangeByIndex(fila, 4).setText('Suma de todos los materiales');

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

  /// Crea tabla de resistencia con características
  Map<String, int> _crearTablaResistencia(
      xlsio.Worksheet sheet,
      int filaInicial,
      Map<String, int> resistenciaTotales,
      int totalGeneral) {
    int fila = filaInicial;
    
    // Rango para gráfica
    int filaGraficaInicio = 0;
    int filaGraficaFin = 0;
    int columnaGraficaInicio = 0;
    int columnaGraficaFin = 0;

    // Encabezados
    sheet.getRangeByIndex(fila, 1).setText('Nivel de Resistencia');
    sheet.getRangeByIndex(fila, 2).setText('Cantidad');
    sheet.getRangeByIndex(fila, 3).setText('Porcentaje');
    sheet.getRangeByIndex(fila, 4, fila, 5).merge();
    sheet.getRangeByIndex(fila, 4).setText('Recomendación');
    filaGraficaInicio = fila;
    columnaGraficaInicio = 1;

    final xlsio.Range rangoHeader = sheet.getRangeByIndex(fila, 1, fila, 5);
    rangoHeader.cellStyle.bold = true;
    rangoHeader.cellStyle.backColor = '#A9D18E';
    rangoHeader.cellStyle.fontColor = '#FFFFFF';
    rangoHeader.cellStyle.borders.all.lineStyle = xlsio.LineStyle.thin;
    fila++;

    // Mapeo de recomendaciones por nivel de resistencia
    Map<String, String> recomendaciones = {
      'Alta Resistencia': 'Continuar mantenimiento preventivo',
      'Media-Alta Resistencia': 'Monitoreo periódico recomendado',
      'Baja Resistencia': 'Evaluación urgente, considerar refuerzo',
      'Resistencia Variable': 'Inspección caso por caso',
      'Sin Clasificar': 'Evaluación técnica requerida',
    };

    // Datos ordenados por resistencia (de alta a baja)
    List<String> ordenResistencia = [
      'Alta Resistencia',
      'Media-Alta Resistencia', 
      'Resistencia Variable',
      'Baja Resistencia',
      'Sin Clasificar'
    ];

    for (String nivel in ordenResistencia) {
      if (resistenciaTotales.containsKey(nivel)) {
        int conteo = resistenciaTotales[nivel]!;
        double porcentaje = totalGeneral > 0 ? (conteo / totalGeneral) * 100 : 0;
        String recomendacion = recomendaciones[nivel] ?? 'Consultar especialista';

        sheet.getRangeByIndex(fila, 1).setText(nivel);
        sheet.getRangeByIndex(fila, 2).setNumber(conteo.toDouble());
        sheet
            .getRangeByIndex(fila, 3)
            .setText('${porcentaje.toStringAsFixed(1)}%');
        sheet.getRangeByIndex(fila, 4, fila, 5).merge();
        sheet.getRangeByIndex(fila, 4).setText(recomendacion);
        sheet.getRangeByIndex(fila, 4).cellStyle.wrapText = true;

        // Color según nivel de resistencia
        String bgColor = '#FFFFFF';
        if (nivel.contains('Alta')) bgColor = '#E8F5E8';
        else if (nivel.contains('Baja')) bgColor = '#FFE8E8';
        else if (nivel.contains('Variable') || nivel.contains('Sin Clasificar')) bgColor = '#FFF2CC';
        else bgColor = fila % 2 == 0 ? '#F2F2F2' : '#FFFFFF';
        
        final xlsio.Range rangoFila = sheet.getRangeByIndex(fila, 1, fila, 5);
        rangoFila.cellStyle.backColor = bgColor;
        rangoFila.cellStyle.borders.all.lineStyle = xlsio.LineStyle.thin;

        fila++;
      }
    }
    filaGraficaFin = fila;
    columnaGraficaFin = 2;

    // Fila de total
    sheet.getRangeByIndex(fila, 1).setText('TOTAL');
    sheet.getRangeByIndex(fila, 2).setNumber(totalGeneral.toDouble());
    sheet.getRangeByIndex(fila, 3).setText('100%');
    sheet.getRangeByIndex(fila, 4, fila, 5).merge();
    sheet
        .getRangeByIndex(fila, 4)
        .setText('Todos los niveles de resistencia');

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

  /// Crea un gráfico de barras similar al PDF (idéntico al archivo base)
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
      print('⚠️ [EXCEL-MATERIAL-V2] Error al crear gráfico: $e');
      sheet.getRangeByIndex(filaInicial, 1).setText('Gráfico no disponible');
      return filaInicial + 1;
    }
  }

  /// Encuentra el material predominante en las estadísticas
  String _encontrarMaterialPredominante(Map<String, dynamic> conteoMateriales) {
    if (conteoMateriales.isEmpty) return 'No determinado';

    String predominante = 'No determinado';
    int maxConteo = 0;

    conteoMateriales.forEach((material, conteo) {
      if (conteo is int && conteo > maxConteo) {
        maxConteo = conteo;
        predominante = material;
      }
    });

    return predominante;
  }

  /// Determina el nivel de resistencia de un material
  String _determinarResistencia(String material) {
    Map<String, String> resistenciaPorMaterial = {
      'Concreto': 'Alta Resistencia',
      'Ladrillo': 'Media-Alta Resistencia',
      'Adobe': 'Baja Resistencia',
      'Madera/Lámina/Otros': 'Resistencia Variable',
      'No determinado': 'Sin Clasificar',
    };

    return resistenciaPorMaterial[material] ?? 'Sin Clasificar';
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
        print(
            '✅ [EXCEL-MATERIAL-V2] Archivo guardado: $rutaCompleta (${await archivo.length()} bytes)');
        return rutaCompleta;
      } else {
        throw Exception('El archivo no se guardó correctamente');
      }
    } catch (e) {
      print('❌ [EXCEL-MATERIAL-V2] Error al guardar archivo: $e');
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

  // === MÉTODOS ADICIONALES DE UTILIDAD ===

  /// Aplica formato condicional a un rango (idéntico al base)
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

  /// Crea un resumen visual con iconos (adaptado para materiales)
  Future<void> _crearResumenVisual(
    xlsio.Worksheet sheet,
    int filaInicial,
    Map<String, dynamic> estadisticas,
  ) async {
    int fila = filaInicial;

    // Título
    final xlsio.Range rangoTitulo = sheet.getRangeByIndex(fila, 1, fila, 4);
    rangoTitulo.merge();
    rangoTitulo.setText('RESUMEN VISUAL DE MATERIALES');
    rangoTitulo.cellStyle.bold = true;
    rangoTitulo.cellStyle.fontSize = 12;
    rangoTitulo.cellStyle.backColor = '#4472C4';
    rangoTitulo.cellStyle.fontColor = '#FFFFFF';
    fila++;

    // Indicadores con formato visual
    final List<Map<String, dynamic>> indicadores = [
      {
        'titulo': 'Total Evaluados',
        'valor': estadisticas['totalFormatos'] ?? 0,
        'icono': '🏗️',
        'color': '#4472C4'
      },
      {
        'titulo': 'Material Principal',
        'valor': _encontrarMaterialPredominante(
            estadisticas['conteoMateriales'] ?? {}),
        'icono': '🧱',
        'color': '#70AD47'
      },
      {
        'titulo': 'Nivel Resistencia',
        'valor': _determinarResistencia(_encontrarMaterialPredominante(
            estadisticas['conteoMateriales'] ?? {})),
        'icono': '💪',
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

  /// Valida los datos antes de procesarlos (adaptado para materiales)
  bool _validarDatos(Map<String, dynamic> datos) {
    // Verificar estructura básica
    if (!datos.containsKey('conteoMateriales')) {
      print('⚠️ [EXCEL-MATERIAL-V2] Estructura de datos incompleta');
      return false;
    }

    // Verificar que hay datos de materiales
    if (datos['conteoMateriales'] == null ||
        datos['conteoMateriales'].isEmpty) {
      print('⚠️ [EXCEL-MATERIAL-V2] No hay datos de materiales disponibles');
      return false;
    }

    return true;
  }
}