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

  FormatoEvaluacion({
    required this.informacionGeneral,
    required this.sistemaEstructural,
    required this.evaluacionDanos,
    required this.ubicacionGeorreferencial,
    required this.id,
    required this.fechaCreacion,
    required this.fechaModificacion,
    required this.usuarioCreador,
  });

  /// Convierte el objeto a un mapa para serialización
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fechaCreacion': fechaCreacion.toIso8601String(),
      'fechaModificacion': fechaModificacion.toIso8601String(),
      'usuarioCreador': usuarioCreador,
      'informacionGeneral': informacionGeneral.toJson(),
      'sistemaEstructural': sistemaEstructural.toJson(),
      'evaluacionDanos': evaluacionDanos.toJson(),
      'ubicacionGeorreferencial': ubicacionGeorreferencial.toJson(),
    };
  }

  /// Crea un objeto desde un mapa deserializado
  factory FormatoEvaluacion.fromJson(Map<String, dynamic> json) {
    return FormatoEvaluacion(
      id: json['id'],
      fechaCreacion: DateTime.parse(json['fechaCreacion']),
      fechaModificacion: DateTime.parse(json['fechaModificacion']),
      usuarioCreador: json['usuarioCreador'],
      informacionGeneral: InformacionGeneral.fromJson(json['informacionGeneral']),
      sistemaEstructural: SistemaEstructural.fromJson(json['sistemaEstructural']),
      evaluacionDanos: EvaluacionDanos.fromJson(json['evaluacionDanos']),
      ubicacionGeorreferencial: UbicacionGeorreferencial.fromJson(json['ubicacionGeorreferencial']),
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
      frenteX: json['frenteX'],
      frenteY: json['frenteY'],
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
      otrasCaracteristicas: Map<String, bool>.from(json['otrasCaracteristicas']),
      separacionEdificios: json['separacionEdificios'],
    );
  }
}

/// Modelo para la evaluación de daños
class EvaluacionDanos {
  final Map<String, bool> geotecnicos;
  final double inclinacionEdificio;
  final Map<String, bool> conexionesFalla;
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
      inclinacionEdificio: json['inclinacionEdificio'],
      conexionesFalla: Map<String, bool>.from(json['conexionesFalla']),
      danosEstructura: Map<String, Map<String, bool>>.from(
        json['danosEstructura'].map((k, v) => MapEntry(k, Map<String, bool>.from(v))),
      ),
      mediciones: Map<String, Map<String, double>>.from(
        json['mediciones'].map((k, v) => MapEntry(k, Map<String, double>.from(v))),
      ),
      columnasConDanoSevero: json['columnasConDanoSevero'],
      totalColumnasEntrepiso: json['totalColumnasEntrepiso'],
      nivelDano: Map<String, bool>.from(json['nivelDano']),
      otrosDanos: Map<String, bool>.from(json['otrosDanos']),
    );
  }
}

/// Modelo para la ubicación georreferencial
class UbicacionGeorreferencial {
  final String? existenPlanos; // Cambiado de Map<String, bool> a String?
  final String direccion;
  final double latitud;
  final double longitud;
  final List<String> rutasFotos;

  UbicacionGeorreferencial({
    required this.existenPlanos,
    required this.direccion,
    required this.latitud,
    required this.longitud,
    required this.rutasFotos,
  });

  Map<String, dynamic> toJson() {
    return {
      'existenPlanos': existenPlanos,
      'direccion': direccion,
      'latitud': latitud,
      'longitud': longitud,
      'rutasFotos': rutasFotos,
    };
  }

  factory UbicacionGeorreferencial.fromJson(Map<String, dynamic> json) {
    return UbicacionGeorreferencial(
      existenPlanos: json['existenPlanos'],
      direccion: json['direccion'],
      latitud: json['latitud'],
      longitud: json['longitud'],
      rutasFotos: List<String>.from(json['rutasFotos']),
    );
  }
}