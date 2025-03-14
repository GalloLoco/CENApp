import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class ReporteScreen extends StatefulWidget {
  @override
  _ReporteScreenState createState() => _ReporteScreenState();
}

class _ReporteScreenState extends State<ReporteScreen> {
  TextEditingController nombreInmuebleController = TextEditingController();
  TextEditingController fechaInicioController =
      TextEditingController(text: '08/02/2025');
  TextEditingController fechaFinalController =
      TextEditingController(text: '08/02/2025');
  String tipoReporte = '';
  String estadistico = '';
  String evaluador = '';
  String ubicacionGeografica = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(50), // Ajusta la altura del degradado
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF64B7F1), Color(0xFFA4D4F5), Color.fromARGB(255, 255, 255, 255)],
              stops: [0.0, 0.52, 1.0],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: AppBar(
            backgroundColor: Colors
                .transparent, // Hace que el fondo del AppBar sea transparente
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  'Reporte',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 15),
              _buildTextField('Nombre del inmueble', nombreInmuebleController),
              SizedBox(height: 10),
              Text('Fecha de evaluación:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Row(
                children: [
                  Expanded(
                      child: _buildTextField('Inicio', fechaInicioController)),
                  SizedBox(width: 10),
                  Text('-'),
                  SizedBox(width: 10),
                  Expanded(
                      child: _buildTextField('Final', fechaFinalController)),
                ],
              ),
              SizedBox(height: 10),
              _buildDropdownField(
                  'Tipo de reporte', ['Opción 1', 'Opción 2', 'Opción 3'],
                  (value) {
                setState(() {
                  tipoReporte = value!;
                });
              }),
              _buildDropdownField(
                  'Estadístico', ['Opción A', 'Opción B', 'Opción C'], (value) {
                setState(() {
                  estadistico = value!;
                });
              }),
              _buildDropdownField(
                  'Evaluador', ['Persona 1', 'Persona 2', 'Persona 3'],
                  (value) {
                setState(() {
                  evaluador = value!;
                });
              }),
              _buildDropdownField(
                  'Ubicación geográfica', ['Zona 1', 'Zona 2', 'Zona 3'],
                  (value) {
                setState(() {
                  ubicacionGeografica = value!;
                });
              }),
              SizedBox(height: 10),
              Container(
                height: 250,
                decoration:
                    BoxDecoration(border: Border.all(color: Colors.black)),
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter: LatLng(24.1426, -110.3128),
                    initialZoom: 14,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                      subdomains: ['a', 'b', 'c'],
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: LatLng(24.1426, -110.3128),
                          width: 50.0,
                          height: 50.0,
                          child: Icon(Icons.location_pin,
                              color: Colors.red, size: 40),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    // Acción para generar el reporte
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Generar',
                    style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildDropdownField(
      String label, List<String> options, ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        items: options.map((String option) {
          return DropdownMenuItem<String>(
            value: option,
            child: Text(option),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }
}
