import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../data/services/image_base64_service.dart';
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
      //var statusPhotos = await Permission.photos.request();
      
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
 // Guarda un formato de evaluación como archivo JSON con imágenes en base64
static Future<String> guardarFormatoJSON(FormatoEvaluacion formato) async {
  try {
    // Primero, verificar si hay imágenes para convertir
    List<String> rutasFotos = formato.ubicacionGeorreferencial.rutasFotos;
    Map<String, String> imagenesBase64 = {};
    
    if (rutasFotos.isNotEmpty) {
      // Convertir imágenes a base64
      imagenesBase64 = await ImageBase64Service.imagesToBase64Map(rutasFotos);
      
      // Crear una copia del formato con las imágenes en base64
      UbicacionGeorreferencial ubicacionConBase64 = UbicacionGeorreferencial(
        existenPlanos: formato.ubicacionGeorreferencial.existenPlanos,
        direccion: formato.ubicacionGeorreferencial.direccion,
        latitud: formato.ubicacionGeorreferencial.latitud,
        longitud: formato.ubicacionGeorreferencial.longitud,
        rutasFotos: formato.ubicacionGeorreferencial.rutasFotos,
        imagenesBase64: imagenesBase64,
      );
      
      // Crear copia modificada del formato original con las imágenes en base64
      formato = FormatoEvaluacion(
        id: formato.id,
        fechaCreacion: formato.fechaCreacion,
        fechaModificacion: formato.fechaModificacion,
        usuarioCreador: formato.usuarioCreador,
        informacionGeneral: formato.informacionGeneral,
        sistemaEstructural: formato.sistemaEstructural,
        evaluacionDanos: formato.evaluacionDanos,
        ubicacionGeorreferencial: ubicacionConBase64,
      );
    }
    
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
    FormatoEvaluacion formato = FormatoEvaluacion.fromJsonString(jsonString);
    
    // Verificar si hay imágenes en base64 para restaurar
    if (formato.ubicacionGeorreferencial.imagenesBase64 != null &&
        formato.ubicacionGeorreferencial.imagenesBase64!.isNotEmpty) {
      // Convertir base64 a archivos de imagen
      List<String> rutasFotosRecuperadas = await ImageBase64Service.base64MapToImages(
        formato.ubicacionGeorreferencial.imagenesBase64!
      );
      
      // Crear una copia del formato con las rutas actualizadas
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
}