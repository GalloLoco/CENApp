import 'package:cenapp/pantallas/HomeScreen.dart';
import 'package:flutter/material.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

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
        title: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Image.asset('assets/logoCenapp.png', height: 50),
          ],
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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: constraints.maxHeight * 0.05),
                    Text(
                      'Registrarse',
                      style: TextStyle(
                        fontSize: constraints.maxWidth * 0.1,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: constraints.maxHeight * 0.05),
                    _buildInputField(Icons.person, 'Nombre de usuario', fieldWidth),
                    SizedBox(height: constraints.maxHeight * 0.02),
                    _buildInputField(Icons.person, 'Nombre Completo', fieldWidth),
                    SizedBox(height: constraints.maxHeight * 0.02),
                    _buildInputField(Icons.engineering, 'Grado', fieldWidth),
                    SizedBox(height: constraints.maxHeight * 0.02),
                    _buildInputField(Icons.lock, 'Contraseña', fieldWidth, obscureText: true),
                    SizedBox(height: constraints.maxHeight * 0.02),
                    _buildInputField(Icons.lock, 'Repetir contraseña', fieldWidth, obscureText: true),
                    SizedBox(height: constraints.maxHeight * 0.05),
                    _buildButton(context, 'Aceptar', buttonWidth, buttonHeight, HomeScreen()),
                    SizedBox(height: constraints.maxHeight * 0.1),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInputField(IconData icon, String hintText, double width, {bool obscureText = false}) {
    return SizedBox(
      width: width,
      child: TextField(
        obscureText: obscureText,
        decoration: InputDecoration(
          prefixIcon: Icon(icon),
          hintText: hintText,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildButton(BuildContext context, String text, double width, double height, Widget screen) {
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
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

