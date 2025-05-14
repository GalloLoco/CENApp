import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../logica/formato_evaluacion.dart';

class CloudStorageService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Colección donde se almacenarán los formatos
  final String _formatosCollection = 'formatos_evaluacion';

  // Buscar formatos con filtros múltiples
 Future<List<Map<String, dynamic>>> buscarFormatos({
  String? id,
  String? nombreInmueble,
  DateTime? fechaCreacionDesde,
  DateTime? fechaCreacionHasta,
  DateTime? fechaModificacionDesde,
  DateTime? fechaModificacionHasta,
  String? ubicacionColonia,
  String? ubicacionCalle,
  String? ubicacionCodigoPostal,
  String? ubicacionCiudad,
  String? ubicacionMunicipio,
  String? ubicacionEstado,
  String? usuarioCreador,
}) async {
  try {
    // Crear una query base
    Query query = _firestore.collection(_formatosCollection);

    // Aplicar filtros según los parámetros proporcionados
    if (id != null && id.isNotEmpty) {
      query = query.where('id', isEqualTo: id);
    }

    if (nombreInmueble != null && nombreInmueble.isNotEmpty) {
      // Búsqueda por aproximación (contiene)
      query = query.where('informacionGeneral.nombreInmueble', 
          isGreaterThanOrEqualTo: nombreInmueble)
          .where('informacionGeneral.nombreInmueble', 
          isLessThanOrEqualTo: nombreInmueble + '\uf8ff');
    }

    if (fechaCreacionDesde != null) {
      query = query.where('fechaCreacion', isGreaterThanOrEqualTo: fechaCreacionDesde);
    }

    if (usuarioCreador != null && usuarioCreador.isNotEmpty) {
      query = query.where('usuarioCreador', isEqualTo: usuarioCreador);
    }

    // Limitar resultados para evitar sobrecarga
    query = query.limit(50);

    // Ejecutar la consulta
    QuerySnapshot snapshot = await query.get();

    // Procesar resultados
    List<Map<String, dynamic>> resultados = [];
    
    for (var doc in snapshot.docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      
      // Filtro adicional para ubicación si es necesario
      bool cumpleFiltrosUbicacion = true;
      
      // Filtro de colonia
      if (ubicacionColonia != null && ubicacionColonia.isNotEmpty) {
        try {
          String colonia = data['informacionGeneral']['colonia'] ?? '';
          if (!colonia.toLowerCase().contains(ubicacionColonia.toLowerCase())) {
            cumpleFiltrosUbicacion = false;
          }
        } catch (e) {
          cumpleFiltrosUbicacion = false;
        }
      }
      
      // Filtro de calle
      if (ubicacionCalle != null && ubicacionCalle.isNotEmpty) {
        try {
          String calle = data['informacionGeneral']['calle'] ?? '';
          if (!calle.toLowerCase().contains(ubicacionCalle.toLowerCase())) {
            cumpleFiltrosUbicacion = false;
          }
        } catch (e) {
          cumpleFiltrosUbicacion = false;
        }
      }
      
      // Filtro de código postal
      if (ubicacionCodigoPostal != null && ubicacionCodigoPostal.isNotEmpty) {
        try {
          String cp = data['informacionGeneral']['codigoPostal'] ?? '';
          if (!cp.toLowerCase().contains(ubicacionCodigoPostal.toLowerCase())) {
            cumpleFiltrosUbicacion = false;
          }
        } catch (e) {
          cumpleFiltrosUbicacion = false;
        }
      }
      
      // Filtro de ciudad/pueblo
      if (ubicacionCiudad != null && ubicacionCiudad.isNotEmpty) {
        try {
          String ciudad = data['informacionGeneral']['ciudadPueblo'] ?? '';
          if (!ciudad.toLowerCase().contains(ubicacionCiudad.toLowerCase())) {
            cumpleFiltrosUbicacion = false;
          }
        } catch (e) {
          cumpleFiltrosUbicacion = false;
        }
      }
      
      // Filtro de delegación/municipio
      if (ubicacionMunicipio != null && ubicacionMunicipio.isNotEmpty) {
        try {
          String municipio = data['informacionGeneral']['delegacionMunicipio'] ?? '';
          if (!municipio.toLowerCase().contains(ubicacionMunicipio.toLowerCase())) {
            cumpleFiltrosUbicacion = false;
          }
        } catch (e) {
          cumpleFiltrosUbicacion = false;
        }
      }
      
      // Filtro de estado
      if (ubicacionEstado != null && ubicacionEstado.isNotEmpty) {
        try {
          String estado = data['informacionGeneral']['estado'] ?? '';
          if (!estado.toLowerCase().contains(ubicacionEstado.toLowerCase())) {
            cumpleFiltrosUbicacion = false;
          }
        } catch (e) {
          cumpleFiltrosUbicacion = false;
        }
      }
      
      // Filtros de fecha modificación
      bool cumpleFiltrosFecha = true;
      if (fechaCreacionHasta != null) {
        try {
          if (data['fechaCreacion'] is Timestamp) {
            DateTime dateTime = (data['fechaCreacion'] as Timestamp).toDate();
            if (dateTime.isAfter(fechaCreacionHasta)) {
              cumpleFiltrosFecha = false;
            }
          }
        } catch (e) {
          // Si hay error, asumir que cumple el filtro
        }
      }
      
      if (fechaModificacionDesde != null) {
  try {
    if (data['fechaModificacion'] is Timestamp) {
      DateTime dateTime = (data['fechaModificacion'] as Timestamp).toDate();
      if (dateTime.isBefore(fechaModificacionDesde)) {
        cumpleFiltrosFecha = false;
      }
    }
  } catch (e) {
    // Si hay error, asumir que cumple el filtro
  }
}

if (fechaModificacionHasta != null) {
  try {
    if (data['fechaModificacion'] is Timestamp) {
      DateTime dateTime = (data['fechaModificacion'] as Timestamp).toDate();
      if (dateTime.isAfter(fechaModificacionHasta)) {
        cumpleFiltrosFecha = false;
      }
    }
  } catch (e) {
    // Si hay error, asumir que cumple el filtro
  }
}

// Si cumple con todos los filtros adicionales, agregar a resultados
if (cumpleFiltrosUbicacion && cumpleFiltrosFecha) {
  // Extraer los datos para mostrar en la tabla
  String id = data['id'] ?? '';
  String nombreInmueble = data['informacionGeneral']['nombreInmueble'] ?? '';
  dynamic fechaCreacion = data['fechaCreacion'];
  dynamic fechaModificacion = data['fechaModificacion'];
  
  // Construir una representación de la ubicación
  String ubicacion = '';
  try {
    String colonia = data['informacionGeneral']['colonia'] ?? '';
    String calle = data['informacionGeneral']['calle'] ?? '';
    String cp = data['informacionGeneral']['codigoPostal'] ?? '';
    String ciudad = data['informacionGeneral']['ciudadPueblo'] ?? '';
    
    if (colonia.isNotEmpty) {
      ubicacion = colonia;
      if (calle.isNotEmpty) {
        ubicacion += ', ' + calle;
      }
      if (cp.isNotEmpty) {
        ubicacion += ', C.P. ' + cp;
      }
      if (ciudad.isNotEmpty) {
        ubicacion += ', ' + ciudad;
      }
    } else if (calle.isNotEmpty) {
      ubicacion = calle;
      if (cp.isNotEmpty) {
        ubicacion += ', C.P. ' + cp;
      }
      if (ciudad.isNotEmpty) {
        ubicacion += ', ' + ciudad;
      }
    } else if (ciudad.isNotEmpty) {
      ubicacion = ciudad;
    }
  } catch (e) {
    ubicacion = 'No disponible';
  }
  
  // Obtener el usuario creador
  String usuarioCreador = data['usuarioCreador'] ?? 'No disponible';
  
  // Agregar a la lista de resultados
  resultados.add({
    'documentId': doc.id,
    'id': id,
    'nombreInmueble': nombreInmueble,
    'fechaCreacion': fechaCreacion,
    'fechaModificacion': fechaModificacion,
    'ubicacion': ubicacion,
    'usuarioCreador': usuarioCreador,
  });
}
    }
    
    // Ordenar resultados por fecha de modificación (descendente)
    resultados.sort((a, b) {
      var fechaA = a['fechaModificacion'];
      var fechaB = b['fechaModificacion'];
      
      if (fechaA == null && fechaB == null) return 0;
      if (fechaA == null) return 1;
      if (fechaB == null) return -1;
      
      if (fechaA is Timestamp && fechaB is Timestamp) {
        return fechaB.toDate().compareTo(fechaA.toDate());
      }
      
      return 0;
    });
    
    return resultados;
  } catch (e) {
    print('Error en buscarFormatos: $e');
    throw e;
  }
}

  // Obtener formato completo por ID de documento
  Future<FormatoEvaluacion?> obtenerFormatoPorId(String documentId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection(_formatosCollection)
          .doc(documentId)
          .get();
      
      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return FormatoEvaluacion.fromJson(data);
      }
      
      return null;
    } catch (e) {
      print('Error al obtener formato: $e');
      return null;
    }
  }

  // Subir un formato a Firestore
  Future<String> subirFormato(FormatoEvaluacion formato) async {
  try {
    // Verificar si el usuario está autenticado
    User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw Exception('Debes iniciar sesión para guardar en el servidor');
    }
    
    // Convertir el formato a JSON
    Map<String, dynamic> formatoJson = formato.toJson();
    
    // Añadir metadatos adicionales
    formatoJson['fechaSubida'] = FieldValue.serverTimestamp();
    formatoJson['subidoPor'] = currentUser.uid;
    formatoJson['emailUsuario'] = currentUser.email;
    
    // Primero verificar si ya existe un documento con el mismo ID
    QuerySnapshot existingDocs = await _firestore
        .collection(_formatosCollection)
        .where('id', isEqualTo: formato.id)
        .get();
    
    String documentId;
    
    if (existingDocs.docs.isNotEmpty) {
      // Si ya existe, actualizarlo
      documentId = existingDocs.docs.first.id;
      
      print('Documento encontrado con ID: $documentId. Actualizando...');
      
      await _firestore
          .collection(_formatosCollection)
          .doc(documentId)
          .update(formatoJson);
      
      print('Documento actualizado correctamente');
    } else {
      // Si no existe, crear uno nuevo
      print('No se encontró documento existente. Creando nuevo...');
      
      DocumentReference docRef = await _firestore
          .collection(_formatosCollection)
          .add(formatoJson);
      
      documentId = docRef.id;
      print('Nuevo documento creado con ID: $documentId');
    }
    
    return documentId;
  } catch (e) {
    print('Error al subir formato: $e');
    rethrow;
  }
}
Future<bool> verificarExistenciaFormato(String formatoId) async {
  try {
    QuerySnapshot existingDocs = await _firestore
        .collection(_formatosCollection)
        .where('id', isEqualTo: formatoId)
        .get();
    
    return existingDocs.docs.isNotEmpty;
  } catch (e) {
    print('Error al verificar existencia de formato: $e');
    return false; // En caso de error, asumimos que no existía
  }
}

}

