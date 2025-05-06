import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Para los formateadores de input
import '../logica/formato_evaluacion.dart';

class EvaluacionDanosScreen extends StatefulWidget {
  final EvaluacionDanos? evaluacionExistente;

  const EvaluacionDanosScreen({Key? key, this.evaluacionExistente})
      : super(key: key);

  @override
  _EvaluacionDanosScreenState createState() => _EvaluacionDanosScreenState();
}

class _EvaluacionDanosScreenState extends State<EvaluacionDanosScreen> {
  // Mapa para almacenar los valores de los checkboxes
  Map<String, bool> selectedCheckboxes = {};

  // Controladores para campos de texto existentes
  TextEditingController columnasDanioSeveroController = TextEditingController();
  TextEditingController totalColumnasEntrepisosController =
      TextEditingController();
  TextEditingController inclinacionController = TextEditingController();

  // Mapas para almacenar los datos de daños y mediciones
  Map<String, Map<String, bool>> danosEstructurales = {};
  Map<String, Map<String, TextEditingController>> medicionesControllers = {};

  // Nuevas variables para Losas
  bool losasColapso = false;
  TextEditingController losasGrietasMaxController = TextEditingController();
  TextEditingController losasFlechaMaxController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Inicializar los controladores para losas
    losasGrietasMaxController = TextEditingController();
    losasFlechaMaxController = TextEditingController();

    // Inicializar los checkboxes con valores predeterminados
    List<String> allCheckboxOptions = [
      'Grietas en el terreno',
      'Hundimientos',
      'Falla',
      'Colapso total',
      'Daño severo',
      'Daño medio',
      'Daño ligero',
      'Vidrios',
      'Acabados',
      'Plafones',
      'Fachadas',
      'Bardas y pretiles',
      'Cubos (escalera/elevador)',
      'Instalaciones'
    ];

    for (var option in allCheckboxOptions) {
      selectedCheckboxes[option] = false;
    }

    // Inicializar mapas para daños de estructura
    List<String> estructuras = [
      'Columnas',
      'Trabes',
      'Muro (Mampost.)',
      'Muro (concreto)'
    ];
    List<String> tiposDano = [
      'Colapso',
      'Grietas cortante',
      'Grietas Flexión',
      'Aplastamiento',
      'Pandeo barras',
      'Pandeo placas',
      'Falla Soldadura'
    ];

    for (var estructura in estructuras) {
      danosEstructurales[estructura] = {};
      for (var tipo in tiposDano) {
        danosEstructurales[estructura]![tipo] = false;
      }
    }

    // Inicializar controladores para mediciones
    List<String> tiposMedicion = [
      'Ancho máximo de grieta (mm)',
      'Separación de estribos (cm)',
      'Longitud de traslape (cm)',
      'Sección/Espesor de muro (cm)'
    ];

    for (var estructura in estructuras) {
      medicionesControllers[estructura] = {};
      for (var medicion in tiposMedicion) {
        medicionesControllers[estructura]![medicion] = TextEditingController();
      }
    }

    // Cargar valores existentes si hay
    if (widget.evaluacionExistente != null) {
      // Cargar valores de checkboxes
      final evalExistente = widget.evaluacionExistente!;

      // Cargar geotécnicos
      evalExistente.geotecnicos.forEach((key, value) {
        if (selectedCheckboxes.containsKey(key)) {
          selectedCheckboxes[key] = value;
        }
      });

      // Cargar valores de losas
      losasColapso = evalExistente.losasColapso;
      losasGrietasMaxController.text = evalExistente.losasGrietasMax.toString();
      losasFlechaMaxController.text = evalExistente.losasFlechaMax.toString();

      // Cargar inclinación
      inclinacionController.text = evalExistente.inclinacionEdificio.toString();

      // Cargar conexiones
      evalExistente.conexionesFalla.forEach((key, value) {
        if (selectedCheckboxes.containsKey(key)) {
          selectedCheckboxes[key] = value;
        }
      });

      // Cargar daños estructura
      evalExistente.danosEstructura.forEach((estructura, danos) {
        if (danosEstructurales.containsKey(estructura)) {
          danos.forEach((tipo, valor) {
            if (danosEstructurales[estructura]!.containsKey(tipo)) {
              danosEstructurales[estructura]![tipo] = valor;
            }
          });
        }
      });

      // Cargar mediciones
      evalExistente.mediciones.forEach((estructura, mediciones) {
        if (medicionesControllers.containsKey(estructura)) {
          mediciones.forEach((tipo, valor) {
            if (medicionesControllers[estructura]!.containsKey(tipo)) {
              medicionesControllers[estructura]![tipo]!.text = valor.toString();
            }
          });
        }
      });

      // Cargar datos de entrepiso crítico
      columnasDanioSeveroController.text =
          evalExistente.columnasConDanoSevero.toString();
      totalColumnasEntrepisosController.text =
          evalExistente.totalColumnasEntrepiso.toString();

      // Cargar nivel de daño
      evalExistente.nivelDano.forEach((key, value) {
        if (selectedCheckboxes.containsKey(key)) {
          selectedCheckboxes[key] = value;
        }
      });

      // Cargar otros daños
      evalExistente.otrosDanos.forEach((key, value) {
        if (selectedCheckboxes.containsKey(key)) {
          selectedCheckboxes[key] = value;
        }
      });
    }
  }

  @override
  void dispose() {
    // Liberar controladores existentes
    columnasDanioSeveroController.dispose();
    totalColumnasEntrepisosController.dispose();
    inclinacionController.dispose();

    // Liberar controladores de mediciones
    medicionesControllers.forEach((_, controladores) {
      controladores.forEach((_, controller) => controller.dispose());
    });

    // Liberar nuevos controladores de losas
    losasGrietasMaxController.dispose();
    losasFlechaMaxController.dispose();

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
            onPressed: _guardarYRegresar,
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
                    // Daños geotécnicos
                    _buildCheckboxSection('Geotécnicos',
                        ['Grietas en el terreno', 'Hundimientos']),

                    // Inclinación del edificio
                    _buildTextField(
                        'Inclinación del edificio', inclinacionController, '%'),

                    // Nueva sección de Losas
                    _buildLosasSection(),

                    // Conexiones
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

  /// Construye la sección específica para Losas
  Widget _buildLosasSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 20),
        Text('Losas',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        CheckboxListTile(
          title: Text('Colapso'),
          value: losasColapso,
          onChanged: (bool? value) {
            setState(() {
              losasColapso = value ?? false;
            });
          },
          dense: true,
          contentPadding: EdgeInsets.symmetric(horizontal: 0),
        ),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                'Grietas máx',
                losasGrietasMaxController,
                'mm',
                keyboardType: TextInputType.number,
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: _buildTextField(
                'Flecha máx',
                losasFlechaMaxController,
                'cm',
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Construye una sección con checkboxes
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
            value: selectedCheckboxes[option] ?? false,
            onChanged: (bool? value) {
              setState(() {
                selectedCheckboxes[option] = value ?? false;
              });
            },
            dense: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 0),
          );
        }).toList(),
      ],
    );
  }

  /// Construye un campo de texto con validación
  Widget _buildTextField(
      String label, TextEditingController controller, String suffix,
      {TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: keyboardType == TextInputType.number
            ? [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$'))]
            : null,
        decoration: InputDecoration(
          labelText: label,
          suffixText: suffix,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  /// Construye la tabla combinada
  Widget _buildCombinedTable() {
    // Código original de la tabla combinada
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
                  ...damageTypes.map((damageType) {
                    String key = '${row}_${damageType}';
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
                          value: danosEstructurales[row]?[damageType] ?? false,
                          onChanged: (val) {
                            setState(() {
                              if (danosEstructurales.containsKey(row)) {
                                danosEstructurales[row]![damageType] =
                                    val ?? false;
                              }
                            });
                          },
                        ),
                      ),
                    );
                  }),
                  // Campos de texto para mediciones
                  ...measurementTypes.map((measureType) {
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
                          controller: medicionesControllers[row]?[measureType],
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'^\d*\.?\d*$'))
                          ],
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

  /// Construye la sección del entrepiso crítico
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
              columnasDanioSeveroController, '',
              keyboardType: TextInputType.number),
          Text(
            '(colapso, aplastamiento, pandeo, grietas > 3 mm)',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          SizedBox(height: 10),
          _buildTextField('Total de columnas (muros) en el entrepiso',
              totalColumnasEntrepisosController, '',
              keyboardType: TextInputType.number),
        ],
      ),
    );
  }

  /// Método para guardar los datos y regresar
  void _guardarYRegresar() {
    // Validar datos numéricos de Losas
    double losasGrietasMaxValue = 0.0;
    double losasFlechaMaxValue = 0.0;

    try {
      if (losasGrietasMaxController.text.isNotEmpty) {
        losasGrietasMaxValue = double.parse(losasGrietasMaxController.text);
      }
      if (losasFlechaMaxController.text.isNotEmpty) {
        losasFlechaMaxValue = double.parse(losasFlechaMaxController.text);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Por favor, ingrese valores numéricos válidos para las mediciones de losas'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Recopilar datos de geotécnicos
    Map<String, bool> danosGeotecnicos = {
      'Grietas en el terreno':
          selectedCheckboxes['Grietas en el terreno'] ?? false,
      'Hundimientos': selectedCheckboxes['Hundimientos'] ?? false,
    };

    // Recopilar datos de conexiones
    Map<String, bool> conexiones = {
      'Falla': selectedCheckboxes['Falla'] ?? false,
    };

    // Recopilar datos de nivel de daño
    Map<String, bool> nivelDano = {
      'Colapso total': selectedCheckboxes['Colapso total'] ?? false,
      'Daño severo': selectedCheckboxes['Daño severo'] ?? false,
      'Daño medio': selectedCheckboxes['Daño medio'] ?? false,
      'Daño ligero': selectedCheckboxes['Daño ligero'] ?? false,
    };

    // Recopilar datos de otros daños
    Map<String, bool> otrosDanos = {
      'Vidrios': selectedCheckboxes['Vidrios'] ?? false,
      'Acabados': selectedCheckboxes['Acabados'] ?? false,
      'Plafones': selectedCheckboxes['Plafones'] ?? false,
      'Fachadas': selectedCheckboxes['Fachadas'] ?? false,
      'Bardas y pretiles': selectedCheckboxes['Bardas y pretiles'] ?? false,
      'Cubos (escalera/elevador)':
          selectedCheckboxes['Cubos (escalera/elevador)'] ?? false,
      'Instalaciones': selectedCheckboxes['Instalaciones'] ?? false,
    };

    // Recopilar mediciones
    Map<String, Map<String, double>> mediciones = {};
    medicionesControllers.forEach((estructura, controladores) {
      mediciones[estructura] = {};
      controladores.forEach((tipo, controller) {
        mediciones[estructura]![tipo] =
            double.tryParse(controller!.text) ?? 0.0;
      });
    });

    // Crear el objeto EvaluacionDanos
    final evaluacion = EvaluacionDanos(
      geotecnicos: danosGeotecnicos,
      inclinacionEdificio: double.tryParse(inclinacionController.text) ?? 0.0,
      conexionesFalla: conexiones,

      // Datos de Losas
      losasColapso: losasColapso,
      losasGrietasMax: losasGrietasMaxValue,
      losasFlechaMax: losasFlechaMaxValue,

      danosEstructura: danosEstructurales,
      mediciones: mediciones,
      columnasConDanoSevero:
          int.tryParse(columnasDanioSeveroController.text) ?? 0,
      totalColumnasEntrepiso:
          int.tryParse(totalColumnasEntrepisosController.text) ?? 0,
      nivelDano: nivelDano,
      otrosDanos: otrosDanos,
    );

    // Retornar a la pantalla anterior con los datos
    Navigator.pop(context, {'completado': true, 'datos': evaluacion});
  }
}
