import 'package:geolocator/geolocator.dart';


/// Servicio para gestionar la ubicación y fecha actual
class LocationService {
  
  /// Obtiene la fecha actual formateada
  String getCurrentFormattedDate() {
     final now = DateTime.now();
  
  // Lista de meses en español
  final meses = [
    'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio', 
    'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'
  ];
  
  // Construir la fecha formateada manualmente
  return '${now.day} de ${meses[now.month - 1]} del ${now.year}';
  }
  
  /// Verifica y solicita permisos de ubicación
  Future<bool> _checkAndRequestLocationPermissions() async {
    bool serviceEnabled;
    LocationPermission permission;
    
    // Verificar si el servicio de ubicación está habilitado
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }
    
    // Verificar permisos
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      return false;
    }
    
    return true;
  }
  
  /// Obtiene la ubicación actual
  Future<Position?> getCurrentLocation() async {
    try {
      bool permissionsGranted = await _checkAndRequestLocationPermissions();
      
      if (!permissionsGranted) {
        print("Permisos de ubicación no concedidos");
        return null;
      }
      
      // Obtener ubicación actual
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      print("Error al obtener ubicación: $e");
      return null;
    }
  }
  
  /// Formatea la ubicación para mostrarla
  Future<String> getFormattedLocation() async {
    try {
      Position? position = await getCurrentLocation();
      
      if (position != null) {
        // Redondear a 4 decimales para mayor precisión
        double lat = double.parse(position.latitude.toStringAsFixed(4));
        double lng = double.parse(position.longitude.toStringAsFixed(4));
        double alt = double.parse(position.altitude.toStringAsFixed(0));
        
        String latDir = lat >= 0 ? "N" : "S";
        String lngDir = lng >= 0 ? "E" : "O";
        
        // Formato: "19.4326 N, 99.1332 O, 2240 msnm"
        return "${lat.abs()} $latDir, ${lng.abs()} $lngDir, ${alt.toInt()} msnm";
      }
      
      return "Ubicación no disponible";
    } catch (e) {
      print("Error al formatear ubicación: $e");
      return "Ubicación no disponible";
    }
  }
}