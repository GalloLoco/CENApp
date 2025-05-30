// lib/data/services/reporte_service.dart (versión actualizada con Excel)

import 'dart:typed_data';
import 'package:intl/intl.dart';
import '../../logica/formato_evaluacion.dart';
import '../../data/services/cloud_storage_service.dart';
import '../../data/services/estadisticos_service.dart';
import '../reportes/sistema_estructural_reporte.dart';
import '../reportes/material_dominante_reporte.dart';
import '../reportes/evaluacion_danos_reporte.dart';
import '../../data/services/reporte_documental_service.dart';
import '../reportes/usovivienda_topografico_Excel.dart';
import '../reportes/sistema_estructural_reporte_excel.dart';  //reporte Excel
import '../reportes/material_dominante_excel.dart'; // Nuevo import
import '../reportes/resumen_general_excel.dart';
import '../reportes/evaluacion_danos_excel.dart';
import '../reportes/reporte_completo.dart';
import '../../data/services/excel_reporte_service.dart'; // Nuevo import

class ReporteService {
  final CloudStorageService _cloudService = CloudStorageService();
  final ExcelReporteService _excelService =
      ExcelReporteService(); // Nueva instancia





  /// Genera un reporte completo unificado que incluye todas las secciones de análisis
  /// Este reporte consolida: Resumen General, Uso y Topografía, Material Dominante,
  /// Sistema Estructural y Evaluación de Daños en un solo documento integral
  ///
  /// **ACTUALIZADO**: Ahora incluye generación de Excel
  Future<Map<String, String>> generarReporteCompleto({
  required String nombreInmueble,
  required DateTime fechaInicio,
  required DateTime fechaFin,
  required String usuarioCreador,
  required List<Map<String, dynamic>> ubicaciones,
}) async {
  try {
    print('📊 [REPORTE COMPLETO] Iniciando generación integral con Excel...');

    // Paso 1: Buscar formatos (reutiliza lógica existente)
    List<FormatoEvaluacion> formatos = await _buscarFormatos(
      nombreInmueble: nombreInmueble,
      fechaInicio: fechaInicio,
      fechaFin: fechaFin,
      usuarioCreador: usuarioCreador,
      ubicaciones: ubicaciones,
    );

    if (formatos.isEmpty) {
      throw Exception('No se encontraron formatos que cumplan con los criterios especificados');
    }

    print('✅ [REPORTE COMPLETO] Encontrados ${formatos.length} formatos');

    // Paso 2: Generar análisis completo (reutiliza servicio existente)
    Map<String, dynamic> datosCompletos = await ReporteCompletoService.generarReporteCompleto(
      formatos: formatos,
      metadatos: {
        'titulo': 'Reporte Completo de Evaluación Estructural',
        'subtitulo': 'Análisis Integral Multidimensional',
        'totalFormatos': formatos.length,
        'nombreInmueble': nombreInmueble.isEmpty ? 'Todos' : nombreInmueble,
        'fechaInicio': DateFormat('dd/MM/yyyy').format(fechaInicio),
        'fechaFin': DateFormat('dd/MM/yyyy').format(fechaFin),
        'usuarioCreador': usuarioCreador.isEmpty ? 'Todos' : usuarioCreador,
        'ubicaciones': ubicaciones,
        'periodoEvaluacion': '${DateFormat('MM/yyyy').format(fechaInicio)} - ${DateFormat('MM/yyyy').format(fechaFin)}',
      },
    );

    // Paso 3: Preparar tablas consolidadas (reutiliza lógica existente)
    List<Map<String, dynamic>> tablasCompletas = ReporteCompletoService.prepararTablasCompletas(datosCompletos);

    // 🆕 Paso 4: Generar Excel usando nuestro nuevo servicio
    String rutaExcel = await _excelService.generarReporteCompletoExcel(
      titulo: 'Reporte Completo de Evaluación Estructural',
      subtitulo: 'Análisis Integral Multidimensional - ${datosCompletos['metadatos']['periodoEvaluacion']}',
      datos: datosCompletos,
      tablas: tablasCompletas,
      metadatos: datosCompletos['metadatos'],
    );

    print('✅ [EXCEL-COMPLETO] Reporte Excel integral generado: $rutaExcel');

    // Paso 5: Generar también PDF (mantener funcionalidad existente)
    List<Uint8List> graficasCompletas = await ReporteCompletoService.generarGraficasCompletas(datosCompletos);
    String conclusionesCompletas = ReporteCompletoService.generarConclusionesCompletas(datosCompletos);
    
    // Agregar conclusiones a metadatos
    datosCompletos['metadatos']['conclusiones'] = conclusionesCompletas;

    String rutaPDF = await ReporteDocumentalService.generarReportePDF(
      titulo: 'Reporte Completo de Evaluación Estructural',
      subtitulo: 'Análisis Integral Multidimensional - Período: ${datosCompletos['metadatos']['periodoEvaluacion']}',
      datos: datosCompletos,
      tablas: tablasCompletas,
      graficas: graficasCompletas,
      metadatos: datosCompletos['metadatos'],
    );

    print('✅ [REPORTE COMPLETO] Ambos formatos generados exitosamente');
    print('   PDF: $rutaPDF');
    print('   Excel: $rutaExcel');

    return {
      'excel': rutaExcel, // 🆕 NUEVO: Excel con análisis integral
      'pdf': rutaPDF,     // Mantener PDF existente
    };

  } catch (e) {
    print('❌ [REPORTE COMPLETO] Error al generar reporte integral: $e');
    throw Exception('Error al generar reporte completo: $e');
  }
}

  /// Genera un reporte de evaluación de daños
  /// Genera un reporte de evaluación de daños
/// **ACTUALIZADO**: Incluye generación de Excel
Future<Map<String, String>> generarReporteEvaluacionDanos({
  required String nombreInmueble,
  required DateTime fechaInicio,
  required DateTime fechaFin,
  required String usuarioCreador,
  required List<Map<String, dynamic>> ubicaciones,
}) async {
  try {
    // Paso 1: Buscar formatos que cumplan con los criterios
    List<FormatoEvaluacion> formatos = await _buscarFormatos(
      nombreInmueble: nombreInmueble,
      fechaInicio: fechaInicio,
      fechaFin: fechaFin,
      usuarioCreador: usuarioCreador,
      ubicaciones: ubicaciones,
    );

    if (formatos.isEmpty) {
      throw Exception(
          'No se encontraron formatos que cumplan con los criterios especificados');
    }

    // Paso 2: Analizar los datos usando el módulo específico de evaluación de daños
    Map<String, dynamic> datosEstadisticos =
        EvaluacionDanosReport.analizarDatos(formatos);

    // Paso 3: Preparar datos para las tablas del reporte
    List<Map<String, dynamic>> tablas =
        EvaluacionDanosReport.prepararTablas(datosEstadisticos);

    // Paso 4: Construir metadatos para el reporte
    Map<String, dynamic> metadatos = {
      'titulo': 'Evaluación de Daños',
      'subtitulo': 'Análisis de Daños y Riesgos Estructurales',
      'totalFormatos': formatos.length,
      'nombreInmueble': nombreInmueble.isEmpty ? 'Todos' : nombreInmueble,
      'fechaInicio': DateFormat('dd/MM/yyyy').format(fechaInicio),
      'fechaFin': DateFormat('dd/MM/yyyy').format(fechaFin),
      'usuarioCreador': usuarioCreador.isEmpty ? 'Todos' : usuarioCreador,
      'ubicaciones': ubicaciones,
      'autor': 'Sistema CENApp - Módulo de Evaluación de Daños',
      'conclusiones': EvaluacionDanosReport.generarConclusiones(
          datosEstadisticos, formatos.length),
    };

    // 🆕 Paso 5: Generar Excel usando nuestro servicio especializado
    String rutaExcel = await ExcelReporteServiceEvaluacionDanosV2().generarReporteEvaluacionDanos(
      titulo: metadatos['titulo']!,
      subtitulo: metadatos['subtitulo']!,
      datos: datosEstadisticos,
      tablas: tablas,
      metadatos: metadatos,
    );

    print('✅ [EXCEL] Reporte Evaluación de Daños Excel generado: $rutaExcel');

    // Paso 6: Generar también PDF (mantener funcionalidad existente)
    List<Uint8List> graficas =
        await EvaluacionDanosReport.generarPlaceholdersGraficas(
            datosEstadisticos);

    String rutaPDF = await ReporteDocumentalService.generarReportePDF(
      titulo: 'Reporte de Evaluación de Daños',
      subtitulo: 'Análisis de Daños y Riesgos Estructurales',
      datos: datosEstadisticos,
      tablas: tablas,
      graficas: graficas,
      metadatos: metadatos,
    );

    print('✅ [PDF] Reporte PDF generado: $rutaPDF');

    return {
      'excel': rutaExcel, // 🆕 NUEVO: Excel con análisis detallado
      'pdf': rutaPDF, // Mantener PDF existente
    };
  } catch (e) {
    print('❌ Error al generar reporte de evaluación de daños: $e');
    throw Exception('Error al generar reporte de evaluación de daños: $e');
  }
}

  /// Genera un reporte de material dominante de construcción
  /// **ACTUALIZADO**: Incluye generación de Excel
  Future<Map<String, String>> generarReporteMaterialDominante({
    required String nombreInmueble,
    required DateTime fechaInicio,
    required DateTime fechaFin,
    required String usuarioCreador,
    required List<Map<String, dynamic>> ubicaciones,
  }) async {
    // Paso 1: Buscar formatos que cumplan con los criterios
    List<FormatoEvaluacion> formatos = await _buscarFormatos(
      nombreInmueble: nombreInmueble,
      fechaInicio: fechaInicio,
      fechaFin: fechaFin,
      usuarioCreador: usuarioCreador,
      ubicaciones: ubicaciones,
    );

    if (formatos.isEmpty) {
      throw Exception(
          'No se encontraron formatos que cumplan con los criterios especificados');
    }

    // Paso 2: Analizar los datos usando el módulo específico
    Map<String, dynamic> datosEstadisticos =
        MaterialDominanteReport.analizarDatos(formatos);

    // Paso 3: Preparar datos para las tablas del reporte
    List<Map<String, dynamic>> tablas =
        MaterialDominanteReport.prepararTablas(datosEstadisticos);

    // Paso 4: Generar placeholders para gráficas
    List<Uint8List> graficas =
        await MaterialDominanteReport.generarPlaceholdersGraficas(
            datosEstadisticos);

    // Paso 5: Construir metadatos para el reporte
    Map<String, dynamic> metadatos = {
      'titulo': 'Material Dominante de Construcción',
      'subtitulo': 'Análisis de Materiales Predominantes',
      'totalFormatos': formatos.length,
      'nombreInmueble': nombreInmueble.isEmpty ? 'Todos' : nombreInmueble,
      'fechaInicio': DateFormat('dd/MM/yyyy').format(fechaInicio),
      'fechaFin': DateFormat('dd/MM/yyyy').format(fechaFin),
      'usuarioCreador': usuarioCreador.isEmpty ? 'Todos' : usuarioCreador,
      'ubicaciones': ubicaciones,
      'conclusiones': MaterialDominanteReport.generarConclusiones(
          datosEstadisticos, formatos.length),
    };

    // 🆕 Paso 6: Generar Excel usando nuestro servicio especializado
    String rutaExcel = await ExcelReporteMaterialDominanteV2().generarReporteMaterialDominante(
      titulo: metadatos['titulo']!,
      subtitulo: metadatos['subtitulo']!,
      datos: datosEstadisticos,
      tablas: tablas,
      metadatos: metadatos,
    );

    print('✅ [EXCEL] Reporte Material Dominante Excel generado: $rutaExcel');

// Paso 7: Generar también PDF (mantener funcionalidad existente)
    String rutaPDF = await ReporteDocumentalService.generarReportePDF(
      titulo: 'Reporte Estadístico',
      subtitulo: 'Material Dominante de Construcción',
      datos: datosEstadisticos,
      tablas: tablas,
      graficas: graficas,
      metadatos: metadatos,
    );

    return {
      'excel': rutaExcel, // 🆕 NUEVO: Excel con análisis detallado
      'pdf': rutaPDF, // Mantener PDF existente
    };
  }

  /// Genera un reporte de sistema estructural
  /// **ACTUALIZADO**: Incluye generación de Excel
  Future<Map<String, String>> generarReporteSistemaEstructural({
    required String nombreInmueble,
    required DateTime fechaInicio,
    required DateTime fechaFin,
    required String usuarioCreador,
    required List<Map<String, dynamic>> ubicaciones,
  }) async {
    // Paso 1: Buscar formatos que cumplan con los criterios
    List<FormatoEvaluacion> formatos = await _buscarFormatos(
      nombreInmueble: nombreInmueble,
      fechaInicio: fechaInicio,
      fechaFin: fechaFin,
      usuarioCreador: usuarioCreador,
      ubicaciones: ubicaciones,
    );

    if (formatos.isEmpty) {
      throw Exception(
          'No se encontraron formatos que cumplan con los criterios especificados');
    }

    // Paso 2: Analizar los datos usando el módulo específico
    Map<String, dynamic> datosEstadisticos =
        SistemaEstructuralReport.analizarDatos(formatos);

    // Paso 3: Preparar datos para las tablas del reporte
    List<Map<String, dynamic>> tablas =
        SistemaEstructuralReport.prepararTablas(datosEstadisticos);

    // Paso 4: Generar placeholders para gráficas
    List<Uint8List> graficas =
        await SistemaEstructuralReport.generarPlaceholdersGraficas(
            datosEstadisticos);

    // Paso 5: Construir metadatos para el reporte
    Map<String, dynamic> metadatos = {
      'titulo': 'Sistema Estructural',
      'subtitulo': 'Análisis de Elementos Estructurales',
      'totalFormatos': formatos.length,
      'nombreInmueble': nombreInmueble.isEmpty ? 'Todos' : nombreInmueble,
      'fechaInicio': DateFormat('dd/MM/yyyy').format(fechaInicio),
      'fechaFin': DateFormat('dd/MM/yyyy').format(fechaFin),
      'usuarioCreador': usuarioCreador.isEmpty ? 'Todos' : usuarioCreador,
      'ubicaciones': ubicaciones,
      'conclusiones': SistemaEstructuralReport.generarConclusiones(
          datosEstadisticos, formatos.length),
    };

    // Paso 6: Generar documento PDF (mantener existente)
    String rutaPDF = await ReporteDocumentalService.generarReportePDF(
      titulo: 'Reporte Estadístico',
      subtitulo: 'Sistema Estructural',
      datos: datosEstadisticos,
      tablas: tablas,
      graficas: graficas,
      metadatos: metadatos,
    );

// 🆕 Paso 7: Generar Excel usando nuestro servicio especializado
    String rutaExcel =
        await ExcelReporteServiceSistemaEstructuralV2().generarReporteSistemaEstructural(
      titulo: metadatos['titulo']!,
      subtitulo: metadatos['subtitulo']!,
      datos: datosEstadisticos,
      tablas: tablas,
      metadatos: metadatos,
    );

    print('✅ [EXCEL] Reporte Sistema Estructural Excel generado: $rutaExcel');

    return {
      'excel': rutaExcel, // 🆕 NUEVO: Excel con análisis detallado
      'pdf': rutaPDF, // Mantener PDF existente
    };
  }

  /// Genera un reporte de uso de vivienda y topografía (VERSIÓN ACTUALIZADA CON EXCEL)
  Future<Map<String, String>> generarReporteUsoViviendaTopografia({
    required String nombreInmueble,
    required DateTime fechaInicio,
    required DateTime fechaFin,
    required String usuarioCreador,
    required List<Map<String, dynamic>> ubicaciones,
  }) async {
    try {
      print(
          '📊 [REPORTE] Iniciando generación de Uso de Vivienda y Topografía...');

      // Paso 1: Buscar formatos que cumplan con los criterios
      List<FormatoEvaluacion> formatos = await _buscarFormatos(
        nombreInmueble: nombreInmueble,
        fechaInicio: fechaInicio,
        fechaFin: fechaFin,
        usuarioCreador: usuarioCreador,
        ubicaciones: ubicaciones,
      );

      if (formatos.isEmpty) {
        throw Exception(
            'No se encontraron formatos que cumplan con los criterios especificados');
      }

      print('✅ [REPORTE] Encontrados ${formatos.length} formatos');

      // Paso 2: Analizar los datos para generar estadísticas
      Map<String, dynamic> datosEstadisticos =
          EstadisticosService.analizarUsoViviendaTopografia(formatos);

      // Paso 3: Preparar datos para las tablas del reporte
      List<Map<String, dynamic>> tablas =
          _prepararTablasParaReporte(datosEstadisticos);

      // Paso 4: Construir metadatos para el reporte
      Map<String, dynamic> metadatos = {
        'titulo': 'Uso de Vivienda y Topografía',
        'subtitulo':
            'Análisis de Patrones de Uso y Características Topográficas',
        'totalFormatos': formatos.length,
        'nombreInmueble': nombreInmueble.isEmpty ? 'Todos' : nombreInmueble,
        'fechaInicio': DateFormat('dd/MM/yyyy').format(fechaInicio),
        'fechaFin': DateFormat('dd/MM/yyyy').format(fechaFin),
        'usuarioCreador': usuarioCreador.isEmpty ? 'Todos' : usuarioCreador,
        'ubicaciones': ubicaciones,
        'autor': 'Sistema CENApp - Uso y Topografía',
        'periodoEvaluacion':
            '${DateFormat('MM/yyyy').format(fechaInicio)} - ${DateFormat('MM/yyyy').format(fechaFin)}',
        'conclusiones':
            _generarConclusiones(datosEstadisticos, formatos.length),
      };

      print('📊 [REPORTE] Iniciando generación de documentos...');

      // 🆕 Paso 5: Generar reporte Excel usando nuestro servicio
      String rutaExcel = await ExcelReporteServiceUsoViviendaV2().generarReporteUsoTopografia (
        titulo: metadatos['titulo']!,
        subtitulo: metadatos['subtitulo']!,
        datos: datosEstadisticos,
        tablas: tablas,
        metadatos: metadatos,
      );

      print('✅ [EXCEL] Reporte Excel generado: $rutaExcel');

      // Paso 6: Generar también PDF (mantener funcionalidad existente)
      List<Uint8List> graficas =
          await _generarGraficasReporte(datosEstadisticos);

      String rutaPDF = await ReporteDocumentalService.generarReportePDF(
        titulo: 'Reporte Estadístico',
        subtitulo: 'Uso de Vivienda y Topografía',
        datos: datosEstadisticos,
        tablas: tablas,
        graficas: graficas,
        metadatos: metadatos,
      );

      print('✅ [PDF] Reporte PDF generado: $rutaPDF');

      // Retornar ambos archivos
      return {
        'excel': rutaExcel, // 🆕 NUEVO: Excel con gráficos
        'pdf': rutaPDF, // Mantener PDF existente
      };
    } catch (e) {
      print('❌ [REPORTE] Error en Uso de Vivienda y Topografía: $e');
      throw Exception(
          'Error al generar reporte de uso de vivienda y topografía: $e');
    }
  }

  /// Genera un reporte de resumen general
  /// **NUEVO**: Ahora incluye generación de Excel
  Future<Map<String, String>> generarReporteResumenGeneral({
    required String nombreInmueble,
    required DateTime fechaInicio,
    required DateTime fechaFin,
    required String usuarioCreador,
    required List<Map<String, dynamic>> ubicaciones,
  }) async {
    try {
      print('📊 [RESUMEN GENERAL] Iniciando generación con soporte Excel...');

      // Paso 1: Buscar formatos que cumplan con los criterios
      List<FormatoEvaluacion> formatos = await _buscarFormatos(
        nombreInmueble: nombreInmueble,
        fechaInicio: fechaInicio,
        fechaFin: fechaFin,
        usuarioCreador: usuarioCreador,
        ubicaciones: ubicaciones,
      );

      if (formatos.isEmpty) {
        throw Exception(
            'No se encontraron formatos que cumplan con los criterios especificados');
      }

      print('✅ [RESUMEN GENERAL] Encontrados ${formatos.length} formatos');

      // Paso 2: Analizar los datos para generar estadísticas de distribución geográfica
      Map<String, dynamic> datosEstadisticos =
          _analizarDistribucionGeografica(formatos);

      // Paso 3: Preparar datos para las tablas del reporte
      List<Map<String, dynamic>> tablas =
          _prepararTablasResumenGeneral(datosEstadisticos, formatos);

      // Paso 4: Generar gráficas
      List<Uint8List> graficas =
          await _generarGraficasResumenGeneral(datosEstadisticos);

      // Paso 5: Construir metadatos para el reporte
      Map<String, dynamic> metadatos = {
        'titulo': 'Resumen General',
        'totalFormatos': formatos.length,
        'nombreInmueble': nombreInmueble.isEmpty ? 'Todos' : nombreInmueble,
        'fechaInicio': DateFormat('dd/MM/yyyy').format(fechaInicio),
        'fechaFin': DateFormat('dd/MM/yyyy').format(fechaFin),
        'usuarioCreador': usuarioCreador.isEmpty ? 'Todos' : usuarioCreador,
        'ubicaciones': ubicaciones,
        'periodoEvaluacion':
            '${DateFormat('MM/yyyy').format(fechaInicio)} - ${DateFormat('MM/yyyy').format(fechaFin)}',
        'areasGeograficas': _obtenerAreasGeograficas(formatos),
        'conclusiones':
            _generarConclusionesResumenGeneral(datosEstadisticos, formatos),
      };

      // Paso 6: Generar documento PDF
      print('📄 [RESUMEN GENERAL] Generando PDF...');
      String rutaPDF = await ReporteDocumentalService.generarReportePDF(
        titulo: 'Resumen General de Evaluaciones',
        subtitulo: 'Período: ${metadatos['periodoEvaluacion']}',
        datos: datosEstadisticos,
        tablas: tablas,
        graficas: graficas,
        metadatos: metadatos,
      );

      // **PASO 7: GENERAR EXCEL** (NUEVA FUNCIONALIDAD)
      print('📊 [RESUMEN GENERAL] Generando Excel...');
      String rutaExcel = await ExcelReporteServiceResumenGeneralV2().generarReporteResumenGeneral(
        titulo: 'Resumen General de Evaluaciones',
        subtitulo: 'Período: ${metadatos['periodoEvaluacion']}',
        datos: datosEstadisticos,
        tablas: tablas,
        metadatos: metadatos,
      );

      print('✅ [RESUMEN GENERAL] Ambos formatos generados exitosamente');
      print('   PDF: $rutaPDF');
      print('   Excel: $rutaExcel');

      return {
        'pdf': rutaPDF,
        'excel': rutaExcel, // **NUEVO**: Retornar también la ruta del Excel
      };
    } catch (e) {
      print('❌ [RESUMEN GENERAL] Error al generar reporte: $e');
      throw Exception('Error al generar reporte de resumen general: $e');
    }
  }

  // ============================================================================
  // MÉTODOS AUXILIARES (sin cambios significativos)
  // ============================================================================

  /// Busca formatos según los criterios especificados
  Future<List<FormatoEvaluacion>> _buscarFormatos({
    required String nombreInmueble,
    required DateTime fechaInicio,
    required DateTime fechaFin,
    required String usuarioCreador,
    required List<Map<String, dynamic>> ubicaciones,
  }) async {
    // Lista para almacenar los formatos encontrados
    List<FormatoEvaluacion> formatos = [];

    // Ajustar fechaFin para incluir todo el día
    DateTime fechaFinAjustada = DateTime(
      fechaFin.year,
      fechaFin.month,
      fechaFin.day,
      23,
      59,
      59,
      999,
    );

    // Realizar búsqueda en el servidor
    List<Map<String, dynamic>> resultados = await _cloudService.buscarFormatos(
      nombreInmueble: nombreInmueble,
      fechaCreacionDesde: fechaInicio,
      fechaCreacionHasta: fechaFinAjustada,
      usuarioCreador: usuarioCreador,
    );

    // Para cada resultado, obtener el formato completo
    for (var resultado in resultados) {
      FormatoEvaluacion? formato =
          await _cloudService.obtenerFormatoPorId(resultado['documentId']);
      if (formato != null) {
        // Verificar si cumple con las ubicaciones especificadas
        bool cumpleUbicaciones = _verificarUbicaciones(formato, ubicaciones);
        if (cumpleUbicaciones) {
          formatos.add(formato);
        }
      }
    }

    return formatos;
  }

  /// Verifica si un formato cumple con las ubicaciones especificadas
  bool _verificarUbicaciones(
      FormatoEvaluacion formato, List<Map<String, dynamic>> ubicaciones) {
    // Si no hay ubicaciones especificadas, retornar true
    if (ubicaciones.isEmpty) {
      return true;
    }

    // Verificar cada ubicación
    for (var ubicacion in ubicaciones) {
      String municipio = ubicacion['municipio'] ?? '';
      String ciudad = ubicacion['ciudad'] ?? '';
      String? colonia = ubicacion['colonia'];

      bool cumpleMunicipio = municipio.isEmpty ||
          formato.informacionGeneral.delegacionMunicipio == municipio;

      bool cumpleCiudad =
          ciudad.isEmpty || formato.informacionGeneral.ciudadPueblo == ciudad;

      bool cumpleColonia = colonia == null ||
          colonia.isEmpty ||
          formato.informacionGeneral.colonia == colonia;

      // Si cumple con una ubicación, retornar true
      if (cumpleMunicipio && cumpleCiudad && cumpleColonia) {
        return true;
      }
    }

    // Si no cumple con ninguna ubicación, retornar false
    return false;
  }

  List<Map<String, dynamic>> _prepararTablasParaReporte(
    Map<String, dynamic> datosEstadisticos) {
  
  List<Map<String, dynamic>> tablas = [];

  // 🏠 TABLA 1: Uso de Vivienda (CORREGIDA)
  if (datosEstadisticos.containsKey('usosVivienda') && 
      datosEstadisticos['usosVivienda']['estadisticas'] != null) {
    
    Map<String, Map<String, dynamic>> estadisticasUsos =
        datosEstadisticos['usosVivienda']['estadisticas'];

    if (estadisticasUsos.isNotEmpty) {
      List<List<dynamic>> filasUsos = [];

      // ✅ CALCULAR TOTAL CORRECTO: Suma de todos los conteos de uso
      int totalUsosRegistrados = estadisticasUsos.values
          .fold(0, (sum, stats) => sum + (stats['conteo'] as int? ?? 0));

      // 📊 Procesar cada uso con cálculos corregidos
      estadisticasUsos.forEach((uso, estadisticas) {
        int conteo = estadisticas['conteo'] as int? ?? 0;
        
        if (conteo > 0) {
          // ✅ PORCENTAJE CORRECTO: conteo / total de usos registrados
          double porcentajeRelativo = totalUsosRegistrados > 0 
              ? (conteo / totalUsosRegistrados) * 100 
              : 0.0;

          // 📈 También calculamos porcentaje absoluto si está disponible
          double porcentajeAbsoluto = estadisticas.containsKey('porcentajeAbsoluto')
              ? (estadisticas['porcentajeAbsoluto'] as double? ?? 0.0)
              : porcentajeRelativo;

          filasUsos.add([
            uso,
            conteo,
            '${porcentajeRelativo.toStringAsFixed(2)}%',
          ]);
        }
      });

      // 📊 Ordenar por frecuencia (descendente) para mejor visualización
      filasUsos.sort((a, b) => (b[1] as int).compareTo(a[1] as int));

      // 🔍 Agregar información de contexto si es útil
      if (filasUsos.isNotEmpty) {
        tablas.add({
          'titulo': 'Uso de Vivienda',
          'descripcion': 'Distribución de los usos de vivienda en los formatos analizados. Total de usos registrados: $totalUsosRegistrados.',
          'encabezados': ['Uso', 'Conteo', 'Porcentaje'],
          'filas': filasUsos,
          'metadatos': {
            'totalRegistros': totalUsosRegistrados,
            'tiposDistintos': estadisticasUsos.length,
          },
        });
      }
    }
  }

  // 🏔️ TABLA 2: Topografía (CORREGIDA)
  if (datosEstadisticos.containsKey('topografia') && 
      datosEstadisticos['topografia']['estadisticas'] != null) {
    
    Map<String, Map<String, dynamic>> estadisticasTopografia =
        datosEstadisticos['topografia']['estadisticas'];

    if (estadisticasTopografia.isNotEmpty) {
      List<List<dynamic>> filasTopografia = [];

      // ✅ CALCULAR TOTAL CORRECTO: Suma de todos los conteos de topografía
      int totalTopografiaRegistrada = estadisticasTopografia.values
          .fold(0, (sum, stats) => sum + (stats['conteo'] as int? ?? 0));

      // 🗻 Procesar cada tipo de topografía con cálculos corregidos
      estadisticasTopografia.forEach((tipo, estadisticas) {
        int conteo = estadisticas['conteo'] as int? ?? 0;
        
        if (conteo > 0) {
          // ✅ PORCENTAJE CORRECTO: conteo / total de topografías registradas
          double porcentajeRelativo = totalTopografiaRegistrada > 0 
              ? (conteo / totalTopografiaRegistrada) * 100 
              : 0.0;

          // 📈 También calculamos porcentaje absoluto si está disponible
          double porcentajeAbsoluto = estadisticas.containsKey('porcentajeAbsoluto')
              ? (estadisticas['porcentajeAbsoluto'] as double? ?? 0.0)
              : porcentajeRelativo;

          filasTopografia.add([
            tipo,
            conteo,
            '${porcentajeRelativo.toStringAsFixed(2)}%',
          ]);
        }
      });

      // 📊 Ordenar por frecuencia (descendente)
      filasTopografia.sort((a, b) => (b[1] as int).compareTo(a[1] as int));

      // 🏔️ Agregar tabla con información contextual
      if (filasTopografia.isNotEmpty) {
        tablas.add({
          'titulo': 'Topografía',
          'descripcion': 'Distribución de los tipos de topografía en los formatos analizados. Total de registros topográficos: $totalTopografiaRegistrada.',
          'encabezados': ['Tipo de Topografía', 'Conteo', 'Porcentaje'],
          'filas': filasTopografia,
          'metadatos': {
            'totalRegistros': totalTopografiaRegistrada,
            'tiposDistintos': estadisticasTopografia.length,
          },
        });
      }
    }
  }

  // 📊 TABLA 3: Resumen comparativo (NUEVA - valor agregado)
  if (tablas.length >= 2) {
    // Extraer datos de las tablas anteriores para crear un resumen
    var tablaUsos = tablas.firstWhere((t) => t['titulo'] == 'Uso de Vivienda', 
        orElse: () => {});
    var tablaTopografia = tablas.firstWhere((t) => t['titulo'] == 'Topografía', 
        orElse: () => {});

    List<List<dynamic>> filasResumen = [];

    // Añadir métricas comparativas
    if (tablaUsos.isNotEmpty && tablaUsos['metadatos'] != null) {
      filasResumen.add([
        'Tipos de uso identificados',
        tablaUsos['metadatos']['tiposDistintos'],
        'Diversidad de uso',
      ]);
      filasResumen.add([
        'Total registros de uso',
        tablaUsos['metadatos']['totalRegistros'],
        'Algunos inmuebles pueden tener múltiples usos',
      ]);
    }

    if (tablaTopografia.isNotEmpty && tablaTopografia['metadatos'] != null) {
      filasResumen.add([
        'Tipos de topografía identificados',
        tablaTopografia['metadatos']['tiposDistintos'],
        'Variedad geográfica',
      ]);
      filasResumen.add([
        'Total registros topográficos',
        tablaTopografia['metadatos']['totalRegistros'],
        'Características del terreno',
      ]);
    }

    // Calcular índice de diversidad si tenemos datos
    if (tablaUsos.isNotEmpty && tablaTopografia.isNotEmpty) {
      int totalUsos = tablaUsos['metadatos']?['tiposDistintos'] ?? 0;
      int totalTopografia = tablaTopografia['metadatos']?['tiposDistintos'] ?? 0;
      double indiceDiversidad = (totalUsos + totalTopografia) / 2.0;
      
      filasResumen.add([
        'Índice de diversidad promedio',
        indiceDiversidad.toStringAsFixed(1),
        indiceDiversidad > 5 ? 'Alta diversidad' : 'Diversidad moderada',
      ]);
    }

    if (filasResumen.isNotEmpty) {
      tablas.add({
        'titulo': 'Resumen Comparativo',
        'descripcion': 'Métricas comparativas entre uso de vivienda y topografía.',
        'encabezados': ['Métrica', 'Valor', 'Interpretación'],
        'filas': filasResumen,
      });
    }
  }

  return tablas;
}

  /// Genera gráficas para el reporte de uso y topografía
  Future<List<Uint8List>> _generarGraficasReporte(
      Map<String, dynamic> datosEstadisticos) async {
    List<Uint8List> graficas = [];

    // Verificar si hay datos de uso de vivienda
    if (datosEstadisticos.containsKey('usosVivienda') &&
        datosEstadisticos['usosVivienda'].containsKey('estadisticas') &&
        datosEstadisticos['usosVivienda']['estadisticas'].isNotEmpty) {
      graficas.add(Uint8List(0)); // Placeholder vacío
    }

    // Verificar si hay datos de topografía
    if (datosEstadisticos.containsKey('topografia') &&
        datosEstadisticos['topografia'].containsKey('estadisticas') &&
        datosEstadisticos['topografia']['estadisticas'].isNotEmpty) {
      graficas.add(Uint8List(0)); // Placeholder vacío
    }

    return graficas;
  }

  /// Genera conclusiones para el reporte de uso y topografía
  String _generarConclusiones(
      Map<String, dynamic> datosEstadisticos, int totalFormatos) {
    StringBuffer conclusiones = StringBuffer();

    conclusiones.writeln(
        'Se analizaron un total de $totalFormatos formatos de evaluación.');

    // Análisis de uso de vivienda
    Map<String, Map<String, dynamic>> estadisticasUsos =
        datosEstadisticos['usosVivienda']['estadisticas'];

    if (estadisticasUsos.isNotEmpty) {
      // Encontrar el uso más común
      String? usoMasComun;
      int maxConteoUso = 0;

      estadisticasUsos.forEach((uso, estadisticas) {
        if (estadisticas['conteo'] > maxConteoUso) {
          maxConteoUso = estadisticas['conteo'];
          usoMasComun = uso;
        }
      });

      if (usoMasComun != null) {
        double porcentajeUsoComun = (maxConteoUso / totalFormatos) * 100;
        conclusiones.writeln(
            '\nEl uso más común fue "$usoMasComun" con $maxConteoUso ocurrencias (${porcentajeUsoComun.toStringAsFixed(2)}% del total).');
      }
    }

    // Análisis de topografía
    Map<String, Map<String, dynamic>> estadisticasTopografia =
        datosEstadisticos['topografia']['estadisticas'];

    if (estadisticasTopografia.isNotEmpty) {
      // Encontrar la topografía más común
      String? topografiaMasComun;
      int maxConteoTopografia = 0;

      estadisticasTopografia.forEach((tipo, estadisticas) {
        if (estadisticas['conteo'] > maxConteoTopografia) {
          maxConteoTopografia = estadisticas['conteo'];
          topografiaMasComun = tipo;
        }
      });

      if (topografiaMasComun != null) {
        double porcentajeTopografiaComun =
            (maxConteoTopografia / totalFormatos) * 100;
        conclusiones.writeln(
            '\nLa topografía más común fue "$topografiaMasComun" con $maxConteoTopografia ocurrencias (${porcentajeTopografiaComun.toStringAsFixed(2)}% del total).');
      }
    }

    conclusiones.writeln(
        '\nEste reporte proporciona una visión general de los patrones de uso y la distribución topográfica de los inmuebles evaluados en el período seleccionado.');

    return conclusiones.toString();
  }

  // Métodos para el reporte de Resumen General

  /// Analiza la distribución geográfica de los formatos
  Map<String, dynamic> _analizarDistribucionGeografica(
      List<FormatoEvaluacion> formatos) {
    // Mapas para almacenar conteos por ubicación geográfica
    Map<String, int> conteoColonias = {};
    Map<String, int> conteoCiudades = {};
    Map<String, int> conteoMunicipios = {};
    Map<String, int> conteoEstados = {};

    // Para cada formato, contar las ubicaciones
    for (var formato in formatos) {
      // Obtener datos de ubicación
      String colonia = formato.informacionGeneral.colonia;
      String ciudad = formato.informacionGeneral.ciudadPueblo;
      String municipio = formato.informacionGeneral.delegacionMunicipio;
      String estado = formato.informacionGeneral.estado;

      // Incrementar contadores
      if (colonia.isNotEmpty) {
        conteoColonias[colonia] = (conteoColonias[colonia] ?? 0) + 1;
      }

      if (ciudad.isNotEmpty) {
        conteoCiudades[ciudad] = (conteoCiudades[ciudad] ?? 0) + 1;
      }

      if (municipio.isNotEmpty) {
        conteoMunicipios[municipio] = (conteoMunicipios[municipio] ?? 0) + 1;
      }

      if (estado.isNotEmpty) {
        conteoEstados[estado] = (conteoEstados[estado] ?? 0) + 1;
      }
    }

    // Agrupar por periodos (meses)
    Map<String, int> conteoPorMes = {};

    for (var formato in formatos) {
      // Formato MM/yyyy - ejemplo: "05/2025"
      String mesAnio = DateFormat('MM/yyyy').format(formato.fechaCreacion);
      conteoPorMes[mesAnio] = (conteoPorMes[mesAnio] ?? 0) + 1;
    }

    return {
      'distribucionGeografica': {
        'colonias': conteoColonias,
        'ciudades': conteoCiudades,
        'municipios': conteoMunicipios,
        'estados': conteoEstados,
      },
      'distribucionTemporal': {
        'meses': conteoPorMes,
      }
    };
  }

  /// Preparar tablas para el resumen general
  static List<Map<String, dynamic>> _prepararTablasResumenGeneral(
    Map<String, dynamic> datosEstadisticos,
    List<FormatoEvaluacion> formatos) {
  
  List<Map<String, dynamic>> tablas = [];

  // Tabla 1: Resumen total
  tablas.add({
    'titulo': 'Resumen Total de Evaluaciones',
    'descripcion': 'Cantidad total de inmuebles evaluados en el período seleccionado.',
    'encabezados': ['Descripción', 'Cantidad'],
    'filas': [
      ['Total de inmuebles evaluados', formatos.length],
    ],
  });

  // Tabla 2: Distribución por ciudades (CORREGIDA)
  Map<String, int> conteoCiudades =
      datosEstadisticos['distribucionGeografica']['ciudades'];

  if (conteoCiudades.isNotEmpty) {
    List<List<dynamic>> filasCiudades = [];
    
    // ✅ TOTAL CORRECTO: Suma de todos los conteos (total de formatos)
    int totalFormatos = formatos.length;

    conteoCiudades.forEach((ciudad, conteo) {
      // ✅ PORCENTAJE CORRECTO: conteo / total de formatos
      double porcentaje = totalFormatos > 0 
          ? (conteo / totalFormatos) * 100 
          : 0.0;
      
      filasCiudades.add([
        ciudad,
        conteo,
        '${porcentaje.toStringAsFixed(2)}%',
      ]);
    });

    // 📈 Ordenar por frecuencia (descendente) para mejor visualización
    filasCiudades.sort((a, b) => (b[1] as int).compareTo(a[1] as int));

    tablas.add({
      'titulo': 'Distribución por Ciudades',
      'descripcion': 'Cantidad de inmuebles evaluados por ciudad.',
      'encabezados': ['Ciudad', 'Cantidad', 'Porcentaje'],
      'filas': filasCiudades,
    });
  }

  // 🏘️ Tabla 3: Distribución por colonias (CORREGIDA Y OPTIMIZADA)
  Map<String, int> conteoColonias =
      datosEstadisticos['distribucionGeografica']['colonias'];

  if (conteoColonias.isNotEmpty) {
    List<List<dynamic>> filasColonias = [];
    
    // ✅ TOTAL CORRECTO: Total de formatos analizados
    int totalFormatos = formatos.length;

    conteoColonias.forEach((colonia, conteo) {
      // ✅ PORCENTAJE CORRECTO: conteo / total de formatos
      double porcentaje = totalFormatos > 0 
          ? (conteo / totalFormatos) * 100 
          : 0.0;
      
      filasColonias.add([
        colonia,
        conteo,
        '${porcentaje.toStringAsFixed(2)}%',
      ]);
    });

    // 📊 Ordenar por frecuencia (descendente)
    filasColonias.sort((a, b) => (b[1] as int).compareTo(a[1] as int));

    // 🔝 Limitar a las 10 más frecuentes para optimizar visualización
    if (filasColonias.length > 10) {
      // Calcular el total de las colonias restantes
      int conteoRestantes = 0;
      for (int i = 10; i < filasColonias.length; i++) {
        conteoRestantes += filasColonias[i][1] as int;
      }
      
      // Truncar la lista a 10 elementos
      filasColonias = filasColonias.sublist(0, 10);
      
      // Agregar fila de "Otras colonias" si hay más de 10
      if (conteoRestantes > 0) {
        double porcentajeRestantes = totalFormatos > 0 
            ? (conteoRestantes / totalFormatos) * 100 
            : 0.0;
        
        filasColonias.add([
          'Otras ${conteoColonias.length - 10} colonias',
          conteoRestantes,
          '${porcentajeRestantes.toStringAsFixed(2)}%',
        ]);
      }
    }

    tablas.add({
      'titulo': 'Distribución por Colonias (Top 10)',
      'descripcion': 'Las 10 colonias con mayor cantidad de inmuebles evaluados.',
      'encabezados': ['Colonia', 'Cantidad', 'Porcentaje'],
      'filas': filasColonias,
    });
  }

  // 📅 Tabla 4: Distribución temporal (BONUS - también corregida)
  if (datosEstadisticos.containsKey('distribucionTemporal')) {
    Map<String, int> conteoPorMes = 
        datosEstadisticos['distribucionTemporal']['meses'];
    
    if (conteoPorMes.isNotEmpty) {
      List<List<dynamic>> filasMeses = [];
      int totalFormatos = formatos.length;

      conteoPorMes.forEach((mes, conteo) {
        // ✅ PORCENTAJE CORRECTO para distribución temporal
        double porcentaje = totalFormatos > 0 
            ? (conteo / totalFormatos) * 100 
            : 0.0;
        
        filasMeses.add([
          mes,
          conteo,
          '${porcentaje.toStringAsFixed(2)}%',
        ]);
      });

      // Ordenar cronológicamente
      filasMeses.sort((a, b) {
        try {
          final fechaA = DateFormat('MM/yyyy').parse(a[0]);
          final fechaB = DateFormat('MM/yyyy').parse(b[0]);
          return fechaA.compareTo(fechaB);
        } catch (e) {
          return (a[0] as String).compareTo(b[0] as String);
        }
      });

      tablas.add({
        'titulo': 'Distribución Temporal',
        'descripcion': 'Cantidad de inmuebles evaluados por mes.',
        'encabezados': ['Período', 'Cantidad', 'Porcentaje'],
        'filas': filasMeses,
      });
    }
  }

  return tablas;
}

  /// Generar gráficas para el resumen general
  Future<List<Uint8List>> _generarGraficasResumenGeneral(
      Map<String, dynamic> datosEstadisticos) async {
    List<Uint8List> graficas = [];

    // Placeholder para gráfica de distribución por ciudades
    if (datosEstadisticos['distribucionGeografica']['ciudades'].isNotEmpty) {
      graficas.add(Uint8List(0));
    }

    // Placeholder para gráfica de distribución por colonia
    if (datosEstadisticos['distribucionGeografica']['colonias'].isNotEmpty) {
      graficas.add(Uint8List(0));
    }

    return graficas;
  }

  /// Obtener las áreas geográficas cubiertas por las evaluaciones
  String _obtenerAreasGeograficas(List<FormatoEvaluacion> formatos) {
    // Extraer conjuntos únicos de ubicaciones
    Set<String> colonias = {};
    Set<String> ciudades = {};
    Set<String> municipios = {};

    for (var formato in formatos) {
      String colonia = formato.informacionGeneral.colonia;
      String ciudad = formato.informacionGeneral.ciudadPueblo;
      String municipio = formato.informacionGeneral.delegacionMunicipio;

      if (colonia.isNotEmpty) colonias.add(colonia);
      if (ciudad.isNotEmpty) ciudades.add(ciudad);
      if (municipio.isNotEmpty) municipios.add(municipio);
    }

    // Construir una cadena que describa las áreas cubiertas
    StringBuffer areas = StringBuffer();

    if (colonias.isNotEmpty) {
      areas.write('Colonias: ${colonias.join(", ")}');
    }

    if (ciudades.isNotEmpty) {
      if (areas.isNotEmpty) areas.write('\n');
      areas.write('Ciudades: ${ciudades.join(", ")}');
    }

    if (municipios.isNotEmpty) {
      if (areas.isNotEmpty) areas.write('\n');
      areas.write('Municipios: ${municipios.join(", ")}');
    }

    return areas.toString();
  }

  /// Generar conclusiones para el resumen general
  String _generarConclusionesResumenGeneral(
      Map<String, dynamic> datosEstadisticos,
      List<FormatoEvaluacion> formatos) {
    StringBuffer conclusiones = StringBuffer();

    // Información general
    conclusiones.writeln(
        'Se analizaron un total de ${formatos.length} inmuebles en el período seleccionado.');

    // Distribución geográfica
    Map<String, int> conteoCiudades =
        datosEstadisticos['distribucionGeografica']['ciudades'];
    if (conteoCiudades.isNotEmpty) {
      // Encontrar la ciudad con más evaluaciones
      String? ciudadPrincipal;
      int maxCiudad = 0;

      conteoCiudades.forEach((ciudad, conteo) {
        if (conteo > maxCiudad) {
          maxCiudad = conteo;
          ciudadPrincipal = ciudad;
        }
      });

      if (ciudadPrincipal != null) {
        double porcentajeCiudad = (maxCiudad / formatos.length) * 100;
        conclusiones.writeln(
            '\nLa ciudad con mayor cantidad de evaluaciones fue "$ciudadPrincipal" con $maxCiudad inmuebles (${porcentajeCiudad.toStringAsFixed(2)}% del total).');
      }
    }

    // Distribución temporal
    Map<String, int> conteoPorMes =
        datosEstadisticos['distribucionTemporal']['meses'];
    if (conteoPorMes.isNotEmpty) {
      // Encontrar el mes con más evaluaciones
      String? mesPrincipal;
      int maxMes = 0;

      conteoPorMes.forEach((mes, conteo) {
        if (conteo > maxMes) {
          maxMes = conteo;
          mesPrincipal = mes;
        }
      });

      if (mesPrincipal != null) {
        double porcentajeMes = (maxMes / formatos.length) * 100;
        conclusiones.writeln(
            '\nEl mes con mayor actividad de evaluaciones fue "$mesPrincipal" con $maxMes inmuebles evaluados (${porcentajeMes.toStringAsFixed(2)}% del total).');
      }
    }

    conclusiones.writeln(
        '\nEste resumen proporciona una visión general de la distribución geográfica y temporal de las evaluaciones realizadas.');

    return conclusiones.toString();
  }
}
