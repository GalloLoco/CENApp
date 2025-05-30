// lib/data/services/file_storage_service.dart

import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../utils/permisos_modernos.dart' as permisosModernos;
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
    // Para Android 10+ o posterior, necesitamos solicitar permisos de almacenamiento
    if (Platform.isAndroid) {
      // Verificar permisos primero
      bool hasPermission = await _checkAndRequestStoragePermission();
      if (!hasPermission) {
        throw Exception('No se obtuvieron permisos de almacenamiento');
      }

      // Intenta primero la ruta de Descargas estándar
      try {
        final downloadsDir = Directory('/storage/emulated/0/Download');
        if (await downloadsDir.exists()) {
          print(
              'Usando directorio de descargas estándar: ${downloadsDir.path}');
          return downloadsDir;
        }
      } catch (e) {
        print('Error al acceder a /storage/emulated/0/Download: $e');
      }

      // Si no podemos acceder al directorio estándar, intentamos encontrar el directorio de descargas público
      try {
        final extDir = await getExternalStorageDirectory();
        if (extDir != null) {
          // Navegar hacia arriba para encontrar el directorio de descargas
          String path = extDir.path;
          final pathParts = path.split('/');
          final index = pathParts.indexOf('Android');
          if (index > 0) {
            final baseDir = pathParts.sublist(0, index).join('/');
            final downloadsDir = Directory('$baseDir/Download');

            // Verificar si existe
            bool exists = await downloadsDir.exists();

            // Si no existe, intentar crearlo
            if (!exists) {
              try {
                await downloadsDir.create(recursive: true);
                exists = true; // Si llegamos aquí, la creación tuvo éxito
              } catch (e) {
                print('Error al crear el directorio de descargas: $e');
                exists = false;
              }
            }

            // Si existe o se creó correctamente
            if (exists) {
              print(
                  'Usando directorio de descargas alternativo: ${downloadsDir.path}');
              return downloadsDir;
            }
          }
        }
      } catch (e) {
        print('Error al buscar directorio de descargas alternativo: $e');
      }
    }

    // Si no podemos encontrar un directorio de descargas público, usamos el directorio de documentos como fallback
    print('Fallback: usando directorio de documentos de la app');
    final documentsDir = await getApplicationDocumentsDirectory();
    return documentsDir;
  }

// Función auxiliar para verificar y solicitar permisos
  Future<bool> _checkAndRequestStoragePermission() async {
    if (await Permission.storage.isGranted) {
      return true;
    }

    // Si los permisos no están concedidos, solicitarlos
    var status = await Permission.storage.request();
    if (status.isGranted) {
      return true;
    }

    // Para Android 10+, podría ser necesario solicitar MANAGE_EXTERNAL_STORAGE
    if (await Permission.manageExternalStorage.isGranted) {
      return true;
    }

    try {
      status = await Permission.manageExternalStorage.request();
      return status.isGranted;
    } catch (e) {
      print('Error al solicitar permisos de manageExternalStorage: $e');
      // Algunos dispositivos no soportan este permiso
      return false;
    }
  }


  /// Guarda un archivo con el contenido proporcionado
  Future<String> guardarArchivo(String nombreArchivo, String contenido,
      {Directory? directorio}) async {
    try {
      // Usar el directorio proporcionado o el predeterminado
      final dir = directorio ?? await obtenerDirectorioDocumentos();

      // Ruta completa del archivo
      final rutaArchivo = '${dir.path}/$nombreArchivo';

      // Intentar escribir archivo de manera segura
      bool exito = await escribirArchivoSeguro(rutaArchivo, contenido);

      if (!exito) {
        // Si falla, intentar con un nombre único
        final nombreUnico = generarNombreArchivoUnico(
            nombreArchivo.split('.').first, nombreArchivo.split('.').last);
        final nuevaRuta = '${dir.path}/$nombreUnico';

        // Intentar escribir con el nuevo nombre
        bool exitoSegundo = await escribirArchivoSeguro(nuevaRuta, contenido);

        if (!exitoSegundo) {
          throw Exception(
              'No se pudo guardar el archivo después de múltiples intentos');
        }

        return nuevaRuta;
      }

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
  Future<String> guardarArchivoBytes(String nombreArchivo, List<int> bytes,
      {Directory? directorio}) async {
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

  /// Verifica si un archivo se guardó correctamente
  Future<bool> verificarArchivoGuardado(String rutaArchivo) async {
    try {
      final archivo = File(rutaArchivo);
      return await archivo.exists() && (await archivo.length() > 0);
    } catch (e) {
      print('Error verificando archivo: $e');
      return false;
    }
  }

  /// Escribe un archivo de manera segura con reintentos
  Future<bool> escribirArchivoSeguro(String ruta, String contenido,
      {int intentos = 3}) async {
    for (int i = 0; i < intentos; i++) {
      try {
        final archivo = File(ruta);
        await archivo.writeAsString(contenido, flush: true);

        // Verificar que el archivo se escribió correctamente
        if (await archivo.exists() && await archivo.length() > 0) {
          return true;
        }
      } catch (e) {
        print('Error en intento ${i + 1} escribiendo archivo: $e');
        // Esperar un momento antes de reintentar
        await Future.delayed(Duration(milliseconds: 200 * (i + 1)));
      }
    }

    return false; // Falló después de todos los intentos
  }

  /// Genera un nombre de archivo único para evitar sobrescrituras
  String generarNombreArchivoUnico(String baseNombre, String extension) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '$baseNombre-$timestamp.$extension';
  }
  /// Guarda una imagen en el dispositivo de forma optimizada
Future<String> guardarImagenEnDispositivo(
  String rutaImagenOriginal, {
  String? nombrePersonalizado,
  Directory? directorioDestino,
}) async {
  try {
    print('📸 [FILE_SERVICE] Guardando imagen: $rutaImagenOriginal');

    // Verificar permisos usando tu método existente
   

    // Usar tu directorio de descargas existente
    final directorio = directorioDestino ?? await obtenerDirectorioDescargas();
    
    // Crear subdirectorio para imágenes si no existe
    final directorioImagenes = Directory('${directorio.path}/cenapp/imagenes');
    if (!await directorioImagenes.exists()) {
      await directorioImagenes.create(recursive: true);
    }

    // Generar nombre único para evitar sobrescrituras
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final extension = rutaImagenOriginal.split('.').last.toLowerCase();
    final nombreFinal = nombrePersonalizado != null 
        ? '${nombrePersonalizado}_$timestamp.$extension'
        : 'cenapp_imagen_$timestamp.$extension';

    // Ruta de destino
    final rutaDestino = '${directorioImagenes.path}/$nombreFinal';

    // Copiar archivo de forma eficiente
    final archivoOriginal = File(rutaImagenOriginal);
    if (!await archivoOriginal.exists()) {
      throw Exception('Archivo de imagen no encontrado: $rutaImagenOriginal');
    }

    final archivoDestino = File(rutaDestino);
    await archivoOriginal.copy(rutaDestino);

    // Verificar que se copió correctamente
    if (await archivoDestino.exists() && await archivoDestino.length() > 0) {
      print('✅ [FILE_SERVICE] Imagen guardada exitosamente: $rutaDestino');
      return rutaDestino;
    } else {
      throw Exception('Error al verificar la copia de la imagen');
    }

  } catch (e) {
    print('❌ [FILE_SERVICE] Error al guardar imagen: $e');
    throw Exception('Error al guardar imagen: $e');
  }
}

/// Guarda múltiples imágenes de forma eficiente (por lotes)
Future<List<String>> guardarMultiplesImagenes(
  List<String> rutasImagenes, {
  String? prefijoNombre,
  Directory? directorioDestino,
  Function(int, int)? onProgress, // Callback para mostrar progreso
}) async {
  List<String> rutasGuardadas = [];
  
  for (int i = 0; i < rutasImagenes.length; i++) {
    try {
      final nombrePersonalizado = prefijoNombre != null 
          ? '${prefijoNombre}_${i + 1}'
          : null;
      
      final rutaGuardada = await guardarImagenEnDispositivo(
        rutasImagenes[i],
        nombrePersonalizado: nombrePersonalizado,
        directorioDestino: directorioDestino,
      );
      
      rutasGuardadas.add(rutaGuardada);
      
      // Notificar progreso si se proporciona callback
      onProgress?.call(i + 1, rutasImagenes.length);
      
    } catch (e) {
      print('⚠️ [FILE_SERVICE] Error al guardar imagen ${i + 1}: $e');
      // Continuar con las siguientes imágenes
    }
  }
  
  return rutasGuardadas;
}
}
