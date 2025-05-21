// Versión alternativa y simplificada del servicio de gráficas
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:math';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';

class GraficasService {

    /// Crea un gráfico de barras horizontales para el PDF (útil para distribuciones geográficas)
static pw.Widget crearGraficoBarrasHorizontalesPDF({
  required Map<String, int> datos,
  required String titulo,
  double ancho = 500,
  double alto = 300,
  int maxItems = 10, // Limitamos el número de ítems para mejor visualización
}) {
  // Procesar los datos
  List<MapEntry<String, int>> entradas = datos.entries.toList();
  
  // Ordenar por valor (descendente)
  entradas.sort((a, b) => b.value.compareTo(a.value));
  
  // Limitar el número de ítems
  if (entradas.length > maxItems) {
    entradas = entradas.sublist(0, maxItems);
  }
  
  // Si no hay datos, mostrar mensaje
  if (entradas.isEmpty) {
    return pw.Container(
      width: ancho,
      height: alto,
      alignment: pw.Alignment.center,
      child: pw.Text('No hay datos disponibles para generar el gráfico'),
    );
  }
  
  // Calcular total para porcentajes
  int total = entradas.fold(0, (sum, entry) => sum + entry.value);
  
  // Colores para las barras
  List<PdfColor> colores = [
    PdfColors.blue,
    PdfColors.red,
    PdfColors.green,
    PdfColors.orange,
    PdfColors.purple,
    PdfColors.teal,
    PdfColors.brown,
    PdfColors.pink,
    PdfColors.cyan,
    PdfColors.amber,
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
        
        // Gráfico de barras horizontales
        pw.Expanded(
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              // Etiquetas de las barras (nombres)
              pw.Container(
                width: ancho * 0.3, // 30% del ancho para etiquetas
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                  children: entradas.map((entry) {
                    // Truncar etiquetas largas
                    String etiqueta = entry.key.length > 15 
                        ? '${entry.key.substring(0, 12)}...' 
                        : entry.key;
                    
                    return pw.Padding(
                      padding: pw.EdgeInsets.symmetric(vertical: 2),
                      child: pw.Text(
                        etiqueta,
                        style: pw.TextStyle(fontSize: 8),
                        textAlign: pw.TextAlign.right,
                      ),
                    );
                  }).toList(),
                ),
              ),
              
              // Separador
              pw.SizedBox(width: 5),
              
              // Gráfico de barras
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                  children: List.generate(
                    entradas.length,
                    (index) {
                      final entry = entradas[index];
                      final porcentaje = total > 0 ? entry.value / total : 0;
                      
                      return pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.center,
                        children: [
                          // Barra
                          pw.Container(
                            width: (ancho * 0.6) * porcentaje, // Ancho proporcional al valor
                            height: 15,
                            color: colores[index % colores.length],
                          ),
                          
                          // Valor
                          pw.SizedBox(width: 5),
                          pw.Text(
                            '${entry.value} (${(porcentaje * 100).toStringAsFixed(1)}%)',
                            style: pw.TextStyle(fontSize: 8),
                          ),
                        ],
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
  );
}

/// Crea un gráfico de líneas para mostrar tendencias temporales en un PDF

/// Crea un gráfico de mapa de áreas (simplificado para PDF) para mostrar la distribución geográfica
static pw.Widget crearGraficoMapaAreasPDF({
  required Map<String, Map<String, int>> datos,
  required String titulo,
  double ancho = 500,
  double alto = 350,
}) {
  // Extraer datos de colonias y ciudades
  Map<String, int> colonias = datos['colonias'] ?? {};
  Map<String, int> ciudades = datos['ciudades'] ?? {};
  
  // Si no hay datos, mostrar mensaje
  if (colonias.isEmpty && ciudades.isEmpty) {
    return pw.Container(
      width: ancho,
      height: alto,
      alignment: pw.Alignment.center,
      child: pw.Text('No hay datos disponibles para generar el gráfico'),
    );
  }
  
  // Dado que en PDF no podemos crear mapas interactivos reales,
  // crearemos una representación visual abstracta de la distribución
  
  // Colores para las secciones
  List<PdfColor> colores = [
    PdfColors.blue100,
    PdfColors.blue200,
    PdfColors.blue300,
    PdfColors.blue400,
    PdfColors.blue500,
    PdfColors.blue600,
    PdfColors.blue700,
    PdfColors.blue800,
    PdfColors.blue900,
  ];
  
  // Ordenar ciudades por cantidad (descendente)
  List<MapEntry<String, int>> entradasCiudades = ciudades.entries.toList();
  entradasCiudades.sort((a, b) => b.value.compareTo(a.value));
  
  // Limitar a las 5 principales ciudades
  if (entradasCiudades.length > 5) {
    entradasCiudades = entradasCiudades.sublist(0, 5);
  }
  
  // Ordenar colonias por cantidad (descendente)
  List<MapEntry<String, int>> entradasColonias = colonias.entries.toList();
  entradasColonias.sort((a, b) => b.value.compareTo(a.value));
  
  // Limitar a las 10 principales colonias
  if (entradasColonias.length > 10) {
    entradasColonias = entradasColonias.sublist(0, 10);
  }
  
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
        
        // Mapa simplificado (representación visual)
        pw.Expanded(
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              // Sección para ciudades
              pw.Expanded(
                flex: 3,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Distribución por Ciudades',
                      style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
                      textAlign: pw.TextAlign.center,
                    ),
                    pw.SizedBox(height: 5),
                    
                    // Representación de ciudades como bloques proporcionales
                    pw.Expanded(
                      child: pw.Column(
                        children: [
                          pw.Expanded(
                            child: pw.GridView(
                              crossAxisCount: 2,
                              childAspectRatio: 0.8,
                              children: List.generate(
                                entradasCiudades.length,
                                (index) {
                                  int total = entradasCiudades.fold(0, (sum, entry) => sum + entry.value);
                                  MapEntry<String, int> ciudad = entradasCiudades[index];
                                  double tamano = ciudad.value / total;
                                  
                                  return pw.Padding(
                                    padding: pw.EdgeInsets.all(5),
                                    child: pw.Stack(
                                      alignment: pw.Alignment.center,
                                      children: [
                                        pw.Container(
                                          decoration: pw.BoxDecoration(
                                            color: colores[index % colores.length],
                                            borderRadius: pw.BorderRadius.circular(5),
                                          ),
                                        ),
                                        pw.Column(
                                          mainAxisAlignment: pw.MainAxisAlignment.center,
                                          children: [
                                            pw.Text(
                                              ciudad.key,
                                              style: pw.TextStyle(
                                                fontSize: 9,
                                                fontWeight: pw.FontWeight.bold,
                                                color: PdfColors.white,
                                              ),
                                              textAlign: pw.TextAlign.center,
                                            ),
                                            pw.SizedBox(height: 5),
                                            pw.Text(
                                              '${ciudad.value} inmuebles',
                                              style: pw.TextStyle(
                                                fontSize: 8,
                                                color: PdfColors.white,
                                              ),
                                              textAlign: pw.TextAlign.center,
                                            ),
                                            pw.SizedBox(height: 3),
                                            pw.Text(
                                              '${(tamano * 100).toStringAsFixed(1)}%',
                                              style: pw.TextStyle(
                                                fontSize: 8,
                                                fontWeight: pw.FontWeight.bold,
                                                color: PdfColors.white,
                                              ),
                                              textAlign: pw.TextAlign.center,
                                            ),
                                          ],
                                        ),
                                      ],
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
              
              // Separador
              pw.SizedBox(width: 10),
              
              // Sección para colonias
              pw.Expanded(
                flex: 4,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Distribución por Colonias',
                      style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
                      textAlign: pw.TextAlign.center,
                    ),
                    pw.SizedBox(height: 5),
                    
                    // Lista de colonias
                    pw.Expanded(
                      child: pw.Wrap(
                        spacing: 5,
                        runSpacing: 5,
                        children: List.generate(
                          entradasColonias.length,
                          (index) {
                            MapEntry<String, int> colonia = entradasColonias[index];
                            
                            return pw.Container(
                              width: (ancho / 2) * 0.45,
                              height: alto * 0.15,
                              decoration: pw.BoxDecoration(
                                color: colores[(colores.length - 1 - index) % colores.length],
                                borderRadius: pw.BorderRadius.circular(5),
                              ),
                              padding: pw.EdgeInsets.all(5),
                              child: pw.Column(
                                mainAxisAlignment: pw.MainAxisAlignment.center,
                                children: [
                                  pw.Text(
                                    colonia.key,
                                    style: pw.TextStyle(
                                      fontSize: 7,
                                      fontWeight: pw.FontWeight.bold,
                                      color: PdfColors.white,
                                    ),
                                    textAlign: pw.TextAlign.center,
                                    maxLines: 2,
                                    overflow: pw.TextOverflow.clip,
                                  ),
                                  pw.SizedBox(height: 3),
                                  pw.Text(
                                    '${colonia.value} inmuebles',
                                    style: pw.TextStyle(
                                      fontSize: 6,
                                      color: PdfColors.white,
                                    ),
                                    textAlign: pw.TextAlign.center,
                                  ),
                                ],
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
        
        // Nota explicativa
        pw.SizedBox(height: 10),
        pw.Container(
          padding: pw.EdgeInsets.all(5),
          decoration: pw.BoxDecoration(
            color: PdfColors.grey100,
            borderRadius: pw.BorderRadius.circular(5),
          ),
          child: pw.Text(
            'Nota: El tamaño de cada bloque es proporcional a la cantidad de inmuebles evaluados en esa área geográfica.',
            style: pw.TextStyle(fontSize: 7, fontStyle: pw.FontStyle.italic),
            textAlign: pw.TextAlign.center,
          ),
        ),
      ],
    ),
  );
}






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

    // Convertir datos a lista ordenada para facilitar el procesamiento
    List<MapEntry<String, int>> datosOrdenados = datos.entries.toList();
    datosOrdenados
        .sort((a, b) => b.value.compareTo(a.value)); // Ordenar de mayor a menor

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
                // Gráfico circular real
                pw.Expanded(
                  flex: 3,
                  child: pw.CustomPaint(
                    painter: (PdfGraphics canvas, PdfPoint size) {
                      // Definir centro y radio
                      final center = PdfPoint(size.x / 2, size.y / 2 + 20);
                      final radius = math.min(size.x, size.y) / 2 - 80;

                      // Variables para dibujar los sectores
                      double startAngle = 0;
                      double currentAngle = 0;

                      // Dibujar cada sector
                      for (int i = 0; i < datosOrdenados.length; i++) {
                        final entry = datosOrdenados[i];
                        final porcentaje = entry.value / total;
                        final sweepAngle = porcentaje * 2 * pi;

                        // Seleccionar color
                        final color = colores[i % colores.length];

                        // Dibujar sector
                        canvas
                          ..setFillColor(color)
                          ..moveTo(center.x, center.y)
                          
                          ..drawEllipse(
                            center.x - radius,
                            center.y - radius,
                            radius * 2,
                            radius * 2,
                          )
                          ..clipPath()
                          ..moveTo(center.x, center.y)
                          ..lineTo(
                            center.x + radius * math.cos(startAngle),
                            center.y + radius * math.sin(startAngle),
                          )
                          ..lineTo(
                            center.x + radius * math.cos(startAngle + sweepAngle),
                            center.y + radius * math.sin(startAngle + sweepAngle),
                          )
                          ..closePath()
                          ..fillPath();

                        // Actualizar ángulo para el siguiente sector
                        startAngle += sweepAngle;
                      }
                    },
                  ),
                ),

                // Leyenda (igual que en la versión original)
                pw.Expanded(
                  flex: 2,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Leyenda',
                          style: pw.TextStyle(
                              fontSize: 10, fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 10),

                      // Crear elementos de la leyenda
                      ...datosOrdenados.take(10).map((entry) {
                        int index = datosOrdenados.indexOf(entry);
                        double porcentaje =
                            total > 0 ? (entry.value / total) * 100 : 0;

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