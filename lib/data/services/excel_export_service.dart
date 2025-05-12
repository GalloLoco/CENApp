// lib/data/services/excel_export_service.dart - Versión con una sola hoja
import 'dart:io';
import 'package:excel/excel.dart';
import '../../logica/formato_evaluacion.dart';
import './file_storage_service.dart';

/// Servicio para la exportación de documentos a Excel (versión de hoja única)
class ExcelExportService {
  final FileStorageService _fileService = FileStorageService();

  /// Exporta el formato de evaluación a un archivo Excel de una sola hoja
  Future<String> exportarFormatoExcel(FormatoEvaluacion formato,
      {Directory? directorio}) async {
    try {
      // Obtener directorio
      final directorioFinal =
          directorio ?? await _fileService.obtenerDirectorioDocumentos();
      final nombreArchivo = 'Cenapp${formato.id}.xlsx';
      final rutaArchivo = '${directorioFinal.path}/$nombreArchivo';

      // Crear un libro de Excel
      final excel = Excel.createExcel();

      // Usar solo una hoja para todos los datos
      final hojaUnica = excel['Formato Completo'];

      // Formatear coordenadas para mostrarlas en formato amigable
      String coordenadasFormateadas = _formatearCoordenadas(
          formato.ubicacionGeorreferencial.latitud,
          formato.ubicacionGeorreferencial.longitud,
          formato.ubicacionGeorreferencial.altitud);

      // Eliminar la hoja por defecto si es diferente
      if (excel.sheets.containsKey('Sheet1') &&
          'Sheet1' != 'Formato Completo') {
        excel.delete('Sheet1');
      }

      // Llenar la hoja única con todos los datos
      int filaActual = 0;

      // Título principal
      _escribirCelda(
          hojaUnica, filaActual++, 0, 'FORMATO DE EVALUACIÓN DE INMUEBLE');
      _escribirCelda(hojaUnica, filaActual++, 0, 'ID: ${formato.id}');
      _escribirCelda(hojaUnica, filaActual++, 0,
          'Fecha de evaluacion: ${_formatearFecha(formato.fechaCreacion)} - Nombre del evaluador: ${formato.usuarioCreador} - Grado: ${formato.gradoUsuario}');
      _escribirCelda(hojaUnica, filaActual++, 0, 'Coordenadas: ${coordenadasFormateadas}');

      // Separador
      filaActual++;

      // ---- SECCIÓN 1: INFORMACIÓN GENERAL ----
      filaActual = _escribirSeccionInfoGeneral(
          hojaUnica, filaActual, formato.informacionGeneral);

      // Separador
      filaActual++;

      // ---- SECCIÓN 2: SISTEMA ESTRUCTURAL ----
      filaActual = _escribirSeccionSistemaEstructural(
          hojaUnica, filaActual, formato.sistemaEstructural);

      // Separador
      filaActual++;

      // ---- SECCIÓN 3: EVALUACIÓN DE DAÑOS ----
      filaActual = _escribirSeccionEvaluacionDanos(
          hojaUnica, filaActual, formato.evaluacionDanos);

      // Separador
      filaActual++;

      // ---- SECCIÓN 4: UBICACIÓN GEORREFERENCIAL ----
      filaActual = _escribirSeccionUbicacion(
          hojaUnica, filaActual, formato.ubicacionGeorreferencial);

      // IMPORTANTE: Aquí se generan los bytes del Excel
      final bytes = excel.save(); // Esta línea genera los bytes
      if (bytes == null) {
        throw Exception('Error al codificar el archivo Excel');
      }
      // Guardar el archivo Excel
      final archivo = File(rutaArchivo);
      await archivo.writeAsBytes(bytes);

      return rutaArchivo;
    } catch (e) {
      print('Error en exportarFormatoExcel: $e');
      rethrow;
    }
  }

  // Métodos para escribir cada sección y retornar la siguiente fila disponible
  int _escribirSeccionInfoGeneral(
      Sheet hoja, int filaInicial, InformacionGeneral info) {
    try {
      int fila = filaInicial;

      // Encabezado de sección
      _escribirCeldaResaltada(
          hoja, fila++, 0, 'INFORMACIÓN GENERAL DEL INMUEBLE');

      // Datos básicos
      _escribirCelda(hoja, fila, 0, 'Nombre del inmueble:');
      _escribirCelda(hoja, fila++, 1, info.nombreInmueble);

      _escribirCelda(hoja, fila, 0, 'Calle:');
      _escribirCelda(hoja, fila++, 1, info.calle);

      _escribirCelda(hoja, fila, 0, 'Colonia:');
      _escribirCelda(hoja, fila++, 1, info.colonia);

      _escribirCelda(hoja, fila, 0, 'Código Postal:');
      _escribirCelda(hoja, fila++, 1, info.codigoPostal);

      _escribirCelda(hoja, fila, 0, 'Ciudad/Pueblo:');
      _escribirCelda(hoja, fila++, 1, info.ciudadPueblo);

      _escribirCelda(hoja, fila, 0, 'Delegación/Municipio:');
      _escribirCelda(hoja, fila++, 1, info.delegacionMunicipio);

      _escribirCelda(hoja, fila, 0, 'Estado:');
      _escribirCelda(hoja, fila++, 1, info.estado);

      _escribirCelda(hoja, fila, 0, 'Referencias:');
      _escribirCelda(hoja, fila++, 1, info.referencias);

      _escribirCelda(hoja, fila, 0, 'Persona contactada:');
      _escribirCelda(hoja, fila++, 1, info.personaContacto);

      _escribirCelda(hoja, fila, 0, 'Teléfono:');
      _escribirCelda(hoja, fila++, 1, info.telefono);

      // Dimensiones
      fila++;
      _escribirCeldaResaltada(hoja, fila++, 0, 'DIMENSIONES');

      _escribirCelda(hoja, fila, 0, 'Frente X:');
      _escribirCelda(hoja, fila++, 1, '${info.frenteX} metros');

      _escribirCelda(hoja, fila, 0, 'Frente Y:');
      _escribirCelda(hoja, fila++, 1, '${info.frenteY} metros');

      _escribirCelda(hoja, fila, 0, 'Número de niveles:');
      _escribirCelda(hoja, fila++, 1, info.niveles.toString());

      _escribirCelda(hoja, fila, 0, 'Número de ocupantes:');
      _escribirCelda(hoja, fila++, 1, info.ocupantes.toString());

      _escribirCelda(hoja, fila, 0, 'Número de sótanos:');
      _escribirCelda(hoja, fila++, 1, info.sotanos.toString());

      // Usos
      fila++;
      _escribirCeldaResaltada(hoja, fila++, 0, 'USOS');

      for (var entry in info.usos.entries) {
        if (entry.value) {
          _escribirCelda(hoja, fila, 0, entry.key);
          _escribirCelda(hoja, fila++, 1, 'Sí');
        }
      }

      if (info.otroUso.isNotEmpty) {
        _escribirCelda(hoja, fila, 0, 'Otro uso:');
        _escribirCelda(hoja, fila++, 1, info.otroUso);
      }

      // Topografía
      fila++;
      _escribirCeldaResaltada(hoja, fila++, 0, 'TOPOGRAFÍA');

      for (var entry in info.topografia.entries) {
        if (entry.value) {
          _escribirCelda(hoja, fila, 0, entry.key);
          _escribirCelda(hoja, fila++, 1, 'Sí');
        }
      }

      return fila; // Retornar la siguiente fila disponible
    } catch (e) {
      print('Error en _escribirSeccionInfoGeneral: $e');
      return filaInicial + 30; // Avanzar algunas filas en caso de error
    }
  }

  int _escribirSeccionSistemaEstructural(
      Sheet hoja, int filaInicial, SistemaEstructural sistema) {
    try {
      int fila = filaInicial;

      // Encabezado de sección
      _escribirCeldaResaltada(hoja, fila++, 0, 'SISTEMA ESTRUCTURAL');

      // Dirección X
      _escribirCeldaSubtitulo(hoja, fila++, 0, 'DIRECCIÓN X');
      for (var entry in sistema.direccionX.entries) {
        if (entry.value) {
          _escribirCelda(hoja, fila, 0, entry.key);
          _escribirCelda(hoja, fila++, 1, 'Sí');
        }
      }

      // Dirección Y
      fila++;
      _escribirCeldaSubtitulo(hoja, fila++, 0, 'DIRECCIÓN Y');
      for (var entry in sistema.direccionY.entries) {
        if (entry.value) {
          _escribirCelda(hoja, fila, 0, entry.key);
          _escribirCelda(hoja, fila++, 1, 'Sí');
        }
      }

      // Muros de mampostería
      fila++;
      _escribirCeldaSubtitulo(hoja, fila++, 0, 'MUROS DE MAMPOSTERÍA');
      for (var entry in sistema.murosMamposteria.entries) {
        if (entry.value) {
          _escribirCelda(hoja, fila, 0, entry.key);
          _escribirCelda(hoja, fila++, 1, 'Sí');
        }
      }

      // Sistemas de piso
      fila++;
      _escribirCeldaSubtitulo(hoja, fila++, 0, 'SISTEMAS DE PISO');
      for (var entry in sistema.sistemasPiso.entries) {
        if (entry.value) {
          _escribirCelda(hoja, fila, 0, entry.key);
          _escribirCelda(hoja, fila++, 1, 'Sí');
        }
      }

      // Sistemas de techo
      fila++;
      _escribirCeldaSubtitulo(hoja, fila++, 0, 'SISTEMAS DE TECHO');
      for (var entry in sistema.sistemasTecho.entries) {
        if (entry.value) {
          _escribirCelda(hoja, fila, 0, entry.key);
          _escribirCelda(hoja, fila++, 1, 'Sí');
        }
      }

      if (sistema.otroTecho.isNotEmpty) {
        _escribirCelda(hoja, fila, 0, 'Otro:');
        _escribirCelda(hoja, fila++, 1, sistema.otroTecho);
      }

      // Cimentación
      fila++;
      _escribirCeldaSubtitulo(hoja, fila++, 0, 'CIMENTACIÓN');
      for (var entry in sistema.cimentacion.entries) {
        if (entry.value) {
          _escribirCelda(hoja, fila, 0, entry.key);
          _escribirCelda(hoja, fila++, 1, 'Sí');
        }
      }

      // Vulnerabilidad
      fila++;
      _escribirCeldaSubtitulo(hoja, fila++, 0, 'VULNERABILIDAD');
      for (var entry in sistema.vulnerabilidad.entries) {
        if (entry.value) {
          _escribirCelda(hoja, fila, 0, entry.key);
          _escribirCelda(hoja, fila++, 1, 'Sí');
        }
      }

      // Posición en manzana
      fila++;
      _escribirCeldaSubtitulo(hoja, fila++, 0, 'POSICIÓN EN MANZANA');
      for (var entry in sistema.posicionManzana.entries) {
        if (entry.value) {
          _escribirCelda(hoja, fila, 0, entry.key);
          _escribirCelda(hoja, fila++, 1, 'Sí');
        }
      }

      // Otras características
      fila++;
      _escribirCeldaSubtitulo(hoja, fila++, 0, 'OTRAS CARACTERÍSTICAS');
      for (var entry in sistema.otrasCaracteristicas.entries) {
        if (entry.value) {
          _escribirCelda(hoja, fila, 0, entry.key);
          _escribirCelda(hoja, fila++, 1, 'Sí');
        }
      }

      // Separación edificios
      fila++;
      _escribirCelda(hoja, fila, 0, 'Separación edificios vecinos:');
      _escribirCelda(hoja, fila++, 1, '${sistema.separacionEdificios} cm');

      return fila; // Retornar la siguiente fila disponible
    } catch (e) {
      print('Error en _escribirSeccionSistemaEstructural: $e');
      return filaInicial + 50; // Avanzar algunas filas en caso de error
    }
  }

  int _escribirSeccionEvaluacionDanos(
      Sheet hoja, int filaInicial, EvaluacionDanos evaluacion) {
    try {
      int fila = filaInicial;

      // Encabezado de sección
      _escribirCeldaResaltada(hoja, fila++, 0, 'EVALUACIÓN DE DAÑOS');

      // Daños geotécnicos
      _escribirCeldaSubtitulo(hoja, fila++, 0, 'DAÑOS GEOTÉCNICOS');
      for (var entry in evaluacion.geotecnicos.entries) {
        if (entry.value) {
          _escribirCelda(hoja, fila, 0, entry.key);
          _escribirCelda(hoja, fila++, 1, 'Sí');
        }
      }

      // Inclinación
      fila++;
      _escribirCelda(hoja, fila, 0, 'Inclinación del edificio:');
      _escribirCelda(hoja, fila++, 1, '${evaluacion.inclinacionEdificio}%');

      // Losas
      fila++;
      _escribirCeldaSubtitulo(hoja, fila++, 0, 'LOSAS');
      _escribirCelda(hoja, fila, 0, 'Colapso:');
      _escribirCelda(hoja, fila++, 1, evaluacion.losasColapso ? 'Sí' : 'No');
      _escribirCelda(hoja, fila, 0, 'Grietas máximas:');
      _escribirCelda(hoja, fila++, 1, '${evaluacion.losasGrietasMax} mm');
      _escribirCelda(hoja, fila, 0, 'Flecha máxima:');
      _escribirCelda(hoja, fila++, 1, '${evaluacion.losasFlechaMax} cm');

      // Conexiones con falla
      fila++;
      _escribirCeldaSubtitulo(hoja, fila++, 0, 'CONEXIONES CON FALLA');
      for (var entry in evaluacion.conexionesFalla.entries) {
        if (entry.value) {
          _escribirCelda(hoja, fila, 0, entry.key);
          _escribirCelda(hoja, fila++, 1, 'Sí');
        }
      }

      // Daños a la estructura
      fila++;
      _escribirCeldaSubtitulo(hoja, fila++, 0, 'DAÑOS A LA ESTRUCTURA');

      for (var estructuraEntry in evaluacion.danosEstructura.entries) {
        String estructura = estructuraEntry.key;
        Map<String, bool> danos = estructuraEntry.value;

        // Verificar si hay algún daño para esta estructura
        bool hayDanos = danos.values.any((v) => v);

        if (hayDanos) {
          _escribirCelda(hoja, fila++, 0, estructura + ':');

          // Escribir los daños para esta estructura
          danos.forEach((tipoDano, seleccionado) {
            if (seleccionado) {
              _escribirCelda(hoja, fila, 0, '   ' + tipoDano);
              _escribirCelda(hoja, fila++, 1, 'Sí');
            }
          });
        }
      }

      // Mediciones
      fila++;
      _escribirCeldaSubtitulo(hoja, fila++, 0, 'MEDICIONES');

      for (var estructuraEntry in evaluacion.mediciones.entries) {
        String estructura = estructuraEntry.key;
        Map<String, double> mediciones = estructuraEntry.value;

        // Verificar si hay mediciones para esta estructura
        bool hayMediciones = mediciones.values.any((v) => v > 0);

        if (hayMediciones) {
          _escribirCelda(hoja, fila++, 0, estructura + ':');

          // Escribir las mediciones para esta estructura
          mediciones.forEach((tipoMedicion, valor) {
            if (valor > 0) {
              _escribirCelda(hoja, fila, 0, '   ' + tipoMedicion);
              _escribirCelda(hoja, fila++, 1, valor.toString());
            }
          });
        }
      }

      // Entrepiso crítico
      fila++;
      _escribirCeldaSubtitulo(hoja, fila++, 0, 'ENTREPISO CRÍTICO');
      _escribirCelda(hoja, fila, 0, 'Columnas con daño severo:');
      _escribirCelda(
          hoja, fila++, 1, evaluacion.columnasConDanoSevero.toString());
      _escribirCelda(hoja, fila, 0, 'Total columnas en entrepiso:');
      _escribirCelda(
          hoja, fila++, 1, evaluacion.totalColumnasEntrepiso.toString());

      // Nivel de daño
      fila++;
      _escribirCeldaSubtitulo(hoja, fila++, 0, 'NIVEL DE DAÑO');
      for (var entry in evaluacion.nivelDano.entries) {
        if (entry.value) {
          _escribirCelda(hoja, fila, 0, entry.key);
          _escribirCelda(hoja, fila++, 1, 'Sí');
        }
      }

      // Otros daños
      fila++;
      _escribirCeldaSubtitulo(hoja, fila++, 0, 'OTROS DAÑOS');
      for (var entry in evaluacion.otrosDanos.entries) {
        if (entry.value) {
          _escribirCelda(hoja, fila, 0, entry.key);
          _escribirCelda(hoja, fila++, 1, 'Sí');
        }
      }

      return fila; // Retornar la siguiente fila disponible
    } catch (e) {
      print('Error en _escribirSeccionEvaluacionDanos: $e');
      return filaInicial + 50; // Avanzar algunas filas en caso de error
    }
  }

  int _escribirSeccionUbicacion(
      Sheet hoja, int filaInicial, UbicacionGeorreferencial ubicacion) {
    try {
      int fila = filaInicial;

      // Encabezado de sección
      _escribirCeldaResaltada(hoja, fila++, 0, 'UBICACIÓN GEORREFERENCIAL');

      // Formatear coordenadas para mostrarlas en formato amigable
      String coordenadasFormateadas = _formatearCoordenadas(
          ubicacion.latitud, ubicacion.longitud, ubicacion.altitud);

      // Datos básicos
      _escribirCelda(hoja, fila, 0, 'Existen planos:');
      _escribirCelda(
          hoja, fila++, 1, ubicacion.existenPlanos ?? 'No especificado');

      _escribirCelda(hoja, fila, 0, 'Dirección:');
      _escribirCelda(hoja, fila++, 1, ubicacion.direccion);

      _escribirCelda(hoja, fila, 0, 'Coordenadas:');
      _escribirCelda(hoja, fila++, 1, coordenadasFormateadas);

      // ... resto del código ...

      return fila; // Retornar la siguiente fila disponible
    } catch (e) {
      print('Error en _escribirSeccionUbicacion: $e');
      return filaInicial + 20; // Avanzar algunas filas en caso de error
    }
  }

  // Métodos auxiliares optimizados

  // Agregar método para formatear coordenadas
  String _formatearCoordenadas(
      double latitud, double longitud, double altitud) {
    // Redondear a 4 decimales para mayor precisión
    double lat = double.parse(latitud.toStringAsFixed(4));
    double lng = double.parse(longitud.toStringAsFixed(4));
    int alt = altitud.round(); // Redondear la altitud a entero

    String latDir = lat >= 0 ? "N" : "S";
    String lngDir = lng >= 0 ? "E" : "O";

    // Formato: "19.4326 N, 99.1332 O, 2240 msnm"
    return "${lat.abs()} $latDir, ${lng.abs()} $lngDir, ${alt.abs()} msnm";
  }

  void _escribirCelda(Sheet hoja, int fila, int columna, String valor) {
    try {
      final celda =
          CellIndex.indexByColumnRow(columnIndex: columna, rowIndex: fila);
      hoja.cell(celda).value = TextCellValue(valor);
    } catch (e) {
      print('Error al escribir celda ($fila,$columna): $e');
    }
  }

  void _escribirCeldaResaltada(
      Sheet hoja, int fila, int columna, String valor) {
    try {
      final celda =
          CellIndex.indexByColumnRow(columnIndex: columna, rowIndex: fila);
      hoja.cell(celda).value = TextCellValue(valor);

      // Intentar aplicar estilo
      try {
        hoja.cell(celda).cellStyle = CellStyle(
          bold: true,
          fontSize: 14,
        );
      } catch (_) {
        // Ignorar errores de estilo
      }
    } catch (e) {
      print('Error al escribir celda resaltada ($fila,$columna): $e');
    }
  }

  void _escribirCeldaSubtitulo(
      Sheet hoja, int fila, int columna, String valor) {
    try {
      final celda =
          CellIndex.indexByColumnRow(columnIndex: columna, rowIndex: fila);
      hoja.cell(celda).value = TextCellValue(valor);

      // Intentar aplicar estilo
      try {
        hoja.cell(celda).cellStyle = CellStyle(
          bold: true,
          fontSize: 12,
        );
      } catch (_) {
        // Ignorar errores de estilo
      }
    } catch (e) {
      print('Error al escribir celda subtítulo ($fila,$columna): $e');
    }
  }

  String _formatearFecha(DateTime fecha) {
    return '${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year}';
  }

  /// Método para exportación a CSV (mantenido como alternativa)
  Future<String> exportarFormatoCSV(FormatoEvaluacion formato,
      {Directory? directorio}) async {
    // Obtener directorio
    final directorioFinal =
        directorio ?? await _fileService.obtenerDirectorioDocumentos();
    final nombreArchivo = 'Cenapp${formato.id}.csv';
    final rutaArchivo = '${directorioFinal.path}/$nombreArchivo';
    final buffer = StringBuffer();

    buffer.writeln('Sección,Campo,Valor');

    // Información General
    buffer.writeln('Información General,ID,${_escaparCSV(formato.id)}');
    buffer.writeln(
        'Información General,Nombre del inmueble,${_escaparCSV(formato.informacionGeneral.nombreInmueble)}');
    buffer.writeln(
        'Información General,Calle,${_escaparCSV(formato.informacionGeneral.calle)}');
    buffer.writeln(
        'Información General,Colonia,${_escaparCSV(formato.informacionGeneral.colonia)}');

    // Y así sucesivamente con los demás datos...

    final archivo = File(rutaArchivo);
    await archivo.writeAsString(buffer.toString());

    return rutaArchivo;
  }

  String _escaparCSV(String valor) {
    if (valor.contains(',') || valor.contains('"') || valor.contains('\n')) {
      return '"${valor.replaceAll('"', '""')}"';
    }
    return valor;
  }
}
