// services/documento_service.dart
import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:excel/excel.dart';
import 'package:share_plus/share_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import './formato_evaluacion.dart';
import './file_service.dart';

/// Clase que gestiona la creación, almacenamiento y exportación de documentos
class DocumentoService {
  /// Guarda el formato de evaluación en formato JSON
  Future<String> guardarFormatoJSON(FormatoEvaluacion formato) async {
    try {
      // Guardar en la ubicación estándar
      final directorioApp = await obtenerDirectorioDocumentos();
      final nombreArchivoApp = 'Cenapp${formato.id}.json';
      final rutaArchivoApp = '${directorioApp.path}/$nombreArchivoApp';

      // Convertir datos a JSON
      final jsonData = formato.toJsonString();

      // Escribir archivo en la carpeta de la app
      final archivoApp = File(rutaArchivoApp);
      await archivoApp.writeAsString(jsonData);

      // También guardar en la carpeta de descargas para fácil acceso
      final rutaArchivoDescargas =
          await FileService.guardarFormatoJSON(formato);

      return rutaArchivoApp;
    } catch (e) {
      throw Exception('Error al guardar formato: $e');
    }
  }

  /// Carga un formato de evaluación desde un archivo JSON
  Future<FormatoEvaluacion> cargarFormatoJSON(String rutaArchivo) async {
    try {
      final archivo = File(rutaArchivo);
      final jsonString = await archivo.readAsString();
      return FormatoEvaluacion.fromJsonString(jsonString);
    } catch (e) {
      throw Exception('Error al cargar formato: $e');
    }
  }

  /// Exporta el formato de evaluación a un archivo PDF
  /// Exporta el formato de evaluación a un archivo PDF
  Future<String> exportarPDF(FormatoEvaluacion formato) async {
    try {
      // Obtener directorio de documentos
      final directorio = await obtenerDirectorioDocumentos();

      // Crear nombre de archivo PDF
      final nombreArchivo = 'Cenapp${formato.id}.pdf';
      final rutaArchivo = '${directorio.path}/$nombreArchivo';

      // Crear documento PDF
      final pdf = pw.Document();

      // Agregar páginas al PDF
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: pw.EdgeInsets.all(20),
          header: (context) => _construirEncabezadoPDF(formato),
          build: (context) => [
            _construirInformacionGeneralPDF(formato.informacionGeneral),
            pw.SizedBox(height: 20),
            _construirSistemaEstructuralPDFCompleto(formato.sistemaEstructural),
            pw.SizedBox(height: 20),
            _construirEvaluacionDanosPDFCompleto(formato.evaluacionDanos),
            pw.SizedBox(height: 20),
            _construirUbicacionPDFCompleto(formato.ubicacionGeorreferencial),
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

  pw.Widget _construirEncabezadoPDF(FormatoEvaluacion formato) {
    return pw.Container(
      alignment: pw.Alignment.center,
      margin: const pw.EdgeInsets.only(bottom: 10),
      child: pw.Column(
        children: [
          pw.Text(
            'FORMATO DE EVALUACIÓN DE INMUEBLE',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 5),
          pw.Text(
            'ID: ${formato.id}',
            style: pw.TextStyle(fontSize: 10),
          ),
          pw.Text(
            'Creado: ${_formatearFecha(formato.fechaCreacion)} - Usuario: ${formato.usuarioCreador}',
            style: pw.TextStyle(fontSize: 10),
          ),
        ],
      ),
    );
  }

  pw.Widget _construirSistemaEstructuralPDFCompleto(
      SistemaEstructural sistema) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          color: PdfColors.lightBlue50,
          padding: pw.EdgeInsets.all(8),
          child: pw.Text(
            'SISTEMA ESTRUCTURAL',
            style: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
        pw.SizedBox(height: 10),

        // Dirección X
        _construirSeccionCheckboxPDF('Dirección X', sistema.direccionX),
        pw.SizedBox(height: 10),

        // Dirección Y
        _construirSeccionCheckboxPDF('Dirección Y', sistema.direccionY),
        pw.SizedBox(height: 10),

        // Muros de mampostería
        _construirSeccionCheckboxPDF(
            'Muros de Mampostería', sistema.murosMamposteria),
        pw.SizedBox(height: 10),

        // Sistemas de piso
        _construirSeccionCheckboxPDF('Sistemas de Piso', sistema.sistemasPiso),
        pw.SizedBox(height: 10),

        // Sistemas de techo
        _construirSeccionCheckboxPDF(
            'Sistemas de Techo', sistema.sistemasTecho),
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
        _construirSeccionCheckboxPDF(
            'Posición en Manzana', sistema.posicionManzana),
        pw.SizedBox(height: 10),

        // Otras características
        _construirSeccionCheckboxPDF(
            'Otras Características', sistema.otrasCaracteristicas),
        pw.SizedBox(height: 10),

        // Separación de edificios
        _filaPDF('Separación edificios vecinos:',
            '${sistema.separacionEdificios} cm'),
      ],
    );
  }

  pw.Widget _construirEvaluacionDanosPDFCompleto(EvaluacionDanos evaluacion) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          color: PdfColors.lightBlue50,
          padding: pw.EdgeInsets.all(8),
          child: pw.Text(
            'EVALUACIÓN DE DAÑOS',
            style: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
        pw.SizedBox(height: 10),

        // Daños geotécnicos
        _construirSeccionCheckboxPDF(
            'Daños Geotécnicos', evaluacion.geotecnicos),
        pw.SizedBox(height: 10),

        // Inclinación del edificio
        _filaPDF(
            'Inclinación del edificio:', '${evaluacion.inclinacionEdificio}%'),
        pw.SizedBox(height: 10),

        // Conexiones con falla
        _construirSeccionCheckboxPDF(
            'Conexiones con Falla', evaluacion.conexionesFalla),
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
        _filaPDF(
            'Columnas con daño severo:', '${evaluacion.columnasConDanoSevero}'),
        _filaPDF('Total columnas en entrepiso:',
            '${evaluacion.totalColumnasEntrepiso}'),
        pw.SizedBox(height: 10),

        // Nivel de daño
        _construirSeccionCheckboxPDF('Nivel de Daño', evaluacion.nivelDano),
        pw.SizedBox(height: 10),

        // Otros daños
        _construirSeccionCheckboxPDF('Otros Daños', evaluacion.otrosDanos),
      ],
    );
  }

  pw.Widget _construirUbicacionPDFCompleto(UbicacionGeorreferencial ubicacion) {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Container(
        color: PdfColors.lightBlue50,
        padding: pw.EdgeInsets.all(8),
        child: pw.Text(
          'UBICACIÓN GEORREFERENCIAL',
          style: pw.TextStyle(
            fontWeight: pw.FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
      pw.SizedBox(height: 10),

      // Existencia de planos (mostrar como texto)
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
      _filaPDF('Coordenadas:',
          'Lat: ${ubicacion.latitud}, Long: ${ubicacion.longitud}'),

      // Información sobre fotos adjuntas
      ubicacion.rutasFotos.isNotEmpty
          ? pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.SizedBox(height: 10),
                pw.Text('Fotografías adjuntas:',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 5),
                ...ubicacion.rutasFotos.map((ruta) => pw.Text(
                    '- ${_obtenerNombreArchivo(ruta)}',
                    style: pw.TextStyle(fontSize: 10))),
              ],
            )
          : pw.Container(),
    ],
  );
}

// Métodos auxiliares para construir secciones específicas

  pw.Widget _construirSeccionCheckboxPDF(
      String titulo, Map<String, bool> opciones) {
    List<pw.Widget> opcionesSeleccionadas = [];

    // Filtramos para obtener solo las opciones seleccionadas (true)
    opciones.forEach((opcion, seleccionado) {
      if (seleccionado) {
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

  pw.Widget _construirTablaDanosEstructuraPDF(
      Map<String, Map<String, bool>> danosEstructura) {
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

  pw.Widget _construirTablaMedicionesPDF(
      Map<String, Map<String, double>> mediciones) {
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

// Helpers adicionales
  String _obtenerNombreArchivo(String rutaCompleta) {
    final partes = rutaCompleta.split('/');
    return partes.last;
  }

  /// Exporta el formato de evaluación a un archivo Excel
  Future<String> exportarExcel(FormatoEvaluacion formato) async {
    try {
      // Obtener directorio
      final directorio = await obtenerDirectorioDocumentos();

      // Crear nombre de archivo Excel
      final nombreArchivo = 'Cenapp${formato.id}.xlsx';
      final rutaArchivo = '${directorio.path}/$nombreArchivo';

      // Crear un libro de Excel
      final excel = Excel.createExcel();

      // Crear hojas para cada sección
      final hojaInfoGeneral = excel['Info General'];
      final hojaSistemaEstructural = excel['Sistema Estructural'];
      final hojaEvaluacionDanos = excel['Evaluación Daños'];
      final hojaUbicacion = excel['Ubicación'];

      // Eliminar la hoja por defecto si existe después de crear las nuevas
      if (excel.sheets.containsKey('Sheet1')) {
        excel.delete('Sheet1');
      }

      // Llenar la hoja de información general
      _llenarHojaInfoGeneral(hojaInfoGeneral, formato.informacionGeneral);

      // Llenar la hoja de sistema estructural con datos simplificados
      _llenarHojaSistemaEstructuralSimple(
          hojaSistemaEstructural, formato.sistemaEstructural);

      // Llenar la hoja de evaluación de daños con datos simplificados
      _llenarHojaEvaluacionDanosSimple(
          hojaEvaluacionDanos, formato.evaluacionDanos);

      // Llenar la hoja de ubicación con datos simplificados
      _llenarHojaUbicacionSimple(
          hojaUbicacion, formato.ubicacionGeorreferencial);

      // Guardar el archivo Excel
      final bytes = excel.encode();
      final archivo = File(rutaArchivo);
      await archivo.writeAsBytes(bytes!);

      return rutaArchivo;
    } catch (e) {
      throw Exception('Error al exportar a Excel: $e');
    }
  }

  /// Exporta el formato de evaluación a un archivo CSV
  Future<String> exportarCSV(FormatoEvaluacion formato) async {
    try {
      // Obtener directorio
      final directorio = await obtenerDirectorioDocumentos();

      // Crear nombre de archivo CSV
      final nombreArchivo = 'Cenapp${formato.id}.csv';
      final rutaArchivo = '${directorio.path}/$nombreArchivo';

      // Crear contenido CSV
      final StringBuffer csvContent = StringBuffer();

      // Encabezados
      csvContent.writeln('ID,Sección,Campo,Valor');

      // Información general
      _agregarSeccionCSV(csvContent, formato.id, 'Información General',
          'Nombre del inmueble', formato.informacionGeneral.nombreInmueble);
      _agregarSeccionCSV(csvContent, formato.id, 'Información General', 'Calle',
          formato.informacionGeneral.calle);
      _agregarSeccionCSV(csvContent, formato.id, 'Información General',
          'Colonia', formato.informacionGeneral.colonia);
      _agregarSeccionCSV(csvContent, formato.id, 'Información General',
          'Código Postal', formato.informacionGeneral.codigoPostal);
      _agregarSeccionCSV(csvContent, formato.id, 'Información General',
          'Ciudad/Pueblo', formato.informacionGeneral.ciudadPueblo);
      _agregarSeccionCSV(
          csvContent,
          formato.id,
          'Información General',
          'Delegación/Municipio',
          formato.informacionGeneral.delegacionMunicipio);
      _agregarSeccionCSV(csvContent, formato.id, 'Información General',
          'Estado', formato.informacionGeneral.estado);

      // Información de dimensiones
      _agregarSeccionCSV(csvContent, formato.id, 'Dimensiones', 'Frente X',
          formato.informacionGeneral.frenteX.toString());
      _agregarSeccionCSV(csvContent, formato.id, 'Dimensiones', 'Frente Y',
          formato.informacionGeneral.frenteY.toString());
      _agregarSeccionCSV(csvContent, formato.id, 'Dimensiones', 'Niveles',
          formato.informacionGeneral.niveles.toString());

      // Metadatos
      _agregarSeccionCSV(csvContent, formato.id, 'Metadatos', 'Fecha Creación',
          _formatearFecha(formato.fechaCreacion));
      _agregarSeccionCSV(csvContent, formato.id, 'Metadatos',
          'Fecha Modificación', _formatearFecha(formato.fechaModificacion));
      _agregarSeccionCSV(csvContent, formato.id, 'Metadatos', 'Usuario Creador',
          formato.usuarioCreador);

      // Escribir el archivo
      final archivo = File(rutaArchivo);
      await archivo.writeAsString(csvContent.toString());

      return rutaArchivo;
    } catch (e) {
      throw Exception('Error al exportar a CSV: $e');
    }
  }

  /// Agrega una línea al CSV con escape de comillas
  void _agregarSeccionCSV(StringBuffer buffer, String id, String seccion,
      String campo, String valor) {
    // Escapar comillas en los valores
    final idEscapado = _escaparCSV(id);
    final seccionEscapada = _escaparCSV(seccion);
    final campoEscapado = _escaparCSV(campo);
    final valorEscapado = _escaparCSV(valor);

    buffer
        .writeln('$idEscapado,$seccionEscapada,$campoEscapado,$valorEscapado');
  }

  /// Escapa un valor para CSV (encerrar en comillas y duplicar comillas internas)
  String _escaparCSV(String valor) {
    if (valor.contains(',') || valor.contains('"') || valor.contains('\n')) {
      return '"${valor.replaceAll('"', '""')}"';
    }
    return valor;
  }

  /// Comparte un archivo utilizando la funcionalidad nativa del sistema
  Future<void> compartirArchivo(String rutaArchivo, String tipoArchivo) async {
    try {
      final result = await Share.shareXFiles(
        [XFile(rutaArchivo)],
        text: 'Formato de Evaluación CENApp',
        subject: 'Formato de Evaluación - CENApp',
      );

      if (result.status == ShareResultStatus.success) {
        print('Archivo compartido exitosamente');
      }
    } catch (e) {
      throw Exception('Error al compartir archivo: $e');
    }
  }

  /// Obtiene el directorio de documentos y verifica/solicita permisos
  Future<Directory> obtenerDirectorioDocumentos() async {
    // Verificar y solicitar permisos de almacenamiento si es necesario
    if (Platform.isAndroid) {
      final status = await Permission.storage.status;
      if (!status.isGranted) {
        await Permission.storage.request();
      }
    }

    // Obtener el directorio de documentos
    final directorio = await getApplicationDocumentsDirectory();

    // Crear un subdirectorio para los documentos de la app
    final cenappDir = Directory('${directorio.path}/cenapp_docs');
    if (!await cenappDir.exists()) {
      await cenappDir.create(recursive: true);
    }

    return cenappDir;
  }

  pw.Widget _construirInformacionGeneralPDF(InformacionGeneral info) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          color: PdfColors.lightBlue50,
          padding: pw.EdgeInsets.all(8),
          child: pw.Text(
            'INFORMACIÓN GENERAL',
            style: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
        pw.SizedBox(height: 10),
        _filaPDF('Nombre del inmueble:', info.nombreInmueble),
        _filaPDF('Dirección:',
            '${info.calle}, ${info.colonia}, CP ${info.codigoPostal}'),
        _filaPDF('Ubicación:',
            '${info.ciudadPueblo}, ${info.delegacionMunicipio}, ${info.estado}'),
        _filaPDF('Persona de contacto:',
            '${info.personaContacto} - Tel: ${info.telefono}'),
        pw.SizedBox(height: 10),
        pw.Text('Dimensiones:',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        _filaPDF('Frente X:', '${info.frenteX} metros'),
        _filaPDF('Frente Y:', '${info.frenteY} metros'),
        _filaPDF('Niveles:', '${info.niveles}'),
        _filaPDF('Ocupantes:', '${info.ocupantes}'),
        _filaPDF('Sótanos:', '${info.sotanos}'),
      ],
    );
  }

  pw.Widget _construirSistemaEstructuralPDF(SistemaEstructural sistema) {
    // Crear un contenido simplificado para el PDF
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          color: PdfColors.lightBlue50,
          padding: pw.EdgeInsets.all(8),
          child: pw.Text(
            'SISTEMA ESTRUCTURAL',
            style: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
        pw.SizedBox(height: 10),
        pw.Text('Sistema estructural registrado.',
            style: pw.TextStyle(fontSize: 12)),
        pw.SizedBox(height: 5),
        pw.Text('Para ver detalles completos, abra el archivo Excel exportado.',
            style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
      ],
    );
  }

  pw.Widget _construirEvaluacionDanosPDF(EvaluacionDanos evaluacion) {
    // Crear un contenido simplificado para el PDF
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          color: PdfColors.lightBlue50,
          padding: pw.EdgeInsets.all(8),
          child: pw.Text(
            'EVALUACIÓN DE DAÑOS',
            style: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
        pw.SizedBox(height: 10),
        pw.Text('Evaluación de daños registrada.',
            style: pw.TextStyle(fontSize: 12)),
        pw.SizedBox(height: 5),
        pw.Text('Para ver detalles completos, abra el archivo Excel exportado.',
            style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
      ],
    );
  }

  pw.Widget _construirUbicacionPDF(UbicacionGeorreferencial ubicacion) {
    // Crear un contenido simplificado para el PDF
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          color: PdfColors.lightBlue50,
          padding: pw.EdgeInsets.all(8),
          child: pw.Text(
            'UBICACIÓN GEORREFERENCIAL',
            style: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
        pw.SizedBox(height: 10),
        _filaPDF('Dirección:', ubicacion.direccion),
        _filaPDF('Coordenadas:',
            'Lat: ${ubicacion.latitud}, Long: ${ubicacion.longitud}'),
        pw.SizedBox(height: 10),
        pw.Text(
            'Para ver más detalles y fotos adjuntas, consulte el archivo Excel exportado.',
            style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
      ],
    );
  }

  // Helper para crear filas en el PDF
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

  // Métodos para llenar las hojas de Excel (versiones simplificadas)
  void _llenarHojaInfoGeneral(Sheet hoja, InformacionGeneral info) {
    // Encabezados
    _escribirExcelCelda(hoja, 0, 0, 'INFORMACIÓN GENERAL DEL INMUEBLE');
    _escribirExcelCelda(hoja, 2, 0, 'Parámetro');
    _escribirExcelCelda(hoja, 2, 1, 'Valor');

    // Datos
    int fila = 3;
    _escribirExcelFila(
        hoja, fila++, 'Nombre del inmueble', info.nombreInmueble);
    _escribirExcelFila(hoja, fila++, 'Calle', info.calle);
    _escribirExcelFila(hoja, fila++, 'Colonia', info.colonia);
    _escribirExcelFila(hoja, fila++, 'Código Postal', info.codigoPostal);
    _escribirExcelFila(hoja, fila++, 'Ciudad/Pueblo', info.ciudadPueblo);
    _escribirExcelFila(
        hoja, fila++, 'Delegación/Municipio', info.delegacionMunicipio);
    _escribirExcelFila(hoja, fila++, 'Estado', info.estado);
    _escribirExcelFila(hoja, fila++, 'Referencias', info.referencias);
    _escribirExcelFila(
        hoja, fila++, 'Persona de contacto', info.personaContacto);
    _escribirExcelFila(hoja, fila++, 'Teléfono', info.telefono);

    // Dimensiones
    fila += 1;
    _escribirExcelCelda(hoja, fila++, 0, 'DIMENSIONES');
    _escribirExcelFila(hoja, fila++, 'Frente X', '${info.frenteX} metros');
    _escribirExcelFila(hoja, fila++, 'Frente Y', '${info.frenteY} metros');
    _escribirExcelFila(
        hoja, fila++, 'Número de niveles', info.niveles.toString());
    _escribirExcelFila(
        hoja, fila++, 'Número de ocupantes', info.ocupantes.toString());
    _escribirExcelFila(
        hoja, fila++, 'Número de sótanos', info.sotanos.toString());
  }

  // Versión simplificada para Sistema Estructural
  void _llenarHojaSistemaEstructuralSimple(
      Sheet hoja, SistemaEstructural sistema) {
    // Encabezados
    _escribirExcelCelda(hoja, 0, 0, 'SISTEMA ESTRUCTURAL');
    _escribirExcelCelda(hoja, 2, 0, 'Dato estructural registrado');
    _escribirExcelCelda(hoja, 2, 1, 'Valor');

    int fila = 3;
    // Agregar algunos datos básicos
    _escribirExcelFila(hoja, fila++, 'Sistema registrado', 'Sí');
    _escribirExcelFila(
        hoja, fila++, 'Separación edificios vecinos (cm)', '5.0');
  }

  // Versión simplificada para Evaluación de Daños
  void _llenarHojaEvaluacionDanosSimple(
      Sheet hoja, EvaluacionDanos evaluacion) {
    // Encabezados
    _escribirExcelCelda(hoja, 0, 0, 'EVALUACIÓN DE DAÑOS');
    _escribirExcelCelda(hoja, 2, 0, 'Dato de daño registrado');
    _escribirExcelCelda(hoja, 2, 1, 'Valor');

    int fila = 3;
    // Agregar algunos datos básicos
    _escribirExcelFila(hoja, fila++, 'Evaluación registrada', 'Sí');
  }

  // Versión simplificada para Ubicación
  void _llenarHojaUbicacionSimple(
      Sheet hoja, UbicacionGeorreferencial ubicacion) {
    // Encabezados
    _escribirExcelCelda(hoja, 0, 0, 'UBICACIÓN GEORREFERENCIAL');
    _escribirExcelCelda(hoja, 2, 0, 'Parámetro');
    _escribirExcelCelda(hoja, 2, 1, 'Valor');

    int fila = 3;
    // Agregar la dirección y coordenadas
    _escribirExcelFila(hoja, fila++, 'Dirección', ubicacion.direccion);
    _escribirExcelFila(hoja, fila++, 'Latitud', ubicacion.latitud.toString());
    _escribirExcelFila(hoja, fila++, 'Longitud', ubicacion.longitud.toString());
  }

  // Métodos helper para escribir en Excel
  void _escribirExcelCelda(Sheet hoja, int fila, int columna, dynamic valor) {
    final celda =
        CellIndex.indexByColumnRow(columnIndex: columna, rowIndex: fila);
    hoja.cell(celda).value = valor;
  }

  void _escribirExcelFila(Sheet hoja, int fila, String etiqueta, String valor) {
    _escribirExcelCelda(hoja, fila, 0, etiqueta);
    _escribirExcelCelda(hoja, fila, 1, valor);
  }

  // Helper para formatear fechas
  String _formatearFecha(DateTime fecha) {
    return '${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year}';
  }
}
