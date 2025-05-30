/*

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as path;

/// Servicio optimizado para guardar imágenes en la galería del dispositivo
class ImageGalleryService {
  
  /// Guarda una lista de imágenes en la galería del dispositivo
  static Future<Map<String, bool>> guardarImagenesEnGaleria({
    required List<String> rutasImagenes,
    String? albumName = 'CENApp_Evaluaciones',
    BuildContext? context,
  }) async {
    
    print('📸 [GALLERY] Iniciando guardado de ${rutasImagenes.length} imágenes...');
    
    Map<String, bool> resultados = {};
    
    // Verificar permisos
    bool tienePermisos = await _verificarPermisos();
    if (!tienePermisos) {
      print('❌ [GALLERY] Sin permisos');
      for (String ruta in rutasImagenes) {
        resultados[ruta] = false;
      }
      return resultados;
    }
    
    // Procesar cada imagen
    for (int i = 0; i < rutasImagenes.length; i++) {
      String rutaImagen = rutasImagenes[i];
      
      try {
        bool exito = await _guardarImagenIndividual(
          rutaImagen: rutaImagen,
          albumName: albumName,
          indice: i + 1,
        );
        
        resultados[rutaImagen] = exito;
        
        // Pausa para no saturar el sistema
        if (i < rutasImagenes.length - 1) {
          await Future.delayed(Duration(milliseconds: 100));
        }
        
      } catch (e) {
        print('❌ [GALLERY] Error imagen ${i + 1}: $e');
        resultados[rutaImagen] = false;
      }
    }
    
    // Mostrar notificación si se proporciona contexto
    if (context != null) {
      _mostrarNotificacion(context, resultados);
    }
    
    return resultados;
  }
  
  /// Guarda una imagen individual
  static Future<bool> _guardarImagenIndividual({
    required String rutaImagen,
    String? albumName,
    int? indice,
  }) async {
    
    try {
      File archivoImagen = File(rutaImagen);
      if (!await archivoImagen.exists()) return false;
      
      Uint8List imageBytes = await archivoImagen.readAsBytes();
      if (imageBytes.isEmpty) return false;
      
      // Nombre descriptivo
      String timestamp = DateTime.now().toIso8601String().replaceAll(':', '-').split('.')[0];
      String nombreArchivo = 'CENApp_Eval_${indice ?? 'img'}_$timestamp';
      
      // Guardar en galería
      final result = await ImageGallerySaver.saveImage(
        imageBytes,
        name: nombreArchivo,
        
        isReturnImagePathOfIOS: true,
      );
      
      return result != null && result['isSuccess'] == true;
      
    } catch (e) {
      print('❌ [GALLERY] Error: $e');
      return false;
    }
  }
  
  /// Verificar permisos
  static Future<bool> _verificarPermisos() async {
    try {
      if (Platform.isAndroid) {
        List<Permission> permisos = [Permission.photos, Permission.storage];
        Map<Permission, PermissionStatus> statuses = await permisos.request();
        return statuses.values.any((status) => status == PermissionStatus.granted);
      } else if (Platform.isIOS) {
        PermissionStatus status = await Permission.photos.request();
        return status == PermissionStatus.granted || status == PermissionStatus.limited;
      }
      return true;
    } catch (e) {
      return false;
    }
  }
  
  /// Mostrar notificación de resultado
  static void _mostrarNotificacion(BuildContext context, Map<String, bool> resultados) {
    int exitosos = resultados.values.where((v) => v == true).length;
    int fallidos = resultados.values.where((v) => v == false).length;
    
    String mensaje;
    Color color;
    
    if (fallidos == 0) {
      mensaje = exitosos == 1 ? 'Imagen guardada en galería' : '$exitosos imágenes guardadas en galería';
      color = Colors.green;
    } else if (exitosos == 0) {
      mensaje = 'Error al guardar imágenes en galería';
      color = Colors.red;
    } else {
      mensaje = '$exitosos guardadas, $fallidos con errores';
      color = Colors.orange;
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje, style: TextStyle(color: Colors.white)),
        backgroundColor: color,
        duration: Duration(seconds: 3),
      ),
    );
  }
}*/