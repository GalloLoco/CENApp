import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class UbicacionGeorreferencialScreen extends StatefulWidget {
  @override
  _UbicacionGeorreferencialScreenState createState() =>
      _UbicacionGeorreferencialScreenState();
}

class _UbicacionGeorreferencialScreenState
    extends State<UbicacionGeorreferencialScreen> {
  Map<String, bool> selectedCheckboxes = {
    'Arquitectonico': false,
    'Estructural': false,
    'Ninguno': false,
  };

  TextEditingController direccionController = TextEditingController();
  List<Image> imagenesAdjuntas = [];

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
        actions: [
          IconButton(
            icon: Icon(Icons.check, color: Colors.black),
            onPressed: () {
              Navigator.pop(context, true);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  'Ubicación Georreferencial',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 10),
              _buildCheckboxSection('Existen planos:',
                  ['Arquitectonico', 'Estructural', 'Ninguno']),
              _buildTextField('Dirección', direccionController),
              SizedBox(height: 10),
              Container(
                height: 250,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                ),
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter: LatLng(
                        24.1426, -110.3128), // Nueva ubicación en La Paz, BCS
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
                          point: LatLng(24.1426, -110.3128), // La Paz, BCS
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
              Divider(),
              Center(
                child: Text(
                  'Adjuntar Fotografías',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 10),
              Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(
                      color: Colors.black, style: BorderStyle.solid, width: 2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child:
                      Icon(Icons.camera_alt, size: 50, color: Colors.black54),
                ),
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      IconButton(
                        icon: Icon(Icons.add_circle,
                            color: Colors.green, size: 40),
                        onPressed: () {
                          // Acción para agregar imagen
                        },
                      ),
                      Text('Agregar'),
                    ],
                  ),
                  SizedBox(width: 40),
                  Column(
                    children: [
                      IconButton(
                        icon: Icon(Icons.remove_circle,
                            color: Colors.red, size: 40),
                        onPressed: () {
                          // Acción para eliminar imagen
                        },
                      ),
                      Text('Eliminar'),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCheckboxSection(String title, List<String> options) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 10),
        Text(title,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ...options.map((option) {
          return CheckboxListTile(
            title: Text(option),
            value: selectedCheckboxes[option],
            onChanged: (bool? value) {
              setState(() {
                selectedCheckboxes[option] = value ?? false;
              });
            },
          );
        }).toList(),
      ],
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
}
