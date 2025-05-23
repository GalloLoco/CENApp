// lib/data/services/excel_reporte_service.dart

import 'dart:io';
import 'package:excel/excel.dart';
import 'package:intl/intl.dart';
import './file_storage_service.dart';

/// Servicio especializado para generar reportes en formato Excel
/// Optimizado para crear hojas de cálculo con datos estadísticos,
/// tablas formateadas y representaciones visuales de gráficos
class ExcelReporteService {
  final FileStorageService _fileService = FileStorageService();

 Future<String> generarReporteUsoTopografiaExcel({
  required String titulo,
  required String subtitulo,
  required Map<String, dynamic> datos,
  required List<Map<String, dynamic>> tablas,
  required Map<String, dynamic> metadatos,
  Directory? directorio,
}) async {
  try {
    print('📊 [EXCEL-USO] Iniciando generación de reporte Excel: $titulo');

    // Crear nuevo libro de Excel usando la librería excel
    var excel = Excel.createExcel();
    
    // Eliminar hoja por defecto
    excel.delete('Sheet1');
    
    // Crear hoja única con todo el contenido
    String nombreHoja = 'Uso de Vivienda y Topografía';
    excel.copy('Sheet1', nombreHoja);
    excel.delete('Sheet1');
    
    Sheet sheet = excel[nombreHoja];
    
    // Crear contenido completo en una sola hoja
    await _crearContenidoUsoTopografiaCompleto(sheet, titulo, subtitulo, datos, tablas, metadatos);

    // Guardar archivo
    final String rutaArchivo = await _guardarArchivoExcelEstandar(
      excel, 
      titulo, 
      directorio
    );
    
    print('✅ [EXCEL-USO] Reporte Excel generado exitosamente: $rutaArchivo');
    return rutaArchivo;

  } catch (e) {
    print('❌ [EXCEL-USO] Error al generar reporte Excel: $e');
    throw Exception('Error al generar reporte Excel de uso y topografía: $e');
  }
}

/// Crea todo el contenido del reporte en una sola hoja usando la librería excel estándar
Future<void> _crearContenidoUsoTopografiaCompleto(
  Sheet sheet,
  String titulo,
  String subtitulo,
  Map<String, dynamic> datos,
  List<Map<String, dynamic>> tablas,
  Map<String, dynamic> metadatos,
) async {
  int filaActual = 0; // Empezar desde fila 0 (excel package usa base 0)

  // === SECCIÓN 1: ENCABEZADO ===
  filaActual = _crearEncabezadoUsoTopografia(sheet, titulo, subtitulo, metadatos, filaActual);
  filaActual += 2;

  // === SECCIÓN 2: FILTROS APLICADOS ===
  filaActual = _crearSeccionFiltrosUsoTopografia(sheet, metadatos, filaActual);
  filaActual += 2;

  // === SECCIÓN 3: RESUMEN ESTADÍSTICO ===
  filaActual = _crearResumenEstadisticoUsoTopografia(sheet, datos, metadatos, filaActual);
  filaActual += 2;

  // === SECCIÓN 4: ANÁLISIS DE USO DE VIVIENDA ===
  filaActual = _crearAnalisisUsoVivienda(sheet, datos, filaActual);
  filaActual += 2;

  // === SECCIÓN 5: ANÁLISIS DE TOPOGRAFÍA ===
  filaActual = _crearAnalisisTopografia(sheet, datos, filaActual);
  filaActual += 2;

  // === SECCIÓN 6: COMPARATIVA Y CONCLUSIONES ===
  _crearSeccionComparativaYConclusiones(sheet, datos, metadatos, filaActual);
}

/// Crea encabezado principal del reporte
int _crearEncabezadoUsoTopografia(
  Sheet sheet,
  String titulo,
  String subtitulo,
  Map<String, dynamic> metadatos,
  int filaInicial,
) {
  int fila = filaInicial;

  // Título principal (fusionar celdas A-F)
  _setCellValue(sheet, fila, 0, titulo.toUpperCase());
  _aplicarEstiloEncabezado(sheet, fila, 0, bold: true, fontSize: 16, backgroundColor: '#1F4E79');
  fila++;

  // Subtítulo
  _setCellValue(sheet, fila, 0, subtitulo);
  _aplicarEstiloEncabezado(sheet, fila, 0, bold: true, fontSize: 14, backgroundColor: '#2F5F8F');
  fila++;

  // Fecha de generación
  String fechaGeneracion = DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now());
  _setCellValue(sheet, fila, 0, 'Generado el: $fechaGeneracion');
  _aplicarEstiloEncabezado(sheet, fila, 0, fontSize: 10, backgroundColor: '#E7E6E6');
  fila++;

  return fila;
}

/// Crea sección de filtros aplicados
int _crearSeccionFiltrosUsoTopografia(
  Sheet sheet,
  Map<String, dynamic> metadatos,
  int filaInicial,
) {
  int fila = filaInicial;

  // Título de sección
  _setCellValue(sheet, fila, 0, 'FILTROS APLICADOS');
  _aplicarEstiloSeccion(sheet, fila, 0);
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

  // Escribir filtros
  for (var filtro in filtros) {
    _setCellValue(sheet, fila, 0, filtro[0]);
    _aplicarEstilo(sheet, fila, 0, bold: true, backgroundColor: '#F2F2F2');
    
    _setCellValue(sheet, fila, 1, filtro[1]);
    _aplicarEstilo(sheet, fila, 1, backgroundColor: '#FAFAFA');
    
    fila++;
  }

  return fila;
}

/// Crea resumen estadístico general
int _crearResumenEstadisticoUsoTopografia(
  Sheet sheet,
  Map<String, dynamic> datos,
  Map<String, dynamic> metadatos,
  int filaInicial,
) {
  int fila = filaInicial;

  // Título de sección
  _setCellValue(sheet, fila, 0, 'RESUMEN ESTADÍSTICO GENERAL');
  _aplicarEstiloSeccion(sheet, fila, 0);
  fila++;

  final int totalFormatos = metadatos['totalFormatos'] ?? 0;

  // Calcular estadísticas de uso
  int totalUsosRegistrados = 0;
  int tiposUsoDistintos = 0;
  if (datos.containsKey('usosVivienda') && datos['usosVivienda']['estadisticas'] != null) {
    Map<String, dynamic> estadisticasUsos = datos['usosVivienda']['estadisticas'];
    totalUsosRegistrados = estadisticasUsos.values.fold(0, (sum, stats) => sum + (stats['conteo'] as int? ?? 0));
    tiposUsoDistintos = estadisticasUsos.values.where((stats) => (stats['conteo'] as int? ?? 0) > 0).length;
  }

  // Calcular estadísticas de topografía
  int totalTopografiaRegistrada = 0;
  int tiposTopografiaDistintos = 0;
  if (datos.containsKey('topografia') && datos['topografia']['estadisticas'] != null) {
    Map<String, dynamic> estadisticasTopografia = datos['topografia']['estadisticas'];
    totalTopografiaRegistrada = estadisticasTopografia.values.fold(0, (sum, stats) => sum + (stats['conteo'] as int? ?? 0));
    tiposTopografiaDistintos = estadisticasTopografia.values.where((stats) => (stats['conteo'] as int? ?? 0) > 0).length;
  }

  // Encabezados
  _setCellValue(sheet, fila, 0, 'Concepto');
  _setCellValue(sheet, fila, 1, 'Valor');
  _setCellValue(sheet, fila, 2, 'Observación');
  _aplicarEstiloTablaHeader(sheet, fila, 0, 3, '#70AD47');
  fila++;

  // Datos estadísticos
  final List<List<String>> estadisticas = [
    ['Total de inmuebles evaluados', '$totalFormatos', '100% de la muestra'],
    ['Tipos de uso identificados', '$tiposUsoDistintos', 'Diversidad de uso'],
    ['Total registros de uso', '$totalUsosRegistrados', 'Algunos inmuebles pueden tener múltiples usos'],
    ['Tipos de topografía identificados', '$tiposTopografiaDistintos', 'Variedad topográfica'],
    ['Total registros de topografía', '$totalTopografiaRegistrada', 'Características del terreno'],
  ];

  for (int i = 0; i < estadisticas.length; i++) {
    var stat = estadisticas[i];
    _setCellValue(sheet, fila, 0, stat[0]);
    _setCellValue(sheet, fila, 1, stat[1]);
    _setCellValue(sheet, fila, 2, stat[2]);
    
    // Alternar colores
    String bgColor = fila % 2 == 0 ? '#F2F2F2' : '#FFFFFF';
    _aplicarEstiloFila(sheet, fila, 0, 3, bgColor);
    fila++;
  }

  return fila;
}

/// Crea análisis detallado de uso de vivienda
int _crearAnalisisUsoVivienda(
  Sheet sheet,
  Map<String, dynamic> datos,
  int filaInicial,
) {
  int fila = filaInicial;

  // Título de sección
  _setCellValue(sheet, fila, 0, 'ANÁLISIS DETALLADO DE USO DE VIVIENDA');
  _aplicarEstiloSeccion(sheet, fila, 0);
  fila++;

  // Verificar si hay datos
  if (!datos.containsKey('usosVivienda') || 
      !datos['usosVivienda'].containsKey('estadisticas')) {
    _setCellValue(sheet, fila, 0, 'No hay datos de uso de vivienda disponibles');
    return fila + 1;
  }

  Map<String, dynamic> estadisticasUsos = datos['usosVivienda']['estadisticas'];
  
  // Encabezados de tabla
  _setCellValue(sheet, fila, 0, 'Tipo de Uso');
  _setCellValue(sheet, fila, 1, 'Cantidad');
  _setCellValue(sheet, fila, 2, 'Porcentaje');
  _setCellValue(sheet, fila, 3, 'Observaciones');
  _aplicarEstiloTablaHeader(sheet, fila, 0, 4, '#9BC2E6');
  fila++;

  // Ordenar datos por cantidad
  var usosOrdenados = estadisticasUsos.entries
      .where((entry) => entry.value['conteo'] > 0)
      .toList()
    ..sort((a, b) => b.value['conteo'].compareTo(a.value['conteo']));

  int totalUsos = usosOrdenados.fold(0, (sum, entry) => sum + entry.value['conteo'] as int);

  // Datos de uso
  for (int i = 0; i < usosOrdenados.length; i++) {
    var entry = usosOrdenados[i];
    String uso = entry.key;
    int conteo = entry.value['conteo'];
    double porcentaje = totalUsos > 0 ? (conteo / totalUsos) * 100 : 0;
    
    String observacion = '';
    if (i == 0) observacion = 'Uso predominante';
    else if (porcentaje > 20) observacion = 'Uso significativo';
    else if (porcentaje > 10) observacion = 'Uso moderado';
    else observacion = 'Uso menor';

    _setCellValue(sheet, fila, 0, uso);
    _setCellValue(sheet, fila, 1, conteo.toString());
    _setCellValue(sheet, fila, 2, '${porcentaje.toStringAsFixed(1)}%');
    _setCellValue(sheet, fila, 3, observacion);
    
    // Alternar colores
    String bgColor = fila % 2 == 0 ? '#F2F2F2' : '#FFFFFF';
    _aplicarEstiloFila(sheet, fila, 0, 4, bgColor);
    fila++;
  }

  // Fila de total
  _setCellValue(sheet, fila, 0, 'TOTAL');
  _setCellValue(sheet, fila, 1, totalUsos.toString());
  _setCellValue(sheet, fila, 2, '100%');
  _setCellValue(sheet, fila, 3, 'Suma de todos los usos');
  _aplicarEstiloTablaHeader(sheet, fila, 0, 4, '#D9E2F3');
  fila++;

  return fila;
}

/// Crea análisis detallado de topografía
int _crearAnalisisTopografia(
  Sheet sheet,
  Map<String, dynamic> datos,
  int filaInicial,
) {
  int fila = filaInicial;

  // Título de sección
  _setCellValue(sheet, fila, 0, 'ANÁLISIS DETALLADO DE TOPOGRAFÍA');
  _aplicarEstiloSeccion(sheet, fila, 0);
  fila++;

  // Verificar si hay datos
  if (!datos.containsKey('topografia') || 
      !datos['topografia'].containsKey('estadisticas')) {
    _setCellValue(sheet, fila, 0, 'No hay datos de topografía disponibles');
    return fila + 1;
  }

  Map<String, dynamic> estadisticasTopografia = datos['topografia']['estadisticas'];
  
  // Encabezados de tabla
  _setCellValue(sheet, fila, 0, 'Tipo de Topografía');
  _setCellValue(sheet, fila, 1, 'Cantidad');
  _setCellValue(sheet, fila, 2, 'Porcentaje');
  _setCellValue(sheet, fila, 3, 'Características');
  _aplicarEstiloTablaHeader(sheet, fila, 0, 4, '#A9D18E');
  fila++;

  // Ordenar datos por cantidad
  var topografiaOrdenada = estadisticasTopografia.entries
      .where((entry) => entry.value['conteo'] > 0)
      .toList()
    ..sort((a, b) => b.value['conteo'].compareTo(a.value['conteo']));

  int totalTopografia = topografiaOrdenada.fold(0, (sum, entry) => sum + entry.value['conteo'] as int);

  // Datos de topografía con características
  Map<String, String> caracteristicasTopografia = {
    'Planicie': 'Terreno plano, estable para construcción',
    'Fondo de valle': 'Zona baja, posible riesgo de inundación',
    'Ladera de cerro': 'Pendiente, riesgo de deslizamiento',
    'Depósitos lacustres': 'Suelo blando, requiere cimentación especial',
    'Rivera río/lago': 'Zona húmeda, considerar nivel freático',
    'Costa': 'Ambiente salino, requiere materiales resistentes',
  };

  for (int i = 0; i < topografiaOrdenada.length; i++) {
    var entry = topografiaOrdenada[i];
    String tipo = entry.key;
    int conteo = entry.value['conteo'];
    double porcentaje = totalTopografia > 0 ? (conteo / totalTopografia) * 100 : 0;
    String caracteristica = caracteristicasTopografia[tipo] ?? 'Consultar especificaciones técnicas';

    _setCellValue(sheet, fila, 0, tipo);
    _setCellValue(sheet, fila, 1, conteo.toString());
    _setCellValue(sheet, fila, 2, '${porcentaje.toStringAsFixed(1)}%');
    _setCellValue(sheet, fila, 3, caracteristica);
    
    // Alternar colores
    String bgColor = fila % 2 == 0 ? '#F2F2F2' : '#FFFFFF';
    _aplicarEstiloFila(sheet, fila, 0, 4, bgColor);
    fila++;
  }

  // Fila de total
  _setCellValue(sheet, fila, 0, 'TOTAL');
  _setCellValue(sheet, fila, 1, totalTopografia.toString());
  _setCellValue(sheet, fila, 2, '100%');
  _setCellValue(sheet, fila, 3, 'Todas las características identificadas');
  _aplicarEstiloTablaHeader(sheet, fila, 0, 4, '#E2EFDA');
  fila++;

  return fila;
}

/// Crea sección de comparativa y conclusiones
void _crearSeccionComparativaYConclusiones(
  Sheet sheet,
  Map<String, dynamic> datos,
  Map<String, dynamic> metadatos,
  int filaInicial,
) {
  int fila = filaInicial;

  // Título de sección
  _setCellValue(sheet, fila, 0, 'COMPARATIVA Y CONCLUSIONES');
  _aplicarEstiloSeccion(sheet, fila, 0);
  fila++;

  // Análisis comparativo
  _setCellValue(sheet, fila, 0, 'ANÁLISIS COMPARATIVO');
  _aplicarEstilo(sheet, fila, 0, bold: true, backgroundColor: '#FFE2CC');
  fila++;

  // Encontrar uso y topografía predominantes
  String usoPredominante = 'No determinado';
  String topografiaPredominante = 'No determinado';

  // Buscar uso más común
  if (datos.containsKey('usosVivienda') && datos['usosVivienda']['estadisticas'] != null) {
    Map<String, dynamic> estadisticasUsos = datos['usosVivienda']['estadisticas'];
    var usoMax = estadisticasUsos.entries
        .where((entry) => entry.value['conteo'] > 0)
        .fold<MapEntry<String, dynamic>?>(null, (prev, curr) => prev == null || curr.value['conteo'] > prev.value['conteo'] ? curr : prev);
    if (usoMax != null) usoPredominante = usoMax.key;
  }

  // Buscar topografía más común
  if (datos.containsKey('topografia') && datos['topografia']['estadisticas'] != null) {
    Map<String, dynamic> estadisticasTopografia = datos['topografia']['estadisticas'];
    var topoMax = estadisticasTopografia.entries
        .where((entry) => entry.value['conteo'] > 0)
        .fold<MapEntry<String, dynamic>?>(null, (prev, curr) => prev == null || (curr as MapEntry<String, dynamic>).value['conteo'] > prev.value['conteo'] ? curr : prev);
    if (topoMax != null) topografiaPredominante = topoMax.key;
  }

  // Comparativa
  _setCellValue(sheet, fila, 0, 'Uso predominante:');
  _setCellValue(sheet, fila, 1, usoPredominante);
  _aplicarEstilo(sheet, fila, 0, bold: true);
  fila++;

  _setCellValue(sheet, fila, 0, 'Topografía predominante:');
  _setCellValue(sheet, fila, 1, topografiaPredominante);
  _aplicarEstilo(sheet, fila, 0, bold: true);
  fila++;

  fila++;

  // Conclusiones
  String conclusiones = metadatos['conclusiones'] ?? 'No hay conclusiones disponibles.';
  _setCellValue(sheet, fila, 0, 'CONCLUSIONES:');
  _aplicarEstilo(sheet, fila, 0, bold: true, backgroundColor: '#FFF2CC');
  fila++;

  // Dividir conclusiones en líneas más manejables
  List<String> lineasConclusiones = conclusiones.split('\n').where((linea) => linea.trim().isNotEmpty).toList();
  
  for (String linea in lineasConclusiones) {
    _setCellValue(sheet, fila, 0, linea.trim());
    _aplicarEstilo(sheet, fila, 0, backgroundColor: '#FFF9E6');
    fila++;
  }
}

/// Guarda el archivo Excel usando la librería excel estándar
Future<String> _guardarArchivoExcelEstandar(
  Excel excel,
  String titulo,
  Directory? directorio,
) async {
  try {
    // Obtener directorio de destino
    final directorioFinal = directorio ?? await FileStorageService().obtenerDirectorioDescargas();
    
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
    final List<int>? bytes = excel.save();
    if (bytes != null) {
      final File archivo = File(rutaCompleta);
      await archivo.writeAsBytes(bytes);

      // Verificar que el archivo se guardó correctamente
      if (await archivo.exists() && await archivo.length() > 0) {
        print('✅ [EXCEL-USO] Archivo Excel guardado: $rutaCompleta (${await archivo.length()} bytes)');
        return rutaCompleta;
      } else {
        throw Exception('El archivo Excel no se guardó correctamente');
      }
    } else {
      throw Exception('No se pudieron generar los bytes del archivo Excel');
    }

  } catch (e) {
    print('❌ [EXCEL-USO] Error al guardar archivo Excel: $e');
    throw Exception('Error al guardar archivo Excel: $e');
  }
}

// === MÉTODOS AUXILIARES PARA FORMATEO (usando librería excel estándar) ===

/// Establece valor en una celda
void _setCellValue(Sheet sheet, int fila, int columna, String valor) {
  sheet.cell(CellIndex.indexByColumnRow(columnIndex: columna, rowIndex: fila)).value = TextCellValue(valor);
}

/// Aplica estilo de encabezado
void _aplicarEstiloEncabezado(Sheet sheet, int fila, int columna, {bool bold = false, int fontSize = 12, String backgroundColor = '#FFFFFF'}) {
  var cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: columna, rowIndex: fila));
  cell.cellStyle = CellStyle(
    bold: bold,
    fontSize: fontSize,
    backgroundColorHex: ExcelColor.white,
  );
}



/// Aplica estilo general
void _aplicarEstilo(Sheet sheet, int fila, int columna, {bool bold = false, String backgroundColor = '#FFFFFF'}) {
  var cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: columna, rowIndex: fila));
  cell.cellStyle = CellStyle(
    bold: bold,
    backgroundColorHex: ExcelColor.white,
  );
}

/// Aplica estilo a header de tabla
void _aplicarEstiloTablaHeader(Sheet sheet, int fila, int columnaInicio, int numColumnas, String backgroundColor) {
  for (int i = 0; i < numColumnas; i++) {
    var cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: columnaInicio + i, rowIndex: fila));
    cell.cellStyle = CellStyle(
      bold: true,
      backgroundColorHex: ExcelColor.white,
    );
  }
}

/// Aplica estilo a una fila completa
void _aplicarEstiloFila(Sheet sheet, int fila, int columnaInicio, int numColumnas, String backgroundColor) {
  for (int i = 0; i < numColumnas; i++) {
    var cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: columnaInicio + i, rowIndex: fila));
    cell.cellStyle = CellStyle(
      backgroundColorHex: ExcelColor.white,
    );
  }
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
/// Aplica estilo de sección
  void _aplicarEstiloSeccion(Sheet hoja, int fila, int columna) {
    try {
      final celda = CellIndex.indexByColumnRow(columnIndex: columna, rowIndex: fila);
      hoja.cell(celda).cellStyle = CellStyle(
        bold: true,
        fontSize: 12,
        fontFamily: getFontFamily(FontFamily.Arial),
        backgroundColorHex: ExcelColor.lightBlue,
        fontColorHex: ExcelColor.black,
      );
    } catch (e) {
      print('⚠️ Error aplicando estilo sección: $e');
    }
  }



  /// Genera un reporte completo de Resumen General en Excel
  Future<String> generarReporteResumenGeneralExcel({
    required String titulo,
  required String subtitulo,
  required Map<String, dynamic> datos,
  required List<Map<String, dynamic>> tablas,
  required Map<String, dynamic> metadatos,
  Directory? directorio,
}) async {
  try {
    print('📊 [EXCEL-RESUMEN] Iniciando generación optimizada de reporte Excel: $titulo');

    // Crear nuevo libro de Excel usando la librería excel
    var excel = Excel.createExcel();
    
    // Eliminar hoja por defecto
    excel.delete('Sheet1');
    
    // Crear hoja única con TODO el contenido del resumen general
    String nombreHoja = 'Resumen General Completo';
    excel.copy('Sheet1', nombreHoja);
    excel.delete('Sheet1');
    
    Sheet sheet = excel[nombreHoja];
    
    // Crear contenido completo en una sola hoja
    await _crearContenidoResumenGeneralCompleto(sheet, titulo, subtitulo, datos, tablas, metadatos);

    // Guardar archivo
    final String rutaArchivo = await _guardarArchivoExcelEstandar(
      excel, 
      titulo, 
      directorio
    );
    
    print('✅ [EXCEL-RESUMEN] Reporte Excel optimizado generado exitosamente: $rutaArchivo');
    return rutaArchivo;

  } catch (e) {
    print('❌ [EXCEL-RESUMEN] Error al generar reporte Excel optimizado: $e');
    throw Exception('Error al generar reporte Excel: $e');
  }
}

/// Crea todo el contenido del resumen general en una sola hoja
Future<void> _crearContenidoResumenGeneralCompleto(
  Sheet sheet,
  String titulo,
  String subtitulo,
  Map<String, dynamic> datos,
  List<Map<String, dynamic>> tablas,
  Map<String, dynamic> metadatos,
) async {
  int filaActual = 0;

  // === SECCIÓN 1: ENCABEZADO ===
  filaActual = _crearEncabezadoUsoTopografia(sheet, titulo, subtitulo, metadatos, filaActual);
  filaActual += 2;

  // === SECCIÓN 2: FILTROS APLICADOS ===
  filaActual = _crearSeccionFiltrosUsoTopografia(sheet, metadatos, filaActual);
  filaActual += 2;

  // === SECCIÓN 3: ESTADÍSTICAS GENERALES ===
  filaActual = _crearEstadisticasGeneralesResumen(sheet, datos, metadatos, filaActual);
  filaActual += 2;

  // === SECCIÓN 4: DISTRIBUCIÓN POR CIUDADES ===
  filaActual = _crearDistribucionCiudades(sheet, datos, filaActual);
  filaActual += 2;

  // === SECCIÓN 5: DISTRIBUCIÓN POR COLONIAS (TOP 10) ===
  filaActual = _crearDistribucionColonias(sheet, datos, filaActual);
  filaActual += 2;

  // === SECCIÓN 6: DISTRIBUCIÓN TEMPORAL ===
  filaActual = _crearDistribucionTemporal(sheet, datos, filaActual);
  filaActual += 2;

  // === SECCIÓN 7: INDICADORES CLAVE ===
  _crearIndicadoresClave(sheet, datos, metadatos, filaActual);
}

/// Crea estadísticas generales del resumen
int _crearEstadisticasGeneralesResumen(
  Sheet sheet,
  Map<String, dynamic> datos,
  Map<String, dynamic> metadatos,
  int filaInicial,
) {
  int fila = filaInicial;

  // Título de sección
  _setCellValue(sheet, fila, 0, 'ESTADÍSTICAS GENERALES');
  _aplicarEstiloSeccion(sheet, fila, 0);
  fila++;

  final int totalFormatos = metadatos['totalFormatos'] ?? 0;
  
  // Extraer datos de distribución geográfica
  Map<String, int> ciudades = {};
  Map<String, int> colonias = {};
  Map<String, int> meses = {};
  
  if (datos.containsKey('distribucionGeografica')) {
    ciudades = Map<String, int>.from(datos['distribucionGeografica']['ciudades'] ?? {});
    colonias = Map<String, int>.from(datos['distribucionGeografica']['colonias'] ?? {});
  }
  
  if (datos.containsKey('distribucionTemporal')) {
    meses = Map<String, int>.from(datos['distribucionTemporal']['meses'] ?? {});
  }

  // Encabezados de tabla
  _setCellValue(sheet, fila, 0, 'Concepto');
  _setCellValue(sheet, fila, 1, 'Valor');
  _setCellValue(sheet, fila, 2, 'Porcentaje/Observación');
  _aplicarEstiloTablaHeader(sheet, fila, 0, 3, '#70AD47');
  fila++;

  // Estadísticas principales
  final List<List<String>> estadisticas = [
    ['Total de inmuebles evaluados', '$totalFormatos', '100%'],
    ['Ciudades cubiertas', '${ciudades.length}', 'Cobertura geográfica'],
    ['Colonias cubiertas', '${colonias.length}', 'Distribución local'],
    ['Períodos analizados', '${meses.length}', 'Cobertura temporal'],
  ];

  // Encontrar ciudad principal
  if (ciudades.isNotEmpty) {
    final ciudadPrincipal = ciudades.entries.reduce((a, b) => a.value > b.value ? a : b);
    final porcentajeCiudad = totalFormatos > 0 ? (ciudadPrincipal.value / totalFormatos * 100) : 0;
    estadisticas.add([
      'Ciudad principal', 
      '${ciudadPrincipal.key}', 
      '${ciudadPrincipal.value} inmuebles (${porcentajeCiudad.toStringAsFixed(1)}%)'
    ]);
  }

  // Encontrar mes más activo
  if (meses.isNotEmpty) {
    final mesPrincipal = meses.entries.reduce((a, b) => a.value > b.value ? a : b);
    estadisticas.add([
      'Mes más activo', 
      '${mesPrincipal.key}', 
      '${mesPrincipal.value} evaluaciones'
    ]);
  }

  // Escribir estadísticas
  for (int i = 0; i < estadisticas.length; i++) {
    var stat = estadisticas[i];
    _setCellValue(sheet, fila, 0, stat[0]);
    _setCellValue(sheet, fila, 1, stat[1]);
    _setCellValue(sheet, fila, 2, stat[2]);
    
    // Alternar colores
    String bgColor = fila % 2 == 0 ? '#F2F2F2' : '#FFFFFF';
    _aplicarEstiloFila(sheet, fila, 0, 3, bgColor);
    fila++;
  }

  return fila;
}

/// Crea distribución por ciudades
int _crearDistribucionCiudades(
  Sheet sheet,
  Map<String, dynamic> datos,
  int filaInicial,
) {
  int fila = filaInicial;

  // Título de sección
  _setCellValue(sheet, fila, 0, 'DISTRIBUCIÓN POR CIUDADES');
  _aplicarEstiloSeccion(sheet, fila, 0);
  fila++;

  // Verificar si hay datos
  if (!datos.containsKey('distribucionGeografica') || 
      datos['distribucionGeografica']['ciudades'].isEmpty) {
    _setCellValue(sheet, fila, 0, 'No hay datos de distribución por ciudades disponibles');
    return fila + 1;
  }

  Map<String, int> ciudades = Map<String, int>.from(datos['distribucionGeografica']['ciudades']);
  
  // Encabezados
  _setCellValue(sheet, fila, 0, 'Ciudad');
  _setCellValue(sheet, fila, 1, 'Cantidad');
  _setCellValue(sheet, fila, 2, 'Porcentaje');
  _setCellValue(sheet, fila, 3, 'Clasificación');
  _aplicarEstiloTablaHeader(sheet, fila, 0, 4, '#9BC2E6');
  fila++;

  // Ordenar ciudades por cantidad
  var ciudadesOrdenadas = ciudades.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));

  int totalCiudades = ciudades.values.fold(0, (sum, val) => sum + val);

  for (int i = 0; i < ciudadesOrdenadas.length; i++) {
    var entry = ciudadesOrdenadas[i];
    String ciudad = entry.key;
    int conteo = entry.value;
    double porcentaje = totalCiudades > 0 ? (conteo / totalCiudades) * 100 : 0;
    
    String clasificacion = '';
    if (i == 0) clasificacion = 'Principal';
    else if (porcentaje > 15) clasificacion = 'Significativa';
    else if (porcentaje > 5) clasificacion = 'Moderada';
    else clasificacion = 'Menor';

    _setCellValue(sheet, fila, 0, ciudad);
    _setCellValue(sheet, fila, 1, conteo.toString());
    _setCellValue(sheet, fila, 2, '${porcentaje.toStringAsFixed(2)}%');
    _setCellValue(sheet, fila, 3, clasificacion);
    
    // Alternar colores
    String bgColor = fila % 2 == 0 ? '#F2F2F2' : '#FFFFFF';
    _aplicarEstiloFila(sheet, fila, 0, 4, bgColor);
    fila++;
  }

  // Total
  _setCellValue(sheet, fila, 0, 'TOTAL');
  _setCellValue(sheet, fila, 1, totalCiudades.toString());
  _setCellValue(sheet, fila, 2, '100%');
  _setCellValue(sheet, fila, 3, 'Todas las ciudades');
  _aplicarEstiloTablaHeader(sheet, fila, 0, 4, '#D9E2F3');
  fila++;

  return fila;
}

/// Crea distribución por colonias (top 10)
int _crearDistribucionColonias(
  Sheet sheet,
  Map<String, dynamic> datos,
  int filaInicial,
) {
  int fila = filaInicial;

  // Título de sección
  _setCellValue(sheet, fila, 0, 'DISTRIBUCIÓN POR COLONIAS (TOP 10)');
  _aplicarEstiloSeccion(sheet, fila, 0);
  fila++;

  // Verificar si hay datos
  if (!datos.containsKey('distribucionGeografica') || 
      datos['distribucionGeografica']['colonias'].isEmpty) {
    _setCellValue(sheet, fila, 0, 'No hay datos de distribución por colonias disponibles');
    return fila + 1;
  }

  Map<String, int> colonias = Map<String, int>.from(datos['distribucionGeografica']['colonias']);
  
  // Encabezados
  _setCellValue(sheet, fila, 0, 'Colonia');
  _setCellValue(sheet, fila, 1, 'Cantidad');
  _setCellValue(sheet, fila, 2, 'Porcentaje');
  _setCellValue(sheet, fila, 3, 'Ranking');
  _aplicarEstiloTablaHeader(sheet, fila, 0, 4, '#A9D18E');
  fila++;

  // Ordenar colonias y tomar top 10
  var coloniasOrdenadas = colonias.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  
  var coloniasTop10 = coloniasOrdenadas.take(10).toList();
  int totalColonias = colonias.values.fold(0, (sum, val) => sum + val);

  for (int i = 0; i < coloniasTop10.length; i++) {
    var entry = coloniasTop10[i];
    String colonia = entry.key;
    int conteo = entry.value;
    double porcentaje = totalColonias > 0 ? (conteo / totalColonias) * 100 : 0;

    _setCellValue(sheet, fila, 0, colonia);
    _setCellValue(sheet, fila, 1, conteo.toString());
    _setCellValue(sheet, fila, 2, '${porcentaje.toStringAsFixed(2)}%');
    _setCellValue(sheet, fila, 3, '#${i + 1}');
    
    // Alternar colores
    String bgColor = fila % 2 == 0 ? '#F2F2F2' : '#FFFFFF';
    _aplicarEstiloFila(sheet, fila, 0, 4, bgColor);
    fila++;
  }

  // Nota sobre el resto
  if (colonias.length > 10) {
    int restantes = colonias.length - 10;
    int conteoRestantes = totalColonias - coloniasTop10.fold(0, (sum, entry) => sum + entry.value);
    double porcentajeRestantes = totalColonias > 0 ? (conteoRestantes / totalColonias) * 100 : 0;
    
    _setCellValue(sheet, fila, 0, 'Otras $restantes colonias');
    _setCellValue(sheet, fila, 1, conteoRestantes.toString());
    _setCellValue(sheet, fila, 2, '${porcentajeRestantes.toStringAsFixed(2)}%');
    _setCellValue(sheet, fila, 3, 'Resto');
    _aplicarEstiloTablaHeader(sheet, fila, 0, 4, '#E2EFDA');
    fila++;
  }

  return fila;
}

/// Crea distribución temporal
int _crearDistribucionTemporal(
  Sheet sheet,
  Map<String, dynamic> datos,
  int filaInicial,
) {
  int fila = filaInicial;

  // Título de sección
  _setCellValue(sheet, fila, 0, 'DISTRIBUCIÓN TEMPORAL');
  _aplicarEstiloSeccion(sheet, fila, 0);
  fila++;

  // Verificar si hay datos
  if (!datos.containsKey('distribucionTemporal') || 
      datos['distribucionTemporal']['meses'].isEmpty) {
    _setCellValue(sheet, fila, 0, 'No hay datos de distribución temporal disponibles');
    return fila + 1;
  }

  Map<String, int> meses = Map<String, int>.from(datos['distribucionTemporal']['meses']);
  
  // Encabezados
  _setCellValue(sheet, fila, 0, 'Período (MM/YYYY)');
  _setCellValue(sheet, fila, 1, 'Evaluaciones');
  _setCellValue(sheet, fila, 2, 'Porcentaje');
  _setCellValue(sheet, fila, 3, 'Tendencia');
  _aplicarEstiloTablaHeader(sheet, fila, 0, 4, '#F4CCCC');
  fila++;

  // Ordenar meses cronológicamente
  var mesesOrdenados = meses.entries.toList()
    ..sort((a, b) {
      try {
        final fechaA = DateFormat('MM/yyyy').parse(a.key);
        final fechaB = DateFormat('MM/yyyy').parse(b.key);
        return fechaA.compareTo(fechaB);
      } catch (e) {
        return a.key.compareTo(b.key);
      }
    });

  int totalEvaluaciones = meses.values.fold(0, (sum, val) => sum + val);
  double promedioMensual = totalEvaluaciones / meses.length;

  for (int i = 0; i < mesesOrdenados.length; i++) {
    var entry = mesesOrdenados[i];
    String mes = entry.key;
    int conteo = entry.value;
    double porcentaje = totalEvaluaciones > 0 ? (conteo / totalEvaluaciones) * 100 : 0;
    
    String tendencia = '';
    if (conteo > promedioMensual * 1.2) tendencia = 'Alta actividad';
    else if (conteo > promedioMensual * 0.8) tendencia = 'Actividad normal';
    else tendencia = 'Baja actividad';

    _setCellValue(sheet, fila, 0, mes);
    _setCellValue(sheet, fila, 1, conteo.toString());
    _setCellValue(sheet, fila, 2, '${porcentaje.toStringAsFixed(2)}%');
    _setCellValue(sheet, fila, 3, tendencia);
    
    // Alternar colores
    String bgColor = fila % 2 == 0 ? '#F2F2F2' : '#FFFFFF';
    _aplicarEstiloFila(sheet, fila, 0, 4, bgColor);
    fila++;
  }

  // Promedio mensual
  _setCellValue(sheet, fila, 0, 'PROMEDIO MENSUAL');
  _setCellValue(sheet, fila, 1, promedioMensual.toStringAsFixed(1));
  _setCellValue(sheet, fila, 2, '${(100 / meses.length).toStringAsFixed(1)}%');
  _setCellValue(sheet, fila, 3, 'Referencia estadística');
  _aplicarEstiloTablaHeader(sheet, fila, 0, 4, '#FFE2CC');
  fila++;

  return fila;
}

/// Crea indicadores clave y conclusiones
void _crearIndicadoresClave(
  Sheet sheet,
  Map<String, dynamic> datos,
  Map<String, dynamic> metadatos,
  int filaInicial,
) {
  int fila = filaInicial;

  // Título de sección
  _setCellValue(sheet, fila, 0, 'INDICADORES CLAVE Y CONCLUSIONES');
  _aplicarEstiloSeccion(sheet, fila, 0);
  fila++;

  // Calcular concentración geográfica
  Map<String, int> ciudades = {};
  if (datos.containsKey('distribucionGeografica')) {
    ciudades = Map<String, int>.from(datos['distribucionGeografica']['ciudades'] ?? {});
  }

  if (ciudades.isNotEmpty && ciudades.length > 1) {
    final totalEvaluaciones = ciudades.values.fold(0, (sum, val) => sum + val);
    double indiceHerfindahl = 0;
    
    for (var conteo in ciudades.values) {
      double proporcion = conteo / totalEvaluaciones;
      indiceHerfindahl += proporcion * proporcion;
    }
    
    String nivelConcentracion;
    if (indiceHerfindahl > 0.7) {
      nivelConcentracion = 'Alta concentración geográfica';
    } else if (indiceHerfindahl > 0.4) {
      nivelConcentracion = 'Concentración geográfica media';
    } else {
      nivelConcentracion = 'Distribución geográfica uniforme';
    }

    _setCellValue(sheet, fila, 0, 'Concentración geográfica:');
    _setCellValue(sheet, fila, 1, nivelConcentracion);
    _setCellValue(sheet, fila, 2, 'Índice: ${(indiceHerfindahl * 100).toStringAsFixed(1)}%');
    _aplicarEstilo(sheet, fila, 0, bold: true);
    fila++;
  }

  // Resumen ejecutivo
  _setCellValue(sheet, fila, 0, 'RESUMEN EJECUTIVO:');
  _aplicarEstilo(sheet, fila, 0, bold: true, backgroundColor: '#FFF2CC');
  fila++;

  final int totalFormatos = metadatos['totalFormatos'] ?? 0;
  String resumenEjecutivo = 'Se analizaron $totalFormatos inmuebles distribuidos en ${ciudades.length} ciudades durante el período especificado. ';
  
  if (ciudades.isNotEmpty) {
    final ciudadPrincipal = ciudades.entries.reduce((a, b) => a.value > b.value ? a : b);
    resumenEjecutivo += 'La ciudad con mayor concentración de evaluaciones fue ${ciudadPrincipal.key} con ${ciudadPrincipal.value} inmuebles. ';
  }
  
  resumenEjecutivo += 'Este análisis proporciona una base sólida para la planificación de recursos y toma de decisiones en evaluaciones estructurales futuras.';

  _setCellValue(sheet, fila, 0, resumenEjecutivo);
  _aplicarEstilo(sheet, fila, 0, backgroundColor: '#FFF9E6');
  fila++;
}
}