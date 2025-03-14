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
            SizedBox(width: 10),
            Image.asset('assets/logoCenapp.png', height: 50),
          ],)
        
      ),
      body: SingleChildScrollView(
        child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Registrarse',
                    style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                    
                  ),
                  
                ],
              ),
              SizedBox(height: 80),
              _buildInputField(Icons.person, 'Nombre de usuario'),
              SizedBox(height: 20),
              _buildInputField(Icons.person, 'Nombre Completo:'),
              SizedBox(height: 20),
              _buildInputField(Icons.engineering, 'Grado:'),
              SizedBox(height: 20),
              _buildInputField(Icons.lock, 'Contraseña', obscureText: true),
              SizedBox(height: 20),
              _buildInputField(Icons.lock, 'Repetir contraseña', obscureText: true),
              SizedBox(height: 80),
              ElevatedButton(
                onPressed: () {
                   Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => HomeScreen()),
                      );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlue,
                  minimumSize: Size(double.infinity, 50),
                ),
                child: Text(
                  'Aceptar',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
        ),
      );
    
  }

  Widget _buildInputField(IconData icon, String hintText, {bool obscureText = false}) {
    return TextField(
      obscureText: obscureText,
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        hintText: hintText,
        border: OutlineInputBorder(),
      ),
    );
  }
}
