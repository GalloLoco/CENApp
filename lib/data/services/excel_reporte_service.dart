// lib/data/services/excel_reporte_service.dart


import 'dart:io';

import 'package:syncfusion_flutter_xlsio/xlsio.dart';
import 'package:syncfusion_officechart/officechart.dart';
import 'package:intl/intl.dart';
import 'file_storage_service.dart';

/// Servicio especializado para generar reportes en formato Excel
/// Utiliza Syncfusion XlsIO para crear archivos Excel con formato profesional
class ExcelReporteService {
  final FileStorageService _fileService = FileStorageService();

  /// Genera un reporte completo en Excel con múltiples hojas
  /// [titulo] - Título principal del reporte
  /// [subtitulo] - Subtítulo descriptivo
  /// [datos] - Datos estadísticos procesados
  /// [tablas] - Lista de tablas formateadas para mostrar
  /// [metadatos] - Información adicional del reporte
  /// [directorio] - Directorio de destino (opcional)
  Future<String> generarReporteExcel({
    required String titulo,
    required String subtitulo,
    required Map<String, dynamic> datos,
    required List<Map<String, dynamic>> tablas,
    required Map<String, dynamic> metadatos,
    Directory? directorio,
  }) async {
    try {
      print('📊 [EXCEL] Iniciando generación de reporte Excel: $titulo');

      // Crear nuevo libro de Excel
      final Workbook workbook = Workbook();
      
      // Configurar propiedades del documento
      _configurarPropiedadesDocumento(workbook, titulo, subtitulo, metadatos);
      
      // Eliminar hoja por defecto y crear hojas personalizadas
      workbook.worksheets.clear();
      
      // 1. Hoja de resumen ejecutivo
      await _crearHojaResumenEjecutivo(workbook, titulo, subtitulo, datos, metadatos);
      
      // 2. Hojas de datos detallados (una por cada tabla)
      await _crearHojasDatosDetallados(workbook, tablas, datos);
      
      // 3. Hoja de gráficos (si hay datos para gráficos)
      await _crearHojaGraficos(workbook, datos, metadatos);
      
      // 4. Hoja de metadatos y filtros aplicados
      await _crearHojaMetadatos(workbook, metadatos);

      // Guardar archivo
      final String rutaArchivo = await _guardarArchivoExcel(
        workbook, 
        titulo, 
        directorio
      );
      
      // Liberar recursos
      workbook.dispose();
      
      print('✅ [EXCEL] Reporte Excel generado exitosamente: $rutaArchivo');
      return rutaArchivo;

    } catch (e) {
      print('❌ [EXCEL] Error al generar reporte Excel: $e');
      throw Exception('Error al generar reporte Excel: $e');
    }
  }

  /// Configura las propiedades del documento Excel
  void _configurarPropiedadesDocumento(
    Workbook workbook, 
    String titulo, 
    String subtitulo, 
    Map<String, dynamic> metadatos
  ) {
    // Configurar propiedades del documento
    workbook.builtInProperties.title = titulo;
    workbook.builtInProperties.subject = subtitulo;
    workbook.builtInProperties.author = metadatos['autor'] ?? 'CENApp Sistema';
    workbook.builtInProperties.company = 'CENApp - Centro de Evaluación';
    workbook.builtInProperties.comments = 'Reporte generado automáticamente por CENApp';
    
  }

  /// Crea la hoja de resumen ejecutivo con información principal
  Future<void> _crearHojaResumenEjecutivo(
    Workbook workbook,
    String titulo,
    String subtitulo,
    Map<String, dynamic> datos,
    Map<String, dynamic> metadatos,
  ) async {
    final Worksheet worksheet = workbook.worksheets.add();
    worksheet.name = 'Resumen Ejecutivo';
    
    // Configurar anchos de columnas
    worksheet.getRangeByName('A:A').columnWidth = 25;
    worksheet.getRangeByName('B:B').columnWidth = 30;
    worksheet.getRangeByName('C:C').columnWidth = 20;
    worksheet.getRangeByName('D:D').columnWidth = 15;

    int filaActual = 1;

    // === ENCABEZADO PRINCIPAL ===
    filaActual = await _crearEncabezadoPrincipal(
      worksheet, 
      titulo, 
      subtitulo, 
      metadatos, 
      filaActual
    );

    filaActual += 2; // Espacio

    // === RESUMEN DE FILTROS APLICADOS ===
    filaActual = await _crearSeccionFiltros(worksheet, metadatos, filaActual);

    filaActual += 2; // Espacio

    // === ESTADÍSTICAS GENERALES ===
    filaActual = await _crearSeccionEstadisticasGenerales(
      worksheet, 
      datos, 
      metadatos, 
      filaActual
    );

    filaActual += 2; // Espacio

    // === INDICADORES CLAVE ===
    filaActual = await _crearSeccionIndicadoresClave(
      worksheet, 
      datos, 
      filaActual
    );

    // Aplicar formato final a la hoja
    _aplicarFormatoFinalHoja(worksheet);
  }

  /// Crea el encabezado principal del reporte
  Future<int> _crearEncabezadoPrincipal(
    Worksheet worksheet,
    String titulo,
    String subtitulo,
    Map<String, dynamic> metadatos,
    int filaInicial,
  ) async {
    int fila = filaInicial;

    // Título principal
    final Range rangoTitulo = worksheet.getRangeByName('A$fila:D$fila');
    rangoTitulo.merge();
    rangoTitulo.setText(titulo.toUpperCase());
    rangoTitulo.cellStyle.fontName = 'Calibri';
    rangoTitulo.cellStyle.fontSize = 18;
    rangoTitulo.cellStyle.bold = true;
    rangoTitulo.cellStyle.fontColor = '#FFFFFF';
    rangoTitulo.cellStyle.backColor = '#1F4E79';
    rangoTitulo.cellStyle.hAlign = HAlignType.center;
    rangoTitulo.cellStyle.vAlign = VAlignType.center;
    fila++;

    // Subtítulo
    final Range rangoSubtitulo = worksheet.getRangeByName('A$fila:D$fila');
    rangoSubtitulo.merge();
    rangoSubtitulo.setText(subtitulo);
    rangoSubtitulo.cellStyle.fontName = 'Calibri';
    rangoSubtitulo.cellStyle.fontSize = 14;
    rangoSubtitulo.cellStyle.bold = true;
    rangoSubtitulo.cellStyle.fontColor = '#FFFFFF';
    rangoSubtitulo.cellStyle.backColor = '#2F5F8F';
    rangoSubtitulo.cellStyle.hAlign = HAlignType.center;
    fila++;

    // Fecha de generación
    final String fechaGeneracion = DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now());
    final Range rangoFecha = worksheet.getRangeByName('A$fila:D$fila');
    rangoFecha.merge();
    rangoFecha.setText('Generado el: $fechaGeneracion');
    rangoFecha.cellStyle.fontName = 'Calibri';
    rangoFecha.cellStyle.fontSize = 10;
    rangoFecha.cellStyle.italic = true;
    rangoFecha.cellStyle.hAlign = HAlignType.center;
    rangoFecha.cellStyle.backColor = '#E7E6E6';
    fila++;

    return fila;
  }

  /// Crea la sección de filtros aplicados
  Future<int> _crearSeccionFiltros(
    Worksheet worksheet,
    Map<String, dynamic> metadatos,
    int filaInicial,
  ) async {
    int fila = filaInicial;

    // Título de sección
    final Range tituloFiltros = worksheet.getRangeByName('A$fila:D$fila');
    tituloFiltros.merge();
    tituloFiltros.setText('FILTROS APLICADOS');
    tituloFiltros.cellStyle.fontName = 'Calibri';
    tituloFiltros.cellStyle.fontSize = 12;
    tituloFiltros.cellStyle.bold = true;
    tituloFiltros.cellStyle.backColor = '#D9E2F3';
    tituloFiltros.cellStyle.hAlign = HAlignType.center;
    fila++;

    // Lista de filtros
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

    // Escribir filtros en formato de tabla
    for (var filtro in filtros) {
      worksheet.getRangeByName('A$fila').setText(filtro[0]);
      worksheet.getRangeByName('A$fila').cellStyle.bold = true;
      worksheet.getRangeByName('A$fila').cellStyle.backColor = '#F2F2F2';
      
      final Range valorRange = worksheet.getRangeByName('B$fila:D$fila');
      valorRange.merge();
      valorRange.setText(filtro[1]);
      valorRange.cellStyle.backColor = '#FAFAFA';
      
      fila++;
    }

    return fila;
  }

  /// Crea la sección de estadísticas generales
  Future<int> _crearSeccionEstadisticasGenerales(
    Worksheet worksheet,
    Map<String, dynamic> datos,
    Map<String, dynamic> metadatos,
    int filaInicial,
  ) async {
    int fila = filaInicial;

    // Título de sección
    final Range tituloStats = worksheet.getRangeByName('A$fila:D$fila');
    tituloStats.merge();
    tituloStats.setText('ESTADÍSTICAS GENERALES');
    tituloStats.cellStyle.fontName = 'Calibri';
    tituloStats.cellStyle.fontSize = 12;
    tituloStats.cellStyle.bold = true;
    tituloStats.cellStyle.backColor = '#E2EFDA';
    tituloStats.cellStyle.hAlign = HAlignType.center;
    fila++;

    // Calcular estadísticas
    final int totalFormatos = metadatos['totalFormatos'] ?? 0;
    
    // Extraer datos de distribución geográfica
    Map<String, int> ciudades = {};
    Map<String, int> colonias = {};
    
    if (datos.containsKey('distribucionGeografica')) {
      ciudades = Map<String, int>.from(datos['distribucionGeografica']['ciudades'] ?? {});
      colonias = Map<String, int>.from(datos['distribucionGeografica']['colonias'] ?? {});
    }

    // Estadísticas principales
    final List<List<dynamic>> estadisticas = [
      ['Total de inmuebles evaluados', totalFormatos, '100%'],
      ['Ciudades cubiertas', ciudades.length, '-'],
      ['Colonias cubiertas', colonias.length, '-'],
    ];

    // Encontrar ciudad principal
    if (ciudades.isNotEmpty) {
      final ciudadPrincipal = ciudades.entries.reduce((a, b) => a.value > b.value ? a : b);
      final porcentajeCiudad = totalFormatos > 0 ? (ciudadPrincipal.value / totalFormatos * 100) : 0;
      estadisticas.add([
        'Ciudad principal', 
        '${ciudadPrincipal.key} (${ciudadPrincipal.value})', 
        '${porcentajeCiudad.toStringAsFixed(1)}%'
      ]);
    }

    // Encontrar colonia principal
    if (colonias.isNotEmpty) {
      final coloniaPrincipal = colonias.entries.reduce((a, b) => a.value > b.value ? a : b);
      final porcentajeColonia = totalFormatos > 0 ? (coloniaPrincipal.value / totalFormatos * 100) : 0;
      estadisticas.add([
        'Colonia principal', 
        '${coloniaPrincipal.key} (${coloniaPrincipal.value})', 
        '${porcentajeColonia.toStringAsFixed(1)}%'
      ]);
    }

    // Encabezados de tabla
    worksheet.getRangeByName('A$fila').setText('Concepto');
    worksheet.getRangeByName('B$fila').setText('Valor');
    worksheet.getRangeByName('C$fila').setText('Porcentaje');
    
    final Range headerRange = worksheet.getRangeByName('A$fila:C$fila');
    headerRange.cellStyle.bold = true;
    headerRange.cellStyle.backColor = '#70AD47';
    headerRange.cellStyle.fontColor = '#FFFFFF';
    headerRange.cellStyle.hAlign = HAlignType.center;
    fila++;

    // Datos de la tabla
    for (var stat in estadisticas) {
      worksheet.getRangeByName('A$fila').setText(stat[0].toString());
      worksheet.getRangeByName('B$fila').setText(stat[1].toString());
      worksheet.getRangeByName('C$fila').setText(stat[2].toString());
      
      // Alternar colores de fila
      if (fila % 2 == 0) {
        final Range filaRange = worksheet.getRangeByName('A$fila:C$fila');
        filaRange.cellStyle.backColor = '#F2F2F2';
      }
      
      fila++;
    }

    return fila;
  }

  /// Crea la sección de indicadores clave
  Future<int> _crearSeccionIndicadoresClave(
    Worksheet worksheet,
    Map<String, dynamic> datos,
    int filaInicial,
  ) async {
    int fila = filaInicial;

    // Título de sección
    final Range tituloIndicadores = worksheet.getRangeByName('A$fila:D$fila');
    tituloIndicadores.merge();
    tituloIndicadores.setText('INDICADORES CLAVE DE DISTRIBUCIÓN');
    tituloIndicadores.cellStyle.fontName = 'Calibri';
    tituloIndicadores.cellStyle.fontSize = 12;
    tituloIndicadores.cellStyle.bold = true;
    tituloIndicadores.cellStyle.backColor = '#FFE2CC';
    tituloIndicadores.cellStyle.hAlign = HAlignType.center;
    fila++;

    // Extraer datos de distribución temporal si existen
    Map<String, int> meses = {};
    if (datos.containsKey('distribucionTemporal')) {
      meses = Map<String, int>.from(datos['distribucionTemporal']['meses'] ?? {});
    }

    // Análisis temporal
    if (meses.isNotEmpty) {
      final mesPrincipal = meses.entries.reduce((a, b) => a.value > b.value ? a : b);
      
      worksheet.getRangeByName('A$fila').setText('Mes con mayor actividad:');
      worksheet.getRangeByName('A$fila').cellStyle.bold = true;
      
      final Range mesRange = worksheet.getRangeByName('B$fila:D$fila');
      mesRange.merge();
      mesRange.setText('${mesPrincipal.key} (${mesPrincipal.value} evaluaciones)');
      mesRange.cellStyle.backColor = '#FFF2CC';
      
      fila++;
    }

    // Índice de concentración geográfica
    Map<String, int> ciudades = {};
    if (datos.containsKey('distribucionGeografica')) {
      ciudades = Map<String, int>.from(datos['distribucionGeografica']['ciudades'] ?? {});
    }

    if (ciudades.isNotEmpty && ciudades.length > 1) {
      // Calcular índice de Herfindahl (concentración)
      final totalEvaluaciones = ciudades.values.fold(0, (sum, val) => sum + val);
      double indiceHerfindahl = 0;
      
      for (var conteo in ciudades.values) {
        double proporcion = conteo / totalEvaluaciones;
        indiceHerfindahl += proporcion * proporcion;
      }
      
      String nivelConcentracion;
      if (indiceHerfindahl > 0.7) {
        nivelConcentracion = 'Alta concentración';
      } else if (indiceHerfindahl > 0.4) {
        nivelConcentracion = 'Concentración media';
      } else {
        nivelConcentracion = 'Distribución uniforme';
      }

      worksheet.getRangeByName('A$fila').setText('Concentración geográfica:');
      worksheet.getRangeByName('A$fila').cellStyle.bold = true;
      
      final Range concentracionRange = worksheet.getRangeByName('B$fila:D$fila');
      concentracionRange.merge();
      concentracionRange.setText('$nivelConcentracion (Índice: ${(indiceHerfindahl * 100).toStringAsFixed(1)}%)');
      concentracionRange.cellStyle.backColor = '#E2F0D9';
      
      fila++;
    }

    return fila;
  }

  /// Crea hojas detalladas con los datos de las tablas
  Future<void> _crearHojasDatosDetallados(
    Workbook workbook,
    List<Map<String, dynamic>> tablas,
    Map<String, dynamic> datos,
  ) async {
    for (int i = 0; i < tablas.length; i++) {
      final tabla = tablas[i];
      final String nombreHoja = _limpiarNombreHoja(tabla['titulo'] ?? 'Datos $i');
      
      final Worksheet worksheet = workbook.worksheets.add();
      worksheet.name = nombreHoja;
      await _crearHojaTablaDetallada(worksheet, tabla);
    }
  }

  /// Crea una hoja individual con datos detallados de una tabla
  Future<void> _crearHojaTablaDetallada(
    Worksheet worksheet,
    Map<String, dynamic> tabla,
  ) async {
    // Configurar anchos de columnas
    worksheet.getRangeByName('A:A').columnWidth = 35;
    worksheet.getRangeByName('B:B').columnWidth = 15;
    worksheet.getRangeByName('C:C').columnWidth = 15;

    int fila = 1;

    // Título de la tabla
    final Range tituloTabla = worksheet.getRangeByName('A$fila:C$fila');
    tituloTabla.merge();
    tituloTabla.setText(tabla['titulo']?.toString().toUpperCase() ?? 'DATOS');
    tituloTabla.cellStyle.fontName = 'Calibri';
    tituloTabla.cellStyle.fontSize = 14;
    tituloTabla.cellStyle.bold = true;
    tituloTabla.cellStyle.fontColor = '#FFFFFF';
    tituloTabla.cellStyle.backColor = '#1F4E79';
    tituloTabla.cellStyle.hAlign = HAlignType.center;
    fila++;

    // Descripción (si existe)
    if (tabla['descripcion'] != null && tabla['descripcion'].toString().isNotEmpty) {
      final Range descripcionRange = worksheet.getRangeByName('A$fila:C$fila');
      descripcionRange.merge();
      descripcionRange.setText(tabla['descripcion'].toString());
      descripcionRange.cellStyle.fontSize = 10;
      descripcionRange.cellStyle.italic = true;
      descripcionRange.cellStyle.backColor = '#E7E6E6';
      descripcionRange.cellStyle.wrapText = true;
      fila++;
    }

    fila++; // Espacio

    // Encabezados
    final List<String> encabezados = List<String>.from(tabla['encabezados'] ?? []);
    for (int i = 0; i < encabezados.length; i++) {
      final String columna = String.fromCharCode(65 + i); // A, B, C, etc.
      worksheet.getRangeByName('$columna$fila').setText(encabezados[i]);
      worksheet.getRangeByName('$columna$fila').cellStyle.bold = true;
      worksheet.getRangeByName('$columna$fila').cellStyle.backColor = '#70AD47';
      worksheet.getRangeByName('$columna$fila').cellStyle.fontColor = '#FFFFFF';
      worksheet.getRangeByName('$columna$fila').cellStyle.hAlign = HAlignType.center;
    }
    fila++;

    // Datos
    final List<List<dynamic>> filas = List<List<dynamic>>.from(tabla['filas'] ?? []);
    for (var filaData in filas) {
      for (int i = 0; i < filaData.length && i < encabezados.length; i++) {
        final String columna = String.fromCharCode(65 + i);
        worksheet.getRangeByName('$columna$fila').setText(filaData[i].toString());
        
        // Aplicar formato numérico para columnas de números/porcentajes
        if (i > 0) { // Columnas numéricas (no la primera que suele ser texto)
          if (filaData[i].toString().contains('%')) {
            worksheet.getRangeByName('$columna$fila').cellStyle.hAlign = HAlignType.center;
          } else if (filaData[i] is num) {
            worksheet.getRangeByName('$columna$fila').cellStyle.hAlign = HAlignType.right;
          }
        }
        
        // Alternar colores de fila
        if (fila % 2 == 0) {
          worksheet.getRangeByName('$columna$fila').cellStyle.backColor = '#F2F2F2';
        }
      }
      fila++;
    }

    // Agregar bordes a toda la tabla
    final String rangoTabla = 'A1:${String.fromCharCode(64 + encabezados.length)}$fila';
    final Range tablaCompleta = worksheet.getRangeByName(rangoTabla);
    tablaCompleta.cellStyle.borders.all.lineStyle = LineStyle.thin;
    tablaCompleta.cellStyle.borders.all.color = '#000000';
  }

  
  /// Crea gráfico de distribución por ciudades
  Future<int> _crearGraficoDistribucionCiudades(
  Worksheet worksheet,
  Map<String, dynamic> datos,
  int filaInicial,
) async {
  int fila = filaInicial;

  // Título del gráfico
  worksheet.getRangeByName('A$fila').setText('Distribución por Ciudades');
  worksheet.getRangeByName('A$fila').cellStyle.bold = true;
  worksheet.getRangeByName('A$fila').cellStyle.fontSize = 12;
  fila++;

  // Datos para el gráfico
  final Map<String, int> ciudades = Map<String, int>.from(
    datos['distribucionGeografica']['ciudades'] ?? {}
  );

  // Validar que hay datos
  if (ciudades.isEmpty) {
    worksheet.getRangeByName('A$fila').setText('No hay datos de ciudades disponibles');
    return fila + 2;
  }

  // Preparar datos en formato tabla para el gráfico
  worksheet.getRangeByName('A$fila').setText('Ciudad');
  worksheet.getRangeByName('B$fila').setText('Cantidad');
  worksheet.getRangeByName('A$fila:B$fila').cellStyle.bold = true;
  worksheet.getRangeByName('A$fila:B$fila').cellStyle.backColor = '#D9E2F3';
  fila++;

  final int filaInicioGrafico = fila;
  
  // Escribir datos (limitado a top 10 para mejor visualización)
  final ciudadesOrdenadas = ciudades.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  
  final ciudadesTop = ciudadesOrdenadas.take(10).toList();

  // Verificar que tenemos al menos un dato
  if (ciudadesTop.isEmpty) {
    worksheet.getRangeByName('A$fila').setText('No hay datos suficientes para el gráfico');
    return fila + 2;
  }

  for (var ciudad in ciudadesTop) {
    worksheet.getRangeByName('A$fila').setText(ciudad.key);
    worksheet.getRangeByName('B$fila').setNumber(ciudad.value.toDouble());
    fila++;
  }

  try {
    // === CREAR GRÁFICO USANDO SINTAXIS OFICIAL ===
    
    // 1. Crear ChartCollection para la worksheet (SINTAXIS CORRECTA)
    final ChartCollection charts = ChartCollection(worksheet);
    
    // 2. Agregar gráfico a la colección
    final Chart chart = charts.add();
    
    // 3. Configurar tipo de gráfico
    chart.chartType = ExcelChartType.column; // o ExcelChartType.pie para gráfico circular
    
    // 4. Establecer rango de datos
    chart.dataRange = worksheet.getRangeByName('A${filaInicioGrafico}:B${fila-1}');
    chart.isSeriesInRows = false;
    
    // 5. Configurar título del gráfico
    chart.chartTitle = 'Distribución de Evaluaciones por Ciudad';
    chart.chartTitleArea.bold = true;
    chart.chartTitleArea.size = 14;
    
    // 6. Configurar posición y tamaño del gráfico
    chart.topRow = filaInicioGrafico;
    chart.bottomRow = fila + 15;
    chart.leftColumn = 4; // Columna D
    chart.rightColumn = 10; // Columna J
    
    // 7. IMPORTANTE: Asignar la colección de gráficos a la worksheet
    worksheet.charts = charts;
    
    print('✅ [EXCEL] Gráfico de ciudades creado exitosamente');
    
  } catch (e) {
    print('❌ [EXCEL] Error al crear gráfico de ciudades: $e');
    // Agregar nota de error en la hoja
    worksheet.getRangeByName('D$filaInicioGrafico').setText('Error al generar gráfico: $e');
    worksheet.getRangeByName('D$filaInicioGrafico').cellStyle.fontColor = '#FF0000';
  }

  return fila + 20; // Espacio adicional para el gráfico
}

/// Crea gráfico de distribución temporal
Future<int> _crearGraficoDistribucionTemporal(
  Worksheet worksheet,
  Map<String, dynamic> datos,
  int filaInicial,
) async {
  int fila = filaInicial;

  // Título del gráfico
  worksheet.getRangeByName('A$fila').setText('Distribución Temporal');
  worksheet.getRangeByName('A$fila').cellStyle.bold = true;
  worksheet.getRangeByName('A$fila').cellStyle.fontSize = 12;
  fila++;

  // Datos para el gráfico
  final Map<String, int> meses = Map<String, int>.from(
    datos['distribucionTemporal']['meses'] ?? {}
  );

  // Validar que hay datos
  if (meses.isEmpty) {
    worksheet.getRangeByName('A$fila').setText('No hay datos temporales disponibles');
    return fila + 2;
  }

  // Preparar datos en formato tabla
  worksheet.getRangeByName('A$fila').setText('Período');
  worksheet.getRangeByName('B$fila').setText('Evaluaciones');
  worksheet.getRangeByName('A$fila:B$fila').cellStyle.bold = true;
  worksheet.getRangeByName('A$fila:B$fila').cellStyle.backColor = '#E2EFDA';
  fila++;

  final int filaInicioGrafico = fila;

  // Escribir datos ordenados cronológicamente
  final mesesOrdenados = meses.entries.toList()
    ..sort((a, b) {
      try {
        // Ordenar por fecha (MM/yyyy)
        final fechaA = DateFormat('MM/yyyy').parse(a.key);
        final fechaB = DateFormat('MM/yyyy').parse(b.key);
        return fechaA.compareTo(fechaB);
      } catch (e) {
        // Si no se puede parsear, usar orden alfabético
        return a.key.compareTo(b.key);
      }
    });

  for (var mes in mesesOrdenados) {
    worksheet.getRangeByName('A$fila').setText(mes.key);
    worksheet.getRangeByName('B$fila').setNumber(mes.value.toDouble());
    fila++;
  }

  try {
    // === CREAR GRÁFICO USANDO LA SINTAXIS EXACTA DEL EJEMPLO OFICIAL ===
    
    // Verificar si ya hay gráficos en la worksheet
    ChartCollection charts;
    
    if (worksheet.charts != null) {
      // Si ya hay charts asignados, necesitamos crear una nueva colección
      // porque cada worksheet solo puede tener UNA colección de gráficos
      charts = ChartCollection(worksheet);
      
      // Nota: En Syncfusion, cada worksheet maneja sus gráficos a través de UNA colección
      // Si necesitas múltiples gráficos, los agregas a la MISMA colección
      
    } else {
      // Crear nueva colección
      charts = ChartCollection(worksheet);
    }
    
    // Agregar gráfico a la colección
    final Chart chartTemporal = charts.add();
    
    chartTemporal.chartType = ExcelChartType.line;
    chartTemporal.dataRange = worksheet.getRangeByName('A${filaInicioGrafico}:B${fila-1}');
    chartTemporal.isSeriesInRows = false;
    
    chartTemporal.chartTitle = 'Evolución Temporal de Evaluaciones';
    chartTemporal.chartTitleArea.bold = true;
    chartTemporal.chartTitleArea.size = 14;
    
    // Posicionar gráfico temporal más abajo
    chartTemporal.topRow = fila + 2;
    chartTemporal.bottomRow = fila + 17;
    chartTemporal.leftColumn = 4;
    chartTemporal.rightColumn = 10;
    
    // IMPORTANTE: Asignar la colección completa a la worksheet
    worksheet.charts = charts;
    
    print('✅ [EXCEL] Gráfico temporal creado exitosamente');

  } catch (e) {
    print('❌ [EXCEL] Error al crear gráfico temporal: $e');
    worksheet.getRangeByName('D$fila').setText('Error en gráfico temporal: $e');
    worksheet.getRangeByName('D$fila').cellStyle.fontColor = '#FF0000';
  }

  return fila + 20;
}

/// Versión actualizada de _crearHojaGraficos con sintaxis correcta
/// Crea hoja con múltiples gráficos (MÉTODO CORREGIDO)
Future<void> _crearHojaGraficos(
  Workbook workbook,
  Map<String, dynamic> datos,
  Map<String, dynamic> metadatos,
) async {
  final Worksheet worksheet = workbook.worksheets.add();
  worksheet.name = 'Gráficos';
  
  // Configurar hoja
  worksheet.getRangeByName('A:A').columnWidth = 30;
  worksheet.getRangeByName('B:B').columnWidth = 15;

  int fila = 1;

  // Título
  final Range titulo = worksheet.getRangeByName('A$fila:F$fila');
  titulo.merge();
  titulo.setText('GRÁFICOS Y VISUALIZACIONES');
  titulo.cellStyle.fontName = 'Calibri';
  titulo.cellStyle.fontSize = 16;
  titulo.cellStyle.bold = true;
  titulo.cellStyle.fontColor = '#FFFFFF';
  titulo.cellStyle.backColor = '#1F4E79';
  titulo.cellStyle.hAlign = HAlignType.center;
  fila += 3;

  try {
    // === CREAR UNA SOLA COLECCIÓN DE GRÁFICOS PARA TODA LA HOJA ===
    final ChartCollection charts = ChartCollection(worksheet);
    
    // Contador para posicionar gráficos
    int contadorGraficos = 0;
    
    // Gráfico 1: Distribución por ciudades
    if (datos.containsKey('distribucionGeografica') && 
        datos['distribucionGeografica']['ciudades'].isNotEmpty) {
      
      contadorGraficos++;
      fila = await _agregarGraficoDistribucionCiudades(
        worksheet, 
        charts, 
        datos, 
        fila, 
        contadorGraficos
      );
    }

    // Gráfico 2: Distribución temporal (si hay datos)
    if (datos.containsKey('distribucionTemporal') && 
        datos['distribucionTemporal']['meses'].isNotEmpty) {
      
      contadorGraficos++;
      fila = await _agregarGraficoDistribucionTemporal(
        worksheet, 
        charts, 
        datos, 
        fila, 
        contadorGraficos
      );
    }
    
    // IMPORTANTE: Asignar la colección completa al final
    if (contadorGraficos > 0) {
      worksheet.charts = charts;
      print('✅ [EXCEL] Se crearon $contadorGraficos gráficos exitosamente');
    }
    
  } catch (e) {
    print('❌ [EXCEL] Error general al crear gráficos: $e');
  }
}


  

  /// Crea hoja con metadatos y información técnica
  Future<void> _crearHojaMetadatos(
    Workbook workbook,
    Map<String, dynamic> metadatos,
  ) async {
    final Worksheet worksheet = workbook.worksheets.add();
    worksheet.name = 'Metadatos';
    
    // Configurar columnas
    worksheet.getRangeByName('A:A').columnWidth = 25;
    worksheet.getRangeByName('B:B').columnWidth = 40;

    int fila = 1;

    // Título
    final Range titulo = worksheet.getRangeByName('A$fila:B$fila');
    titulo.merge();
    titulo.setText('INFORMACIÓN TÉCNICA DEL REPORTE');
    titulo.cellStyle.fontName = 'Calibri';
    titulo.cellStyle.fontSize = 14;
    titulo.cellStyle.bold = true;
    titulo.cellStyle.fontColor = '#FFFFFF';
    titulo.cellStyle.backColor = '#1F4E79';
    titulo.cellStyle.hAlign = HAlignType.center;
    fila += 2;

    // Información técnica
    final List<List<String>> infoTecnica = [
      ['Generado por:', 'CENApp - Sistema de Evaluación Estructural'],
      ['Fecha de generación:', DateFormat('dd/MM/yyyy HH:mm:ss').format(DateTime.now())],
      ['Versión del sistema:', '1.0.0'],
      ['Tipo de reporte:', metadatos['titulo'] ?? 'Resumen General'],
      ['Total de registros:', '${metadatos['totalFormatos'] ?? 0}'],
      ['Período de análisis:', '${metadatos['fechaInicio']} - ${metadatos['fechaFin']}'],
      ['Usuario creador filtro:', metadatos['usuarioCreador'] ?? 'Todos'],
      ['Nombre inmueble filtro:', metadatos['nombreInmueble'] ?? 'Todos'],
    ];

    // Agregar información de ubicaciones
    if (metadatos['ubicaciones'] != null && metadatos['ubicaciones'].isNotEmpty) {
      final List<Map<String, dynamic>> ubicaciones = metadatos['ubicaciones'];
      infoTecnica.add(['Ubicaciones analizadas:', '${ubicaciones.length}']);
      
      for (int i = 0; i < ubicaciones.length; i++) {
        final ubi = ubicaciones[i];
        String ubicacionDetalle = '';
        if (ubi['municipio'] != null) ubicacionDetalle += 'Municipio: ${ubi['municipio']} ';
        if (ubi['ciudad'] != null) ubicacionDetalle += 'Ciudad: ${ubi['ciudad']} ';
        if (ubi['colonia'] != null && ubi['colonia'].isNotEmpty) {
          ubicacionDetalle += 'Colonia: ${ubi['colonia']}';
        }
        infoTecnica.add(['  Ubicación ${i+1}:', ubicacionDetalle.trim()]);
      }
    }

    // Escribir información técnica
    for (var info in infoTecnica) {
      worksheet.getRangeByName('A$fila').setText(info[0]);
      worksheet.getRangeByName('A$fila').cellStyle.bold = true;
      worksheet.getRangeByName('A$fila').cellStyle.backColor = '#F2F2F2';
      
      worksheet.getRangeByName('B$fila').setText(info[1]);
      worksheet.getRangeByName('B$fila').cellStyle.backColor = '#FAFAFA';
      
      fila++;
    }

    fila += 2;

    // Nota sobre el procesamiento
    final Range nota = worksheet.getRangeByName('A$fila:B$fila');
    nota.merge();
    nota.setText(
      'NOTA: Este reporte ha sido generado automáticamente por el sistema CENApp. '
      'Los datos presentados corresponden a las evaluaciones estructurales realizadas '
      'en el período especificado y con los filtros aplicados. Para consultas técnicas '
      'sobre la interpretación de los datos, consulte la documentación del sistema.'
    );
    nota.cellStyle.fontSize = 9;
    nota.cellStyle.italic = true;
    nota.cellStyle.backColor = '#FFF2CC';
    nota.cellStyle.wrapText = true;
    nota.rowHeight = 80;
  }

  /// Guarda el archivo Excel en el directorio especificado
  Future<String> _guardarArchivoExcel(
    Workbook workbook,
    String titulo,
    Directory? directorio,
  ) async {
    try {
      // Obtener directorio de destino
      final directorioFinal = directorio ?? await _fileService.obtenerDirectorioDescargas();
      
      // Crear subdirectorio para reportes Excel si no existe
      final directorioReportes = Directory('${directorioFinal.path}/cenapp/reportes_excel');
      if (!await directorioReportes.exists()) {
        await directorioReportes.create(recursive: true);
      }

      // Generar nombre de archivo único
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final nombreLimpio = _limpiarNombreArchivo(titulo);
      final nombreArchivo = '${nombreLimpio}_$timestamp.xlsx';
      final rutaCompleta = '${directorioReportes.path}/$nombreArchivo';

      // Guardar archivo
      final List<int> bytes = workbook.saveAsStream();
      final File archivo = File(rutaCompleta);
      await archivo.writeAsBytes(bytes);

      // Verificar que el archivo se guardó correctamente
      if (await archivo.exists() && await archivo.length() > 0) {
        print('✅ [EXCEL] Archivo Excel guardado: $rutaCompleta (${await archivo.length()} bytes)');
        return rutaCompleta;
      } else {
        throw Exception('El archivo Excel no se guardó correctamente');
      }

    } catch (e) {
      print('❌ [EXCEL] Error al guardar archivo Excel: $e');
      throw Exception('Error al guardar archivo Excel: $e');
    }
  }

  /// Aplica formato final a toda la hoja
  void _aplicarFormatoFinalHoja(Worksheet worksheet) {
    // Aplicar fuente estándar a toda la hoja
    worksheet.getRangeByName('A1:Z1000').cellStyle.fontName = 'Calibri';
    worksheet.getRangeByName('A1:Z1000').cellStyle.fontSize = 10;
    
    // Configurar encabezados de impresión
    worksheet.pageSetup.printArea = 'A1:D100';
    worksheet.pageSetup.orientation = ExcelPageOrientation.portrait;
    worksheet.pageSetup.fitToPagesWide = 1;
    worksheet.pageSetup.fitToPagesTall = 0; // Ajustar automáticamente la altura
  }

  /// Limpia el nombre de la hoja para cumplir con las restricciones de Excel
  String _limpiarNombreHoja(String nombre) {
    // Excel no permite ciertos caracteres en nombres de hojas
    String nombreLimpio = nombre
        .replaceAll(RegExp(r'[\\/:*?"<>|]'), '_')
        .replaceAll('  ', ' ')
        .trim();
    
    // Excel limita nombres de hoja a 31 caracteres
    if (nombreLimpio.length > 31) {
      nombreLimpio = nombreLimpio.substring(0, 28) + '...';
    }
    
    return nombreLimpio.isEmpty ? 'Datos' : nombreLimpio;
  }

  /// Agrega gráfico de ciudades a la colección existente
Future<int> _agregarGraficoDistribucionCiudades(
  Worksheet worksheet,
  ChartCollection charts,
  Map<String, dynamic> datos,
  int filaInicial,
  int numeroGrafico,
) async {
  int fila = filaInicial;

  // Preparar datos...
  final Map<String, int> ciudades = Map<String, int>.from(
    datos['distribucionGeografica']['ciudades'] ?? {}
  );

  if (ciudades.isEmpty) return fila + 2;

  // Título y datos del gráfico
  worksheet.getRangeByName('A$fila').setText('Distribución por Ciudades');
  worksheet.getRangeByName('A$fila').cellStyle.bold = true;
  fila++;

  worksheet.getRangeByName('A$fila').setText('Ciudad');
  worksheet.getRangeByName('B$fila').setText('Cantidad');
  fila++;

  final int filaInicioGrafico = fila;
  final ciudadesTop = ciudades.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value))
    ..take(10);

  for (var ciudad in ciudadesTop) {
    worksheet.getRangeByName('A$fila').setText(ciudad.key);
    worksheet.getRangeByName('B$fila').setNumber(ciudad.value.toDouble());
    fila++;
  }

  // Crear gráfico y agregarlo a la colección
  final Chart chart = charts.add();
  chart.chartType = ExcelChartType.column;
  chart.dataRange = worksheet.getRangeByName('A${filaInicioGrafico}:B${fila-1}');
  chart.isSeriesInRows = false;
  chart.chartTitle = 'Distribución de Evaluaciones por Ciudad';
  chart.chartTitleArea.bold = true;
  chart.chartTitleArea.size = 14;
  
  // Posicionar según el número de gráfico
  chart.topRow = filaInicioGrafico;
  chart.bottomRow = fila + 15;
  chart.leftColumn = 4 + (numeroGrafico - 1) * 7; // Separar gráficos horizontalmente
  chart.rightColumn = 10 + (numeroGrafico - 1) * 7;

  return fila + 20;
}

/// Agrega gráfico temporal a la colección existente
Future<int> _agregarGraficoDistribucionTemporal(
  Worksheet worksheet,
  ChartCollection charts,
  Map<String, dynamic> datos,
  int filaInicial,
  int numeroGrafico,
) async {
  int fila = filaInicial;

  // Preparar datos temporales...
  final Map<String, int> meses = Map<String, int>.from(
    datos['distribucionTemporal']['meses'] ?? {}
  );

  if (meses.isEmpty) return fila + 2;

  // Título y datos
  worksheet.getRangeByName('A$fila').setText('Distribución Temporal');
  worksheet.getRangeByName('A$fila').cellStyle.bold = true;
  fila++;

  worksheet.getRangeByName('A$fila').setText('Período');
  worksheet.getRangeByName('B$fila').setText('Evaluaciones');
  fila++;

  final int filaInicioGrafico = fila;
  final mesesOrdenados = meses.entries.toList();

  for (var mes in mesesOrdenados) {
    worksheet.getRangeByName('A$fila').setText(mes.key);
    worksheet.getRangeByName('B$fila').setNumber(mes.value.toDouble());
    fila++;
  }

  // Crear gráfico y agregarlo a la misma colección
  final Chart chartTemporal = charts.add();
  chartTemporal.chartType = ExcelChartType.line;
  chartTemporal.dataRange = worksheet.getRangeByName('A${filaInicioGrafico}:B${fila-1}');
  chartTemporal.isSeriesInRows = false;
  chartTemporal.chartTitle = 'Evolución Temporal de Evaluaciones';
  chartTemporal.chartTitleArea.bold = true;
  chartTemporal.chartTitleArea.size = 14;
  
  // Posicionar según el número de gráfico
  chartTemporal.topRow = filaInicioGrafico;
  chartTemporal.bottomRow = fila + 15;
  chartTemporal.leftColumn = 4 + (numeroGrafico - 1) * 7; // Separar horizontalmente
  chartTemporal.rightColumn = 10 + (numeroGrafico - 1) * 7;

  return fila + 20;
}

  /// Limpia el nombre del archivo para el sistema de archivos
  String _limpiarNombreArchivo(String nombre) {
    return nombre
        .toLowerCase()
        .replaceAll(' ', '_')
        .replaceAll(RegExp(r'[^a-z0-9_]'), '')
        .replaceAll(RegExp(r'_+'), '_')
        .trim();
  }
}