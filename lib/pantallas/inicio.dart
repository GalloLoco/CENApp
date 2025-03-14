// ignore: file_names
import 'package:cenapp/pantallas/iniciarsesion.dart';
import 'package:cenapp/pantallas/registrarse.dart';
import 'package:flutter/material.dart';


class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 20),
            Image.asset('assets/logoCenapp.png', height: 400,), // Ajuste de tamaño para mayor similitud
            //SizedBox(height: 0),
            Text(
              'CENApp',
              style: TextStyle(
                fontFamily: 'Open Sans',
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 150),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UserLoginScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: EdgeInsets.symmetric(vertical: 15),
                minimumSize: Size(250, 50),
                
              ),
              child: Text('Iniciar Sesión', style: TextStyle(
                fontSize: 18, 
                color: Colors.white,
                fontFamily: 'Open Sans',)
                ),
            ),
            SizedBox(height: 10),
            TextButton(
              onPressed: () {},
              child: Text(
                '¿Olvidaste tu contraseña?',
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 14,
                ),
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegisterScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: EdgeInsets.symmetric(vertical: 15),
                minimumSize: Size(250, 50),
              ),
              child: Text('Registrarse', style: TextStyle(fontSize: 18, color: Colors.white)),
            ),
            SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  
}


