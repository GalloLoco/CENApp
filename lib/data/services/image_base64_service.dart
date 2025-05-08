// lib/data/services/image_base64_service.dart
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:image/image.dart' as img;

/// Servicio para convertir imágenes entre formato de archivo y base64
class ImageBase64Service {
  /// Convierte una imagen de archivo a cadena base64 de manera optimizada
  static Future<String> imageToBase64(String imagePath) async {
    try {
      final File file = File(imagePath);
      if (!await file.exists()) {
        throw Exception('El archivo de imagen no existe: $imagePath');
      }
      
      // Comprobar el tamaño antes de procesar
      final fileSize = await file.length();
      if (fileSize > 10 * 1024 * 1024) { // Si es mayor a 10MB
        throw Exception('La imagen es demasiado grande para convertir a base64');
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
      if (decodedImage.width > 800 || decodedImage.height > 800) {
        resizedImage = img.copyResize(
          decodedImage,
          width: decodedImage.width > 800 ? 800 : decodedImage.width,
          height: (decodedImage.height * (decodedImage.width > 800 ? 800 / decodedImage.width : 1)).toInt(),
        );
      }
      
      // Comprimir al 70% de calidad
      final compressedBytes = img.encodeJpg(resizedImage, quality: 70);
      
      // Convertir bytes a base64
      final String base64String = base64Encode(compressedBytes);
      
      return base64String;
    } catch (e) {
      print('Error al convertir imagen a base64: $e');
      throw Exception('Error al convertir imagen a base64: $e');
    }
  }

  /// Convierte una cadena base64 a un archivo de imagen y devuelve la ruta - versión optimizada
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
      
      // Escribir bytes al archivo de manera optimizada
      final File file = File(filePath);
      await file.writeAsBytes(bytes, flush: true);
      
      return filePath;
    } catch (e) {
      print('Error al convertir base64 a imagen: $e');
      throw Exception('Error al convertir base64 a imagen: $e');
    }
  }
  
  /// Convierte un conjunto de rutas de imágenes a un mapa de base64 - versión optimizada
  static Future<Map<String, String>> imagesToBase64Map(List<String> imagePaths) async {
    Map<String, String> base64Map = {};
    List<Exception> errores = [];
    
    for (int i = 0; i < imagePaths.length; i++) {
      try {
        final String imagePath = imagePaths[i];
        final String fileName = path.basename(imagePath);
        final String base64String = await imageToBase64(imagePath);
        
        base64Map[fileName] = base64String;
      } catch (e) {
        // Acumular errores pero seguir procesando las demás imágenes
        errores.add(Exception('Error en imagen ${i+1}: $e'));
      }
    }
    
    // Si hubo errores pero se procesaron algunas imágenes, continuar
    if (errores.isNotEmpty && base64Map.isEmpty) {
      throw Exception('No se pudo convertir ninguna imagen: ${errores.first}');
    }
    
    return base64Map;
  }
  
  /// Convierte un mapa de base64 a archivos de imagen y devuelve sus rutas - versión optimizada
  static Future<List<String>> base64MapToImages(Map<String, String> base64Map) async {
    List<String> imagePaths = [];
    List<Exception> errores = [];
    
    for (var entry in base64Map.entries) {
      try {
        final String filePath = await base64ToImage(entry.value, customFilename: entry.key);
        imagePaths.add(filePath);
      } catch (e) {
        // Acumular errores pero seguir procesando las demás imágenes
        errores.add(Exception('Error al procesar una imagen: $e'));
      }
    }
    
    // Si hubo errores pero se procesaron algunas imágenes, continuar
    if (errores.isNotEmpty && imagePaths.isEmpty) {
      throw Exception('No se pudo convertir ninguna imagen: ${errores.first}');
    }
    
    return imagePaths;
  }
}