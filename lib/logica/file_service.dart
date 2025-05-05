import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:file_picker/file_picker.dart';
import '../logica/formato_evaluacion.dart';

class FileService {
  /// Verifica y solicita permisos de almacenamiento
  static Future<bool> _solicitarPermisos() async {
    if (Platform.isAndroid) {
      // Solicitar permisos de almacenamiento
      var statusStorage = await Permission.storage.status;
      if (!statusStorage.isGranted) {
        statusStorage = await Permission.storage.request();
      }
      
      // Solicitar permisos adicionales para abarcar todos los casos
      var statusPhotos = await Permission.photos.request();
      
      return statusStorage.isGranted;
    }
    return true;
  }

  /// Obtiene la ruta a la carpeta de Descargas
  static Future<Directory> obtenerDirectorioDescargas() async {
    try {
      // Verificar y solicitar permisos
      bool tienePermiso = await _solicitarPermisos();
      if (!tienePermiso) {
        throw Exception('Permisos de almacenamiento denegados');
      }
      
      if (Platform.isAndroid) {
        // Para Android, usar la ruta estándar de Downloads
        Directory? directory = Directory('/storage/emulated/0/Download');
        
        // Si no existe, intentar crear
        if (!await directory.exists()) {
          // Intentar con path_provider
          directory = await getExternalStorageDirectory();
          if (directory != null) {
            // Navegar a la carpeta de descargas
            String path = directory.path;
            List<String> paths = path.split('/');
            int androidIndex = paths.indexOf('Android');
            if (androidIndex > 0) {
              String newPath = paths.sublist(0, androidIndex).join('/') + '/Download';
              directory = Directory(newPath);
            }
          }
        }
        
        // Verificar si podemos acceder al directorio
        if (directory != null && await directory.exists()) {
          return directory;
        }
        
        // Fallback: usar el directorio de documentos
        final appDocDir = await getApplicationDocumentsDirectory();
        return appDocDir;
      } else if (Platform.isIOS) {
        final directory = await getApplicationDocumentsDirectory();
        return directory;
      } else {
        final directory = await getApplicationDocumentsDirectory();
        return directory;
      }
    } catch (e) {
      print('Error obteniendo directorio de descargas: $e');
      // Fallback seguro
      return await getApplicationDocumentsDirectory();
    }
  }

  /// Guarda un formato de evaluación como archivo JSON
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

  /// Selecciona y carga un archivo JSON
  static Future<FormatoEvaluacion?> seleccionarYCargarFormato() async {
    try {
      // Verificar permisos primero
      bool tienePermiso = await _solicitarPermisos();
      if (!tienePermiso) {
        throw Exception('Permisos de almacenamiento denegados');
      }
      
      // Usar FilePicker con configuración específica
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        allowMultiple: false,
        withData: true,
      );
      
      if (result != null && result.files.single.path != null) {
        final path = result.files.single.path!;
        return await cargarFormatoJSON(path);
      } else if (result != null && result.files.single.bytes != null) {
        // Si solo tenemos los bytes
        final bytes = result.files.single.bytes!;
        final jsonString = String.fromCharCodes(bytes);
        return FormatoEvaluacion.fromJsonString(jsonString);
      }
      
      return null;
    } catch (e) {
      print('Error al seleccionar archivo: $e');
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