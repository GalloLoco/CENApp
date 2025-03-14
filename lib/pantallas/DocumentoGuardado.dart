import 'package:flutter/material.dart';

class DocumentoGuardadoScreen extends StatelessWidget {
  const DocumentoGuardadoScreen({super.key});

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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 10),
            Icon(
              Icons.assignment_turned_in,
              size: 200,
              color: Colors.green,
            ),
            SizedBox(height: 10),
            Text(
              'Archivo "Cenap1132.json" creado con éxito.',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 35),
            _buildButton(context, Icons.download, 'Descargar', Colors.lightBlue, () {
              // Acción de descarga
            }, ),
            SizedBox(height: 50),
            _buildButton(context, Icons.mail, 'Enviar Mail', Colors.lightBlue, () {
              // Acción de enviar correo
            }, ),
            SizedBox(height: 50),
            _buildButton(context, Icons.share, 'Exportar', Colors.lightBlue, () {
              // Acción de exportar
            },),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(BuildContext context, IconData icon, String text, Color color, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 100,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        icon: Icon(icon, color: Colors.white, size: 50),
        label: Text(
          text,
          style: TextStyle(fontSize: 40, color: Colors.white, fontWeight: FontWeight.bold),
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
