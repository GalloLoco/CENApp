import 'package:flutter/material.dart';
import 'package:cenapp/pantallas/NuevoFormato.dart';
import 'package:cenapp/pantallas/buscarServidor.dart';
import 'package:cenapp/pantallas/generarreporte.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cenapp/logica/file_service.dart';
import 'package:permission_handler/permission_handler.dart'; // Añade esta importación para openAppSettings
import 'package:cenapp/data/utils/permisos_modernos.dart'; // Importación de la nueva clase
import '../logica/formato_evaluacion.dart';
import 'package:cenapp/main.dart';
import 'package:cenapp/data/services/user_service.dart';
import 'package:cenapp/data/services/location_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Servicios
  final UserService _userService = UserService();
  final LocationService _locationService = LocationService();
  
  // Variables para almacenar datos dinámicos
  String _nombreCompleto = "Cargando...";
  String _grado = "Cargando...";
  String _fechaActual = "Cargando...";
  String _ubicacionActual = "Cargando...";
  
  @override
  void initState() {
    super.initState();
    _cargarDatosUsuario();
    _cargarFechaYUbicacion();
  }
  
  /// Carga datos del usuario autenticado
  Future<void> _cargarDatosUsuario() async {
    try {
      // Cargar nombre
      String nombre = await _userService.getUserFullName();
      
      // Cargar grado
      String grado = await _userService.getUserGrado();
      
      // Actualizar estado
      setState(() {
        _nombreCompleto = nombre;
        _grado = grado;
      });
    } catch (e) {
      print("Error al cargar datos del usuario: $e");
      // Mostrar mensaje de error si es necesario
    }
  }
  
  /// Carga fecha actual y ubicación
  Future<void> _cargarFechaYUbicacion() async {
    try {
      // Cargar fecha
      String fecha = _locationService.getCurrentFormattedDate();
      
      // Actualizar estado parcialmente
      setState(() {
        _fechaActual = fecha;
      });
      
      // Cargar ubicación (puede tardar más)
      String ubicacion = await _locationService.getFormattedLocation();
      
      // Actualizar estado
      setState(() {
        _ubicacionActual = ubicacion;
      });
    } catch (e) {
      print("Error al cargar fecha y ubicación: $e");
      // Mostrar mensaje de error si es necesario
    }
  }

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
            onPressed: () async {
              // Cerrar sesión y volver a la pantalla de inicio
              await _userService.signOut();
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
                    // Fecha y ubicación dinámica
                    '$_fechaActual    $_ubicacionActual',
                    style: TextStyle(
                        fontSize: constraints.maxWidth * 0.04,
                        color: Colors.black54),
                  ),
                ),
                SizedBox(height: constraints.maxHeight * 0.02),
                Image.asset('assets/logoCenapp.png',
                    height: constraints.maxHeight * 0.3),
                SizedBox(height: constraints.maxHeight * 0.02),
                _buildInfoText('Bienvenido: $_nombreCompleto', constraints.maxWidth),
                _buildInfoText('Grado: $_grado', constraints.maxWidth),
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
            bool tienePermisos =
                await PermisosModernos.solicitarPermisosAlmacenamiento(context);
            if (!tienePermisos) {
              // Si no hay permisos, mostrar un mensaje amigable
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      'Para continuar, se necesitan permisos de acceso a archivos.'),
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
              onTap: () {
                // Cerrar el diálogo bottom sheet primero
                Navigator.pop(context);

                // Usar un método que no dependa de contextos anidados
                _seleccionarArchivo(context);
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
                  MaterialPageRoute(
                      builder: (context) => BuscarServidorScreen()),
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

  // Función para seleccionar archivo
  void _seleccionarArchivo(BuildContext context) async {
    print("🔍 DIAGNÓSTICO: Iniciando selección de archivo...");
    
    // Guardar una referencia global al contexto de la aplicación
    final navState = navigatorKey.currentState;
    if (navState == null) {
      print("❌ No se puede obtener el estado del navegador global");
      return;
    }
    
    try {
      // Seleccionar archivo directamente
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
      );
      
      if (result == null || result.files.isEmpty || result.files.first.path == null) {
        print("⚠️ Selección cancelada o archivo inválido");
        return;
      }
      
      String filePath = result.files.first.path!;
      print("✅ Archivo seleccionado: $filePath");
      
      // Verificar extensión .json
      if (!filePath.toLowerCase().endsWith('.json')) {
        ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
          SnackBar(content: Text('Por favor selecciona un archivo JSON'))
        );
        return;
      }
      
      // Cargar el formato
      FormatoEvaluacion? formato;
      try {
        formato = await FileService.cargarFormatoJSON(filePath);
        print("✅ Formato cargado con éxito: ID=${formato.id}");
      } catch (e) {
        print("❌ Error al cargar formato: $e");
        
        ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
          SnackBar(content: Text('Error al cargar el formato: ${e.toString()}'))
        );
        return;
      }
      
      // Navegar usando el navigatorKey global
      print("🔍 Navegando a NuevoFormatoScreen...");
      
      // Importante: Usar pushReplacement para evitar problemas de navegación
      navState.pushReplacement(
        MaterialPageRoute(
          builder: (context) => NuevoFormatoScreen(formatoExistente: formato),
        ),
      );
      
      print("✅ Navegación iniciada");
      
    } catch (e) {
      print("❌❌ ERROR GENERAL: ${e.toString()}");
      
      // Mostrar mensaje de error usando el contexto global
      ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
        SnackBar(content: Text('Error inesperado: ${e.toString()}'))
      );
    }
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
}