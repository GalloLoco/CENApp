import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart'; // Para compute
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../logica/formato_evaluacion.dart';
import '../data/services/documento_service.dart';
import '../data/services/image_conversion_service.dart';

class DocumentoGuardadoScreen extends StatefulWidget {
  final FormatoEvaluacion formato;

  const DocumentoGuardadoScreen({
    Key? key,
    required this.formato,
  }) : super(key: key);

  @override
  _DocumentoGuardadoScreenState createState() =>
      _DocumentoGuardadoScreenState();
}

class _DocumentoGuardadoScreenState extends State<DocumentoGuardadoScreen> {
  final DocumentoService _documentoService = DocumentoService();
  bool _isLoading = false;
  String? _errorMessage;
  String? _jsonFilePath;
  bool _documentoGuardado = false;

  @override
  void initState() {
    super.initState();
    // Guardar el archivo JSON automáticamente al abrir la pantalla
    _guardarDocumentoJSON();
  }

  /// Guarda el documento en formato JSON
  Future<void> _guardarDocumentoJSON() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final filePath =
          await _documentoService.guardarFormatoJSON(widget.formato);
      setState(() {
        _jsonFilePath = filePath;
        _isLoading = false;
        _documentoGuardado = true;
      });

      // Mostrar mensaje de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Documento guardado correctamente'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al guardar el documento: $e';
        _isLoading = false;
      });
    }
  }

  /// Exporta el documento a PDF y lo guarda en Descargas
Future<void> _exportarPDF() async {
  setState(() {
    _isLoading = true;
    _errorMessage = null;
  });

  try {
    // Mostrar diálogo de progreso
    _mostrarIndicadorGuardando(context);
    
    // Generar el PDF y guardarlo directamente en Descargas
    final filePath = await _documentoService.exportarPDF(widget.formato);
    
    // Cerrar el diálogo de progreso
    Navigator.of(context, rootNavigator: true).pop();

    setState(() {
      _isLoading = false;
    });

    // Mostrar diálogo con la ruta donde se guardó el archivo
    _mostrarArchivoPDFGuardado(context, filePath);
  } catch (e) {
    // Cerrar el diálogo de progreso si está abierto
    Navigator.of(context, rootNavigator: true).pop();
    
    setState(() {
      _errorMessage = 'Error al exportar a PDF: $e';
      _isLoading = false;
    });
    
    // Mostrar error
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error al generar PDF: $e'),
        backgroundColor: Colors.red,
      ),
    );
  }
}
// Método para mostrar dónde se guardó el PDF
void _mostrarArchivoPDFGuardado(BuildContext context, String rutaArchivo) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('PDF guardado con éxito'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('El PDF se ha guardado en:'),
          SizedBox(height: 10),
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(4),
            ),
            width: double.infinity,
            child: Text(
              rutaArchivo,
              style: TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
          ),
          SizedBox(height: 15),
          Text('Ubicación: Carpeta de Descargas', 
               style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Aceptar'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            _compartirArchivo(rutaArchivo, 'application/pdf');
          },
          child: Text('Compartir'),
        ),
      ],
    ),
  );
}

  /// Exporta el documento a Excel
  Future<void> _exportarExcel() async {
  setState(() {
    _isLoading = true;
    _errorMessage = null;
  });

  try {
    // Mostrar diálogo de progreso
    _mostrarIndicadorGuardando(context);
    
    // Generar el Excel y guardarlo directamente en Descargas
    final filePath = await _documentoService.exportarExcel(widget.formato);
    
    // Cerrar el diálogo de progreso
    Navigator.of(context, rootNavigator: true).pop();

    setState(() {
      _isLoading = false;
    });

    // Mostrar diálogo con la ruta donde se guardó el archivo
    _mostrarArchivoExcelGuardado(context, filePath);
  } catch (e) {
    // Cerrar el diálogo de progreso si está abierto
    Navigator.of(context, rootNavigator: true).pop();
    
    setState(() {
      _errorMessage = 'Error al exportar a Excel: $e';
      _isLoading = false;
    });
    
    // Mostrar error
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error al generar Excel: $e'),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
      ),
    );
  }
}

  
  // Método para mostrar dónde se guardó el Excel
void _mostrarArchivoExcelGuardado(BuildContext context, String rutaArchivo) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Excel guardado con éxito'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('El archivo Excel se ha guardado en:'),
          SizedBox(height: 10),
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(4),
            ),
            width: double.infinity,
            child: Text(
              rutaArchivo,
              style: TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
          ),
          SizedBox(height: 15),
          Text('Ubicación: Carpeta de Descargas', 
               style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Aceptar'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            _compartirArchivo(rutaArchivo, 'application/vnd.ms-excel');
          },
          child: Text('Compartir'),
        ),
      ],
    ),
  );
}

  /// Compartir un archivo
  Future<void> _compartirArchivo(String filePath, String mimeType) async {
    try {
      await Share.shareXFiles(
        [XFile(filePath)],
        text: 'Documento generado por CENApp',
        subject: 'Formato de evaluación CENApp',
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al compartir: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Función para compartir el archivo JSON
  Future<void> _compartirJSON() async {
    if (_jsonFilePath == null) {
      setState(() {
        _errorMessage = 'No hay un documento para compartir';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No hay un documento para compartir'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Verificar primero si el JSON ya tiene imágenes base64
      final File jsonFile = File(_jsonFilePath!);
      final String jsonContent = await jsonFile.readAsString();
      final formato = FormatoEvaluacion.fromJsonString(jsonContent);

      // Si faltan imágenes base64, añadirlas
      if (formato.ubicacionGeorreferencial.rutasFotos.isNotEmpty &&
          (formato.ubicacionGeorreferencial.imagenesBase64 == null ||
              formato.ubicacionGeorreferencial.imagenesBase64!.isEmpty)) {
        // Mostrar mensaje
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Preparando imágenes para compartir...'),
            duration: Duration(seconds: 1),
          ),
        );

        try {
          // Convertir imágenes a base64
          Map<String, String> imagenesBase64 =
              await ImageConversionService.imagePathsToBase64Map(
                  formato.ubicacionGeorreferencial.rutasFotos);

          // Crear nueva ubicación con imágenes base64
          UbicacionGeorreferencial ubicacionConBase64 =
              UbicacionGeorreferencial(
            existenPlanos: formato.ubicacionGeorreferencial.existenPlanos,
            direccion: formato.ubicacionGeorreferencial.direccion,
            latitud: formato.ubicacionGeorreferencial.latitud,
            longitud: formato.ubicacionGeorreferencial.longitud,
            rutasFotos: formato.ubicacionGeorreferencial.rutasFotos,
            imagenesBase64: imagenesBase64,
          );

          // Actualizar el formato
          final formatoActualizado = FormatoEvaluacion(
            id: formato.id,
            fechaCreacion: formato.fechaCreacion,
            fechaModificacion: formato.fechaModificacion,
            usuarioCreador: formato.usuarioCreador,
            informacionGeneral: formato.informacionGeneral,
            sistemaEstructural: formato.sistemaEstructural,
            evaluacionDanos: formato.evaluacionDanos,
            ubicacionGeorreferencial: ubicacionConBase64,
          );

          // Guardar el formato actualizado
          await jsonFile.writeAsString(formatoActualizado.toJsonString());
        } catch (e) {
          print("Error al preparar imágenes base64 para compartir: $e");
          // Continuar compartiendo aunque falle la conversión
        }
      }

      // Compartir el archivo
      await _compartirArchivo(_jsonFilePath!, 'application/json');

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al compartir: $e';
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al compartir: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Función para guardar en descargas sin finalizar
  Future<void> _guardarEnDescargas() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Mostrar diálogo de progreso
      _mostrarIndicadorGuardando(context);

      // Crear una copia en la carpeta de descargas
      final directorioDescargas =
          await _documentoService.fileService.obtenerDirectorioDescargas();
      final nombreArchivo = 'Cenapp${widget.formato.id}.json';

      // Convertir el formato a JSON
      final jsonData = widget.formato.toJsonString();

      // Guardar archivo en descargas
      final rutaArchivo = await _documentoService.fileService.guardarArchivo(
          nombreArchivo, jsonData,
          directorio: directorioDescargas);

      // Cerrar el diálogo de progreso
      Navigator.of(context, rootNavigator: true).pop();

      setState(() {
        _isLoading = false;
      });

      // Mostrar mensaje con la ruta, pero sin navegación posterior
      _mostrarRutaGuardado(context, rutaArchivo);
    } catch (e) {
      // Cerrar el diálogo de progreso si está abierto
      Navigator.of(context, rootNavigator: true).pop();

      setState(() {
        _errorMessage = 'Error al guardar en Descargas: $e';
        _isLoading = false;
      });

      // Mostrar error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al guardar: $e'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

// Mostrar un indicador de progreso mientras se guarda en descargas
  void _mostrarIndicadorGuardando(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 15),
              Text('Guardando en Descargas...'),
              SizedBox(height: 10),
              Text(
                'No cierre la aplicación',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }

// Método mejorado para mostrar la ruta de guardado
  void _mostrarRutaGuardado(BuildContext context, String rutaArchivo) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Archivo guardado con éxito'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('El documento se ha guardado en:'),
            SizedBox(height: 10),
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(4),
              ),
              width: double.infinity,
              child: Text(
                rutaArchivo,
                style: TextStyle(fontFamily: 'monospace', fontSize: 12),
              ),
            ),
            SizedBox(height: 15),
            Text('Ubicación: Carpeta de Descargas',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(
                  context); // Solo cierra el diálogo, no navega a pantallas anteriores
            },
            child: Text('Aceptar'),
          ),
        ],
      ),
    );
  }

  /// Función para mostrar un mensaje de confirmación antes de regresar
  void _mostrarConfirmacionRegreso(BuildContext context) {
    // Solo mostrar confirmación si no se ha guardado el documento
    if (!_documentoGuardado) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('¿Quieres regresar al inicio?'),
            content: Text(
                'Una vez regresado, cualquier cambio no guardado se perderá.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancelar'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Cerrar el diálogo
                  Navigator.pop(context); // Regresar a NuevoFormatoScreen
                  Navigator.pop(context); // Regresar a HomeScreen
                },
                child: Text('Aceptar',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          );
        },
      );
    } else {
      // Si ya se guardó, simplemente navegar hacia atrás
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Regresar al inicio'),
            content: Text('¿Estás seguro de que quieres volver al inicio?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancelar'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Cerrar el diálogo
                  Navigator.pop(context); // Regresar a NuevoFormatoScreen
                  Navigator.pop(context); // Regresar a HomeScreen
                },
                child: Text('Aceptar',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            _mostrarConfirmacionRegreso(context);
          },
        ),
        title: Text(
          'Documento Guardado',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15.0),
            child: Image.asset(
              'assets/logoCenapp.png',
              height: 40,
            ),
          ),
        ],
      ),
      body: _isLoading
          ? _buildLoadingScreen()
          : _errorMessage != null
              ? _buildErrorScreen()
              : _buildSuccessScreen(),
    );
  }

  /// Construye la pantalla de carga
  Widget _buildLoadingScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Colors.blue),
          SizedBox(height: 20),
          Text('Procesando documento...'),
        ],
      ),
    );
  }

  /// Construye la pantalla de error
  Widget _buildErrorScreen() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 80, color: Colors.red),
            SizedBox(height: 20),
            Text(
              'Ocurrió un error',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            Text(
              _errorMessage!,
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: _guardarDocumentoJSON,
              icon: Icon(Icons.refresh),
              label: Text('Intentar nuevamente'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Construye la pantalla de éxito
  Widget _buildSuccessScreen() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 40),
          Icon(
            Icons.assignment_turned_in,
            size: 100,
            color: Colors.green,
          ),
          SizedBox(height: 30),
          Text(
            'Archivo "${_getNombreArchivo()}" creado con éxito.',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 10),
          Text(
            'Puede exportar o compartir el archivo en varios formatos.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 40),
          _buildExportButton(
            Icons.picture_as_pdf,
            'Exportar a PDF',
            _exportarPDF,
            Colors.red,
          ),
          SizedBox(height: 20),
          _buildExportButton(
            Icons.table_chart,
            'Exportar a Excel',
            _exportarExcel,
            Colors.green,
          ),
          SizedBox(height: 20),
          _buildExportButton(
            Icons.share,
            'Compartir JSON',
            _compartirJSON,
            Colors.blue,
          ),
          SizedBox(height: 20),
          _buildExportButton(
            Icons.save_alt,
            'Guardar JSON',
            _guardarEnDescargas,
            Colors.teal,
          ),
        ],
      ),
    );
  }

  Widget _buildExportButton(
    IconData icon,
    String text,
    VoidCallback onPressed,
    Color color,
  ) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: EdgeInsets.symmetric(vertical: 15),
        ),
        icon: Icon(icon, color: Colors.white),
        label: Text(
          text,
          style: TextStyle(
            fontSize: 18,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  /// Obtiene el nombre del archivo basado en el ID del formato
  String _getNombreArchivo() {
    return "Cenapp${widget.formato.id}.json";
  }
}
