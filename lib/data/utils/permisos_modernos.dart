import 'package:flutter/material.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

class PermisosModernos {
  
  /// Solicita los permisos necesarios para dispositivos modernos (Android 13+)
  static Future<bool> solicitarPermisosAlmacenamiento(BuildContext context) async {
    // Lista de permisos a solicitar según la versión de Android
    List<Permission> permisosNecesarios = [];
    
    if (Platform.isAndroid) {
      // En Android 13+ se utilizan permisos más específicos
      permisosNecesarios.add(Permission.photos);
      permisosNecesarios.add(Permission.videos);
      
      // Para compatibilidad con versiones anteriores
      permisosNecesarios.add(Permission.storage);
    }
    
    // Solicitar todos los permisos necesarios
    Map<Permission, PermissionStatus> statuses = await permisosNecesarios.request();
    
    // Verificar si alguno de los permisos fue concedido
    bool algunoConcedido = statuses.values.any((status) => status.isGranted);
    
    if (!algunoConcedido) {
      // Si ninguno fue concedido, mostrar mensaje
      _mostrarDialogoPermisosModernos(context);
      return false;
    }
    
    return true;
  }
  
  /// Diálogo para explicar los permisos en versiones modernas
  static Future<void> _mostrarDialogoPermisosModernos(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Permisos requeridos'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Para utilizar esta función, CENApp necesita acceso a:'),
              SizedBox(height: 10),
              _buildPermisoItem(Icons.photo, 'Fotos y videos para adjuntar imágenes'),
              _buildPermisoItem(Icons.save, 'Almacenamiento para guardar documentos'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                openAppSettings();
              },
              child: Text('Ir a Configuración'),
            ),
          ],
        );
      },
    );
  }
  
  static Widget _buildPermisoItem(IconData icon, String texto) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 18),
          SizedBox(width: 8),
          Expanded(child: Text(texto)),
        ],
      ),
    );
  }
}