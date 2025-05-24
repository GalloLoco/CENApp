// lib/data/services/excel_export_service.dart
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:syncfusion_flutter_xlsio/xlsio.dart';
import '../../logica/formato_evaluacion.dart';
import './file_storage_service.dart';

/// Servicio optimizado para exportación a Excel usando Syncfusion
/// Preparado para futuras implementaciones de gráficas
class ExcelExportService {
  final FileStorageService _fileService = FileStorageService();
  
  // Constantes para el formato
  static const String SHEET_NAME = 'Formato Completo';
  static const double LOGO_WIDTH = 80;
  static const double LOGO_HEIGHT = 60;
  
  /// Exporta el formato de evaluación a Excel con logos
  Future<String> exportarFormatoExcel(FormatoEvaluacion formato, {Directory? directorio}) async {
    // Crear nuevo libro de Excel
    final Workbook workbook = Workbook();
    
    try {
      // Obtener directorio de destino
      final directorioFinal = directorio ?? await _fileService.obtenerDirectorioDocumentos();
      final nombreArchivo = 'Cenapred${formato.id}.xlsx';
      final rutaArchivo = '${directorioFinal.path}/$nombreArchivo';
      
      // Crear hoja principal
      final Worksheet sheet = workbook.worksheets[0];
      sheet.name = SHEET_NAME;
      
      // Configurar estilos globales
      _configurarEstilosGlobales(workbook);
      
      // Agregar logos en las esquinas superiores
      await _agregarLogos(sheet);
      
      // Llenar contenido del formato
      int filaActual = 8; // Empezar después de los logos
      
      // Encabezado principal
      filaActual = _escribirEncabezado(sheet, filaActual, formato);
      
      // Secciones del formato
      filaActual = _escribirInformacionGeneral(sheet, filaActual + 2, formato.informacionGeneral);
      filaActual = _escribirSistemaEstructural(sheet, filaActual + 2, formato.sistemaEstructural);
      filaActual = _escribirEvaluacionDanos(sheet, filaActual + 2, formato.evaluacionDanos);
      filaActual = _escribirUbicacionGeorreferencial(sheet, filaActual + 2, formato.ubicacionGeorreferencial);
      
      // Ajustar anchos de columna automáticamente
      _ajustarAnchoColumnas(sheet);
      
      // Guardar archivo
      final List<int> bytes = workbook.saveAsStream();
      final File file = File(rutaArchivo);
      await file.writeAsBytes(bytes);
      
      // Liberar recursos
      workbook.dispose();
      
      return rutaArchivo;
    } catch (e) {
      // Asegurar liberación de recursos en caso de error
      workbook.dispose();
      throw Exception('Error al exportar Excel con Syncfusion: $e');
    }
  }

  /// Configura estilos globales del libro
  void _configurarEstilosGlobales(Workbook workbook) {
    // Estilo para títulos principales
    final Style tituloStyle = workbook.styles.add('TituloPrincipal');
    tituloStyle.fontSize = 16;
    tituloStyle.bold = true;
    tituloStyle.hAlign = HAlignType.center;
    tituloStyle.vAlign = VAlignType.center;
    tituloStyle.backColor = '#E3F2FD'; // Azul claro
    
    // Estilo para subtítulos de sección
    final Style seccionStyle = workbook.styles.add('TituloSeccion');
    seccionStyle.fontSize = 14;
    seccionStyle.bold = true;
    seccionStyle.backColor = '#BBDEFB';
    
    // Estilo para subsecciones
    final Style subseccionStyle = workbook.styles.add('Subseccion');
    subseccionStyle.fontSize = 12;
    subseccionStyle.bold = true;
    subseccionStyle.backColor = '#E1F5FE';
    
    // Estilo para etiquetas
    final Style etiquetaStyle = workbook.styles.add('Etiqueta');
    etiquetaStyle.bold = true;
    
    // Estilo para valores
    final Style valorStyle = workbook.styles.add('Valor');
    valorStyle.wrapText = true;
  }

  /// Agrega logos en las esquinas superiores
  Future<void> _agregarLogos(Worksheet sheet) async {
    try {
      // Cargar imagen del logo desde assets
      final ByteData imageData = await rootBundle.load('assets/logoCenapp.png');
      final Uint8List imageBytes = imageData.buffer.asUint8List();
      
      // Logo superior izquierdo
      final Picture logoIzquierdo = sheet.pictures.addStream(1, 1, imageBytes);
      logoIzquierdo.width = LOGO_WIDTH.toInt();
      logoIzquierdo.height = LOGO_HEIGHT.toInt();
      
      // Logo superior derecho (columna H)
      final Picture logoDerecho = sheet.pictures.addStream(1, 8, imageBytes);
      logoDerecho.width = LOGO_WIDTH.toInt();
      logoDerecho.height = LOGO_HEIGHT.toInt();
      
      // Ajustar altura de las primeras filas para acomodar logos
      for (int i = 1; i <= 5; i++) {
        sheet.getRangeByIndex(i, 1).rowHeight = 15;
      }
    } catch (e) {
      print('Error al cargar logos: $e');
      // Continuar sin logos si hay error
    }
  }

  /// Escribe el encabezado principal
  int _escribirEncabezado(Worksheet sheet, int filaInicial, FormatoEvaluacion formato) {
    int fila = filaInicial;
    
    // Título principal centrado
    final Range tituloRange = sheet.getRangeByIndex(fila, 2, fila, 7);
    tituloRange.merge();
    tituloRange.setText('FORMATO DE EVALUACIÓN DE INMUEBLE');
    tituloRange.cellStyle.name = 'TituloPrincipal';
    
    fila += 2;
    
    // Información del formato
    _escribirFilaCentrada(sheet, fila++, 'ID: ${formato.id}', 2, 7);
    _escribirFilaCentrada(sheet, fila++, 
      'Fecha de evaluación: ${_formatearFecha(formato.fechaCreacion)}', 2, 7);
    _escribirFilaCentrada(sheet, fila++, 
      'Evaluador: ${formato.gradoUsuario ?? ""} ${formato.usuarioCreador}', 2, 7);
    
    // Coordenadas
    String coordenadas = _formatearCoordenadas(
      formato.ubicacionGeorreferencial.latitud,
      formato.ubicacionGeorreferencial.longitud,
      formato.ubicacionGeorreferencial.altitud
    );
    _escribirFilaCentrada(sheet, fila++, 'Ubicación: $coordenadas', 2, 7);
    
    return fila;
  }

  /// Escribe la sección de información general
  int _escribirInformacionGeneral(Worksheet sheet, int filaInicial, InformacionGeneral info) {
    int fila = filaInicial;
    
    // Título de sección
    _escribirTituloSeccion(sheet, fila++, 'INFORMACIÓN GENERAL DEL INMUEBLE');
    fila++;
    
    // Datos básicos
    _escribirCampo(sheet, fila++, 'Nombre del inmueble:', info.nombreInmueble);
    _escribirCampo(sheet, fila++, 'Calle:', info.calle);
    _escribirCampo(sheet, fila++, 'Colonia:', info.colonia);
    _escribirCampo(sheet, fila++, 'Código Postal:', info.codigoPostal);
    _escribirCampo(sheet, fila++, 'Ciudad/Pueblo:', info.ciudadPueblo);
    _escribirCampo(sheet, fila++, 'Delegación/Municipio:', info.delegacionMunicipio);
    _escribirCampo(sheet, fila++, 'Estado:', info.estado);
    _escribirCampo(sheet, fila++, 'Referencias:', info.referencias);
    _escribirCampo(sheet, fila++, 'Persona contactada:', info.personaContacto);
    _escribirCampo(sheet, fila++, 'Teléfono:', info.telefono);
    
    fila++;
    
    // Dimensiones
    _escribirSubseccion(sheet, fila++, 'DIMENSIONES');
    _escribirCampo(sheet, fila++, 'Frente X:', '${info.frenteX} metros');
    _escribirCampo(sheet, fila++, 'Frente Y:', '${info.frenteY} metros');
    _escribirCampo(sheet, fila++, 'Número de niveles:', info.niveles.toString());
    _escribirCampo(sheet, fila++, 'Número de ocupantes:', info.ocupantes.toString());
    _escribirCampo(sheet, fila++, 'Número de sótanos:', info.sotanos.toString());
    
    fila++;
    
    // Usos
    _escribirSubseccion(sheet, fila++, 'USOS DEL INMUEBLE');
    info.usos.forEach((uso, seleccionado) {
      if (seleccionado) {
        _escribirCampo(sheet, fila++, uso, 'Sí');
      }
    });
    if (info.otroUso.isNotEmpty) {
      _escribirCampo(sheet, fila++, 'Otro uso:', info.otroUso);
    }
    
    fila++;
    
    // Topografía
    _escribirSubseccion(sheet, fila++, 'TOPOGRAFÍA');
    info.topografia.forEach((tipo, seleccionado) {
      if (seleccionado) {
        _escribirCampo(sheet, fila++, tipo, 'Sí');
      }
    });
    
    return fila;
  }

  /// Escribe la sección de sistema estructural
  int _escribirSistemaEstructural(Worksheet sheet, int filaInicial, SistemaEstructural sistema) {
    int fila = filaInicial;
    
    _escribirTituloSeccion(sheet, fila++, 'SISTEMA ESTRUCTURAL');
    fila++;
    
    // Dirección X
    fila = _escribirMapBool(sheet, fila, 'DIRECCIÓN X', sistema.direccionX);
    
    // Dirección Y
    fila = _escribirMapBool(sheet, fila, 'DIRECCIÓN Y', sistema.direccionY);
    
    // Muros de mampostería
    fila = _escribirMapBool(sheet, fila, 'MUROS DE MAMPOSTERÍA', sistema.murosMamposteria);
    
    // Sistemas de piso
    fila = _escribirMapBool(sheet, fila, 'SISTEMAS DE PISO', sistema.sistemasPiso);
    
    // Sistemas de techo
    fila = _escribirMapBool(sheet, fila, 'SISTEMAS DE TECHO', sistema.sistemasTecho);
    if (sistema.otroTecho.isNotEmpty) {
      _escribirCampo(sheet, fila++, 'Otro techo:', sistema.otroTecho);
    }
    
    // Cimentación
    fila = _escribirMapBool(sheet, fila, 'CIMENTACIÓN', sistema.cimentacion);
    
    // Vulnerabilidad
    fila = _escribirMapBool(sheet, fila, 'VULNERABILIDAD', sistema.vulnerabilidad);
    
    // Posición en manzana
    fila = _escribirMapBool(sheet, fila, 'POSICIÓN EN MANZANA', sistema.posicionManzana);
    
    // Otras características
    fila = _escribirMapBool(sheet, fila, 'OTRAS CARACTERÍSTICAS', sistema.otrasCaracteristicas);
    
    // Separación edificios
    _escribirCampo(sheet, fila++, 'Separación edificios vecinos:', '${sistema.separacionEdificios} cm');
    
    return fila;
  }

  /// Escribe la sección de evaluación de daños
  int _escribirEvaluacionDanos(Worksheet sheet, int filaInicial, EvaluacionDanos evaluacion) {
    int fila = filaInicial;
    
    _escribirTituloSeccion(sheet, fila++, 'EVALUACIÓN DE DAÑOS');
    fila++;
    
    // Daños geotécnicos
    fila = _escribirMapBool(sheet, fila, 'DAÑOS GEOTÉCNICOS', evaluacion.geotecnicos);
    
    // Inclinación
    _escribirCampo(sheet, fila++, 'Inclinación del edificio:', '${evaluacion.inclinacionEdificio}%');
    fila++;
    
    // Losas
    _escribirSubseccion(sheet, fila++, 'LOSAS');
    _escribirCampo(sheet, fila++, 'Colapso:', evaluacion.losasColapso ? 'Sí' : 'No');
    _escribirCampo(sheet, fila++, 'Grietas máximas:', '${evaluacion.losasGrietasMax} mm');
    _escribirCampo(sheet, fila++, 'Flecha máxima:', '${evaluacion.losasFlechaMax} cm');
    fila++;
    
    // Conexiones con falla
    fila = _escribirMapBool(sheet, fila, 'CONEXIONES CON FALLA', evaluacion.conexionesFalla);
    
    // Tabla de daños a la estructura (simplificada)
    _escribirSubseccion(sheet, fila++, 'DAÑOS A LA ESTRUCTURA');
    evaluacion.danosEstructura.forEach((estructura, danos) {
      bool tieneDanos = danos.values.any((v) => v);
      if (tieneDanos) {
        _escribirCampo(sheet, fila++, estructura + ':', '');
        danos.forEach((tipoDano, seleccionado) {
          if (seleccionado) {
            sheet.getRangeByIndex(fila, 3).setText('• $tipoDano');
            fila++;
          }
        });
      }
    });
    
    fila++;
    
    // Mediciones
    _escribirSubseccion(sheet, fila++, 'MEDICIONES');
    evaluacion.mediciones.forEach((estructura, mediciones) {
      bool tieneMediciones = mediciones.values.any((v) => v > 0);
      if (tieneMediciones) {
        _escribirCampo(sheet, fila++, estructura + ':', '');
        mediciones.forEach((tipoMedicion, valor) {
          if (valor > 0) {
            sheet.getRangeByIndex(fila, 3).setText('• $tipoMedicion: $valor');
            fila++;
          }
        });
      }
    });
    
    fila++;
    
    // Entrepiso crítico
    _escribirSubseccion(sheet, fila++, 'ENTREPISO CRÍTICO');
    _escribirCampo(sheet, fila++, 'Columnas con daño severo:', evaluacion.columnasConDanoSevero.toString());
    _escribirCampo(sheet, fila++, 'Total columnas en entrepiso:', evaluacion.totalColumnasEntrepiso.toString());
    
    fila++;
    
    // Nivel de daño
    fila = _escribirMapBool(sheet, fila, 'NIVEL DE DAÑO', evaluacion.nivelDano);
    
    // Otros daños
    fila = _escribirMapBool(sheet, fila, 'OTROS DAÑOS', evaluacion.otrosDanos);
    
    return fila;
  }

  /// Escribe la sección de ubicación georreferencial
  int _escribirUbicacionGeorreferencial(Worksheet sheet, int filaInicial, UbicacionGeorreferencial ubicacion) {
    int fila = filaInicial;
    
    _escribirTituloSeccion(sheet, fila++, 'UBICACIÓN GEORREFERENCIAL');
    fila++;
    
    _escribirCampo(sheet, fila++, 'Existen planos:', ubicacion.existenPlanos ?? 'No especificado');
    _escribirCampo(sheet, fila++, 'Dirección:', ubicacion.direccion);
    
    String coordenadasDetalle = _formatearCoordenadas(
      ubicacion.latitud,
      ubicacion.longitud,
      ubicacion.altitud
    );
    _escribirCampo(sheet, fila++, 'Coordenadas:', coordenadasDetalle);
    
    fila++;
    
    // Fotografías
    _escribirSubseccion(sheet, fila++, 'FOTOGRAFÍAS ADJUNTAS');
    if (ubicacion.rutasFotos.isNotEmpty) {
      _escribirCampo(sheet, fila++, 'Número de fotografías:', ubicacion.rutasFotos.length.toString());
      ubicacion.rutasFotos.forEach((ruta) {
        String nombreArchivo = ruta.split('/').last;
        sheet.getRangeByIndex(fila, 3).setText('• $nombreArchivo');
        fila++;
      });
    } else {
      _escribirCampo(sheet, fila++, 'Fotografías:', 'No hay fotografías adjuntas');
    }
    
    return fila;
  }

  // ===== MÉTODOS AUXILIARES =====

  /// Escribe un título de sección
  void _escribirTituloSeccion(Worksheet sheet, int fila, String titulo) {
    final Range range = sheet.getRangeByIndex(fila, 1, fila, 8);
    range.merge();
    range.setText(titulo);
    range.cellStyle.name = 'TituloSeccion';
  }

  /// Escribe un subtítulo
  void _escribirSubseccion(Worksheet sheet, int fila, String titulo) {
    final Range range = sheet.getRangeByIndex(fila, 1, fila, 6);
    range.merge();
    range.setText(titulo);
    range.cellStyle.name = 'Subseccion';
  }

  /// Escribe un campo etiqueta-valor
  void _escribirCampo(Worksheet sheet, int fila, String etiqueta, String valor) {
    sheet.getRangeByIndex(fila, 1).setText(etiqueta);
    sheet.getRangeByIndex(fila, 1).cellStyle.name = 'Etiqueta';
    
    final Range valorRange = sheet.getRangeByIndex(fila, 3, fila, 6);
    valorRange.merge();
    valorRange.setText(valor);
    valorRange.cellStyle.name = 'Valor';
  }

  /// Escribe una fila centrada
  void _escribirFilaCentrada(Worksheet sheet, int fila, String texto, int colInicio, int colFin) {
    final Range range = sheet.getRangeByIndex(fila, colInicio, fila, colFin);
    range.merge();
    range.setText(texto);
    range.cellStyle.hAlign = HAlignType.center;
  }

  /// Escribe un mapa de valores booleanos
  int _escribirMapBool(Worksheet sheet, int fila, String titulo, Map<String, bool> mapa) {
    _escribirSubseccion(sheet, fila++, titulo);
    
    mapa.forEach((key, value) {
      if (value) {
        _escribirCampo(sheet, fila++, key, 'Sí');
      }
    });
    
    // Si no hay elementos seleccionados
    if (!mapa.values.any((v) => v)) {
      _escribirCampo(sheet, fila++, 'Sin selección', '-');
    }
    
    return fila + 1; // Espacio adicional
  }

  /// Ajusta el ancho de las columnas automáticamente
  void _ajustarAnchoColumnas(Worksheet sheet) {
    // Ajustar columnas principales
    sheet.autoFitColumn(1); // Etiquetas
    sheet.autoFitColumn(2); // Espaciador
    
    // Establecer ancho mínimo para columnas de contenido
    for (int i = 3; i <= 8; i++) {
      if (sheet.getColumnWidth(i) < 15) {
        sheet.getRangeByIndex(1, i).columnWidth = 15;
      }
    }
    
    // Columna 1 más ancha para etiquetas
    if (sheet.getColumnWidth(1) < 30) {
      sheet.getRangeByIndex(1, 1).columnWidth = 30;
    }
  }

  /// Formatea coordenadas
  String _formatearCoordenadas(double latitud, double longitud, double altitud) {
    double lat = double.parse(latitud.toStringAsFixed(4));
    double lng = double.parse(longitud.toStringAsFixed(4));
    int alt = altitud.round();
    
    String latDir = lat >= 0 ? "N" : "S";
    String lngDir = lng >= 0 ? "E" : "O";
    
    return "${lat.abs()} $latDir, ${lng.abs()} $lngDir, ${alt.abs()} msnm";
  }

  /// Formatea fecha
  String _formatearFecha(DateTime fecha) {
    return '${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year}';
  }

  /// Exporta a formato CSV como alternativa
  Future<String> exportarFormatoCSV(FormatoEvaluacion formato, {Directory? directorio}) async {
    final directorioFinal = directorio ?? await _fileService.obtenerDirectorioDocumentos();
    final nombreArchivo = 'Cenapp${formato.id}.csv';
    final rutaArchivo = '${directorioFinal.path}/$nombreArchivo';
    
    final StringBuffer buffer = StringBuffer();
    
    // Encabezado CSV
    buffer.writeln('Sección,Campo,Valor');
    
    // Información general
    buffer.writeln('Información General,ID,${_escaparCSV(formato.id)}');
    buffer.writeln('Información General,Fecha Creación,${_formatearFecha(formato.fechaCreacion)}');
    buffer.writeln('Información General,Evaluador,${_escaparCSV(formato.usuarioCreador)}');
    buffer.writeln('Información General,Nombre Inmueble,${_escaparCSV(formato.informacionGeneral.nombreInmueble)}');
    
    // Agregar más campos según necesidad...
    
    // Guardar archivo
    final File file = File(rutaArchivo);
    await file.writeAsString(buffer.toString());
    
    return rutaArchivo;
  }

  /// Escapa valores para CSV
  String _escaparCSV(String valor) {
    if (valor.contains(',') || valor.contains('"') || valor.contains('\n')) {
      return '"${valor.replaceAll('"', '""')}"';
    }
    return valor;
  }
}