import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Servicio para gestionar información del usuario autenticado
class UserService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  /// Obtiene el usuario actualmente autenticado
  User? getCurrentUser() {
    return _auth.currentUser;
  }
  
  /// Verifica si hay un usuario autenticado
  bool isUserLoggedIn() {
    return _auth.currentUser != null;
  }
  
  /// Obtiene los datos completos del usuario desde Firestore
  Future<Map<String, dynamic>?> getUserData() async {
    try {
      // Obtener usuario actual
      User? user = _auth.currentUser;
      
      if (user == null) {
        return null;
      }
      
      // Buscar datos del usuario en Firestore
      DocumentSnapshot userDoc = await _firestore
          .collection('usuarios')
          .doc(user.uid)
          .get();
      
      if (userDoc.exists) {
        return userDoc.data() as Map<String, dynamic>;
      } else {
        print("No se encontraron datos del usuario en Firestore");
        return null;
      }
    } catch (e) {
      print("Error al obtener datos del usuario: $e");
      return null;
    }
  }
  
  /// Obtiene el nombre completo del usuario
  Future<String> getUserFullName() async {
    try {
      Map<String, dynamic>? userData = await getUserData();
      
      if (userData != null) {
        String nombre = userData['nombre'] ?? '';
        String apellidoPaterno = userData['apellidoPaterno'] ?? '';
        String apellidoMaterno = userData['apellidoMaterno'] ?? '';
        
        return "$nombre $apellidoPaterno $apellidoMaterno".trim();
      }
      
      return "Usuario";
    } catch (e) {
      print("Error al obtener nombre del usuario: $e");
      return "Usuario";
    }
  }
  
  /// Obtiene el grado académico del usuario
  Future<String> getUserGrado() async {
    try {
      Map<String, dynamic>? userData = await getUserData();
      
      if (userData != null) {
        return userData['grado'] ?? 'Ingeniero';
      }
      
      return "Ingeniero";
    } catch (e) {
      print("Error al obtener grado del usuario: $e");
      return "Ingeniero";
    }
  }
  
  /// Cierra la sesión del usuario
  Future<void> signOut() async {
    await _auth.signOut();
  }
}