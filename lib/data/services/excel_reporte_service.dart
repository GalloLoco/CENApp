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

  /// Genera un reporte completo de Resumen General en Excel
  /// 
  /// [datos]: Datos estadísticos del análisis
  /// [tablas]: Lista de tablas para incluir en el reporte
  /// [metadatos]: Información adicional del reporte
  /// [directorio]: Directorio donde guardar el archivo (opcional)
  /// 
  /// Retorna la ruta del archivo Excel generado
  Future<String> generarReporteResumenGeneralExcel({
    required Map<String, dynamic> datos,
    required List<Map<String, dynamic>> tablas,
    required Map<String, dynamic> metadatos,
    Directory? directorio,
  }) async {
    try {
      print('📊 [EXCEL] Iniciando generación de Resumen General en Excel...');
      
      // Crear libro de Excel con configuración optimizada
      final excel = Excel.createExcel();
      
      // Eliminar hoja por defecto si existe
      if (excel.sheets.containsKey('Sheet1')) {
        excel.delete('Sheet1');
      }
      
      // === HOJA 1: RESUMEN EJECUTIVO ===
      await _crearHojaResumenEjecutivo(excel, datos, metadatos);
      
      // === HOJA 2: DISTRIBUCIÓN GEOGRÁFICA ===
      await _crearHojaDistribucionGeografica(excel, datos, tablas);
      
      // === HOJA 3: ANÁLISIS TEMPORAL ===
      await _crearHojaAnalisisTemporal(excel, datos);
      
      // === HOJA 4: GRÁFICOS Y VISUALIZACIONES ===
      await _crearHojaGraficos(excel, datos);
      
      // === HOJA 5: DATOS RAW (para análisis adicional) ===
      await _crearHojaDatosRaw(excel, datos);
      
      // Guardar archivo Excel
      final rutaArchivo = await _guardarArchivoExcel(
        excel, 
        'ResumenGeneral_${DateTime.now().millisecondsSinceEpoch}',
        directorio
      );
      
      print('✅ [EXCEL] Reporte Resumen General Excel generado: $rutaArchivo');
      return rutaArchivo;
      
    } catch (e) {
      print('❌ [EXCEL] Error al generar reporte: $e');
      throw Exception('Error al generar reporte Excel: $e');
    }
  }

  /// Crea la hoja de Resumen Ejecutivo con métricas clave
  Future<void> _crearHojaResumenEjecutivo(
    Excel excel, 
    Map<String, dynamic> datos, 
    Map<String, dynamic> metadatos
  ) async {
    final hoja = excel['Resumen Ejecutivo'];
    int filaActual = 0;

    // === ENCABEZADO DEL REPORTE ===
    _escribirEncabezadoPrincipal(hoja, filaActual, metadatos);
    filaActual += 6; // Saltar líneas del encabezado
    
    // === MÉTRICAS CLAVE ===
    _escribirSeccionTitulo(hoja, filaActual++, 'MÉTRICAS CLAVE', 'A');
    filaActual++;
    
    // Crear tabla de métricas principales
    final metricasClave = _calcularMetricasClave(datos, metadatos);
    filaActual = _escribirTablaMetricas(hoja, filaActual, metricasClave);
    filaActual += 2;
    
    // === DISTRIBUCIÓN GEOGRÁFICA RESUMEN ===
    _escribirSeccionTitulo(hoja, filaActual++, 'COBERTURA GEOGRÁFICA', 'A');
    filaActual++;
    
    filaActual = _escribirResumenGeografico(hoja, filaActual, datos);
    filaActual += 2;
    
    // === TENDENCIAS TEMPORALES ===
    _escribirSeccionTitulo(hoja, filaActual++, 'ACTIVIDAD TEMPORAL', 'A');
    filaActual++;
    
    filaActual = _escribirResumenTemporal(hoja, filaActual, datos);
    
    // Aplicar estilos y formato final
    _aplicarEstilosResumenEjecutivo(hoja);
  }

  /// Crea la hoja de Distribución Geográfica con tablas detalladas
  Future<void> _crearHojaDistribucionGeografica(
    Excel excel, 
    Map<String, dynamic> datos, 
    List<Map<String, dynamic>> tablas
  ) async {
    final hoja = excel['Distribución Geográfica'];
    int filaActual = 0;
    
    // Encabezado de sección
    _escribirCelda(hoja, filaActual++, 0, 'ANÁLISIS DE DISTRIBUCIÓN GEOGRÁFICA');
    _aplicarEstiloTituloPrincipal(hoja, filaActual - 1, 0);
    filaActual++;
    
    // Buscar y procesar tablas geográficas
    for (var tabla in tablas) {
      if (tabla['titulo'].toString().contains('Ciudad') || 
          tabla['titulo'].toString().contains('Colonia')) {
        
        // Título de la tabla
        _escribirSeccionTitulo(hoja, filaActual++, tabla['titulo'], 'A');
        
        // Descripción
        if (tabla['descripcion'] != null) {
          _escribirCelda(hoja, filaActual++, 0, tabla['descripcion']);
          _aplicarEstiloDescripcion(hoja, filaActual - 1, 0);
        }
        filaActual++;
        
        // Escribir tabla con datos
        filaActual = _escribirTablaCompleta(
          hoja, 
          filaActual, 
          tabla['encabezados'], 
          tabla['filas']
        );
        
        // Agregar gráfico de representación textual
        filaActual = _crearGraficoTextual(
          hoja, 
          filaActual + 1, 
          tabla['filas'], 
          'Distribución ${tabla['titulo']}'
        );
        filaActual += 3;
      }
    }
    
    _aplicarEstilosDistribucionGeografica(hoja);
  }

  /// Crea la hoja de Análisis Temporal
  Future<void> _crearHojaAnalisisTemporal(
    Excel excel, 
    Map<String, dynamic> datos
  ) async {
    final hoja = excel['Análisis Temporal'];
    int filaActual = 0;
    
    _escribirCelda(hoja, filaActual++, 0, 'ANÁLISIS TEMPORAL DE EVALUACIONES');
    _aplicarEstiloTituloPrincipal(hoja, filaActual - 1, 0);
    filaActual += 2;
    
    // Verificar si hay datos temporales
    if (datos['distribucionTemporal']?['meses'] != null) {
      Map<String, int> meses = Map<String, int>.from(datos['distribucionTemporal']['meses']);
      
      if (meses.isNotEmpty) {
        // Crear tabla temporal
        _escribirSeccionTitulo(hoja, filaActual++, 'EVALUACIONES POR MES', 'A');
        filaActual++;
        
        // Convertir datos a formato de tabla
        List<List<dynamic>> filasMeses = [];
        meses.forEach((mes, cantidad) {
          filasMeses.add([mes, cantidad]);
        });
        
        // Ordenar cronológicamente
        filasMeses.sort((a, b) => _compararMeses(a[0], b[0]));
        
        // Escribir tabla
        filaActual = _escribirTablaCompleta(
          hoja, 
          filaActual, 
          ['Período', 'Evaluaciones'], 
          filasMeses
        );
        
        // Crear gráfico temporal textual
        filaActual = _crearGraficoTemporalTextual(hoja, filaActual + 2, filasMeses);
        
        // Estadísticas temporales adicionales
        filaActual += 3;
        _escribirEstadisticasTemporales(hoja, filaActual, filasMeses);
      }
    }
    
    _aplicarEstilosAnalisisTemporal(hoja);
  }

  /// Crea la hoja de Gráficos con representaciones visuales en Excel
  Future<void> _crearHojaGraficos(Excel excel, Map<String, dynamic> datos) async {
    final hoja = excel['Gráficos'];
    int filaActual = 0;
    
    _escribirCelda(hoja, filaActual++, 0, 'REPRESENTACIONES GRÁFICAS');
    _aplicarEstiloTituloPrincipal(hoja, filaActual - 1, 0);
    filaActual += 2;
    
    // === GRÁFICO 1: TOP CIUDADES ===
    if (datos['distribucionGeografica']?['ciudades'] != null) {
      Map<String, int> ciudades = Map<String, int>.from(datos['distribucionGeografica']['ciudades']);
      
      if (ciudades.isNotEmpty) {
        _escribirSeccionTitulo(hoja, filaActual++, 'TOP CIUDADES CON MÁS EVALUACIONES', 'A');
        filaActual++;
        
        // Crear gráfico de barras horizontal textual
        filaActual = _crearGraficoBarrasHorizontal(hoja, filaActual, ciudades, 'Ciudad');
        filaActual += 3;
      }
    }
    
    // === GRÁFICO 2: DISTRIBUCIÓN DE COLONIAS ===
    if (datos['distribucionGeografica']?['colonias'] != null) {
      Map<String, int> colonias = Map<String, int>.from(datos['distribucionGeografica']['colonias']);
      
      if (colonias.isNotEmpty) {
        _escribirSeccionTitulo(hoja, filaActual++, 'TOP 10 COLONIAS', 'A');
        filaActual++;
        
        // Limitar a top 10
        var coloniasOrdenadas = colonias.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));
        
        if (coloniasOrdenadas.length > 10) {
          coloniasOrdenadas = coloniasOrdenadas.sublist(0, 10);
        }
        
        Map<String, int> top10Colonias = Map.fromEntries(coloniasOrdenadas);
        
        filaActual = _crearGraficoBarrasHorizontal(hoja, filaActual, top10Colonias, 'Colonia');
        filaActual += 3;
      }
    }
    
    // === GRÁFICO 3: TENDENCIA TEMPORAL ===
    if (datos['distribucionTemporal']?['meses'] != null) {
      Map<String, int> meses = Map<String, int>.from(datos['distribucionTemporal']['meses']);
      
      if (meses.isNotEmpty) {
        _escribirSeccionTitulo(hoja, filaActual++, 'TENDENCIA TEMPORAL', 'A');
        filaActual++;
        
        filaActual = _crearGraficoLinealTemporal(hoja, filaActual, meses);
      }
    }
    
    _aplicarEstilosGraficos(hoja);
  }

  /// Crea la hoja de Datos Raw para análisis adicional
  Future<void> _crearHojaDatosRaw(Excel excel, Map<String, dynamic> datos) async {
    final hoja = excel['Datos Raw'];
    int filaActual = 0;
    
    _escribirCelda(hoja, filaActual++, 0, 'DATOS EN FORMATO BRUTO PARA ANÁLISIS');
    _aplicarEstiloTituloPrincipal(hoja, filaActual - 1, 0);
    filaActual += 2;
    
    // === DATOS GEOGRÁFICOS ===
    _escribirSeccionTitulo(hoja, filaActual++, 'DATOS GEOGRÁFICOS', 'A');
    filaActual++;
    
    // Ciudades
    if (datos['distribucionGeografica']?['ciudades'] != null) {
      _escribirCelda(hoja, filaActual++, 0, 'CIUDADES');
      _escribirCelda(hoja, filaActual, 0, 'Ciudad');
      _escribirCelda(hoja, filaActual++, 1, 'Cantidad');
      
      Map<String, int> ciudades = Map<String, int>.from(datos['distribucionGeografica']['ciudades']);
      ciudades.forEach((ciudad, cantidad) {
        _escribirCelda(hoja, filaActual, 0, ciudad);
        _escribirCelda(hoja, filaActual++, 1, cantidad);
      });
      filaActual += 2;
    }
    
    // Colonias
    if (datos['distribucionGeografica']?['colonias'] != null) {
      _escribirCelda(hoja, filaActual++, 0, 'COLONIAS');
      _escribirCelda(hoja, filaActual, 0, 'Colonia');
      _escribirCelda(hoja, filaActual++, 1, 'Cantidad');
      
      Map<String, int> colonias = Map<String, int>.from(datos['distribucionGeografica']['colonias']);
      colonias.forEach((colonia, cantidad) {
        _escribirCelda(hoja, filaActual, 0, colonia);
        _escribirCelda(hoja, filaActual++, 1, cantidad);
      });
      filaActual += 2;
    }
    
    // === DATOS TEMPORALES ===
    _escribirSeccionTitulo(hoja, filaActual++, 'DATOS TEMPORALES', 'A');
    filaActual++;
    
    if (datos['distribucionTemporal']?['meses'] != null) {
      _escribirCelda(hoja, filaActual, 0, 'Mes');
      _escribirCelda(hoja, filaActual++, 1, 'Evaluaciones');
      
      Map<String, int> meses = Map<String, int>.from(datos['distribucionTemporal']['meses']);
      meses.forEach((mes, cantidad) {
        _escribirCelda(hoja, filaActual, 0, mes);
        _escribirCelda(hoja, filaActual++, 1, cantidad);
      });
    }
    
    _aplicarEstilosDatosRaw(hoja);
  }

  // ============================================================================
  // MÉTODOS AUXILIARES PARA CÁLCULOS Y PROCESAMIENTO
  // ============================================================================

  /// Calcula métricas clave del reporte
  Map<String, dynamic> _calcularMetricasClave(
    Map<String, dynamic> datos, 
    Map<String, dynamic> metadatos
  ) {
    Map<String, dynamic> metricas = {};
    
    // Métricas básicas
    metricas['Total Inmuebles'] = metadatos['totalFormatos'] ?? 0;
    metricas['Período Análisis'] = '${metadatos['fechaInicio']} - ${metadatos['fechaFin']}';
    
    // Cobertura geográfica
    int totalCiudades = datos['distribucionGeografica']?['ciudades']?.length ?? 0;
    int totalColonias = datos['distribucionGeografica']?['colonias']?.length ?? 0;
    
    metricas['Ciudades Cubiertas'] = totalCiudades;
    metricas['Colonias Cubiertas'] = totalColonias;
    
    // Ciudad principal
    if (datos['distribucionGeografica']?['ciudades'] != null) {
      Map<String, int> ciudades = Map<String, int>.from(datos['distribucionGeografica']['ciudades']);
      if (ciudades.isNotEmpty) {
        var ciudadPrincipal = ciudades.entries.reduce((a, b) => a.value > b.value ? a : b);
        metricas['Ciudad Principal'] = '${ciudadPrincipal.key} (${ciudadPrincipal.value} inmuebles)';
      }
    }
    
    // Período más activo
    if (datos['distribucionTemporal']?['meses'] != null) {
      Map<String, int> meses = Map<String, int>.from(datos['distribucionTemporal']['meses']);
      if (meses.isNotEmpty) {
        var mesPrincipal = meses.entries.reduce((a, b) => a.value > b.value ? a : b);
        metricas['Período Más Activo'] = '${mesPrincipal.key} (${mesPrincipal.value} evaluaciones)';
      }
    }
    
    return metricas;
  }

  /// Crea un gráfico de barras horizontal textual en Excel
  int _crearGraficoBarrasHorizontal(
    Sheet hoja, 
    int filaInicial, 
    Map<String, int> datos, 
    String etiqueta
  ) {
    int filaActual = filaInicial;
    
    // Ordenar datos por valor (descendente)
    var datosOrdenados = datos.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    // Calcular valor máximo para escalar las barras
    int valorMaximo = datosOrdenados.isNotEmpty ? datosOrdenados.first.value : 1;
    
    // Encabezados
    _escribirCelda(hoja, filaActual, 0, etiqueta);
    _escribirCelda(hoja, filaActual, 1, 'Cantidad');
    _escribirCelda(hoja, filaActual, 2, 'Gráfico');
    _escribirCelda(hoja, filaActual++, 3, '%');
    
    // Aplicar estilo a encabezados
    for (int col = 0; col <= 3; col++) {
      _aplicarEstiloEncabezadoTabla(hoja, filaActual - 1, col);
    }
    
    // Datos y barras visuales
    for (var entrada in datosOrdenados.take(10)) { // Limitar a top 10
      String nombre = entrada.key;
      int valor = entrada.value;
      double porcentaje = (valor / valorMaximo) * 100;
      
      // Crear barra visual usando caracteres
      String barra = _crearBarraVisual(porcentaje);
      
      _escribirCelda(hoja, filaActual, 0, nombre);
      _escribirCelda(hoja, filaActual, 1, valor);
      _escribirCelda(hoja, filaActual, 2, barra);
      _escribirCelda(hoja, filaActual, 3, '${porcentaje.toStringAsFixed(1)}%');
      
      // Aplicar colores alternados
      if (filaActual % 2 == 0) {
        for (int col = 0; col <= 3; col++) {
          _aplicarEstiloFilaAlternada(hoja, filaActual, col);
        }
      }
      
      filaActual++;
    }
    
    return filaActual;
  }

  /// Crea un gráfico lineal temporal textual
  int _crearGraficoLinealTemporal(Sheet hoja, int filaInicial, Map<String, int> meses) {
    int filaActual = filaInicial;
    
    // Convertir y ordenar datos cronológicamente
    List<MapEntry<String, int>> datosOrdenados = meses.entries.toList();
    datosOrdenados.sort((a, b) => _compararMeses(a.key, b.key));
    
    // Encontrar valor máximo para escalar
    int valorMaximo = datosOrdenados.map((e) => e.value).reduce((a, b) => a > b ? a : b);
    
    // Encabezados
    _escribirCelda(hoja, filaActual, 0, 'Período');
    _escribirCelda(hoja, filaActual, 1, 'Evaluaciones');
    _escribirCelda(hoja, filaActual++, 2, 'Tendencia');
    
    // Datos con indicador de tendencia
    for (int i = 0; i < datosOrdenados.length; i++) {
      var entrada = datosOrdenados[i];
      String mes = entrada.key;
      int valor = entrada.value;
      
      // Calcular indicador de tendencia
      String tendencia = '';
      if (i > 0) {
        int valorAnterior = datosOrdenados[i - 1].value;
        if (valor > valorAnterior) {
          tendencia = '↗️ +${valor - valorAnterior}';
        } else if (valor < valorAnterior) {
          tendencia = '↘️ ${valor - valorAnterior}';
        } else {
          tendencia = '→ =';
        }
      } else {
        tendencia = '-- inicio';
      }
      
      _escribirCelda(hoja, filaActual, 0, mes);
      _escribirCelda(hoja, filaActual, 1, valor);
      _escribirCelda(hoja, filaActual++, 2, tendencia);
    }
    
    return filaActual;
  }

  /// Crea una barra visual usando caracteres Unicode
  String _crearBarraVisual(double porcentaje) {
    int longitudBarra = (porcentaje / 10).round(); // Cada 10% = 1 carácter
    if (longitudBarra > 10) longitudBarra = 10; // Máximo 10 caracteres
    
    return '█' * longitudBarra + '░' * (10 - longitudBarra);
  }

  /// Compara dos strings de mes/año para ordenamiento cronológico
  int _compararMeses(String mesA, String mesB) {
    try {
      // Formato esperado: MM/yyyy
      List<String> partesA = mesA.split('/');
      List<String> partesB = mesB.split('/');
      
      int anioA = int.parse(partesA[1]);
      int anioB = int.parse(partesB[1]);
      int mesNumA = int.parse(partesA[0]);
      int mesNumB = int.parse(partesB[0]);
      
      if (anioA != anioB) {
        return anioA.compareTo(anioB);
      } else {
        return mesNumA.compareTo(mesNumB);
      }
    } catch (e) {
      return mesA.compareTo(mesB); // Fallback a comparación alfabética
    }
  }

  // ============================================================================
  // MÉTODOS AUXILIARES PARA ESCRITURA Y FORMATO
  // ============================================================================

  /// Escribe el encabezado principal del reporte
  void _escribirEncabezadoPrincipal(Sheet hoja, int fila, Map<String, dynamic> metadatos) {
    _escribirCelda(hoja, fila, 0, 'REPORTE DE RESUMEN GENERAL');
    _aplicarEstiloTituloPrincipal(hoja, fila, 0);
    
    _escribirCelda(hoja, fila + 1, 0, 'Análisis de Evaluaciones Estructurales');
    _aplicarEstiloSubtitulo(hoja, fila + 1, 0);
    
    String fechaGeneracion = DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now());
    _escribirCelda(hoja, fila + 2, 0, 'Generado: $fechaGeneracion');
    
    _escribirCelda(hoja, fila + 3, 0, 'Período: ${metadatos['fechaInicio']} - ${metadatos['fechaFin']}');
    _escribirCelda(hoja, fila + 4, 0, 'Total Inmuebles: ${metadatos['totalFormatos']}');
  }

  /// Escribe una sección con título
  void _escribirSeccionTitulo(Sheet hoja, int fila, String titulo, String columna) {
    _escribirCelda(hoja, fila, _columnaToIndex(columna), titulo);
    _aplicarEstiloSeccion(hoja, fila, _columnaToIndex(columna));
  }

  /// Escribe una tabla completa con encabezados y datos
  int _escribirTablaCompleta(
    Sheet hoja, 
    int filaInicial, 
    List<String> encabezados, 
    List<List<dynamic>> filas
  ) {
    int filaActual = filaInicial;
    
    // Escribir encabezados
    for (int col = 0; col < encabezados.length; col++) {
      _escribirCelda(hoja, filaActual, col, encabezados[col]);
      _aplicarEstiloEncabezadoTabla(hoja, filaActual, col);
    }
    filaActual++;
    
    // Escribir datos
    for (var fila in filas) {
      for (int col = 0; col < fila.length && col < encabezados.length; col++) {
        _escribirCelda(hoja, filaActual, col, fila[col]);
        
        // Aplicar color alternado cada dos filas
        if (filaActual % 2 == 0) {
          _aplicarEstiloFilaAlternada(hoja, filaActual, col);
        }
      }
      filaActual++;
    }
    
    return filaActual;
  }

  /// Escribe una tabla de métricas
  int _escribirTablaMetricas(Sheet hoja, int filaInicial, Map<String, dynamic> metricas) {
    int filaActual = filaInicial;
    
    // Encabezados
    _escribirCelda(hoja, filaActual, 0, 'Métrica');
    _escribirCelda(hoja, filaActual, 1, 'Valor');
    _aplicarEstiloEncabezadoTabla(hoja, filaActual, 0);
    _aplicarEstiloEncabezadoTabla(hoja, filaActual, 1);
    filaActual++;
    
    // Métricas
    metricas.forEach((clave, valor) {
      _escribirCelda(hoja, filaActual, 0, clave);
      _escribirCelda(hoja, filaActual, 1, valor.toString());
      
      if (filaActual % 2 == 0) {
        _aplicarEstiloFilaAlternada(hoja, filaActual, 0);
        _aplicarEstiloFilaAlternada(hoja, filaActual, 1);
      }
      
      filaActual++;
    });
    
    return filaActual;
  }

  /// Escribe un resumen geográfico
  int _escribirResumenGeografico(Sheet hoja, int filaActual, Map<String, dynamic> datos) {
    if (datos['distribucionGeografica'] == null) return filaActual;
    
    Map<String, int> ciudades = Map<String, int>.from(datos['distribucionGeografica']['ciudades'] ?? {});
    Map<String, int> colonias = Map<String, int>.from(datos['distribucionGeografica']['colonias'] ?? {});
    
    _escribirCelda(hoja, filaActual++, 0, 'Ciudades evaluadas: ${ciudades.length}');
    _escribirCelda(hoja, filaActual++, 0, 'Colonias evaluadas: ${colonias.length}');
    
    if (ciudades.isNotEmpty) {
      var ciudadPrincipal = ciudades.entries.reduce((a, b) => a.value > b.value ? a : b);
      _escribirCelda(hoja, filaActual++, 0, 'Ciudad principal: ${ciudadPrincipal.key} (${ciudadPrincipal.value} inmuebles)');
    }
    
    return filaActual;
  }

  /// Escribe un resumen temporal
  int _escribirResumenTemporal(Sheet hoja, int filaActual, Map<String, dynamic> datos) {
    if (datos['distribucionTemporal']?['meses'] == null) return filaActual;
    
    Map<String, int> meses = Map<String, int>.from(datos['distribucionTemporal']['meses']);
    
    if (meses.isNotEmpty) {
      var mesPrincipal = meses.entries.reduce((a, b) => a.value > b.value ? a : b);
      int totalEvaluaciones = meses.values.fold(0, (sum, val) => sum + val);
      double promedioPorMes = totalEvaluaciones / meses.length;
      
      _escribirCelda(hoja, filaActual++, 0, 'Período más activo: ${mesPrincipal.key} (${mesPrincipal.value} evaluaciones)');
      _escribirCelda(hoja, filaActual++, 0, 'Promedio mensual: ${promedioPorMes.toStringAsFixed(1)} evaluaciones');
    }
    
    return filaActual;
  }

  /// Crea un gráfico textual simple
  int _crearGraficoTextual(
    Sheet hoja, 
    int filaInicial, 
    List<List<dynamic>> datos, 
    String titulo
  ) {
    int filaActual = filaInicial;
    
    _escribirCelda(hoja, filaActual++, 0, titulo);
    _aplicarEstiloSeccion(hoja, filaActual - 1, 0);
    filaActual++;
    
    // Tomar los primeros 5 elementos para el gráfico
    var datosLimitados = datos.take(5).toList();
    int valorMaximo = datosLimitados.isNotEmpty ? 
        datosLimitados.map((e) => e[1] as int).reduce((a, b) => a > b ? a : b) : 1;
    
    for (var fila in datosLimitados) {
      String nombre = fila[0].toString();
      int valor = fila[1] as int;
      double porcentaje = (valor / valorMaximo) * 100;
      
      String barra = _crearBarraVisual(porcentaje);
      
      _escribirCelda(hoja, filaActual, 0, nombre);
      _escribirCelda(hoja, filaActual, 1, barra);
      _escribirCelda(hoja, filaActual++, 2, valor.toString());
    }
    
    return filaActual;
  }

  /// Crea un gráfico temporal textual
  int _crearGraficoTemporalTextual(Sheet hoja, int filaInicial, List<List<dynamic>> meses) {
    int filaActual = filaInicial;
    
    _escribirCelda(hoja, filaActual++, 0, 'TENDENCIA TEMPORAL');
    _aplicarEstiloSeccion(hoja, filaActual - 1, 0);
    filaActual++;
    
    _escribirCelda(hoja, filaActual, 0, 'Mes');
    _escribirCelda(hoja, filaActual, 1, 'Evaluaciones');
    _escribirCelda(hoja, filaActual++, 2, 'Gráfico');
    
    int valorMaximo = meses.isNotEmpty ? 
        meses.map((e) => e[1] as int).reduce((a, b) => a > b ? a : b) : 1;
    
    for (var fila in meses) {
      String mes = fila[0].toString();
      int valor = fila[1] as int;
      double porcentaje = (valor / valorMaximo) * 100;
      
      String barra = _crearBarraVisual(porcentaje);
      
      _escribirCelda(hoja, filaActual, 0, mes);
      _escribirCelda(hoja, filaActual, 1, valor);
      _escribirCelda(hoja, filaActual++, 2, barra);
    }
    
    return filaActual;
  }

  /// Escribe estadísticas temporales adicionales
  void _escribirEstadisticasTemporales(Sheet hoja, int filaInicial, List<List<dynamic>> meses) {
    int filaActual = filaInicial;
    
    if (meses.isEmpty) return;
    
    _escribirSeccionTitulo(hoja, filaActual++, 'ESTADÍSTICAS TEMPORALES', 'A');
    filaActual++;
    
    // Calcular estadísticas
    List<int> valores = meses.map((e) => e[1] as int).toList();
    int total = valores.fold(0, (sum, val) => sum + val);
    double promedio = total / valores.length;
    int maximo = valores.reduce((a, b) => a > b ? a : b);
    int minimo = valores.reduce((a, b) => a < b ? a : b);
    
    _escribirCelda(hoja, filaActual++, 0, 'Total evaluaciones: $total');
    _escribirCelda(hoja, filaActual++, 0, 'Promedio mensual: ${promedio.toStringAsFixed(1)}');
    _escribirCelda(hoja, filaActual++, 0, 'Mes más activo: $maximo evaluaciones');
    _escribirCelda(hoja, filaActual++, 0, 'Mes menos activo: $minimo evaluaciones');
  }

  // ============================================================================
  // MÉTODOS AUXILIARES PARA ESTILOS Y FORMATO
  // ============================================================================

  /// Convierte letra de columna a índice numérico
  int _columnaToIndex(String columna) {
    return columna.toUpperCase().codeUnitAt(0) - 'A'.codeUnitAt(0);
  }

  /// Escribe una celda con manejo de errores
  void _escribirCelda(Sheet hoja, int fila, int columna, dynamic valor) {
    try {
      final celda = CellIndex.indexByColumnRow(columnIndex: columna, rowIndex: fila);
      
      if (valor is String) {
        hoja.cell(celda).value = TextCellValue(valor);
      } else if (valor is int) {
        hoja.cell(celda).value = IntCellValue(valor);
      } else if (valor is double) {
        hoja.cell(celda).value = DoubleCellValue(valor);
      } else {
        hoja.cell(celda).value = TextCellValue(valor.toString());
      }
    } catch (e) {
      print('⚠️ Error escribiendo celda ($fila,$columna): $e');
    }
  }

  /// Aplica estilo de título principal
  void _aplicarEstiloTituloPrincipal(Sheet hoja, int fila, int columna) {
    try {
      final celda = CellIndex.indexByColumnRow(columnIndex: columna, rowIndex: fila);
      hoja.cell(celda).cellStyle = CellStyle(
        bold: true,
        fontSize: 16,
        fontFamily: getFontFamily(FontFamily.Arial),
        horizontalAlign: HorizontalAlign.Center,
        backgroundColorHex: ExcelColor.blue,
        fontColorHex: ExcelColor.white,
      );
    } catch (e) {
      print('⚠️ Error aplicando estilo título: $e');
    }
  }

  /// Aplica estilo de subtítulo
  void _aplicarEstiloSubtitulo(Sheet hoja, int fila, int columna) {
    try {
      final celda = CellIndex.indexByColumnRow(columnIndex: columna, rowIndex: fila);
      hoja.cell(celda).cellStyle = CellStyle(
        bold: true,
        fontSize: 12,
        fontFamily: getFontFamily(FontFamily.Arial),
        horizontalAlign: HorizontalAlign.Center,
        fontColorHex: ExcelColor.blue,
      );
    } catch (e) {
      print('⚠️ Error aplicando estilo subtítulo: $e');
    }
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

  /// Aplica estilo de encabezado de tabla
  void _aplicarEstiloEncabezadoTabla(Sheet hoja, int fila, int columna) {
    try {
      final celda = CellIndex.indexByColumnRow(columnIndex: columna, rowIndex: fila);
      hoja.cell(celda).cellStyle = CellStyle(
        bold: true,
        fontSize: 10,
        fontFamily: getFontFamily(FontFamily.Arial),
        backgroundColorHex: ExcelColor.grey100,
        fontColorHex: ExcelColor.black,
        horizontalAlign: HorizontalAlign.Center,
      );
    } catch (e) {
      print('⚠️ Error aplicando estilo encabezado tabla: $e');
    }
  }

  /// Aplica estilo de fila alternada
  void _aplicarEstiloFilaAlternada(Sheet hoja, int fila, int columna) {
    try {
      final celda = CellIndex.indexByColumnRow(columnIndex: columna, rowIndex: fila);
      hoja.cell(celda).cellStyle = CellStyle(
        fontSize: 9,
        fontFamily: getFontFamily(FontFamily.Arial),
        backgroundColorHex: ExcelColor.grey200,
      );
    } catch (e) {
      print('⚠️ Error aplicando estilo fila alternada: $e');
    }
  }

  /// Aplica estilo de descripción
  void _aplicarEstiloDescripcion(Sheet hoja, int fila, int columna) {
    try {
      final celda = CellIndex.indexByColumnRow(columnIndex: columna, rowIndex: fila);
      hoja.cell(celda).cellStyle = CellStyle(
        fontSize: 9,
        fontFamily: getFontFamily(FontFamily.Arial),
        fontColorHex: ExcelColor.grey,
        italic: true,
      );
    } catch (e) {
      print('⚠️ Error aplicando estilo descripción: $e');
    }
  }

  /// Aplica estilos específicos para cada hoja
  void _aplicarEstilosResumenEjecutivo(Sheet hoja) {
    // Ajustar ancho de columnas
    try {
      hoja.setColumnWidth(0, 25.0); // Columna A
      hoja.setColumnWidth(1, 35.0); // Columna B
      hoja.setColumnWidth(2, 15.0); // Columna C
    } catch (e) {
      print('⚠️ Error ajustando ancho columnas resumen: $e');
    }
  }

  void _aplicarEstilosDistribucionGeografica(Sheet hoja) {
    try {
      hoja.setColumnWidth(0, 30.0); // Nombres de lugares
      hoja.setColumnWidth(1, 12.0); // Cantidades
      hoja.setColumnWidth(2, 20.0); // Gráficos
      hoja.setColumnWidth(3, 12.0); // Porcentajes
    } catch (e) {
      print('⚠️ Error ajustando ancho columnas geográficas: $e');
    }
  }

  void _aplicarEstilosAnalisisTemporal(Sheet hoja) {
    try {
      hoja.setColumnWidth(0, 15.0); // Períodos
      hoja.setColumnWidth(1, 15.0); // Cantidades
      hoja.setColumnWidth(2, 25.0); // Tendencias/Gráficos
    } catch (e) {
      print('⚠️ Error ajustando ancho columnas temporales: $e');
    }
  }

  void _aplicarEstilosGraficos(Sheet hoja) {
    try {
      hoja.setColumnWidth(0, 25.0); // Etiquetas
      hoja.setColumnWidth(1, 12.0); // Valores
      hoja.setColumnWidth(2, 30.0); // Barras visuales
      hoja.setColumnWidth(3, 12.0); // Porcentajes
    } catch (e) {
      print('⚠️ Error ajustando ancho columnas gráficos: $e');
    }
  }

  void _aplicarEstilosDatosRaw(Sheet hoja) {
    try {
      hoja.setColumnWidth(0, 30.0); // Nombres/Etiquetas
      hoja.setColumnWidth(1, 15.0); // Valores
    } catch (e) {
      print('⚠️ Error ajustando ancho columnas datos raw: $e');
    }
  }

  // ============================================================================
  // MÉTODOS AUXILIARES PARA GUARDADO
  // ============================================================================

  /// Guarda el archivo Excel en el directorio especificado
  Future<String> _guardarArchivoExcel(
    Excel excel, 
    String nombreBase, 
    Directory? directorio
  ) async {
    try {
      // Obtener directorio final
      final directorioFinal = directorio ?? await _fileService.obtenerDirectorioDescargas();
      
      // Crear subdirectorio para reportes si no existe
      final directorioReportes = Directory('${directorioFinal.path}/cenapp/reportes');
      if (!await directorioReportes.exists()) {
        await directorioReportes.create(recursive: true);
      }
      
      // Generar nombre de archivo único
      final nombreArchivo = '$nombreBase.xlsx';
      final rutaArchivo = '${directorioReportes.path}/$nombreArchivo';
      
      // Generar bytes del Excel
      final List<int>? bytes = excel.save();
      if (bytes == null) {
        throw Exception('Error al generar bytes del archivo Excel');
      }
      
      // Guardar archivo
      final archivo = File(rutaArchivo);
      await archivo.writeAsBytes(bytes);
      
      // Verificar que el archivo se guardó correctamente
      if (!await archivo.exists() || await archivo.length() == 0) {
        throw Exception('El archivo Excel no se guardó correctamente');
      }
      
      print('✅ [EXCEL] Archivo guardado exitosamente: $rutaArchivo');
      return rutaArchivo;
      
    } catch (e) {
      print('❌ [EXCEL] Error al guardar archivo: $e');
      throw Exception('Error al guardar archivo Excel: $e');
    }
  }
}