import 'dart:ffi' hide Size;
import 'package:flutter/material.dart';

class DocumentoGuardadoScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            _mostrarConfirmacionRegreso(context);
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15.0),
            child: Image.asset(
              'assets/logoCenapp.png',
              height: 100,
            ),
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
                SizedBox(height: constraints.maxHeight * 0.05),
                Icon(
                  Icons.assignment_turned_in,
                  size: constraints.maxWidth * 0.3,
                  color: Colors.green,
                ),
                SizedBox(height: constraints.maxHeight * 0.05),
                Text(
                  'Archivo "Cenap1132.json" creado con éxito.',
                  style: TextStyle(
                    fontSize: constraints.maxWidth * 0.06,
                    fontWeight: FontWeight.w900,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: constraints.maxHeight * 0.05),
                _buildButton(context, Icons.download, 'Descargar', buttonWidth, buttonHeight),
                SizedBox(height: constraints.maxHeight * 0.03),
                _buildButton(context, Icons.mail, 'Enviar Mail', buttonWidth, buttonHeight),
                SizedBox(height: constraints.maxHeight * 0.03),
                _buildButton(context, Icons.share, 'Exportar', buttonWidth, buttonHeight),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildButton(BuildContext context, IconData icon, String text, double width, double height) {
    return SizedBox(
      width: width,
      child: ElevatedButton.icon(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.lightBlue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: EdgeInsets.symmetric(vertical: height * 0.3),
          minimumSize: Size(width, height),
        ),
        icon: Icon(icon, color: Colors.white, size: width * 0.1),
        label: Text(
          text,
          style: TextStyle(
            fontSize: width * 0.08,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _mostrarConfirmacionRegreso(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('¿Quieres regresar al inicio?'),
          content: Text('Una vez regresado, cualquier cambio no guardado se perderá.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: Text('Aceptar', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }
}

