import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../data/services/ciudad_colonia_service.dart';

class ReporteScreen extends StatefulWidget {
  @override
  _ReporteScreenState createState() => _ReporteScreenState();
}

class _ReporteScreenState extends State<ReporteScreen> {
  // Controladores para los campos de texto
  TextEditingController nombreInmuebleController = TextEditingController();
  TextEditingController fechaInicioController = TextEditingController(
      text: DateFormat('dd/MM/yyyy').format(DateTime.now().subtract(Duration(days: 30))));
  TextEditingController fechaFinalController = TextEditingController(
      text: DateFormat('dd/MM/yyyy').format(DateTime.now()));
  TextEditingController usuarioCreadorController = TextEditingController();
  
  // Variables para control de estado
  bool _isLoading = false;
  bool _dataLoaded = false;
  String _errorMessage = '';
  
  // Variables para el tipo de reporte
  final List<String> _tiposReporte = [
    "Resumen General",
    "Uso de vivienda y topografía",
    "Material dominante de construcción",
    "Sistema estructural",
    "Evaluación de daños",
    "Resumen completo"
  ];
  String _tipoReporteSeleccionado = "Resumen General";
  
  // Variables para ubicaciones múltiples
  List<Map<String, dynamic>> _ubicaciones = [];
  int _idxUbicacionActual = 0;
  
  // Servicio para datos de ciudades y colonias
  final CiudadColoniaService _ciudadService = CiudadColoniaService();
  
  // Variables para los dropdowns de ubicación
  List<String> _municipios = [];
  List<String> _ciudades = [];
  List<String> _colonias = [];

  @override
  void initState() {
    super.initState();
    // Inicializar ubicación actual
    _agregarNuevaUbicacion();
    // Cargar datos iniciales
    _cargarDatosIniciales();
  }

  /// Carga los datos iniciales para los dropdowns
  Future<void> _cargarDatosIniciales() async {
    try {
      setState(() {
        _isLoading = true;
      });
      
      // Cargar los municipios desde el servicio
      _municipios = await _ciudadService.getMunicipios();
      
      // Inicializar con La Paz
      String municipioDefault = 'La Paz';
      
      // Cargar ciudades del municipio por defecto
      _ciudades = await _ciudadService.getCiudadesByMunicipio(municipioDefault);
      
      // Si hay ciudades, cargar la primera ciudad
      if (_ciudades.isNotEmpty) {
        String ciudadDefault = 'La Paz';
        // Cargar colonias de la primera ciudad
        _colonias = await _ciudadService.getColoniasByCiudad(ciudadDefault);
      }
      
      // Actualizar la ubicación actual con los valores por defecto
      setState(() {
        _ubicaciones[_idxUbicacionActual]['municipio'] = 'La Paz';
        _ubicaciones[_idxUbicacionActual]['ciudad'] = 'La Paz';
        _ubicaciones[_idxUbicacionActual]['estado'] = 'Baja California Sur';
      });
      
      setState(() {
        _isLoading = false;
        _dataLoaded = true;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error al cargar datos iniciales: $e';
      });
      _mostrarError(_errorMessage);
    }
  }

  /// Agrega una nueva ubicación al listado
  void _agregarNuevaUbicacion() {
    setState(() {
      _ubicaciones.add({
        'municipio': 'La Paz', 
        'ciudad': 'La Paz', 
        'colonia': null,
        'estado': 'Baja California Sur'
      });
      _idxUbicacionActual = _ubicaciones.length - 1;
    });
  }

  /// Elimina una ubicación del listado
  void _eliminarUbicacion(int index) {
    if (_ubicaciones.length <= 1) {
      // Siempre debe haber al menos una ubicación
      return;
    }
    
    setState(() {
      _ubicaciones.removeAt(index);
      // Ajustar el índice actual si es necesario
      if (_idxUbicacionActual >= _ubicaciones.length) {
        _idxUbicacionActual = _ubicaciones.length - 1;
      }
    });
  }

  /// Muestra un mensaje de error
  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(50),
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
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
      ),
      body: _isLoading 
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        'Generar Reporte',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(height: 15),
                    
                    // Sección: Filtros de búsqueda
                    Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Filtros de búsqueda',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 10),
                            
                            // Nombre del inmueble
                            TextField(
                              controller: nombreInmuebleController,
                              decoration: InputDecoration(
                                labelText: 'Nombre del inmueble',
                                hintText: 'Dejar en blanco para todos',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.business),
                              ),
                            ),
                            
                            SizedBox(height: 15),
                            
                            // Rango de fechas
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: fechaInicioController,
                                    readOnly: true,
                                    onTap: () async {
                                      DateTime? fecha = await showDatePicker(
                                        context: context,
                                        initialDate: DateTime.now().subtract(Duration(days: 30)),
                                        firstDate: DateTime(2020),
                                        lastDate: DateTime.now(),
                                      );
                                      
                                      if (fecha != null) {
                                        setState(() {
                                          fechaInicioController.text = DateFormat('dd/MM/yyyy').format(fecha);
                                        });
                                      }
                                    },
                                    decoration: InputDecoration(
                                      labelText: 'Fecha inicio',
                                      border: OutlineInputBorder(),
                                      prefixIcon: Icon(Icons.date_range),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: TextField(
                                    controller: fechaFinalController,
                                    readOnly: true,
                                    onTap: () async {
                                      DateTime? fecha = await showDatePicker(
                                        context: context,
                                        initialDate: DateTime.now(),
                                        firstDate: DateTime(2020),
                                        lastDate: DateTime.now(),
                                      );
                                      
                                      if (fecha != null) {
                                        setState(() {
                                          fechaFinalController.text = DateFormat('dd/MM/yyyy').format(fecha);
                                        });
                                      }
                                    },
                                    decoration: InputDecoration(
                                      labelText: 'Fecha final',
                                      border: OutlineInputBorder(),
                                      prefixIcon: Icon(Icons.date_range),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            
                            SizedBox(height: 15),
                            
                            // Usuario creador
                            TextField(
                              controller: usuarioCreadorController,
                              decoration: InputDecoration(
                                labelText: 'Usuario creador',
                                hintText: 'Dejar en blanco para todos',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.person),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    SizedBox(height: 20),
                    
                    // Sección: Ubicaciones
                    Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Ubicaciones',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            
                            SizedBox(height: 10),
                            
                            // Lista de ubicaciones como chips horizontales
                            Container(
                              height: 40,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: _ubicaciones.length + 1, // +1 para el botón de agregar
                                itemBuilder: (context, index) {
                                  if (index == _ubicaciones.length) {
                                    // Botón para agregar nueva ubicación
                                    return InkWell(
                                      onTap: _agregarNuevaUbicacion,
                                      child: Container(
                                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                        margin: EdgeInsets.only(right: 8),
                                        decoration: BoxDecoration(
                                          color: Colors.green,
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Icon(Icons.add, color: Colors.white, size: 20),
                                      ),
                                    );
                                  } else {
                                    // Chip para cada ubicación
                                    return InkWell(
                                      onTap: () {
                                        setState(() {
                                          _idxUbicacionActual = index;
                                        });
                                      },
                                      child: Container(
                                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                        margin: EdgeInsets.only(right: 8),
                                        decoration: BoxDecoration(
                                          color: _idxUbicacionActual == index ? Colors.blue : Colors.grey[300],
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              'Ubicación ${index + 1}',
                                              style: TextStyle(
                                                color: _idxUbicacionActual == index ? Colors.white : Colors.black,
                                              ),
                                            ),
                                            if (_ubicaciones.length > 1) 
                                              InkWell(
                                                onTap: () => _eliminarUbicacion(index),
                                                child: Padding(
                                                  padding: EdgeInsets.only(left: 4),
                                                  child: Icon(Icons.close, size: 16, 
                                                    color: _idxUbicacionActual == index ? Colors.white : Colors.black54),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }
                                },
                              ),
                            ),
                            
                            SizedBox(height: 15),
                            
                            // Mostrar detalles de la ubicación actual
                            if (_dataLoaded)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Dropdowns para selección de ubicación
                                  DropdownButtonFormField<String>(
                                    value: _ubicaciones[_idxUbicacionActual]['municipio'],
                                    decoration: InputDecoration(
                                      labelText: 'Municipio/Delegación',
                                      border: OutlineInputBorder(),
                                      prefixIcon: Icon(Icons.location_city),
                                    ),
                                    isExpanded: true,
                                    items: _municipios.map((String municipio) {
                                      return DropdownMenuItem<String>(
                                        value: municipio,
                                        child: Text(municipio),
                                      );
                                    }).toList(),
                                    onChanged: (String? newValue) async {
                                      if (newValue != _ubicaciones[_idxUbicacionActual]['municipio']) {
                                        setState(() {
                                          _ubicaciones[_idxUbicacionActual]['municipio'] = newValue;
                                          _ubicaciones[_idxUbicacionActual]['ciudad'] = null;
                                          _ubicaciones[_idxUbicacionActual]['colonia'] = null;
                                        });
                                        
                                        // Cargar ciudades del nuevo municipio
                                        if (newValue != null) {
                                          _ciudades = await _ciudadService.getCiudadesByMunicipio(newValue);
                                          if (_ciudades.isNotEmpty) {
                                            setState(() {
                                              _ubicaciones[_idxUbicacionActual]['ciudad'] = _ciudades.first;
                                            });
                                            
                                            // Cargar colonias de la primera ciudad
                                            _colonias = await _ciudadService.getColoniasByCiudad(_ciudades.first);
                                          } else {
                                            setState(() {
                                              _colonias = [];
                                            });
                                          }
                                        }
                                      }
                                    },
                                  ),
                                  
                                  SizedBox(height: 15),
                                  
                                  DropdownButtonFormField<String>(
                                    value: _ubicaciones[_idxUbicacionActual]['ciudad'],
                                    decoration: InputDecoration(
                                      labelText: 'Ciudad/Pueblo',
                                      border: OutlineInputBorder(),
                                      prefixIcon: Icon(Icons.location_on),
                                    ),
                                    isExpanded: true,
                                    items: _ciudades.map((String ciudad) {
                                      return DropdownMenuItem<String>(
                                        value: ciudad,
                                        child: Text(ciudad),
                                      );
                                    }).toList(),
                                    onChanged: (String? newValue) async {
                                      if (newValue != _ubicaciones[_idxUbicacionActual]['ciudad']) {
                                        setState(() {
                                          _ubicaciones[_idxUbicacionActual]['ciudad'] = newValue;
                                          _ubicaciones[_idxUbicacionActual]['colonia'] = null;
                                        });
                                        
                                        // Cargar colonias de la nueva ciudad
                                        if (newValue != null) {
                                          _colonias = await _ciudadService.getColoniasByCiudad(newValue);
                                        } else {
                                          setState(() {
                                            _colonias = [];
                                          });
                                        }
                                      }
                                    },
                                  ),
                                  
                                  SizedBox(height: 15),
                                  
                                  DropdownButtonFormField<String>(
                                    value: _ubicaciones[_idxUbicacionActual]['colonia'],
                                    decoration: InputDecoration(
                                      labelText: 'Colonia (opcional)',
                                      border: OutlineInputBorder(),
                                      prefixIcon: Icon(Icons.home),
                                    ),
                                    isExpanded: true,
                                    items: [
                                      DropdownMenuItem<String>(
                                        value: null,
                                        child: Text('Todas las colonias'),
                                      ),
                                      ..._colonias.map((String colonia) {
                                        return DropdownMenuItem<String>(
                                          value: colonia,
                                          child: Text(colonia),
                                        );
                                      }).toList(),
                                    ],
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        _ubicaciones[_idxUbicacionActual]['colonia'] = newValue;
                                      });
                                    },
                                  ),
                                  
                                  SizedBox(height: 15),
                                  
                                  // Campo de texto no editable para el estado (siempre BCS)
                                  TextField(
                                    readOnly: true,
                                    decoration: InputDecoration(
                                      labelText: 'Estado',
                                      hintText: 'Baja California Sur',
                                      border: OutlineInputBorder(),
                                      prefixIcon: Icon(Icons.map),
                                      filled: true,
                                      fillColor: Colors.grey[100],
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ),
                    
                    SizedBox(height: 20),
                    
                    // Sección: Tipo de reporte
                    Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Tipo de reporte',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 10),
                            
                            DropdownButtonFormField<String>(
                              value: _tipoReporteSeleccionado,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.article),
                              ),
                              isExpanded: true,
                              items: _tiposReporte.map((String tipo) {
                                return DropdownMenuItem<String>(
                                  value: tipo,
                                  child: Text(tipo),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  _tipoReporteSeleccionado = newValue!;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    SizedBox(height: 30),
                    
                    // Botones de acción
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: Icon(Icons.search),
                            label: Text('Buscar Formatos'),
                            onPressed: () {
                              // Implementación pendiente
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Funcionalidad pendiente de implementación'),
                                  backgroundColor: Colors.blue,
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              padding: EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 15),
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: Icon(Icons.assignment),
                            label: Text('Generar Reporte'),
                            onPressed: () {
                              // Implementación pendiente
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Funcionalidad pendiente de implementación'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
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
}