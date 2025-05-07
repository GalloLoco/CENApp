// lib/data/services/image_conversion_service.dart
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:image/image.dart' as img;

class ImageConversionService {
  /// Optimiza los bytes de una imagen
  static Future<Uint8List> _optimizeImageBytes(Uint8List bytes) async {
    try {
      // Decodificar la imagen
      final image = img.decodeImage(bytes);
      if (image == null) {
        return bytes; // Si no se puede decodificar, devolver los bytes originales
      }
      
      // Redimensionar si es necesario (para imágenes muy grandes)
      img.Image resizedImage = image;
      if (image.width > 1200 || image.height > 1200) {
        final ratio = image.width / image.height;
        int newWidth, newHeight;
        
        if (ratio > 1) { // Imagen horizontal
          newWidth = 1200;
          newHeight = (1200 / ratio).round();
        } else { // Imagen vertical o cuadrada
          newHeight = 1200;
          newWidth = (1200 * ratio).round();
        }
        
        resizedImage = img.copyResize(
          image,
          width: newWidth,
          height: newHeight,
        );
      }
      
      // Comprimir la imagen
      return Uint8List.fromList(img.encodeJpg(resizedImage, quality: 70));
    } catch (e) {
      print('Error al optimizar la imagen: $e');
      return bytes; // En caso de error, devolver los bytes originales
    }
  }

  /// Convierte una imagen desde su ruta a base64
  static Future<String> imageFileToBase64(String imagePath) async {
    try {
      // Verificar que el archivo existe
      final file = File(imagePath);
      if (!await file.exists()) {
        throw Exception('Archivo de imagen no encontrado: $imagePath');
      }
      
      // Leer los bytes de la imagen
      final bytes = await file.readAsBytes();
      
      // Optimizar la imagen antes de convertirla a base64
      final optimizedBytes = await _optimizeImageBytes(bytes);
      
      // Convertir a base64
      final base64String = base64Encode(optimizedBytes);
      
      return base64String;
    } catch (e) {
      print('Error al convertir imagen a base64: $e');
      throw Exception('Error al convertir imagen a base64: $e');
    }
  }
  
  /// Convierte una cadena base64 a archivo de imagen y devuelve su ruta
  static Future<String> base64ToImageFile(String base64String, {String? customFilename}) async {
    try {
      // Decodificar base64 a bytes
      final bytes = base64Decode(base64String);
      
      // Crear directorio para almacenar imágenes temporales
      final appDir = await getApplicationDocumentsDirectory();
      final imageDir = Directory('${appDir.path}/cenapp/imagenes_base64');
      if (!await imageDir.exists()) {
        await imageDir.create(recursive: true);
      }
      
      // Generar nombre para el archivo
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filename = customFilename ?? 'img_$timestamp.jpg';
      final filePath = '${imageDir.path}/$filename';
      
      // Guardar bytes como archivo
      final file = File(filePath);
      await file.writeAsBytes(bytes);
      
      return filePath;
    } catch (e) {
      print('Error al convertir base64 a imagen: $e');
      throw Exception('Error al convertir base64 a imagen: $e');
    }
  }
  
  /// Convierte una lista de rutas de imágenes a un mapa de base64
  static Future<Map<String, String>> imagePathsToBase64Map(List<String> imagePaths) async {
    final Map<String, String> result = {};
    
    try {
      for (final imagePath in imagePaths) {
        // Obtener el nombre del archivo como clave
        final filename = path.basename(imagePath);
        
        // Convertir la imagen a base64
        final base64String = await imageFileToBase64(imagePath);
        
        // Almacenar en el mapa
        result[filename] = base64String;
      }
      
      return result;
    } catch (e) {
      print('Error al convertir múltiples imágenes a base64: $e');
      throw Exception('Error al convertir múltiples imágenes a base64: $e');
    }
  }
  
  /// Convierte un mapa de base64 a archivos de imagen y devuelve sus rutas
  static Future<List<String>> base64MapToImagePaths(Map<String, String> base64Map) async {
    final List<String> imagePaths = [];
    
    try {
      for (final entry in base64Map.entries) {
        // Convertir base64 a archivo usando el nombre original
        final imagePath = await base64ToImageFile(entry.value, customFilename: entry.key);
        
        // Añadir la ruta resultante a la lista
        imagePaths.add(imagePath);
      }
      
      return imagePaths;
    } catch (e) {
      print('Error al convertir mapa base64 a imágenes: $e');
      throw Exception('Error al convertir mapa base64 a imágenes: $e');
    }
  }
}