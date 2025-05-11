import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../data/services/image_base64_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:file_picker/file_picker.dart';
import '../logica/formato_evaluacion.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

class FileService {
  /// Verificar y solicitar permisos adaptados a Android moderno
  static Future<bool> _solicitarPermisosModernos(BuildContext? context) async {
    if (Platform.isAndroid) {
      // Para Android 13+ (API 33+) solicitar permisos específicos
      List<Permission> permisosNecesarios = [
        Permission.photos, // Para acceder a imágenes
        Permission.videos, // Para acceder a videos
        Permission.storage, // Para compatibilidad con versiones anteriores
      ];

      // Solicitar todos los permisos necesarios a la vez
      Map<Permission, PermissionStatus> statuses =
          await permisosNecesarios.request();

      // Comprobar si alguno de los permisos importantes fue concedido
      bool algunoConcedido = statuses.values.any((status) => status.isGranted);

      // Si no hay permisos concedidos y tenemos un contexto, mostrar diálogo explicativo
      if (!algunoConcedido && context != null) {
        bool abrirConfiguracion = await _mostrarDialogoPermisos(context);
        if (abrirConfiguracion) {
          await openAppSettings();
          return false; // La función que llama deberá manejar este caso
        }
        return false;
      }

      return algunoConcedido;
    }

    // En plataformas no Android, asumir que tenemos permisos
    return true;
  }

  /// Muestra un diálogo explicativo sobre los permisos
  static Future<bool> _mostrarDialogoPermisos(BuildContext context) async {
    final resultado = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Permisos necesarios'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Para abrir archivos, CENApp necesita acceso a:'),
              SizedBox(height: 10),
              _buildPermisoItem(Icons.photo, 'Fotos y videos'),
              _buildPermisoItem(Icons.folder, 'Archivos del dispositivo'),
              SizedBox(height: 10),
              Text(
                  'Por favor, concede estos permisos en la configuración de la aplicación.'),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: Text('Ir a Configuración'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );

    return resultado ?? false;
  }

  static Widget _buildPermisoItem(IconData icon, String texto) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 18),
          SizedBox(width: 8),
          Text(texto),
        ],
      ),
    );
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
              String newPath =
                  paths.sublist(0, androidIndex).join('/') + '/Download';
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

  /// Selecciona y carga un archivo JSON con manejo mejorado de permisos
  static Future<FormatoEvaluacion?> seleccionarYCargarFormato(
      BuildContext context) async {
    print("📂 SERVICIO: Iniciando seleccionarYCargarFormato...");

    try {
      // Verificar permisos primero
      print("📂 SERVICIO: Verificando permisos...");
      bool tienePermiso = await _solicitarPermisosModernos(context);
      if (!tienePermiso) {
        print("❌ SERVICIO: Permisos de almacenamiento denegados");
        throw Exception('Permisos de almacenamiento denegados');
      }
      print("✅ SERVICIO: Permisos verificados");

      // Configuración para FilePicker
      print("📂 SERVICIO: Mostrando selector de archivos...");
      FilePickerResult? result = await FilePicker.platform
          .pickFiles(
        type: FileType.any, // Ver todos los archivos
        allowMultiple: false,
        lockParentWindow: true,
        dialogTitle: 'Seleccionar archivo JSON',
        withData: true,
      )
          .catchError((error) {
        print("❌ SERVICIO: Error en FilePicker: $error");
        return null;
      });

      // Verificar si el usuario seleccionó un archivo
      if (result == null) {
        print("⚠️ SERVICIO: Selección cancelada (result null)");
        return null;
      }

      if (result.files.isEmpty) {
        print("⚠️ SERVICIO: Selección cancelada (files vacío)");
        return null;
      }

      if (result.files.single.path == null) {
        print("❌ SERVICIO: Path del archivo es null");
        throw Exception('No se pudo obtener la ruta del archivo');
      }

      final path = result.files.single.path!;
      print("✅ SERVICIO: Archivo seleccionado: $path");

      // Verificar que sea un archivo JSON
      if (!path.toLowerCase().endsWith('.json')) {
        print("❌ SERVICIO: El archivo no es JSON: $path");
        throw Exception('El archivo seleccionado no es de tipo JSON');
      }
      print("✅ SERVICIO: Verificación de extensión .json correcta");

      // Verificar si el archivo existe
      final file = File(path);
      if (!await file.exists()) {
        print("❌ SERVICIO: El archivo no existe físicamente");
        throw Exception('El archivo seleccionado no existe');
      }
      print("✅ SERVICIO: El archivo existe físicamente");

      // Verificar tamaño del archivo
      int fileSize = await file.length();
      print("📊 SERVICIO: Tamaño del archivo: ${fileSize} bytes");

      if (fileSize == 0) {
        print("❌ SERVICIO: El archivo está vacío");
        throw Exception("El archivo está vacío");
      }

      // Intentar leer los primeros bytes para diagnóstico
      try {
        String filePreview = await file.readAsString().then((content) =>
            content.length > 100 ? content.substring(0, 100) : content);
        print("📄 SERVICIO: Primeros 100 caracteres: $filePreview");
      } catch (e) {
        print("⚠️ SERVICIO: No se pudo leer vista previa: $e");
      }

      // Leer el contenido del archivo de forma segura
      print("📂 SERVICIO: Cargando FormatoEvaluacion desde $path...");

      try {
        FormatoEvaluacion formato = await cargarFormatoJSON(path);
        print("✅ SERVICIO: Formato cargado exitosamente: ID=${formato.id}");
        return formato;
      } catch (e) {
        print("❌ SERVICIO: Error al cargar formato JSON: $e");
        throw Exception('El archivo no parece ser un formato válido: $e');
      }
    } catch (e) {
      print("❌❌ SERVICIO ERROR GENERAL en seleccionarYCargarFormato: $e");
      throw e; // Propagar el error para manejarlo en HomeScreen
    }
  }

  /// Muestra un diálogo cuando el formato de archivo es incorrecto
  static Future<void> _mostrarDialogoFormatoIncorrecto(
      BuildContext context) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Formato no soportado'),
          content: Text('Por favor selecciona un archivo con extensión .json'),
          actions: [
            TextButton(
              child: Text('Aceptar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  /// Muestra un diálogo cuando el archivo JSON no es válido
  static Future<void> _mostrarDialogoFormatoInvalido(
      BuildContext context) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Formato inválido'),
          content: Text(
              'El archivo seleccionado no es un formato de evaluación válido o está dañado.'),
          actions: [
            TextButton(
              child: Text('Aceptar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Para mantener la compatibilidad, conservar este método
  static Future<bool> _solicitarPermisos() async {
    if (Platform.isAndroid) {
      var statusStorage = await Permission.storage.status;
      if (!statusStorage.isGranted) {
        statusStorage = await Permission.storage.request();
      }

      return statusStorage.isGranted;
    }
    return true;
  }

  /// Carga un formato de evaluación desde un archivo JSON con manejo optimizado de imágenes
  static Future<FormatoEvaluacion> cargarFormatoJSON(String rutaArchivo) async {
    print("🔄 SERVICIO: Iniciando cargarFormatoJSON desde: $rutaArchivo");

    try {
      // Verificar existencia del archivo
      final archivo = File(rutaArchivo);
      if (!await archivo.exists()) {
        print("❌ SERVICIO: El archivo no existe");
        throw Exception('El archivo no existe');
      }

      // Leer contenido del archivo
      print("🔄 SERVICIO: Leyendo contenido del archivo...");
      String jsonString;
      try {
        jsonString = await archivo.readAsString();
        print(
            "✅ SERVICIO: Archivo leído correctamente (${jsonString.length} bytes)");

        if (jsonString.isEmpty) {
          print("❌ SERVICIO: El contenido del archivo está vacío");
          throw Exception('El archivo está vacío');
        }
      } catch (e) {
        print("❌ SERVICIO: Error al leer el archivo: $e");
        throw Exception('Error al leer el archivo: $e');
      }

      // Intentar parsear el JSON
      print("🔄 SERVICIO: Convirtiendo JSON a objeto FormatoEvaluacion...");
      FormatoEvaluacion formato;
      try {
        // Verificar si la cadena JSON es válida
        try {
          final jsonData = jsonDecode(jsonString);
          if (jsonData is! Map<String, dynamic>) {
            print("❌ SERVICIO: El JSON no representa un objeto válido");
            throw Exception('El JSON no representa un objeto válido');
          }
          print("✅ SERVICIO: JSON decodificado correctamente");
        } catch (e) {
          print("❌ SERVICIO: Error al decodificar JSON: $e");
          throw Exception('Error al decodificar JSON: $e');
        }

        // Crear el objeto FormatoEvaluacion
        formato = FormatoEvaluacion.fromJsonString(jsonString);
        print("✅ SERVICIO: FormatoEvaluacion creado exitosamente");
        print(
            "📋 SERVICIO: ID=${formato.id}, Usuario=${formato.usuarioCreador}");
        print(
            "📋 SERVICIO: Nombre inmueble=${formato.informacionGeneral.nombreInmueble}");
      } catch (e) {
        print("❌ SERVICIO: Error al crear FormatoEvaluacion: $e");
        throw Exception('No se pudo crear el objeto FormatoEvaluacion: $e');
      }

      // Verificar imágenes en base64 y procesarlas si existen
      print("🔄 SERVICIO: Verificando imágenes base64...");
      if (formato.ubicacionGeorreferencial.imagenesBase64 != null &&
          formato.ubicacionGeorreferencial.imagenesBase64!.isNotEmpty) {
        print(
            "📷 SERVICIO: Hay ${formato.ubicacionGeorreferencial.imagenesBase64!.length} imágenes en base64");
        // Continuar con procesamiento de imágenes...
      } else {
        print("📷 SERVICIO: No hay imágenes base64 para procesar");
      }

      print("✅ SERVICIO: cargarFormatoJSON completado exitosamente");
      return formato;
    } catch (e) {
      print("❌❌ SERVICIO ERROR GENERAL en cargarFormatoJSON: $e");
      throw Exception('Error al cargar formato: $e');
    }
  }
}
