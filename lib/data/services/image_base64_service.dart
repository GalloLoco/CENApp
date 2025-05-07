// lib/data/services/image_base64_service.dart
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:image/image.dart' as img;

/// Servicio para convertir imágenes entre formato de archivo y base64
class ImageBase64Service {
  /// Convierte una imagen de archivo a cadena base64
  static Future<String> imageToBase64(String imagePath) async {
    try {
      final File file = File(imagePath);
      if (!await file.exists()) {
        throw Exception('El archivo de imagen no existe: $imagePath');
      }
      
      // Leer bytes del archivo
      final Uint8List bytes = await file.readAsBytes();
      
      // Comprimir la imagen para reducir el tamaño
      final img.Image? decodedImage = img.decodeImage(bytes);
      if (decodedImage == null) {
        throw Exception('No se pudo decodificar la imagen');
      }
      
      // Redimensionar si es demasiado grande (reduce sustancialmente el tamaño)
      img.Image resizedImage = decodedImage;
      if (decodedImage.width > 1000 || decodedImage.height > 1000) {
        resizedImage = img.copyResize(
          decodedImage,
          width: decodedImage.width > 1000 ? 1000 : decodedImage.width,
          height: (decodedImage.height * (decodedImage.width > 1000 ? 1000 / decodedImage.width : 1)).toInt(),
        );
      }
      
      // Comprimir al 80% de calidad
      final compressedBytes = img.encodeJpg(resizedImage, quality: 80);
      
      // Convertir bytes a base64
      final String base64String = base64Encode(compressedBytes);
      
      return base64String;
    } catch (e) {
      print('Error al convertir imagen a base64: $e');
      throw Exception('Error al convertir imagen a base64: $e');
    }
  }

  /// Convierte una cadena base64 a un archivo de imagen y devuelve la ruta
  static Future<String> base64ToImage(String base64String, {String? customFilename}) async {
    try {
      // Decodificar base64 a bytes
      final Uint8List bytes = base64Decode(base64String);
      
      // Obtener directorio para guardar la imagen
      final directory = await getApplicationDocumentsDirectory();
      final String dirPath = '${directory.path}/cenapp/imagenes_temp';
      await Directory(dirPath).create(recursive: true);
      
      // Generar nombre de archivo único
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final String fileName = customFilename ?? 'img_$timestamp.jpg';
      final String filePath = '$dirPath/$fileName';
      
      // Escribir bytes al archivo
      final File file = File(filePath);
      await file.writeAsBytes(bytes);
      
      return filePath;
    } catch (e) {
      print('Error al convertir base64 a imagen: $e');
      throw Exception('Error al convertir base64 a imagen: $e');
    }
  }
  
  /// Convierte un conjunto de rutas de imágenes a un mapa de base64
  static Future<Map<String, String>> imagesToBase64Map(List<String> imagePaths) async {
    Map<String, String> base64Map = {};
    
    try {
      for (int i = 0; i < imagePaths.length; i++) {
        final String imagePath = imagePaths[i];
        final String fileName = path.basename(imagePath);
        final String base64String = await imageToBase64(imagePath);
        
        base64Map[fileName] = base64String;
      }
      
      return base64Map;
    } catch (e) {
      print('Error al convertir imágenes a mapa base64: $e');
      throw Exception('Error al convertir imágenes a mapa base64: $e');
    }
  }
  
  /// Convierte un mapa de base64 a archivos de imagen y devuelve sus rutas
  static Future<List<String>> base64MapToImages(Map<String, String> base64Map) async {
    List<String> imagePaths = [];
    
    try {
      for (var entry in base64Map.entries) {
        final String filePath = await base64ToImage(entry.value, customFilename: entry.key);
        imagePaths.add(filePath);
      }
      
      return imagePaths;
    } catch (e) {
      print('Error al convertir mapa base64 a imágenes: $e');
      throw Exception('Error al convertir mapa base64 a imágenes: $e');
    }
  }
}