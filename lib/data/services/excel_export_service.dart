// lib/data/services/excel_export_service.dart

import 'dart:io';
import 'package:excel/excel.dart';
import '../../logica/formato_evaluacion.dart';
import './file_storage_service.dart';

/// Servicio para la exportación de documentos a Excel
class ExcelExportService {
  final FileStorageService _fileService = FileStorageService();
  
  /// Exporta el formato de evaluación a un archivo Excel
  Future<String> exportarFormatoExcel(FormatoEvaluacion formato) async {
    try {
      // Obtener directorio
      final directorio = await _fileService.obtenerDirectorioDocumentos();

      // Crear nombre de archivo Excel
      final nombreArchivo = 'Cenapp${formato.id}.xlsx';
      final rutaArchivo = '${directorio.path}/$nombreArchivo';

      // Crear un libro de Excel
      final excel = Excel.createExcel();

      // Crear hojas para cada sección
      final hojaInfoGeneral = excel['Info General'];
      final hojaSistemaEstructural = excel['Sistema Estructural'];
      final hojaEvaluacionDanos = excel['Evaluación Daños'];
      final hojaUbicacion = excel['Ubicación'];

      // Eliminar la hoja por defecto si existe después de crear las nuevas
      if (excel.sheets.containsKey('Sheet1')) {
        excel.delete('Sheet1');
      }

      // Llenar cada hoja con datos
      _llenarHojaInfoGeneral(hojaInfoGeneral, formato.informacionGeneral);
      _llenarHojaSistemaEstructural(hojaSistemaEstructural, formato.sistemaEstructural);
      _llenarHojaEvaluacionDanos(hojaEvaluacionDanos, formato.evaluacionDanos);
      _llenarHojaUbicacion(hojaUbicacion, formato.ubicacionGeorreferencial);

      // Guardar el archivo Excel
      final bytes = excel.encode();
      if (bytes == null) {
        throw Exception('Error al codificar el archivo Excel');
      }
      
      final archivo = File(rutaArchivo);
      await archivo.writeAsBytes(bytes);

      return rutaArchivo;
    } catch (e) {
      throw Exception('Error al exportar a Excel: $e');
    }
  }

  /// Exporta el formato de evaluación a un archivo CSV
  Future<String> exportarFormatoCSV(FormatoEvaluacion formato) async {
    try {
      // Obtener directorio
      final directorio = await _fileService.obtenerDirectorioDocumentos();

      // Crear nombre de archivo CSV
      final nombreArchivo = 'Cenapp${formato.id}.csv';
      final rutaArchivo = '${directorio.path}/$nombreArchivo';

      // Crear contenido CSV
      final StringBuffer csvContent = StringBuffer();

      // Encabezados
      csvContent.writeln('ID,Sección,Campo,Valor');

      // Información general
      _agregarSeccionCSV(csvContent, formato.id, 'Información General',
          'Nombre del inmueble', formato.informacionGeneral.nombreInmueble);
      _agregarSeccionCSV(csvContent, formato.id, 'Información General', 'Calle',
          formato.informacionGeneral.calle);
      _agregarSeccionCSV(csvContent, formato.id, 'Información General',
          'Colonia', formato.informacionGeneral.colonia);
      _agregarSeccionCSV(csvContent, formato.id, 'Información General',
          'Código Postal', formato.informacionGeneral.codigoPostal);
      
      // Resto de la información básica
      _agregarSeccionCSV(csvContent, formato.id, 'Información General',
          'Ciudad/Pueblo', formato.informacionGeneral.ciudadPueblo);
      _agregarSeccionCSV(csvContent, formato.id, 'Información General',
          'Delegación/Municipio', formato.informacionGeneral.delegacionMunicipio);
      _agregarSeccionCSV(csvContent, formato.id, 'Información General',
          'Estado', formato.informacionGeneral.estado);

      // Información de dimensiones
      _agregarSeccionCSV(csvContent, formato.id, 'Dimensiones', 'Frente X',
          formato.informacionGeneral.frenteX.toString());
      _agregarSeccionCSV(csvContent, formato.id, 'Dimensiones', 'Frente Y',
          formato.informacionGeneral.frenteY.toString());
      _agregarSeccionCSV(csvContent, formato.id, 'Dimensiones', 'Niveles',
          formato.informacionGeneral.niveles.toString());

      // Metadatos
      _agregarSeccionCSV(csvContent, formato.id, 'Metadatos', 'Fecha Creación',
          _formatearFecha(formato.fechaCreacion));
      _agregarSeccionCSV(csvContent, formato.id, 'Metadatos',
          'Fecha Modificación', _formatearFecha(formato.fechaModificacion));
      _agregarSeccionCSV(csvContent, formato.id, 'Metadatos', 'Usuario Creador',
          formato.usuarioCreador);

      // Escribir el archivo
      final archivo = File(rutaArchivo);
      await archivo.writeAsString(csvContent.toString());

      return rutaArchivo;
    } catch (e) {
      throw Exception('Error al exportar a CSV: $e');
    }
  }

  // Métodos para llenar las hojas de Excel
  void _llenarHojaInfoGeneral(Sheet hoja, InformacionGeneral info) {
    // Encabezados
    _escribirExcelCelda(hoja, 0, 0, 'INFORMACIÓN GENERAL DEL INMUEBLE');
    _escribirExcelCelda(hoja, 2, 0, 'Parámetro');
    _escribirExcelCelda(hoja, 2, 1, 'Valor');

    // Datos
    int fila = 3;
    _escribirExcelFila(hoja, fila++, 'Nombre del inmueble', info.nombreInmueble);
    _escribirExcelFila(hoja, fila++, 'Calle', info.calle);
    _escribirExcelFila(hoja, fila++, 'Colonia', info.colonia);
    _escribirExcelFila(hoja, fila++, 'Código Postal', info.codigoPostal);
    _escribirExcelFila(hoja, fila++, 'Ciudad/Pueblo', info.ciudadPueblo);
    _escribirExcelFila(hoja, fila++, 'Delegación/Municipio', info.delegacionMunicipio);
    _escribirExcelFila(hoja, fila++, 'Estado', info.estado);
    _escribirExcelFila(hoja, fila++, 'Referencias', info.referencias);
    _escribirExcelFila(hoja, fila++, 'Persona de contacto', info.personaContacto);
    _escribirExcelFila(hoja, fila++, 'Teléfono', info.telefono);

    // Dimensiones
    fila += 1;
    _escribirExcelCelda(hoja, fila++, 0, 'DIMENSIONES');
    _escribirExcelFila(hoja, fila++, 'Frente X', '${info.frenteX} metros');
    _escribirExcelFila(hoja, fila++, 'Frente Y', '${info.frenteY} metros');
    _escribirExcelFila(hoja, fila++, 'Número de niveles', info.niveles.toString());
    _escribirExcelFila(hoja, fila++, 'Número de ocupantes', info.ocupantes.toString());
    _escribirExcelFila(hoja, fila++, 'Número de sótanos', info.sotanos.toString());
    
    // Agregar usos seleccionados
    fila += 1;
    _escribirExcelCelda(hoja, fila++, 0, 'USOS');
    info.usos.forEach((uso, seleccionado) {
      if (seleccionado) {
        _escribirExcelFila(hoja, fila++, uso, 'Sí');
      }
    });
    
    if (info.otroUso.isNotEmpty) {
      _escribirExcelFila(hoja, fila++, 'Otro uso', info.otroUso);
    }
    
    // Topografía
    fila += 1;
    _escribirExcelCelda(hoja, fila++, 0, 'TOPOGRAFÍA');
    info.topografia.forEach((tipo, seleccionado) {
      if (seleccionado) {
        _escribirExcelFila(hoja, fila++, tipo, 'Sí');
      }
    });
  }

  void _llenarHojaSistemaEstructural(Sheet hoja, SistemaEstructural sistema) {
    // Encabezados
    _escribirExcelCelda(hoja, 0, 0, 'SISTEMA ESTRUCTURAL');
    _escribirExcelCelda(hoja, 2, 0, 'Categoría');
    _escribirExcelCelda(hoja, 2, 1, 'Elemento');
    _escribirExcelCelda(hoja, 2, 2, 'Seleccionado');

    int fila = 3;
    
    // Dirección X
    _escribirExcelCelda(hoja, fila++, 0, 'DIRECCIÓN X');
    sistema.direccionX.forEach((elemento, seleccionado) {
      _escribirExcelFila(hoja, fila++, 'Dirección X', elemento, 
          terceraColumna: seleccionado ? 'Sí' : 'No');
    });
    
    // Dirección Y
    fila++;
    _escribirExcelCelda(hoja, fila++, 0, 'DIRECCIÓN Y');
    sistema.direccionY.forEach((elemento, seleccionado) {
      _escribirExcelFila(hoja, fila++, 'Dirección Y', elemento, 
          terceraColumna: seleccionado ? 'Sí' : 'No');
    });
    
    // Muros de mampostería
    fila++;
    _escribirExcelCelda(hoja, fila++, 0, 'MUROS DE MAMPOSTERÍA');
    sistema.murosMamposteria.forEach((elemento, seleccionado) {
      _escribirExcelFila(hoja, fila++, 'Muros de Mampostería', elemento, 
          terceraColumna: seleccionado ? 'Sí' : 'No');
    });
    
    // Sistemas de piso
    fila++;
    _escribirExcelCelda(hoja, fila++, 0, 'SISTEMAS DE PISO');
    sistema.sistemasPiso.forEach((elemento, seleccionado) {
      _escribirExcelFila(hoja, fila++, 'Sistemas de Piso', elemento, 
          terceraColumna: seleccionado ? 'Sí' : 'No');
    });
    
    // Sistemas de techo
    fila++;
    _escribirExcelCelda(hoja, fila++, 0, 'SISTEMAS DE TECHO');
    sistema.sistemasTecho.forEach((elemento, seleccionado) {
      _escribirExcelFila(hoja, fila++, 'Sistemas de Techo', elemento, 
          terceraColumna: seleccionado ? 'Sí' : 'No');
    });
    
    if (sistema.otroTecho.isNotEmpty) {
      _escribirExcelFila(hoja, fila++, 'Sistemas de Techo', 'Otro', 
          terceraColumna: sistema.otroTecho);
    }
    
    // Resto de secciones: cimentación, vulnerabilidad, posición en manzana, etc.
    fila++;
    _escribirExcelCelda(hoja, fila++, 0, 'CIMENTACIÓN');
    sistema.cimentacion.forEach((elemento, seleccionado) {
      _escribirExcelFila(hoja, fila++, 'Cimentación', elemento, 
          terceraColumna: seleccionado ? 'Sí' : 'No');
    });
    
    fila++;
    _escribirExcelCelda(hoja, fila++, 0, 'VULNERABILIDAD');
    sistema.vulnerabilidad.forEach((elemento, seleccionado) {
      _escribirExcelFila(hoja, fila++, 'Vulnerabilidad', elemento, 
          terceraColumna: seleccionado ? 'Sí' : 'No');
    });
    
    fila++;
    _escribirExcelCelda(hoja, fila++, 0, 'POSICIÓN EN MANZANA');
    sistema.posicionManzana.forEach((elemento, seleccionado) {
      _escribirExcelFila(hoja, fila++, 'Posición en Manzana', elemento, 
          terceraColumna: seleccionado ? 'Sí' : 'No');
    });
    
    fila++;
    _escribirExcelCelda(hoja, fila++, 0, 'OTRAS CARACTERÍSTICAS');
    sistema.otrasCaracteristicas.forEach((elemento, seleccionado) {
      _escribirExcelFila(hoja, fila++, 'Otras Características', elemento, 
          terceraColumna: seleccionado ? 'Sí' : 'No');
    });
    
    fila++;
    _escribirExcelFila(hoja, fila++, 'Separación edificios vecinos', 
        '${sistema.separacionEdificios} cm');
  }

  void _llenarHojaEvaluacionDanos(Sheet hoja, EvaluacionDanos evaluacion) {
    // Encabezados
    _escribirExcelCelda(hoja, 0, 0, 'EVALUACIÓN DE DAÑOS');
    _escribirExcelCelda(hoja, 2, 0, 'Categoría');
    _escribirExcelCelda(hoja, 2, 1, 'Elemento');
    _escribirExcelCelda(hoja, 2, 2, 'Valor');

    int fila = 3;
    
    // Daños geotécnicos
    _escribirExcelCelda(hoja, fila++, 0, 'DAÑOS GEOTÉCNICOS');
    evaluacion.geotecnicos.forEach((elemento, seleccionado) {
      _escribirExcelFila(hoja, fila++, 'Daños Geotécnicos', elemento, 
          terceraColumna: seleccionado ? 'Sí' : 'No');
    });
    
    // Inclinación del edificio
    fila++;
    _escribirExcelFila(hoja, fila++, 'Inclinación del edificio', 
        '${evaluacion.inclinacionEdificio}%');
    
    // Losas
    fila++;
    _escribirExcelCelda(hoja, fila++, 0, 'LOSAS');
    _escribirExcelFila(hoja, fila++, 'Losas', 'Colapso', 
        terceraColumna: evaluacion.losasColapso ? 'Sí' : 'No');
    _escribirExcelFila(hoja, fila++, 'Losas', 'Grietas máximas', 
        terceraColumna: '${evaluacion.losasGrietasMax} mm');
    _escribirExcelFila(hoja, fila++, 'Losas', 'Flecha máxima', 
        terceraColumna: '${evaluacion.losasFlechaMax} cm');
    
    // Conexiones con falla
    fila++;
    _escribirExcelCelda(hoja, fila++, 0, 'CONEXIONES CON FALLA');
    evaluacion.conexionesFalla.forEach((elemento, seleccionado) {
      _escribirExcelFila(hoja, fila++, 'Conexiones con Falla', elemento, 
          terceraColumna: seleccionado ? 'Sí' : 'No');
    });
    
    // Daños a la estructura (tabla)
    fila++;
    _escribirExcelCelda(hoja, fila++, 0, 'DAÑOS A LA ESTRUCTURA');
    
    // Estructura en columna A, tipos de daño como encabezados B-H
    List<String> tiposDano = [
      'Colapso',
      'Grietas cortante',
      'Grietas Flexión',
      'Aplastamiento',
      'Pandeo barras',
      'Pandeo placas',
      'Falla Soldadura'
    ];
    
    // Escribir encabezados de tipos de daño
    _escribirExcelCelda(hoja, fila, 0, 'Estructura');
    for (int i = 0; i < tiposDano.length; i++) {
      _escribirExcelCelda(hoja, fila, i + 1, tiposDano[i]);
    }
    fila++;
    
    // Escribir filas de datos
    evaluacion.danosEstructura.forEach((estructura, danos) {
      _escribirExcelCelda(hoja, fila, 0, estructura);
      for (int i = 0; i < tiposDano.length; i++) {
        bool seleccionado = danos[tiposDano[i]] ?? false;
        _escribirExcelCelda(hoja, fila, i + 1, seleccionado ? 'Sí' : 'No');
      }
      fila++;
    });
    
    // Mediciones (tabla)
    fila++;
    _escribirExcelCelda(hoja, fila++, 0, 'MEDICIONES');
    
    // Estructura en columna A, tipos de medición como encabezados B-E
    List<String> tiposMedicion = [
      'Ancho máximo de grieta (mm)',
      'Separación de estribos (cm)',
      'Longitud de traslape (cm)',
      'Sección/Espesor de muro (cm)'
    ];
    
    // Escribir encabezados de tipos de medición
    _escribirExcelCelda(hoja, fila, 0, 'Estructura');
    for (int i = 0; i < tiposMedicion.length; i++) {
      _escribirExcelCelda(hoja, fila, i + 1, tiposMedicion[i]);
    }
    fila++;
    
    // Escribir filas de datos
    evaluacion.mediciones.forEach((estructura, mediciones) {
      _escribirExcelCelda(hoja, fila, 0, estructura);
      for (int i = 0; i < tiposMedicion.length; i++) {
        double valor = mediciones[tiposMedicion[i]] ?? 0.0;
        _escribirExcelCelda(hoja, fila, i + 1, valor.toString());
      }
      fila++;
    });
    
    // Entrepiso crítico
    fila++;
    _escribirExcelCelda(hoja, fila++, 0, 'ENTREPISO CRÍTICO');
    _escribirExcelFila(hoja, fila++, 'Entrepiso Crítico', 'Columnas con daño severo', 
        terceraColumna: evaluacion.columnasConDanoSevero.toString());
    _escribirExcelFila(hoja, fila++, 'Entrepiso Crítico', 'Total columnas en entrepiso', 
        terceraColumna: evaluacion.totalColumnasEntrepiso.toString());
    
    // Nivel de daño
    fila++;
    _escribirExcelCelda(hoja, fila++, 0, 'NIVEL DE DAÑO');
    evaluacion.nivelDano.forEach((elemento, seleccionado) {
      _escribirExcelFila(hoja, fila++, 'Nivel de Daño', elemento, 
          terceraColumna: seleccionado ? 'Sí' : 'No');
    });
    
    // Otros daños
    fila++;
    _escribirExcelCelda(hoja, fila++, 0, 'OTROS DAÑOS');
    evaluacion.otrosDanos.forEach((elemento, seleccionado) {
      _escribirExcelFila(hoja, fila++, 'Otros Daños', elemento, 
          terceraColumna: seleccionado ? 'Sí' : 'No');
    });
  }

  void _llenarHojaUbicacion(Sheet hoja, UbicacionGeorreferencial ubicacion) {
    // Encabezados
    _escribirExcelCelda(hoja, 0, 0, 'UBICACIÓN GEORREFERENCIAL');
    _escribirExcelCelda(hoja, 2, 0, 'Parámetro');
    _escribirExcelCelda(hoja, 2, 1, 'Valor');

    int fila = 3;
    
    // Datos básicos
    _escribirExcelFila(hoja, fila++, 'Existen planos', ubicacion.existenPlanos ?? 'No especificado');
    _escribirExcelFila(hoja, fila++, 'Dirección', ubicacion.direccion);
    _escribirExcelFila(hoja, fila++, 'Latitud', ubicacion.latitud.toString());
    _escribirExcelFila(hoja, fila++, 'Longitud', ubicacion.longitud.toString());
    
    // Fotografías adjuntas
    fila++;
    _escribirExcelCelda(hoja, fila++, 0, 'FOTOGRAFÍAS ADJUNTAS');
    
    if (ubicacion.rutasFotos.isNotEmpty) {
      for (int i = 0; i < ubicacion.rutasFotos.length; i++) {
        _escribirExcelFila(hoja, fila++, 'Fotografía ${i + 1}', 
            _fileService.obtenerNombreArchivo(ubicacion.rutasFotos[i]));
      }
    } else {
      _escribirExcelFila(hoja, fila++, 'Fotografías', 'No hay fotografías adjuntas');
    }
  }

  // Métodos auxiliares para CSV
  void _agregarSeccionCSV(StringBuffer buffer, String id, String seccion,
      String campo, String valor) {
    // Escapar comillas en los valores
    final idEscapado = _escaparCSV(id);
    final seccionEscapada = _escaparCSV(seccion);
    final campoEscapado = _escaparCSV(campo);
    final valorEscapado = _escaparCSV(valor);

    buffer.writeln('$idEscapado,$seccionEscapada,$campoEscapado,$valorEscapado');
  }

  String _escaparCSV(String valor) {
    if (valor.contains(',') || valor.contains('"') || valor.contains('\n')) {
      return '"${valor.replaceAll('"', '""')}"';
    }
    return valor;
  }

  // Métodos auxiliares para Excel
  void _escribirExcelCelda(Sheet hoja, int fila, int columna, dynamic valor) {
    final celda = CellIndex.indexByColumnRow(columnIndex: columna, rowIndex: fila);
    hoja.cell(celda).value = valor;
  }

  void _escribirExcelFila(Sheet hoja, int fila, String etiqueta, String valor, 
      {String? terceraColumna}) {
    _escribirExcelCelda(hoja, fila, 0, etiqueta);
    _escribirExcelCelda(hoja, fila, 1, valor);
    if (terceraColumna != null) {
      _escribirExcelCelda(hoja, fila, 2, terceraColumna);
    }
  }

  // Helper para formatear fechas
  String _formatearFecha(DateTime fecha) {
    return '${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year}';
  }
}