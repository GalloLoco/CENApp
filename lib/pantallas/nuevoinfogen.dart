import 'package:flutter/material.dart';
import '../logica/formato_evaluacion.dart';
import '../data/services/ciudad_colonia_service.dart';

class InformacionGeneralScreen extends StatefulWidget {
  final InformacionGeneral? informacionExistente;
  
  InformacionGeneralScreen({this.informacionExistente});

  @override
  _InformacionGeneralScreenState createState() => _InformacionGeneralScreenState();
}

class _InformacionGeneralScreenState extends State<InformacionGeneralScreen> {
  // Controladores para campos de texto
  late TextEditingController nombreInmuebleController;
  late TextEditingController calleController;
  late TextEditingController cpController;
  late TextEditingController referenciasController;
  late TextEditingController personaContactoController;
  late TextEditingController telefonoController;
  late TextEditingController otroUsoController;
  late TextEditingController frenteXController;
  late TextEditingController frenteYController;
  late TextEditingController nivelesController;
  late TextEditingController ocupantesController;
  late TextEditingController sotanosController;

  // Variables para los dropdowns
  String? _municipioSeleccionado;
  String? _ciudadSeleccionada;
  String? _coloniaSeleccionada;
  
  // Listas para los dropdowns
  List<String> _municipios = [];
  List<String> _ciudades = [];
  List<String> _colonias = [];
  
  // Servicio para gestionar datos de ciudades y colonias
  final CiudadColoniaService _ciudadService = CiudadColoniaService();
  
  // Variable para controlar si se mostró el diálogo de confirmación
  bool _mostradoConfirmacion = false;
  
  // Mapa para almacenar los valores de los checkboxes
  late Map<String, bool> selectedUsos;
  late Map<String, bool> selectedTopografia;
  
  // Flag para controlar si estamos cargando datos iniciales
  bool _cargandoDatos = true;

  @override
  void initState() {
    super.initState();
    
    // Inicializar controladores con valores por defecto o existentes
    nombreInmuebleController = TextEditingController(
      text: widget.informacionExistente?.nombreInmueble ?? '');
    calleController = TextEditingController(
      text: widget.informacionExistente?.calle ?? '');
    cpController = TextEditingController(
      text: widget.informacionExistente?.codigoPostal ?? '');
    referenciasController = TextEditingController(
      text: widget.informacionExistente?.referencias ?? '');
    personaContactoController = TextEditingController(
      text: widget.informacionExistente?.personaContacto ?? '');
    telefonoController = TextEditingController(
      text: widget.informacionExistente?.telefono ?? '');
    otroUsoController = TextEditingController(
      text: widget.informacionExistente?.otroUso ?? '');
    frenteXController = TextEditingController(
      text: (widget.informacionExistente?.frenteX ?? 0).toString());
    frenteYController = TextEditingController(
      text: (widget.informacionExistente?.frenteY ?? 0).toString());
    nivelesController = TextEditingController(
      text: (widget.informacionExistente?.niveles ?? 0).toString());
    ocupantesController = TextEditingController(
      text: (widget.informacionExistente?.ocupantes ?? 0).toString());
    sotanosController = TextEditingController(
      text: (widget.informacionExistente?.sotanos ?? 0).toString());
    
    // Inicializar mapas de checkboxes con valores por defecto
    selectedUsos = {
      'Vivienda': false,
      'Hospital': false,
      'Oficinas': false,
      'Iglesia': false,
      'Comercio': false,
      'Reunión (cine/estadio/salón)': false,
      'Escuela': false,
      'Industrial (fábrica/bodega)': false,
      'Desocupada': false,
    };
    
    selectedTopografia = {
      'Planicie': false,
      'Fondo de valle': false,
      'Ladera de cerro': false,
      'Depósitos lacustres': false,
      'Rivera río/lago': false,
      'Costa': false,
    };
    
    // Cargar valores de checkboxes existentes si hay información
    if (widget.informacionExistente != null) {
      // Cargar usos
      widget.informacionExistente!.usos.forEach((key, value) {
        if (selectedUsos.containsKey(key)) {
          selectedUsos[key] = value;
        }
      });
      
      // Cargar topografía
      widget.informacionExistente!.topografia.forEach((key, value) {
        if (selectedTopografia.containsKey(key)) {
          selectedTopografia[key] = value;
        }
      });
    }
    
    // Cargar datos de ciudades y municipios
    _cargarDatos();
  }
  
  /// Carga los datos de municipios, ciudades y colonias
  Future<void> _cargarDatos() async {
    // Cargar lista de municipios
    _municipios = await _ciudadService.getMunicipios();
    
    // Valores por defecto o existentes
    if (widget.informacionExistente != null) {
      // Si hay datos existentes, cargar municipio, ciudad y colonia
      _municipioSeleccionado = widget.informacionExistente!.delegacionMunicipio;
      _ciudadSeleccionada = widget.informacionExistente!.ciudadPueblo;
      _coloniaSeleccionada = widget.informacionExistente!.colonia;
      
      // Cargar ciudades del municipio seleccionado
      if (_municipioSeleccionado != null && _municipioSeleccionado!.isNotEmpty) {
        _ciudades = await _ciudadService.getCiudadesByMunicipio(_municipioSeleccionado!);
      }
      
      // Cargar colonias de la ciudad seleccionada
      if (_ciudadSeleccionada != null && _ciudadSeleccionada!.isNotEmpty) {
        _colonias = await _ciudadService.getColoniasByCiudad(_ciudadSeleccionada!);
      }
    } else {
      // Por defecto, seleccionar La Paz
      _municipioSeleccionado = 'La Paz';
      _ciudadSeleccionada = 'La Paz';
      
      // Cargar ciudades del municipio de La Paz
      _ciudades = await _ciudadService.getCiudadesByMunicipio('La Paz');
      
      // Cargar colonias de La Paz
      _colonias = await _ciudadService.getColoniasByCiudad('La Paz');
    }
    
    // Actualizar estado cuando finalice la carga
    if (mounted) {
      setState(() {
        _cargandoDatos = false;
      });
    }
  }
  
  @override
  void dispose() {
    // Liberar recursos
    nombreInmuebleController.dispose();
    calleController.dispose();
    cpController.dispose();
    referenciasController.dispose();
    personaContactoController.dispose();
    telefonoController.dispose();
    otroUsoController.dispose();
    frenteXController.dispose();
    frenteYController.dispose();
    nivelesController.dispose();
    ocupantesController.dispose();
    sotanosController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (!_mostradoConfirmacion) {
          _mostradoConfirmacion = true;
          _confirmarSalida(context);
          return false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => _confirmarSalida(context),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.check, color: Colors.black),
              onPressed: _guardarInformacion,
            ),
          ],
        ),
        body: _cargandoDatos 
          ? _buildLoadingScreen()
          : SingleChildScrollView(
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
                    _buildTextField('Nombre del inmueble', nombreInmuebleController),
                    _buildTextField('Calle y número', calleController),
                    
                    // Sección de ubicación con dropdowns
                    _buildDropdownField('Municipio', _municipios, _municipioSeleccionado, (String? value) {
                      if (value != _municipioSeleccionado) {
                        setState(() {
                          _municipioSeleccionado = value;
                          _ciudadSeleccionada = null;
                          _coloniaSeleccionada = null;
                          _ciudades = [];
                          _colonias = [];
                        });
                        
                        // Actualizar ciudades cuando cambie el municipio
                        if (value != null) {
                          _ciudadService.getCiudadesByMunicipio(value).then((ciudades) {
                            setState(() {
                              _ciudades = ciudades;
                              if (ciudades.isNotEmpty) {
                                _ciudadSeleccionada = ciudades.first;
                                
                                // Cargar colonias de la primera ciudad
                                _ciudadService.getColoniasByCiudad(ciudades.first).then((colonias) {
                                  setState(() {
                                    _colonias = colonias;
                                    _coloniaSeleccionada = null; // Inicialmente ninguna colonia seleccionada
                                  });
                                });
                              }
                            });
                          });
                        }
                      }
                    }),
                    
                    _buildDropdownField('Ciudad/Pueblo', _ciudades, _ciudadSeleccionada, (String? value) {
                      if (value != _ciudadSeleccionada) {
                        setState(() {
                          _ciudadSeleccionada = value;
                          _coloniaSeleccionada = null;
                          _colonias = [];
                        });
                        
                        // Actualizar colonias cuando cambie la ciudad
                        if (value != null) {
                          _ciudadService.getColoniasByCiudad(value).then((colonias) {
                            setState(() {
                              _colonias = colonias;
                            });
                          });
                        }
                      }
                    }),
                    
                    _buildDropdownField('Colonia', _colonias, _coloniaSeleccionada, (String? value) {
                      setState(() {
                        _coloniaSeleccionada = value;
                      });
                    }),
                    
                    _buildTextField('Código Postal', cpController, keyboardType: TextInputType.number),
                    _buildTextField('Referencias', referenciasController, hint: '(entre calles "A" y "B", un sitio notable, etc)'),
                    
                    Row(
                      children: [
                        Expanded(child: _buildTextField('Persona contactada', personaContactoController)),
                        SizedBox(width: 10),
                        Expanded(child: _buildTextField('Teléfono', telefonoController, hint: '+(  )')),
                      ],
                    ),
                    
                    SizedBox(height: 10),
                    Text('Uso:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    _buildCheckboxOptions(selectedUsos),
                    _buildTextField('Otro uso (Especifique)', otroUsoController),
                    
                    SizedBox(height: 10),
                    Text('Dimensiones:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    _buildTextField('Frente X =', frenteXController, suffix: 'metros.', keyboardType: TextInputType.number),
                    _buildTextField('Frente Y =', frenteYController, suffix: 'metros.', keyboardType: TextInputType.number),
                    _buildTextField('No. niveles, n =', nivelesController, keyboardType: TextInputType.number),
                    _buildTextField('No. ocupantes =', ocupantesController, keyboardType: TextInputType.number),
                    _buildTextField('No. sótanos =', sotanosController, keyboardType: TextInputType.number),
                    
                    SizedBox(height: 10),
                    Text('Topografía:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    _buildCheckboxOptions(selectedTopografia),
                    
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
      ),
    );
  }

  /// Widget para mostrar pantalla de carga
  Widget _buildLoadingScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 20),
          Text('Cargando datos...'),
        ],
      ),
    );
  }

  Widget _buildTextField(
    String label, 
    TextEditingController controller, 
    {String hint = '', 
    String suffix = '', 
    TextInputType keyboardType = TextInputType.text}
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          suffixText: suffix,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildDropdownField(
    String label,
    List<String> options,
    String? selectedValue,
    ValueChanged<String?> onChanged
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        value: selectedValue,
        isExpanded: true,
        icon: Icon(Icons.arrow_drop_down),
        elevation: 16,
        style: TextStyle(color: Colors.black),
        onChanged: onChanged,
        items: options.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCheckboxOptions(Map<String, bool> options) {
    return Column(
      children: options.entries.map((entry) {
        return CheckboxListTile(
          title: Text(entry.key),
          value: entry.value,
          onChanged: (bool? value) {
            setState(() {
              options[entry.key] = value ?? false;
            });
          },
          dense: true, // Para que sean más compactos
          contentPadding: EdgeInsets.zero, // Eliminar padding horizontal
        );
      }).toList(),
    );
  }

  /// Confirma si el usuario desea salir sin guardar
  void _confirmarSalida(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('¿Salir sin guardar?'),
          content: Text('Los cambios no guardados se perderán.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Cierra el diálogo
                Navigator.pop(context); // Regresa a la pantalla anterior
              },
              child: Text('Salir sin guardar'),
            ),
          ],
        );
      },
    );
  }

  /// Guarda la información y regresa a la pantalla anterior
  void _guardarInformacion() {
    // Validar campos obligatorios
    if (nombreInmuebleController.text.isEmpty) {
      _mostrarAlerta('El nombre del inmueble es obligatorio');
      return;
    }
    
    if (_municipioSeleccionado == null) {
      _mostrarAlerta('Por favor seleccione un municipio');
      return;
    }
    
    if (_ciudadSeleccionada == null) {
      _mostrarAlerta('Por favor seleccione una ciudad o pueblo');
      return;
    }

    try {
      // Crear objeto de información general
      final informacionGeneral = InformacionGeneral(
        nombreInmueble: nombreInmuebleController.text,
        calle: calleController.text,
        colonia: _coloniaSeleccionada ?? '',
        codigoPostal: cpController.text,
        ciudadPueblo: _ciudadSeleccionada ?? '',
        delegacionMunicipio: _municipioSeleccionado ?? '',
        estado: 'Baja California Sur', // Valor fijo para este proyecto
        referencias: referenciasController.text,
        personaContacto: personaContactoController.text,
        telefono: telefonoController.text,
        usos: Map<String, bool>.from(selectedUsos),
        otroUso: otroUsoController.text,
        frenteX: double.tryParse(frenteXController.text) ?? 0.0,
        frenteY: double.tryParse(frenteYController.text) ?? 0.0,
        niveles: int.tryParse(nivelesController.text) ?? 0,
        ocupantes: int.tryParse(ocupantesController.text) ?? 0,
        sotanos: int.tryParse(sotanosController.text) ?? 0,
        topografia: Map<String, bool>.from(selectedTopografia),
      );

      // Regresar con los datos
      Navigator.pop(context, {'completado': true, 'datos': informacionGeneral});
    } catch (e) {
      _mostrarAlerta('Error al guardar: $e');
    }
  }

  void _mostrarAlerta(String mensaje) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(mensaje),
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
}