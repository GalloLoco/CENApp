// lib/data/reports/sistema_estructural_graficas.dart
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../services/graficas_service.dart';

/// Extensión del servicio de gráficas para sistema estructural
class SistemaEstructuralGraficas {
  
  /// Genera gráficos especializados para reporte de sistema estructural
  static List<pw.Widget> generarGraficos(Map<String, dynamic> datos) {
    List<pw.Widget> widgets = [];
    
    // Categorías a incluir en los gráficos
    final List<Map<String, String>> categorias = [
      {'id': 'direccionX', 'titulo': 'Dirección X', 'descripcion': 'Elementos estructurales en dirección X'},
      {'id': 'direccionY', 'titulo': 'Dirección Y', 'descripcion': 'Elementos estructurales en dirección Y'},
      {'id': 'murosMamposteria', 'titulo': 'Muros de Mampostería', 'descripcion': 'Tipos de muros de mampostería'},
      {'id': 'sistemasPiso', 'titulo': 'Sistemas de Piso', 'descripcion': 'Tipos de sistemas de piso'},
      {'id': 'sistemasTecho', 'titulo': 'Sistemas de Techo', 'descripcion': 'Tipos de sistemas de techo'},
      {'id': 'cimentacion', 'titulo': 'Cimentación', 'descripcion': 'Tipos de cimentación'},
    ];
    
    // Para cada categoría, generar un gráfico
    for (var categoria in categorias) {
      String id = categoria['id']!;
      String titulo = categoria['titulo']!;
      String descripcion = categoria['descripcion']!;
      
      // Verificar si hay datos para esta categoría
      if (datos['estadisticas']?[id] != null && 
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
        
        // Añadir descripción
        widgets.add(
          pw.Paragraph(
            text: descripcion,
            style: pw.TextStyle(
              fontSize: 10,
              fontStyle: pw.FontStyle.italic,
              color: PdfColors.grey700,
            ),
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
        
        // Añadir estadísticas simples
        widgets.add(
          pw.Container(
            margin: pw.EdgeInsets.only(top: 10, bottom: 20),
            padding: pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey100,
              borderRadius: pw.BorderRadius.circular(5),
              border: pw.Border.all(color: PdfColors.grey300),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Estadísticas clave:',
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 9,
                  ),
                ),
                pw.SizedBox(height: 5),
                _construirEstadisticasClave(datos['estadisticas'][id], datos['totalFormatos']),
              ],
            ),
          ),
        );
      }
    }
    
    return widgets;
  }
  
  /// Construye un widget con estadísticas claves para una categoría
  static pw.Widget _construirEstadisticasClave(Map<String, dynamic> estadisticas, int totalFormatos) {
    // Encontrar el elemento más común
    String elementoMasComun = '';
    int maxConteo = 0;
    
    estadisticas.forEach((elemento, stats) {
      if (stats['conteo'] > maxConteo) {
        maxConteo = stats['conteo'];
        elementoMasComun = elemento;
      }
    });
    
    // Calcular el porcentaje del más común
    double porcentajeMasComun = (maxConteo / totalFormatos) * 100;
    
    // Calcular el número total de elementos seleccionados
    int totalSeleccionados = 0;
    estadisticas.forEach((elemento, stats) {
      totalSeleccionados += stats['conteo'] as int;
    });
    
    // Calcular promedio de selecciones por formato
    double promedioPorFormato = totalSeleccionados / totalFormatos;
    
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          '• Elemento más común: $elementoMasComun (${porcentajeMasComun.toStringAsFixed(1)}% de los formatos)',
          style: pw.TextStyle(fontSize: 8),
        ),
        pw.Text(
          '• Total de elementos seleccionados: $totalSeleccionados',
          style: pw.TextStyle(fontSize: 8),
        ),
        pw.Text(
          '• Promedio de elementos por formato: ${promedioPorFormato.toStringAsFixed(2)}',
          style: pw.TextStyle(fontSize: 8),
        ),
      ],
    );
  }
}