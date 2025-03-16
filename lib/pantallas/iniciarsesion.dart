import 'package:cenapp/pantallas/homescreen.dart';
import 'package:flutter/material.dart';

class UserLoginScreen extends StatelessWidget {
  const UserLoginScreen({super.key});

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
                    _buildInputField(Icons.person, 'Usuario', fieldWidth),
                    SizedBox(height: constraints.maxHeight * 0.02),
                    _buildInputField(Icons.lock, 'Contraseña', fieldWidth, obscureText: true),
                    SizedBox(height: constraints.maxHeight * 0.05),
                    _buildButton(context, 'Entrar', buttonWidth, buttonHeight, HomeScreen()),
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