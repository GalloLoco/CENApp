// lib/data/services/file_storage_service.dart

import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as path;

/// Servicio para gestionar el almacenamiento de archivos
class FileStorageService {
  /// Verifica y solicita permisos de almacenamiento
  Future<bool> solicitarPermisos() async {
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

  /// Obtiene la ruta al directorio de documentos de la aplicación
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

  /// Obtiene la ruta a la carpeta de Descargas
  Future<Directory> obtenerDirectorioDescargas() async {
    try {
      // Verificar y solicitar permisos
      bool tienePermiso = await solicitarPermisos();
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
        return await getApplicationDocumentsDirectory();
      } else if (Platform.isIOS) {
        return await getApplicationDocumentsDirectory();
      } else {
        return await getApplicationDocumentsDirectory();
      }
    } catch (e) {
      print('Error obteniendo directorio de descargas: $e');
      // Fallback seguro
      return await getApplicationDocumentsDirectory();
    }
  }

  /// Guarda un archivo con el contenido proporcionado
  Future<String> guardarArchivo(String nombreArchivo, String contenido, {Directory? directorio}) async {
    try {
      // Usar el directorio proporcionado o el predeterminado
      final dir = directorio ?? await obtenerDirectorioDocumentos();
      
      // Ruta completa del archivo
      final rutaArchivo = '${dir.path}/$nombreArchivo';
      
      // Escribir archivo
      final archivo = File(rutaArchivo);
      await archivo.writeAsString(contenido);
      
      return rutaArchivo;
    } catch (e) {
      throw Exception('Error al guardar archivo: $e');
    }
  }

  /// Carga el contenido de un archivo
  Future<String> cargarArchivo(String rutaArchivo) async {
    try {
      final archivo = File(rutaArchivo);
      if (!await archivo.exists()) {
        throw Exception('El archivo no existe: $rutaArchivo');
      }
      
      return await archivo.readAsString();
    } catch (e) {
      throw Exception('Error al cargar archivo: $e');
    }
  }

  /// Guarda un archivo de bytes (como una imagen o PDF)
  Future<String> guardarArchivoBytes(String nombreArchivo, List<int> bytes, {Directory? directorio}) async {
    try {
      // Usar el directorio proporcionado o el predeterminado
      final dir = directorio ?? await obtenerDirectorioDocumentos();
      
      // Ruta completa del archivo
      final rutaArchivo = '${dir.path}/$nombreArchivo';
      
      // Escribir archivo
      final archivo = File(rutaArchivo);
      await archivo.writeAsBytes(bytes);
      
      return rutaArchivo;
    } catch (e) {
      throw Exception('Error al guardar archivo de bytes: $e');
    }
  }

  /// Obtiene el nombre del archivo de una ruta completa
  String obtenerNombreArchivo(String rutaCompleta) {
    return path.basename(rutaCompleta);
  }
}