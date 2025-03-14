import 'package:flutter/material.dart';

class EvaluacionDanosScreen extends StatefulWidget {
  @override
  _EvaluacionDanosScreenState createState() => _EvaluacionDanosScreenState();
}

class _EvaluacionDanosScreenState extends State<EvaluacionDanosScreen> {
  Map<String, bool> selectedCheckboxes = {
    'Grietas en el terreno': false,
    'Hundimientos': false,
    'Colapso': false,
    'Falla en conexiones': false,
    'Daño ligero': false,
    'Daño medio': false,
    'Daño severo': false,
    'Colapso total': false,
    'Vidrios': false,
    'Acabados': false,
    'Plafones': false,
    'Fachadas': false,
    'Bardas y pretiles': false,
    'Cubos (escalera/elevador)': false,
    'Instalaciones': false,
  };

  TextEditingController inclinacionController = TextEditingController();
  TextEditingController grietasMaxController = TextEditingController();
  TextEditingController flechaMaxController = TextEditingController();
  TextEditingController columnasDanioSeveroController = TextEditingController();
  TextEditingController totalColumnasEntrepisosController = TextEditingController();

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
                  'Evaluación de Daños',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 10),
              _buildCheckboxSection('Geotécnicos', ['Grietas en el terreno', 'Hundimientos']),
              _buildTextField('Inclinación del edificio', inclinacionController, '%'),
              _buildCheckboxSection('Losas', ['Colapso']),
              _buildTextField('Grietas max', grietasMaxController, 'mm'),
              _buildTextField('Flecha max', flechaMaxController, 'cm'),
              _buildCheckboxSection('Conexiones', ['Falla en conexiones']),
              _buildMatrizDanios(),
              _buildTextField('No. de columnas (o muros) daño severo', columnasDanioSeveroController, ''),
              _buildTextField('Total de columnas (muros) en el entrepiso', totalColumnasEntrepisosController, ''),
              _buildCheckboxSection('Nivel de daño de la estructura', ['Daño ligero', 'Daño medio', 'Daño severo', 'Colapso total']),
              _buildCheckboxSection('Otros daños', ['Vidrios', 'Acabados', 'Plafones', 'Fachadas', 'Bardas y pretiles', 'Cubos (escalera/elevador)', 'Instalaciones']),
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

  Widget _buildTextField(String label, TextEditingController controller, String suffix) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          suffixText: suffix,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildMatrizDanios() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 10),
        Text('Colapso - Grietas Cortante', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Table(
          border: TableBorder.all(),
          children: [
            TableRow(children: [
              Center(child: Text('Columnas')),
              Center(child: Checkbox(value: false, onChanged: (val) {})),
              Center(child: Checkbox(value: false, onChanged: (val) {})),
            ]),
            TableRow(children: [
              Center(child: Text('Trabes')),
              Center(child: Checkbox(value: false, onChanged: (val) {})),
              Center(child: Checkbox(value: false, onChanged: (val) {})),
            ]),
            TableRow(children: [
              Center(child: Text('Muro (Mampost.)')),
              Center(child: Checkbox(value: false, onChanged: (val) {})),
              Center(child: Checkbox(value: false, onChanged: (val) {})),
            ]),
            TableRow(children: [
              Center(child: Text('Muro (concreto)')),
              Center(child: Checkbox(value: false, onChanged: (val) {})),
              Center(child: Checkbox(value: false, onChanged: (val) {})),
            ]),
          ],
        ),
      ],
    );
  }
}
