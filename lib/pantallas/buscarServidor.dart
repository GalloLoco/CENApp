// lib/pantallas/buscarServidor.dart (versión mejorada)
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cenapp/data/services/cloud_storage_service.dart';
import 'package:cenapp/pantallas/NuevoFormato.dart';
import '../logica/formato_evaluacion.dart';
import '../data/services/ciudad_colonia_service.dart';

class BuscarServidorScreen extends StatefulWidget {
  const BuscarServidorScreen({super.key});

  @override
  _BuscarServidorScreenState createState() => _BuscarServidorScreenState();
}

class _BuscarServidorScreenState extends State<BuscarServidorScreen> {
  // Instancia del servicio de almacenamiento en la nube
  final CloudStorageService _cloudService = CloudStorageService();

  // Controladores para los campos de búsqueda básicos
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _nombreInmuebleController =
      TextEditingController();
  final TextEditingController _fechaCreacionController =
      TextEditingController();
  final TextEditingController _fechaModificacionController =
      TextEditingController();
  final TextEditingController _usuarioCreadorController =
      TextEditingController();

  // Controladores para los campos de ubicación
  final TextEditingController _calleNumeroController = TextEditingController();
  final TextEditingController _codigoPostalController = TextEditingController();

  String? _municipioSeleccionado = 'La Paz';
  String? _ciudadSeleccionada = 'La Paz';
  String? _coloniaSeleccionada;
  String _estadoSeleccionado = 'Baja California Sur';
  List<String> _municipios = [];
  List<String> _ciudades = [];
  List<String> _colonias = [];
  final CiudadColoniaService _ciudadService = CiudadColoniaService();
  bool _cargandoDatos = true;

  // Variables para fechas
  DateTime? _fechaCreacion;
  DateTime? _fechaModificacion;

  // Variable para controlar el estado de carga
  bool _isLoading = false;

  // Lista para almacenar los resultados de la búsqueda
  List<Map<String, dynamic>> _resultados = [];

  // Variable para controlar si se muestran los campos de ubicación extendidos
  bool _mostrarCamposUbicacionExtendidos = false;

  @override
  void dispose() {
    // Liberar recursos de controladores básicos
    _idController.dispose();
    _nombreInmuebleController.dispose();
    _fechaCreacionController.dispose();
    _fechaModificacionController.dispose();
    _usuarioCreadorController.dispose();

    // Liberar recursos de controladores de ubicación
    _calleNumeroController.dispose();
    _codigoPostalController.dispose();

    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  // Función para seleccionar fecha
  Future<void> _seleccionarFecha(BuildContext context, bool esCreacion) async {
    final DateTime? fechaSeleccionada = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.lightBlue,
            ),
          ),
          child: child!,
        );
      },
    );

    if (fechaSeleccionada != null) {
      setState(() {
        if (esCreacion) {
          // Para búsqueda, usamos el inicio del día (00:00:00)
          _fechaCreacion = DateTime(
            fechaSeleccionada.year,
            fechaSeleccionada.month,
            fechaSeleccionada.day,
          );
          _fechaCreacionController.text =
              DateFormat('dd/MM/yyyy').format(fechaSeleccionada);
        } else {
          // Para búsqueda, usamos el inicio del día (00:00:00)
          _fechaModificacion = DateTime(
            fechaSeleccionada.year,
            fechaSeleccionada.month,
            fechaSeleccionada.day,
          );
          _fechaModificacionController.text =
              DateFormat('dd/MM/yyyy').format(fechaSeleccionada);
        }
      });
    }
  }

  // Función para limpiar una fecha
  void _limpiarFecha(bool esCreacion) {
    setState(() {
      if (esCreacion) {
        _fechaCreacion = null;
        _fechaCreacionController.text = '';
      } else {
        _fechaModificacion = null;
        _fechaModificacionController.text = '';
      }
    });
  }

  // Función para realizar la búsqueda
  Future<void> _buscar() async {
    /*// Validar que al menos un campo tenga valor
    bool hayAlgunCampoLleno = _idController.text.isNotEmpty ||
        _nombreInmuebleController.text.isNotEmpty ||
        _fechaCreacion != null ||
        _fechaModificacion != null ||
        _coloniaSeleccionada != null && _coloniaSeleccionada!.isNotEmpty ||
        _calleNumeroController.text.isNotEmpty ||
        _codigoPostalController.text.isNotEmpty ||
        _ciudadSeleccionada == 'La Paz' ||
        _municipioSeleccionado == 'La Paz' ||
        _usuarioCreadorController.text.isNotEmpty;

    if (!hayAlgunCampoLleno) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Por favor, ingresa al menos un criterio de búsqueda'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }*/

    setState(() {
      _isLoading = true;
    });

    try {
      // Preparar fechas para la búsqueda
      DateTime? fechaCreacionHasta;
      DateTime? fechaModificacionHasta;

      // Si se seleccionó una fecha de creación, crear el rango de ese día completo
      if (_fechaCreacion != null) {
        // Fecha hasta = final del día seleccionado (23:59:59)
        fechaCreacionHasta = DateTime(
          _fechaCreacion!.year,
          _fechaCreacion!.month,
          _fechaCreacion!.day,
          23,
          59,
          59,
          999,
        );
      }

      // Si se seleccionó una fecha de modificación, crear el rango de ese día completo
      if (_fechaModificacion != null) {
        // Fecha hasta = final del día seleccionado (23:59:59)
        fechaModificacionHasta = DateTime(
          _fechaModificacion!.year,
          _fechaModificacion!.month,
          _fechaModificacion!.day,
          23,
          59,
          59,
          999,
        );
      }

      // Realizar la búsqueda utilizando el servicio con fechas ajustadas
      List<Map<String, dynamic>> resultados =
          await _cloudService.buscarFormatos(
        id: _idController.text,
        nombreInmueble: _nombreInmuebleController.text.toUpperCase(),
        fechaCreacionDesde: _fechaCreacion,
        fechaCreacionHasta: fechaCreacionHasta,
        fechaModificacionDesde: _fechaModificacion,
        fechaModificacionHasta: fechaModificacionHasta,
        ubicacionColonia:
            _coloniaSeleccionada?.isEmpty ?? true ? null : _coloniaSeleccionada,
        ubicacionCalle: _calleNumeroController.text,
        ubicacionCodigoPostal: _codigoPostalController.text,
        ubicacionCiudad: _ciudadSeleccionada,
        ubicacionMunicipio: _municipioSeleccionado,
        ubicacionEstado: _estadoSeleccionado,
        usuarioCreador: _usuarioCreadorController.text,
      );

      setState(() {
        _resultados = resultados;
        _isLoading = false;
      });

      // Mostrar mensaje según los resultados
      if (_resultados.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'No se encontraron resultados con los criterios especificados'),
            backgroundColor: Colors.blue,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Se encontraron ${_resultados.length} resultado(s)'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      // Detectar error específico de índice faltante
      String errorMsg = e.toString();
      if (errorMsg.contains('requires an index') ||
          errorMsg.contains('no index defined')) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Se requiere crear un índice en Firebase para esta consulta. Por favor, contacta al administrador.'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 6),
          ),
        );
      } else {
        // Mostrar error genérico
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al realizar la búsqueda: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Función para limpiar todos los filtros
  void _limpiarFiltros() {
    setState(() {
      _idController.clear();
      _nombreInmuebleController.clear();
      _fechaCreacion = null;
      _fechaCreacionController.clear();
      _fechaModificacion = null;
      _fechaModificacionController.clear();
      _coloniaSeleccionada = 'Arcos del Sol';
      _calleNumeroController.clear();
      _codigoPostalController.clear();
      _municipioSeleccionado = 'La Paz';
    _ciudadSeleccionada = 'La Paz';
    _estadoSeleccionado = 'Baja California Sur';
      _usuarioCreadorController.clear();
      _resultados = [];
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Todos los filtros han sido limpiados'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  // Función para abrir un formato
  Future<void> _abrirFormato(String documentId) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Mostrar diálogo de carga
      _mostrarDialogoCarga(context, 'Cargando formato...');

      // Obtener el formato completo
      FormatoEvaluacion? formato =
          await _cloudService.obtenerFormatoPorId(documentId);

      // Cerrar diálogo de carga
      Navigator.of(context, rootNavigator: true).pop();

      if (formato != null) {
        setState(() {
          _isLoading = false;
        });

        // Navegar a la pantalla de edición
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NuevoFormatoScreen(formatoExistente: formato),
          ),
        );
      } else {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No se pudo cargar el formato seleccionado'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Cerrar diálogo de carga si está abierto
      Navigator.of(context, rootNavigator: true).pop();

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al abrir el formato: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Método para mostrar diálogo de carga
  void _mostrarDialogoCarga(BuildContext context, String mensaje) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 15),
              Text(mensaje),
              SizedBox(height: 10),
              Text(
                'Por favor espere, esto puede tardar unos momentos...',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
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
                        'Buscar Formato',
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(height: 20),

                    // Sección de búsqueda
                    _buildSearchSection(),

                    SizedBox(height: 20),

                    // Botones de acción
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _buscar,
                            icon: Icon(Icons.search),
                            label: Text('Buscar'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF80C0ED),
                              padding: EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        ElevatedButton.icon(
                          onPressed: _limpiarFiltros,
                          icon: Icon(Icons.clear_all),
                          label: Text('Limpiar'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey,
                            padding: EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 20),

                    // Tabla de resultados
                    _resultados.isNotEmpty
                        ? _buildResultsTable()
                        : Center(
                            child: Column(
                              children: [
                                Icon(Icons.search,
                                    size: 50, color: Colors.grey[400]),
                                SizedBox(height: 10),
                                Text(
                                  'Ingresa criterios de búsqueda y presiona "Buscar"',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontStyle: FontStyle.italic,
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

  // Construye la sección de búsqueda
  Widget _buildSearchSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ID y nombre del inmueble
        _buildSectionTitle('Búsqueda por ID o nombre del inmueble'),
        SizedBox(height: 5),

        // Campo ID más grande
        TextField(
          controller: _idController,
          decoration: InputDecoration(
            labelText: 'ID',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.tag),
          ),
        ),

        SizedBox(height: 10),

        // Campo de nombre de inmueble
        TextField(
          controller: _nombreInmuebleController,
          decoration: InputDecoration(
            labelText: 'Nombre del inmueble',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.business),
          ),
        ),

        SizedBox(height: 20),

        // Fechas
        _buildSectionTitle('Fechas'),

        // Fecha de creación con botón para limpiar
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _fechaCreacionController,
                readOnly: true,
                onTap: () => _seleccionarFecha(context, true),
                decoration: InputDecoration(
                  labelText: 'Fecha de creación',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_today),
                  hintText: 'Seleccionar fecha',
                ),
              ),
            ),
            if (_fechaCreacionController.text.isNotEmpty)
              IconButton(
                icon: Icon(Icons.clear, color: Colors.red),
                onPressed: () => _limpiarFecha(true),
                tooltip: 'Limpiar fecha',
              ),
          ],
        ),

        SizedBox(height: 10),

        // Fecha de modificación con botón para limpiar
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _fechaModificacionController,
                readOnly: true,
                onTap: () => _seleccionarFecha(context, false),
                decoration: InputDecoration(
                  labelText: 'Fecha de modificación',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_today),
                  hintText: 'Seleccionar fecha',
                ),
              ),
            ),
            if (_fechaModificacionController.text.isNotEmpty)
              IconButton(
                icon: Icon(Icons.clear, color: Colors.red),
                onPressed: () => _limpiarFecha(false),
                tooltip: 'Limpiar fecha',
              ),
          ],
        ),

        SizedBox(height: 20),

        // Ubicación geográfica
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionTitle('Ubicación geográfica'),
            TextButton.icon(
              icon: Icon(
                _mostrarCamposUbicacionExtendidos
                    ? Icons.arrow_drop_up
                    : Icons.arrow_drop_down,
              ),
              label: Text(_mostrarCamposUbicacionExtendidos
                  ? 'Mostrar menos'
                  : 'Mostrar más'),
              onPressed: () {
                setState(() {
                  _mostrarCamposUbicacionExtendidos =
                      !_mostrarCamposUbicacionExtendidos;
                });
              },
            ),
          ],
        ),

// Campos básicos de ubicación
        _cargandoDatos
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            : Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _calleNumeroController,
                          decoration: InputDecoration(
                            labelText: 'Calle y número',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.location_on),
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _coloniaSeleccionada,
                          isExpanded: true,
                          decoration: InputDecoration(
                            labelText: 'Colonia',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.home),
                          ),
                          items: [
                            DropdownMenuItem<String>(
                              value: null,
                              child: Text('Todas'),
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
                              _coloniaSeleccionada = newValue;
                            });
                          },
                        ),
                      ),
                    ],
                  ),

                  // Campos extendidos de ubicación
                  if (_mostrarCamposUbicacionExtendidos) ...[
                    SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: _ciudadSeleccionada,
                      isExpanded: true,
                      decoration: InputDecoration(
                        labelText: 'Ciudad/Pueblo',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.location_city),
                      ),
                      items: _ciudades.map((String ciudad) {
                        return DropdownMenuItem<String>(
                          value: ciudad,
                          child: Text(ciudad),
                        );
                      }).toList(),
                      onChanged: (String? value) {
                        if (value != _ciudadSeleccionada) {
                          setState(() {
                            _ciudadSeleccionada = value;
                            _coloniaSeleccionada = null;
                            _colonias = [];
                          });

                          // Actualizar colonias cuando cambie la ciudad
                          if (value != null) {
                            _ciudadService
                                .getColoniasByCiudad(value)
                                .then((colonias) {
                              setState(() {
                                _colonias = colonias;
                              });
                            });
                          }
                        }
                      },
                    ),
                    SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: _municipioSeleccionado,
                      isExpanded: true,
                      decoration: InputDecoration(
                        labelText: 'Delegación/Municipio',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.apartment),
                      ),
                      items: _municipios.map((String municipio) {
                        return DropdownMenuItem<String>(
                          value: municipio,
                          child: Text(municipio),
                        );
                      }).toList(),
                      onChanged: (String? value) {
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
                            _ciudadService
                                .getCiudadesByMunicipio(value)
                                .then((ciudades) {
                              setState(() {
                                _ciudades = ciudades;
                                if (ciudades.isNotEmpty) {
                                  _ciudadSeleccionada = ciudades.first;

                                  // Cargar colonias de la primera ciudad
                                  _ciudadService
                                      .getColoniasByCiudad(ciudades.first)
                                      .then((colonias) {
                                    setState(() {
                                      _colonias = colonias;
                                      _coloniaSeleccionada = null;
                                    });
                                  });
                                }
                              });
                            });
                          }
                        }
                      },
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: _codigoPostalController,
                      decoration: InputDecoration(
                        labelText: 'Código Postal',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.markunread_mailbox),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 10),
                    TextField(
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'Estado',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.map),
                        hintText: _estadoSeleccionado,
                        filled: true,
                        fillColor: Colors.grey[100],
                      ),
                    ),
                  ],
                ],
              ),

        SizedBox(height: 20),

        // Búsqueda por usuario creador
        _buildSectionTitle('Búsqueda por usuario creador'),
        TextField(
          controller: _usuarioCreadorController,
          decoration: InputDecoration(
            labelText: 'Usuario creador',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.person),
          ),
        ),
      ],
    );
  }

  // Construye título de sección
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.blueGrey[800],
        ),
      ),
    );
  }

  // Construye la tabla de resultados
  Widget _buildResultsTable() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Resultados (${_resultados.length})'),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(5),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columnSpacing: 20,
              headingRowColor: MaterialStateProperty.all(Colors.grey[200]),
              columns: [
                DataColumn(label: Text('ID')),
                DataColumn(label: Text('Nombre del inmueble')),
                DataColumn(label: Text('Fecha Creación')),
                DataColumn(label: Text('Fecha Modificación')),
                DataColumn(label: Text('Ubicación')),
                DataColumn(label: Text('Usuario Creador')),
                DataColumn(label: Text('Acción')),
              ],
              rows: _resultados.map((resultado) {
                // Formato de fechas
                String fechaCreacion = _formatDate(resultado['fechaCreacion']);
                String fechaModificacion =
                    _formatDate(resultado['fechaModificacion']);

                return DataRow(cells: [
                  DataCell(Text(resultado['id'])),
                  DataCell(
                    Container(
                      constraints: BoxConstraints(maxWidth: 200),
                      child: Text(
                        resultado['nombreInmueble'],
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  DataCell(Text(fechaCreacion)),
                  DataCell(Text(fechaModificacion)),
                  DataCell(
                    Container(
                      constraints: BoxConstraints(maxWidth: 150),
                      child: Text(
                        resultado['ubicacion'],
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  DataCell(Text(resultado['usuarioCreador'])),
                  DataCell(
                    ElevatedButton.icon(
                      icon: Icon(Icons.edit, size: 16),
                      label: Text('Abrir'),
                      onPressed: () => _abrirFormato(resultado['documentId']),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      ),
                    ),
                  ),
                ]);
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  /// Carga los datos de municipios, ciudades y colonias
  Future<void> _cargarDatos() async {
    try {
      setState(() {
        _cargandoDatos = true;
      });

      // Cargar lista de municipios
      _municipios = await _ciudadService.getMunicipios();

      // Establecer valores por defecto
      _municipioSeleccionado = 'La Paz';
      _ciudadSeleccionada = 'La Paz';
      _estadoSeleccionado = 'Baja California Sur';

      // Cargar ciudades del municipio seleccionado
      _ciudades = await _ciudadService.getCiudadesByMunicipio('La Paz');

      // Cargar colonias de La Paz
      _colonias = await _ciudadService.getColoniasByCiudad('La Paz');

      // Actualizar estado cuando finalice la carga
      setState(() {
        _cargandoDatos = false;
      });
    } catch (e) {
      print('Error al cargar datos: $e');
      setState(() {
        _cargandoDatos = false;
        _municipios = ['La Paz'];
        _ciudades = ['La Paz'];
        _colonias = [];
      });
    }
  }

  // Formatea una fecha para mostrar en la tabla
  String _formatDate(dynamic date) {
    if (date == null) return 'N/A';

    if (date is Timestamp) {
      DateTime dateTime = date.toDate();
      return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
    } else if (date is DateTime) {
      return DateFormat('dd/MM/yyyy HH:mm').format(date);
    } else if (date is String) {
      try {
        // Intentar parsear la fecha en formato ISO 8601
        DateTime dateTime = DateTime.parse(date);
        return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
      } catch (e) {
        // Si no se puede parsear, devolver la cadena original
        return date;
      }
    }

    return 'N/A';
  }
}
