// ignore: file_names
import 'package:cenapp/pantallas/DocumentoGuardado.dart';
import 'package:cenapp/pantallas/nuevaubicacion.dart';
import 'package:cenapp/pantallas/nuevoinfogen.dart';
import 'package:cenapp/pantallas/nuevosisest.dart';
import 'package:cenapp/pantallas/nuevaevaluacion.dart';
import 'package:flutter/material.dart';

class NuevoFormatoScreen extends StatefulWidget {
  const NuevoFormatoScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _NuevoFormatoScreenState createState() => _NuevoFormatoScreenState();
}

class _NuevoFormatoScreenState extends State<NuevoFormatoScreen> {
  bool informacionGeneralCompletado = false;
  bool sistemaEstructuralCompletado = false;
  bool evaluacionDanosCompletado = false;
  bool ubicacionGeorreferencialCompletado = false;

   void _validarYContinuar() {
    if (informacionGeneralCompletado && sistemaEstructuralCompletado && evaluacionDanosCompletado && ubicacionGeorreferencialCompletado) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => DocumentoGuardadoScreen()),
      );
    } else {
      _mostrarAlerta();
    }
  }

  void _mostrarAlerta() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Faltan apartados'),
          content: Text('Debe completar todas las categorías antes de continuar.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.checklist, color: Colors.black),
            onPressed: _validarYContinuar ,// Acción del botón de checklist
            
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 10),
            Text(
              'Categorias:',
              style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 15),
            Text(
              'Rellene correctamente cada apartado',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, color: Colors.black54),
            ),
            SizedBox(height: 100),
            _buildButton(
              context,
              'Información general del inmueble',
              informacionGeneralCompletado,
              () async {
                final resultado = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => InformacionGeneralScreen()),
                );

                if (resultado == true) {
                  setState(() {
                    informacionGeneralCompletado = true;
                  });
                }
              },
            ),
            SizedBox(height: 40),
            _buildButton(context, 'Sistema Estructural',sistemaEstructuralCompletado , () async {
                final resultado = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SistemaEstructuralScreen()),
                );

                if (resultado == true) {
                  setState(() {
                    sistemaEstructuralCompletado = true;
                  });
                }
              },),
            SizedBox(height: 40),
            _buildButton(context, 'Evaluación de daños', evaluacionDanosCompletado, () async {
                final resultado = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EvaluacionDanosScreen()),
                );

                if (resultado == true) {
                  setState(() {
                    evaluacionDanosCompletado = true;
                  });
                }
              },),
            SizedBox(height: 40),
            _buildButton(context, 'Ubicación georreferencial', ubicacionGeorreferencialCompletado, ()async {
                final resultado = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UbicacionGeorreferencialScreen()),
                );

                if (resultado == true) {
                  setState(() {
                    ubicacionGeorreferencialCompletado = true;
                  });
                }
              },),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(BuildContext context, String text, bool completado, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: completado ? Colors.blue : Color(0xFF80C0ED), // 🔹 Se cambia si está completado
          padding: EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 18,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}