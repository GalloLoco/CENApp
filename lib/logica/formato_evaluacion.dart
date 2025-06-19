import 'dart:convert';

/// Modelo principal para almacenar todos los datos del formato de evaluación
class FormatoEvaluacion {
  final InformacionGeneral informacionGeneral;
  final SistemaEstructural sistemaEstructural;
  final EvaluacionDanos evaluacionDanos;
  final UbicacionGeorreferencial ubicacionGeorreferencial;
  final String id;
  final DateTime fechaCreacion;
  final DateTime fechaModificacion;
  final String usuarioCreador;
  final String? gradoUsuario; // Nuevo campo para almacenar el grado

  FormatoEvaluacion({
    required this.informacionGeneral,
    required this.sistemaEstructural,
    required this.evaluacionDanos,
    required this.ubicacionGeorreferencial,
    required this.id,
    required this.fechaCreacion,
    required this.fechaModificacion,
    required this.usuarioCreador,
    this.gradoUsuario, // Parámetro opcional con valor por defecto
  });

  // Actualizar el método toJson para incluir el nuevo campo
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fechaCreacion': fechaCreacion.toIso8601String(),
      'fechaModificacion': fechaModificacion.toIso8601String(),
      'usuarioCreador': usuarioCreador,
      'gradoUsuario': gradoUsuario, // Incluir el grado en el JSON
      'informacionGeneral': informacionGeneral.toJson(),
      'sistemaEstructural': sistemaEstructural.toJson(),
      'evaluacionDanos': evaluacionDanos.toJson(),
      'ubicacionGeorreferencial': ubicacionGeorreferencial.toJson(),
    };
  }

  /// Crea un objeto desde un mapa deserializado
  // Actualizar el método factory para incluir el nuevo campo
  factory FormatoEvaluacion.fromJson(Map<String, dynamic> json) {
    return FormatoEvaluacion(
      id: json['id'],
      fechaCreacion: DateTime.parse(json['fechaCreacion']),
      fechaModificacion: DateTime.parse(json['fechaModificacion']),
      usuarioCreador: json['usuarioCreador'],
      gradoUsuario: json['gradoUsuario'], // Cargar el grado desde el JSON
      informacionGeneral:
          InformacionGeneral.fromJson(json['informacionGeneral']),
      sistemaEstructural:
          SistemaEstructural.fromJson(json['sistemaEstructural']),
      evaluacionDanos: EvaluacionDanos.fromJson(json['evaluacionDanos']),
      ubicacionGeorreferencial:
          UbicacionGeorreferencial.fromJson(json['ubicacionGeorreferencial']),
    );
  }

  /// Serializa el objeto a una cadena JSON
  String toJsonString() {
    return jsonEncode(toJson());
  }

  /// Crea un objeto desde una cadena JSON
  factory FormatoEvaluacion.fromJsonString(String jsonString) {
    return FormatoEvaluacion.fromJson(jsonDecode(jsonString));
  }
}

/// Modelo para la información general del inmueble
class InformacionGeneral {
  final String nombreInmueble;
  final String calle;
  final String colonia;
  final String codigoPostal;
  final String ciudadPueblo;
  final String delegacionMunicipio;
  final String estado;
  final String referencias;
  final String personaContacto;
  final String telefono;
  final Map<String, bool> usos;
  final String otroUso;
  final double frenteX;
  final double frenteY;
  final int niveles;
  final int ocupantes;
  final int sotanos;
  final Map<String, bool> topografia;

  InformacionGeneral({
    required this.nombreInmueble,
    required this.calle,
    required this.colonia,
    required this.codigoPostal,
    required this.ciudadPueblo,
    required this.delegacionMunicipio,
    required this.estado,
    required this.referencias,
    required this.personaContacto,
    required this.telefono,
    required this.usos,
    required this.otroUso,
    required this.frenteX,
    required this.frenteY,
    required this.niveles,
    required this.ocupantes,
    required this.sotanos,
    required this.topografia,
  });

  Map<String, dynamic> toJson() {
    return {
      'nombreInmueble': nombreInmueble,
      'calle': calle,
      'colonia': colonia,
      'codigoPostal': codigoPostal,
      'ciudadPueblo': ciudadPueblo,
      'delegacionMunicipio': delegacionMunicipio,
      'estado': estado,
      'referencias': referencias,
      'personaContacto': personaContacto,
      'telefono': telefono,
      'usos': usos,
      'otroUso': otroUso,
      'frenteX': frenteX,
      'frenteY': frenteY,
      'niveles': niveles,
      'ocupantes': ocupantes,
      'sotanos': sotanos,
      'topografia': topografia,
    };
  }

  factory InformacionGeneral.fromJson(Map<String, dynamic> json) {
    return InformacionGeneral(
      nombreInmueble: json['nombreInmueble'],
      calle: json['calle'],
      colonia: json['colonia'],
      codigoPostal: json['codigoPostal'],
      ciudadPueblo: json['ciudadPueblo'],
      delegacionMunicipio: json['delegacionMunicipio'],
      estado: json['estado'],
      referencias: json['referencias'],
      personaContacto: json['personaContacto'],
      telefono: json['telefono'],
      usos: Map<String, bool>.from(json['usos']),
      otroUso: json['otroUso'],
      frenteX: json['frenteX'].toDouble(),
      frenteY: json['frenteY'].toDouble(),
      niveles: json['niveles'],
      ocupantes: json['ocupantes'],
      sotanos: json['sotanos'],
      topografia: Map<String, bool>.from(json['topografia']),
    );
  }
}

/// Modelo para el sistema estructural
class SistemaEstructural {
  final Map<String, bool> direccionX;
  final Map<String, bool> direccionY;
  final Map<String, bool> murosMamposteria;
  final Map<String, bool> sistemasPiso;
  final Map<String, bool> sistemasTecho;
  final String otroTecho;
  final Map<String, bool> cimentacion;
  final Map<String, bool> vulnerabilidad;
  final Map<String, bool> posicionManzana;
  final Map<String, bool> otrasCaracteristicas;
  final double separacionEdificios;

  SistemaEstructural({
    required this.direccionX,
    required this.direccionY,
    required this.murosMamposteria,
    required this.sistemasPiso,
    required this.sistemasTecho,
    required this.otroTecho,
    required this.cimentacion,
    required this.vulnerabilidad,
    required this.posicionManzana,
    required this.otrasCaracteristicas,
    required this.separacionEdificios,
  });

  Map<String, dynamic> toJson() {
    return {
      'direccionX': direccionX,
      'direccionY': direccionY,
      'murosMamposteria': murosMamposteria,
      'sistemasPiso': sistemasPiso,
      'sistemasTecho': sistemasTecho,
      'otroTecho': otroTecho,
      'cimentacion': cimentacion,
      'vulnerabilidad': vulnerabilidad,
      'posicionManzana': posicionManzana,
      'otrasCaracteristicas': otrasCaracteristicas,
      'separacionEdificios': separacionEdificios,
    };
  }

  factory SistemaEstructural.fromJson(Map<String, dynamic> json) {
    return SistemaEstructural(
      direccionX: Map<String, bool>.from(json['direccionX']),
      direccionY: Map<String, bool>.from(json['direccionY']),
      murosMamposteria: Map<String, bool>.from(json['murosMamposteria']),
      sistemasPiso: Map<String, bool>.from(json['sistemasPiso']),
      sistemasTecho: Map<String, bool>.from(json['sistemasTecho']),
      otroTecho: json['otroTecho'],
      cimentacion: Map<String, bool>.from(json['cimentacion']),
      vulnerabilidad: Map<String, bool>.from(json['vulnerabilidad']),
      posicionManzana: Map<String, bool>.from(json['posicionManzana']),
      otrasCaracteristicas:
          Map<String, bool>.from(json['otrasCaracteristicas']),
      separacionEdificios: json['separacionEdificios'].toDouble(),
    );
  }
}

/// Modelo para la evaluación de daños
class EvaluacionDanos {
  final Map<String, bool> geotecnicos;
  final double inclinacionEdificio;
  final Map<String, bool> conexionesFalla;

  // Nuevos campos para Losas
  final bool losasColapso;
  final double losasGrietasMax;
  final double losasFlechaMax;

  final Map<String, Map<String, bool>> danosEstructura;
  final Map<String, Map<String, double>> mediciones;
  final int columnasConDanoSevero;
  final int totalColumnasEntrepiso;
  final Map<String, bool> nivelDano;
  final Map<String, bool> otrosDanos;

  EvaluacionDanos({
    required this.geotecnicos,
    required this.inclinacionEdificio,
    required this.conexionesFalla,

    // Nuevos parámetros requeridos
    required this.losasColapso,
    required this.losasGrietasMax,
    required this.losasFlechaMax,
    required this.danosEstructura,
    required this.mediciones,
    required this.columnasConDanoSevero,
    required this.totalColumnasEntrepiso,
    required this.nivelDano,
    required this.otrosDanos,
  });

  Map<String, dynamic> toJson() {
    return {
      'geotecnicos': geotecnicos,
      'inclinacionEdificio': inclinacionEdificio,
      'conexionesFalla': conexionesFalla,

      // Añadir los nuevos campos al JSON
      'losasColapso': losasColapso,
      'losasGrietasMax': losasGrietasMax,
      'losasFlechaMax': losasFlechaMax,

      'danosEstructura': danosEstructura,
      'mediciones': mediciones,
      'columnasConDanoSevero': columnasConDanoSevero,
      'totalColumnasEntrepiso': totalColumnasEntrepiso,
      'nivelDano': nivelDano,
      'otrosDanos': otrosDanos,
    };
  }

  factory EvaluacionDanos.fromJson(Map<String, dynamic> json) {
    return EvaluacionDanos(
      geotecnicos: Map<String, bool>.from(json['geotecnicos']),
      inclinacionEdificio: json['inclinacionEdificio'].toDouble(),
      conexionesFalla: Map<String, bool>.from(json['conexionesFalla']),

      // Obtener los nuevos campos del JSON con valores por defecto si no existen
      losasColapso: json['losasColapso'] ?? false,
      losasGrietasMax: json['losasGrietasMax'].toDouble() ?? 0.0,
      losasFlechaMax: json['losasFlechaMax'].toDouble() ?? 0.0,

      danosEstructura: Map<String, Map<String, bool>>.from(
        json['danosEstructura']
            .map((k, v) => MapEntry(k, Map<String, bool>.from(v))),
      ),
      mediciones: (() {
        Map<String, Map<String, double>> result = {};
        (json['mediciones'] as Map<String, dynamic>).forEach((k, v) {
          Map<String, double> innerMap = {};
          (v as Map<String, dynamic>).forEach((innerK, innerV) {
            innerMap[innerK] = (innerV as num).toDouble();
          });
          result[k] = innerMap;
        });
        return result;
      })(),
      columnasConDanoSevero: json['columnasConDanoSevero'],
      totalColumnasEntrepiso: json['totalColumnasEntrepiso'],
      nivelDano: Map<String, bool>.from(json['nivelDano']),
      otrosDanos: Map<String, bool>.from(json['otrosDanos']),
    );
  }
}

/// Modelo para la ubicación georreferencial
class UbicacionGeorreferencial {
  final String? existenPlanos;
  final String direccion;
  final double latitud;
  final double longitud;
  final double altitud; // Nuevo campo para almacenar la altitud
  final List<String> rutasFotos;
  final Map<String, String>? imagenesBase64;

  UbicacionGeorreferencial({
    required this.existenPlanos,
    required this.direccion,
    required this.latitud,
    required this.longitud,
    this.altitud = 0.0, // Parámetro opcional con valor por defecto
    required this.rutasFotos,
    this.imagenesBase64,
  });

  Map<String, dynamic> toJson() {
    return {
      'existenPlanos': existenPlanos,
      'direccion': direccion,
      'latitud': latitud,
      'longitud': longitud,
      'altitud': altitud, // Incluir altitud en el JSON
      'rutasFotos': rutasFotos,
      'imagenesBase64': imagenesBase64,
    };
  }

  factory UbicacionGeorreferencial.fromJson(Map<String, dynamic> json) {
    return UbicacionGeorreferencial(
      existenPlanos: json['existenPlanos'],
      direccion: json['direccion'],
      latitud: json['latitud'],
      longitud: json['longitud'],
      altitud: json['altitud'].toDouble() ??
          0.0, // Cargar la altitud desde el JSON, con valor por defecto
      rutasFotos: List<String>.from(json['rutasFotos'] ?? []),
      imagenesBase64: json['imagenesBase64'] != null
          ? Map<String, String>.from(json['imagenesBase64'])
          : null,
    );
  }
}
