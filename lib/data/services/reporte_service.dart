// lib/data/services/reporte_service.dart

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../logica/formato_evaluacion.dart';
import '../../data/services/cloud_storage_service.dart';
import '../../data/services/estadisticos_service.dart';
import '../../data/services/graficas_service.dart';
import '../../data/services/reporte_documental_service.dart';

class ReporteService {
  final CloudStorageService _cloudService = CloudStorageService();
  
  /// Genera un reporte de uso de vivienda y topografía
  Future<Map<String, String>> generarReporteUsoViviendaTopografia({
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
      throw Exception('No se encontraron formatos que cumplan con los criterios especificados');
    }
    
    // Paso 2: Analizar los datos para generar estadísticas
    Map<String, dynamic> datosEstadisticos = EstadisticosService.analizarUsoViviendaTopografia(formatos);
    
    // Paso 3: Preparar datos para las tablas del reporte
    List<Map<String, dynamic>> tablas = _prepararTablasParaReporte(datosEstadisticos);
    
    // Paso 4: Generar gráficas
    List<Uint8List> graficas = await _generarGraficasReporte(datosEstadisticos);
    
    // Paso 5: Construir metadatos para el reporte
    Map<String, dynamic> metadatos = {
      'totalFormatos': formatos.length,
      'nombreInmueble': nombreInmueble.isEmpty ? 'Todos' : nombreInmueble,
      'fechaInicio': DateFormat('dd/MM/yyyy').format(fechaInicio),
      'fechaFin': DateFormat('dd/MM/yyyy').format(fechaFin),
      'usuarioCreador': usuarioCreador.isEmpty ? 'Todos' : usuarioCreador,
      'ubicaciones': ubicaciones,
      'conclusiones': _generarConclusiones(datosEstadisticos, formatos.length),
    };
    
    // Paso 6: Generar documentos PDF y DOCX
    String rutaPDF = await ReporteDocumentalService.generarReportePDF(
      titulo: 'Reporte Estadístico',
      subtitulo: 'Uso de Vivienda y Topografía',
      datos: datosEstadisticos,
      tablas: tablas,
      graficas: graficas,
      metadatos: metadatos,
    );
    
    String rutaDOCX = await ReporteDocumentalService.generarReporteDOCX(
      titulo: 'Reporte Estadístico',
      subtitulo: 'Uso de Vivienda y Topografía',
      datos: datosEstadisticos,
      tablas: tablas,
      graficas: graficas,
      metadatos: metadatos,
    );
    
    return {
      'pdf': rutaPDF,
      'docx': rutaDOCX,
    };
  }
  
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
      FormatoEvaluacion? formato = await _cloudService.obtenerFormatoPorId(resultado['documentId']);
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
  bool _verificarUbicaciones(FormatoEvaluacion formato, List<Map<String, dynamic>> ubicaciones) {
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
      
      bool cumpleCiudad = ciudad.isEmpty || 
                           formato.informacionGeneral.ciudadPueblo == ciudad;
      
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
  
  /// Prepara los datos de las tablas para el reporte
  List<Map<String, dynamic>> _prepararTablasParaReporte(Map<String, dynamic> datosEstadisticos) {
    List<Map<String, dynamic>> tablas = [];
    
    // Tabla de uso de vivienda
    Map<String, Map<String, dynamic>> estadisticasUsos = datosEstadisticos['usosVivienda']['estadisticas'];
    
    if (estadisticasUsos.isNotEmpty) {
      List<List<dynamic>> filasUsos = [];
      
      estadisticasUsos.forEach((uso, estadisticas) {
        if (estadisticas['conteo'] > 0) {
          filasUsos.add([
            uso,
            estadisticas['conteo'],
            '${((estadisticas['conteo'] / estadisticasUsos.length) * 100).toStringAsFixed(2)}%',
          ]);
        }
      });
      
      // Ordenar por frecuencia (descendente)
      filasUsos.sort((a, b) => (b[1] as int).compareTo(a[1] as int));
      
      tablas.add({
        'titulo': 'Uso de Vivienda',
        'descripcion': 'Distribución de los usos de vivienda en los formatos analizados.',
        'encabezados': ['Uso', 'Conteo', 'Porcentaje'],
        'filas': filasUsos,
      });
    }
    
    // Tabla de topografía
    Map<String, Map<String, dynamic>> estadisticasTopografia = datosEstadisticos['topografia']['estadisticas'];
    
    if (estadisticasTopografia.isNotEmpty) {
      List<List<dynamic>> filasTopografia = [];
      
      estadisticasTopografia.forEach((tipo, estadisticas) {
        if (estadisticas['conteo'] > 0) {
          filasTopografia.add([
            tipo,
            estadisticas['conteo'],
            '${((estadisticas['conteo'] / estadisticasTopografia.length) * 100).toStringAsFixed(2)}%',
          ]);
        }
      });
      
      // Ordenar por frecuencia (descendente)
      filasTopografia.sort((a, b) => (b[1] as int).compareTo(a[1] as int));
      
      tablas.add({
        'titulo': 'Topografía',
        'descripcion': 'Distribución de los tipos de topografía en los formatos analizados.',
        'encabezados': ['Tipo de Topografía', 'Conteo', 'Porcentaje'],
        'filas': filasTopografia,
      });
    }
    
    return tablas;
  }
  
  /// Genera gráficas para el reporte
  Future<List<Uint8List>> _generarGraficasReporte(Map<String, dynamic> datosEstadisticos) async {
    List<Uint8List> graficas = [];
    
    // Gráfico de uso de vivienda
    Map<String, Map<String, dynamic>> estadisticasUsos = datosEstadisticos['usosVivienda']['estadisticas'];
    
    if (estadisticasUsos.isNotEmpty) {
      Map<String, int> datosUsos = {};
      
      estadisticasUsos.forEach((uso, estadisticas) {
        if (estadisticas['conteo'] > 0) {
          datosUsos[uso] = estadisticas['conteo'];
        }
      });
      
      // Si hay datos, generar gráfico circular
      if (datosUsos.isNotEmpty) {
        Uint8List graficoUsos = await GraficasService.generarGraficoCircular(
          datos: datosUsos,
          titulo: 'Distribución de Uso de Vivienda',
          ancho: 800,
          alto: 500,
        );
        
        graficas.add(graficoUsos);
      }
    }
    
    // Gráfico de topografía
    Map<String, Map<String, dynamic>> estadisticasTopografia = datosEstadisticos['topografia']['estadisticas'];
    
    if (estadisticasTopografia.isNotEmpty) {
      Map<String, int> datosTopografia = {};
      
      estadisticasTopografia.forEach((tipo, estadisticas) {
        if (estadisticas['conteo'] > 0) {
          datosTopografia[tipo] = estadisticas['conteo'];
        }
      });
      
      // Si hay datos, generar gráfico de barras
      if (datosTopografia.isNotEmpty) {
        Uint8List graficoTopografia = await GraficasService.generarGraficoBarra(
          datos: datosTopografia,
          titulo: 'Distribución de Tipos de Topografía',
          ancho: 800,
          alto: 500,
        );
        
        graficas.add(graficoTopografia);
      }
    }
    
    return graficas;
  }
  
  /// Genera conclusiones automáticas basadas en los datos
  String _generarConclusiones(Map<String, dynamic> datosEstadisticos, int totalFormatos) {
    StringBuffer conclusiones = StringBuffer();
    
    conclusiones.writeln('Se analizaron un total de $totalFormatos formatos de evaluación.');
    
    // Análisis de uso de vivienda
    Map<String, Map<String, dynamic>> estadisticasUsos = datosEstadisticos['usosVivienda']['estadisticas'];
    
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
        conclusiones.writeln('\nEl uso más común fue "$usoMasComun" con $maxConteoUso ocurrencias (${porcentajeUsoComun.toStringAsFixed(2)}% del total).');
      }
    }
    
    // Análisis de topografía
    Map<String, Map<String, dynamic>> estadisticasTopografia = datosEstadisticos['topografia']['estadisticas'];
    
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
        double porcentajeTopografiaComun = (maxConteoTopografia / totalFormatos) * 100;
        conclusiones.writeln('\nLa topografía más común fue "$topografiaMasComun" con $maxConteoTopografia ocurrencias (${porcentajeTopografiaComun.toStringAsFixed(2)}% del total).');
      }
    }
    
    // Conclusión general
    conclusiones.writeln('\nEste reporte proporciona una visión general de los patrones de uso y la distribución topográfica de los inmuebles evaluados en el período seleccionado, lo que puede ser útil para la planificación de recursos y la toma de decisiones en futuros proyectos de evaluación estructural.');
    
    return conclusiones.toString();
  }
}