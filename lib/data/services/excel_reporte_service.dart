// lib/data/services/excel_reporte_service.dart

import 'dart:io';
import 'package:excel/excel.dart';
import 'dart:math';
import 'package:intl/intl.dart';
import './file_storage_service.dart';

/// Servicio especializado para generar reportes en formato Excel
/// Optimizado para crear hojas de cálculo con datos estadísticos,
/// tablas formateadas y representaciones visuales de gráficos
class ExcelReporteService {
  

  /// Genera un reporte completo unificado en Excel que incluye todas las secciones
/// Integra: Resumen General, Uso y Topografía, Material Dominante, 
/// Sistema Estructural y Evaluación de Daños en una sola hoja optimizada
Future<String> generarReporteCompletoExcel({
  required String titulo,
  required String subtitulo,
  required Map<String, dynamic> datos,
  required List<Map<String, dynamic>> tablas,
  required Map<String, dynamic> metadatos,
  Directory? directorio,
}) async {
  try {
    print('📊 [EXCEL-COMPLETO] Iniciando generación de reporte integral: $titulo');

    // Crear nuevo libro de Excel
    var excel = Excel.createExcel();
    excel.delete('Sheet1');
    
    // Crear hoja única con todo el contenido integral
    String nombreHoja = 'Reporte Integral Completo';
    excel.copy('Sheet1', nombreHoja);
    excel.delete('Sheet1');
    
    Sheet sheet = excel[nombreHoja];
    
    // Crear contenido integral completo en una sola hoja
    await _crearContenidoReporteCompletoIntegral(
      sheet, titulo, subtitulo, datos, tablas, metadatos
    );

    // Guardar archivo con nombre específico
    final String rutaArchivo = await _guardarArchivoExcelEstandar(
      excel, 
      'reporte_completo_integral', 
      directorio
    );
    
    print('✅ [EXCEL-COMPLETO] Reporte integral Excel generado: $rutaArchivo');
    return rutaArchivo;

  } catch (e) {
    print('❌ [EXCEL-COMPLETO] Error al generar reporte integral: $e');
    throw Exception('Error al generar reporte Excel completo: $e');
  }
}

/// Crea todo el contenido del reporte completo integral en una sola hoja
/// Organiza las 5 secciones principales de forma clara y estructurada
Future<void> _crearContenidoReporteCompletoIntegral(
  Sheet sheet,
  String titulo,
  String subtitulo,
  Map<String, dynamic> datos,
  List<Map<String, dynamic>> tablas,
  Map<String, dynamic> metadatos,
) async {
  int filaActual = 0;

  // === ENCABEZADO PRINCIPAL ===
  filaActual = _crearEncabezadoReporteCompleto(
    sheet, titulo, subtitulo, metadatos, filaActual
  );
  filaActual += 2;

  // === RESUMEN EJECUTIVO CONSOLIDADO ===
  filaActual = _crearResumenEjecutivoConsolidado(
    sheet, datos, metadatos, filaActual
  );
  filaActual += 3;

  // === SECCIÓN 1: RESUMEN GENERAL Y DISTRIBUCIÓN ===
  filaActual = _crearSeccionResumenGeneralCompleto(
    sheet, datos, filaActual
  );
  filaActual += 3;

  // === SECCIÓN 2: USO DE VIVIENDA Y TOPOGRAFÍA ===
  filaActual = _crearSeccionUsoTopografiaCompleto(
    sheet, datos, filaActual
  );
  filaActual += 3;

  // === SECCIÓN 3: MATERIAL DOMINANTE ===
  filaActual = _crearSeccionMaterialDominanteCompleto(
    sheet, datos, filaActual
  );
  filaActual += 3;

  // === SECCIÓN 4: SISTEMA ESTRUCTURAL ===
  filaActual = _crearSeccionSistemaEstructuralCompleto(
    sheet, datos, filaActual
  );
  filaActual += 3;

  // === SECCIÓN 5: EVALUACIÓN DE DAÑOS Y RIESGOS ===
  filaActual = _crearSeccionEvaluacionDanosCompleto(
    sheet, datos, filaActual
  );
  filaActual += 3;

  // === CONCLUSIONES Y RECOMENDACIONES INTEGRALES ===
  _crearConclusionesIntegralesCompletas(
    sheet, datos, metadatos, filaActual
  );
}

/// Crea encabezado específico para reporte completo
int _crearEncabezadoReporteCompleto(
  Sheet sheet,
  String titulo,
  String subtitulo,
  Map<String, dynamic> metadatos,
  int filaInicial,
) {
  int fila = filaInicial;

  // Título principal destacado
  _setCellValue(sheet, fila, 0, 'REPORTE INTEGRAL DE EVALUACIÓN ESTRUCTURAL');
  _aplicarEstiloEncabezado(sheet, fila, 0, bold: true, fontSize: 18, backgroundColor: '#1F4E79');
  fila++;

  // Subtítulo descriptivo
  _setCellValue(sheet, fila, 0, 'Análisis Multidimensional Completo - 5 Módulos Integrados');
  _aplicarEstiloEncabezado(sheet, fila, 0, bold: true, fontSize: 14, backgroundColor: '#2F5F8F');
  fila++;

  // Información de contexto
  String fechaGeneracion = DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now());
  _setCellValue(sheet, fila, 0, 'Generado: $fechaGeneracion | Formatos: ${metadatos['totalFormatos']} | Período: ${metadatos['periodoEvaluacion'] ?? 'No especificado'}');
  _aplicarEstiloEncabezado(sheet, fila, 0, fontSize: 10, backgroundColor: '#E7E6E6');
  fila++;

  return fila;
}

/// Crea resumen ejecutivo consolidado con indicadores clave
int _crearResumenEjecutivoConsolidado(
  Sheet sheet,
  Map<String, dynamic> datos,
  Map<String, dynamic> metadatos,
  int filaInicial,
) {
  int fila = filaInicial;

  // Título de sección
  _setCellValue(sheet, fila, 0, 'RESUMEN EJECUTIVO CONSOLIDADO');
  _aplicarEstiloSeccion(sheet, fila, 0);
  fila++;

  final int totalFormatos = metadatos['totalFormatos'] ?? 0;

  // Calcular indicadores clave de todas las secciones
  
  // Del resumen general
  int ciudadesCubiertas = 0;
  if (datos['resumenGeneral']?['distribucionGeografica']?['ciudades'] != null) {
    ciudadesCubiertas = datos['resumenGeneral']['distribucionGeografica']['ciudades'].length;
  }

  // Del material dominante
  String materialPredominante = 'No determinado';
  if (datos['materialDominante']?['conteoMateriales'] != null) {
    final materiales = Map<String, int>.from(datos['materialDominante']['conteoMateriales']);
    if (materiales.isNotEmpty) {
      final entry = materiales.entries.where((e) => e.value > 0).fold<MapEntry<String, int>?>(
        null, (prev, curr) => prev == null || curr.value > prev.value ? curr : prev);
      if (entry != null) materialPredominante = entry.key;
    }
  }

  // De evaluación de daños
  int inmueblesSinDano = 0;
  int inmueblesRiesgoAlto = 0;
  if (datos['evaluacionDanos']?['resumenRiesgos'] != null) {
    final riesgos = datos['evaluacionDanos']['resumenRiesgos'];
    inmueblesRiesgoAlto = riesgos['riesgoAlto'] ?? 0;
    inmueblesSinDano = (totalFormatos - (riesgos['riesgoAlto'] ?? 0) - (riesgos['riesgoMedio'] ?? 0) - (riesgos['riesgoBajo'] ?? 0)).toInt();
  }

  // Encabezados
  _setCellValue(sheet, fila, 0, 'Indicador Clave');
  _setCellValue(sheet, fila, 1, 'Valor');
  _setCellValue(sheet, fila, 2, 'Interpretación');
  _setCellValue(sheet, fila, 3, 'Estado');
  _aplicarEstiloTablaHeader(sheet, fila, 0, 4, '#FFB366');
  fila++;

  // Indicadores consolidados
  final List<List<String>> indicadores = [
    ['Inmuebles evaluados', '$totalFormatos', 'Muestra total analizada', 'Completo'],
    ['Cobertura geográfica', '$ciudadesCubiertas ciudades', 'Distribución territorial', ciudadesCubiertas > 3 ? 'Amplia' : 'Limitada'],
    ['Material predominante', materialPredominante, 'Patrón constructivo principal', materialPredominante == 'Concreto' ? 'Resistente' : 'Revisar'],
    ['Inmuebles riesgo alto', '$inmueblesRiesgoAlto', 'Requieren intervención inmediata', inmueblesRiesgoAlto > 0 ? 'Crítico' : 'Estable'],
    ['Tasa de seguridad', '${((inmueblesSinDano / totalFormatos) * 100).toStringAsFixed(1)}%', 'Inmuebles sin daños aparentes', inmueblesSinDano > (totalFormatos * 0.7) ? 'Buena' : 'Preocupante'],
  ];

  for (int i = 0; i < indicadores.length; i++) {
    var indicador = indicadores[i];
    _setCellValue(sheet, fila, 0, indicador[0]);
    _setCellValue(sheet, fila, 1, indicador[1]);
    _setCellValue(sheet, fila, 2, indicador[2]);
    _setCellValue(sheet, fila, 3, indicador[3]);
    
    // Color por estado
    String bgColor = '#FFFFFF';
    if (indicador[3] == 'Crítico' || indicador[3] == 'Preocupante') {
      bgColor = '#FFE8E8';
    } else if (indicador[3] == 'Buena' || indicador[3] == 'Amplia') {
      bgColor = '#E8F5E8';
    } else if (indicador[3] == 'Revisar') {
      bgColor = '#FFF2CC';
    } else {
      bgColor = fila % 2 == 0 ? '#F2F2F2' : '#FFFFFF';
    }
    
    _aplicarEstiloFila(sheet, fila, 0, 4, bgColor);
    fila++;
  }

  return fila;
}

/// Crea sección consolidada de resumen general
int _crearSeccionResumenGeneralCompleto(
  Sheet sheet,
  Map<String, dynamic> datos,
  int filaInicial,
) {
  int fila = filaInicial;

  // Título de sección con número
  _setCellValue(sheet, fila, 0, '1. RESUMEN GENERAL Y DISTRIBUCIÓN TERRITORIAL');
  _aplicarEstiloSeccion(sheet, fila, 0);
  fila++;

  // Verificar datos
  if (!datos.containsKey('resumenGeneral')) {
    _setCellValue(sheet, fila, 0, 'Datos de resumen general no disponibles');
    return fila + 1;
  }

  // Distribución por ciudades (top 5)
  final distribucionGeo = datos['resumenGeneral']['distribucionGeografica'];
  if (distribucionGeo['ciudades'] != null && distribucionGeo['ciudades'].isNotEmpty) {
    Map<String, int> ciudades = Map<String, int>.from(distribucionGeo['ciudades']);
    
    _setCellValue(sheet, fila, 0, 'TOP 5 CIUDADES CON MÁS EVALUACIONES');
    _aplicarEstilo(sheet, fila, 0, bold: true, backgroundColor: '#E2EFDA');
    fila++;

    // Encabezados
    _setCellValue(sheet, fila, 0, 'Ciudad');
    _setCellValue(sheet, fila, 1, 'Evaluaciones');
    _setCellValue(sheet, fila, 2, 'Porcentaje');
    _aplicarEstiloTablaHeader(sheet, fila, 0, 3, '#9BC2E6');
    fila++;

    var ciudadesTop = ciudades.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    ciudadesTop = ciudadesTop.take(5).toList();

    int totalCiudades = ciudades.values.fold(0, (sum, val) => sum + val);

    for (var entry in ciudadesTop) {
      double porcentaje = totalCiudades > 0 ? (entry.value / totalCiudades) * 100 : 0;
      _setCellValue(sheet, fila, 0, entry.key);
      _setCellValue(sheet, fila, 1, entry.value.toString());
      _setCellValue(sheet, fila, 2, '${porcentaje.toStringAsFixed(1)}%');
      _aplicarEstiloFila(sheet, fila, 0, 3, fila % 2 == 0 ? '#F2F2F2' : '#FFFFFF');
      fila++;
    }
  }

  return fila;
}

/// Crea sección consolidada de uso y topografía
int _crearSeccionUsoTopografiaCompleto(
  Sheet sheet,
  Map<String, dynamic> datos,
  int filaInicial,
) {
  int fila = filaInicial;

  // Título de sección
  _setCellValue(sheet, fila, 0, '2. USO DE VIVIENDA Y CARACTERÍSTICAS TOPOGRÁFICAS');
  _aplicarEstiloSeccion(sheet, fila, 0);
  fila++;

  if (!datos.containsKey('usoTopografia')) {
    _setCellValue(sheet, fila, 0, 'Datos de uso y topografía no disponibles');
    return fila + 1;
  }

  // Top 3 usos más comunes
  if (datos['usoTopografia']['usosVivienda']?['estadisticas'] != null) {
    _setCellValue(sheet, fila, 0, 'TOP 3 USOS MÁS FRECUENTES');
    _aplicarEstilo(sheet, fila, 0, bold: true, backgroundColor: '#E2EFDA');
    fila++;

    final usos = Map<String, dynamic>.from(datos['usoTopografia']['usosVivienda']['estadisticas']);
    var usosOrdenados = usos.entries
        .where((e) => e.value['conteo'] > 0)
        .toList()
      ..sort((a, b) => b.value['conteo'].compareTo(a.value['conteo']));

    for (int i = 0; i < 3 && i < usosOrdenados.length; i++) {
      var entry = usosOrdenados[i];
      _setCellValue(sheet, fila, 0, '${i + 1}. ${entry.key}');
      _setCellValue(sheet, fila, 1, '${entry.value['conteo']} inmuebles');
      _aplicarEstiloFila(sheet, fila, 0, 2, '#F9F9F9');
      fila++;
    }
  }

  fila++; // Espaciado

  // Top 3 topografías más comunes
  if (datos['usoTopografia']['topografia']?['estadisticas'] != null) {
    _setCellValue(sheet, fila, 0, 'TOP 3 TOPOGRAFÍAS MÁS FRECUENTES');
    _aplicarEstilo(sheet, fila, 0, bold: true, backgroundColor: '#E2EFDA');
    fila++;

    final topografia = Map<String, dynamic>.from(datos['usoTopografia']['topografia']['estadisticas']);
    var topoOrdenada = topografia.entries
        .where((e) => e.value['conteo'] > 0)
        .toList()
      ..sort((a, b) => b.value['conteo'].compareTo(a.value['conteo']));

    for (int i = 0; i < 3 && i < topoOrdenada.length; i++) {
      var entry = topoOrdenada[i];
      _setCellValue(sheet, fila, 0, '${i + 1}. ${entry.key}');
      _setCellValue(sheet, fila, 1, '${entry.value['conteo']} inmuebles');
      _aplicarEstiloFila(sheet, fila, 0, 2, '#F9F9F9');
      fila++;
    }
  }

  return fila;
}

/// Crea sección consolidada de material dominante
int _crearSeccionMaterialDominanteCompleto(
  Sheet sheet,
  Map<String, dynamic> datos,
  int filaInicial,
) {
  int fila = filaInicial;

  // Título de sección
  _setCellValue(sheet, fila, 0, '3. MATERIALES DOMINANTES DE CONSTRUCCIÓN');
  _aplicarEstiloSeccion(sheet, fila, 0);
  fila++;

  if (!datos.containsKey('materialDominante')) {
    _setCellValue(sheet, fila, 0, 'Datos de material dominante no disponibles');
    return fila + 1;
  }

  // Distribución de materiales
  final materiales = Map<String, int>.from(datos['materialDominante']['conteoMateriales'] ?? {});
  if (materiales.isNotEmpty) {
    _setCellValue(sheet, fila, 0, 'DISTRIBUCIÓN DE MATERIALES CONSTRUCTIVOS');
    _aplicarEstilo(sheet, fila, 0, bold: true, backgroundColor: '#E2EFDA');
    fila++;

    // Encabezados
    _setCellValue(sheet, fila, 0, 'Material');
    _setCellValue(sheet, fila, 1, 'Cantidad');
    _setCellValue(sheet, fila, 2, 'Resistencia');
    _aplicarEstiloTablaHeader(sheet, fila, 0, 3, '#C6E0B4');
    fila++;

    // Clasificación de resistencia
    Map<String, String> resistenciaMateriales = {
      'Concreto': 'Alta',
      'Ladrillo': 'Media-Alta',
      'Adobe': 'Baja',
      'Madera/Lámina/Otros': 'Variable',
      'No determinado': 'Desconocida',
    };

    var materialesOrdenados = materiales.entries
        .where((e) => e.value > 0)
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    for (var entry in materialesOrdenados) {
      String resistencia = resistenciaMateriales[entry.key] ?? 'No especificada';
      _setCellValue(sheet, fila, 0, entry.key);
      _setCellValue(sheet, fila, 1, entry.value.toString());
      _setCellValue(sheet, fila, 2, resistencia);
      
      String bgColor = '#FFFFFF';
      if (resistencia == 'Alta') bgColor = '#E8F5E8';
      else if (resistencia == 'Baja') bgColor = '#FFE8E8';
      else if (resistencia == 'Desconocida') bgColor = '#FFF2CC';
      
      _aplicarEstiloFila(sheet, fila, 0, 3, bgColor);
      fila++;
    }
  }

  return fila;
}

/// Crea sección consolidada de sistema estructural
int _crearSeccionSistemaEstructuralCompleto(
  Sheet sheet,
  Map<String, dynamic> datos,
  int filaInicial,
) {
  int fila = filaInicial;

  // Título de sección
  _setCellValue(sheet, fila, 0, '4. SISTEMAS ESTRUCTURALES PREDOMINANTES');
  _aplicarEstiloSeccion(sheet, fila, 0);
  fila++;

  if (!datos.containsKey('sistemaEstructural')) {
    _setCellValue(sheet, fila, 0, 'Datos de sistema estructural no disponibles');
    return fila + 1;
  }

  // Elementos más comunes por categoría (top 2 de cada una)
  final categorias = ['direccionX', 'direccionY', 'murosMamposteria', 'cimentacion'];
  final nombresCategoria = ['Dirección X', 'Dirección Y', 'Muros Mampostería', 'Cimentación'];

  for (int catIndex = 0; catIndex < categorias.length; catIndex++) {
    String categoria = categorias[catIndex];
    String nombreCategoria = nombresCategoria[catIndex];

    if (datos['sistemaEstructural']['estadisticas']?[categoria] != null) {
      _setCellValue(sheet, fila, 0, 'TOP 2 EN $nombreCategoria');
      _aplicarEstilo(sheet, fila, 0, bold: true, backgroundColor: '#F4B183');
      fila++;

      final elementos = Map<String, dynamic>.from(datos['sistemaEstructural']['estadisticas'][categoria]);
      var elementosOrdenados = elementos.entries
          .where((e) => e.value['conteo'] > 0)
          .toList()
        ..sort((a, b) => b.value['conteo'].compareTo(a.value['conteo']));

      for (int i = 0; i < 2 && i < elementosOrdenados.length; i++) {
        var entry = elementosOrdenados[i];
        _setCellValue(sheet, fila, 0, '${i + 1}. ${entry.key}');
        _setCellValue(sheet, fila, 1, '${entry.value['conteo']} casos');
        _aplicarEstiloFila(sheet, fila, 0, 2, '#FFF2E6');
        fila++;
      }

      fila++; // Espaciado entre categorías
    }
  }

  return fila;
}

/// Crea sección consolidada de evaluación de daños
int _crearSeccionEvaluacionDanosCompleto(
  Sheet sheet,
  Map<String, dynamic> datos,
  int filaInicial,
) {
  int fila = filaInicial;

  // Título de sección
  _setCellValue(sheet, fila, 0, '5. EVALUACIÓN DE DAÑOS Y ANÁLISIS DE RIESGOS');
  _aplicarEstiloSeccion(sheet, fila, 0);
  fila++;

  if (!datos.containsKey('evaluacionDanos')) {
    _setCellValue(sheet, fila, 0, 'Datos de evaluación de daños no disponibles');
    return fila + 1;
  }

  // Resumen de riesgos
  if (datos['evaluacionDanos']['resumenRiesgos'] != null) {
    _setCellValue(sheet, fila, 0, 'DISTRIBUCIÓN DE NIVELES DE RIESGO');
    _aplicarEstilo(sheet, fila, 0, bold: true, backgroundColor: '#E2EFDA');
    fila++;

    final riesgos = datos['evaluacionDanos']['resumenRiesgos'];
    
    // Encabezados
    _setCellValue(sheet, fila, 0, 'Nivel de Riesgo');
    _setCellValue(sheet, fila, 1, 'Cantidad');
    _setCellValue(sheet, fila, 2, 'Urgencia');
    _aplicarEstiloTablaHeader(sheet, fila, 0, 3, '#F4CCCC');
    fila++;

    // Datos de riesgo
    final List<List<dynamic>> datosRiesgo = [
      ['Riesgo Alto', riesgos['riesgoAlto'] ?? 0, 'Intervención inmediata', '#FFE8E8'],
      ['Riesgo Medio', riesgos['riesgoMedio'] ?? 0, 'Refuerzo a mediano plazo', '#FFF2CC'],
      ['Riesgo Bajo', riesgos['riesgoBajo'] ?? 0, 'Monitoreo preventivo', '#E8F5E8'],
    ];

    for (var riesgo in datosRiesgo) {
      _setCellValue(sheet, fila, 0, riesgo[0].toString());
      _setCellValue(sheet, fila, 1, riesgo[1].toString());
      _setCellValue(sheet, fila, 2, riesgo[2].toString());
      _aplicarEstiloFila(sheet, fila, 0, 3, riesgo[3].toString());
      fila++;
    }
  }

  fila++; // Espaciado

  // Nivel de daño más crítico
  if (datos['evaluacionDanos']['estadisticas']?['nivelDano'] != null) {
    _setCellValue(sheet, fila, 0, 'CASOS CRÍTICOS IDENTIFICADOS');
    _aplicarEstilo(sheet, fila, 0, bold: true, backgroundColor: '#FFE2CC');
    fila++;

    final nivelesDano = Map<String, dynamic>.from(datos['evaluacionDanos']['estadisticas']['nivelDano']);
    int colapsoTotal = nivelesDano['Colapso total']?['conteo'] ?? 0;
    int danoSevero = nivelesDano['Daño severo']?['conteo'] ?? 0;
    
    if (colapsoTotal > 0 || danoSevero > 0) {
      _setCellValue(sheet, fila, 0, '⚠️ Colapso total: $colapsoTotal inmuebles');
      _aplicarEstiloFila(sheet, fila, 0, 1, '#FFE8E8');
      fila++;
      _setCellValue(sheet, fila, 0, '⚠️ Daño severo: $danoSevero inmuebles');
      _aplicarEstiloFila(sheet, fila, 0, 1, '#FFE8E8');
      fila++;
    } else {
      _setCellValue(sheet, fila, 0, '✅ No se detectaron casos críticos');
      _aplicarEstiloFila(sheet, fila, 0, 1, '#E8F5E8');
      fila++;
    }
  }

  return fila;
}

/// Crea conclusiones y recomendaciones integrales finales
void _crearConclusionesIntegralesCompletas(
  Sheet sheet,
  Map<String, dynamic> datos,
  Map<String, dynamic> metadatos,
  int filaInicial,
) {
  int fila = filaInicial;

  // Título de sección
  _setCellValue(sheet, fila, 0, 'CONCLUSIONES Y RECOMENDACIONES INTEGRALES');
  _aplicarEstiloSeccion(sheet, fila, 0);
  fila++;

  // Análisis integral de prioridades
  _setCellValue(sheet, fila, 0, 'MATRIZ DE PRIORIDADES INTEGRALES');
  _aplicarEstilo(sheet, fila, 0, bold: true, backgroundColor: '#D9E2F3');
  fila++;

  // Calcular prioridades basadas en todos los datos
  int inmueblesCriticos = 0;
  int inmueblesVulnerables = 0;
  int inmueblesSeguros = 0;

  // De evaluación de daños
  if (datos['evaluacionDanos']?['resumenRiesgos'] != null) {
    final riesgos = datos['evaluacionDanos']['resumenRiesgos'];
    inmueblesCriticos = (riesgos['riesgoAlto'] ?? 0);
    inmueblesVulnerables = (riesgos['riesgoMedio'] ?? 0);
    inmueblesSeguros = (riesgos['riesgoBajo'] ?? 0);
  }

  // De material dominante
  int materialesVulnerables = 0;
  if (datos['materialDominante']?['conteoMateriales'] != null) {
    final materiales = Map<String, int>.from(datos['materialDominante']['conteoMateriales']);
    materialesVulnerables = (materiales['Adobe'] ?? 0) + (materiales['Madera/Lámina/Otros'] ?? 0);
  }

  final int totalFormatos = metadatos['totalFormatos'] ?? 0;

  // Recomendaciones por prioridad
  final List<List<String>> recomendaciones = [
    ['PRIORIDAD CRÍTICA', '$inmueblesCriticos inmuebles', 'Evacuación y refuerzo inmediato'],
    ['PRIORIDAD ALTA', '$materialesVulnerables inmuebles', 'Programa de refuerzo estructural'],
    ['PRIORIDAD MEDIA', '$inmueblesVulnerables inmuebles', 'Monitoreo y mejoras graduales'],
    ['MANTENIMIENTO', '$inmueblesSeguros inmuebles', 'Mantenimiento preventivo'],
  ];

  // Encabezados
  _setCellValue(sheet, fila, 0, 'Nivel de Prioridad');
  _setCellValue(sheet, fila, 1, 'Afectados');
  _setCellValue(sheet, fila, 2, 'Acción Recomendada');
  _aplicarEstiloTablaHeader(sheet, fila, 0, 3, '#B4C6E7');
  fila++;

  // Escribir recomendaciones con colores por prioridad
  final List<String> coloresPrioridad = ['#FFE8E8', '#FFF2CC', '#FFF2E6', '#E8F5E8'];
  
  for (int i = 0; i < recomendaciones.length; i++) {
    var recomendacion = recomendaciones[i];
    _setCellValue(sheet, fila, 0, recomendacion[0]);
    _setCellValue(sheet, fila, 1, recomendacion[1]);
    _setCellValue(sheet, fila, 2, recomendacion[2]);
    _aplicarEstiloFila(sheet, fila, 0, 3, coloresPrioridad[i]);
    fila++;
  }

  fila += 2; // Espaciado

  // Conclusión ejecutiva final
  _setCellValue(sheet, fila, 0, 'CONCLUSIÓN EJECUTIVA INTEGRAL');
  _aplicarEstilo(sheet, fila, 0, bold: true, backgroundColor: '#E7E6E6');
  fila++;

  // Generar conclusión basada en todos los datos
  String conclusion = _generarConclusionIntegral(datos, metadatos, inmueblesCriticos, materialesVulnerables, totalFormatos);
  
  _setCellValue(sheet, fila, 0, conclusion);
  _aplicarEstilo(sheet, fila, 0, backgroundColor: '#F9F9F9');
  fila++;

  fila++; // Espaciado final

  // Firma y validación
  _setCellValue(sheet, fila, 0, 'Reporte generado automáticamente por CENApp - Sistema de Evaluación Estructural');
  _aplicarEstilo(sheet, fila, 0, backgroundColor: '#E7E6E6');
  _setCellValue(sheet, fila, 1, DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now()));
  _aplicarEstilo(sheet, fila, 1, backgroundColor: '#E7E6E6');
}

/// Genera conclusión integral basada en todos los módulos analizados
String _generarConclusionIntegral(
  Map<String, dynamic> datos, 
  Map<String, dynamic> metadatos,
  int inmueblesCriticos,
  int materialesVulnerables,
  int totalFormatos,
) {
  StringBuffer conclusion = StringBuffer();
  
  conclusion.write('Análisis integral de $totalFormatos inmuebles completado. ');
  
  // Evaluación general de riesgo
  double porcentajeCritico = totalFormatos > 0 ? (inmueblesCriticos / totalFormatos) * 100 : 0;
  double porcentajeVulnerable = totalFormatos > 0 ? (materialesVulnerables / totalFormatos) * 100 : 0;
  
  if (porcentajeCritico > 10) {
    conclusion.write('ALERTA: ${porcentajeCritico.toStringAsFixed(1)}% de inmuebles en riesgo crítico requieren intervención inmediata. ');
  } else if (porcentajeCritico > 0) {
    conclusion.write('Se identificaron $inmueblesCriticos inmuebles en riesgo crítico que requieren atención prioritaria. ');
  } else {
    conclusion.write('Situación general estable sin casos críticos identificados. ');
  }
  
  if (porcentajeVulnerable > 30) {
    conclusion.write('El ${porcentajeVulnerable.toStringAsFixed(1)}% de inmuebles presenta materiales vulnerables que requieren programa de refuerzo. ');
  }
  
  // Material predominante
  if (datos['materialDominante']?['conteoMateriales'] != null) {
    final materiales = Map<String, int>.from(datos['materialDominante']['conteoMateriales']);
    if (materiales.isNotEmpty) {
      final materialPrincipal = materiales.entries
          .where((e) => e.value > 0)
          .fold<MapEntry<String, int>?>(null, (prev, curr) => prev == null || curr.value > prev.value ? curr : prev);
      if (materialPrincipal != null) {
        conclusion.write('Material predominante: ${materialPrincipal.key}. ');
      }
    }
  }
  
  conclusion.write('Se recomienda implementar las acciones prioritarias identificadas para optimizar la seguridad estructural regional.');
  
  return conclusion.toString();
}




  Future<String> generarReporteEvaluacionDanosExcel({
  required String titulo,
  required String subtitulo,
  required Map<String, dynamic> datos,
  required List<Map<String, dynamic>> tablas,
  required Map<String, dynamic> metadatos,
  Directory? directorio,
}) async {
  try {
    print('📊 [EXCEL-DAÑOS] Iniciando generación de reporte Excel: $titulo');

    // Crear nuevo libro de Excel usando la librería excel
    var excel = Excel.createExcel();
    
    // Eliminar hoja por defecto
    excel.delete('Sheet1');
    
    // Crear hoja única con todo el contenido
    String nombreHoja = 'Evaluación de Daños';
    excel.copy('Sheet1', nombreHoja);
    excel.delete('Sheet1');
    
    Sheet sheet = excel[nombreHoja];
    
    // Crear contenido completo en una sola hoja
    await _crearContenidoEvaluacionDanosCompleto(sheet, titulo, subtitulo, datos, tablas, metadatos);

    // Guardar archivo
    final String rutaArchivo = await _guardarArchivoExcelEstandar(
      excel, 
      titulo, 
      directorio
    );
    
    print('✅ [EXCEL-DAÑOS] Reporte Excel generado exitosamente: $rutaArchivo');
    return rutaArchivo;

  } catch (e) {
    print('❌ [EXCEL-DAÑOS] Error al generar reporte Excel: $e');
    throw Exception('Error al generar reporte Excel de evaluación de daños: $e');
  }
}

/// Crea todo el contenido del reporte de evaluación de daños en una sola hoja
Future<void> _crearContenidoEvaluacionDanosCompleto(
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

  // === SECCIÓN 3: RESUMEN DE RIESGOS ===
  filaActual = _crearResumenRiesgosGenerales(sheet, datos, metadatos, filaActual);
  filaActual += 2;

  // === SECCIÓN 4: ANÁLISIS GEOTÉCNICO ===
  filaActual = _crearAnalisisGeotecnico(sheet, datos, filaActual);
  filaActual += 2;

  // === SECCIÓN 5: EVALUACIÓN DE SISTEMAS ESTRUCTURALES ===
  filaActual = _crearEvaluacionSistemasEstructurales(sheet, datos, filaActual);
  filaActual += 2;

  // === SECCIÓN 6: CLASIFICACIÓN POR NIVEL DE DAÑO ===
  filaActual = _crearClasificacionNivelDano(sheet, datos, filaActual);
  filaActual += 2;

  // === SECCIÓN 7: RECOMENDACIONES DE INTERVENCIÓN ===
  _crearRecomendacionesIntervencion(sheet, datos, metadatos, filaActual);
}

/// Crea resumen de riesgos generales
int _crearResumenRiesgosGenerales(
  Sheet sheet,
  Map<String, dynamic> datos,
  Map<String, dynamic> metadatos,
  int filaInicial,
) {
  int fila = filaInicial;

  // Título de sección
  _setCellValue(sheet, fila, 0, 'RESUMEN DE RIESGOS GENERALES');
  _aplicarEstiloSeccion(sheet, fila, 0);
  fila++;

  final int totalFormatos = metadatos['totalFormatos'] ?? 0;

  // Extraer datos de resumen de riesgos
  Map<String, dynamic> resumenRiesgos = {};
  if (datos.containsKey('resumenRiesgos')) {
    resumenRiesgos = Map<String, dynamic>.from(datos['resumenRiesgos']);
  }

  int riesgoAlto = resumenRiesgos['riesgoAlto'] ?? 0;
  int riesgoMedio = resumenRiesgos['riesgoMedio'] ?? 0;
  int riesgoBajo = resumenRiesgos['riesgoBajo'] ?? 0;

  // Encabezados de tabla
  _setCellValue(sheet, fila, 0, 'Nivel de Riesgo');
  _setCellValue(sheet, fila, 1, 'Cantidad');
  _setCellValue(sheet, fila, 2, 'Porcentaje');
  _setCellValue(sheet, fila, 3, 'Prioridad de Intervención');
  _aplicarEstiloTablaHeader(sheet, fila, 0, 4, '#FF6B6B');
  fila++;

  // Calcular porcentajes
  double porcentajeAlto = totalFormatos > 0 ? (riesgoAlto / totalFormatos) * 100 : 0;
  double porcentajeMedio = totalFormatos > 0 ? (riesgoMedio / totalFormatos) * 100 : 0;
  double porcentajeBajo = totalFormatos > 0 ? (riesgoBajo / totalFormatos) * 100 : 0;

  // Datos de riesgos con colores específicos
  final List<List<dynamic>> datosRiesgos = [
    ['RIESGO ALTO', riesgoAlto, '${porcentajeAlto.toStringAsFixed(1)}%', 'INMEDIATA', '#FFE8E8'],
    ['RIESGO MEDIO', riesgoMedio, '${porcentajeMedio.toStringAsFixed(1)}%', 'URGENTE', '#FFF2CC'],
    ['RIESGO BAJO', riesgoBajo, '${porcentajeBajo.toStringAsFixed(1)}%', 'PROGRAMADA', '#E8F5E8'],
  ];

  for (var datosRiesgo in datosRiesgos) {
    _setCellValue(sheet, fila, 0, datosRiesgo[0]);
    _setCellValue(sheet, fila, 1, datosRiesgo[1].toString());
    _setCellValue(sheet, fila, 2, datosRiesgo[2]);
    _setCellValue(sheet, fila, 3, datosRiesgo[3]);
    
    _aplicarEstiloFila(sheet, fila, 0, 4, datosRiesgo[4]);
    fila++;
  }

  // Total
  _setCellValue(sheet, fila, 0, 'TOTAL EVALUADO');
  _setCellValue(sheet, fila, 1, totalFormatos.toString());
  _setCellValue(sheet, fila, 2, '100%');
  _setCellValue(sheet, fila, 3, 'Base de análisis');
  _aplicarEstiloTablaHeader(sheet, fila, 0, 4, '#D9E2F3');
  fila++;

  return fila;
}

/// Crea análisis geotécnico detallado
int _crearAnalisisGeotecnico(
  Sheet sheet,
  Map<String, dynamic> datos,
  int filaInicial,
) {
  int fila = filaInicial;

  // Título de sección
  _setCellValue(sheet, fila, 0, 'ANÁLISIS GEOTÉCNICO Y CIMENTACIÓN');
  _aplicarEstiloSeccion(sheet, fila, 0);
  fila++;

  // Verificar si hay datos geotécnicos
  if (!datos.containsKey('estadisticas') || 
      !datos['estadisticas'].containsKey('geotecnicos')) {
    _setCellValue(sheet, fila, 0, 'No hay datos geotécnicos disponibles');
    return fila + 1;
  }

  Map<String, dynamic> geotecnicos = datos['estadisticas']['geotecnicos'];

  // Encabezados
  _setCellValue(sheet, fila, 0, 'Problema Geotécnico');
  _setCellValue(sheet, fila, 1, 'Inmuebles Afectados');
  _setCellValue(sheet, fila, 2, 'Porcentaje');
  _setCellValue(sheet, fila, 3, 'Nivel de Gravedad');
  _setCellValue(sheet, fila, 4, 'Acción Recomendada');
  _aplicarEstiloTablaHeader(sheet, fila, 0, 5, '#8B4513');
  fila++;

  // Mapeo de gravedad y acciones
  Map<String, Map<String, String>> accionesGeotecnicas = {
    'Grietas en el terreno': {
      'gravedad': 'ALTA',
      'accion': 'Estudio geotécnico especializado'
    },
    'Hundimientos': {
      'gravedad': 'CRÍTICA',
      'accion': 'Evaluación estructural inmediata'
    },
    'Inclinación del edificio': {
      'gravedad': 'CRÍTICA',
      'accion': 'Evacuación y refuerzo urgente'
    },
  };

  // Procesar datos geotécnicos
  geotecnicos.forEach((problema, stats) {
    int conteo = stats['conteo'] ?? 0;
    double porcentaje = stats['porcentaje'] ?? 0;
    
    if (conteo > 0) {
      var info = accionesGeotecnicas[problema] ?? {
        'gravedad': 'MEDIA',
        'accion': 'Evaluación específica requerida'
      };

      _setCellValue(sheet, fila, 0, problema);
      _setCellValue(sheet, fila, 1, conteo.toString());
      _setCellValue(sheet, fila, 2, '${porcentaje.toStringAsFixed(1)}%');
      _setCellValue(sheet, fila, 3, info['gravedad']!);
      _setCellValue(sheet, fila, 4, info['accion']!);
      
      // Color según gravedad
      String bgColor = '#FFFFFF';
      if (info['gravedad'] == 'CRÍTICA') bgColor = '#FFE8E8';
      else if (info['gravedad'] == 'ALTA') bgColor = '#FFF2CC';
      else bgColor = fila % 2 == 0 ? '#F2F2F2' : '#FFFFFF';
      
      _aplicarEstiloFila(sheet, fila, 0, 5, bgColor);
      fila++;
    }
  });

  return fila;
}

/// Crea evaluación de sistemas estructurales
int _crearEvaluacionSistemasEstructurales(
  Sheet sheet,
  Map<String, dynamic> datos,
  int filaInicial,
) {
  int fila = filaInicial;

  // Título de sección
  _setCellValue(sheet, fila, 0, 'EVALUACIÓN DE SISTEMAS ESTRUCTURALES');
  _aplicarEstiloSeccion(sheet, fila, 0);
  fila++;

  // Categorías a evaluar
  final List<Map<String, String>> categorias = [
    {'id': 'sistemaEstructuralDeficiente', 'titulo': 'Calidad Estructural'},
    {'id': 'techoPesado', 'titulo': 'Sistema de Techo'},
    {'id': 'murosDelgados', 'titulo': 'Refuerzo en Muros'},
    {'id': 'irregularidadPlanta', 'titulo': 'Geometría en Planta'},
    {'id': 'losas', 'titulo': 'Condición de Losas'},
  ];

  // Encabezados
  _setCellValue(sheet, fila, 0, 'Sistema Evaluado');
  _setCellValue(sheet, fila, 1, 'Condición Principal');
  _setCellValue(sheet, fila, 2, 'Cantidad');
  _setCellValue(sheet, fila, 3, 'Porcentaje');
  _setCellValue(sheet, fila, 4, 'Recomendación');
  _aplicarEstiloTablaHeader(sheet, fila, 0, 5, '#4472C4');
  fila++;

  // Procesar cada categoría
  for (var categoria in categorias) {
    String id = categoria['id']!;
    String titulo = categoria['titulo']!;
    
    if (datos['estadisticas'].containsKey(id)) {
      Map<String, dynamic> estadisticasCategoria = datos['estadisticas'][id];
      
      // Encontrar la condición predominante
      String condicionPrincipal = 'No determinada';
      int maxConteo = 0;
      double maxPorcentaje = 0;
      
      estadisticasCategoria.forEach((condicion, stats) {
        int conteo = stats['conteo'] ?? 0;
        if (conteo > maxConteo) {
          maxConteo = conteo;
          maxPorcentaje = stats['porcentaje'] ?? 0;
          condicionPrincipal = condicion;
        }
      });
      
      // Generar recomendación
      String recomendacion = _generarRecomendacionSistema(id, condicionPrincipal);
      
      _setCellValue(sheet, fila, 0, titulo);
      _setCellValue(sheet, fila, 1, condicionPrincipal);
      _setCellValue(sheet, fila, 2, maxConteo.toString());
      _setCellValue(sheet, fila, 3, '${maxPorcentaje.toStringAsFixed(1)}%');
      _setCellValue(sheet, fila, 4, recomendacion);
      
      // Color según riesgo implícito
      String bgColor = _obtenerColorRiesgoSistema(id, condicionPrincipal);
      _aplicarEstiloFila(sheet, fila, 0, 5, bgColor);
      fila++;
    }
  }

  return fila;
}

/// Crea clasificación por nivel de daño
int _crearClasificacionNivelDano(
  Sheet sheet,
  Map<String, dynamic> datos,
  int filaInicial,
) {
  int fila = filaInicial;

  // Título de sección
  _setCellValue(sheet, fila, 0, 'CLASIFICACIÓN POR NIVEL DE DAÑO');
  _aplicarEstiloSeccion(sheet, fila, 0);
  fila++;

  // Verificar datos de nivel de daño
  if (!datos['estadisticas'].containsKey('nivelDano')) {
    _setCellValue(sheet, fila, 0, 'No hay datos de clasificación de daños');
    return fila + 1;
  }

  Map<String, dynamic> nivelDano = datos['estadisticas']['nivelDano'];

  // Encabezados
  _setCellValue(sheet, fila, 0, 'Nivel de Daño');
  _setCellValue(sheet, fila, 1, 'Inmuebles');
  _setCellValue(sheet, fila, 2, 'Porcentaje');
  _setCellValue(sheet, fila, 3, 'Tiempo de Respuesta');
  _setCellValue(sheet, fila, 4, 'Acciones Prioritarias');
  _aplicarEstiloTablaHeader(sheet, fila, 0, 5, '#C5504B');
  fila++;

  // Ordenar por gravedad (de mayor a menor)
  final ordenGravedad = [
    'Colapso total',
    'Daño severo', 
    'Daño medio',
    'Daño ligero',
    'Sin daño aparente'
  ];

  // Mapeo de tiempos y acciones
  Map<String, Map<String, String>> accionesPorNivel = {
    'Colapso total': {
      'tiempo': 'INMEDIATO',
      'acciones': 'Evacuación, demolición controlada'
    },
    'Daño severo': {
      'tiempo': '24-48 HORAS',
      'acciones': 'Refuerzo urgente, apuntalamiento'
    },
    'Daño medio': {
      'tiempo': '1-2 SEMANAS',
      'acciones': 'Reparación estructural programada'
    },
    'Daño ligero': {
      'tiempo': '1-3 MESES',
      'acciones': 'Mantenimiento preventivo'
    },
    'Sin daño aparente': {
      'tiempo': 'MONITOREO',
      'acciones': 'Inspección periódica'
    },
  };

  for (String nivel in ordenGravedad) {
    if (nivelDano.containsKey(nivel)) {
      int conteo = nivelDano[nivel]['conteo'] ?? 0;
      double porcentaje = nivelDano[nivel]['porcentaje'] ?? 0;
      
      if (conteo > 0) {
        var info = accionesPorNivel[nivel]!;
        
        _setCellValue(sheet, fila, 0, nivel.toUpperCase());
        _setCellValue(sheet, fila, 1, conteo.toString());
        _setCellValue(sheet, fila, 2, '${porcentaje.toStringAsFixed(1)}%');
        _setCellValue(sheet, fila, 3, info['tiempo']!);
        _setCellValue(sheet, fila, 4, info['acciones']!);
        
        // Color según severidad
        String bgColor = _obtenerColorNivelDano(nivel);
        _aplicarEstiloFila(sheet, fila, 0, 5, bgColor);
        fila++;
      }
    }
  }

  return fila;
}

/// Crea recomendaciones de intervención
void _crearRecomendacionesIntervencion(
  Sheet sheet,
  Map<String, dynamic> datos,
  Map<String, dynamic> metadatos,
  int filaInicial,
) {
  int fila = filaInicial;

  // Título de sección
  _setCellValue(sheet, fila, 0, 'RECOMENDACIONES DE INTERVENCIÓN');
  _aplicarEstiloSeccion(sheet, fila, 0);
  fila++;

  // Análisis de prioridades
  Map<String, dynamic> resumenRiesgos = datos['resumenRiesgos'] ?? {};
  int riesgoAlto = resumenRiesgos['riesgoAlto'] ?? 0;
  int riesgoMedio = resumenRiesgos['riesgoMedio'] ?? 0;
  final int totalFormatos = metadatos['totalFormatos'] ?? 0;

  _setCellValue(sheet, fila, 0, 'PLAN DE ACCIÓN PRIORITARIO:');
  _aplicarEstilo(sheet, fila, 0, bold: true, backgroundColor: '#E74C3C');
  fila++;

  // Recomendaciones específicas basadas en datos
  List<String> recomendaciones = [];

  if (riesgoAlto > 0) {
    double porcentajeAlto = (riesgoAlto / totalFormatos) * 100;
    recomendaciones.add('• PRIORIDAD 1: Intervención inmediata en $riesgoAlto inmuebles de riesgo alto (${porcentajeAlto.toStringAsFixed(1)}%)');
  }

  if (riesgoMedio > 0) {
    double porcentajeMedio = (riesgoMedio / totalFormatos) * 100;
    recomendaciones.add('• PRIORIDAD 2: Programar refuerzo en $riesgoMedio inmuebles de riesgo medio (${porcentajeMedio.toStringAsFixed(1)}%)');
  }

  // Verificar problemas geotécnicos
  if (datos['estadisticas'].containsKey('geotecnicos')) {
    Map<String, dynamic> geotecnicos = datos['estadisticas']['geotecnicos'];
    int problemasGeo = 0;
    geotecnicos.forEach((problema, stats) {
      problemasGeo += stats['conteo'] as int? ?? 0;
    });
    
    if (problemasGeo > 0) {
      recomendaciones.add('• Realizar estudios geotécnicos especializados para $problemasGeo casos identificados');
    }
  }

  recomendaciones.addAll([
    '• Establecer sistema de monitoreo continuo para inmuebles en riesgo',
    '• Capacitar equipos de respuesta para emergencias estructurales',
    '• Desarrollar protocolos de evacuación específicos por nivel de daño',
    '• Implementar inspecciones periódicas programadas',
  ]);

  // Escribir recomendaciones
  for (String recomendacion in recomendaciones) {
    _setCellValue(sheet, fila, 0, recomendacion);
    _aplicarEstilo(sheet, fila, 0, backgroundColor: '#F8F9FA');
    fila++;
  }

  fila++;

  // Conclusión final
  String conclusion = metadatos['conclusiones'] ?? 
      'Análisis completado. Se requiere acción inmediata en inmuebles de alto riesgo y seguimiento programado para el resto.';

  _setCellValue(sheet, fila, 0, 'CONCLUSIÓN:');
  _aplicarEstilo(sheet, fila, 0, bold: true, backgroundColor: '#3498DB');
  fila++;

  _setCellValue(sheet, fila, 0, conclusion);
  _aplicarEstilo(sheet, fila, 0, backgroundColor: '#EBF3FD');
}

// === MÉTODOS AUXILIARES ESPECÍFICOS ===

/// Genera recomendación específica para cada sistema
String _generarRecomendacionSistema(String idSistema, String condicion) {
  Map<String, Map<String, String>> recomendaciones = {
    'sistemaEstructuralDeficiente': {
      'Sistema deficiente': 'Refuerzo estructural urgente',
      'Sistema adecuado': 'Mantenimiento preventivo regular'
    },
    'techoPesado': {
      'Techo pesado': 'Evaluar carga estructural y reforzar',
      'Techo ligero': 'Verificar anclajes y conectores'
    },
    'murosDelgados': {
      'Muros sin refuerzo': 'Instalar refuerzo sísmico',
      'Muros reforzados': 'Inspección de refuerzos existentes'
    },
    'irregularidadPlanta': {
      'Geometría irregular': 'Análisis sísmico especializado',
      'Geometría regular': 'Monitoreo estándar'
    },
    'losas': {
      'Colapso': 'Reparación o reemplazo inmediato',
      'Grietas máximas': 'Sellado y monitoreo de grietas',
      'Flecha máxima': 'Evaluación de capacidad de carga'
    }
  };

  return recomendaciones[idSistema]?[condicion] ?? 'Evaluación técnica especializada';
}

/// Obtiene color según riesgo del sistema
String _obtenerColorRiesgoSistema(String idSistema, String condicion) {
  // Condiciones de alto riesgo
  List<String> altoRiesgo = [
    'Sistema deficiente', 'Techo pesado', 'Muros sin refuerzo', 
    'Geometría irregular', 'Colapso'
  ];
  
  if (altoRiesgo.contains(condicion)) return '#FFE8E8';
  return '#E8F5E8';
}

/// Obtiene color según nivel de daño
String _obtenerColorNivelDano(String nivel) {
  switch (nivel) {
    case 'Colapso total': return '#FF6B6B';
    case 'Daño severo': return '#FF9F43';
    case 'Daño medio': return '#FFA502';
    case 'Daño ligero': return '#7BED9F';
    case 'Sin daño aparente': return '#70A1FF';
    default: return '#FFFFFF';
  }
}


  /// Genera un reporte completo de Sistema Estructural en Excel
/// Incluye análisis detallado de elementos estructurales por categoría
Future<String> generarReporteSistemaEstructuralExcel({
  required String titulo,
  required String subtitulo,
  required Map<String, dynamic> datos,
  required List<Map<String, dynamic>> tablas,
  required Map<String, dynamic> metadatos,
  Directory? directorio,
}) async {
  try {
    print('📊 [EXCEL-SISTEMA] Iniciando generación de reporte Excel: $titulo');

    // Crear nuevo libro de Excel usando la librería excel
    var excel = Excel.createExcel();
    
    // Eliminar hoja por defecto
    excel.delete('Sheet1');
    
    // Crear hoja única con todo el contenido
    String nombreHoja = 'Sistema Estructural';
    excel.copy('Sheet1', nombreHoja);
    excel.delete('Sheet1');
    
    Sheet sheet = excel[nombreHoja];
    
    // Crear contenido completo en una sola hoja
    await _crearContenidoSistemaEstructuralCompleto(sheet, titulo, subtitulo, datos, tablas, metadatos);

    // Guardar archivo
    final String rutaArchivo = await _guardarArchivoExcelEstandar(
      excel, 
      titulo, 
      directorio
    );
    
    print('✅ [EXCEL-SISTEMA] Reporte Excel generado exitosamente: $rutaArchivo');
    return rutaArchivo;

  } catch (e) {
    print('❌ [EXCEL-SISTEMA] Error al generar reporte Excel: $e');
    throw Exception('Error al generar reporte Excel de sistema estructural: $e');
  }
}

/// Crea todo el contenido del reporte de sistema estructural en una sola hoja
Future<void> _crearContenidoSistemaEstructuralCompleto(
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

  // === SECCIÓN 3: RESUMEN ESTADÍSTICO ===
  filaActual = _crearResumenEstadisticoSistemaEstructural(sheet, datos, metadatos, filaActual);
  filaActual += 2;

  // === SECCIÓN 4: ANÁLISIS POR CATEGORÍAS ESTRUCTURALES ===
  filaActual = _crearAnalisisCategorias(sheet, datos, filaActual);
  filaActual += 2;

  // === SECCIÓN 5: MATRIZ DE COMPATIBILIDAD ===
  filaActual = _crearMatrizCompatibilidad(sheet, datos, filaActual);
  filaActual += 2;

  // === SECCIÓN 6: EVALUACIÓN DE VULNERABILIDAD ===
  filaActual = _crearEvaluacionVulnerabilidad(sheet, datos, filaActual);
  filaActual += 2;

  // === SECCIÓN 7: RECOMENDACIONES TÉCNICAS ===
  _crearRecomendacionesTecnicasSistema(sheet, datos, metadatos, filaActual);
}

/// Crea resumen estadístico específico para sistema estructural
int _crearResumenEstadisticoSistemaEstructural(
  Sheet sheet,
  Map<String, dynamic> datos,
  Map<String, dynamic> metadatos,
  int filaInicial,
) {
  int fila = filaInicial;

  // Título de sección
  _setCellValue(sheet, fila, 0, 'RESUMEN ESTADÍSTICO SISTEMA ESTRUCTURAL');
  _aplicarEstiloSeccion(sheet, fila, 0);
  fila++;

  final int totalFormatos = metadatos['totalFormatos'] ?? 0;

  // Categorías del sistema estructural
  final List<String> categorias = [
    'direccionX', 'direccionY', 'murosMamposteria', 
    'sistemasPiso', 'sistemasTecho', 'cimentacion'
  ];

  // Calcular estadísticas por categoría
  int totalElementos = 0;
  int categoriasConDatos = 0;
  
  for (String categoria in categorias) {
    if (datos['estadisticas']?.containsKey(categoria) == true) {
      Map<String, dynamic> estadisticasCategoria = datos['estadisticas'][categoria];
      if (estadisticasCategoria.isNotEmpty) {
        categoriasConDatos++;
        totalElementos += estadisticasCategoria.values
            .map((e) => e['conteo'] as int? ?? 0)
            .fold(0, (sum, count) => sum + count);
      }
    }
  }

  // Encabezados de tabla
  _setCellValue(sheet, fila, 0, 'Concepto');
  _setCellValue(sheet, fila, 1, 'Valor');
  _setCellValue(sheet, fila, 2, 'Interpretación');
  _aplicarEstiloTablaHeader(sheet, fila, 0, 3, '#9BC2E6');
  fila++;

  // Estadísticas principales
  final List<List<String>> estadisticas = [
    ['Total inmuebles analizados', '$totalFormatos', '100% de la muestra'],
    ['Categorías con datos', '$categoriasConDatos', 'De 6 categorías principales'],
    ['Total elementos registrados', '$totalElementos', 'Suma de todos los elementos'],
    ['Promedio elementos/inmueble', 
     totalFormatos > 0 ? (totalElementos / totalFormatos).toStringAsFixed(1) : '0',
     'Diversidad estructural promedio'],
  ];

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

/// Crea análisis detallado por categorías estructurales
int _crearAnalisisCategorias(
  Sheet sheet,
  Map<String, dynamic> datos,
  int filaInicial,
) {
  int fila = filaInicial;

  // Título de sección
  _setCellValue(sheet, fila, 0, 'ANÁLISIS POR CATEGORÍAS ESTRUCTURALES');
  _aplicarEstiloSeccion(sheet, fila, 0);
  fila++;

  // Definir categorías con sus nombres legibles y colores
  final List<Map<String, dynamic>> categorias = [
    {'id': 'direccionX', 'nombre': 'Dirección X', 'color': '#E8F5E8'},
    {'id': 'direccionY', 'nombre': 'Dirección Y', 'color': '#E8F0FF'},
    {'id': 'murosMamposteria', 'nombre': 'Muros de Mampostería', 'color': '#FFF2CC'},
    {'id': 'sistemasPiso', 'nombre': 'Sistemas de Piso', 'color': '#FFE2CC'},
    {'id': 'sistemasTecho', 'nombre': 'Sistemas de Techo', 'color': '#F2E2FF'},
    {'id': 'cimentacion', 'nombre': 'Cimentación', 'color': '#E2F0D9'},
  ];

  for (var categoria in categorias) {
    String id = categoria['id'];
    String nombre = categoria['nombre'];
    String color = categoria['color'];

    // Verificar si hay datos para esta categoría
    if (!datos['estadisticas']?.containsKey(id) || 
        datos['estadisticas'][id].isEmpty) {
      continue;
    }

    Map<String, dynamic> estadisticasCategoria = datos['estadisticas'][id];

    // Subtítulo de categoría
    _setCellValue(sheet, fila, 0, nombre.toUpperCase());
    _aplicarEstilo(sheet, fila, 0, bold: true, backgroundColor: color);
    fila++;

    // Encabezados específicos
    _setCellValue(sheet, fila, 0, 'Elemento Estructural');
    _setCellValue(sheet, fila, 1, 'Cantidad');
    _setCellValue(sheet, fila, 2, 'Porcentaje');
    _setCellValue(sheet, fila, 3, 'Clasificación');
    _aplicarEstiloTablaHeader(sheet, fila, 0, 4, '#D9E2F3');
    fila++;

    // Ordenar elementos por cantidad
    var elementosOrdenados = estadisticasCategoria.entries
        .where((entry) => entry.value['conteo'] > 0)
        .toList()
      ..sort((a, b) => b.value['conteo'].compareTo(a.value['conteo']));

    int totalCategoria = elementosOrdenados.fold(0, (sum, entry) => sum + entry.value['conteo'] as int);

    // Mostrar elementos
    for (int i = 0; i < elementosOrdenados.length; i++) {
      var entry = elementosOrdenados[i];
      String elemento = entry.key;
      int conteo = entry.value['conteo'];
      double porcentaje = totalCategoria > 0 ? (conteo / totalCategoria) * 100 : 0;
      
      String clasificacion = '';
      if (i == 0) clasificacion = 'Predominante';
      else if (porcentaje > 20) clasificacion = 'Significativo';
      else if (porcentaje > 10) clasificacion = 'Moderado';
      else clasificacion = 'Menor';

      _setCellValue(sheet, fila, 0, elemento);
      _setCellValue(sheet, fila, 1, conteo.toString());
      _setCellValue(sheet, fila, 2, '${porcentaje.toStringAsFixed(1)}%');
      _setCellValue(sheet, fila, 3, clasificacion);
      
      // Alternar colores
      String bgColor = fila % 2 == 0 ? '#F9F9F9' : '#FFFFFF';
      _aplicarEstiloFila(sheet, fila, 0, 4, bgColor);
      fila++;
    }

    // Línea de separación
    fila++;
  }

  return fila;
}

/// Crea matriz de compatibilidad entre sistemas
int _crearMatrizCompatibilidad(
  Sheet sheet,
  Map<String, dynamic> datos,
  int filaInicial,
) {
  int fila = filaInicial;

  // Título de sección
  _setCellValue(sheet, fila, 0, 'MATRIZ DE COMPATIBILIDAD DE SISTEMAS');
  _aplicarEstiloSeccion(sheet, fila, 0);
  fila++;

  // Descripción
  _setCellValue(sheet, fila, 0, 'Análisis de combinaciones estructurales más frecuentes');
  _aplicarEstilo(sheet, fila, 0, backgroundColor: '#F0F8FF');
  fila++;
  fila++;

  // Obtener elementos predominantes de cada categoría
  Map<String, String> elementosPredominantes = {};
  
  final List<String> categoriasClave = ['direccionX', 'direccionY', 'cimentacion'];
  
  for (String categoria in categoriasClave) {
    if (datos['estadisticas']?.containsKey(categoria)) {
      Map<String, dynamic> estadisticas = datos['estadisticas'][categoria];
      if (estadisticas.isNotEmpty) {
        var predominante = estadisticas.entries
            .where((e) => e.value['conteo'] > 0)
            .reduce((a, b) => a.value['conteo'] > b.value['conteo'] ? a : b);
        elementosPredominantes[categoria] = predominante.key;
      }
    }
  }

  // Encabezados
  _setCellValue(sheet, fila, 0, 'Sistema');
  _setCellValue(sheet, fila, 1, 'Elemento Predominante');
  _setCellValue(sheet, fila, 2, 'Compatibilidad');
  _setCellValue(sheet, fila, 3, 'Recomendación');
  _aplicarEstiloTablaHeader(sheet, fila, 0, 4, '#C6E0B4');
  fila++;

  // Análisis de compatibilidad
  final Map<String, String> nombresCategoria = {
    'direccionX': 'Dirección X',
    'direccionY': 'Dirección Y',
    'cimentacion': 'Cimentación',
  };

  elementosPredominantes.forEach((categoria, elemento) {
    String compatibilidad = _evaluarCompatibilidad(elemento);
    String recomendacion = _obtenerRecomendacion(elemento);
    
    _setCellValue(sheet, fila, 0, nombresCategoria[categoria] ?? categoria);
    _setCellValue(sheet, fila, 1, elemento);
    _setCellValue(sheet, fila, 2, compatibilidad);
    _setCellValue(sheet, fila, 3, recomendacion);
    
    // Color según compatibilidad
    String bgColor = '#FFFFFF';
    if (compatibilidad.contains('Alta')) bgColor = '#E8F5E8';
    else if (compatibilidad.contains('Media')) bgColor = '#FFF2CC';
    else if (compatibilidad.contains('Baja')) bgColor = '#FFE8E8';
    
    _aplicarEstiloFila(sheet, fila, 0, 4, bgColor);
    fila++;
  });

  return fila;
}

/// Crea evaluación de vulnerabilidad
int _crearEvaluacionVulnerabilidad(
  Sheet sheet,
  Map<String, dynamic> datos,
  int filaInicial,
) {
  int fila = filaInicial;

  // Título de sección
  _setCellValue(sheet, fila, 0, 'EVALUACIÓN DE VULNERABILIDAD ESTRUCTURAL');
  _aplicarEstiloSeccion(sheet, fila, 0);
  fila++;

  // Verificar si hay datos de vulnerabilidad
  if (!datos['estadisticas']?.containsKey('vulnerabilidad')) {
    _setCellValue(sheet, fila, 0, 'No hay datos de vulnerabilidad disponibles');
    return fila + 1;
  }

  Map<String, dynamic> vulnerabilidad = datos['estadisticas']['vulnerabilidad'];

  // Encabezados
  _setCellValue(sheet, fila, 0, 'Factor de Vulnerabilidad');
  _setCellValue(sheet, fila, 1, 'Casos Detectados');
  _setCellValue(sheet, fila, 2, 'Nivel de Riesgo');
  _setCellValue(sheet, fila, 3, 'Acción Requerida');
  _aplicarEstiloTablaHeader(sheet, fila, 0, 4, '#FFB366');
  fila++;

  // Factores de vulnerabilidad con niveles de riesgo
  vulnerabilidad.forEach((factor, stats) {
    int conteo = stats['conteo'] ?? 0;
    if (conteo > 0) {
      String nivelRiesgo = _evaluarNivelRiesgo(factor, conteo);
      String accion = _determinarAccion(nivelRiesgo);
      
      _setCellValue(sheet, fila, 0, factor);
      _setCellValue(sheet, fila, 1, conteo.toString());
      _setCellValue(sheet, fila, 2, nivelRiesgo);
      _setCellValue(sheet, fila, 3, accion);
      
      // Color según nivel de riesgo
      String bgColor = '#FFFFFF';
      if (nivelRiesgo.contains('Alto')) bgColor = '#FFE8E8';
      else if (nivelRiesgo.contains('Medio')) bgColor = '#FFF2CC';
      else bgColor = '#E8F5E8';
      
      _aplicarEstiloFila(sheet, fila, 0, 4, bgColor);
      fila++;
    }
  });

  return fila;
}

/// Crea recomendaciones técnicas específicas para sistema estructural
void _crearRecomendacionesTecnicasSistema(
  Sheet sheet,
  Map<String, dynamic> datos,
  Map<String, dynamic> metadatos,
  int filaInicial,
) {
  int fila = filaInicial;

  // Título de sección
  _setCellValue(sheet, fila, 0, 'RECOMENDACIONES TÉCNICAS ESPECIALIZADAS');
  _aplicarEstiloSeccion(sheet, fila, 0);
  fila++;

  // Análisis de elementos críticos
  List<String> recomendacionesCriticas = _generarRecomendacionesCriticas(datos);
  
  _setCellValue(sheet, fila, 0, 'RECOMENDACIONES PRIORITARIAS:');
  _aplicarEstilo(sheet, fila, 0, bold: true, backgroundColor: '#FFE2CC');
  fila++;

  for (String recomendacion in recomendacionesCriticas) {
    _setCellValue(sheet, fila, 0, recomendacion);
    _aplicarEstilo(sheet, fila, 0, backgroundColor: '#FFF9E6');
    fila++;
  }

  fila++;

  // Conclusión técnica
  String conclusion = metadatos['conclusiones'] ?? 
      'Se recomienda realizar evaluaciones periódicas del sistema estructural y mantener un registro actualizado de las condiciones encontradas.';

  _setCellValue(sheet, fila, 0, 'CONCLUSIÓN TÉCNICA:');
  _aplicarEstilo(sheet, fila, 0, bold: true, backgroundColor: '#E2EFDA');
  fila++;

  _setCellValue(sheet, fila, 0, conclusion);
  _aplicarEstilo(sheet, fila, 0, backgroundColor: '#F2F7FF');
}

// === MÉTODOS AUXILIARES ESPECÍFICOS ===

/// Evalúa compatibilidad de elementos estructurales
String _evaluarCompatibilidad(String elemento) {
  // Mapeo de compatibilidades basado en ingeniería estructural
  Map<String, String> compatibilidades = {
    'Marcos de concreto': 'Alta - Sistema rígido confiable',
    'Muros de concreto': 'Alta - Estructura monolítica',
    'Muros confinados': 'Media-Alta - Buen comportamiento sísmico',
    'Losa maciza': 'Alta - Distribución uniforme de cargas',
    'Zapatas aisladas': 'Media - Requiere buen suelo',
    'Losa de cimentación': 'Alta - Distribución amplia de cargas',
  };
  
  return compatibilidades[elemento] ?? 'Media - Requiere evaluación específica';
}

/// Obtiene recomendación para elemento específico
String _obtenerRecomendacion(String elemento) {
  Map<String, String> recomendaciones = {
    'Marcos de concreto': 'Mantener inspección de juntas',
    'Muros de concreto': 'Verificar fisuras periódicamente',
    'Muros confinados': 'Inspeccionar elementos de confinamiento',
    'Adobe o bahareque': 'Considerar refuerzo urgente',
    'Losa maciza': 'Monitorear deflexiones',
    'Teja': 'Verificar sistema de soporte',
  };
  
  return recomendaciones[elemento] ?? 'Consultar especialista estructural';
}

/// Evalúa nivel de riesgo basado en el factor
String _evaluarNivelRiesgo(String factor, int casos) {
  // Factores de alto riesgo
  List<String> factoresAltoRiesgo = [
    'Geometría irregular',
    'Discontinuidad en planta',
    'Piso blando',
    'Columna corta',
  ];
  
  if (factoresAltoRiesgo.any((f) => factor.toLowerCase().contains(f.toLowerCase()))) {
    return casos > 5 ? 'Riesgo Alto' : 'Riesgo Medio';
  }
  
  return casos > 10 ? 'Riesgo Medio' : 'Riesgo Bajo';
}

/// Determina acción según nivel de riesgo
String _determinarAccion(String nivelRiesgo) {
  switch (nivelRiesgo) {
    case 'Riesgo Alto':
      return 'Evaluación estructural inmediata';
    case 'Riesgo Medio':
      return 'Inspección detallada en 6 meses';
    case 'Riesgo Bajo':
      return 'Monitoreo rutinario anual';
    default:
      return 'Consultar especialista';
  }
}

/// Genera recomendaciones críticas basadas en los datos
List<String> _generarRecomendacionesCriticas(Map<String, dynamic> datos) {
  List<String> recomendaciones = [];
  
  // Verificar sistemas de adobe o bahareque
  if (datos['estadisticas']?['direccionX']?.containsKey('Muros de adobe o bahareque') == true ||
      datos['estadisticas']?['direccionY']?.containsKey('Muros de adobe o bahareque') == true) {
    recomendaciones.add('• CRÍTICO: Inmuebles con adobe/bahareque requieren refuerzo estructural urgente');
  }
  
  // Verificar vulnerabilidades geométricas
  if (datos['estadisticas']?['vulnerabilidad']?.isNotEmpty == true) {
    recomendaciones.add('• Implementar medidas correctivas para vulnerabilidades identificadas');
  }
  
  // Recomendaciones generales
  recomendaciones.addAll([
    '• Establecer programa de inspección periódica según tipología estructural',
    '• Capacitar personal en identificación de elementos estructurales críticos',
    '• Desarrollar protocolos específicos por tipo de sistema estructural',
  ]);
  
  return recomendaciones;
}

  /// Genera un reporte completo de Material Dominante en Excel
/// Incluye análisis detallado de materiales de construcción predominantes
Future<String> generarReporteMaterialDominanteExcel({
  required String titulo,
  required String subtitulo,
  required Map<String, dynamic> datos,
  required List<Map<String, dynamic>> tablas,
  required Map<String, dynamic> metadatos,
  Directory? directorio,
}) async {
  try {
    print('📊 [EXCEL-MATERIAL] Iniciando generación de reporte Excel: $titulo');

    // Crear nuevo libro de Excel usando la librería excel
    var excel = Excel.createExcel();
    
    // Eliminar hoja por defecto
    excel.delete('Sheet1');
    
    // Crear hoja única con todo el contenido
    String nombreHoja = 'Material Dominante';
    excel.copy('Sheet1', nombreHoja);
    excel.delete('Sheet1');
    
    Sheet sheet = excel[nombreHoja];
    
    // Crear contenido completo en una sola hoja
    await _crearContenidoMaterialDominanteCompleto(sheet, titulo, subtitulo, datos, tablas, metadatos);

    // Guardar archivo
    final String rutaArchivo = await _guardarArchivoExcelEstandar(
      excel, 
      titulo, 
      directorio
    );
    
    print('✅ [EXCEL-MATERIAL] Reporte Excel generado exitosamente: $rutaArchivo');
    return rutaArchivo;

  } catch (e) {
    print('❌ [EXCEL-MATERIAL] Error al generar reporte Excel: $e');
    throw Exception('Error al generar reporte Excel de material dominante: $e');
  }
}

/// Crea todo el contenido del reporte de material dominante en una sola hoja
Future<void> _crearContenidoMaterialDominanteCompleto(
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

  // === SECCIÓN 3: RESUMEN ESTADÍSTICO ===
  filaActual = _crearResumenEstadisticoMaterialDominante(sheet, datos, metadatos, filaActual);
  filaActual += 2;

  // === SECCIÓN 4: ANÁLISIS DETALLADO DE MATERIALES ===
  filaActual = _crearAnalisisDetalladoMateriales(sheet, datos, filaActual);
  filaActual += 2;

  // === SECCIÓN 5: CLASIFICACIÓN POR RESISTENCIA ===
  filaActual = _crearClasificacionResistencia(sheet, datos, filaActual);
  filaActual += 2;

  // === SECCIÓN 6: RECOMENDACIONES TÉCNICAS ===
  _crearRecomendacionesTecnicas(sheet, datos, metadatos, filaActual);
}

/// Crea resumen estadístico específico para materiales
int _crearResumenEstadisticoMaterialDominante(
  Sheet sheet,
  Map<String, dynamic> datos,
  Map<String, dynamic> metadatos,
  int filaInicial,
) {
  int fila = filaInicial;

  // Título de sección
  _setCellValue(sheet, fila, 0, 'RESUMEN ESTADÍSTICO DE MATERIALES');
  _aplicarEstiloSeccion(sheet, fila, 0);
  fila++;

  final int totalFormatos = metadatos['totalFormatos'] ?? 0;

  // Extraer datos de conteo de materiales
  Map<String, int> conteoMateriales = {};
  if (datos.containsKey('conteoMateriales')) {
    conteoMateriales = Map<String, int>.from(datos['conteoMateriales']);
  }

  // Calcular estadísticas principales
  int materialesDistintos = conteoMateriales.values.where((conteo) => conteo > 0).length;
  int totalMaterialesIdentificados = conteoMateriales.values.fold(0, (sum, conteo) => sum + conteo);
  
  // Calcular índice de diversidad (Shannon)
  double indiceDiversidad = 0.0;
  if (totalMaterialesIdentificados > 0) {
    for (var conteo in conteoMateriales.values) {
      if (conteo > 0) {
        double proporcion = conteo / totalMaterialesIdentificados;
        indiceDiversidad -= proporcion * (proporcion > 0 ? log(proporcion * 1.4427) : 0); // log2
      }
    }
  }

  // Encabezados de tabla
  _setCellValue(sheet, fila, 0, 'Concepto');
  _setCellValue(sheet, fila, 1, 'Valor');
  _setCellValue(sheet, fila, 2, 'Interpretación');
  _aplicarEstiloTablaHeader(sheet, fila, 0, 3, '#FFB366');
  fila++;

  // Estadísticas principales
  final List<List<String>> estadisticas = [
    ['Total de inmuebles analizados', '$totalFormatos', '100% de la muestra'],
    ['Materiales distintos identificados', '$materialesDistintos', 'Diversidad de materiales'],
    ['Inmuebles con material identificado', '$totalMaterialesIdentificados', 'Claridad en identificación'],
    ['Índice de diversidad Shannon', indiceDiversidad.toStringAsFixed(2), 
     indiceDiversidad < 1.0 ? 'Baja diversidad' : indiceDiversidad < 2.0 ? 'Diversidad media' : 'Alta diversidad'],
  ];

  // Encontrar material predominante
  if (conteoMateriales.isNotEmpty) {
    final materialPredominante = conteoMateriales.entries
        .where((entry) => entry.value > 0)
        .reduce((a, b) => a.value > b.value ? a : b);
    
    double porcentajePredominante = totalFormatos > 0 ? (materialPredominante.value / totalFormatos) * 100 : 0;
    estadisticas.add([
      'Material predominante', 
      materialPredominante.key, 
      '${materialPredominante.value} inmuebles (${porcentajePredominante.toStringAsFixed(1)}%)'
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

/// Crea análisis detallado de materiales con características técnicas
int _crearAnalisisDetalladoMateriales(
  Sheet sheet,
  Map<String, dynamic> datos,
  int filaInicial,
) {
  int fila = filaInicial;

  // Título de sección
  _setCellValue(sheet, fila, 0, 'ANÁLISIS DETALLADO DE MATERIALES');
  _aplicarEstiloSeccion(sheet, fila, 0);
  fila++;

  // Verificar si hay datos
  if (!datos.containsKey('conteoMateriales') || datos['conteoMateriales'].isEmpty) {
    _setCellValue(sheet, fila, 0, 'No hay datos de materiales disponibles');
    return fila + 1;
  }

  Map<String, int> conteoMateriales = Map<String, int>.from(datos['conteoMateriales']);
  
  // Encabezados de tabla expandida
  _setCellValue(sheet, fila, 0, 'Material');
  _setCellValue(sheet, fila, 1, 'Cantidad');
  _setCellValue(sheet, fila, 2, 'Porcentaje');
  _setCellValue(sheet, fila, 3, 'Resistencia');
  _setCellValue(sheet, fila, 4, 'Durabilidad');
  _setCellValue(sheet, fila, 5, 'Características');
  _aplicarEstiloTablaHeader(sheet, fila, 0, 6, '#C6E0B4');
  fila++;

  // Propiedades técnicas de materiales
  Map<String, Map<String, String>> propiedadesMateriales = {
    'Ladrillo': {
      'resistencia': 'Media-Alta',
      'durabilidad': 'Alta',
      'caracteristicas': 'Resistente a compresión, buen aislamiento térmico'
    },
    'Concreto': {
      'resistencia': 'Alta',
      'durabilidad': 'Muy Alta',
      'caracteristicas': 'Excelente resistencia, versatilidad estructural'
    },
    'Adobe': {
      'resistencia': 'Baja',
      'durabilidad': 'Media',
      'caracteristicas': 'Económico, vulnerable a humedad y sismos'
    },
    'Madera/Lámina/Otros': {
      'resistencia': 'Variable',
      'durabilidad': 'Baja-Media',
      'caracteristicas': 'Flexible, requiere mantenimiento constante'
    },
    'No determinado': {
      'resistencia': 'Desconocida',
      'durabilidad': 'Desconocida',
      'caracteristicas': 'Requiere evaluación técnica específica'
    },
  };

  // Ordenar materiales por cantidad
  var materialesOrdenados = conteoMateriales.entries
      .where((entry) => entry.value > 0)
      .toList()
    ..sort((a, b) => b.value.compareTo(a.value));

  int totalMateriales = materialesOrdenados.fold(0, (sum, entry) => sum + entry.value);

  // Datos de materiales
  for (int i = 0; i < materialesOrdenados.length; i++) {
    var entry = materialesOrdenados[i];
    String material = entry.key;
    int conteo = entry.value;
    double porcentaje = totalMateriales > 0 ? (conteo / totalMateriales) * 100 : 0;
    
    Map<String, String> propiedades = propiedadesMateriales[material] ?? {
      'resistencia': 'No especificada',
      'durabilidad': 'No especificada',
      'caracteristicas': 'Consultar especificaciones técnicas'
    };

    _setCellValue(sheet, fila, 0, material);
    _setCellValue(sheet, fila, 1, conteo.toString());
    _setCellValue(sheet, fila, 2, '${porcentaje.toStringAsFixed(1)}%');
    _setCellValue(sheet, fila, 3, propiedades['resistencia']!);
    _setCellValue(sheet, fila, 4, propiedades['durabilidad']!);
    _setCellValue(sheet, fila, 5, propiedades['caracteristicas']!);
    
    // Alternar colores con códigos específicos por nivel de resistencia
    String bgColor = '#FFFFFF';
    if (propiedades['resistencia'] == 'Alta' || propiedades['resistencia'] == 'Muy Alta') {
      bgColor = '#E8F5E8'; // Verde claro para alta resistencia
    } else if (propiedades['resistencia'] == 'Baja') {
      bgColor = '#FFE8E8'; // Rojo claro para baja resistencia
    } else if (fila % 2 == 0) {
      bgColor = '#F2F2F2';
    }
    _aplicarEstiloFila(sheet, fila, 0, 6, bgColor);
    fila++;
  }

  // Fila de total
  _setCellValue(sheet, fila, 0, 'TOTAL');
  _setCellValue(sheet, fila, 1, totalMateriales.toString());
  _setCellValue(sheet, fila, 2, '100%');
  _setCellValue(sheet, fila, 3, 'Mixto');
  _setCellValue(sheet, fila, 4, 'Variable');
  _setCellValue(sheet, fila, 5, 'Combinación de propiedades');
  _aplicarEstiloTablaHeader(sheet, fila, 0, 6, '#D9E2F3');
  fila++;

  return fila;
}

/// Crea clasificación por resistencia estructural
int _crearClasificacionResistencia(
  Sheet sheet,
  Map<String, dynamic> datos,
  int filaInicial,
) {
  int fila = filaInicial;

  // Título de sección
  _setCellValue(sheet, fila, 0, 'CLASIFICACIÓN POR RESISTENCIA ESTRUCTURAL');
  _aplicarEstiloSeccion(sheet, fila, 0);
  fila++;

  if (!datos.containsKey('conteoMateriales') || datos['conteoMateriales'].isEmpty) {
    _setCellValue(sheet, fila, 0, 'No hay datos suficientes para clasificación');
    return fila + 1;
  }

  Map<String, int> conteoMateriales = Map<String, int>.from(datos['conteoMateriales']);

  // Clasificar materiales por resistencia
  Map<String, List<String>> clasificacionResistencia = {
    'Alta Resistencia': ['Concreto'],
    'Media-Alta Resistencia': ['Ladrillo'],
    'Baja Resistencia': ['Adobe'],
    'Resistencia Variable': ['Madera/Lámina/Otros'],
    'Sin Clasificar': ['No determinado'],
  };

  // Encabezados
  _setCellValue(sheet, fila, 0, 'Nivel de Resistencia');
  _setCellValue(sheet, fila, 1, 'Materiales');
  _setCellValue(sheet, fila, 2, 'Cantidad Total');
  _setCellValue(sheet, fila, 3, 'Porcentaje');
  _setCellValue(sheet, fila, 4, 'Recomendación');
  _aplicarEstiloTablaHeader(sheet, fila, 0, 5, '#F4B183');
  fila++;

  int totalInmuebles = conteoMateriales.values.fold(0, (sum, val) => sum + val);

  // Recomendaciones por nivel de resistencia
  Map<String, String> recomendaciones = {
    'Alta Resistencia': 'Continuar mantenimiento preventivo',
    'Media-Alta Resistencia': 'Monitoreo periódico, refuerzo opcional',
    'Baja Resistencia': 'Evaluación urgente, considerar refuerzo',
    'Resistencia Variable': 'Inspección caso por caso',
    'Sin Clasificar': 'Evaluación técnica inmediata requerida',
  };

  // Procesar cada nivel de resistencia
  for (var entry in clasificacionResistencia.entries) {
    String nivelResistencia = entry.key;
    List<String> materialesEnNivel = entry.value;
    
    // Calcular total para este nivel
    int cantidadTotal = 0;
    List<String> materialesPresentes = [];
    
    for (String material in materialesEnNivel) {
      if (conteoMateriales.containsKey(material) && conteoMateriales[material]! > 0) {
        cantidadTotal += conteoMateriales[material]!;
        materialesPresentes.add('$material (${conteoMateriales[material]})');
      }
    }
    
    if (cantidadTotal > 0) {
      double porcentaje = totalInmuebles > 0 ? (cantidadTotal / totalInmuebles) * 100 : 0;
      
      _setCellValue(sheet, fila, 0, nivelResistencia);
      _setCellValue(sheet, fila, 1, materialesPresentes.join(', '));
      _setCellValue(sheet, fila, 2, cantidadTotal.toString());
      _setCellValue(sheet, fila, 3, '${porcentaje.toStringAsFixed(1)}%');
      _setCellValue(sheet, fila, 4, recomendaciones[nivelResistencia] ?? 'Consultar especialista');
      
      // Color por nivel de riesgo
      String bgColor = '#FFFFFF';
      if (nivelResistencia.contains('Alta Resistencia')) {
        bgColor = '#E8F5E8'; // Verde
      } else if (nivelResistencia.contains('Baja Resistencia')) {
        bgColor = '#FFE8E8'; // Rojo
      } else if (nivelResistencia.contains('Variable') || nivelResistencia.contains('Sin Clasificar')) {
        bgColor = '#FFF2CC'; // Amarillo
      } else {
        bgColor = fila % 2 == 0 ? '#F2F2F2' : '#FFFFFF';
      }
      
      _aplicarEstiloFila(sheet, fila, 0, 5, bgColor);
      fila++;
    }
  }

  return fila;
}

/// Crea sección de recomendaciones técnicas
void _crearRecomendacionesTecnicas(
  Sheet sheet,
  Map<String, dynamic> datos,
  Map<String, dynamic> metadatos,
  int filaInicial,
) {
  int fila = filaInicial;

  // Título de sección
  _setCellValue(sheet, fila, 0, 'RECOMENDACIONES TÉCNICAS Y CONCLUSIONES');
  _aplicarEstiloSeccion(sheet, fila, 0);
  fila++;

  if (!datos.containsKey('conteoMateriales')) {
    _setCellValue(sheet, fila, 0, 'No hay datos suficientes para generar recomendaciones');
    return;
  }

  Map<String, int> conteoMateriales = Map<String, int>.from(datos['conteoMateriales']);
  final int totalFormatos = metadatos['totalFormatos'] ?? 0;

  // Análisis de riesgos por material predominante
  _setCellValue(sheet, fila, 0, 'ANÁLISIS DE RIESGOS:');
  _aplicarEstilo(sheet, fila, 0, bold: true, backgroundColor: '#FFE2CC');
  fila++;

  // Calcular porcentajes de materiales vulnerables
  int materialesVulnerables = (conteoMateriales['Adobe'] ?? 0) + 
                              (conteoMateriales['Madera/Lámina/Otros'] ?? 0);
  double porcentajeVulnerable = totalFormatos > 0 ? (materialesVulnerables / totalFormatos) * 100 : 0;

  int materialesResistentes = (conteoMateriales['Concreto'] ?? 0) + 
                              (conteoMateriales['Ladrillo'] ?? 0);
  double porcentajeResistente = totalFormatos > 0 ? (materialesResistentes / totalFormatos) * 100 : 0;

  _setCellValue(sheet, fila, 0, '• Materiales vulnerables: ${porcentajeVulnerable.toStringAsFixed(1)}% ($materialesVulnerables inmuebles)');
  _aplicarEstilo(sheet, fila, 0, backgroundColor: '#FFE8E8');
  fila++;

  _setCellValue(sheet, fila, 0, '• Materiales resistentes: ${porcentajeResistente.toStringAsFixed(1)}% ($materialesResistentes inmuebles)');
  _aplicarEstilo(sheet, fila, 0, backgroundColor: '#E8F5E8');
  fila++;

  fila++;

  // Recomendaciones específicas
  _setCellValue(sheet, fila, 0, 'RECOMENDACIONES ESPECÍFICAS:');
  _aplicarEstilo(sheet, fila, 0, bold: true, backgroundColor: '#E2EFDA');
  fila++;

  List<String> recomendaciones = [];

  if (porcentajeVulnerable > 30) {
    recomendaciones.add('• PRIORIDAD ALTA: Implementar programa de refuerzo masivo para inmuebles con materiales vulnerables');
  }

  if (porcentajeVulnerable > 50) {
    recomendaciones.add('• Establecer plan de evacuación para zonas con alta concentración de materiales de bajo desempeño');
  }

  if (conteoMateriales['No determinado'] != null && conteoMateriales['No determinado']! > 0) {
    double porcentajeIndeterminado = (conteoMateriales['No determinado']! / totalFormatos) * 100;
    recomendaciones.add('• Realizar evaluaciones técnicas específicas para ${porcentajeIndeterminado.toStringAsFixed(1)}% de inmuebles sin material determinado');
  }

  recomendaciones.addAll([
    '• Establecer programa de mantenimiento preventivo para materiales de alta resistencia',
    '• Desarrollar normativas específicas para cada tipo de material identificado',
    '• Capacitar evaluadores en identificación precisa de materiales de construcción',
  ]);

  // Escribir recomendaciones
  for (String recomendacion in recomendaciones) {
    _setCellValue(sheet, fila, 0, recomendacion);
    _aplicarEstilo(sheet, fila, 0, backgroundColor: '#F9F9F9');
    fila++;
  }

  fila++;

  // Conclusión final
  String materialPredominante = 'No determinado';
  if (conteoMateriales.isNotEmpty) {
    final entry = conteoMateriales.entries
        .where((e) => e.value > 0)
        .reduce((a, b) => a.value > b.value ? a : b);
    materialPredominante = entry.key;
  }

  String conclusion = metadatos['conclusiones'] ?? 
      'Material predominante identificado: $materialPredominante. Se recomienda continuar con el monitoreo y evaluación de materiales para optimizar las estrategias de refuerzo estructural.';

  _setCellValue(sheet, fila, 0, 'CONCLUSIÓN:');
  _aplicarEstilo(sheet, fila, 0, bold: true, backgroundColor: '#D9E2F3');
  fila++;

  _setCellValue(sheet, fila, 0, conclusion);
  _aplicarEstilo(sheet, fila, 0, backgroundColor: '#F2F7FF');
}

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