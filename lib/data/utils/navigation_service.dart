import 'package:flutter/material.dart';

// La clave del navegador global
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// Clase de servicio para acceder a funciones de navegación desde cualquier lugar
class NavigationService {
  // Método para navegar a una nueva ruta
  static Future<T?> navigateTo<T>(Widget route) {
    return navigatorKey.currentState!.push(
      MaterialPageRoute(builder: (_) => route),
    );
  }
  
  // Método para mostrar un diálogo
  static Future<T?> showDialogGlobal<T>(Widget dialog) {
    return showDialog<T>(
      context: navigatorKey.currentContext!,
      builder: (_) => dialog,
    );
  }
  
  // Método para mostrar un SnackBar
  static void showSnackBar(String message, {Color backgroundColor = Colors.black}) {
    ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
      ),
    );
  }
}