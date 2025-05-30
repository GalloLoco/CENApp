// Versión alternativa y simplificada del servicio de gráficas

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
    int maxItems = 10,
    String? etiquetaEjeX, // Nueva: etiqueta personalizada para eje X
    String? etiquetaEjeY, // Nueva: etiqueta personalizada para eje Y
    bool mostrarPorcentajes = true, // Nueva: opción para mostrar porcentajes
    PdfColor? colorBarras, // Nueva: color personalizable
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
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: PdfColors.grey300),
          borderRadius: pw.BorderRadius.circular(8),
        ),
        child: pw.Text(
          'No hay datos disponibles para generar el gráfico',
          style: pw.TextStyle(color: PdfColors.grey600),
        ),
      );
    }

    // Calcular total para porcentajes
    int total = entradas.fold(0, (sum, entry) => sum + entry.value);

    // Determinar el valor máximo para escalar las barras
    int maxValor = entradas.map((e) => e.value).reduce(math.max);
    int maxPorcentaje = maxValor > 0 ? (maxValor * 100 / total).round() : 0;

    // Color principal (azul por defecto)
    PdfColor colorPrincipal = colorBarras ?? PdfColors.blue600;

    // Definir márgenes y espacios
    const double margenIzquierdo = 150; // Espacio para etiquetas
    const double margenDerecho = 80; // Espacio para valores
    const double margenSuperior = 60; // Espacio para título y etiqueta
    const double margenInferior = 40; // Espacio para etiqueta del eje
    const double alturaBarras = 20; // Altura de cada barra
    const double espacioEntreBarras = 10;
    double escalaY = maxPorcentaje > 0 ? 100 / maxPorcentaje : 1;

    // Calcular altura dinámica basada en el número de elementos
    double alturaGrafico =
        (entradas.length * (alturaBarras + espacioEntreBarras)) +
            margenSuperior +
            margenInferior;

    // Ajustar altura si es necesario
    alto = math.max(alto, alturaGrafico);

    return pw.Container(
      width: ancho,
      height: alto,
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey200),
        borderRadius: pw.BorderRadius.circular(8),
        color: PdfColors.white,
      ),
      child: pw.Stack(
        children: [
          // Título principal
          pw.Positioned(
            top: 10,
            left: 0,
            right: 0,
            child: pw.Center(
              child: pw.Text(
                titulo,
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.grey800,
                ),
              ),
            ),
          ),

          // Área del gráfico con ejes
          pw.Positioned(
            top: margenSuperior,
            left: margenIzquierdo,
            right: margenDerecho,
            bottom: margenInferior,
            child: pw.CustomPaint(
              painter: (PdfGraphics canvas, PdfPoint size) {
                // Dibujar líneas de cuadrícula verticales
                final double anchoGrafico = size.x;
                final double altoGrafico = size.y;

                // Líneas de cuadrícula (cada 25%)
                for (int i = 0; i <= 4; i++) {
                  double x = (anchoGrafico * i) / 4;
                  canvas
                    ..setStrokeColor(PdfColors.grey200)
                    ..setLineWidth(0.5)
                    ..drawLine(x, 0, x, altoGrafico)
                    ..strokePath();
                }

                // Dibujar eje Y (vertical)
                canvas
                  ..setStrokeColor(PdfColors.grey700)
                  ..setLineWidth(1.5)
                  ..drawLine(0, 0, 0, altoGrafico)
                  ..strokePath();

                // Dibujar eje X (horizontal)
                canvas
                  ..setStrokeColor(PdfColors.grey700)
                  ..setLineWidth(1.5)
                  ..drawLine(0, altoGrafico, anchoGrafico, altoGrafico)
                  ..strokePath();
              },
            ),
          ),

          // Etiquetas del eje X (valores)
          pw.Positioned(
            top: margenSuperior - 20,
            left: margenIzquierdo,
            right: margenDerecho,
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                
                for (int i = 0; i <= 5; i++)
                  pw.Container(
                    
                    child: pw.Text(
                      '${(100 * i / 5 / escalaY).toStringAsFixed(0)}%',
                      style:
                          pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
                      textAlign: pw.TextAlign.right,
                    ),
                  ),
              
              ],
            ),
          ),

          // Título del eje X
          pw.Positioned(
            bottom: 5,
            left: margenIzquierdo,
            right: margenDerecho,
            child: pw.Center(
              child: pw.Text(
                etiquetaEjeX ??
                    (mostrarPorcentajes ? 'Porcentaje (%)' : 'Cantidad'),
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.grey700,
                ),
              ),
            ),
          ),

          // Título del eje Y (rotado)
          pw.Positioned(
            left: 10,
            top: margenSuperior,
            bottom: margenInferior,
            child: pw.Transform.rotate(
              angle: -math.pi / 2,
              child: pw.Container(
                alignment: pw.Alignment.center,
                child: pw.Text(
                  etiquetaEjeY ?? 'Categorías',
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.grey700,
                  ),
                ),
              ),
            ),
          ),

          // Barras y etiquetas
          pw.Positioned(
            top: margenSuperior,
            left: 0,
            right: 0,
            bottom: margenInferior,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                for (int index = 0; index < entradas.length; index++)
                  pw.Container(
                    height: alturaBarras,
                    margin: pw.EdgeInsets.only(bottom: espacioEntreBarras),
                    child: pw.Row(
                      children: [
                        // Etiqueta de la categoría
                        pw.Container(
                          width: margenIzquierdo - 10,
                          padding: pw.EdgeInsets.only(right: 10),
                          child: pw.Text(
                            entradas[index].key.length > 20
                                ? '${entradas[index].key.substring(0, 17)}...'
                                : entradas[index].key,
                            style: pw.TextStyle(
                                fontSize: 9, color: PdfColors.grey800),
                            textAlign: pw.TextAlign.right,
                            maxLines: 1,
                          ),
                        ),

                        // Contenedor para la barra
                        pw.Expanded(
                          child: pw.Container(
                            margin: pw.EdgeInsets.only(
                              left: 10, // ← agrega este margen izquierdo
                              right: margenDerecho -70,
                            ),
                            child: pw.Stack(
                              children: [
                                // Barra 360 es el 100% del ancho
                                pw.Container(
                                  width: ((ancho -
                                          margenIzquierdo -
                                          margenDerecho) *
                                      entradas[index].value /
                                      maxValor),
                                  height: alturaBarras,
                                  decoration: pw.BoxDecoration(
                                    color: colorPrincipal,
                                    borderRadius: pw.BorderRadius.circular(3),
                                    boxShadow: [
                                      pw.BoxShadow(
                                        color: PdfColors.grey300,
                                        offset: PdfPoint(1, 1),
                                        blurRadius: 2,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Valor y porcentaje
                        pw.Container(
                          width: margenDerecho - 10,
                          padding: pw.EdgeInsets.only(left: 10),
                          child: pw.Text(
                            mostrarPorcentajes
                                ? '${entradas[index].value} (${((entradas[index].value / total) * 100).toStringAsFixed(1)}%)'
                                : '${entradas[index].value}',
                            style: pw.TextStyle(
                              fontSize: 8,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.grey800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // Leyenda de información adicional
          if (entradas.length < datos.length)
            pw.Positioned(
              bottom: margenInferior + 20,
              right: 10,
              child: pw.Container(
                padding: pw.EdgeInsets.all(5),
                decoration: pw.BoxDecoration(
                  color: PdfColors.amber50,
                  borderRadius: pw.BorderRadius.circular(4),
                  border: pw.Border.all(color: PdfColors.amber300),
                ),
                child: pw.Text(
                  'Mostrando top $maxItems de ${datos.length} elementos',
                  style: pw.TextStyle(fontSize: 7, color: PdfColors.amber800),
                ),
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
                        style: pw.TextStyle(
                            fontSize: 10, fontWeight: pw.FontWeight.bold),
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
                                    int total = entradasCiudades.fold(
                                        0, (sum, entry) => sum + entry.value);
                                    MapEntry<String, int> ciudad =
                                        entradasCiudades[index];
                                    double tamano = ciudad.value / total;

                                    return pw.Padding(
                                      padding: pw.EdgeInsets.all(5),
                                      child: pw.Stack(
                                        alignment: pw.Alignment.center,
                                        children: [
                                          pw.Container(
                                            decoration: pw.BoxDecoration(
                                              color: colores[
                                                  index % colores.length],
                                              borderRadius:
                                                  pw.BorderRadius.circular(5),
                                            ),
                                          ),
                                          pw.Column(
                                            mainAxisAlignment:
                                                pw.MainAxisAlignment.center,
                                            children: [
                                              pw.Text(
                                                ciudad.key,
                                                style: pw.TextStyle(
                                                  fontSize: 9,
                                                  fontWeight:
                                                      pw.FontWeight.bold,
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
                                                  fontWeight:
                                                      pw.FontWeight.bold,
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
                        style: pw.TextStyle(
                            fontSize: 10, fontWeight: pw.FontWeight.bold),
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
                              MapEntry<String, int> colonia =
                                  entradasColonias[index];

                              return pw.Container(
                                width: (ancho / 2) * 0.45,
                                height: alto * 0.15,
                                decoration: pw.BoxDecoration(
                                  color: colores[(colores.length - 1 - index) %
                                      colores.length],
                                  borderRadius: pw.BorderRadius.circular(5),
                                ),
                                padding: pw.EdgeInsets.all(5),
                                child: pw.Column(
                                  mainAxisAlignment:
                                      pw.MainAxisAlignment.center,
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
  static List<Map<String, dynamic>> generarDatosGraficoBarra(
      Map<String, int> datos) {
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
    String? etiquetaEjeX, // Nueva: etiqueta personalizada para eje X
    String? etiquetaEjeY, // Nueva: etiqueta personalizada para eje Y
    bool mostrarValores = true, // Nueva: mostrar valores sobre las barras
    List<PdfColor>? colores, // Nueva: colores personalizables
  }) {
    // Procesar los datos
    List<Map<String, dynamic>> puntos = generarDatosGraficoBarra(datos);

    // Si no hay datos, mostrar mensaje
    if (puntos.isEmpty) {
      return pw.Container(
        width: ancho,
        height: alto,
        alignment: pw.Alignment.center,
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: PdfColors.grey300),
          borderRadius: pw.BorderRadius.circular(8),
        ),
        child: pw.Text(
          'No hay datos disponibles para generar el gráfico',
          style: pw.TextStyle(color: PdfColors.grey600),
        ),
      );
    }

    // Colores para las barras (con gradiente mejorado)
    List<PdfColor> coloresPredeterminados = colores ??
        [
          PdfColors.blue600,
          PdfColors.green600,
          PdfColors.orange600,
          PdfColors.purple600,
          PdfColors.red600,
          PdfColors.teal600,
          PdfColors.amber600,
        ];

    // Determinar el valor máximo para escalar el eje Y
    double maxPorcentaje =
        puntos.map((p) => p['porcentaje'] as double).reduce(math.max);
    double escalaY = maxPorcentaje > 0 ? 100 / maxPorcentaje : 1;

    // Definir márgenes
    const double margenIzquierdo = 60;
    const double margenDerecho = 30;
    const double margenSuperior = 60;
    const double margenInferior = 100; // Más espacio para etiquetas rotadas

    return pw.Container(
      width: ancho,
      height: alto,
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey200),
        borderRadius: pw.BorderRadius.circular(8),
        color: PdfColors.white,
      ),
      child: pw.Stack(
        children: [
          // Título principal
          pw.Positioned(
            top: 10,
            left: 0,
            right: 0,
            child: pw.Center(
              child: pw.Text(
                titulo,
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.grey800,
                ),
              ),
            ),
          ),

          // Área del gráfico
          pw.Positioned(
            top: margenSuperior,
            left: margenIzquierdo,
            right: margenDerecho,
            bottom: margenInferior,
            child: pw.CustomPaint(
              painter: (PdfGraphics canvas, PdfPoint size) {
                final double anchoGrafico = size.x;
                final double altoGrafico = size.y;

                // Dibujar líneas de cuadrícula horizontales
                for (int i = 0; i <= 5; i++) {
                  double y = altoGrafico - (altoGrafico * i / 5);

                  // Línea de cuadrícula
                  canvas
                    ..setStrokeColor(PdfColors.grey200)
                    ..setLineWidth(0.5)
                    ..drawLine(0, y, anchoGrafico, y)
                    ..strokePath();
                }

                // Dibujar eje Y
                canvas
                  ..setStrokeColor(PdfColors.grey700)
                  ..setLineWidth(2)
                  ..drawLine(0, 0, 0, altoGrafico)
                  ..strokePath();

                // Dibujar eje X
                canvas
                  ..setStrokeColor(PdfColors.grey700)
                  ..setLineWidth(2)
                  ..drawLine(0, altoGrafico, anchoGrafico, altoGrafico)
                  ..strokePath();

                // Dibujar barras
                if (puntos.isNotEmpty) {
                  double anchoBarra = anchoGrafico / (puntos.length * 1.5);
                  double espaciado = anchoBarra * 0.5;

                  for (int i = 0; i < puntos.length && i < 10; i++) {
                    final punto = puntos[i];
                    double porcentaje = punto['porcentaje'] as double;
                    double alturaBarra =
                        (porcentaje / 100) * altoGrafico * escalaY;

                    double x = espaciado + (i * (anchoBarra + espaciado));
                    double y = altoGrafico - alturaBarra;

                    // Sombra de la barra
                    canvas
                      ..setFillColor(PdfColors.grey300)
                      ..drawRect(x + 2, y + 2, anchoBarra, alturaBarra - 2)
                      ..fillPath();

                    // Barra principal
                    canvas
                      ..setFillColor(
                        punto['etiqueta'] == 'Riesgo Alto'
                            ? coloresPredeterminados[0]
                            : punto['etiqueta'] == 'Riesgo Medio'
                                ? coloresPredeterminados[1]
                                : punto['etiqueta'] == 'Riesgo Bajo'
                                    ? coloresPredeterminados[2]:
                                    coloresPredeterminados[i % coloresPredeterminados.length],
                                    
                      )
                      ..drawRect(x, y, anchoBarra, alturaBarra)
                      ..fillPath();

                    // Borde de la barra
                    canvas
                      ..setStrokeColor(coloresPredeterminados[
                          i % coloresPredeterminados.length])
                      ..setLineWidth(1)
                      ..drawRect(x, y, anchoBarra, alturaBarra)
                      ..strokePath();
                  }
                }
              },
            ),
          ),

          // Etiquetas del eje Y
          pw.Positioned(
            top: margenSuperior,
            left: 5,
            bottom: margenInferior,
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                for (int i = 0; i <= 5; i++)
                  pw.Container(
                    width: margenIzquierdo - 10,
                    child: pw.Text(
                      '${(100 * i / 5 / escalaY).toStringAsFixed(0)}%',
                      style:
                          pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
                      textAlign: pw.TextAlign.right,
                    ),
                  ),
              ],
            ),
          ),

          // Título del eje Y (rotado)
          pw.Positioned(
            left: -10,
            top: margenSuperior,
            bottom: margenInferior,
            child: pw.Transform.rotate(
              angle: -math.pi / 2,
              child: pw.Container(
                alignment: pw.Alignment.center,
                child: pw.Text(
                  etiquetaEjeY ?? 'Porcentaje (%)',
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.grey700,
                  ),
                ),
              ),
            ),
          ),

          // Etiquetas del eje X
          pw.Positioned(
            bottom: margenInferior - 20,
            left: margenIzquierdo,
            right: margenDerecho,
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
              children: [
                for (int i = 0; i < puntos.length && i < 10; i++)
                  pw.Container(
                    width: (ancho - margenIzquierdo - margenDerecho) /
                        math.min(puntos.length, 10),
                    child: pw.Transform.rotate(
                      angle: 0, // Rotar 30 grados
                      child: pw.Text(
                        puntos[i]['etiqueta'].toString().length > 12
                            ? '${puntos[i]['etiqueta'].toString().substring(0, 10)}...'
                            : puntos[i]['etiqueta'].toString(),
                        style:
                            pw.TextStyle(fontSize: 7, color: PdfColors.grey700),
                        textAlign: pw.TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Título del eje X
          pw.Positioned(
            bottom: 10,
            left: margenIzquierdo,
            right: margenDerecho,
            child: pw.Center(
              child: pw.Text(
                etiquetaEjeX ?? 'Categorías',
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.grey700,
                ),
              ),
            ),
          ),

          // Valores sobre las barras (si está habilitado)
          if (mostrarValores)
            pw.Positioned(
              top: margenSuperior,
              left: margenIzquierdo,
              right: margenDerecho,
              bottom: margenInferior,
              child: pw.Stack(
                children: [
                  // Iterar sobre los puntos para crear los valores
                  for (int i = 0; i < puntos.length && i < 10; i++)
                    pw.Builder(builder: (context) {
                      final punto = puntos[i];
                      double porcentaje = punto['porcentaje'] as double;
                      double anchoBarra =
                          (ancho - margenIzquierdo - margenDerecho) /
                              (puntos.length * 1.5);
                      double espaciado = anchoBarra * 0.5;
                      double alturaBarra =
                          ((alto - margenSuperior - margenInferior) *
                                  porcentaje /
                                  100) *
                              escalaY;

                      double xPos = espaciado + (i * (anchoBarra + espaciado));
                      double yPos = (alto - margenSuperior - margenInferior) -
                          alturaBarra -
                          15;

                      return pw.Positioned(
                        left: xPos,
                        top: yPos,
                        child: pw.Container(
                          width: anchoBarra,
                          alignment: pw.Alignment.center,
                          child: pw.Text(
                            '${punto['valor']}',
                            style: pw.TextStyle(
                              fontSize: 7,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.grey800,
                            ),
                          ),
                        ),
                      );
                    }),
                ],
              ),
            ),

          // Leyenda con información adicional
          pw.Positioned(
            bottom: 5,
            right: 10,
            child: pw.Container(
              padding: pw.EdgeInsets.all(5),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey100,
                borderRadius: pw.BorderRadius.circular(4),
                border: pw.Border.all(color: PdfColors.grey300),
              ),
              child: pw.Row(
                mainAxisSize: pw.MainAxisSize.min,
                children: [
                  pw.Icon(pw.IconData(0xe88e),
                      size: 10, color: PdfColors.grey600),
                  pw.SizedBox(width: 5),
                  pw.Text(
                    'Total elementos: ${datos.length}',
                    style: pw.TextStyle(fontSize: 7, color: PdfColors.grey600),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
