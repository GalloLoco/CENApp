import 'package:flutter/material.dart';

class SistemaEstructuralScreen extends StatefulWidget {
  @override
  _SistemaEstructuralScreenState createState() => _SistemaEstructuralScreenState();
}

class _SistemaEstructuralScreenState extends State<SistemaEstructuralScreen> {
  Map<String, bool> selectedCheckboxes = {
     'Marcos de acero X': false,
    'Marcos de concreto X': false,
    'Columnas y losa plana X': false,
    'Uso de contravientos X': false,
    'Muros de concreto X': false,
    'Muros de carga mampostería X': false,
    'Marcos y muros diafragma X': false,
    'Muros de adobe o bahareque X': false,
    'Muros de madera, lámina, otros X': false,
    'Marcos de acero Y': false,
    'Marcos de concreto Y': false,
    'Columnas y losa plana Y': false,
    'Uso de contravientos Y': false,
    'Muros de concreto Y': false,
    'Muros de carga mampostería Y': false,
    'Marcos y muros diafragma Y': false,
    'Muros de adobe o bahareque Y': false,
    'Muros de madera, lámina, otros Y': false,
    'Muros confinados': false,
    'Refuerzo interior': false,
    'Simple': false,
    'Tabicón de concreto': false,
    'Bloque concreto 20x40cm': false,
    'Tabique arcilla (ladrillo)': false,
    'Tabique hueco de arcilla': false,
    'Losa maciza': false,
    'Losa reticular': false,
    'Vigueta y bovedilla': false,
    'No se sabe': false,
    'Igual al piso': false,
    'Lámina': false,
    'Teja': false,
    'Zapatas aisladas': false,
    'Zapatas corridas': false,
    'Cimiento de piedra': false,
    'Losa de cimentación': false,
    //'Tabique arcilla (ladrillo)': false,
    'Cajón': false,
    'Pilotes / pilas': false,
    'No se sabe 2': false,
    'Asimetría por muros, cubos, cargas': false,
    'Grandes aberturas, entrantes/salientes': false,
    'Geometría irregular en planta “L”, “T”, “H”': false,
    'Planta baja de doble altura': false,
    'Muros no llegan a cimentación': false,
    'Planta baja flexible': false,
    'Columna corta': false,
    'Esquina': false,
    'Medio': false,
    'Aislado': false,
    'Grandes masas en pisos superiores': false,
    'Reducción brusca de pisos superiores': false,
  };

  TextEditingController otroTechoController = TextEditingController();
  TextEditingController separacionEdif = TextEditingController();

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
                  'Sistema Estructural',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 10),
              _buildCheckboxSection('Dirección X', [
                'Marcos de acero X', 'Marcos de concreto X', 'Columnas y losa plana X', 'Uso de contravientos X', 'Muros de concreto X',
                'Muros de carga mampostería X', 'Marcos y muros diafragma X', 'Muros de adobe o bahareque X', 'Muros de madera, lámina, otros X'
              ]),
              _buildCheckboxSection('Dirección Y', [
                'Marcos de acero Y', 'Marcos de concreto Y', 'Columnas y losa plana Y', 'Uso de contravientos Y', 'Muros de concreto Y',
                'Muros de carga mampostería Y', 'Marcos y muros diafragma Y', 'Muros de adobe o bahareque Y', 'Muros de madera, lámina, otros Y'
              ]),
              _buildCheckboxSection('Muros de mampostería', [
                'Muros confinados', 'Refuerzo interior', 'Simple', 'Tabicón de concreto', 'Bloque concreto 20x40cm', 'Tabique arcilla (ladrillo)', 'Tabique hueco de arcilla'
              ]),
              _buildCheckboxSection('Sistemas de piso', ['Losa maciza', 'Losa reticular', 'Vigueta y bovedilla', 'No se sabe']),

                //Opcion con checkbox y textbox otro              
              _buildCheckboxSection('Sistemas de techo', ['Igual al piso', 'Lámina', 'Teja']),
              Row(
                children: [
                  Checkbox(
                    value: selectedCheckboxes['Otro techo'] ?? false,
                    onChanged: (bool? value) {
                      setState(() {
                        selectedCheckboxes['Otro techo'] = value ?? false;
                      });
                    },
                  ),
                  Expanded(
                    child: TextField(
                      controller: otroTechoController,
                      decoration: InputDecoration(
                        labelText: 'Otro:',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              _buildCheckboxSection('Cimentación', [
                'Zapatas aisladas', 'Zapatas corridas', 'Cimiento de piedra', 'Losa de cimentación', 'Tabique arcilla (ladrillo)',
                'Cajón', 'Pilotes / pilas', 'No se sabe 2'
              ]),
              _buildCheckboxSection('Vulnerabilidad', [
                'Asimetría por muros, cubos, cargas', 'Grandes aberturas, entrantes/salientes', 'Geometría irregular en planta “L”, “T”, “H”',
                'Planta baja de doble altura', 'Muros no llegan a cimentación', 'Planta baja flexible', 'Columna corta'
              ]),
              _buildCheckboxSection('Posición en manzana', ['Esquina', 'Medio', 'Aislado']),
              _buildCheckboxSection('Otras características', ['Grandes masas en pisos superiores', 'Reducción brusca de pisos superiores']),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: separacionEdif,
                      decoration: InputDecoration(
                        labelText: 'Separacion Edif. Vecinos(CM):',
                        border: OutlineInputBorder(),
                      ),
                    ),
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
        Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
}
