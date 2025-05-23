import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../data/services/ciudad_colonia_service.dart';
import '../data/services/reporte_service.dart';
import 'package:open_file/open_file.dart';

class ReporteScreen extends StatefulWidget {
  @override
  _ReporteScreenState createState() => _ReporteScreenState();
}

class _ReporteScreenState extends State<ReporteScreen> {
  // Controladores para los campos de texto
  TextEditingController nombreInmuebleController = TextEditingController();
  TextEditingController fechaInicioController = TextEditingController(
      text: DateFormat('dd/MM/yyyy')
          .format(DateTime.now().subtract(Duration(days: 30))));
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
              colors: [
                Color(0xFF64B7F1),
                Color(0xFFA4D4F5),
                Color.fromARGB(255, 255, 255, 255)
              ],
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
                padding: const EdgeInsets.symmetric(
                    horizontal: 20.0, vertical: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        'Generar Reporte',
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
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
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
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
                                        initialDate: DateTime.now()
                                            .subtract(Duration(days: 30)),
                                        firstDate: DateTime(2020),
                                        lastDate: DateTime.now(),
                                      );

                                      if (fecha != null) {
                                        setState(() {
                                          fechaInicioController.text =
                                              DateFormat('dd/MM/yyyy')
                                                  .format(fecha);
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
                                          fechaFinalController.text =
                                              DateFormat('dd/MM/yyyy')
                                                  .format(fecha);
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
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),

                            SizedBox(height: 10),

                            // Lista de ubicaciones como chips horizontales
                            Container(
                              height: 40,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: _ubicaciones.length +
                                    1, // +1 para el botón de agregar
                                itemBuilder: (context, index) {
                                  if (index == _ubicaciones.length) {
                                    // Botón para agregar nueva ubicación
                                    return InkWell(
                                      onTap: _agregarNuevaUbicacion,
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 8),
                                        margin: EdgeInsets.only(right: 8),
                                        decoration: BoxDecoration(
                                          color: Colors.green,
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Icon(Icons.add,
                                            color: Colors.white, size: 20),
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
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 8),
                                        margin: EdgeInsets.only(right: 8),
                                        decoration: BoxDecoration(
                                          color: _idxUbicacionActual == index
                                              ? Colors.blue
                                              : Colors.grey[300],
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              'Ubicación ${index + 1}',
                                              style: TextStyle(
                                                color:
                                                    _idxUbicacionActual == index
                                                        ? Colors.white
                                                        : Colors.black,
                                              ),
                                            ),
                                            if (_ubicaciones.length > 1)
                                              InkWell(
                                                onTap: () =>
                                                    _eliminarUbicacion(index),
                                                child: Padding(
                                                  padding:
                                                      EdgeInsets.only(left: 4),
                                                  child: Icon(Icons.close,
                                                      size: 16,
                                                      color:
                                                          _idxUbicacionActual ==
                                                                  index
                                                              ? Colors.white
                                                              : Colors.black54),
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
                                    value: _ubicaciones[_idxUbicacionActual]
                                        ['municipio'],
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
                                      if (newValue !=
                                          _ubicaciones[_idxUbicacionActual]
                                              ['municipio']) {
                                        setState(() {
                                          _ubicaciones[_idxUbicacionActual]
                                              ['municipio'] = newValue;
                                          _ubicaciones[_idxUbicacionActual]
                                              ['ciudad'] = null;
                                          _ubicaciones[_idxUbicacionActual]
                                              ['colonia'] = null;
                                        });

                                        // Cargar ciudades del nuevo municipio
                                        if (newValue != null) {
                                          _ciudades = await _ciudadService
                                              .getCiudadesByMunicipio(newValue);
                                          if (_ciudades.isNotEmpty) {
                                            setState(() {
                                              _ubicaciones[_idxUbicacionActual]
                                                  ['ciudad'] = _ciudades.first;
                                            });

                                            // Cargar colonias de la primera ciudad
                                            _colonias = await _ciudadService
                                                .getColoniasByCiudad(
                                                    _ciudades.first);
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
                                    value: _ubicaciones[_idxUbicacionActual]
                                        ['ciudad'],
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
                                      if (newValue !=
                                          _ubicaciones[_idxUbicacionActual]
                                              ['ciudad']) {
                                        setState(() {
                                          _ubicaciones[_idxUbicacionActual]
                                              ['ciudad'] = newValue;
                                          _ubicaciones[_idxUbicacionActual]
                                              ['colonia'] = null;
                                        });

                                        // Cargar colonias de la nueva ciudad
                                        if (newValue != null) {
                                          _colonias = await _ciudadService
                                              .getColoniasByCiudad(newValue);
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
                                    value: _ubicaciones[_idxUbicacionActual]
                                        ['colonia'],
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
                                        _ubicaciones[_idxUbicacionActual]
                                            ['colonia'] = newValue;
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
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
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
                      // ✅ BOTÓN ÚNICO OPTIMIZADO - Reemplaza toda la sección Row anterior
                    SizedBox(
                      width: double.infinity, // Ocupa todo el ancho disponible
                      child: ElevatedButton.icon(
                        icon: Icon(
                          Icons.assignment,
                          size: 24,
                          color: Colors.white,
                        ),
                        label: Text(
                          'Generar Reporte',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        onPressed: _isLoading ? null : () {
                          _generarReporte();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[600], // Color verde más profesional
                          disabledBackgroundColor: Colors.grey[400], // Color cuando está deshabilitado
                          elevation: 3, // Sombra sutil
                          padding: EdgeInsets.symmetric(vertical: 18), // Más altura para mejor UX
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12), // Bordes más suaves
                          ),
                        ),
                      ),
                    ),

                    // ✅ INDICADOR DE CARGA OPTIMIZADO (agregar después del botón)
                    if (_isLoading) ...[
                      SizedBox(height: 20),
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.blue[200]!),
                        ),
                        child: Column(
                          children: [
                            CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[600]!),
                            ),
                            SizedBox(height: 12),
                            Text(
                              'Generando reporte...',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.blue[800],
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Esto puede tomar unos momentos',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // ✅ INFORMACIÓN ADICIONAL (opcional - mejora UX)
                    SizedBox(height: 20),
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.blue[600],
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Se generarán archivos PDF y Excel según el tipo de reporte seleccionado',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  /// Genera el reporte basado en los criterios seleccionados
  Future<void> _generarReporte() async {
    try {
      // Validar que haya al menos un filtro
      if (nombreInmuebleController.text.isEmpty &&
          usuarioCreadorController.text.isEmpty &&
          _ubicaciones.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Por favor, especifica al menos un criterio de búsqueda'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      // Mostrar indicador de carga
      setState(() {
        _isLoading = true;
      });

      // Convertir fechas de string a DateTime
      DateTime fechaInicio;
      DateTime fechaFin;

      try {
        // Formato dd/MM/yyyy
        List<String> partesFechaInicio = fechaInicioController.text.split('/');
        fechaInicio = DateTime(
          int.parse(partesFechaInicio[2]), // año
          int.parse(partesFechaInicio[1]), // mes
          int.parse(partesFechaInicio[0]), // día
        );

        List<String> partesFechaFin = fechaFinalController.text.split('/');
        fechaFin = DateTime(
          int.parse(partesFechaFin[2]), // año
          int.parse(partesFechaFin[1]), // mes
          int.parse(partesFechaFin[0]), // día
          23, 59, 59, // final del día
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Formato de fecha inválido: $e'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Crear instancia del servicio de reportes
      final reporteService = ReporteService();

      // Limpiar ubicaciones vacías (que no tienen selección de ciudad)
      List<Map<String, dynamic>> ubicacionesValidas = _ubicaciones
          .where((ubi) => ubi['ciudad'] != null && ubi['ciudad'].isNotEmpty)
          .toList();

      // Determinar qué tipo de reporte generar basado en la selección
      Map<String, String> rutasReporte;

      try {
        if (_tipoReporteSeleccionado == "Resumen General") {
          // **ACTUALIZADO**: Generar reporte de Resumen General con Excel
          try {
            print(
                '🔍 Iniciando generación de reporte Resumen General con Excel...');

            rutasReporte = await reporteService.generarReporteResumenGeneral(
              nombreInmueble: nombreInmuebleController.text,
              fechaInicio: fechaInicio,
              fechaFin: fechaFin,
              usuarioCreador: usuarioCreadorController.text,
              ubicaciones: ubicacionesValidas,
            );

            print(
                '✅ Reporte Resumen General generado exitosamente (PDF + Excel)');
          } catch (e) {
            print('❌ Error específico en reporte Resumen General: $e');
            rethrow;
          }
        } else if (_tipoReporteSeleccionado == "Uso de vivienda y topografía") {
          // Reporte existente de uso de vivienda y topografía
          rutasReporte =
              await reporteService.generarReporteUsoViviendaTopografia(
            nombreInmueble: nombreInmuebleController.text,
            fechaInicio: fechaInicio,
            fechaFin: fechaFin,
            usuarioCreador: usuarioCreadorController.text,
            ubicaciones: ubicacionesValidas,
          );
        } else if (_tipoReporteSeleccionado == "Sistema estructural") {
          // Nuevo reporte de sistema estructural
          rutasReporte = await reporteService.generarReporteSistemaEstructural(
            nombreInmueble: nombreInmuebleController.text,
            fechaInicio: fechaInicio,
            fechaFin: fechaFin,
            usuarioCreador: usuarioCreadorController.text,
            ubicaciones: ubicacionesValidas,
          );
        } else if (_tipoReporteSeleccionado ==
            "Material dominante de construcción") {
          // Nuevo reporte de material dominante
          rutasReporte = await reporteService.generarReporteMaterialDominante(
            nombreInmueble: nombreInmuebleController.text,
            fechaInicio: fechaInicio,
            fechaFin: fechaFin,
            usuarioCreador: usuarioCreadorController.text,
            ubicaciones: ubicacionesValidas,
          );
        } else if (_tipoReporteSeleccionado == "Evaluación de daños") {
          try {
            print(
                '🔍 Iniciando generación de reporte de evaluación de daños...');

            rutasReporte = await reporteService.generarReporteEvaluacionDanos(
              nombreInmueble: nombreInmuebleController.text,
              fechaInicio: fechaInicio,
              fechaFin: fechaFin,
              usuarioCreador: usuarioCreadorController.text,
              ubicaciones: ubicacionesValidas,
            );

            print('✅ Reporte de evaluación de daños generado exitosamente');
          } catch (e) {
            print('❌ Error específico en reporte de evaluación de daños: $e');
            rethrow;
          }
        } else if (_tipoReporteSeleccionado == "Resumen completo") {
          // Nuevo reporte completo unificado
          try {
            print('🔍 Iniciando generación de reporte completo unificado...');

            rutasReporte = await reporteService.generarReporteCompleto(
              nombreInmueble: nombreInmuebleController.text,
              fechaInicio: fechaInicio,
              fechaFin: fechaFin,
              usuarioCreador: usuarioCreadorController.text,
              ubicaciones: ubicacionesValidas,
            );

            print('✅ Reporte completo unificado generado exitosamente');
          } catch (e) {
            print('❌ Error específico en reporte completo: $e');
            rethrow;
          }
        } else {
          // Para otros tipos de reporte (pendientes de implementar)
          // Por ahora, mostramos un mensaje informativo
          setState(() {
            _isLoading = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'El tipo de reporte "$_tipoReporteSeleccionado" está pendiente de implementación'),
              backgroundColor: Colors.blue,
              duration: Duration(seconds: 3),
            ),
          );

          return;
        }

        setState(() {
          _isLoading = false;
        });

        // Mostrar diálogo de éxito con opciones para abrir los archivos
        _mostrarDialogoReporteGenerado(rutasReporte);
      } catch (e) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al generar reporte: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error inesperado: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Muestra un diálogo con las opciones para abrir los archivos generados
  void _mostrarDialogoReporteGenerado(Map<String, String> rutasReporte) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('Reporte Generado'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('El reporte ha sido generado exitosamente.'),
            SizedBox(height: 15),
            
            // **NUEVO**: Mostrar información sobre formatos disponibles
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info, size: 16, color: Colors.blue),
                      SizedBox(width: 8),
                      Text(
                        'Formatos disponibles:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade800,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    '• PDF: Ideal para visualización y presentaciones\n'
                    '• Excel: Perfecto para análisis y procesamiento de datos',
                    style: TextStyle(fontSize: 12, color: Colors.blue.shade700),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 20),
            Text('Archivos generados:', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 10),

            // Opción de PDF
            if (rutasReporte.containsKey('pdf'))
              _buildFileOption('PDF', rutasReporte['pdf']!,
                  Icons.picture_as_pdf, Colors.red),

            SizedBox(height: 10),

            // **NUEVO**: Opción de Excel
            if (rutasReporte.containsKey('excel'))
              _buildFileOption('Excel', rutasReporte['excel']!,
                  Icons.table_chart, Colors.green),

            SizedBox(height: 10),

            // Opción de DOCX/TXT (si existe)
            if (rutasReporte.containsKey('docx'))
              _buildFileOption('Documento de texto', rutasReporte['docx']!,
                  Icons.description, Colors.blue),
          ],
        ),
        actions: [
          // **NUEVO**: Botón para abrir carpeta de destino
          if (rutasReporte.isNotEmpty)
            TextButton.icon(
              icon: Icon(Icons.folder_open),
              label: Text('Abrir Carpeta'),
              onPressed: () {
                _abrirCarpetaDestino(rutasReporte);
              },
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cerrar'),
          ),
        ],
      );
    },
  );
}

  /// Construye una opción para abrir un archivo
  Widget _buildFileOption(String tipo, String ruta, IconData icono, Color color) {
  return InkWell(
    onTap: () {
      _abrirArchivo(ruta);
    },
    borderRadius: BorderRadius.circular(8),
    child: Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: color.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(8),
        color: color.withOpacity(0.05),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icono, color: color, size: 20),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tipo,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.lightBlueAccent,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  _obtenerNombreArchivo(ruta),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Icon(Icons.launch, color: color, size: 18),
        ],
      ),
    ),
  );
}
String _obtenerNombreArchivo(String rutaCompleta) {
  return rutaCompleta.split('/').last;
}

/// **NUEVO**: Abre la carpeta donde se guardaron los archivos
Future<void> _abrirCarpetaDestino(Map<String, String> rutasReporte) async {
  try {
    // Obtener la ruta de cualquier archivo para determinar la carpeta
    String rutaArchivo = rutasReporte.values.first;
    String carpeta = rutaArchivo.substring(0, rutaArchivo.lastIndexOf('/'));
    
    // En Android, mostrar mensaje con la ruta
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Archivos guardados en:'),
            SizedBox(height: 4),
            Text(
              carpeta,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        duration: Duration(seconds: 5),
        action: SnackBarAction(
          label: 'Copiar',
          onPressed: () {
            // Aquí podrías implementar copiar al portapapeles
          },
        ),
      ),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('No se pudo abrir la carpeta destino'),
        backgroundColor: Colors.orange,
      ),
    );
  }
}

  /// Abre un archivo usando el sistema operativo
  Future<void> _abrirArchivo(String ruta) async {
    try {
      final result = await OpenFile.open(ruta);

      if (result.type != ResultType.done) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al abrir el archivo: ${result.message}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al abrir el archivo: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
