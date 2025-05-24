// lib/data/services/pdf_export_service.dart

import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path/path.dart' as path;
import 'package:flutter/services.dart' show rootBundle;
import '../../logica/formato_evaluacion.dart';
import './file_storage_service.dart';

/// Servicio para la exportación de documentos a PDF
class PdfExportService {
  final FileStorageService _fileService = FileStorageService();
   // Cache para el logo para evitar cargarlo múltiples veces
  static pw.MemoryImage? _logoImage;
  
  /// Carga el logo desde assets una sola vez y lo mantiene en cache
  Future<pw.MemoryImage> _cargarLogo() async {
    if (_logoImage == null) {
      try {
        // Cargar el logo desde assets
        final logoBytes = await rootBundle.load('assets/logoCenapp.png');
        _logoImage = pw.MemoryImage(logoBytes.buffer.asUint8List());
      } catch (e) {
        print('Error al cargar el logo: $e');
        // Si no se puede cargar el logo, creamos una imagen placeholder
        throw Exception('No se pudo cargar el logo de la aplicación');
      }
    }
    return _logoImage!;
  }
  
  /// Exporta el formato de evaluación a un archivo PDF
  Future<String> exportarFormatoPDF(FormatoEvaluacion formato, {Directory? directorio}) async {
    try {
       // Cargar el logo antes de crear el PDF
      final logo = await _cargarLogo();

       // Obtener directorio de documentos o usar el proporcionado
    final directorioFinal = directorio ?? await _fileService.obtenerDirectorioDocumentos();

      // Crear nombre de archivo PDF
    final nombreArchivo = 'Cenapp${formato.id}.pdf';
    final rutaArchivo = '${directorioFinal.path}/$nombreArchivo';

      // Crear documento PDF
      final pdf = pw.Document(
        compress: true,
        version: PdfVersion.pdf_1_5,
      );

      // Agregar páginas al PDF
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: pw.EdgeInsets.all(20),
          header: (context) => _construirEncabezadoPDF(formato,logo),
          build: (context) => [
            _construirInformacionGeneralPDF(formato.informacionGeneral),
            pw.SizedBox(height: 20),
            _construirSistemaEstructuralPDF(formato.sistemaEstructural),
            pw.SizedBox(height: 20),
            _construirEvaluacionDanosPDF(formato.evaluacionDanos),
            pw.SizedBox(height: 20),
            _construirUbicacionPDF(formato.ubicacionGeorreferencial),
          ],
          footer: (context) => pw.Container(
            alignment: pw.Alignment.centerRight,
            margin: const pw.EdgeInsets.only(top: 1.0 * PdfPageFormat.cm),
            child: pw.Text(
              'Página ${context.pageNumber} de ${context.pagesCount}',
              style: pw.TextStyle(color: PdfColors.grey),
            ),
          ),
        ),
      );

      // Guardar el archivo PDF
      final archivo = File(rutaArchivo);
      await archivo.writeAsBytes(await pdf.save());

      return rutaArchivo;
    } catch (e) {
      throw Exception('Error al exportar a PDF: $e');
    }
  }

  // Widgets para construir las diferentes secciones del PDF
 pw.Widget _construirEncabezadoPDF(FormatoEvaluacion formato, pw.MemoryImage logo) {
  // Formatear las coordenadas
  String coordenadasFormateadas = _formatearCoordenadas(
    formato.ubicacionGeorreferencial.latitud,
    formato.ubicacionGeorreferencial.longitud,
    formato.ubicacionGeorreferencial.altitud
  );
  
   return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 10),
      child: pw.Column(
        children: [
          // Fila superior con logos en las esquinas
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Logo izquierdo
              pw.Container(
                width: 60,
                height: 40,
                child: pw.Image(
                  logo,
                  fit: pw.BoxFit.contain,
                ),
              ),
              
              // Título central
              pw.Expanded(
                child: pw.Container(
                  alignment: pw.Alignment.center,
                  child: pw.Text(
                    'FORMATO DE EVALUACIÓN DE INMUEBLE',
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                    ),
                    textAlign: pw.TextAlign.center,
                  ),
                ),
              ),
              
              // Logo derecho
              pw.Container(
                width: 60,
                height: 40,
                child: pw.Image(
                  logo,
                  fit: pw.BoxFit.contain,
                ),
              ),
            ],
          ),
          
          pw.SizedBox(height: 8),
          
          // Información del formato centrada
          pw.Column(
            children: [
              pw.Text(
                'ID: ${formato.id}',
                style: pw.TextStyle(fontSize: 10),
              ),
              pw.Text(
                'Fecha de creación: ${_formatearFecha(formato.fechaCreacion)}',
                style: pw.TextStyle(fontSize: 10),
              ),
              pw.Text(
                'Evaluador: ${formato.gradoUsuario ?? ""} ${formato.usuarioCreador}',
                style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
              ),
              pw.Text(
                'Ubicación: $coordenadasFormateadas',
                style: pw.TextStyle(fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
}

// Añadir método para formatear coordenadas
String _formatearCoordenadas(double latitud, double longitud, double altitud) {
  // Redondear a 4 decimales para mayor precisión
  double lat = double.parse(latitud.toStringAsFixed(4));
  double lng = double.parse(longitud.toStringAsFixed(4));
  int alt = altitud.round(); // Redondear la altitud a entero
  
  String latDir = lat >= 0 ? "N" : "S";
  String lngDir = lng >= 0 ? "E" : "O";
  
  // Formato: "19.4326 N, 99.1332 O, 2240 msnm"
  return "${lat.abs()} $latDir, ${lng.abs()} $lngDir, ${alt.abs()} msnm";
}

  pw.Widget _construirInformacionGeneralPDF(InformacionGeneral info) {
    // Lista para almacenar elementos de topografía seleccionados
    List<String> topografiaSeleccionada = _obtenerSeleccionados(info.topografia);
    
    // Lista para almacenar elementos de uso seleccionados
    List<String> usosSeleccionados = _obtenerSeleccionados(info.usos);

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Encabezado con fondo azul claro
        _crearEncabezadoSeccion('INFORMACIÓN GENERAL'),
        pw.SizedBox(height: 10),

        // Datos de identificación
        _filaPDF('Nombre del inmueble:', info.nombreInmueble),

        // Dirección completa (desglosada)
        pw.Container(
          margin: pw.EdgeInsets.only(top: 10, bottom: 5),
          child: pw.Text('Dirección:',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        ),
        _filaPDF('Calle y número:', info.calle),
        _filaPDF('Colonia:', info.colonia),
        _filaPDF('Código Postal:', info.codigoPostal),
        _filaPDF('Pueblo o ciudad:', info.ciudadPueblo),
        _filaPDF('Delegación/Municipio:', info.delegacionMunicipio),
        _filaPDF('Estado:', info.estado),
        _filaPDF('Referencias:', info.referencias),

        // Contacto
        pw.Container(
          margin: pw.EdgeInsets.only(top: 10, bottom: 5),
          child: pw.Text('Contacto:',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        ),
        _filaPDF('Persona de contacto:', info.personaContacto),
        _filaPDF('Teléfono:', info.telefono),

        // Uso del inmueble
        pw.Container(
          margin: pw.EdgeInsets.only(top: 10, bottom: 5),
          child: pw.Text('Uso del inmueble:',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        ),
        _construirListaItems(usosSeleccionados),

        // Otro uso (si existe)
        info.otroUso.isNotEmpty
            ? _filaPDF('Otro uso:', info.otroUso)
            : pw.Container(),

        // Dimensiones
        pw.Container(
          margin: pw.EdgeInsets.only(top: 10, bottom: 5),
          child: pw.Text('Dimensiones:',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        ),
        _filaPDF('Frente X:', '${info.frenteX} metros'),
        _filaPDF('Frente Y:', '${info.frenteY} metros'),
        _filaPDF('Niveles:', '${info.niveles}'),
        _filaPDF('Ocupantes:', '${info.ocupantes}'),
        _filaPDF('Sótanos:', '${info.sotanos}'),

        // Topografía
        pw.Container(
          margin: pw.EdgeInsets.only(top: 10, bottom: 5),
          child: pw.Text('Topografía:',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        ),
        _construirListaItems(topografiaSeleccionada),
      ],
    );
  }

  pw.Widget _construirSistemaEstructuralPDF(SistemaEstructural sistema) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _crearEncabezadoSeccion('SISTEMA ESTRUCTURAL'),
        pw.SizedBox(height: 10),

        // Dirección X
        _construirSeccionCheckboxPDF('Dirección X', sistema.direccionX),
        pw.SizedBox(height: 10),

        // Dirección Y
        _construirSeccionCheckboxPDF('Dirección Y', sistema.direccionY),
        pw.SizedBox(height: 10),

        // Muros de mampostería
        _construirSeccionCheckboxPDF('Muros de Mampostería', sistema.murosMamposteria),
        pw.SizedBox(height: 10),

        // Sistemas de piso
        _construirSeccionCheckboxPDF('Sistemas de Piso', sistema.sistemasPiso),
        pw.SizedBox(height: 10),

        // Sistemas de techo
        _construirSeccionCheckboxPDF('Sistemas de Techo', sistema.sistemasTecho),
        pw.SizedBox(height: 5),
        sistema.otroTecho.isNotEmpty
            ? _filaPDF('Otro techo:', sistema.otroTecho)
            : pw.Container(),
        pw.SizedBox(height: 10),

        // Cimentación
        _construirSeccionCheckboxPDF('Cimentación', sistema.cimentacion),
        pw.SizedBox(height: 10),

        // Vulnerabilidad
        _construirSeccionCheckboxPDF('Vulnerabilidad', sistema.vulnerabilidad),
        pw.SizedBox(height: 10),

        // Posición en manzana
        _construirSeccionCheckboxPDF('Posición en Manzana', sistema.posicionManzana),
        pw.SizedBox(height: 10),

        // Otras características
        _construirSeccionCheckboxPDF('Otras Características', sistema.otrasCaracteristicas),
        pw.SizedBox(height: 10),

        // Separación de edificios
        _filaPDF('Separación edificios vecinos:', '${sistema.separacionEdificios} cm'),
      ],
    );
  }

  pw.Widget _construirEvaluacionDanosPDF(EvaluacionDanos evaluacion) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _crearEncabezadoSeccion('EVALUACIÓN DE DAÑOS'),
        pw.SizedBox(height: 10),

        // Daños geotécnicos
        _construirSeccionCheckboxPDF('Daños Geotécnicos', evaluacion.geotecnicos),
        pw.SizedBox(height: 10),

        // Inclinación del edificio
        _filaPDF('Inclinación del edificio:', '${evaluacion.inclinacionEdificio}%'),
        pw.SizedBox(height: 10),

        // Sección de Losas
        _construirSeccionLosasPDF(evaluacion),
        pw.SizedBox(height: 10),

        // Conexiones con falla
        _construirSeccionCheckboxPDF('Conexiones con Falla', evaluacion.conexionesFalla),
        pw.SizedBox(height: 10),

        // Tabla de daños a la estructura
        _construirTablaDanosEstructuraPDF(evaluacion.danosEstructura),
        pw.SizedBox(height: 10),

        // Tabla de mediciones
        _construirTablaMedicionesPDF(evaluacion.mediciones),
        pw.SizedBox(height: 10),

        // Entrepiso crítico
        pw.Text('Entrepiso crítico (más débil/dañado):',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        _filaPDF('Columnas con daño severo:', '${evaluacion.columnasConDanoSevero}'),
        _filaPDF('Total columnas en entrepiso:', '${evaluacion.totalColumnasEntrepiso}'),
        pw.SizedBox(height: 10),

        // Nivel de daño
        _construirSeccionCheckboxPDF('Nivel de Daño', evaluacion.nivelDano),
        pw.SizedBox(height: 10),

        // Otros daños
        _construirSeccionCheckboxPDF('Otros Daños', evaluacion.otrosDanos),
      ],
    );
  }

  pw.Widget _construirUbicacionPDF(UbicacionGeorreferencial ubicacion) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _crearEncabezadoSeccion('UBICACIÓN GEORREFERENCIAL'),
        pw.SizedBox(height: 10),

        // Existencia de planos
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.SizedBox(
              width: 150,
              child: pw.Text('Existen planos:',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ),
            pw.Expanded(
              child: pw.Text(ubicacion.existenPlanos ?? 'No especificado'),
            ),
          ],
        ),
        pw.SizedBox(height: 10),

        // Dirección y coordenadas
        _filaPDF('Dirección:', ubicacion.direccion),
        _filaPDF('Coordenadas:', 'Lat: ${ubicacion.latitud}, Long: ${ubicacion.longitud}'),
        pw.SizedBox(height: 15),

        // Sección de fotografías adjuntas
        ubicacion.rutasFotos.isNotEmpty
            ? _construirSeccionFotografiasPDF(ubicacion.rutasFotos)
            : pw.Container(
                padding: pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey100,
                  border: pw.Border.all(color: PdfColors.grey400),
                  borderRadius: pw.BorderRadius.circular(5),
                ),
                child: pw.Text('No hay fotografías adjuntas'),
              ),
      ],
    );
  }

  // Métodos auxiliares para la creación de componentes del PDF
  
  List<String> _obtenerSeleccionados(Map<String, bool> opciones) {
    return opciones.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();
  }

  pw.Widget _crearEncabezadoSeccion(String titulo) {
    return pw.Container(
      color: PdfColors.lightBlue50,
      padding: pw.EdgeInsets.all(8),
      child: pw.Text(
        titulo,
        style: pw.TextStyle(
          fontWeight: pw.FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  pw.Widget _construirListaItems(List<String> items) {
    return items.isNotEmpty
        ? pw.Padding(
            padding: pw.EdgeInsets.only(left: 20),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: items.map((item) => pw.Text('• $item')).toList(),
            ),
          )
        : pw.Padding(
            padding: pw.EdgeInsets.only(left: 20),
            child: pw.Text('No especificado'),
          );
  }

  pw.Widget _filaPDF(String etiqueta, String valor) {
    return pw.Padding(
      padding: pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 150,
            child: pw.Text(etiqueta,
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          ),
          pw.Expanded(child: pw.Text(valor)),
        ],
      ),
    );
  }

  pw.Widget _construirSeccionCheckboxPDF(String titulo, Map<String, bool> opciones) {
    List<pw.Widget> opcionesSeleccionadas = [];

    // Caso especial para la Vulnerabilidad con el caso específico
    if (titulo == 'Vulnerabilidad') {
      // Verificar manualmente si la opción de geometría irregular está activada
      bool tieneGeometriaIrregular = opciones.entries.any((entry) =>
          entry.key.contains('Geometría irregular') && entry.value == true);

      // Si está activada, asegurar que se agregue a la lista
      if (tieneGeometriaIrregular) {
        opcionesSeleccionadas.add(pw.Padding(
          padding: pw.EdgeInsets.only(left: 10, bottom: 2),
          child: pw.Text('• Geometría irregular en planta "L", "T", "H"'),
        ));
      }
    }

    // Procesamiento normal para el resto de opciones
    opciones.forEach((opcion, seleccionado) {
      // Saltar la opción de geometría irregular, ya que la manejamos separadamente
      if (seleccionado && !opcion.contains('Geometría irregular')) {
        opcionesSeleccionadas.add(pw.Padding(
          padding: pw.EdgeInsets.only(left: 10, bottom: 2),
          child: pw.Text('• $opcion'),
        ));
      }
    });

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(titulo, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 3),
        ...opcionesSeleccionadas,
        // Si no hay opciones seleccionadas, mostrar mensaje
        if (opcionesSeleccionadas.isEmpty)
          pw.Padding(
            padding: pw.EdgeInsets.only(left: 10),
            child: pw.Text('Ninguna opción seleccionada'),
          ),
      ],
    );
  }

  pw.Widget _construirSeccionLosasPDF(EvaluacionDanos evaluacion) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Losas:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 5),
        pw.Padding(
          padding: pw.EdgeInsets.only(left: 10),
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Opción de Colapso utilizando el mismo estilo que otras secciones de checkboxes
              pw.Row(
                children: [
                  pw.Container(
                    width: 10,
                    height: 10,
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(),
                    ),
                    child: evaluacion.losasColapso
                        ? pw.Center(
                            child: pw.Text(
                              '✓',
                              style: pw.TextStyle(
                                fontSize: 8,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                          )
                        : pw.Container(),
                  ),
                  pw.SizedBox(width: 5),
                  pw.Text('Colapso'),
                ],
              ),
              pw.SizedBox(width: 40),
              pw.Text('Grietas máx: ${evaluacion.losasGrietasMax} mm'),
              pw.SizedBox(width: 40),
              pw.Text('Flecha máx: ${evaluacion.losasFlechaMax} cm'),
            ],
          ),
        ),
      ],
    );
  }

  pw.Widget _construirTablaDanosEstructuraPDF(Map<String, Map<String, bool>> danosEstructura) {
    // Encabezados de la tabla
    List<String> tiposDano = [
      'Colapso',
      'Grietas cortante',
      'Grietas Flexión',
      'Aplastamiento',
      'Pandeo barras',
      'Pandeo placas',
      'Falla Soldadura'
    ];

    // Creamos las filas de la tabla
    List<List<pw.Widget>> filas = [];

    // Fila de encabezados
    List<pw.Widget> encabezados = [
      pw.Text('Estructura',
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
      ...tiposDano
          .map((tipo) => pw.Text(tipo,
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              textAlign: pw.TextAlign.center))
          .toList(),
    ];
    filas.add(encabezados);

    // Filas de datos
    danosEstructura.forEach((elementoEstructural, danosElemento) {
      List<pw.Widget> fila = [pw.Text(elementoEstructural)];

      // Para cada tipo de daño, agregamos un check si está seleccionado
      for (String tipoDano in tiposDano) {
        bool seleccionado = danosElemento[tipoDano] ?? false;
        fila.add(pw.Center(
          child: pw.Text(seleccionado ? '✓' : ''),
        ));
      }

      filas.add(fila);
    });

    // Construir la tabla
    return pw.Table(
      border: pw.TableBorder.all(),
      columnWidths: {
        0: pw.FlexColumnWidth(2),
        for (int i = 1; i <= tiposDano.length; i++) i: pw.FlexColumnWidth(1),
      },
      children: filas.map((fila) {
        return pw.TableRow(
          decoration: pw.BoxDecoration(
            color: filas.indexOf(fila) == 0 ? PdfColors.grey200 : null,
          ),
          children: fila,
        );
      }).toList(),
    );
  }

  pw.Widget _construirTablaMedicionesPDF(Map<String, Map<String, double>> mediciones) {
    // Encabezados de la tabla
    List<String> tiposMedicion = [
      'Ancho máximo de grieta (mm)',
      'Separación de estribos (cm)',
      'Longitud de traslape (cm)',
      'Sección/Espesor de muro (cm)'
    ];

    // Creamos las filas de la tabla
    List<List<pw.Widget>> filas = [];

    // Fila de encabezados
    List<pw.Widget> encabezados = [
      pw.Text('Estructura',
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
      ...tiposMedicion
          .map((tipo) => pw.Text(tipo,
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              textAlign: pw.TextAlign.center))
          .toList(),
    ];
    filas.add(encabezados);

    // Filas de datos
    mediciones.forEach((elementoEstructural, medicionesElemento) {
      List<pw.Widget> fila = [pw.Text(elementoEstructural)];

      // Para cada tipo de medición, agregamos el valor
      for (String tipoMedicion in tiposMedicion) {
        double valor = medicionesElemento[tipoMedicion] ?? 0.0;
        fila.add(pw.Center(
          child: pw.Text(valor.toString()),
        ));
      }

      filas.add(fila);
    });

    // Construir la tabla
    return pw.Table(
      border: pw.TableBorder.all(),
      columnWidths: {
        0: pw.FlexColumnWidth(2),
        for (int i = 1; i <= tiposMedicion.length; i++)
          i: pw.FlexColumnWidth(1.5),
      },
      children: filas.map((fila) {
        return pw.TableRow(
          decoration: pw.BoxDecoration(
            color: filas.indexOf(fila) == 0 ? PdfColors.grey200 : null,
          ),
          children: fila,
        );
      }).toList(),
    );
  }

  pw.Widget _construirSeccionFotografiasPDF(List<String> rutasFotos) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Título de la sección
        pw.Text('Fotografías adjuntas:',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 10),

        // Contenedor para las imágenes
        pw.Container(
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey400),
            borderRadius: pw.BorderRadius.circular(5),
          ),
          padding: pw.EdgeInsets.all(5),
          child: _construirGaleriaImagenesPDF(rutasFotos),
        ),
      ],
    );
  }

pw.Widget _construirGaleriaImagenesPDF(List<String> rutasFotos) {
    // Lista para almacenar las filas de imágenes
    List<pw.Widget> filas = [];

    // Procesamos las imágenes de 2 en 2
    for (int i = 0; i < rutasFotos.length; i += 2) {
      // Lista para las imágenes de esta fila
      List<pw.Widget> imagenesEnFila = [];

      // Primera imagen de la fila
      imagenesEnFila.add(
        pw.Expanded(
          child: pw.Padding(
            padding: pw.EdgeInsets.all(5),
            child: _cargarImagenPDF(rutasFotos[i]),
          ),
        ),
      );

      // Segunda imagen de la fila (si existe)
      if (i + 1 < rutasFotos.length) {
        imagenesEnFila.add(
          pw.Expanded(
            child: pw.Padding(
              padding: pw.EdgeInsets.all(5),
              child: _cargarImagenPDF(rutasFotos[i + 1]),
            ),
          ),
        );
      } else {
        // Si no hay segunda imagen, agregamos un espacio en blanco
        imagenesEnFila.add(pw.Expanded(child: pw.Container()));
      }

      // Agregamos la fila completa al listado
      filas.add(
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: imagenesEnFila,
        ),
      );

      // Separador entre filas
      filas.add(pw.SizedBox(height: 5));
    }

    // Si no hay imágenes, mostramos un mensaje
    if (rutasFotos.isEmpty) {
      filas.add(
        pw.Container(
          padding: pw.EdgeInsets.symmetric(vertical: 20),
          alignment: pw.Alignment.center,
          child: pw.Text(
            'No hay fotografías adjuntas',
            style: pw.TextStyle(
              fontSize: 12,
              color: PdfColors.grey700,
              fontStyle: pw.FontStyle.italic,
            ),
          ),
        ),
      );
    }

    // Devolvemos todas las filas dentro de una columna
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: filas,
    );
  }
}
/// Carga una imagen desde una ruta de archivo con manejo de errores
  pw.Widget _cargarImagenPDF(String rutaImagen) {
    try {
      // Intentar cargar la imagen
      final File imageFile = File(rutaImagen);
      if (imageFile.existsSync()) {
        final imageBytes = imageFile.readAsBytesSync();

        // Obtener nombre del archivo para mostrar como etiqueta
        final String nombreArchivo = path.basename(rutaImagen);

        return pw.Column(
          children: [
            // Imagen con borde
            pw.Container(
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey300),
              ),
              height: 120, // Altura fija para mantener orden
              child: pw.Image(
                pw.MemoryImage(imageBytes),
                fit: pw.BoxFit.contain, // Mantener proporciones
              ),
            ),
            // Etiqueta con el nombre de archivo
            pw.SizedBox(height: 3),
            pw.Text(
              nombreArchivo,
              style: pw.TextStyle(fontSize: 7),
              textAlign: pw.TextAlign.center,
            ),
          ],
        );
      } else {
        // Si el archivo no existe
        return _imagenNoDisponiblePDF("Archivo no encontrado");
      }
    } catch (e) {
      // En caso de error al cargar la imagen
      print('Error al cargar imagen para PDF: $e');
      return _imagenNoDisponiblePDF("Error al cargar imagen");
    }
  }

  /// Widget de placeholder para cuando no se puede cargar una imagen
  pw.Widget _imagenNoDisponiblePDF(String mensaje) {
    return pw.Container(
      height: 120,
      decoration: pw.BoxDecoration(
        color: PdfColors.grey200,
        border: pw.Border.all(color: PdfColors.grey400),
      ),
      alignment: pw.Alignment.center,
      child: pw.Column(
        mainAxisAlignment: pw.MainAxisAlignment.center,
        children: [
          pw.Text(
            '🖼️',
            style: pw.TextStyle(fontSize: 20),
          ),
          pw.SizedBox(height: 5),
          pw.Text(
            mensaje,
            style: pw.TextStyle(fontSize: 10),
            textAlign: pw.TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Formatea una fecha para mostrarla en formato DD/MM/YYYY
  String _formatearFecha(DateTime fecha) {
    return '${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year}';
  }

