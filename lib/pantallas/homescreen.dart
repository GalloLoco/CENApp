import 'package:flutter/material.dart';
import 'package:cenapp/pantallas/NuevoFormato.dart';
import 'package:cenapp/pantallas/buscarServidor.dart';
import 'package:cenapp/pantallas/generarreporte.dart';
import 'package:cenapp/logica/file_service.dart';
import 'package:permission_handler/permission_handler.dart'; // Añade esta importación para openAppSettings
import 'package:cenapp/data/utils/permisos_modernos.dart'; // Importación de la nueva clase

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.black),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          double buttonWidth = constraints.maxWidth * 0.8;
          double buttonHeight = constraints.maxHeight * 0.1;

          return Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    '2 de Febrero del 2025    1587 N, 251 O, 100 msnm',
                    style: TextStyle(
                        fontSize: constraints.maxWidth * 0.04,
                        color: Colors.black54),
                  ),
                ),
                SizedBox(height: constraints.maxHeight * 0.02),
                Image.asset('assets/logoCenapp.png',
                    height: constraints.maxHeight * 0.3),
                SizedBox(height: constraints.maxHeight * 0.02),
                _buildInfoText('Bienvenido: Joel', constraints.maxWidth),
                _buildInfoText('Clave: 777', constraints.maxWidth),
                _buildInfoText('Grado: Ingeniero', constraints.maxWidth),
                SizedBox(height: constraints.maxHeight * 0.05),
                _buildButton(context, 'Nuevo', Icons.add_box_outlined,
                    buttonWidth, buttonHeight, NuevoFormatoScreen()),
                SizedBox(height: constraints.maxHeight * 0.03),
                _buildButton(context, 'Abrir', Icons.folder_open, buttonWidth,
                    buttonHeight, () => _mostrarOpciones(context)),
                SizedBox(height: constraints.maxHeight * 0.03),
                _buildButton(context, 'Reportes', Icons.assignment, buttonWidth,
                    buttonHeight, ReporteScreen()),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoText(String text, double width) {
    return Align(
      alignment: Alignment.topLeft,
      child: Text(
        text,
        style: TextStyle(fontSize: width * 0.05, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildButton(BuildContext context, String text, IconData icon,
      double width, double height, dynamic screen) {
    return SizedBox(
      width: width,
      child: ElevatedButton.icon(
        onPressed: () async {
          // Verificar permisos para botones que requieren almacenamiento
          if (text == 'Abrir' || text == 'Nuevo') {
            // Usar el enfoque moderno para solicitar permisos
            bool tienePermisos = await PermisosModernos.solicitarPermisosAlmacenamiento(context);
            if (!tienePermisos) {
              // Si no hay permisos, mostrar un mensaje amigable
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Para continuar, se necesitan permisos de acceso a archivos.'),
                  backgroundColor: Colors.orange,
                  duration: Duration(seconds: 3),
                  action: SnackBarAction(
                    label: 'Configuración',
                    textColor: Colors.white,
                    onPressed: () {
                      openAppSettings();
                    },
                  ),
                ),
              );
              return;
            }
          }
          
          // Continuar con la navegación normal
          if (screen is Widget) {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => screen));
          } else if (screen is Function) {
            screen();
          }
        },
        icon: Icon(icon, color: Colors.black, size: width * 0.1),
        label: Text(
          text,
          style: TextStyle(
              fontSize: width * 0.08,
              fontWeight: FontWeight.normal,
              color: Colors.black),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.lightBlue,
          minimumSize: Size(width, height),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  void _mostrarOpciones(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Wrap(
          children: [
            ListTile(
  leading: Icon(Icons.folder, color: Colors.blue),
  title: Text('Archivos'),
  subtitle: Text('Abrir formato desde el dispositivo'),
  onTap: () async {
    // Cerrar el diálogo primero
    Navigator.pop(context);
    
    try {
      // Mostrar indicador de carga
      _mostrarCargando(context, 'Buscando archivos...');
      
      // Pasar el contexto a la función para que pueda mostrar diálogos
      final formato = await FileService.seleccionarYCargarFormato(context);
      
      // Cerrar el indicador de carga (solo si está activo)
      if (Navigator.of(context, rootNavigator: true).canPop()) {
        Navigator.of(context, rootNavigator: true).pop();
      }
      
      // Solo navegar si se seleccionó un formato válido
      if (formato != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NuevoFormatoScreen(formatoExistente: formato),
          ),
        );
      } 
      // No hacemos nada si formato == null (el usuario canceló o no hay archivos)
      
    } catch (e) {
      // Cerrar indicador de carga si está abierto
      if (Navigator.of(context, rootNavigator: true).canPop()) {
        Navigator.of(context, rootNavigator: true).pop();
      }
      
      // Mostrar mensaje de error con opción para ir a configuración
      _mostrarErrorConConfig(context, e.toString());
    }
  },
),
            ListTile(
              leading: Icon(Icons.cloud, color: Colors.lightBlue),
              title: Text('Servidor'),
              subtitle: Text('Buscar formato en el servidor'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => BuscarServidorScreen()),
                );
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.cancel, color: Colors.red),
              title: Text('Cancelar', style: TextStyle(color: Colors.red)),
              onTap: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
  }

  // Función para mostrar un indicador de carga
  void _mostrarCargando(BuildContext context, String mensaje) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 20),
                Text(mensaje),
              ],
            ),
          ),
        );
      },
    );
  }
  /// Muestra un mensaje de error con opción para ir a la configuración
void _mostrarErrorConConfig(BuildContext context, String mensaje) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        mensaje.replaceAll('Exception: ', ''), // Eliminar el "Exception: " del mensaje
        style: TextStyle(color: Colors.white),
      ),
      backgroundColor: Colors.red,
      duration: Duration(seconds: 5),
      action: SnackBarAction(
        label: 'Configuración',
        textColor: Colors.white,
        onPressed: () {
          openAppSettings();
        },
      ),
    ),
  );
}

  // Implementación completa para abrir formatos existentes
  void _abrirFormatoExistente(BuildContext context) async {
    try {
      // Verificar permisos modernos antes de continuar
      bool tienePermisos = await PermisosModernos.solicitarPermisosAlmacenamiento(context);
      if (!tienePermisos) {
        return;
      }
      
      // Mostrar indicador de carga
      _mostrarCargando(context, 'Cargando formato...');
      
      // Seleccionar y cargar archivo
      final formato = await FileService.seleccionarYCargarFormato(context);
      
      // Cerrar indicador de carga
      Navigator.of(context, rootNavigator: true).pop();
      
      if (formato != null) {
        // Navegar a la pantalla de edición con el formato cargado
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NuevoFormatoScreen(formatoExistente: formato),
          ),
        );
      }
    } catch (e) {
      // Cerrar indicador de carga si está abierto
      Navigator.of(context, rootNavigator: true).pop();
      
      // Mostrar error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al abrir el formato: ${e.toString().split(':').last.trim()}'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }
  
  // Diálogo de error mejorado
  void _mostrarError(BuildContext context, String titulo, String mensaje) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(titulo),
          content: Text(mensaje),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Aceptar'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.blue,
              ),
            ),
          ],
        );
      },
    );
  }
}