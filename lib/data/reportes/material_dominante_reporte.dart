// lib/data/reportes/material_dominante_reporte.dart

import 'dart:typed_data';

import 'package:pdf/widgets.dart' as pw;
import '../../logica/formato_evaluacion.dart';

import '../services/graficas_service.dart';

/// Clase para manejar la generación de reportes de material dominante de construcción
/// Implementa métodos específicos para este tipo de reporte
class MaterialDominanteReport {
  /// Analiza un conjunto de formatos para extraer información del material dominante
  static Map<String, dynamic> analizarDatos(List<FormatoEvaluacion> formatos) {
    // Categorías de materiales a identificar
    Map<String, Map<String, List<String>>> categoriasMateriales = {
      'Ladrillo': {
        'murosMamposteria': [
          'Tabique arcilla (ladrillo)',
          'Tabique hueco de arcilla',
          'Simple',
          'Muros confinados',
          'Refuerzo interior'
        ],
        'direccionX': [
          'Muros de carga mampostería X',
          
        ],
        'direccionY': [
          'Muros de carga mampostería Y',
          
        ]
      },
      'Concreto': {
        'murosMamposteria': [
          'Bloque concreto 20x40cm',
          'Tabicón de concreto'
        ],
        'direccionX': [
          'Muros de concreto X',
          'Marcos de concreto X',
          'Columnas y losa plana X'
        ],
        'direccionY': [
          'Muros de concreto Y',
          'Marcos de concreto Y',
          'Columnas y losa plana Y'
        ]
      },
      'Adobe': {
        'direccionX': ['Muros de adobe o bahareque X'],
        'direccionY': ['Muros de adobe o bahareque Y']
      },
      'Madera/Lámina/Otros': {
        'direccionX': ['Muros de madera, lámina, otros X'],
        'direccionY': ['Muros de madera, lámina, otros Y']
      },
      'Acero': {
        'direccionX': ['Marcos de acero X'],
        'direccionY': ['Marcos de acero Y']
      }
    };
    
    // Contadores para cada material
    Map<String, int> conteoMateriales = {
      'Ladrillo': 0,
      'Concreto': 0,
      'Adobe': 0,
      'Madera/Lámina/Otros': 0,
      'Acero': 0,
      'No determinado': 0 // Para inmuebles sin material claramente identificado
    };
    
    // Analizar cada formato
    for (var formato in formatos) {
      bool materialIdentificado = false;
      
      // Verificar cada categoría de material
      categoriasMateriales.forEach((material, categorias) {
        // Buscar coincidencias en muros de mampostería si aplica
        if (categorias.containsKey('murosMamposteria') && materialIdentificado == false) {
          for (var opcion in categorias['murosMamposteria']!) {
            if (formato.sistemaEstructural.murosMamposteria.containsKey(opcion) && 
                formato.sistemaEstructural.murosMamposteria[opcion] == true) {
              conteoMateriales[material] = conteoMateriales[material]! + 1;
              materialIdentificado = true;
              break;
            }
          }
        }
        
        // Si ya se identificó material, no seguir buscando
        if (materialIdentificado) return;
        
        // Buscar coincidencias en dirección X
        if (categorias.containsKey('direccionX')) {
          for (var opcion in categorias['direccionX']!) {
            if (formato.sistemaEstructural.direccionX.containsKey(opcion) && 
                formato.sistemaEstructural.direccionX[opcion] == true) {
              conteoMateriales[material] = conteoMateriales[material]! + 1;
              materialIdentificado = true;
              break;
            }
          }
        }
        
        // Si ya se identificó material, no seguir buscando
        if (materialIdentificado) return;
        
        // Buscar coincidencias en dirección Y
        if (categorias.containsKey('direccionY')) {
          for (var opcion in categorias['direccionY']!) {
            if (formato.sistemaEstructural.direccionY.containsKey(opcion) && 
                formato.sistemaEstructural.direccionY[opcion] == true) {
              conteoMateriales[material] = conteoMateriales[material]! + 1;
              materialIdentificado = true;
              break;
            }
          }
        }
        // Si ya se identificó material, no seguir buscando
        if (materialIdentificado) return;
      });
      
      // Si no se identificó ningún material, incrementar contador de "No determinado"
      if (!materialIdentificado) {
        conteoMateriales['No determinado'] = conteoMateriales['No determinado']! + 1;
      }
    }
    
    // Calcular estadísticas (porcentajes)
    Map<String, Map<String, dynamic>> estadisticas = {};
    int totalFormatos = formatos.length;
    
    conteoMateriales.forEach((material, conteo) {
      double porcentaje = totalFormatos > 0 ? (conteo / totalFormatos) * 100 : 0;
      
      estadisticas[material] = {
        'conteo': conteo,
        'porcentaje': porcentaje,
      };
    });
    
    return {
      'conteoMateriales': conteoMateriales,
      'estadisticas': estadisticas,
      'totalFormatos': totalFormatos,
    };
  }
  
  /// Prepara los datos para las tablas del reporte
  static List<Map<String, dynamic>> prepararTablas(Map<String, dynamic> datosEstadisticos) {
    List<Map<String, dynamic>> tablas = [];
    
    // Obtener estadísticas de materiales
    Map<String, Map<String, dynamic>> estadisticas = datosEstadisticos['estadisticas'];
    
    // Crear filas para la tabla
    List<List<dynamic>> filas = [];
    
    // Ordenar materiales por frecuencia (de mayor a menor)
    var materialesOrdenados = estadisticas.entries.toList()
      ..sort((a, b) => (b.value['conteo'] as int).compareTo(a.value['conteo'] as int));
    
    for (var entry in materialesOrdenados) {
      String material = entry.key;
      int conteo = entry.value['conteo'];
      double porcentaje = entry.value['porcentaje'];
      
      // Solo incluir materiales con al menos un registro
      if (conteo > 0) {
        filas.add([
          material,
          conteo,
          '${porcentaje.toStringAsFixed(2)}%',
        ]);
      }
    }
    
    // Si hay filas, agregar la tabla
    if (filas.isNotEmpty) {
      tablas.add({
        'titulo': 'Material Dominante de Construcción',
        'descripcion': 'Distribución de inmuebles evaluados según su material predominante de construcción.',
        'encabezados': ['Material', 'Cantidad', 'Porcentaje'],
        'filas': filas,
      });
    }
    
    return tablas;
  }
  
  /// Genera placeholders para las gráficas que se crearán en el PDF
  static Future<List<Uint8List>> generarPlaceholdersGraficas(Map<String, dynamic> datosEstadisticos) async {
    // Simplemente retornamos placeholders para que las gráficas se generen en el PDF
    return [Uint8List(0)]; // Un placeholder para la gráfica principal
  }
  
  /// Genera las gráficas para el reporte en formato PDF
  static List<pw.Widget> generarGraficosPDF(Map<String, dynamic> datos) {
    List<pw.Widget> widgets = [];
    
    // Verificar si hay datos de materiales dominantes
    if (datos['estadisticas'] != null && datos['estadisticas'].isNotEmpty) {
      // Convertir los datos al formato esperado por el servicio de gráficas
      Map<String, int> datosGrafico = {};
      datos['conteoMateriales'].forEach((material, conteo) {
        if (conteo > 0) {
          datosGrafico[material] = conteo;
        }
      });
      
      // Añadir encabezado para el gráfico
      widgets.add(
        pw.Header(
          level: 2,
          text: 'Distribución de Materiales Dominantes',
          textStyle: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold),
        ),
      );
      
      // Añadir gráfico circular
      widgets.add(
        GraficasService.crearGraficoCircularPDF(
          datos: datosGrafico,
          titulo: 'Distribución por Material Predominante',
          ancho: 500,
          alto: 300,
        ),
      );
      
      // Añadir gráfico de barras horizontales para una mejor visualización
      widgets.add(
        pw.SizedBox(height: 20),
      );
      
      widgets.add(
        pw.Header(
          level: 2,
          text: 'Comparativa de Materiales por Frecuencia',
          textStyle: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold),
        ),
      );
      
      widgets.add(
        GraficasService.crearGraficoBarrasHorizontalesPDF(
          datos: datosGrafico,
          titulo: 'Cantidad de Inmuebles por Material Predominante',
          ancho: 500,
          alto: 300,
        ),
      );
      
      widgets.add(pw.SizedBox(height: 20));
    }
    
    return widgets;
  }
  
  /// Genera las conclusiones para el reporte
  static String generarConclusiones(Map<String, dynamic> datosEstadisticos, int totalFormatos) {
    StringBuffer conclusiones = StringBuffer();
    
    // Mensaje inicial
    conclusiones.writeln(
      'Se analizaron un total de $totalFormatos formatos de evaluación para determinar los materiales dominantes de construcción.');
    
    // Si no hay formatos analizados
    if (totalFormatos == 0) {
      conclusiones.writeln('\nNo se encontraron formatos que cumplieran con los criterios especificados.');
      return conclusiones.toString();
    }
    
    // Obtener el material más común
    String? materialMasComun;
    int maxConteo = 0;
    double maxPorcentaje = 0;
    
    datosEstadisticos['estadisticas'].forEach((material, stats) {
      if (stats['conteo'] > maxConteo) {
        maxConteo = stats['conteo'];
        maxPorcentaje = stats['porcentaje'];
        materialMasComun = material;
      }
    });
    
    if (materialMasComun != null) {
      conclusiones.writeln(
        '\nEl material predominante en los inmuebles evaluados es "$materialMasComun" con $maxConteo ocurrencias (${maxPorcentaje.toStringAsFixed(2)}% del total).');
    }
    
    // Analizar la distribución de materiales
    var materialesOrdenados = datosEstadisticos['estadisticas'].entries.toList()
      ..sort((a, b) => (b.value['conteo'] as int).compareTo(a.value['conteo'] as int));
    
    // Si hay más de un material con presencia significativa
    if (materialesOrdenados.length > 1 && materialesOrdenados[1].value['conteo'] > 0) {
      String segundoMaterial = materialesOrdenados[1].key;
      int segundoConteo = materialesOrdenados[1].value['conteo'];
      double segundoPorcentaje = materialesOrdenados[1].value['porcentaje'];
      
      conclusiones.writeln(
        '\nEl segundo material más común es "$segundoMaterial" con $segundoConteo ocurrencias (${segundoPorcentaje.toStringAsFixed(2)}% del total).');
    }
    
    // Verificar si hay inmuebles sin material determinado
    if (datosEstadisticos['estadisticas'].containsKey('No determinado') && 
        datosEstadisticos['estadisticas']['No determinado']['conteo'] > 0) {
      int noDetConteo = datosEstadisticos['estadisticas']['No determinado']['conteo'];
      double noDetPorcentaje = datosEstadisticos['estadisticas']['No determinado']['porcentaje'];
      
      if (noDetConteo > 0 && noDetPorcentaje > 5) { // Solo si es un porcentaje significativo
        conclusiones.writeln(
          '\nSe identificaron $noDetConteo inmuebles (${noDetPorcentaje.toStringAsFixed(2)}%) donde no fue posible determinar claramente el material predominante.');
      }
    }
    
    // Conclusión general
    conclusiones.writeln(
      '\nEste reporte proporciona una visión integral de los materiales predominantes en los inmuebles evaluados, lo que puede ser útil para identificar patrones constructivos en la región y para la planificación de recursos en evaluaciones estructurales futuras.');
    
    return conclusiones.toString();
  }
}