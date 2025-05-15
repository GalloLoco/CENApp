// Versión alternativa y simplificada del servicio de gráficas
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';

class GraficasService {
  /// Genera datos para un gráfico de barras (como lista de puntos)
  static List<Map<String, dynamic>> generarDatosGraficoBarra(Map<String, int> datos) {
    // Convertir los datos a un formato que podamos usar en PDF
    List<Map<String, dynamic>> puntos = [];
    
    // Total para calcular porcentajes
    int total = datos.values.fold(0, (sum, value) => sum + value);
    
    // Agregar cada punto
    datos.forEach((key, value) {
      double porcentaje = total > 0 ? (value / total) * 100 : 0;
      
      puntos.add({
        'etiqueta': key,
        'valor': value,
        'porcentaje': porcentaje,
      });
    });
    
    // Ordenar por valor (descendente)
    puntos.sort((a, b) => (b['valor'] as int).compareTo(a['valor'] as int));
    
    return puntos;
  }
  
  /// Crea un gráfico de barras directamente en un documento PDF
  static pw.Widget crearGraficoBarrasPDF({
    required Map<String, int> datos,
    required String titulo,
    double ancho = 500,
    double alto = 300,
  }) {
    // Procesar los datos
    List<Map<String, dynamic>> puntos = generarDatosGraficoBarra(datos);
    
    // Si no hay datos, mostrar mensaje
    if (puntos.isEmpty) {
      return pw.Container(
        width: ancho,
        height: alto,
        alignment: pw.Alignment.center,
        child: pw.Text('No hay datos disponibles para generar el gráfico'),
      );
    }
    
    // Colores para las barras
    List<PdfColor> colores = [
      PdfColors.blue,
      PdfColors.red,
      PdfColors.green,
      PdfColors.orange,
      PdfColors.purple,
      PdfColors.teal,
      PdfColors.brown,
    ];
    
    // Crear el gráfico usando widgets de PDF
    return pw.Container(
      width: ancho,
      height: alto,
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          // Título
          pw.Text(
            titulo,
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 10),
          
          // Gráfico
          pw.Expanded(
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                // Eje Y (valores)
                pw.Container(
                  width: 40,
                  child: pw.Column(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('100%', style: pw.TextStyle(fontSize: 8)),
                      pw.Text('75%', style: pw.TextStyle(fontSize: 8)),
                      pw.Text('50%', style: pw.TextStyle(fontSize: 8)),
                      pw.Text('25%', style: pw.TextStyle(fontSize: 8)),
                      pw.Text('0%', style: pw.TextStyle(fontSize: 8)),
                    ],
                  ),
                ),
                
                // Barras y eje X
                pw.Expanded(
                  child: pw.Column(
                    children: [
                      // Barras
                      pw.Expanded(
                        child: pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: pw.CrossAxisAlignment.end,
                          children: List.generate(
                            puntos.length > 10 ? 10 : puntos.length, // Limitar a 10 barras máximo
                            (index) {
                              final punto = puntos[index];
                              final porcentaje = punto['porcentaje'] as double;
                              
                              return pw.Container(
                                width: (ancho - 60) / (puntos.length > 10 ? 10 : puntos.length) - 10,
                                height: (alto - 60) * (porcentaje / 100),
                                color: colores[index % colores.length],
                                child: pw.Container(),
                              );
                            },
                          ),
                        ),
                      ),
                      
                      // Eje X (etiquetas)
                      pw.Container(
                        height: 40,
                        child: pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: List.generate(
                            puntos.length > 10 ? 10 : puntos.length, // Limitar a 10 etiquetas máximo
                            (index) {
                              final punto = puntos[index];
                              final etiqueta = punto['etiqueta'] as String;
                              
                              // Acortar etiquetas largas
                              String etiquetaCorta = etiqueta.length > 10 
                                  ? etiqueta.substring(0, 10) + '...' 
                                  : etiqueta;
                              
                              return pw.Container(
                                width: (ancho - 60) / (puntos.length > 10 ? 10 : puntos.length) - 10,
                                child: pw.Transform.rotate(
                                  angle: pi / 6, // 30 grados
                                  child: pw.Text(
                                    etiquetaCorta, 
                                    style: pw.TextStyle(fontSize: 6),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Leyenda
          pw.Container(
            height: 60,
            child: pw.Column(
              children: [
                pw.Text('Leyenda', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 5),
                pw.Wrap(
                  spacing: 10,
                  runSpacing: 5,
                  children: List.generate(
                    puntos.length > 5 ? 5 : puntos.length, // Limitar a 5 leyendas máximo
                    (index) {
                      final punto = puntos[index];
                      final etiqueta = punto['etiqueta'] as String;
                      final valor = punto['valor'] as int;
                      
                      return pw.Row(
                        mainAxisSize: pw.MainAxisSize.min,
                        children: [
                          pw.Container(
                            width: 8,
                            height: 8,
                            color: colores[index % colores.length],
                          ),
                          pw.SizedBox(width: 2),
                          pw.Text(
                            '$etiqueta ($valor)', 
                            style: pw.TextStyle(fontSize: 6),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  /// Crea un gráfico circular directamente en un documento PDF
  static pw.Widget crearGraficoCircularPDF({
    required Map<String, int> datos,
    required String titulo,
    double ancho = 500,
    double alto = 300,
  }) {
    // Calcular total
    int total = datos.values.fold(0, (sum, value) => sum + value);
    
    // Si no hay datos, mostrar mensaje
    if (total == 0) {
      return pw.Container(
        width: ancho,
        height: alto,
        alignment: pw.Alignment.center,
        child: pw.Text('No hay datos disponibles para generar el gráfico'),
      );
    }
    
    // Colores para los sectores
    List<PdfColor> colores = [
      PdfColors.blue,
      PdfColors.red,
      PdfColors.green,
      PdfColors.orange,
      PdfColors.purple,
      PdfColors.teal,
      PdfColors.brown,
    ];
    
    // Crear el gráfico usando widgets de PDF
    return pw.Container(
      width: ancho,
      height: alto,
      child: pw.Column(
        children: [
          // Título
          pw.Text(
            titulo,
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 20),
          
          // Gráfico + Leyenda
          pw.Expanded(
            child: pw.Row(
              children: [
                // Gráfico circular (se usará un rectángulo por simplicidad)
                pw.Expanded(
                  flex: 3,
                  child: pw.Container(
                    alignment: pw.Alignment.center,
                    child: pw.Text(
                      'Gráfico Circular\n(Simplificado en versión PDF)',
                      textAlign: pw.TextAlign.center,
                    ),
                  ),
                ),
                
                // Leyenda
                pw.Expanded(
                  flex: 2,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Leyenda', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 10),
                      
                      // Crear elementos de la leyenda
                      ...datos.entries.take(10).map((entry) {
                        int index = datos.keys.toList().indexOf(entry.key);
                        double porcentaje = total > 0 ? (entry.value / total) * 100 : 0;
                        
                        return pw.Padding(
                          padding: const pw.EdgeInsets.only(bottom: 5),
                          child: pw.Row(
                            children: [
                              pw.Container(
                                width: 10,
                                height: 10,
                                color: colores[index % colores.length],
                              ),
                              pw.SizedBox(width: 5),
                              pw.Expanded(
                                child: pw.Text(
                                  '${entry.key} (${porcentaje.toStringAsFixed(1)}%)',
                                  style: pw.TextStyle(fontSize: 8),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}