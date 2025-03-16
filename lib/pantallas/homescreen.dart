import 'package:cenapp/pantallas/NuevoFormato.dart';
import 'package:cenapp/pantallas/buscarServidor.dart';
import 'package:cenapp/pantallas/generarreporte.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.black), 
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          double buttonWidth = constraints.maxWidth * 0.8;
          double buttonHeight = constraints.maxHeight * 0.1;
          
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    '2 de Febrero del 2025    1587 N, 251 O, 100 msnm',
                    style: TextStyle(fontSize: constraints.maxWidth * 0.04, color: Colors.black54),
                  ),
                ),
                SizedBox(height: constraints.maxHeight * 0.02),
                Image.asset('assets/logoCenapp.png', height: constraints.maxHeight * 0.3),
                SizedBox(height: constraints.maxHeight * 0.02),
                _buildInfoText('Bienvenido: Joel', constraints.maxWidth),
                _buildInfoText('Clave: 777', constraints.maxWidth),
                _buildInfoText('Grado: Ingeniero', constraints.maxWidth),
                SizedBox(height: constraints.maxHeight * 0.05),
                _buildButton(
                  context, 'Nuevo', Icons.add_box_outlined, buttonWidth, buttonHeight, NuevoFormatoScreen()
                ),
                SizedBox(height: constraints.maxHeight * 0.03),
                _buildButton(
                  context, 'Abrir', Icons.folder_open, buttonWidth, buttonHeight, () => _mostrarOpciones(context)
                ),
                SizedBox(height: constraints.maxHeight * 0.03),
                _buildButton(
                  context, 'Reportes', Icons.assignment, buttonWidth, buttonHeight, ReporteScreen()
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoText(String text, double width) {
    return Align(
      alignment: Alignment.topLeft,
      child: Text(
        text,
        style: TextStyle(fontSize: width * 0.05, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildButton(BuildContext context, String text, IconData icon, double width, double height, dynamic screen) {
    return SizedBox(
      width: width,
      child: ElevatedButton.icon(
        onPressed: () {
          if (screen is Widget) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
          } else if (screen is Function) {
            screen();
          }
        },
        icon: Icon(icon, color: Colors.black, size: width * 0.1),
        label: Text(
          text,
          style: TextStyle(fontSize: width * 0.08, fontWeight: FontWeight.normal, color: Colors.black),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.lightBlue,
          minimumSize: Size(width, height),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: Icon(Icons.cloud),
              title: Text('Servidor'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => BuscarServidorScreen()),
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
