import 'package:flutter/material.dart';

class InformacionGeneralScreen extends StatefulWidget {
  @override
  _InformacionGeneralScreenState createState() => _InformacionGeneralScreenState();
}

class _InformacionGeneralScreenState extends State<InformacionGeneralScreen> {
  bool isCompleted = false;

  // Mapa para almacenar los valores de los checkboxes
  Map<String, bool> selectedCheckboxes = {
    'Vivienda': false,
    'Hospital': false,
    'Oficinas': false,
    'Iglesia': false,
    'Comercio': false,
    'Reunión (cine/estadio/salón)': false,
    'Escuela': false,
    'Industrial (fábrica/bodega)': false,
    'Desocupada': false,
    'Planicie': false,
    'Fondo de valle': false,
    'Ladera de cerro': false,
    'Depósitos lacustres': false,
    'Rivera río/lago': false,
    'Costa': false,
  };

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
              setState(() {
                isCompleted = true;
              });
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
                  'Información General',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 10),
              _buildTextField('Nombre del inmueble'),
              _buildTextField('Calle y número'),
              Row(
                children: [
                  Expanded(child: _buildTextField('Colonia')),
                  SizedBox(width: 10),
                  Expanded(child: _buildTextField('Código Postal')),
                ],
              ),
              Row(
                children: [
                  Expanded(child: _buildTextField('Pueblo o ciudad')),
                  SizedBox(width: 10),
                  Expanded(child: _buildTextField('Delegación/Municipio')),
                ],
              ),
              _buildTextField('Estado'),
              _buildTextField('Referencias', hint: '(entre calles “A” y “B”, un sitio notable, etc)'),
              Row(
                children: [
                  Expanded(child: _buildTextField('Persona contactada')),
                  SizedBox(width: 10),
                  Expanded(child: _buildTextField('Teléfono', hint: '+(  )')),
                ],
              ),
              SizedBox(height: 10),
              Text('Uso:'),
              _buildCheckboxOptions([
                'Vivienda', 'Hospital', 'Oficinas', 'Iglesia', 'Comercio', 'Reunión (cine/estadio/salón)',
                'Escuela', 'Industrial (fábrica/bodega)', 'Desocupada'
              ]),
              _buildTextField('Otro uso (Especifique)'),
              SizedBox(height: 10),
              Text('Dimensiones:'),
              _buildTextField('Frente X =', suffix: 'metros.'),
              _buildTextField('Frente Y =', suffix: 'metros.'),
              _buildTextField('No. niveles, n ='),
              _buildTextField('No. ocupantes ='),
              _buildTextField('No. sótanos ='),
              SizedBox(height: 10),
              Text('Topografía:'),
              _buildCheckboxOptions([
                'Planicie', 'Fondo de valle', 'Ladera de cerro', 'Depósitos lacustres', 'Rivera río/lago', 'Costa'
              ]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, {String hint = '', String suffix = ''}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          suffixText: suffix,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildCheckboxOptions(List<String> options) {
    return Column(
      children: options.map((option) {
        return CheckboxListTile(
          title: Text(option),
          value: selectedCheckboxes[option], // ✅ Ahora usa el mapa para almacenar el valor
          onChanged: (bool? value) {
            setState(() {
              selectedCheckboxes[option] = value ?? false;
            });
          },
        );
      }).toList(),
    );
  }
}
