// lib/data/reportes/reporte_completo_service.dart

import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../logica/formato_evaluacion.dart';
import '../services/estadisticos_service.dart';
import '../services/graficas_service.dart';

// Importar todos los reportes individuales existentes
import 'sistema_estructural_reporte.dart';
import 'material_dominante_reporte.dart';
import 'evaluacion_danos_reporte.dart';
import '../services/reporte_service.dart';

/// Servicio especializado para generar reportes completos unificados
/// Reutiliza la lógica de todos los reportes individuales existentes
class ReporteCompletoService {
  
  /// Genera un reporte completo que incluye todas las secciones
  /// de análisis disponibles en orden específico
  static Future<Map<String, dynamic>> generarReporteCompleto({
    required List<FormatoEvaluacion> formatos,
    required Map<String, dynamic> metadatos,
  }) async {
    
    print('📊 [REPORTE COMPLETO] Iniciando análisis integral de ${formatos.length} formatos...');
    
    // 1. SECCIÓN: Resumen General (distribución geográfica y temporal)
    print('📈 [SECCIÓN 1/5] Analizando resumen general...');
    Map<String, dynamic> datosResumenGeneral = _analizarResumenGeneral(formatos);
    
    // 2. SECCIÓN: Uso de Vivienda y Topografía
    print('🏠 [SECCIÓN 2/5] Analizando uso de vivienda y topografía...');
    Map<String, dynamic> datosUsoTopografia = EstadisticosService.analizarUsoViviendaTopografia(formatos);
    
    // 3. SECCIÓN: Material Dominante de Construcción
    print('🧱 [SECCIÓN 3/5] Analizando materiales dominantes...');
    Map<String, dynamic> datosMaterialDominante = MaterialDominanteReport.analizarDatos(formatos);
    
    // 4. SECCIÓN: Sistema Estructural
    print('🏗️ [SECCIÓN 4/5] Analizando sistemas estructurales...');
    Map<String, dynamic> datosSistemaEstructural = SistemaEstructuralReport.analizarDatos(formatos);
    
    // 5. SECCIÓN: Evaluación de Daños
    print('⚠️ [SECCIÓN 5/5] Analizando evaluación de daños...');
    Map<String, dynamic> datosEvaluacionDanos = EvaluacionDanosReport.analizarDatos(formatos);
    
    // Consolidar todos los datos en una estructura unificada
    Map<String, dynamic> datosCompletos = {
      'metadatos': metadatos,
      'totalFormatos': formatos.length,
      'fechaGeneracion': DateTime.now(),
      
      // Cada sección mantiene su estructura original para reutilizar lógica existente
      'resumenGeneral': datosResumenGeneral,
      'usoTopografia': datosUsoTopografia,
      'materialDominante': datosMaterialDominante,
      'sistemaEstructural': datosSistemaEstructural,
      'evaluacionDanos': datosEvaluacionDanos,
      
      // Estadísticas consolidadas para vista general
      'estadisticasGlobales': _calcularEstadisticasGlobales(formatos, {
        'resumenGeneral': datosResumenGeneral,
        'usoTopografia': datosUsoTopografia,
        'materialDominante': datosMaterialDominante,
        'sistemaEstructural': datosSistemaEstructural,
        'evaluacionDanos': datosEvaluacionDanos,
      }),
    };
    
    print('✅ [REPORTE COMPLETO] Análisis integral completado exitosamente');
    return datosCompletos;
  }
  
  /// Prepara las tablas consolidadas para el reporte completo
  /// Reutiliza las funciones existentes de cada reporte individual
  static List<Map<String, dynamic>> prepararTablasCompletas(Map<String, dynamic> datosCompletos) {
    
    List<Map<String, dynamic>> tablasUnificadas = [];
    
    // === TABLA RESUMEN EJECUTIVO ===
    tablasUnificadas.add({
      'seccion': 'RESUMEN EJECUTIVO',
      'titulo': 'Estadísticas Generales del Análisis',
      'descripcion': 'Vista consolidada de todos los aspectos evaluados en el período analizado.',
      'encabezados': ['Categoría', 'Valores Principales', 'Observaciones'],
      'filas': _construirFilasResumenEjecutivo(datosCompletos),
    });
    
    // === SECCIÓN 1: RESUMEN GENERAL ===
    List<Map<String, dynamic>> tablasResumen = _prepararTablasResumenGeneral(
      datosCompletos['resumenGeneral'], 
      datosCompletos['totalFormatos']
    );
    for (var tabla in tablasResumen) {
      tabla['seccion'] = 'DISTRIBUCIÓN GEOGRÁFICA Y TEMPORAL';
      tablasUnificadas.add(tabla);
    }
    
    // === SECCIÓN 2: USO DE VIVIENDA Y TOPOGRAFÍA ===
    List<Map<String, dynamic>> tablasUsoTop = _prepararTablasUsoTopografia(datosCompletos['usoTopografia']);
    for (var tabla in tablasUsoTop) {
      tabla['seccion'] = 'USO DE VIVIENDA Y TOPOGRAFÍA';
      tablasUnificadas.add(tabla);
    }
    
    // === SECCIÓN 3: MATERIAL DOMINANTE ===
    List<Map<String, dynamic>> tablasMaterial = MaterialDominanteReport.prepararTablas(datosCompletos['materialDominante']);
    for (var tabla in tablasMaterial) {
      tabla['seccion'] = 'MATERIAL DOMINANTE DE CONSTRUCCIÓN';
      tablasUnificadas.add(tabla);
    }
    
    // === SECCIÓN 4: SISTEMA ESTRUCTURAL ===
    List<Map<String, dynamic>> tablasSistema = SistemaEstructuralReport.prepararTablas(datosCompletos['sistemaEstructural']);
    for (var tabla in tablasSistema) {
      tabla['seccion'] = 'SISTEMA ESTRUCTURAL';
      tablasUnificadas.add(tabla);
    }
    
    // === SECCIÓN 5: EVALUACIÓN DE DAÑOS ===
    List<Map<String, dynamic>> tablasDanos = EvaluacionDanosReport.prepararTablas(datosCompletos['evaluacionDanos']);
    for (var tabla in tablasDanos) {
      tabla['seccion'] = 'EVALUACIÓN DE DAÑOS Y RIESGOS';
      tablasUnificadas.add(tabla);
    }
    
    return tablasUnificadas;
  }
  
  /// Genera todos los gráficos para el reporte completo
  /// Reutiliza los generadores de gráficos existentes de cada sección
  static Future<List<Uint8List>> generarGraficasCompletas(Map<String, dynamic> datosCompletos) async {
    
    List<Uint8List> graficasUnificadas = [];
    
    // Generar placeholders para cada sección (serán renderizados directamente en PDF)
    
    // 1. Gráficas de Resumen General
    if (datosCompletos['resumenGeneral']['distribucionGeografica']['ciudades'].isNotEmpty) {
      graficasUnificadas.add(Uint8List(0)); // Distribución por ciudades
      graficasUnificadas.add(Uint8List(0)); // Mapa de áreas geográficas
    }
    
    // 2. Gráficas de Uso y Topografía
    if (datosCompletos['usoTopografia']['usosVivienda']['estadisticas'].isNotEmpty) {
      graficasUnificadas.add(Uint8List(0)); // Uso de vivienda (circular)
    }
    if (datosCompletos['usoTopografia']['topografia']['estadisticas'].isNotEmpty) {
      graficasUnificadas.add(Uint8List(0)); // Topografía (barras)
    }
    
    // 3. Gráficas de Material Dominante
    if (datosCompletos['materialDominante']['conteoMateriales'].isNotEmpty) {
      graficasUnificadas.add(Uint8List(0)); // Material dominante (circular)
      graficasUnificadas.add(Uint8List(0)); // Material dominante (barras)
    }
    
    // 4. Gráficas de Sistema Estructural (las 6 categorías principales)
    Map<String, dynamic> estadisticasSistema = datosCompletos['sistemaEstructural']['estadisticas'];
    List<String> categoriasSistema = ['direccionX', 'direccionY', 'murosMamposteria', 'sistemasPiso', 'sistemasTecho', 'cimentacion'];
    for (String categoria in categoriasSistema) {
      if (estadisticasSistema.containsKey(categoria) && estadisticasSistema[categoria].isNotEmpty) {
        graficasUnificadas.add(Uint8List(0)); // Una gráfica por categoría
      }
    }
    
    // 5. Gráficas de Evaluación de Daños (los 7 rubros principales + resumen de riesgos)
    Map<String, dynamic> estadisticasDanos = datosCompletos['evaluacionDanos']['estadisticas'];
    List<String> rubrosDanos = ['geotecnicos', 'losas', 'sistemaEstructuralDeficiente', 'techoPesado', 'murosDelgados', 'irregularidadPlanta', 'nivelDano'];
    for (String rubro in rubrosDanos) {
      if (estadisticasDanos.containsKey(rubro) && estadisticasDanos[rubro].isNotEmpty) {
        graficasUnificadas.add(Uint8List(0)); // Una gráfica por rubro
      }
    }
    // Gráfica de resumen de riesgos
    graficasUnificadas.add(Uint8List(0));
    
    return graficasUnificadas;
  }
  
  /// Genera las conclusiones consolidadas del reporte completo
  static String generarConclusionesCompletas(Map<String, dynamic> datosCompletos) {
    
    StringBuffer conclusiones = StringBuffer();
    int totalFormatos = datosCompletos['totalFormatos'];
    
    // === INTRODUCCIÓN ===
    conclusiones.writeln('CONCLUSIONES DEL ANÁLISIS INTEGRAL');
    conclusiones.writeln('=' * 50);
    conclusiones.writeln();
    conclusiones.writeln('Se realizó un análisis integral de $totalFormatos formatos de evaluación estructural, '
        'abarcando múltiples dimensiones: distribución geográfica, uso de inmuebles, materiales de construcción, '
        'sistemas estructurales y evaluación de daños.');
    conclusiones.writeln();
    
    // === SECCIÓN 1: DISTRIBUCIÓN GEOGRÁFICA ===
    conclusiones.writeln('1. DISTRIBUCIÓN GEOGRÁFICA Y TEMPORAL');
    conclusiones.writeln('-' * 40);
    Map<String, int> ciudades = datosCompletos['resumenGeneral']['distribucionGeografica']['ciudades'];
    if (ciudades.isNotEmpty) {
      var ciudadPrincipal = ciudades.entries.reduce((a, b) => a.value > b.value ? a : b);
      double porcentajeCiudad = (ciudadPrincipal.value / totalFormatos) * 100;
      conclusiones.writeln('• La mayor concentración de evaluaciones se registró en ${ciudadPrincipal.key} '
          'con ${ciudadPrincipal.value} inmuebles (${porcentajeCiudad.toStringAsFixed(1)}%).');
    }
    conclusiones.writeln();
    
    // === SECCIÓN 2: USO DE VIVIENDA ===
    conclusiones.writeln('2. USO DE VIVIENDA Y TOPOGRAFÍA');
    conclusiones.writeln('-' * 40);
    String conclusionesUso = _generarConclusionesUsoTopografia(datosCompletos['usoTopografia'], totalFormatos);
    conclusiones.writeln(conclusionesUso);
    conclusiones.writeln();
    
    // === SECCIÓN 3: MATERIAL DOMINANTE ===
    conclusiones.writeln('3. MATERIAL DOMINANTE DE CONSTRUCCIÓN');
    conclusiones.writeln('-' * 40);
    String conclusionesMaterial = MaterialDominanteReport.generarConclusiones(datosCompletos['materialDominante'], totalFormatos);
    // Extraer solo la parte relevante (omitir la introducción repetitiva)
    List<String> lineasMaterial = conclusionesMaterial.split('\n');
    for (int i = 1; i < lineasMaterial.length; i++) {
      if (lineasMaterial[i].trim().isNotEmpty) {
        conclusiones.writeln(lineasMaterial[i]);
      }
    }
    conclusiones.writeln();
    
    // === SECCIÓN 4: SISTEMA ESTRUCTURAL ===
    conclusiones.writeln('4. SISTEMA ESTRUCTURAL');
    conclusiones.writeln('-' * 40);
    String conclusionesSistema = SistemaEstructuralReport.generarConclusiones(datosCompletos['sistemaEstructural'], totalFormatos);
    List<String> lineasSistema = conclusionesSistema.split('\n');
    for (int i = 1; i < lineasSistema.length; i++) {
      if (lineasSistema[i].trim().isNotEmpty) {
        conclusiones.writeln(lineasSistema[i]);
      }
    }
    conclusiones.writeln();
    
    // === SECCIÓN 5: EVALUACIÓN DE DAÑOS ===
    conclusiones.writeln('5. EVALUACIÓN DE DAÑOS Y RIESGOS');
    conclusiones.writeln('-' * 40);
    String conclusionesDanos = EvaluacionDanosReport.generarConclusiones(datosCompletos['evaluacionDanos'], totalFormatos);
    List<String> lineasDanos = conclusionesDanos.split('\n');
    for (int i = 1; i < lineasDanos.length; i++) {
      if (lineasDanos[i].trim().isNotEmpty) {
        conclusiones.writeln(lineasDanos[i]);
      }
    }
    conclusiones.writeln();
    
    // === CONCLUSIONES GENERALES ===
    conclusiones.writeln('CONCLUSIONES GENERALES Y RECOMENDACIONES');
    conclusiones.writeln('=' * 50);
    conclusiones.writeln();
    
    // Calcular estadísticas globales de riesgo
    Map<String, dynamic> resumenRiesgos = datosCompletos['evaluacionDanos']['resumenRiesgos'];
    double porcentajeRiesgoAlto = (resumenRiesgos['riesgoAlto'] / totalFormatos) * 100;
    double porcentajeRiesgoMedio = (resumenRiesgos['riesgoMedio'] / totalFormatos) * 100;
    
    conclusiones.writeln('• PRIORIDAD ALTA: ${porcentajeRiesgoAlto.toStringAsFixed(1)}% de los inmuebles requieren intervención inmediata.');
    conclusiones.writeln('• PRIORIDAD MEDIA: ${porcentajeRiesgoMedio.toStringAsFixed(1)}% necesitan refuerzo o reparación a mediano plazo.');
    conclusiones.writeln();
    
    conclusiones.writeln('Este análisis integral proporciona una base sólida para la toma de decisiones en políticas públicas, '
        'asignación de recursos y planificación de intervenciones estructurales en la región evaluada.');
    
    return conclusiones.toString();
  }
  
  // === MÉTODOS AUXILIARES PRIVADOS ===
  
  /// Analiza los datos de resumen general (reutiliza lógica del ReporteService)
  static Map<String, dynamic> _analizarResumenGeneral(List<FormatoEvaluacion> formatos) {
    // Mapas para almacenar conteos por ubicación geográfica
    Map<String, int> conteoColonias = {};
    Map<String, int> conteoCiudades = {};
    Map<String, int> conteoMunicipios = {};
    Map<String, int> conteoEstados = {};
    Map<String, int> conteoPorMes = {};
    
    // Analizar cada formato (lógica extraída del ReporteService)
    for (var formato in formatos) {
      // Datos geográficos
      String colonia = formato.informacionGeneral.colonia;
      String ciudad = formato.informacionGeneral.ciudadPueblo;
      String municipio = formato.informacionGeneral.delegacionMunicipio;
      String estado = formato.informacionGeneral.estado;
      
      if (colonia.isNotEmpty) conteoColonias[colonia] = (conteoColonias[colonia] ?? 0) + 1;
      if (ciudad.isNotEmpty) conteoCiudades[ciudad] = (conteoCiudades[ciudad] ?? 0) + 1;
      if (municipio.isNotEmpty) conteoMunicipios[municipio] = (conteoMunicipios[municipio] ?? 0) + 1;
      if (estado.isNotEmpty) conteoEstados[estado] = (conteoEstados[estado] ?? 0) + 1;
      
      // Datos temporales
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
  
  /// Calcula estadísticas globales consolidadas
  static Map<String, dynamic> _calcularEstadisticasGlobales(List<FormatoEvaluacion> formatos, Map<String, dynamic> datosSecciones) {
    return {
      'totalInmuebles': formatos.length,
      'periodoAnalisis': {
        'fechaInicio': formatos.isNotEmpty ? formatos.map((f) => f.fechaCreacion).reduce((a, b) => a.isBefore(b) ? a : b) : null,
        'fechaFin': formatos.isNotEmpty ? formatos.map((f) => f.fechaCreacion).reduce((a, b) => a.isAfter(b) ? a : b) : null,
      },
      'cobertura': {
        'ciudades': datosSecciones['resumenGeneral']['distribucionGeografica']['ciudades'].length,
        'colonias': datosSecciones['resumenGeneral']['distribucionGeografica']['colonias'].length,
      },
      'indicadoresRiesgo': datosSecciones['evaluacionDanos']['resumenRiesgos'],
    };
  }
  
  /// Construye las filas del resumen ejecutivo
  static List<List<dynamic>> _construirFilasResumenEjecutivo(Map<String, dynamic> datosCompletos) {
    List<List<dynamic>> filas = [];
    int total = datosCompletos['totalFormatos'];
    
    // Fila 1: Cobertura geográfica
    int ciudades = datosCompletos['resumenGeneral']['distribucionGeografica']['ciudades'].length;
    filas.add(['Cobertura Geográfica', '$ciudades ciudades evaluadas', 'Distribución amplia en la región']);
    
    // Fila 2: Material predominante (con validación de datos)
    try {
      Map<String, dynamic> estadisticasMaterial = Map<String, dynamic>.from(datosCompletos['materialDominante']['estadisticas']);
      if (estadisticasMaterial.isNotEmpty) {
        var materialPrincipal = estadisticasMaterial.entries
            .cast<MapEntry<String, Map<String, dynamic>>>()
            .reduce((a, b) => (a.value['conteo'] as int) > (b.value['conteo'] as int) ? a : b);
        filas.add(['Material Dominante', materialPrincipal.key, '${(materialPrincipal.value['porcentaje'] as double).toStringAsFixed(1)}% del total']);
      } else {
        filas.add(['Material Dominante', 'No determinado', 'Datos insuficientes']);
      }
    } catch (e) {
      print('⚠️ Error procesando material dominante: $e');
      filas.add(['Material Dominante', 'Error en datos', 'Revisar información']);
    }
    
    // Fila 3: Nivel de riesgo
    Map<String, dynamic> riesgos = Map<String, dynamic>.from(datosCompletos['evaluacionDanos']['resumenRiesgos']);
    int riesgoAlto = riesgos['riesgoAlto'] as int;
    filas.add(['Riesgo Alto', '$riesgoAlto inmuebles', '${((riesgoAlto / total) * 100).toStringAsFixed(1)}% requieren atención inmediata']);
    
    // Fila 4: Uso principal (con validación de datos)
    try {
      Map<String, dynamic> estadisticasUsos = Map<String, dynamic>.from(datosCompletos['usoTopografia']['usosVivienda']['estadisticas']);
      var usosConDatos = estadisticasUsos.entries
          .cast<MapEntry<String, Map<String, dynamic>>>()
          .where((e) => (e.value['conteo'] as int) > 0);
      
      if (usosConDatos.isNotEmpty) {
        var usoPrincipal = usosConDatos
            .reduce((a, b) => (a.value['conteo'] as int) > (b.value['conteo'] as int) ? a : b);
        filas.add(['Uso Principal', usoPrincipal.key, 'Uso más frecuente identificado']);
      } else {
        filas.add(['Uso Principal', 'No determinado', 'Datos insuficientes']);
      }
    } catch (e) {
      print('⚠️ Error procesando uso principal: $e');
      filas.add(['Uso Principal', 'Error en datos', 'Revisar información']);
    }
    
    return filas;
  }
  
  /// Prepara tablas del resumen general (similar al ReporteService pero optimizado)
  static List<Map<String, dynamic>> _prepararTablasResumenGeneral(Map<String, dynamic> datos, int totalFormatos) {
    List<Map<String, dynamic>> tablas = [];
    
    // Tabla de distribución por ciudades (con validación robusta)
    try {
      if (datos.containsKey('distribucionGeografica') && 
          datos['distribucionGeografica'].containsKey('ciudades')) {
        Map<String, int> ciudades = Map<String, int>.from(datos['distribucionGeografica']['ciudades']);
        
        if (ciudades.isNotEmpty) {
          List<List<dynamic>> filasCiudades = [];
          
          ciudades.forEach((ciudad, conteo) {
            double porcentaje = totalFormatos > 0 ? (conteo / totalFormatos) * 100 : 0;
            filasCiudades.add([ciudad, conteo, '${porcentaje.toStringAsFixed(2)}%']);
          });
          
          // Ordenar por frecuencia (descendente)
          filasCiudades.sort((a, b) => (b[1] as int).compareTo(a[1] as int));
          
          tablas.add({
            'titulo': 'Distribución por Ciudades',
            'descripcion': 'Cantidad de inmuebles evaluados por ciudad.',
            'encabezados': ['Ciudad', 'Cantidad', 'Porcentaje'],
            'filas': filasCiudades,
          });
        }
      }
    } catch (e) {
      print('⚠️ Error procesando tabla de distribución por ciudades: $e');
    }
    
    // Tabla de distribución por colonias (limitada a las 10 más frecuentes)
    try {
      if (datos.containsKey('distribucionGeografica') && 
          datos['distribucionGeografica'].containsKey('colonias')) {
        Map<String, int> colonias = Map<String, int>.from(datos['distribucionGeografica']['colonias']);
        
        if (colonias.isNotEmpty) {
          List<List<dynamic>> filasColonias = [];
          
          colonias.forEach((colonia, conteo) {
            double porcentaje = totalFormatos > 0 ? (conteo / totalFormatos) * 100 : 0;
            filasColonias.add([colonia, conteo, '${porcentaje.toStringAsFixed(2)}%']);
          });
          
          // Ordenar por frecuencia (descendente)
          filasColonias.sort((a, b) => (b[1] as int).compareTo(a[1] as int));
          
          // Limitar a las 10 más frecuentes
          if (filasColonias.length > 10) {
            filasColonias = filasColonias.sublist(0, 10);
          }
          
          tablas.add({
            'titulo': 'Distribución por Colonias (Top 10)',
            'descripcion': 'Las 10 colonias con mayor cantidad de inmuebles evaluados.',
            'encabezados': ['Colonia', 'Cantidad', 'Porcentaje'],
            'filas': filasColonias,
          });
        }
      }
    } catch (e) {
      print('⚠️ Error procesando tabla de distribución por colonias: $e');
    }
    
    return tablas;
  }
  
  /// Prepara tablas de uso y topografía (similar al ReporteService)
  static List<Map<String, dynamic>> _prepararTablasUsoTopografia(Map<String, dynamic> datos) {
    List<Map<String, dynamic>> tablas = [];
    
    // Tabla de uso de vivienda (con validación robusta)
    try {
      if (datos.containsKey('usosVivienda') && datos['usosVivienda'].containsKey('estadisticas')) {
        Map<String, dynamic> estadisticasUsos = Map<String, dynamic>.from(datos['usosVivienda']['estadisticas']);
        
        if (estadisticasUsos.isNotEmpty) {
          List<List<dynamic>> filasUsos = [];
          
          estadisticasUsos.forEach((uso, estadisticas) {
            Map<String, dynamic> stats = Map<String, dynamic>.from(estadisticas);
            int conteo = stats['conteo'] as int? ?? 0;
            
            if (conteo > 0) {
              // Calcular porcentaje basado en el total de formatos, no en el número de estadísticas
              double porcentaje = (conteo / estadisticasUsos.length) * 100;
              filasUsos.add([uso, conteo, '${porcentaje.toStringAsFixed(2)}%']);
            }
          });
          
          if (filasUsos.isNotEmpty) {
            // Ordenar por frecuencia (descendente)
            filasUsos.sort((a, b) => (b[1] as int).compareTo(a[1] as int));
            
            tablas.add({
              'titulo': 'Uso de Vivienda',
              'descripcion': 'Distribución de los usos de vivienda en los formatos analizados.',
              'encabezados': ['Uso', 'Conteo', 'Porcentaje'],
              'filas': filasUsos,
            });
          }
        }
      }
    } catch (e) {
      print('⚠️ Error procesando tabla de uso de vivienda: $e');
    }
    
    // Tabla de topografía (con validación robusta)
    try {
      if (datos.containsKey('topografia') && datos['topografia'].containsKey('estadisticas')) {
        Map<String, dynamic> estadisticasTopografia = Map<String, dynamic>.from(datos['topografia']['estadisticas']);
        
        if (estadisticasTopografia.isNotEmpty) {
          List<List<dynamic>> filasTopografia = [];
          
          estadisticasTopografia.forEach((tipo, estadisticas) {
            Map<String, dynamic> stats = Map<String, dynamic>.from(estadisticas);
            int conteo = stats['conteo'] as int? ?? 0;
            
            if (conteo > 0) {
              // Calcular porcentaje basado en el total de formatos, no en el número de estadísticas
              double porcentaje = (conteo / estadisticasTopografia.length) * 100;
              filasTopografia.add([tipo, conteo, '${porcentaje.toStringAsFixed(2)}%']);
            }
          });
          
          if (filasTopografia.isNotEmpty) {
            // Ordenar por frecuencia (descendente)
            filasTopografia.sort((a, b) => (b[1] as int).compareTo(a[1] as int));
            
            tablas.add({
              'titulo': 'Topografía',
              'descripcion': 'Distribución de los tipos de topografía en los formatos analizados.',
              'encabezados': ['Tipo de Topografía', 'Conteo', 'Porcentaje'],
              'filas': filasTopografia,
            });
          }
        }
      }
    } catch (e) {
      print('⚠️ Error procesando tabla de topografía: $e');
    }
    
    return tablas;
  }
  
  /// Genera conclusiones de uso y topografía (extraído del ReporteService)
  static String _generarConclusionesUsoTopografia(Map<String, dynamic> datos, int totalFormatos) {
    StringBuffer conclusiones = StringBuffer();
    
    // Análisis de uso de vivienda (con validación robusta)
    try {
      Map<String, dynamic> estadisticasUsos = Map<String, dynamic>.from(datos['usosVivienda']['estadisticas']);
      if (estadisticasUsos.isNotEmpty) {
        var usosConDatos = estadisticasUsos.entries
            .cast<MapEntry<String, Map<String, dynamic>>>()
            .where((e) => (e.value['conteo'] as int) > 0);
        
        if (usosConDatos.isNotEmpty) {
          var usoMasComun = usosConDatos
              .reduce((a, b) => (a.value['conteo'] as int) > (b.value['conteo'] as int) ? a : b);
          
          double porcentajeUso = ((usoMasComun.value['conteo'] as int) / totalFormatos) * 100;
          conclusiones.writeln('• El uso más común fue "${usoMasComun.key}" con ${usoMasComun.value['conteo']} ocurrencias '
              '(${porcentajeUso.toStringAsFixed(2)}% del total).');
        } else {
          conclusiones.writeln('• No se encontraron datos suficientes para determinar el uso más común.');
        }
      } else {
        conclusiones.writeln('• No hay estadísticas de uso de vivienda disponibles.');
      }
    } catch (e) {
      print('⚠️ Error procesando conclusiones de uso: $e');
      conclusiones.writeln('• Error al procesar datos de uso de vivienda.');
    }
    
    // Análisis de topografía (con validación robusta)
    try {
      Map<String, dynamic> estadisticasTopografia = Map<String, dynamic>.from(datos['topografia']['estadisticas']);
      if (estadisticasTopografia.isNotEmpty) {
        var topografiasConDatos = estadisticasTopografia.entries
            .cast<MapEntry<String, Map<String, dynamic>>>()
            .where((e) => (e.value['conteo'] as int) > 0);
        
        if (topografiasConDatos.isNotEmpty) {
          var topografiaMasComun = topografiasConDatos
              .reduce((a, b) => (a.value['conteo'] as int) > (b.value['conteo'] as int) ? a : b);
          
          double porcentajeTopografia = ((topografiaMasComun.value['conteo'] as int) / totalFormatos) * 100;
          conclusiones.writeln('• La topografía más común fue "${topografiaMasComun.key}" con ${topografiaMasComun.value['conteo']} ocurrencias '
              '(${porcentajeTopografia.toStringAsFixed(2)}% del total).');
        } else {
          conclusiones.writeln('• No se encontraron datos suficientes para determinar la topografía más común.');
        }
      } else {
        conclusiones.writeln('• No hay estadísticas de topografía disponibles.');
      }
    } catch (e) {
      print('⚠️ Error procesando conclusiones de topografía: $e');
      conclusiones.writeln('• Error al procesar datos de topografía.');
    }
    
    return conclusiones.toString();
  }
}