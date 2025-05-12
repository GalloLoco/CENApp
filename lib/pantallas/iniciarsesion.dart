import 'package:cenapp/pantallas/homescreen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserLoginScreen extends StatefulWidget {
  const UserLoginScreen({super.key});

  @override
  _UserLoginScreenState createState() => _UserLoginScreenState();
}

class _UserLoginScreenState extends State<UserLoginScreen> {
  // Controladores para los campos de texto
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  // Variable para controlar el estado de carga
  bool _isLoading = false;
  
  // Clave global para el formulario
  final _formKey = GlobalKey<FormState>();

  // Función para iniciar sesión con Firebase
  Future<void> _iniciarSesion() async {
    // Validar formulario
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Iniciar sesión con Firebase Authentication
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      
      // Si llegamos aquí, la autenticación fue exitosa
      setState(() {
        _isLoading = false;
      });
      
      // Mostrar mensaje de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Inicio de sesión exitoso'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 1),
        ),
      );
      
      // Navegar a la pantalla principal
      print("Inicio de sesión exitoso, navegando a HomeScreen...");
      try {
        // Usar pushReplacement para sustituir la pantalla actual por la nueva
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
        print("Navegación completada");
      } catch (e) {
        print("Error en la navegación: $e");
      }
      
    } on FirebaseAuthException catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      // Manejar errores específicos de autenticación
      String mensajeError = 'Error al iniciar sesión';
      
      if (e.code == 'user-not-found') {
        mensajeError = 'No existe una cuenta con este correo electrónico';
      } else if (e.code == 'wrong-password') {
        mensajeError = 'Contraseña incorrecta';
      } else if (e.code == 'invalid-email') {
        mensajeError = 'El formato del correo electrónico no es válido';
      } else if (e.code == 'user-disabled') {
        mensajeError = 'Esta cuenta ha sido deshabilitada';
      } else if (e.code == 'too-many-requests') {
        mensajeError = 'Demasiados intentos fallidos. Intenta más tarde';
      }
      
      // Mostrar mensaje de error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(mensajeError),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      // Manejar otros errores
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    // Liberar recursos
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
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
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          double fieldWidth = constraints.maxWidth * 0.8;
          double buttonWidth = constraints.maxWidth * 0.7;
          double buttonHeight = constraints.maxHeight * 0.08;

          return SingleChildScrollView(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: constraints.maxHeight * 0.05),
                      Image.asset('assets/logoCenapp.png', height: constraints.maxHeight * 0.3),
                      SizedBox(height: constraints.maxHeight * 0.05),
                      Text(
                        'Iniciar Sesión',
                        style: TextStyle(
                          fontSize: constraints.maxWidth * 0.1,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: constraints.maxHeight * 0.05),
                      
                      // Campo de correo electrónico (modificado de "Usuario")
                      _buildInputField(
                        Icons.email, 
                        'Correo electrónico', 
                        _emailController, 
                        fieldWidth,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingresa tu correo electrónico';
                          }
                          // Validar formato de email
                          bool emailValid = RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(value);
                          if (!emailValid) {
                            return 'Ingresa un correo electrónico válido';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: constraints.maxHeight * 0.02),
                      
                      // Campo de contraseña
                      _buildInputField(
                        Icons.lock, 
                        'Contraseña', 
                        _passwordController, 
                        fieldWidth,
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingresa tu contraseña';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: constraints.maxHeight * 0.05),
                      
                      // Botón de inicio de sesión
                      _isLoading
                          ? CircularProgressIndicator()
                          : _buildButton(
                              context,
                              'Entrar',
                              buttonWidth,
                              buttonHeight,
                              _iniciarSesion,
                            ),
                      SizedBox(height: constraints.maxHeight * 0.1),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInputField(
    IconData icon,
    String hintText,
    TextEditingController controller,
    double width, {
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return SizedBox(
      width: width,
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          prefixIcon: Icon(icon),
          hintText: hintText,
          border: OutlineInputBorder(),
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildButton(
    BuildContext context,
    String text,
    double width,
    double height,
    Function() onPressed,
  ) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.lightBlue,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        padding: EdgeInsets.symmetric(vertical: height * 0.3),
        minimumSize: Size(width, height),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: width * 0.08,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}