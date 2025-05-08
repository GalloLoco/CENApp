import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../data/services/image_base64_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:file_picker/file_picker.dart';
import '../logica/formato_evaluacion.dart';
import 'package:flutter/material.dart';
import '../data/utils/permisos_modernos.dart';

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

  /// Selecciona y carga un archivo JSON de manera optimizada
  /// Selecciona y carga un archivo JSON con manejo mejorado de permisos
  /// Selecciona y carga un archivo JSON con manejo mejorado de permisos
  static Future<FormatoEvaluacion?> seleccionarYCargarFormato(
      BuildContext context) async {
    try {
      // Verificar permisos primero usando el enfoque moderno
      bool tienePermiso = await _solicitarPermisosModernos(context);
      if (!tienePermiso) {
        throw Exception(
            'Permisos de almacenamiento denegados. Para continuar, por favor otorga permisos de almacenamiento en la configuración.');
      }

      // Usar FilePicker con configuración optimizada para archivos JSON
      FilePickerResult? result = await FilePicker.platform
          .pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        allowMultiple: false,
        lockParentWindow: true,
        dialogTitle: 'Seleccionar formato de evaluación',
        // Añadir parámetros adicionales para mejor detección
        withData: true, // Cargar datos directamente
        allowCompression: false, // No comprimir los datos
      )
          .catchError((error) {
        // Manejar errores de FilePicker
        print('Error en FilePicker: $error');
        return null; // Regresar null si hay error sin crashear
      });

      // Usuario canceló la selección o hubo un error
      if (result == null || result.files.isEmpty) {
        return null;
      }

      // Verificar que obtuvimos una ruta válida
      if (result.files.single.path == null) {
        print('No se pudo obtener la ruta del archivo');
        return null; // Regresar null en lugar de lanzar excepción
      }

      final path = result.files.single.path!;

      // Verificar extensión de forma no sensible a mayúsculas/minúsculas
      if (!path.toLowerCase().endsWith('.json')) {
        // Mostrar diálogo en lugar de lanzar excepción
        await _mostrarDialogoFormatoIncorrecto(context);
        return null;
      }

      // Primero verificar si el archivo existe
      final file = File(path);
      if (!await file.exists()) {
        print('El archivo no existe: $path');
        return null;
      }

      // Intentar cargar el archivo
      try {
        return await cargarFormatoJSON(path);
      } catch (e) {
        print('Error al cargar formato JSON: $e');
        await _mostrarDialogoFormatoInvalido(context);
        return null; // Regresar null en lugar de propagar el error
      }
    } catch (e) {
      print('Error al seleccionar archivo: $e');
      // Solo relanzar ciertos tipos de errores
      if (e.toString().contains('Permisos')) {
        rethrow;
      }
      return null; // Para otros errores, regresar null sin crashear
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
    try {
      final archivo = File(rutaArchivo);
      if (!await archivo.exists()) {
        throw Exception('El archivo no existe');
      }

      // Leer archivo con manejo de memoria optimizado para archivos grandes
      final jsonString = await archivo.readAsString();
      FormatoEvaluacion formato;

      try {
        formato = FormatoEvaluacion.fromJsonString(jsonString);
      } catch (e) {
        throw Exception('No se puede decodificar el formato: $e');
      }

      // Verificar si hay imágenes en base64 para restaurar
      if (formato.ubicacionGeorreferencial.imagenesBase64 != null &&
          formato.ubicacionGeorreferencial.imagenesBase64!.isNotEmpty) {
        // Mostrar indicador de progreso (implementar en UI)
        print(
            'Procesando ${formato.ubicacionGeorreferencial.imagenesBase64!.length} imágenes en base64...');

        // Optimización: Procesar solo un máximo de 10 imágenes para evitar problemas de memoria
        var imagenesBase64 = formato.ubicacionGeorreferencial.imagenesBase64!;
        int maxImagenes =
            imagenesBase64.length > 10 ? 10 : imagenesBase64.length;
        Map<String, String> imagenesLimitadas = {};

        int i = 0;
        for (var entry in imagenesBase64.entries) {
          if (i < maxImagenes) {
            imagenesLimitadas[entry.key] = entry.value;
            i++;
          } else {
            break;
          }
        }

        // Convertir base64 a archivos de imagen de forma optimizada
        List<String> rutasFotosRecuperadas =
            await ImageBase64Service.base64MapToImages(imagenesLimitadas);

        // Crear una copia del formato con las rutas actualizadas
        UbicacionGeorreferencial ubicacionActualizada =
            UbicacionGeorreferencial(
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
      print('Error detallado al cargar formato: $e');
      throw Exception(
          'Error al cargar formato: ${e.toString().split('\n')[0]}');
    }
  }
}
