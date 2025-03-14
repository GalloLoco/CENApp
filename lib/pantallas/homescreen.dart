import 'package:cenapp/pantallas/NuevoFormato.dart';
import 'package:cenapp/pantallas/buscarServidor.dart';
import 'package:cenapp/pantallas/generarreporte.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(50), // Ajusta la altura del degradado
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF64B7F1),
                Color(0xFFA4D4F5),
                Color.fromARGB(255, 255, 255, 255)
              ],
              stops: [0.0, 0.52, 1.0],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Colors
                .transparent, // Hace que el fondo del AppBar sea transparente
            elevation: 0,
            actions: [
              IconButton(
                icon: Icon(Icons.logout, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                '2 de Febrero del 2025                              1587 N, 251 O, 100 msnm',
                style: TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ),
            SizedBox(height: 0),
            Image.asset('assets/logoCenapp.png', height: 300),
            SizedBox(height: 0),
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                'Bienvenido: Joel',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                'Clave: 777',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                'Grado: Ingeniero',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => NuevoFormatoScreen()),
                );
              },
              icon: Icon(Icons.add_box_outlined, color: Colors.black, size: 50),
              label: Text(
                'Nuevo',
                style: TextStyle(
                  fontSize: 50,
                  fontWeight: FontWeight.normal,
                  color: Colors.black,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlue,
                minimumSize: Size(double.infinity, 80),
              ),
            ),
            SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () {
                _mostrarOpciones(context);
              },
              icon: Icon(Icons.folder_open, color: Colors.black, size: 50),
              label: Text(
                'Abrir',
                style: TextStyle(
                  fontSize: 50,
                  fontWeight: FontWeight.normal,
                  color: Colors.black,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlue,
                minimumSize: Size(double.infinity, 80),
              ),
            ),
            SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ReporteScreen()),
                );
              },
              icon: Icon(Icons.assignment, color: Colors.black, size: 50),
              label: Text(
                'Reportes',
                style: TextStyle(
                  fontSize: 50,
                  fontWeight: FontWeight.normal,
                  color: Colors.black,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlue,
                minimumSize: Size(double.infinity, 80),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarOpciones(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Wrap(
          children: [
            ListTile(
              leading: Icon(Icons.folder),
              title: Text('Archivos'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.cloud),
              title: Text('Servidor'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => BuscarServidorScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.cancel, color: Colors.red),
              title: Text('Cancelar', style: TextStyle(color: Colors.red)),
              onTap: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
  }
}
