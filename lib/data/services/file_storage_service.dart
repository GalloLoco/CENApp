// lib/data/services/file_storage_service.dart

import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../utils/permisos_modernos.dart' as permisosModernos;
import 'package:path/path.dart' as path;
import 'package:flutter/services.dart';


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
// 🎯 CANAL PARA COMUNICACIÓN CON CÓDIGO NATIVO ANDROID
  static const MethodChannel _channel = MethodChannel('cenapp/media_scanner');

  /// 🆕 SOLUCIÓN ANDROID: Guarda imágenes VISIBLES en la galería
  Future<Map<String, bool>> guardarImagenesSilenciosamente(
    List<String> rutasImagenes, {
    String? carpetaDestino = 'CENApp_Evaluaciones',
  }) async {
    Map<String, bool> resultados = {};
    
    if (rutasImagenes.isEmpty) return resultados;

    try {
      print('📸 [ANDROID] Iniciando guardado VISIBLE de ${rutasImagenes.length} imágenes...');

      // ✅ VERIFICAR PERMISOS ESPECÍFICOS DE ANDROID
      bool tienePermisos = await _verificarPermisosAndroid();
      if (!tienePermisos) {
        print('⚠️ [ANDROID] Sin permisos de media/storage');
        for (String ruta in rutasImagenes) {
          resultados[ruta] = false;
        }
        return resultados;
      }

      // 📁 CREAR DIRECTORIO EN PICTURES (PÚBLICO)
      Directory? directorioDestino = await _crearDirectorioPublico(carpetaDestino);
      if (directorioDestino == null) {
        print('❌ [ANDROID] No se pudo crear directorio público');
        for (String ruta in rutasImagenes) {
          resultados[ruta] = false;
        }
        return resultados;
      }

      // 🖼️ COPIAR IMÁGENES Y HACERLAS VISIBLES
      List<String> rutasGuardadas = [];
      
      for (int i = 0; i < rutasImagenes.length; i++) {
        String rutaImagen = rutasImagenes[i];
        
        try {
          // Copiar imagen al directorio público
          String? rutaGuardada = await _copiarImagenPublica(
            rutaImagen: rutaImagen,
            directorioDestino: directorioDestino,
            indice: i + 1,
          );
          
          if (rutaGuardada != null) {
            rutasGuardadas.add(rutaGuardada);
            resultados[rutaImagen] = true;
            print('✅ [ANDROID] Imagen ${i + 1} copiada: ${path.basename(rutaGuardada)}');
          } else {
            resultados[rutaImagen] = false;
            print('❌ [ANDROID] Falló copia imagen ${i + 1}');
          }
          
          // Pausa mínima entre archivos
          if (i < rutasImagenes.length - 1) {
            await Future.delayed(Duration(milliseconds: 100));
          }
        } catch (e) {
          print('❌ [ANDROID] Error imagen ${i + 1}: $e');
          resultados[rutaImagen] = false;
        }
      }

      // 🔄 PASO CRÍTICO: HACER IMÁGENES VISIBLES EN GALERÍA
      if (rutasGuardadas.isNotEmpty) {
        await _hacerImagenesVisibles(rutasGuardadas);
      }

      int exitosas = resultados.values.where((v) => v == true).length;
      print('✅ [ANDROID] Completado: $exitosas/${rutasImagenes.length} imágenes visibles en galería');
      
      return resultados;
    } catch (e) {
      print('❌ [ANDROID] Error general: $e');
      for (String ruta in rutasImagenes) {
        resultados[ruta] = false;
      }
      return resultados;
    }
  }

  /// 🔐 VERIFICAR PERMISOS ESPECÍFICOS DE ANDROID
  Future<bool> _verificarPermisosAndroid() async {
    try {
      if (!Platform.isAndroid) return true;

      // Lista de permisos a verificar/solicitar
      List<Permission> permisos = [
        Permission.photos,           // Android 13+
        Permission.videos,           // Android 13+
        Permission.storage,          // Android 10-12
      ];

      // Verificar si alguno ya está concedido
      for (Permission permiso in permisos) {
        if (await permiso.isGranted) {
          print('✅ [ANDROID] Permiso concedido: $permiso');
          return true;
        }
      }

      // Solicitar permisos que no están concedidos
      print('🔄 [ANDROID] Solicitando permisos de almacenamiento...');
      Map<Permission, PermissionStatus> statuses = await permisos.request();
      
      // Verificar si alguno fue concedido
      bool algunoConcedido = statuses.values.any((status) => 
          status == PermissionStatus.granted || 
          status == PermissionStatus.limited);

      if (algunoConcedido) {
        print('✅ [ANDROID] Permisos obtenidos exitosamente');
      } else {
        print('❌ [ANDROID] Permisos denegados');
      }

      return algunoConcedido;
    } catch (e) {
      print('❌ [ANDROID] Error verificando permisos: $e');
      return false;
    }
  }

  /// 📁 CREAR DIRECTORIO PÚBLICO EN PICTURES
  Future<Directory?> _crearDirectorioPublico(String? carpetaDestino) async {
    try {
      // 🎯 RUTA PRINCIPAL: Pictures públicas
      String rutaPictures = '/storage/emulated/0/Pictures';
      Directory directorioBase = Directory(rutaPictures);
      
      // Verificar que Pictures existe y es accesible
      if (!await directorioBase.exists()) {
        print('⚠️ [ANDROID] Pictures no existe, creando...');
        try {
          await directorioBase.create(recursive: true);
        } catch (e) {
          print('❌ [ANDROID] No se puede crear Pictures: $e');
          return null;
        }
      }

      // Crear subdirectorio específico de la app
      String nombreCarpeta = carpetaDestino ?? 'CENApp_Imagenes';
      Directory carpetaApp = Directory('${directorioBase.path}/$nombreCarpeta');
      
      if (!await carpetaApp.exists()) {
        await carpetaApp.create(recursive: true);
        print('📁 [ANDROID] Carpeta creada: ${carpetaApp.path}');
      }

      // Verificar que podemos escribir en la carpeta
      try {
        File testFile = File('${carpetaApp.path}/.test_write');
        await testFile.writeAsString('test');
        await testFile.delete();
        print('✅ [ANDROID] Directorio verificado: ${carpetaApp.path}');
        return carpetaApp;
      } catch (e) {
        print('❌ [ANDROID] No se puede escribir en directorio: $e');
        return null;
      }
    } catch (e) {
      print('❌ [ANDROID] Error creando directorio público: $e');
      return null;
    }
  }

  /// 🖼️ COPIAR IMAGEN A DIRECTORIO PÚBLICO
  Future<String?> _copiarImagenPublica({
    required String rutaImagen,
    required Directory directorioDestino,
    required int indice,
  }) async {
    try {
      final File archivoOriginal = File(rutaImagen);
      
      if (!await archivoOriginal.exists()) {
        print('⚠️ [ANDROID] Archivo original no existe: $rutaImagen');
        return null;
      }

      // Generar nombre único
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final String extension = path.extension(rutaImagen).toLowerCase();
      final String nombreArchivo = 'CENApp_Eval_${indice}_$timestamp$extension';
      
      // Ruta de destino
      final String rutaDestino = '${directorioDestino.path}/$nombreArchivo';
      final File archivoDestino = File(rutaDestino);

      // Copiar archivo
      await archivoOriginal.copy(rutaDestino);
      
      // Verificar copia exitosa
      if (await archivoDestino.exists() && await archivoDestino.length() > 0) {
        return rutaDestino;
      } else {
        print('❌ [ANDROID] Verificación de copia falló');
        return null;
      }
    } catch (e) {
      print('❌ [ANDROID] Error copiando imagen: $e');
      return null;
    }
  }

  /// 🔄 HACER IMÁGENES VISIBLES EN GALERÍA (PASO CRÍTICO)
  Future<void> _hacerImagenesVisibles(List<String> rutasGuardadas) async {
    try {
      print('🔄 [ANDROID] Haciendo ${rutasGuardadas.length} imágenes visibles en galería...');

      // MÉTODO 1: MediaScanner nativo (más efectivo)
      for (String ruta in rutasGuardadas) {
        try {
          await _escanearArchivoConMediaScanner(ruta);
        } catch (e) {
          print('⚠️ [ANDROID] Error escaneando archivo $ruta: $e');
        }
      }

      // MÉTODO 2: Fallback - Comando shell (si está disponible)
      try {
        await _ejecutarEscaneoShell(rutasGuardadas);
      } catch (e) {
        print('⚠️ [ANDROID] Escaneo shell falló: $e');
      }

      print('✅ [ANDROID] Proceso de visibilidad completado');
    } catch (e) {
      print('❌ [ANDROID] Error haciendo imágenes visibles: $e');
    }
  }

  /// 📱 ESCANEAR ARCHIVO CON MEDIA SCANNER NATIVO
  Future<void> _escanearArchivoConMediaScanner(String rutaArchivo) async {
    try {
      // Llamar al MediaScanner nativo de Android via Platform Channel
      await _channel.invokeMethod('scanFile', {'path': rutaArchivo});
      print('✅ [ANDROID] MediaScanner: ${path.basename(rutaArchivo)}');
    } catch (e) {
      print('⚠️ [ANDROID] MediaScanner falló para ${path.basename(rutaArchivo)}: $e');
      
      // Fallback: Crear archivo .nomedia para forzar re-escaneo
      try {
        String directorio = path.dirname(rutaArchivo);
        File nomediaFile = File('$directorio/.nomedia');
        if (await nomediaFile.exists()) {
          await nomediaFile.delete();
          await Future.delayed(Duration(milliseconds: 100));
        }
      } catch (e2) {
        // Ignorar errores del fallback
      }
    }
  }

  /// 🐚 EJECUTAR ESCANEO VÍA SHELL (FALLBACK)
  Future<void> _ejecutarEscaneoShell(List<String> rutas) async {
    try {
      // Comando para forzar re-escaneo del directorio
      String directorio = path.dirname(rutas.first);
      
      ProcessResult result = await Process.run(
        'am', 
        ['broadcast', '-a', 'android.intent.action.MEDIA_SCANNER_SCAN_FILE', '-d', 'file://$directorio'],
        runInShell: true
      );
      
      if (result.exitCode == 0) {
        print('✅ [ANDROID] Shell scan exitoso');
      } else {
        print('⚠️ [ANDROID] Shell scan falló: ${result.stderr}');
      }
    } catch (e) {
      print('⚠️ [ANDROID] Shell scan no disponible: $e');
    }
  }

}
