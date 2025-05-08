// lib/utils/permisos_manager.dart

import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';

/// Clase para manejar los permisos de la aplicación
class PermisosManager {
  /// Solicita los permisos necesarios y muestra diálogos apropiados
  static Future<bool> solicitarPermisosAlmacenamiento(BuildContext context) async {
    // Verificar estado actual de los permisos
    PermissionStatus statusStorage = await Permission.storage.status;
    
    // Si ya está concedido, retornar true inmediatamente
    if (statusStorage.isGranted) {
      return true;
    }
    
    // Si está permanentemente denegado, mostrar diálogo explicativo
    if (statusStorage.isPermanentlyDenied) {
      // Mostrar diálogo explicativo con opción para ir a configuración
      bool irAConfiguracion = await _mostrarDialogoConfiguracion(context);
      if (irAConfiguracion) {
        // Abrir configuración de la aplicación
        await openAppSettings();
        // No podemos saber el resultado, así que verificamos de nuevo
        return await Permission.storage.status.isGranted;
      }
      return false;
    }
    
    // Solicitar permisos normalmente
    statusStorage = await Permission.storage.request();
    
    // Si fue denegado tras solicitar, mostrar mensaje explicativo
    if (statusStorage.isDenied) {
      _mostrarMensajePermisoDenegado(context);
      return false;
    }
    
    // Para Android 10+ (API 29+), también solicitar permisos adicionales si están disponibles
    if (statusStorage.isGranted) {
      try {
        // En Android 11+ intentar solicitar MANAGE_EXTERNAL_STORAGE
        PermissionStatus statusManage = await Permission.manageExternalStorage.status;
        if (!statusManage.isGranted && !statusManage.isPermanentlyDenied) {
          await Permission.manageExternalStorage.request();
        }
      } catch (e) {
        // Algunos dispositivos no soportan este permiso, ignorar errores
        print('Error al solicitar permisos adicionales: $e');
      }
      
      // Adicionalmente solicitar permisos para fotos
      try {
        await Permission.photos.request();
      } catch (e) {
        print('Error al solicitar permiso para fotos: $e');
      }
      
      return true;
    }
    
    return statusStorage.isGranted;
  }

  /// Muestra un diálogo explicando por qué se necesitan permisos y pide ir a configuración
  static Future<bool> _mostrarDialogoConfiguracion(BuildContext context) async {
    final resultado = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Permisos necesarios'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Para utilizar esta función, es necesario otorgar permisos de almacenamiento.'),
                SizedBox(height: 10),
                Text('Por favor, abra la configuración y otorgue los permisos necesarios a la aplicación.'),
              ],
            ),
          ),
          actions: <Widget>[
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

  /// Muestra un mensaje explicativo cuando el usuario deniega el permiso
  static void _mostrarMensajePermisoDenegado(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Permisos de almacenamiento denegados. Para continuar, por favor otorga permisos de almacenamiento en la configuración.',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 4),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }
}