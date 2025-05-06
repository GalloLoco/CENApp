import 'dart:async';
//import 'dart:io';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../logica/formato_evaluacion.dart';
import '../data/services/documento_service.dart';

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

  /// Exporta el documento a PDF
  Future<void> _exportarPDF() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Mostrar mensaje de progreso
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Generando PDF...'),
          duration: Duration(seconds: 1),
        ),
      );

      final filePath = await _documentoService.exportarPDF(widget.formato);

      setState(() {
        _isLoading = false;
      });

      // Mostrar mensaje de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Archivo PDF creado con éxito'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      // Pequeña pausa para que el usuario vea el mensaje de éxito
      await Future.delayed(Duration(milliseconds: 1000));

      // Compartir el archivo
      _compartirArchivo(filePath, 'application/pdf');
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al exportar a PDF: $e';
        _isLoading = false;
      });

      // Mostrar mensaje de error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al generar PDF: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Exporta el documento a Excel
  Future<void> _exportarExcel() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Mostrar mensaje de progreso
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Generando Excel... Este proceso puede tardar unos segundos.'),
          duration: Duration(seconds: 2),
        ),
      );

      // Intentar exportar con un tiempo de espera más largo (90 segundos)
      String filePath;
      try {
        filePath = await _documentoService
            .exportarExcel(widget.formato)
            .timeout(Duration(seconds: 90));
      } catch (exportError) {
        if (exportError is TimeoutException) {
          throw Exception(
              'Tiempo de espera agotado. La operación está tomando demasiado tiempo.');
        }
        rethrow;
      }

      setState(() {
        _isLoading = false;
      });

      // Mostrar mensaje de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Archivo Excel creado con éxito'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      // Pequeña pausa para que el usuario vea el mensaje de éxito
      await Future.delayed(Duration(milliseconds: 500));

      // Compartir el archivo
      _compartirArchivo(filePath, 'application/vnd.ms-excel');
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al exportar a Excel: $e';
        _isLoading = false;
      });

      // Mostrar mensaje de error específico para timeouts
      if (e.toString().contains('tiempo')) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'La generación del Excel está tomando demasiado tiempo. Se ha simplificado la exportación.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 4),
            action: SnackBarAction(
              label: 'INTENTAR CSV',
              onPressed: () {
                _exportarCSV(); // Método alternativo para exportar a CSV
              },
            ),
          ),
        );
      } else {
        // Otros errores
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al generar Excel: $e'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  /// Método alternativo para exportar a CSV (más ligero)
  Future<void> _exportarCSV() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Mostrar mensaje de progreso
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Generando CSV...'),
          duration: Duration(seconds: 1),
        ),
      );

      // CSV es más simple y rápido que Excel
      final filePath = await _documentoService
          .exportarCSV(widget.formato)
          .timeout(Duration(seconds: 30));

      setState(() {
        _isLoading = false;
      });

      // Mostrar mensaje de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Archivo CSV creado con éxito'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      // Compartir el archivo
      _compartirArchivo(filePath, 'text/csv');
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al exportar a CSV: $e';
        _isLoading = false;
      });

      // Mostrar mensaje de error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al generar CSV: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
      await _compartirArchivo(_jsonFilePath!, 'application/json');
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al compartir: $e';
        _isLoading = false;
      });
    }
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
            'Guardar y Finalizar',
            () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Documento guardado y finalizado'),
                  backgroundColor: Colors.green,
                ),
              );

              // Esperar un momento y luego regresar a la pantalla de inicio
              Future.delayed(Duration(seconds: 1), () {
                Navigator.pop(context); // Regresar a NuevoFormatoScreen
                Navigator.pop(context); // Regresar a HomeScreen
              });
            },
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
