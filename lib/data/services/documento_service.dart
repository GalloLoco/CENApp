// lib/data/services/documento_service.dart
import 'dart:async';
import 'dart:io';
import 'package:share_plus/share_plus.dart';
import '../../logica/formato_evaluacion.dart';
import './image_base64_service.dart';
import './file_storage_service.dart';
import './pdf_export_service.dart';
import './excel_export_service.dart';
import 'package:cenapp/data/services/image_conversion_service.dart';

/// Servicio principal para la gestión de documentos
/// Coordina los servicios especializados para almacenamiento y exportación
class DocumentoService {
  final FileStorageService _fileService = FileStorageService();
  final PdfExportService _pdfService = PdfExportService();
  final ExcelExportService _excelService = ExcelExportService();

  FileStorageService get fileService => _fileService;

  /// Guarda el formato de evaluación en formato JSON
  Future<String> guardarFormatoJSON(FormatoEvaluacion formato) async {
    try {
      print("Iniciando guardado de formato JSON con imágenes base64...");
      
      // Crear un nuevo formato para incluir las imágenes base64
      FormatoEvaluacion formatoConBase64 = formato;
      
      // Verificar si hay rutas de fotos para convertir
      if (formato.ubicacionGeorreferencial.rutasFotos.isNotEmpty) {
        print("Encontradas ${formato.ubicacionGeorreferencial.rutasFotos.length} imágenes para convertir");
        
        try {
          // Convertir imágenes a base64
          Map<String, String> imagenesBase64 = await ImageConversionService.imagePathsToBase64Map(
            formato.ubicacionGeorreferencial.rutasFotos
          );
          
          print("Conversión a base64 completada: ${imagenesBase64.length} imágenes convertidas");
          
          // Crear una nueva instancia de UbicacionGeorreferencial con las imágenes base64
          UbicacionGeorreferencial nuevaUbicacion = UbicacionGeorreferencial(
            existenPlanos: formato.ubicacionGeorreferencial.existenPlanos,
            direccion: formato.ubicacionGeorreferencial.direccion,
            latitud: formato.ubicacionGeorreferencial.latitud,
            longitud: formato.ubicacionGeorreferencial.longitud,
            rutasFotos: formato.ubicacionGeorreferencial.rutasFotos,
            imagenesBase64: imagenesBase64,  // Añadir las imágenes en base64
          );
          
          // Crear un nuevo formato con la ubicación actualizada
          formatoConBase64 = FormatoEvaluacion(
            id: formato.id,
            fechaCreacion: formato.fechaCreacion,
            fechaModificacion: formato.fechaModificacion,
            usuarioCreador: formato.usuarioCreador,
            informacionGeneral: formato.informacionGeneral,
            sistemaEstructural: formato.sistemaEstructural,
            evaluacionDanos: formato.evaluacionDanos,
            ubicacionGeorreferencial: nuevaUbicacion,
          );
          
        } catch (e) {
          print("Error al convertir imágenes a base64: $e");
          // Continuar con el formato original si hay un error
        }
      }
      
      // Convertir a JSON el formato con base64
      final jsonData = formatoConBase64.toJsonString();
      
      // Guardar en documentos de la app
      final directorio = await _fileService.obtenerDirectorioDocumentos();
      final nombreArchivo = 'Cenapp${formato.id}.json';
      final rutaArchivo = await _fileService.guardarArchivo(
        nombreArchivo, 
        jsonData, 
        directorio: directorio
      );
      
      // También guardar en descargas
      try {
        final directorioDescargas = await _fileService.obtenerDirectorioDescargas();
        await _fileService.guardarArchivo(
          nombreArchivo, 
          jsonData, 
          directorio: directorioDescargas
        );
      } catch (e) {
        print('No se pudo guardar en descargas: $e');
      }
      
      return rutaArchivo;
    } catch (e) {
      print("Error general en guardarFormatoJSON: $e");
      throw Exception('Error al guardar formato JSON: $e');
    }
  }

  /// Carga un formato de evaluación desde un archivo JSON
  Future<FormatoEvaluacion> cargarFormatoJSON(String rutaArchivo) async {
  try {
    final jsonString = await _fileService.cargarArchivo(rutaArchivo);
    FormatoEvaluacion formato = FormatoEvaluacion.fromJsonString(jsonString);
    
    // Verificar si hay imágenes en base64 para restaurar
    if (formato.ubicacionGeorreferencial.imagenesBase64 != null &&
        formato.ubicacionGeorreferencial.imagenesBase64!.isNotEmpty) {
      // Convertir base64 a archivos de imagen
      List<String> rutasFotosRecuperadas = await ImageBase64Service.base64MapToImages(
        formato.ubicacionGeorreferencial.imagenesBase64!
      );
      
      // Actualizar rutas de fotos
      UbicacionGeorreferencial ubicacionActualizada = UbicacionGeorreferencial(
        existenPlanos: formato.ubicacionGeorreferencial.existenPlanos,
        direccion: formato.ubicacionGeorreferencial.direccion,
        latitud: formato.ubicacionGeorreferencial.latitud,
        longitud: formato.ubicacionGeorreferencial.longitud,
        rutasFotos: rutasFotosRecuperadas,
        imagenesBase64: formato.ubicacionGeorreferencial.imagenesBase64,
      );
      
      // Actualizar el formato
      formato = FormatoEvaluacion(
        id: formato.id,
        fechaCreacion: formato.fechaCreacion,
        fechaModificacion: formato.fechaModificacion,
        usuarioCreador: formato.usuarioCreador,
        informacionGeneral: formato.informacionGeneral,
        sistemaEstructural: formato.sistemaEstructural,
        evaluacionDanos: formato.evaluacionDanos,
        ubicacionGeorreferencial: ubicacionActualizada,
      );
    }
    
    return formato;
  } catch (e) {
    throw Exception('Error al cargar formato: $e');
  }
}
Future<void> verificarContenidoJSON(String rutaArchivo) async {
  try {
    // Leer el archivo
    final archivo = File(rutaArchivo);
    if (await archivo.exists()) {
      final contenido = await archivo.readAsString();
      
      // Verificar la presencia de imágenes base64
      if (contenido.contains('"imagenesBase64":{') || 
          contenido.contains('"imagenesBase64": {')) {
        print("✅ El archivo JSON contiene imágenes en base64");
        
        // Intentar cargarlo como objeto para validar
        try {
          final formato = FormatoEvaluacion.fromJsonString(contenido);
          if (formato.ubicacionGeorreferencial.imagenesBase64 != null &&
              formato.ubicacionGeorreferencial.imagenesBase64!.isNotEmpty) {
            print("✅ Se pudieron cargar ${formato.ubicacionGeorreferencial.imagenesBase64!.length} imágenes base64");
          } else {
            print("❌ No se pudieron cargar imágenes base64 del JSON");
          }
        } catch (e) {
          print("❌ Error al parsear el JSON: $e");
        }
      } else {
        print("❌ El archivo JSON NO contiene imágenes en base64");
      }
      
      // Tamaño del archivo
      final tamano = await archivo.length();
      print("📊 Tamaño del archivo: ${(tamano / 1024).toStringAsFixed(2)} KB");
    } else {
      print("❌ El archivo no existe");
    }
  } catch (e) {
    print("❌ Error al verificar contenido: $e");
  }
}

  
  /// Exporta el formato de evaluación a un archivo PDF
Future<String> exportarPDF(FormatoEvaluacion formato) async {
  try {
    // Obtener directorio de descargas en lugar de usar el directorio por defecto del PdfService
    final directorioDescargas = await fileService.obtenerDirectorioDescargas();
    
    // Generar el PDF usando el servicio pero especificando el directorio de descargas
    final rutaPDF = await _pdfService.exportarFormatoPDF(formato, directorio: directorioDescargas);
    
    return rutaPDF;
  } catch (e) {
    throw Exception('Error al exportar a PDF: $e');
  }
}

  /// Exporta el formato de evaluación a un archivo Excel
Future<String> exportarExcel(FormatoEvaluacion formato) async {
  try {
    // Obtener directorio de descargas
    final directorioDescargas = await fileService.obtenerDirectorioDescargas();
    
    // Exportar Excel al directorio de descargas
    return await _excelService.exportarFormatoExcel(formato, directorio: directorioDescargas);
  } catch (e) {
    // Si ocurre un error, intentar con una exportación simplificada
    if (e is TimeoutException || e.toString().contains('tiempo')) {
      print('Timeout en exportación a Excel, intentando versión simplificada...');
      final directorioDescargas = await fileService.obtenerDirectorioDescargas();
      return await _excelService.exportarFormatoExcel(formato, directorio: directorioDescargas);
    }
    rethrow;
  }
}

/// Exporta el formato de evaluación a un archivo CSV
Future<String> exportarCSV(FormatoEvaluacion formato) async {
  try {
    // Obtener directorio de descargas
    final directorioDescargas = await fileService.obtenerDirectorioDescargas();
    
    // Exportar CSV al directorio de descargas
    return await _excelService.exportarFormatoCSV(formato, directorio: directorioDescargas);
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
