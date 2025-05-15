import 'package:cenapp/pantallas/iniciarsesion.dart';
import 'package:cenapp/pantallas/registrarse.dart';
import 'package:flutter/material.dart';
import 'package:cenapp/pantallas/recuperarContrasena.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          double logoHeight = constraints.maxHeight * 0.3;
          double buttonWidth = constraints.maxWidth * 0.7;
          double buttonHeight = constraints.maxHeight * 0.08;

          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: constraints.maxHeight * 0.15),
                Image.asset(
                  'assets/logoCenapp.png',
                  height: logoHeight,
                  fit: BoxFit.contain,
                ),
                SizedBox(height: constraints.maxHeight * 0.001),
                
                SizedBox(height: constraints.maxHeight * 0.1),
                _buildButton(
                  context,
                  'Iniciar Sesión',
                  buttonWidth,
                  buttonHeight,
                  UserLoginScreen(),
                ),
                SizedBox(height: constraints.maxHeight * 0.02),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ForgotPasswordScreen()),
                    );
                  },
                  child: Text(
                    '¿Olvidaste tu contraseña?',
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: constraints.maxWidth * 0.04,
                    ),
                  ),
                ),
                SizedBox(height: constraints.maxHeight * 0.02),
                _buildButton(
                  context,
                  'Registrarse',
                  buttonWidth,
                  buttonHeight,
                  RegisterScreen(),
                ),
                SizedBox(height: constraints.maxHeight * 0.1),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildButton(BuildContext context, String text, double width,
      double height, Widget screen) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => screen),
        );
      },
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
          fontFamily: 'Open Sans',
        ),
      ),
    );
  }
}
