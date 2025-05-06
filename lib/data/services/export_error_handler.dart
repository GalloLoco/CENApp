// lib/data/services/export_error_handler.dart

import 'dart:io';
import 'package:flutter/foundation.dart';

/// Servicio para manejar errores durante la exportación de documentos
class ExportErrorHandler {
  
  /// Analiza un error y devuelve un mensaje amigable para el usuario
  static String obtenerMensajeError(dynamic error) {
    String mensajeError = 'Error desconocido durante la exportación';
    
    if (error is Exception) {
      String errorStr = error.toString().toLowerCase();
      
      // Errores relacionados con Excel
      if (errorStr.contains('cellvalue') || 
          errorStr.contains('type \'string\' is not a subtype of type')) {
        return 'Error de formato en los datos. Es posible que haya caracteres especiales que no son compatibles con Excel.';
      } 
      // Errores de permisos
      else if (errorStr.contains('permission') || 
               errorStr.contains('denied') ||
               errorStr.contains('access')) {
        return 'Error de permisos. Asegúrese de que la aplicación tiene acceso al almacenamiento del dispositivo.';
      } 
      // Errores de rutas
      else if (errorStr.contains('path') || 
               errorStr.contains('directory') ||
               errorStr.contains('file')) {
        return 'Error al crear el archivo. Verifique el almacenamiento disponible en su dispositivo.';
      }
      // Errores de tiempo de espera
      else if (errorStr.contains('timeout')) {
        return 'La operación ha tardado demasiado tiempo. Intente con un formato de datos más pequeño.';
      }
      // Errores de memoria
      else if (errorStr.contains('memory') || 
               errorStr.contains('out of memory')) {
        return 'No hay suficiente memoria para completar la operación. Intente cerrar otras aplicaciones.';
      }
      
      // Extraer mensaje de error de la excepción (eliminar "Exception: " del inicio)
      mensajeError = error.toString();
      if (mensajeError.startsWith('Exception: ')) {
        mensajeError = mensajeError.substring(11);
      }
    } else if (error is FileSystemException) {
      // Errores específicos del sistema de archivos
      if (error.osError != null) {
        return 'Error de sistema: ${error.osError!.message}';
      }
      mensajeError = 'Error de acceso al archivo: ${error.message}';
    } else {
      mensajeError = error.toString();
    }
    
    return mensajeError;
  }
  
  /// Registra el error para análisis futuro (logging)
  static void registrarError(dynamic error, String operacion, {StackTrace? stackTrace}) {
    // En producción, aquí conectaríamos con un servicio de registro como 
    // Firebase Crashlytics, Sentry.io, etc.
    if (kDebugMode) {
      print('==== ERROR EN $operacion ====');
      print('TIPO: ${error.runtimeType}');
      print('DETALLES: $error');
      if (stackTrace != null) {
        print('STACK TRACE:\n$stackTrace');
      }
      print('==============================');
    }
  }
  
  /// Verifica si hay espacio suficiente para la operación de exportación
  static Future<bool> verificarEspacioSuficiente(int tamanoEstimado) async {
    try {
      Directory tempDir = Directory.systemTemp;
      final stat = await tempDir.stat();
      
      // En sistemas donde no podemos obtener el espacio libre,
      // asumimos que hay suficiente
      if (stat.type == FileSystemEntityType.notFound) {
        return true;
      }
      
      // En implementaciones futuras, aquí verificaríamos el espacio disponible
      // pero esto requiere implementaciones específicas por plataforma
      
      return true;
    } catch (e) {
      // Si no podemos verificar, asumimos que hay espacio
      return true;
    }
  }
}