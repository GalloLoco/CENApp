// file_service.dart
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:file_picker/file_picker.dart';
import '../logica/formato_evaluacion.dart';

class FileService {
  /// Obtiene la ruta a la carpeta de Descargas
  static Future<Directory> obtenerDirectorioDescargas() async {
    // Verificar y solicitar permisos de almacenamiento
    if (Platform.isAndroid) {
      final status = await Permission.storage.status;
      if (!status.isGranted) {
        await Permission.storage.request();
      }
      
      // En Android, la carpeta de descargas generalmente está en /storage/emulated/0/Download
      return Directory('/storage/emulated/0/Download');
    } else if (Platform.isIOS) {
      // En iOS, usamos la carpeta de documentos pública
      final directory = await getApplicationDocumentsDirectory();
      return directory;
    } else {
      // Para otras plataformas, usar la carpeta de documentos
      final directory = await getApplicationDocumentsDirectory();
      return directory;
    }
  }

  /// Guarda un formato de evaluación como archivo JSON en la carpeta de Descargas
  static Future<String> guardarFormatoJSON(FormatoEvaluacion formato) async {
    try {
      // Obtener el directorio de descargas
      final directorio = await obtenerDirectorioDescargas();
      
      // Crear nombre de archivo basado en ID
      final nombreArchivo = 'Cenapp${formato.id}.json';
      
      // Ruta completa del archivo
      final rutaArchivo = '${directorio.path}/$nombreArchivo';
      
      // Convertir datos a JSON
      final jsonData = formato.toJsonString();
      
      // Escribir archivo
      final archivo = File(rutaArchivo);
      await archivo.writeAsString(jsonData);
      
      return rutaArchivo;
    } catch (e) {
      throw Exception('Error al guardar formato: $e');
    }
  }

  /// Selecciona y carga un archivo JSON desde la carpeta de Descargas
  static Future<FormatoEvaluacion?> seleccionarYCargarFormato() async {
    try {
      // Configurar el file picker para que solo muestre archivos JSON
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        initialDirectory: (await obtenerDirectorioDescargas()).path,
      );
      
      if (result != null && result.files.single.path != null) {
        final path = result.files.single.path!;
        return cargarFormatoJSON(path);
      }
      
      return null;
    } catch (e) {
      throw Exception('Error al seleccionar archivo: $e');
    }
  }
  
  /// Carga un formato de evaluación desde un archivo JSON
  static Future<FormatoEvaluacion> cargarFormatoJSON(String rutaArchivo) async {
    try {
      final archivo = File(rutaArchivo);
      if (!await archivo.exists()) {
        throw Exception('El archivo no existe');
      }
      
      final jsonString = await archivo.readAsString();
      return FormatoEvaluacion.fromJsonString(jsonString);
    } catch (e) {
      throw Exception('Error al cargar formato: $e');
    }
  }
}