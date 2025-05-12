import 'package:flutter/material.dart';
import '../logica/formato_evaluacion.dart';
import 'DocumentoGuardado.dart';
import 'nuevaubicacion.dart';
import 'nuevoinfogen.dart';
import 'nuevosisest.dart';
import 'nuevaevaluacion.dart';
import '../data/services/user_service.dart';

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

  // Modo de edición vs. creación
  bool esModoEdicion = false;

  // Clave global para el Scaffold (para mostrar SnackBars)
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();

    // Si hay un formato existente, cargar sus datos
    if (widget.formatoExistente != null) {
      _cargarFormatoExistente(widget.formatoExistente!);
      esModoEdicion = true;

      // Notificar al usuario que está editando un formato existente
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Editando formato existente: ${widget.formatoExistente!.id}'),
            backgroundColor: Colors.blue,
            duration: Duration(seconds: 2),
          ),
        );
      });
    }
  }

  /// Carga los datos de un formato existente de manera optimizada
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

  // Método para validar y continuar
  Future<void> _validarYContinuar() async {
    if (!_validarDatosFormato()) {
      return; // Si la validación falla, no continuar
    }

    try {
      // Mostrar indicador de carga
      _mostrarCargando(context, 'Preparando formato...');

      // Obtener datos del usuario actual
      final userService = UserService();
      String nombreCompleto = await userService.getUserFullName();
      String gradoUsuario = await userService.getUserGrado();

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
            nombreCompleto, // Usar el nombre completo del usuario actual
        gradoUsuario: gradoUsuario, // Incluir el grado del usuario
      );

      // Breve retraso para mostrar el indicador
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
  }

  /// Valida que todos los datos del formato estén correctos
  bool _validarDatosFormato() {
    // Verificar que todos los apartados estén completados
    if (!informacionGeneralCompletado ||
        !sistemaEstructuralCompletado ||
        !evaluacionDanosCompletado ||
        !ubicacionGeorreferencialCompletado) {
      // Preparar mensaje detallado
      String mensaje = 'Faltan completar los siguientes apartados:';
      if (!informacionGeneralCompletado) mensaje += '\n- Información general';
      if (!sistemaEstructuralCompletado) mensaje += '\n- Sistema estructural';
      if (!evaluacionDanosCompletado) mensaje += '\n- Evaluación de daños';
      if (!ubicacionGeorreferencialCompletado)
        mensaje += '\n- Ubicación georreferencial';

      _mostrarAlerta('Faltan apartados', mensaje);
      return false;
    }

    // Verificaciones adicionales por sección
    // Información general
    if (informacionGeneral?.nombreInmueble.isEmpty ?? true) {
      _mostrarAlerta(
          'Información General', 'El nombre del inmueble es obligatorio');
      return false;
    }

    // Verificar que haya al menos una foto en ubicación
    if (ubicacionGeorreferencial?.rutasFotos.isEmpty ?? true) {
      _mostrarAlerta('Ubicación Georreferencial',
          'Se requiere al menos una fotografía del inmueble');
      return false;
    }

    return true;
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.blue,
              ),
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
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

  // Función para mostrar un mensaje de confirmación antes de regresar
  void _mostrarConfirmacionRegreso(BuildContext context) {
    // Verificar si hay cambios no guardados
    bool tieneModificaciones = false;

    // Si estamos en modo edición y alguna sección ha sido completada, podría haber cambios
    if (esModoEdicion) {
      if (informacionGeneralCompletado ||
          sistemaEstructuralCompletado ||
          evaluacionDanosCompletado ||
          ubicacionGeorreferencialCompletado) {
        tieneModificaciones = true;
      }
    } else {
      // Si no estamos en modo edición, cualquier sección completada representa cambios
      if (informacionGeneralCompletado ||
          sistemaEstructuralCompletado ||
          evaluacionDanosCompletado ||
          ubicacionGeorreferencialCompletado) {
        tieneModificaciones = true;
      }
    }

    // Si hay modificaciones, mostrar diálogo de confirmación
    if (tieneModificaciones) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('¿Descartar cambios?'),
            content: Text(
                'Hay cambios no guardados. Si regresas, se perderán todos los cambios.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancelar'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.blue,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Cerrar el diálogo
                  Navigator.pop(context); // Regresar a la pantalla anterior
                },
                child: Text('Descartar'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red,
                ),
              ),
            ],
          );
        },
      );
    } else {
      // Si no hay cambios, simplemente regresar
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => _mostrarConfirmacionRegreso(context),
        ),
        title: Text(
          esModoEdicion ? 'Editar Formato' : 'Nuevo Formato',
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.checklist, color: Colors.black),
            onPressed: _validarYContinuar,
            tooltip: 'Guardar y continuar',
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
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 15),
            Text(
              esModoEdicion
                  ? 'Revise y modifique los apartados según sea necesario'
                  : 'Rellene correctamente cada apartado',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
            if (esModoEdicion) ...[
              SizedBox(height: 8),
              Text(
                'ID: $formatoId',
                style: TextStyle(
                    fontSize: 14,
                    color: Colors.blue[700],
                    fontWeight: FontWeight.w500),
              ),
              Text(
                'Creado: ${_formatearFecha(fechaCreacion ?? DateTime.now())}',
                style: TextStyle(fontSize: 14, color: Colors.blue[700]),
              ),
            ],
            SizedBox(height: 40),
            _buildButton(
              context,
              'Información general del inmueble',
              informacionGeneralCompletado,
              () async {
                // Navegar a la pantalla de información general
                final resultado = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => InformacionGeneralScreen(
                      informacionExistente: informacionGeneral,
                    ),
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
            SizedBox(height: 20),
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
            SizedBox(height: 20),
            _buildButton(
              context,
              'Evaluación de daños',
              evaluacionDanosCompletado,
              () async {
                final resultado = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EvaluacionDanosScreen(
                      evaluacionExistente: evaluacionDanos,
                    ),
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
            SizedBox(height: 20),
            _buildButton(
              context,
              'Ubicación georreferencial',
              ubicacionGeorreferencialCompletado,
              () async {
                final resultado = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UbicacionGeorreferencialScreen(
                      ubicacionExistente: ubicacionGeorreferencial,
                    ),
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
                        altitud: datos['altitud'] ??
                            0.0, // Asegurar que incluimos la altitud
                        rutasFotos: List<String>.from(datos['rutasFotos']),
                        imagenesBase64: datos['imagenesBase64'] != null
                            ? Map<String, String>.from(datos['imagenesBase64'])
                            : null,
                      );
                    });
                  }
                }
              },
            ),

            // Información sobre modo edición/creación
            Spacer(),
            if (esModoEdicion)
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Estás editando un formato existente. Completa todos los apartados y presiona el botón de verificación para guardar los cambios.',
                        style: TextStyle(color: Colors.blue[700], fontSize: 12),
                      ),
                    ),
                  ],
                ),
              )
            else
              SizedBox(height: 20), // Espaciador para modo creación
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
          elevation: 3,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 16,
                  color: completado ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (completado)
              Icon(Icons.check_circle, color: Colors.white)
            else
              Icon(Icons.arrow_forward_ios, color: Colors.black54, size: 18),
          ],
        ),
      ),
    );
  }

  // Formatea una fecha para mostrarla en formato DD/MM/YYYY
  String _formatearFecha(DateTime fecha) {
    return '${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year}';
  }
}
