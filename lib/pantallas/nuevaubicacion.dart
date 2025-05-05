import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class UbicacionGeorreferencialScreen extends StatefulWidget {
  @override
  _UbicacionGeorreferencialScreenState createState() =>
      _UbicacionGeorreferencialScreenState();
}

class _UbicacionGeorreferencialScreenState
    extends State<UbicacionGeorreferencialScreen> {
  // Variable para controlar la opción seleccionada (solo una a la vez)
  String? selectedPlano;

  // Variables para el mapa
  final MapController mapController = MapController();
  LatLng posicionActual = LatLng(24.1426, -110.3128); // La Paz, BCS por defecto
  bool isLoadingLocation = false;
  
  // Variables para imágenes
  final ImagePicker _picker = ImagePicker();
  bool _isProcessingImage = false;
  List<String> imagenesAdjuntas = [];
  static const int MAX_FOTOS = 6; // Limitar cantidad de fotos

  // Controladores
  TextEditingController direccionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkPermisos();
  }

  // Verificar y solicitar permisos
  Future<void> _checkPermisos() async {
    // Permisos de ubicación
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _mostrarError('Permisos de ubicación denegados');
        return;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      _mostrarError('Los permisos de ubicación están permanentemente denegados. Por favor, habilítalos en la configuración de la app.');
      return;
    }
    
    // Permisos de cámara para después
    var statusCamera = await Permission.camera.status;
    if (!statusCamera.isGranted) {
      statusCamera = await Permission.camera.request();
    }
    
    // Obtener ubicación actual si los permisos están concedidos
    if (permission == LocationPermission.whileInUse || 
        permission == LocationPermission.always) {
      _obtenerUbicacionActual();
    }
  }

  // Obtener ubicación actual
  Future<void> _obtenerUbicacionActual() async {
    try {
      setState(() {
        isLoadingLocation = true;
      });
      
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high
      );
      
      LatLng nuevaPosicion = LatLng(position.latitude, position.longitude);
      
      setState(() {
        posicionActual = nuevaPosicion;
        isLoadingLocation = false;
      });
      
      // Centrar mapa en la ubicación actual
      mapController.move(posicionActual, 15.0);
      
      // Obtener dirección a partir de coordenadas
      _obtenerDireccion(posicionActual);
      
    } catch (e) {
      setState(() {
        isLoadingLocation = false;
      });
      _mostrarError('Error al obtener ubicación: $e');
    }
  }

  // Obtener dirección a partir de coordenadas (geocodificación inversa)
  Future<void> _obtenerDireccion(LatLng coordenadas) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        coordenadas.latitude, 
        coordenadas.longitude
      );
      
      if (placemarks.isNotEmpty) {
        Placemark lugar = placemarks.first;
        String direccion = '${lugar.street}, ${lugar.subLocality}, ${lugar.locality}, ${lugar.administrativeArea}';
        direccionController.text = direccion;
      }
    } catch (e) {
      print('Error al obtener dirección: $e');
      // No mostrar error al usuario para no interrumpir la experiencia
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.check, color: Colors.black),
            onPressed: _guardarYRegresar,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  'Ubicación Georreferencial',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 10),
              _buildRadioSection('Existen planos:'),
              _buildTextField('Dirección', direccionController),
              SizedBox(height: 10),
              _buildMapSection(),
              SizedBox(height: 20),
              _buildSeccionFotografias(),
            ],
          ),
        ),
      ),
    );
  }

  /// Construir sección de radio buttons
  Widget _buildRadioSection(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 10),
        Text(title,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        RadioListTile<String>(
          title: Text('Arquitectónico'),
          value: 'Arquitectónico',
          groupValue: selectedPlano,
          onChanged: (String? value) {
            setState(() {
              selectedPlano = value;
            });
          },
        ),
        RadioListTile<String>(
          title: Text('Estructural'),
          value: 'Estructural',
          groupValue: selectedPlano,
          onChanged: (String? value) {
            setState(() {
              selectedPlano = value;
            });
          },
        ),
        RadioListTile<String>(
          title: Text('Ninguno'),
          value: 'Ninguno',
          groupValue: selectedPlano,
          onChanged: (String? value) {
            setState(() {
              selectedPlano = value;
            });
          },
        ),
      ],
    );
  }

  /// Construir campo de texto
  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  /// Construir sección del mapa
  Widget _buildMapSection() {
    return Column(
      children: [
        Container(
          height: 250,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black),
          ),
          child: Stack(
            children: [
              FlutterMap(
                mapController: mapController,
                options: MapOptions(
                  initialCenter: posicionActual,
                  initialZoom: 14,
                  onTap: (_, point) {
                    setState(() {
                      posicionActual = point;
                    });
                    _obtenerDireccion(point);
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                    subdomains: ['a', 'b', 'c'],
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: posicionActual,
                        width: 50.0,
                        height: 50.0,
                        child: Icon(Icons.location_pin,
                            color: Colors.red, size: 40),
                      ),
                    ],
                  ),
                ],
              ),
              Positioned(
                right: 10,
                bottom: 10,
                child: FloatingActionButton(
                  mini: true,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.my_location, color: Colors.blue),
                  onPressed: _obtenerUbicacionActual,
                ),
              ),
              if (isLoadingLocation)
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withOpacity(0.3),
                    child: Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  ),
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(
            'Toca el mapa para seleccionar la ubicación',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ),
      ],
    );
  }

  /// Construir sección de fotografías
  Widget _buildSeccionFotografias() {
    return Column(
      children: [
        Divider(),
        Center(
          child: Text(
            'Adjuntar Fotografías',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(height: 10),
        
        // Mostrar fotos adjuntas
        if (imagenesAdjuntas.isNotEmpty)
          Container(
            height: 120,
            width: double.infinity,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: imagenesAdjuntas.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Stack(
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            File(imagenesAdjuntas[index]),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        right: 0,
                        top: 0,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              imagenesAdjuntas.removeAt(index);
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            padding: EdgeInsets.all(4),
                            child: Icon(Icons.close, size: 16, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          )
        else
          Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(
                  color: Colors.black, style: BorderStyle.solid, width: 2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                'No hay fotos adjuntas',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
          ),
          
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildImageButton(
              icon: Icons.camera_alt,
              label: 'Cámara',
              color: Colors.blue,
              onPressed: _tomarFoto,
            ),
            SizedBox(width: 20),
            _buildImageButton(
              icon: Icons.photo_library,
              label: 'Galería',
              color: Colors.green,
              onPressed: _seleccionarDeGaleria,
            ),
          ],
        ),
        
        if (imagenesAdjuntas.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              '${imagenesAdjuntas.length}/$MAX_FOTOS fotos adjuntas',
              style: TextStyle(
                fontSize: 12, 
                color: imagenesAdjuntas.length >= MAX_FOTOS 
                  ? Colors.red 
                  : Colors.grey[600]
              ),
            ),
          ),
      ],
    );
  }

  /// Construir botón para añadir imagen
  Widget _buildImageButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Column(
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            shape: CircleBorder(),
            padding: EdgeInsets.all(15),
          ),
          onPressed: onPressed,
          child: Icon(icon, color: Colors.white, size: 30),
        ),
        SizedBox(height: 5),
        Text(label),
      ],
    );
  }

  /// Tomar foto con la cámara - versión optimizada
  Future<void> _tomarFoto() async {
    if (_isProcessingImage) return; // Evitar múltiples llamadas
    
    // Verificar límite
    if (imagenesAdjuntas.length >= MAX_FOTOS) {
      _mostrarError('Límite de $MAX_FOTOS fotos alcanzado. Elimina algunas para continuar.');
      return;
    }
    
    try {
      setState(() => _isProcessingImage = true);
      
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 50, // Menor calidad = menos memoria
        maxWidth: 800,    // Limitar dimensiones
        maxHeight: 800,
        preferredCameraDevice: CameraDevice.rear,
      );
      
      if (photo != null) {
        String rutaGuardada = await _guardarImagen(photo);
        
        // Liberar memoria inmediatamente
        final compressedFile = File(photo.path);
        if (await compressedFile.exists() && photo.path != rutaGuardada) {
          await compressedFile.delete()
              .catchError((e) => print('Error eliminando archivo temporal: $e'));
        }
        
        setState(() {
          imagenesAdjuntas.add(rutaGuardada);
        });
      }
    } catch (e) {
      _mostrarError('Error al tomar foto: $e');
    } finally {
      setState(() => _isProcessingImage = false);
    }
  }

  /// Seleccionar imagen de la galería
  Future<void> _seleccionarDeGaleria() async {
    if (_isProcessingImage) return;
    
    // Verificar límite
    if (imagenesAdjuntas.length >= MAX_FOTOS) {
      _mostrarError('Límite de $MAX_FOTOS fotos alcanzado. Elimina algunas para continuar.');
      return;
    }
    
    try {
      setState(() => _isProcessingImage = true);
      
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 50,
        maxWidth: 800,
        maxHeight: 800,
      );
      
      if (image != null) {
        String rutaGuardada = await _guardarImagen(image);
        setState(() {
          imagenesAdjuntas.add(rutaGuardada);
        });
      }
    } catch (e) {
      _mostrarError('Error al seleccionar imagen: $e');
    } finally {
      setState(() => _isProcessingImage = false);
    }
  }

  /// Guardar imagen localmente - optimizado
  Future<String> _guardarImagen(XFile imagen) async {
    try {
      // Obtener directorio de documentos de la app
      final directory = await getApplicationDocumentsDirectory();
      final String dirPath = '${directory.path}/cenapp/imagenes';
      
      // Crear directorio si no existe
      await Directory(dirPath).create(recursive: true);
      
      // Generar nombre único
      final String fileName = 
          'IMG_${DateTime.now().millisecondsSinceEpoch}${path.extension(imagen.path)}';
      final String filePath = '$dirPath/$fileName';
      
      // Leer bytes de la imagen
      final bytes = await imagen.readAsBytes();
      
      // Escribir directamente el archivo en lugar de copiarlo
      await File(filePath).writeAsBytes(bytes);
      
      return filePath;
    } catch (e) {
      throw Exception('Error al guardar imagen: $e');
    }
  }

  /// Mostrar mensaje de error
  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: Colors.red,
      ),
    );
  }

  /// Guardar y regresar a la pantalla anterior
  void _guardarYRegresar() {
  // Validar datos mínimos
  if (direccionController.text.isEmpty) {
    _mostrarError('Por favor ingresa una dirección');
    return;
  }
  
  // Crear objeto de ubicación con los datos ingresados
  final ubicacion = {
    'completado': true,
    'datos': {
      'existenPlanos': selectedPlano,
      'direccion': direccionController.text,
      'latitud': posicionActual.latitude,
      'longitud': posicionActual.longitude,
      'rutasFotos': imagenesAdjuntas,
    },
  };
  
  // Regresar con los datos
  Navigator.pop(context, ubicacion);
}

  @override
  void dispose() {
    // Liberar recursos
    mapController.dispose();
direccionController.dispose();
super.dispose();
}
}