// lib/data/reports/sistema_estructural_report.dart
import 'dart:typed_data';

import 'package:pdf/widgets.dart' as pw;
import '../../logica/formato_evaluacion.dart';
import '../services/estadisticos_service.dart';
import '../services/graficas_service.dart';

/// Clase para manejar la generación de reportes de sistema estructural
/// Implementa métodos específicos para este tipo de reporte
class SistemaEstructuralReport {
  /// Analiza un conjunto de formatos para extraer información del sistema estructural
  static Map<String, dynamic> analizarDatos(List<FormatoEvaluacion> formatos) {
    return EstadisticosService.analizarSistemaEstructural(formatos);
  }
  
  /// Prepara los datos para las tablas del reporte
  static List<Map<String, dynamic>> prepararTablas(Map<String, dynamic> datosEstadisticos) {
    List<Map<String, dynamic>> tablas = [];
    
    // Categorías a incluir en el reporte
    final List<Map<String, String>> categorias = [
      {'id': 'direccionX', 'titulo': 'Dirección X', 'descripcion': 'Elementos estructurales en dirección X'},
      {'id': 'direccionY', 'titulo': 'Dirección Y', 'descripcion': 'Elementos estructurales en dirección Y'},
      {'id': 'murosMamposteria', 'titulo': 'Muros de Mampostería', 'descripcion': 'Tipos de muros de mampostería'},
      {'id': 'sistemasPiso', 'titulo': 'Sistemas de Piso', 'descripcion': 'Tipos de sistemas de piso'},
      {'id': 'sistemasTecho', 'titulo': 'Sistemas de Techo', 'descripcion': 'Tipos de sistemas de techo'},
      {'id': 'cimentacion', 'titulo': 'Cimentación', 'descripcion': 'Tipos de cimentación'},
    ];
    

    
    // Para cada categoría, crear una tabla
    for (var categoria in categorias) {
      String id = categoria['id']!;
      
      // Verificar si hay datos para esta categoría
      if (datosEstadisticos['estadisticas'].containsKey(id)) {
        Map<String, dynamic> estadisticasCategoria = datosEstadisticos['estadisticas'][id];
        
        // Crear filas para la tabla
        List<List<dynamic>> filas = [];
        
        // Ordenar opciones por frecuencia (de mayor a menor)
        var opcionesOrdenadas = estadisticasCategoria.entries.toList()
          ..sort((a, b) => (b.value['conteo'] as int).compareTo(a.value['conteo'] as int));
        
        for (var opcion in opcionesOrdenadas) {
          String nombreOpcion = opcion.key;
          int conteo = opcion.value['conteo'];
          double porcentaje = opcion.value['porcentaje'];
          
          filas.add([
            nombreOpcion,
            conteo,
            '${porcentaje.toStringAsFixed(2)}%',
          ]);
        }
        
        // Si hay filas, agregar la tabla
        if (filas.isNotEmpty) {
          tablas.add({
            'titulo': categoria['titulo'],
            'descripcion': categoria['descripcion'],
            'encabezados': ['Elemento', 'Conteo', 'Porcentaje'],
            'filas': filas,
          });
        }
      }
    }
    
    return tablas;
  }
  
  /// Genera placeholders para las gráficas que se crearán en el PDF
  static Future<List<Uint8List>> generarPlaceholdersGraficas(Map<String, dynamic> datosEstadisticos) async {
    List<Uint8List> graficas = [];
    
    // Categorías principales para las que generaremos gráficos
    final List<String> categoriasPrincipales = [
      'direccionX',
      'direccionY',
      'murosMamposteria',
      'sistemasPiso',
      'sistemasTecho',
      'cimentacion',
    ];
    
    // Añadir un placeholder por cada categoría que tenga datos
    for (var categoria in categoriasPrincipales) {
      if (datosEstadisticos['estadisticas'].containsKey(categoria) &&
          datosEstadisticos['estadisticas'][categoria].isNotEmpty) {
        graficas.add(Uint8List(0)); // Placeholder vacío
      }
    }
    
    return graficas;
  }
  
  /// Genera las gráficas para el reporte en formato PDF
  static List<pw.Widget> generarGraficosPDF(Map<String, dynamic> datos) {
    List<pw.Widget> widgets = [];
    
    // Categorías a incluir en los gráficos
    final List<Map<String, String>> categorias = [
      {'id': 'direccionX', 'titulo': 'Dirección X'},
      {'id': 'direccionY', 'titulo': 'Dirección Y'},
      {'id': 'murosMamposteria', 'titulo': 'Muros de Mampostería'},
      {'id': 'sistemasPiso', 'titulo': 'Sistemas de Piso'},
      {'id': 'sistemasTecho', 'titulo': 'Sistemas de Techo'},
      {'id': 'cimentacion', 'titulo': 'Cimentación'},
    ];
    
    // Para cada categoría, generar un gráfico
    for (var categoria in categorias) {
      String id = categoria['id']!;
      String titulo = categoria['titulo']!;
      
      // Verificar si hay datos para esta categoría
      if (datos['estadisticas'].containsKey(id) && 
          datos['estadisticas'][id].isNotEmpty) {
        
        // Convertir los datos al formato esperado por el servicio de gráficas
        Map<String, int> datosGrafico = {};
        datos['estadisticas'][id].forEach((elemento, stats) {
          datosGrafico[elemento] = stats['conteo'];
        });
        
        // Añadir encabezado
        widgets.add(
          pw.Header(
            level: 2,
            text: 'Distribución de Elementos: $titulo',
            textStyle: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold),
          ),
        );
        
        // Crear y añadir el gráfico
        widgets.add(
          GraficasService.crearGraficoBarrasHorizontalesPDF(
            datos: datosGrafico,
            titulo: 'Frecuencia de Elementos en $titulo',
            ancho: 500,
            alto: 300,
          ),
        );
        
        widgets.add(pw.SizedBox(height: 20));
      }
    }
    
    return widgets;
  }
  
  /// Genera las conclusiones para el reporte
  static String generarConclusiones(Map<String, dynamic> datosEstadisticos, int totalFormatos) {
    StringBuffer conclusiones = StringBuffer();
    
    // Mensaje inicial
    conclusiones.writeln(
      'Se analizaron un total de $totalFormatos formatos de evaluación para determinar los patrones estructurales predominantes.');
    
    // Categorías a incluir en las conclusiones
    final List<Map<String, String>> categorias = [
      {'id': 'direccionX', 'nombre': 'Dirección X'},
      {'id': 'direccionY', 'nombre': 'Dirección Y'},
      {'id': 'murosMamposteria', 'nombre': 'Muros de Mampostería'},
      {'id': 'sistemasPiso', 'nombre': 'Sistemas de Piso'},
      {'id': 'sistemasTecho', 'nombre': 'Sistemas de Techo'},
      {'id': 'cimentacion', 'nombre': 'Cimentación'},
    ];
    
    // Para cada categoría, encontrar el elemento más común
    for (var categoria in categorias) {
      String id = categoria['id']!;
      String nombre = categoria['nombre']!;
      
      if (datosEstadisticos['estadisticas'].containsKey(id) &&
          datosEstadisticos['estadisticas'][id].isNotEmpty) {
        
        // Encontrar el elemento más común
        String elementoMasComun = '';
        int maxConteo = 0;
        double maxPorcentaje = 0;
        
        datosEstadisticos['estadisticas'][id].forEach((elemento, stats) {
          if (stats['conteo'] > maxConteo) {
            maxConteo = stats['conteo'];
            maxPorcentaje = stats['porcentaje'];
            elementoMasComun = elemento;
          }
        });
        
        if (elementoMasComun.isNotEmpty) {
          conclusiones.writeln(
            '\nEl elemento más común en $nombre fue "$elementoMasComun" con $maxConteo ocurrencias (${maxPorcentaje.toStringAsFixed(2)}% del total).');
        }
      }
    }
    
    // Conclusión general
    conclusiones.writeln(
      '\nEste reporte proporciona una visión integral de los sistemas estructurales predominantes en los inmuebles evaluados, lo que puede ser útil para identificar patrones de construcción comunes y potenciales vulnerabilidades estructurales en la región.');
    
    return conclusiones.toString();
  }
}