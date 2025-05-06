import 'package:flutter/material.dart';
import '../logica/formato_evaluacion.dart';

class SistemaEstructuralScreen extends StatefulWidget {
  @override
  _SistemaEstructuralScreenState createState() =>
      _SistemaEstructuralScreenState();
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
    'Geometría irregular en planta "L", "T", "H"': false,
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
            onPressed:
                _guardarYRegresar, // Conectar con el método que acabamos de crear
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
                'Marcos de acero X',
                'Marcos de concreto X',
                'Columnas y losa plana X',
                'Uso de contravientos X',
                'Muros de concreto X',
                'Muros de carga mampostería X',
                'Marcos y muros diafragma X',
                'Muros de adobe o bahareque X',
                'Muros de madera, lámina, otros X'
              ]),
              _buildCheckboxSection('Dirección Y', [
                'Marcos de acero Y',
                'Marcos de concreto Y',
                'Columnas y losa plana Y',
                'Uso de contravientos Y',
                'Muros de concreto Y',
                'Muros de carga mampostería Y',
                'Marcos y muros diafragma Y',
                'Muros de adobe o bahareque Y',
                'Muros de madera, lámina, otros Y'
              ]),
              _buildCheckboxSection('Muros de mampostería', [
                'Muros confinados',
                'Refuerzo interior',
                'Simple',
                'Tabicón de concreto',
                'Bloque concreto 20x40cm',
                'Tabique arcilla (ladrillo)',
                'Tabique hueco de arcilla'
              ]),
              _buildCheckboxSection('Sistemas de piso', [
                'Losa maciza',
                'Losa reticular',
                'Vigueta y bovedilla',
                'No se sabe'
              ]),

              //Opcion con checkbox y textbox otro
              _buildCheckboxSection(
                  'Sistemas de techo', ['Igual al piso', 'Lámina', 'Teja']),
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
                'Zapatas aisladas',
                'Zapatas corridas',
                'Cimiento de piedra',
                'Losa de cimentación',
                'Tabique arcilla (ladrillo)',
                'Cajón',
                'Pilotes / pilas',
                'No se sabe 2'
              ]),
              _buildCheckboxSection('Vulnerabilidad', [
                'Asimetría por muros, cubos, cargas',
                'Grandes aberturas, entrantes/salientes',
                'Geometría irregular en planta "L", "T", "H"',
                'Planta baja de doble altura',
                'Muros no llegan a cimentación',
                'Planta baja flexible',
                'Columna corta'
              ]),
              _buildCheckboxSection(
                  'Posición en manzana', ['Esquina', 'Medio', 'Aislado']),
              _buildCheckboxSection('Otras características', [
                'Grandes masas en pisos superiores',
                'Reducción brusca de pisos superiores'
              ]),
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

  // Añade este método a la clase _SistemaEstructuralScreenState
  void _guardarYRegresar() {
    // Crear objeto de sistema estructural con los datos ingresados
    final sistema = SistemaEstructural(
      direccionX: {
        'Marcos de acero X': selectedCheckboxes['Marcos de acero X'] ?? false,
        'Marcos de concreto X':
            selectedCheckboxes['Marcos de concreto X'] ?? false,
        'Columnas y losa plana X':
            selectedCheckboxes['Columnas y losa plana X'] ?? false,
        'Uso de contravientos X':
            selectedCheckboxes['Uso de contravientos X'] ?? false,
        'Muros de concreto X':
            selectedCheckboxes['Muros de concreto X'] ?? false,
        'Muros de carga mampostería X':
            selectedCheckboxes['Muros de carga mampostería X'] ?? false,
        'Marcos y muros diafragma X':
            selectedCheckboxes['Marcos y muros diafragma X'] ?? false,
        'Muros de adobe o bahareque X':
            selectedCheckboxes['Muros de adobe o bahareque X'] ?? false,
        'Muros de madera, lámina, otros X':
            selectedCheckboxes['Muros de madera, lámina, otros X'] ?? false,
      },
      direccionY: {
        'Marcos de acero Y': selectedCheckboxes['Marcos de acero Y'] ?? false,
        'Marcos de concreto Y':
            selectedCheckboxes['Marcos de concreto Y'] ?? false,
        'Columnas y losa plana Y':
            selectedCheckboxes['Columnas y losa plana Y'] ?? false,
        'Uso de contravientos Y':
            selectedCheckboxes['Uso de contravientos Y'] ?? false,
        'Muros de concreto Y':
            selectedCheckboxes['Muros de concreto Y'] ?? false,
        'Muros de carga mampostería Y':
            selectedCheckboxes['Muros de carga mampostería Y'] ?? false,
        'Marcos y muros diafragma Y':
            selectedCheckboxes['Marcos y muros diafragma Y'] ?? false,
        'Muros de adobe o bahareque Y':
            selectedCheckboxes['Muros de adobe o bahareque Y'] ?? false,
        'Muros de madera, lámina, otros Y':
            selectedCheckboxes['Muros de madera, lámina, otros Y'] ?? false,
      },
      murosMamposteria: {
        'Muros confinados': selectedCheckboxes['Muros confinados'] ?? false,
        'Refuerzo interior': selectedCheckboxes['Refuerzo interior'] ?? false,
        'Simple': selectedCheckboxes['Simple'] ?? false,
        'Tabicón de concreto':
            selectedCheckboxes['Tabicón de concreto'] ?? false,
        'Bloque concreto 20x40cm':
            selectedCheckboxes['Bloque concreto 20x40cm'] ?? false,
        'Tabique arcilla (ladrillo)':
            selectedCheckboxes['Tabique arcilla (ladrillo)'] ?? false,
        'Tabique hueco de arcilla':
            selectedCheckboxes['Tabique hueco de arcilla'] ?? false,
      },
      sistemasPiso: {
        'Losa maciza': selectedCheckboxes['Losa maciza'] ?? false,
        'Losa reticular': selectedCheckboxes['Losa reticular'] ?? false,
        'Vigueta y bovedilla':
            selectedCheckboxes['Vigueta y bovedilla'] ?? false,
        'No se sabe': selectedCheckboxes['No se sabe'] ?? false,
      },
      sistemasTecho: {
        'Igual al piso': selectedCheckboxes['Igual al piso'] ?? false,
        'Lámina': selectedCheckboxes['Lámina'] ?? false,
        'Teja': selectedCheckboxes['Teja'] ?? false,
      },
      otroTecho: otroTechoController.text,
      cimentacion: {
        'Zapatas aisladas': selectedCheckboxes['Zapatas aisladas'] ?? false,
        'Zapatas corridas': selectedCheckboxes['Zapatas corridas'] ?? false,
        'Cimiento de piedra': selectedCheckboxes['Cimiento de piedra'] ?? false,
        'Losa de cimentación':
            selectedCheckboxes['Losa de cimentación'] ?? false,
        'Tabique arcilla (ladrillo)':
            selectedCheckboxes['Tabique arcilla (ladrillo)'] ?? false,
        'Cajón': selectedCheckboxes['Cajón'] ?? false,
        'Pilotes / pilas': selectedCheckboxes['Pilotes / pilas'] ?? false,
        'No se sabe 2': selectedCheckboxes['No se sabe 2'] ?? false,
      },
      vulnerabilidad: {
        'Asimetría por muros, cubos, cargas':
            selectedCheckboxes['Asimetría por muros, cubos, cargas'] ?? false,
        'Grandes aberturas, entrantes/salientes':
            selectedCheckboxes['Grandes aberturas, entrantes/salientes'] ??
                false,
        'Geometría irregular en planta':
            selectedCheckboxes['Geometría irregular en planta "L", "T", "H"'] ??
                false,
        'Planta baja de doble altura':
            selectedCheckboxes['Planta baja de doble altura'] ?? false,
        'Muros no llegan a cimentación':
            selectedCheckboxes['Muros no llegan a cimentación'] ?? false,
        'Planta baja flexible':
            selectedCheckboxes['Planta baja flexible'] ?? false,
        'Columna corta': selectedCheckboxes['Columna corta'] ?? false,
      },
      posicionManzana: {
        'Esquina': selectedCheckboxes['Esquina'] ?? false,
        'Medio': selectedCheckboxes['Medio'] ?? false,
        'Aislado': selectedCheckboxes['Aislado'] ?? false,
      },
      otrasCaracteristicas: {
        'Grandes masas en pisos superiores':
            selectedCheckboxes['Grandes masas en pisos superiores'] ?? false,
        'Reducción brusca de pisos superiores':
            selectedCheckboxes['Reducción brusca de pisos superiores'] ?? false,
      },
      separacionEdificios: double.tryParse(separacionEdif.text) ?? 0.0,
    );

    // Regresar con los datos
    Navigator.pop(context, {
      'completado': true,
      'datos': sistema,
    });
  }
}
