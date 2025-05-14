// lib/data/services/ciudad_colonia_service.dart
import 'dart:convert';
import 'package:flutter/services.dart';

/// Servicio para gestionar la información de ciudades, municipios y colonias
class CiudadColoniaService {
  static CiudadColoniaService? _instance;
  List<Ciudad> _ciudades = [];
  bool _isLoaded = false;

  /// Constructor privado para implementar el patrón Singleton
  CiudadColoniaService._();

  /// Método de fábrica para obtener la instancia única
  factory CiudadColoniaService() {
    _instance ??= CiudadColoniaService._();
    return _instance!;
  }

  /// Carga los datos del archivo JSON
  Future<void> cargarDatos() async {
    // Solo carga una vez para optimizar rendimiento
    if (_isLoaded) return;
    
    try {
      // Cargar el archivo JSON desde los assets
      final String jsonString = await rootBundle.loadString('assets/ciudades_colonia.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      
      // Parsear los datos a objetos Ciudad
      final List<dynamic> ciudadesJson = jsonData['ciudades'];
      _ciudades = ciudadesJson.map((ciudad) => Ciudad.fromJson(ciudad)).toList();
      
      _isLoaded = true;
    } catch (e) {
      print('Error al cargar datos de ciudades y colonias: $e');
      // Si hay error, inicializar con lista vacía
      _ciudades = [];
    }
  }
  
  /// Obtiene la lista de ciudades disponibles
  Future<List<String>> getCiudades() async {
    await cargarDatos();
    return _ciudades.map((ciudad) => ciudad.nombre).toList();
  }
  
  /// Obtiene la lista de municipios disponibles
  Future<List<String>> getMunicipios() async {
    await cargarDatos();
    return _ciudades.map((ciudad) => ciudad.municipio).toSet().toList();
  }
  
  /// Obtiene las ciudades de un municipio específico
  Future<List<String>> getCiudadesByMunicipio(String municipio) async {
    await cargarDatos();
    return _ciudades
        .where((ciudad) => ciudad.municipio == municipio)
        .map((ciudad) => ciudad.nombre)
        .toList();
  }
  
  /// Obtiene las colonias de una ciudad específica
  Future<List<String>> getColoniasByCiudad(String nombreCiudad) async {
    await cargarDatos();
    
    // Buscar la ciudad
    final ciudadEncontrada = _ciudades.firstWhere(
      (ciudad) => ciudad.nombre == nombreCiudad,
      orElse: () => Ciudad(nombre: "", municipio: "", estado: "", colonias: []),
    );
    
    return ciudadEncontrada.colonias;
  }
  
  /// Obtiene el municipio de una ciudad específica
  Future<String> getMunicipioByCiudad(String nombreCiudad) async {
    await cargarDatos();
    
    final ciudadEncontrada = _ciudades.firstWhere(
      (ciudad) => ciudad.nombre == nombreCiudad,
      orElse: () => Ciudad(nombre: "", municipio: "", estado: "", colonias: []),
    );
    
    return ciudadEncontrada.municipio;
  }
  
  /// Obtiene el estado de una ciudad específica
  Future<String> getEstadoByCiudad(String nombreCiudad) async {
    await cargarDatos();
    
    final ciudadEncontrada = _ciudades.firstWhere(
      (ciudad) => ciudad.nombre == nombreCiudad,
      orElse: () => Ciudad(nombre: "", municipio: "", estado: "", colonias: []),
    );
    
    return ciudadEncontrada.estado;
  }
}

/// Clase modelo para representar una ciudad con sus colonias
class Ciudad {
  final String nombre;
  final String municipio;
  final String estado;
  final List<String> colonias;
  
  Ciudad({
    required this.nombre,
    required this.municipio,
    required this.estado,
    required this.colonias,
  });
  
  factory Ciudad.fromJson(Map<String, dynamic> json) {
    return Ciudad(
      nombre: json['nombre'] ?? '',
      municipio: json['municipio'] ?? '',
      estado: json['estado'] ?? '',
      colonias: List<String>.from(json['colonias'] ?? []),
    );
  }
}