// lib/data/services/documento_service.dart
import 'dart:async';
import 'dart:io';
import 'package:share_plus/share_plus.dart';
import '../../logica/formato_evaluacion.dart';
import './file_storage_service.dart';
import './pdf_export_service.dart';
import './excel_export_service.dart';
import './export_error_handler.dart';
import './export_optimization_service.dart';
/// Servicio principal para la gestión de documentos
/// Coordina los servicios especializados para almacenamiento y exportación
class DocumentoService {
  final FileStorageService _fileService = FileStorageService();
  final PdfExportService _pdfService = PdfExportService();
  final ExcelExportService _excelService = ExcelExportService();

  /// Guarda el formato de evaluación en formato JSON
  Future<String> guardarFormatoJSON(FormatoEvaluacion formato) async {
    try {
      // Convertir datos a JSON
      final jsonData = formato.toJsonString();
      
      // Guardar en documentos de la app
      final directorio = await _fileService.obtenerDirectorioDocumentos();
      final nombreArchivo = 'Cenapp${formato.id}.json';
      final rutaArchivo = await _fileService.guardarArchivo(
        nombreArchivo, 
        jsonData, 
        directorio: directorio
      );
      
      // También guardar en la carpeta de descargas para facilitar el acceso del usuario
      try {
        final directorioDescargas = await _fileService.obtenerDirectorioDescargas();
        await _fileService.guardarArchivo(
          nombreArchivo, 
          jsonData, 
          directorio: directorioDescargas
        );
      } catch (e) {
        print('No se pudo guardar en descargas, pero se guardó en documentos: $e');
      }
      
      return rutaArchivo;
    } catch (e) {
      throw Exception('Error al guardar formato: $e');
    }
  }

  /// Carga un formato de evaluación desde un archivo JSON
  Future<FormatoEvaluacion> cargarFormatoJSON(String rutaArchivo) async {
    try {
      final jsonString = await _fileService.cargarArchivo(rutaArchivo);
      return FormatoEvaluacion.fromJsonString(jsonString);
    } catch (e) {
      throw Exception('Error al cargar formato: $e');
    }
  }

  /// Exporta el formato de evaluación a un archivo PDF
  Future<String> exportarPDF(FormatoEvaluacion formato) async {
    try {
      return await _pdfService.exportarFormatoPDF(formato);
    } catch (e) {
      throw Exception('Error al exportar a PDF: $e');
    }
  }

  /// Exporta el formato de evaluación a un archivo Excel
  Future<String> exportarExcel(FormatoEvaluacion formato) async {
  try {
    // Usar un tiempo de espera más largo para operaciones de exportación
    return await _excelService.exportarFormatoExcel(formato);
  } catch (e) {
    // Si ocurre un error, intentar con una exportación simplificada
    if (e is TimeoutException || e.toString().contains('tiempo')) {
      print('Timeout en exportación a Excel, intentando versión simplificada...');
      return await _excelService.exportarFormatoExcel(formato);
    }
    rethrow;
  }
}

  /// Exporta el formato de evaluación a un archivo CSV
  Future<String> exportarCSV(FormatoEvaluacion formato) async {
    try {
      return await _excelService.exportarFormatoCSV(formato);
    } catch (e) {
      throw Exception('Error al exportar a CSV: $e');
    }
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
}