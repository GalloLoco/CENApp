import 'package:flutter/material.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:cenapp/pantallas/inicio.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
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

class CENApp extends StatelessWidget {
  const CENApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CENApp',
      home: LoginScreen(),
    ); 
  }
}