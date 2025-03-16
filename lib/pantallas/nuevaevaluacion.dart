import 'package:flutter/material.dart';

class EvaluacionDanosScreen extends StatefulWidget {
  @override
  _EvaluacionDanosScreenState createState() => _EvaluacionDanosScreenState();
}

class _EvaluacionDanosScreenState extends State<EvaluacionDanosScreen> {
  Map<String, bool> selectedCheckboxes = {};
  Map<String, TextEditingController> textControllers = {};
  TextEditingController columnasDanioSeveroController = TextEditingController();
  TextEditingController totalColumnasEntrepisosController =
      TextEditingController();
  TextEditingController inclinacionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Inicializar los controladores para los campos de texto
    List<String> rows = [
      'Columnas',
      'Trabes',
      'Muro (Mampost.)',
      'Muro (concreto)'
    ];
    List<String> measurementTypes = [
      'Ancho máximo de grieta (mm)',
      'Separación de estribos (cm)',
      'Longitud de traslape (cm)',
      'Sección/Espesor de muro (cm)'
    ];

    for (var row in rows) {
      for (var type in measurementTypes) {
        textControllers['${row}_${type}'] = TextEditingController();
      }
    }
    
    // Inicializar los checkboxes con valores predeterminados
    List<String> allCheckboxOptions = [
      'Grietas en el terreno', 'Hundimientos', 'Falla',
      'Colapso total', 'Daño severo', 'Daño medio', 'Daño ligero',
      'Vidrios', 'Acabados', 'Plafones', 'Fachadas', 'Bardas y pretiles',
      'Cubos (escalera/elevador)', 'Instalaciones'
    ];
    
    for (var option in allCheckboxOptions) {
      selectedCheckboxes[option] = false;
    }
  }

  @override
  void dispose() {
    // Limpiar controladores
    textControllers.forEach((_, controller) => controller.dispose());
    columnasDanioSeveroController.dispose();
    totalColumnasEntrepisosController.dispose();
    inclinacionController.dispose();
    super.dispose();
  }

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
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                'Evaluación de Daños',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCheckboxSection('Geotécnicos',
                        ['Grietas en el terreno', 'Hundimientos']),
                    _buildTextField(
                        'Inclinación del edificio', inclinacionController, '%'),
                    _buildCheckboxSection('Conexiones', ['Falla']),
                    SizedBox(height: 20),
                    // Tabla combinada con scroll horizontal
                    Container(
                      width: MediaQuery.of(context).size.width - 40,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: _buildCombinedTable(),
                      ),
                    ),
                    SizedBox(height: 20),
                    _buildEntrepisoCritico(),
                    SizedBox(height: 20),
                    _buildCheckboxSection('Nivel de daño de la estructura', [
                      'Colapso total',
                      'Daño severo',
                      'Daño medio',
                      'Daño ligero'
                    ]),
                    _buildCheckboxSection('Otros daños', [
                      'Vidrios',
                      'Acabados',
                      'Plafones',
                      'Fachadas',
                      'Bardas y pretiles',
                      'Cubos (escalera/elevador)',
                      'Instalaciones'
                    ]),
                  ],
                ),
              ),
            ),
          ],
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
            value: selectedCheckboxes[option] ?? false, // Usar ?? false en lugar de solo acceder al valor
            onChanged: (bool? value) {
              setState(() {
                selectedCheckboxes[option] = value ?? false;
              });
            },
            dense: true, // Hace que los checkboxes sean más compactos
            contentPadding: EdgeInsets.symmetric(horizontal: 0), // Elimina el padding extra
          );
        }).toList(),
      ],
    );
  }

  Widget _buildCombinedTable() {
    List<String> damageTypes = [
      'Colapso',
      'Grietas cortante',
      'Grietas Flexión',
      'Aplastamiento',
      'Pandeo barras',
      'Pandeo placas',
      'Falla Soldadura'
    ];
    List<String> measurementTypes = [
      'Ancho máximo de grieta (mm)',
      'Separación de estribos (cm)',
      'Longitud de traslape (cm)',
      'Sección/Espesor de muro (cm)'
    ];
    List<String> rows = [
      'Columnas',
      'Trabes',
      'Muro (Mampost.)',
      'Muro (concreto)'
    ];

    // Calcular el ancho total para la tabla
    final estructuraWidth = 180.0;
    final damageWidth = 110.0;
    final measurementWidth = 140.0;

    final totalWidth = estructuraWidth +
        (damageWidth * damageTypes.length) +
        (measurementWidth * measurementTypes.length);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Encabezados principales
        Container(
          width: totalWidth,
          child: Row(
            children: [
              // Celda de Estructura
              Container(
                width: estructuraWidth,
                height: 50,
                decoration: BoxDecoration(
                  border: Border.all(),
                  color: Colors.grey[200],
                ),
                child: Center(
                  child: Text(
                    'Estructura',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              // Celda combinada para Tipos de daños
              Container(
                width: damageWidth * damageTypes.length,
                height: 50,
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(),
                    right: BorderSide(),
                    bottom: BorderSide(),
                  ),
                  color: Colors.grey[200],
                ),
                child: Center(
                  child: Text(
                    'Tipos de daños',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              // Celda combinada para Mediciones
              Container(
                width: measurementWidth * measurementTypes.length,
                height: 50,
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(),
                    right: BorderSide(),
                    bottom: BorderSide(),
                  ),
                  color: Colors.grey[200],
                ),
                child: Center(
                  child: Text(
                    'Mediciones',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Subencabezados
        Container(
          width: totalWidth,
          child: Row(
            children: [
              // Celda vacía para alinear con Estructura
              Container(
                width: estructuraWidth,
                height: 50,
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(),
                    right: BorderSide(),
                    bottom: BorderSide(),
                  ),
                  color: Colors.grey[100],
                ),
                child: Center(child: Text('')),
              ),
              // Subencabezados para cada tipo de daño
              ...damageTypes.map((header) => Container(
                    width: damageWidth,
                    height: 50,
                    decoration: BoxDecoration(
                      border: Border(
                        right: BorderSide(),
                        bottom: BorderSide(),
                      ),
                      color: Colors.grey[100],
                    ),
                    child: Center(
                      child: Text(
                        header,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                  )),
              // Subencabezados para cada tipo de medición
              ...measurementTypes.map((header) => Container(
                    width: measurementWidth,
                    height: 50,
                    decoration: BoxDecoration(
                      border: Border(
                        right: BorderSide(),
                        bottom: BorderSide(),
                      ),
                      color: Colors.grey[100],
                    ),
                    child: Center(
                      child: Text(
                        header,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                  )),
            ],
          ),
        ),

        // Filas de datos
        ...rows.map((row) => Container(
              width: totalWidth,
              child: Row(
                children: [
                  // Nombre de la estructura
                  Container(
                    width: estructuraWidth,
                    height: 50,
                    decoration: BoxDecoration(
                      border: Border(
                        left: BorderSide(),
                        right: BorderSide(),
                        bottom: BorderSide(),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        row,
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                  // Checkboxes para tipos de daños
                  ...List.generate(damageTypes.length, (index) {
                    String key = '${row}_${damageTypes[index]}';
                    return Container(
                      width: damageWidth,
                      height: 50,
                      decoration: BoxDecoration(
                        border: Border(
                          right: BorderSide(),
                          bottom: BorderSide(),
                        ),
                      ),
                      child: Center(
                        child: Checkbox(
                          value: selectedCheckboxes[key] ?? false, // Usar ?? false
                          onChanged: (val) {
                            setState(() {
                              selectedCheckboxes[key] = val ?? false;
                            });
                          },
                        ),
                      ),
                    );
                  }),
                  // Campos de texto para mediciones
                  ...List.generate(measurementTypes.length, (index) {
                    String key = '${row}_${measurementTypes[index]}';
                    return Container(
                      width: measurementWidth,
                      height: 50,
                      decoration: BoxDecoration(
                        border: Border(
                          right: BorderSide(),
                          bottom: BorderSide(),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: TextField(
                          controller: textControllers[key],
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 8, horizontal: 8),
                            border: OutlineInputBorder(),
                            filled: true,
                            fillColor: Colors.lightBlue[50],
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            )),
      ],
    );
  }

  Widget _buildEntrepisoCritico() {
    return Container(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Entrepiso crítico (más débil y/o más dañado):',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          _buildTextField('No. de columnas (o muros) daño severo',
              columnasDanioSeveroController, ''),
          Text(
            '(colapso, aplastamiento, pandeo, grietas > 3 mm)',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          SizedBox(height: 10),
          _buildTextField('Total de columnas (muros) en el entrepiso',
              totalColumnasEntrepisosController, ''),
        ],
      ),
    );
  }

  Widget _buildTextField(
      String label, TextEditingController controller, String suffix) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          suffixText: suffix,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }
}