import 'package:flutter/material.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:cenapp/pantallas/inicio.dart';
import 'firebase_options.dart'; 
import 'package:firebase_core/firebase_core.dart';



// Asegúrate de que el archivo ciudades_colonia.json esté en la carpeta assets
// y que esté correctamente referenciado en pubspec.yaml

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Precarga del archivo de ciudades para mejorar rendimiento
  await precacheAssets();

  // Solicitar permisos básicos al inicio
  if (Platform.isAndroid) {
    // En Android 13+ usar permisos específicos
    await Permission.photos.request();
    await Permission.videos.request();
    
    // Para compatibilidad con versiones anteriores
    await Permission.storage.request();
  }
  
  runApp(const CENApp());
}

/// Precarga recursos que pueden ser usados frecuentemente
Future<void> precacheAssets() async {
  try {
    // Esto no carga realmente el JSON, solo asegura que esté disponible
    // cuando se necesite en la aplicación
    final manifestContent = await DefaultAssetBundle.of(navigatorKey.currentContext ?? (GlobalKey<NavigatorState>().currentContext!)).loadString('AssetManifest.json');
    print('Asset manifest precargado: $manifestContent.length bytes');
  } catch (e) {
    print('Error al precargar recursos: $e');
    // La aplicación puede continuar, esto es solo una optimización
  }
}

class CENApp extends StatelessWidget {
  const CENApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey, // Agrega el navigatorKey aquí
      debugShowCheckedModeBanner: false,
      title: 'CENApp',
      home: LoginScreen(),
    ); 
  }
}