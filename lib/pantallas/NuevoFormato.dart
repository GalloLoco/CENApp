import 'package:flutter/material.dart';
import '../logica/formato_evaluacion.dart';
import 'DocumentoGuardado.dart';
import 'nuevaubicacion.dart';
import 'nuevoinfogen.dart';
import 'nuevosisest.dart';
import 'nuevaevaluacion.dart';

class NuevoFormatoScreen extends StatefulWidget {
  final FormatoEvaluacion? formatoExistente;

  const NuevoFormatoScreen({Key? key, this.formatoExistente}) : super(key: key);

  @override
  _NuevoFormatoScreenState createState() => _NuevoFormatoScreenState();
}

class _NuevoFormatoScreenState extends State<NuevoFormatoScreen> {
  // Variables para seguimiento de completado
  bool informacionGeneralCompletado = false;
  bool sistemaEstructuralCompletado = false;
  bool evaluacionDanosCompletado = false;
  bool ubicacionGeorreferencialCompletado = false;

  // Datos recopilados de cada sección
  InformacionGeneral? informacionGeneral;
  SistemaEstructural? sistemaEstructural;
  EvaluacionDanos? evaluacionDanos;
  UbicacionGeorreferencial? ubicacionGeorreferencial;

  // ID para mantener referencia al formato original si se está editando
  String? formatoId;
  DateTime? fechaCreacion;
  String? usuarioCreador;

  @override
  void initState() {
    super.initState();

    // Si hay un formato existente, cargar sus datos
    if (widget.formatoExistente != null) {
      _cargarFormatoExistente(widget.formatoExistente!);
    }
  }

  /// Carga los datos de un formato existente
  void _cargarFormatoExistente(FormatoEvaluacion formato) {
    setState(() {
      // Cargar los datos de cada sección
      informacionGeneral = formato.informacionGeneral;
      sistemaEstructural = formato.sistemaEstructural;
      evaluacionDanos = formato.evaluacionDanos;
      ubicacionGeorreferencial = formato.ubicacionGeorreferencial;

      // Marcar todas las secciones como completadas
      informacionGeneralCompletado = true;
      sistemaEstructuralCompletado = true;
      evaluacionDanosCompletado = true;
      ubicacionGeorreferencialCompletado = true;

      // Guardar referencia al ID original y otros metadatos
      formatoId = formato.id;
      fechaCreacion = formato.fechaCreacion;
      usuarioCreador = formato.usuarioCreador;
    });
  }

  // Método para validar y continuar (modificado)
  Future<void> _validarYContinuar() async {
    if (informacionGeneralCompletado &&
        sistemaEstructuralCompletado &&
        evaluacionDanosCompletado &&
        ubicacionGeorreferencialCompletado) {
      try {
        // Crear el formato de evaluación completo
        final formato = FormatoEvaluacion(
          informacionGeneral: informacionGeneral!,
          sistemaEstructural: sistemaEstructural!,
          evaluacionDanos: evaluacionDanos!,
          ubicacionGeorreferencial: ubicacionGeorreferencial!,
          id: formatoId ??
              _generarId(), // Usar el ID original si existe, o generar uno nuevo
          fechaCreacion: fechaCreacion ??
              DateTime.now(), // Mantener fecha de creación original
          fechaModificacion: DateTime.now(), // Actualizar fecha de modificación
          usuarioCreador:
              usuarioCreador ?? "Joel", // Mantener usuario creador original
        );

        // Mostrar indicador de carga
        _mostrarCargando(context, 'Preparando formato...');

        // Simular un breve proceso
        await Future.delayed(const Duration(milliseconds: 500));

        // Cerrar el indicador de carga
        Navigator.pop(context);

        // Navegar a la pantalla de documento guardado
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DocumentoGuardadoScreen(formato: formato),
          ),
        );
      } catch (e) {
        // Cerrar indicador de carga si está activo
        Navigator.of(context, rootNavigator: true).pop();

        // Mostrar error
        _mostrarError('Error al generar formato: $e');
      }
    } else {
      // Mostrar mensaje detallado de las secciones que faltan
      String mensaje = 'Faltan completar los siguientes apartados:';
      if (!informacionGeneralCompletado) mensaje += '\n- Información general';
      if (!sistemaEstructuralCompletado) mensaje += '\n- Sistema estructural';
      if (!evaluacionDanosCompletado) mensaje += '\n- Evaluación de daños';
      if (!ubicacionGeorreferencialCompletado)
        mensaje += '\n- Ubicación georreferencial';

      _mostrarAlerta('Faltan apartados', mensaje);
    }
  }

  // Genera un ID único para el formato
  String _generarId() {
    final ahora = DateTime.now();
    return '${ahora.year}${ahora.month.toString().padLeft(2, '0')}${ahora.day.toString().padLeft(2, '0')}${ahora.hour.toString().padLeft(2, '0')}${ahora.minute.toString().padLeft(2, '0')}${ahora.second.toString().padLeft(2, '0')}';
  }

  // Muestra un diálogo de alerta genérico
  void _mostrarAlerta(String titulo, String mensaje) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(titulo),
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

  // Muestra un diálogo de error
  void _mostrarError(String mensaje) {
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

  // Muestra un indicador de carga
  void _mostrarCargando(BuildContext context, String mensaje) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 20),
                Text(mensaje),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.checklist, color: Colors.black),
            onPressed: _validarYContinuar,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 10),
            Text(
              'Categorias:',
              style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 15),
            Text(
              'Rellene correctamente cada apartado',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, color: Colors.black54),
            ),
            SizedBox(height: 100),
            _buildButton(
              context,
              'Información general del inmueble',
              informacionGeneralCompletado,
              () async {
                // Navegar a la pantalla de información general
                final resultado = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => InformacionGeneralScreen(),
                  ),
                );

                // Procesar el resultado cuando vuelve
                if (resultado != null && resultado is Map<String, dynamic>) {
                  if (resultado['completado'] == true) {
                    setState(() {
                      informacionGeneralCompletado = true;
                      informacionGeneral =
                          resultado['datos'] as InformacionGeneral;
                    });
                  }
                }
              },
            ),
            SizedBox(height: 40),
            _buildButton(
              context,
              'Sistema Estructural',
              sistemaEstructuralCompletado,
              () async {
                final resultado = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SistemaEstructuralScreen(),
                  ),
                );

                // Verificar que el resultado sea un mapa con la estructura correcta
                if (resultado != null && resultado is Map<String, dynamic>) {
                  if (resultado['completado'] == true &&
                      resultado['datos'] != null) {
                    setState(() {
                      sistemaEstructuralCompletado = true;
                      sistemaEstructural =
                          resultado['datos'] as SistemaEstructural;
                    });
                  }
                }
              },
            ),
            SizedBox(height: 40),
            _buildButton(
              context,
              'Evaluación de daños',
              evaluacionDanosCompletado,
              () async {
                final resultado = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EvaluacionDanosScreen(),
                  ),
                );

                // Verificar que el resultado sea un mapa con la estructura correcta
                if (resultado != null && resultado is Map<String, dynamic>) {
                  if (resultado['completado'] == true &&
                      resultado['datos'] != null) {
                    setState(() {
                      evaluacionDanosCompletado = true;
                      evaluacionDanos = resultado['datos'] as EvaluacionDanos;
                    });
                  }
                }
              },
            ),
            SizedBox(height: 40),
            _buildButton(
              context,
              'Ubicación georreferencial',
              ubicacionGeorreferencialCompletado,
              () async {
                final resultado = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UbicacionGeorreferencialScreen(),
                  ),
                );

                // Procesar el resultado correctamente
                if (resultado != null && resultado is Map<String, dynamic>) {
                  if (resultado['completado'] == true) {
                    setState(() {
                      ubicacionGeorreferencialCompletado = true;

                      // Crear objeto UbicacionGeorreferencial a partir de los datos
                      final datos = resultado['datos'];
                      ubicacionGeorreferencial = UbicacionGeorreferencial(
                        existenPlanos: datos['existenPlanos'],
                        direccion: datos['direccion'],
                        latitud: datos['latitud'],
                        longitud: datos['longitud'],
                        rutasFotos: List<String>.from(datos['rutasFotos']),
                      );
                    });
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(BuildContext context, String text, bool completado,
      VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: completado ? Colors.green : Color(0xFF80C0ED),
          padding: EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (completado) Icon(Icons.check_circle, color: Colors.white)
          ],
        ),
      ),
    );
  }
}
