// lib/data/services/reporte_service.dart (versión actualizada)

import 'dart:typed_data';

import 'package:intl/intl.dart';
import '../../logica/formato_evaluacion.dart';
import '../../data/services/cloud_storage_service.dart';
import '../../data/services/estadisticos_service.dart';
import '../reportes/sistema_estructural_reporte.dart';

import '../../data/services/reporte_documental_service.dart';

class ReporteService {
  final CloudStorageService _cloudService = CloudStorageService();

  /// Genera un reporte de sistema estructural (NUEVO)
  Future<Map<String, String>> generarReporteSistemaEstructural({
    required String nombreInmueble,
    required DateTime fechaInicio,
    required DateTime fechaFin,
    required String usuarioCreador,
    required List<Map<String, dynamic>> ubicaciones,
  }) async {
    // Paso 1: Buscar formatos que cumplan con los criterios
    List<FormatoEvaluacion> formatos = await _buscarFormatos(
      nombreInmueble: nombreInmueble,
      fechaInicio: fechaInicio,
      fechaFin: fechaFin,
      usuarioCreador: usuarioCreador,
      ubicaciones: ubicaciones,
    );

    if (formatos.isEmpty) {
      throw Exception(
          'No se encontraron formatos que cumplan con los criterios especificados');
    }

    // Paso 2: Analizar los datos usando el módulo específico
    Map<String, dynamic> datosEstadisticos =
        SistemaEstructuralReport.analizarDatos(formatos);

    // Paso 3: Preparar datos para las tablas del reporte
    List<Map<String, dynamic>> tablas =
        SistemaEstructuralReport.prepararTablas(datosEstadisticos);

    // Paso 4: Generar placeholders para gráficas
    List<Uint8List> graficas =
        await SistemaEstructuralReport.generarPlaceholdersGraficas(
            datosEstadisticos);

    // Paso 5: Construir metadatos para el reporte
    Map<String, dynamic> metadatos = {
      'titulo': 'Sistema Estructural',
      'subtitulo': 'Análisis de Elementos Estructurales',
      'totalFormatos': formatos.length,
      'nombreInmueble': nombreInmueble.isEmpty ? 'Todos' : nombreInmueble,
      'fechaInicio': DateFormat('dd/MM/yyyy').format(fechaInicio),
      'fechaFin': DateFormat('dd/MM/yyyy').format(fechaFin),
      'usuarioCreador': usuarioCreador.isEmpty ? 'Todos' : usuarioCreador,
      'ubicaciones': ubicaciones,
      'conclusiones': SistemaEstructuralReport.generarConclusiones(
          datosEstadisticos, formatos.length),
    };

    // Paso 6: Generar documento PDF
    String rutaPDF = await ReporteDocumentalService.generarReportePDF(
      titulo: 'Reporte Estadístico',
      subtitulo: 'Sistema Estructural',
      datos: datosEstadisticos,
      tablas: tablas,
      graficas: graficas,
      metadatos: metadatos,
    );

    return {
      'pdf': rutaPDF,
    };
  }

  /// Prepara las tablas para el reporte de sistema estructural
  List<Map<String, dynamic>> _prepararTablasSistemaEstructural(
      Map<String, dynamic> datosEstadisticos) {
    List<Map<String, dynamic>> tablas = [];

    // Categorías a incluir en el reporte
    final List<Map<String, String>> categorias = [
      {
        'id': 'direccionX',
        'titulo': 'Dirección X',
        'descripcion': 'Elementos estructurales en dirección X'
      },
      {
        'id': 'direccionY',
        'titulo': 'Dirección Y',
        'descripcion': 'Elementos estructurales en dirección Y'
      },
      {
        'id': 'murosMamposteria',
        'titulo': 'Muros de Mampostería',
        'descripcion': 'Tipos de muros de mampostería'
      },
      {
        'id': 'sistemasPiso',
        'titulo': 'Sistemas de Piso',
        'descripcion': 'Tipos de sistemas de piso'
      },
      {
        'id': 'sistemasTecho',
        'titulo': 'Sistemas de Techo',
        'descripcion': 'Tipos de sistemas de techo'
      },
      {
        'id': 'cimentacion',
        'titulo': 'Cimentación',
        'descripcion': 'Tipos de cimentación'
      },
    ];

    // Total de formatos analizados
    int totalFormatos = datosEstadisticos['totalFormatos'];

    // Para cada categoría, crear una tabla
    for (var categoria in categorias) {
      String id = categoria['id']!;

      // Verificar si hay datos para esta categoría
      if (datosEstadisticos['estadisticas'].containsKey(id)) {
        Map<String, dynamic> estadisticasCategoria =
            datosEstadisticos['estadisticas'][id];

        // Crear filas para la tabla
        List<List<dynamic>> filas = [];

        // Ordenar opciones por frecuencia (de mayor a menor)
        var opcionesOrdenadas = estadisticasCategoria.entries.toList()
          ..sort((a, b) =>
              (b.value['conteo'] as int).compareTo(a.value['conteo'] as int));

        for (var opcion in opcionesOrdenadas) {
          String nombreOpcion = opcion.key;
          int conteo = opcion.value['conteo'];
          double porcentaje = opcion.value['porcentaje'];

          filas.add([
            nombreOpcion,
            conteo,
            '${porcentaje.toStringAsFixed(2)}%',
          ]);
        }

        // Si hay filas, agregar la tabla
        if (filas.isNotEmpty) {
          tablas.add({
            'titulo': categoria['titulo'],
            'descripcion': categoria['descripcion'],
            'encabezados': ['Elemento', 'Conteo', 'Porcentaje'],
            'filas': filas,
          });
        }
      }
    }

    return tablas;
  }

  /// Genera gráficas para el reporte de sistema estructural
  Future<List<Uint8List>> _generarGraficasSistemaEstructural(
      Map<String, dynamic> datosEstadisticos) async {
    // En este caso, usamos placeholders para que las gráficas
    // sean creadas directamente en el PDF
    List<Uint8List> graficas = [];

    // Categorías principales para las que generaremos gráficos
    final List<String> categoriasPrincipales = [
      'direccionX',
      'direccionY',
      'murosMamposteria',
      'sistemasPiso',
      'sistemasTecho',
      'cimentacion',
    ];

    // Añadir un placeholder por cada categoría que tenga datos
    for (var categoria in categoriasPrincipales) {
      if (datosEstadisticos['estadisticas'].containsKey(categoria) &&
          datosEstadisticos['estadisticas'][categoria].isNotEmpty) {
        graficas.add(Uint8List(0)); // Placeholder vacío
      }
    }

    return graficas;
  }

  /// Genera conclusiones para el reporte de sistema estructural
  String _generarConclusionesSistemaEstructural(
      Map<String, dynamic> datosEstadisticos, int totalFormatos) {
    StringBuffer conclusiones = StringBuffer();

    // Mensaje inicial
    conclusiones.writeln(
        'Se analizaron un total de $totalFormatos formatos de evaluación para determinar los patrones estructurales predominantes.');

    // Categorías a incluir en las conclusiones
    final List<Map<String, String>> categorias = [
      {'id': 'direccionX', 'nombre': 'Dirección X'},
      {'id': 'direccionY', 'nombre': 'Dirección Y'},
      {'id': 'murosMamposteria', 'nombre': 'Muros de Mampostería'},
      {'id': 'sistemasPiso', 'nombre': 'Sistemas de Piso'},
      {'id': 'sistemasTecho', 'nombre': 'Sistemas de Techo'},
      {'id': 'cimentacion', 'nombre': 'Cimentación'},
    ];

    // Para cada categoría, encontrar el elemento más común
    for (var categoria in categorias) {
      String id = categoria['id']!;
      String nombre = categoria['nombre']!;

      if (datosEstadisticos['estadisticas'].containsKey(id) &&
          datosEstadisticos['estadisticas'][id].isNotEmpty) {
        // Encontrar el elemento más común
        String elementoMasComun = '';
        int maxConteo = 0;
        double maxPorcentaje = 0;

        datosEstadisticos['estadisticas'][id].forEach((elemento, stats) {
          if (stats['conteo'] > maxConteo) {
            maxConteo = stats['conteo'];
            maxPorcentaje = stats['porcentaje'];
            elementoMasComun = elemento;
          }
        });

        if (elementoMasComun.isNotEmpty) {
          conclusiones.writeln(
              '\nEl elemento más común en $nombre fue "$elementoMasComun" con $maxConteo ocurrencias (${maxPorcentaje.toStringAsFixed(2)}% del total).');
        }
      }
    }

    // Conclusión general
    conclusiones.writeln(
        '\nEste reporte proporciona una visión integral de los sistemas estructurales predominantes en los inmuebles evaluados, lo que puede ser útil para identificar patrones de construcción comunes y potenciales vulnerabilidades estructurales en la región.');

    return conclusiones.toString();
  }

  /// Genera un reporte de uso de vivienda y topografía
  Future<Map<String, String>> generarReporteUsoViviendaTopografia({
    required String nombreInmueble,
    required DateTime fechaInicio,
    required DateTime fechaFin,
    required String usuarioCreador,
    required List<Map<String, dynamic>> ubicaciones,
  }) async {
    // Paso 1: Buscar formatos que cumplan con los criterios
    List<FormatoEvaluacion> formatos = await _buscarFormatos(
      nombreInmueble: nombreInmueble,
      fechaInicio: fechaInicio,
      fechaFin: fechaFin,
      usuarioCreador: usuarioCreador,
      ubicaciones: ubicaciones,
    );

    if (formatos.isEmpty) {
      throw Exception(
          'No se encontraron formatos que cumplan con los criterios especificados');
    }

    // Paso 2: Analizar los datos para generar estadísticas
    Map<String, dynamic> datosEstadisticos =
        EstadisticosService.analizarUsoViviendaTopografia(formatos);

    // Paso 3: Preparar datos para las tablas del reporte
    List<Map<String, dynamic>> tablas =
        _prepararTablasParaReporte(datosEstadisticos);

    // Paso 4: Generar gráficas
    List<Uint8List> graficas = await _generarGraficasReporte(datosEstadisticos);

    // Paso 5: Construir metadatos para el reporte
    Map<String, dynamic> metadatos = {
      'titulo': 'Uso de Vivienda',
      'totalFormatos': formatos.length,
      'nombreInmueble': nombreInmueble.isEmpty ? 'Todos' : nombreInmueble,
      'fechaInicio': DateFormat('dd/MM/yyyy').format(fechaInicio),
      'fechaFin': DateFormat('dd/MM/yyyy').format(fechaFin),
      'usuarioCreador': usuarioCreador.isEmpty ? 'Todos' : usuarioCreador,
      'ubicaciones': ubicaciones,
      'conclusiones': _generarConclusiones(datosEstadisticos, formatos.length),
    };

    // Paso 6: Generar documentos PDF y DOCX
    String rutaPDF = await ReporteDocumentalService.generarReportePDF(
      titulo: 'Reporte Estadístico',
      subtitulo: 'Uso de Vivienda y Topografía',
      datos: datosEstadisticos,
      tablas: tablas,
      graficas: graficas,
      metadatos: metadatos,
    );

    /*String rutaDOCX = await ReporteDocumentalService.generarReporteDOCX(
      titulo: 'Reporte Estadístico',
      subtitulo: 'Uso de Vivienda y Topografía',
      datos: datosEstadisticos,
      tablas: tablas,
      graficas: graficas,
      metadatos: metadatos,
    );*/

    return {
      'pdf': rutaPDF,
      //'docx': rutaDOCX,
    };
  }

  /// Genera un reporte de resumen general
  Future<Map<String, String>> generarReporteResumenGeneral({
    required String nombreInmueble,
    required DateTime fechaInicio,
    required DateTime fechaFin,
    required String usuarioCreador,
    required List<Map<String, dynamic>> ubicaciones,
  }) async {
    // Paso 1: Buscar formatos que cumplan con los criterios
    List<FormatoEvaluacion> formatos = await _buscarFormatos(
      nombreInmueble: nombreInmueble,
      fechaInicio: fechaInicio,
      fechaFin: fechaFin,
      usuarioCreador: usuarioCreador,
      ubicaciones: ubicaciones,
    );

    if (formatos.isEmpty) {
      throw Exception(
          'No se encontraron formatos que cumplan con los criterios especificados');
    }

    // Paso 2: Analizar los datos para generar estadísticas de distribución geográfica
    Map<String, dynamic> datosEstadisticos =
        _analizarDistribucionGeografica(formatos);

    // Paso 3: Preparar datos para las tablas del reporte
    List<Map<String, dynamic>> tablas =
        _prepararTablasResumenGeneral(datosEstadisticos, formatos);

    // Paso 4: Generar gráficas
    List<Uint8List> graficas =
        await _generarGraficasResumenGeneral(datosEstadisticos);

    // Paso 5: Construir metadatos para el reporte
    Map<String, dynamic> metadatos = {
      'titulo': 'Resumen General',
      'totalFormatos': formatos.length,
      'nombreInmueble': nombreInmueble.isEmpty ? 'Todos' : nombreInmueble,
      'fechaInicio': DateFormat('dd/MM/yyyy').format(fechaInicio),
      'fechaFin': DateFormat('dd/MM/yyyy').format(fechaFin),
      'usuarioCreador': usuarioCreador.isEmpty ? 'Todos' : usuarioCreador,
      'ubicaciones': ubicaciones,
      'periodoEvaluacion':
          '${DateFormat('MM/yyyy').format(fechaInicio)} - ${DateFormat('MM/yyyy').format(fechaFin)}',
      'areasGeograficas': _obtenerAreasGeograficas(formatos),
      'conclusiones':
          _generarConclusionesResumenGeneral(datosEstadisticos, formatos),
    };

    // Paso 6: Generar documentos PDF y DOCX
    String rutaPDF = await ReporteDocumentalService.generarReportePDF(
      titulo: 'Resumen General de Evaluaciones',
      subtitulo: 'Período: ${metadatos['periodoEvaluacion']}',
      datos: datosEstadisticos,
      tablas: tablas,
      graficas: graficas,
      metadatos: metadatos,
    );

    /*String rutaDOCX = await ReporteDocumentalService.generarReporteDOCX(
      titulo: 'Resumen General de Evaluaciones',
      subtitulo: 'Período: ${metadatos['periodoEvaluacion']}',
      datos: datosEstadisticos,
      tablas: tablas,
      graficas: graficas,
      metadatos: metadatos,
    );*/

    return {
      'pdf': rutaPDF,
      //'docx': rutaDOCX,
    };
  }

  /// Busca formatos según los criterios especificados
  Future<List<FormatoEvaluacion>> _buscarFormatos({
    required String nombreInmueble,
    required DateTime fechaInicio,
    required DateTime fechaFin,
    required String usuarioCreador,
    required List<Map<String, dynamic>> ubicaciones,
  }) async {
    // Lista para almacenar los formatos encontrados
    List<FormatoEvaluacion> formatos = [];

    // Ajustar fechaFin para incluir todo el día
    DateTime fechaFinAjustada = DateTime(
      fechaFin.year,
      fechaFin.month,
      fechaFin.day,
      23,
      59,
      59,
      999,
    );

    // Realizar búsqueda en el servidor
    List<Map<String, dynamic>> resultados = await _cloudService.buscarFormatos(
      nombreInmueble: nombreInmueble,
      fechaCreacionDesde: fechaInicio,
      fechaCreacionHasta: fechaFinAjustada,
      usuarioCreador: usuarioCreador,
    );

    // Para cada resultado, obtener el formato completo
    for (var resultado in resultados) {
      FormatoEvaluacion? formato =
          await _cloudService.obtenerFormatoPorId(resultado['documentId']);
      if (formato != null) {
        // Verificar si cumple con las ubicaciones especificadas
        bool cumpleUbicaciones = _verificarUbicaciones(formato, ubicaciones);
        if (cumpleUbicaciones) {
          formatos.add(formato);
        }
      }
    }

    return formatos;
  }

  /// Verifica si un formato cumple con las ubicaciones especificadas
  bool _verificarUbicaciones(
      FormatoEvaluacion formato, List<Map<String, dynamic>> ubicaciones) {
    // Si no hay ubicaciones especificadas, retornar true
    if (ubicaciones.isEmpty) {
      return true;
    }

    // Verificar cada ubicación
    for (var ubicacion in ubicaciones) {
      String municipio = ubicacion['municipio'] ?? '';
      String ciudad = ubicacion['ciudad'] ?? '';
      String? colonia = ubicacion['colonia'];

      bool cumpleMunicipio = municipio.isEmpty ||
          formato.informacionGeneral.delegacionMunicipio == municipio;

      bool cumpleCiudad =
          ciudad.isEmpty || formato.informacionGeneral.ciudadPueblo == ciudad;

      bool cumpleColonia = colonia == null ||
          colonia.isEmpty ||
          formato.informacionGeneral.colonia == colonia;

      // Si cumple con una ubicación, retornar true
      if (cumpleMunicipio && cumpleCiudad && cumpleColonia) {
        return true;
      }
    }

    // Si no cumple con ninguna ubicación, retornar false
    return false;
  }

  /// Prepara los datos de las tablas para el reporte de uso y topografía
  List<Map<String, dynamic>> _prepararTablasParaReporte(
      Map<String, dynamic> datosEstadisticos) {
    List<Map<String, dynamic>> tablas = [];

    // Tabla de uso de vivienda
    Map<String, Map<String, dynamic>> estadisticasUsos =
        datosEstadisticos['usosVivienda']['estadisticas'];

    if (estadisticasUsos.isNotEmpty) {
      List<List<dynamic>> filasUsos = [];

      estadisticasUsos.forEach((uso, estadisticas) {
        if (estadisticas['conteo'] > 0) {
          filasUsos.add([
            uso,
            estadisticas['conteo'],
            '${((estadisticas['conteo'] / estadisticasUsos.length) * 100).toStringAsFixed(2)}%',
          ]);
        }
      });

      // Ordenar por frecuencia (descendente)
      filasUsos.sort((a, b) => (b[1] as int).compareTo(a[1] as int));

      tablas.add({
        'titulo': 'Uso de Vivienda',
        'descripcion':
            'Distribución de los usos de vivienda en los formatos analizados.',
        'encabezados': ['Uso', 'Conteo', 'Porcentaje'],
        'filas': filasUsos,
      });
    }

    // Tabla de topografía
    Map<String, Map<String, dynamic>> estadisticasTopografia =
        datosEstadisticos['topografia']['estadisticas'];

    if (estadisticasTopografia.isNotEmpty) {
      List<List<dynamic>> filasTopografia = [];

      estadisticasTopografia.forEach((tipo, estadisticas) {
        if (estadisticas['conteo'] > 0) {
          filasTopografia.add([
            tipo,
            estadisticas['conteo'],
            '${((estadisticas['conteo'] / estadisticasTopografia.length) * 100).toStringAsFixed(2)}%',
          ]);
        }
      });

      // Ordenar por frecuencia (descendente)
      filasTopografia.sort((a, b) => (b[1] as int).compareTo(a[1] as int));

      tablas.add({
        'titulo': 'Topografía',
        'descripcion':
            'Distribución de los tipos de topografía en los formatos analizados.',
        'encabezados': ['Tipo de Topografía', 'Conteo', 'Porcentaje'],
        'filas': filasTopografia,
      });
    }

    return tablas;
  }

  /// Genera gráficas para el reporte de uso y topografía
  Future<List<Uint8List>> _generarGraficasReporte(
      Map<String, dynamic> datosEstadisticos) async {
    // En lugar de intentar generar gráficas como Uint8List,
    // vamos a crear placeholders que indiquen que estas gráficas
    // serán creadas directamente en el PDF

    List<Uint8List> graficas = [];

    // Verificar si hay datos de uso de vivienda
    if (datosEstadisticos.containsKey('usosVivienda') &&
        datosEstadisticos['usosVivienda'].containsKey('estadisticas') &&
        datosEstadisticos['usosVivienda']['estadisticas'].isNotEmpty) {
      // Agregar un placeholder para la gráfica de uso de vivienda
      graficas.add(Uint8List(0)); // Placeholder vacío
    }

    // Verificar si hay datos de topografía
    if (datosEstadisticos.containsKey('topografia') &&
        datosEstadisticos['topografia'].containsKey('estadisticas') &&
        datosEstadisticos['topografia']['estadisticas'].isNotEmpty) {
      // Agregar un placeholder para la gráfica de topografía
      graficas.add(Uint8List(0)); // Placeholder vacío
    }

    return graficas;
  }

  /// Genera conclusiones para el reporte de uso y topografía
  String _generarConclusiones(
      Map<String, dynamic> datosEstadisticos, int totalFormatos) {
    StringBuffer conclusiones = StringBuffer();

    conclusiones.writeln(
        'Se analizaron un total de $totalFormatos formatos de evaluación.');

    // Análisis de uso de vivienda
    Map<String, Map<String, dynamic>> estadisticasUsos =
        datosEstadisticos['usosVivienda']['estadisticas'];

    if (estadisticasUsos.isNotEmpty) {
      // Encontrar el uso más común
      String? usoMasComun;
      int maxConteoUso = 0;

      estadisticasUsos.forEach((uso, estadisticas) {
        if (estadisticas['conteo'] > maxConteoUso) {
          maxConteoUso = estadisticas['conteo'];
          usoMasComun = uso;
        }
      });

      if (usoMasComun != null) {
        double porcentajeUsoComun = (maxConteoUso / totalFormatos) * 100;
        conclusiones.writeln(
            '\nEl uso más común fue "$usoMasComun" con $maxConteoUso ocurrencias (${porcentajeUsoComun.toStringAsFixed(2)}% del total).');
      }
    }

    // Análisis de topografía
    Map<String, Map<String, dynamic>> estadisticasTopografia =
        datosEstadisticos['topografia']['estadisticas'];

    if (estadisticasTopografia.isNotEmpty) {
      // Encontrar la topografía más común
      String? topografiaMasComun;
      int maxConteoTopografia = 0;

      estadisticasTopografia.forEach((tipo, estadisticas) {
        if (estadisticas['conteo'] > maxConteoTopografia) {
          maxConteoTopografia = estadisticas['conteo'];
          topografiaMasComun = tipo;
        }
      });

      if (topografiaMasComun != null) {
        double porcentajeTopografiaComun =
            (maxConteoTopografia / totalFormatos) * 100;
        conclusiones.writeln(
            '\nLa topografía más común fue "$topografiaMasComun" con $maxConteoTopografia ocurrencias (${porcentajeTopografiaComun.toStringAsFixed(2)}% del total).');
      }
    }

    // Conclusión general
    conclusiones.writeln(
        '\nEste reporte proporciona una visión general de los patrones de uso y la distribución topográfica de los inmuebles evaluados en el período seleccionado, lo que puede ser útil para la planificación de recursos y la toma de decisiones en futuros proyectos de evaluación estructural.');

    return conclusiones.toString();
  }

  // Métodos para el reporte de Resumen General

  /// Analiza la distribución geográfica de los formatos
  Map<String, dynamic> _analizarDistribucionGeografica(
      List<FormatoEvaluacion> formatos) {
    // Mapas para almacenar conteos por ubicación geográfica
    Map<String, int> conteoColonias = {};
    Map<String, int> conteoCiudades = {};
    Map<String, int> conteoMunicipios = {};
    Map<String, int> conteoEstados = {};

    // Para cada formato, contar las ubicaciones
    for (var formato in formatos) {
      // Obtener datos de ubicación
      String colonia = formato.informacionGeneral.colonia;
      String ciudad = formato.informacionGeneral.ciudadPueblo;
      String municipio = formato.informacionGeneral.delegacionMunicipio;
      String estado = formato.informacionGeneral.estado;

      // Incrementar contadores
      if (colonia.isNotEmpty) {
        conteoColonias[colonia] = (conteoColonias[colonia] ?? 0) + 1;
      }

      if (ciudad.isNotEmpty) {
        conteoCiudades[ciudad] = (conteoCiudades[ciudad] ?? 0) + 1;
      }

      if (municipio.isNotEmpty) {
        conteoMunicipios[municipio] = (conteoMunicipios[municipio] ?? 0) + 1;
      }

      if (estado.isNotEmpty) {
        conteoEstados[estado] = (conteoEstados[estado] ?? 0) + 1;
      }
    }

    // Agrupar por periodos (meses)
    Map<String, int> conteoPorMes = {};

    // Sin necesidad de inicializar datos de localización
    for (var formato in formatos) {
      // Formato MM/yyyy - ejemplo: "05/2025"
      String mesAnio = DateFormat('MM/yyyy').format(formato.fechaCreacion);
      conteoPorMes[mesAnio] = (conteoPorMes[mesAnio] ?? 0) + 1;
    }

    return {
      'distribucionGeografica': {
        'colonias': conteoColonias,
        'ciudades': conteoCiudades,
        'municipios': conteoMunicipios,
        'estados': conteoEstados,
      },
      'distribucionTemporal': {
        'meses': conteoPorMes,
      }
    };
  }

  /// Preparar tablas para el resumen general
  List<Map<String, dynamic>> _prepararTablasResumenGeneral(
      Map<String, dynamic> datosEstadisticos,
      List<FormatoEvaluacion> formatos) {
    List<Map<String, dynamic>> tablas = [];

    // Tabla 1: Resumen total
    tablas.add({
      'titulo': 'Resumen Total de Evaluaciones',
      'descripcion':
          'Cantidad total de inmuebles evaluados en el período seleccionado.',
      'encabezados': ['Descripción', 'Cantidad'],
      'filas': [
        ['Total de inmuebles evaluados', formatos.length],
      ],
    });

    // Tabla 2: Distribución por ciudades
    Map<String, int> conteoCiudades =
        datosEstadisticos['distribucionGeografica']['ciudades'];

    if (conteoCiudades.isNotEmpty) {
      List<List<dynamic>> filasCiudades = [];

      conteoCiudades.forEach((ciudad, conteo) {
        filasCiudades.add([
          ciudad,
          conteo,
          '${((conteo / formatos.length) * 100).toStringAsFixed(2)}%',
        ]);
      });

      // Ordenar por frecuencia (descendente)
      filasCiudades.sort((a, b) => (b[1] as int).compareTo(a[1] as int));

      tablas.add({
        'titulo': 'Distribución por Ciudades',
        'descripcion': 'Cantidad de inmuebles evaluados por ciudad.',
        'encabezados': ['Ciudad', 'Cantidad', 'Porcentaje'],
        'filas': filasCiudades,
      });
    }

    // Tabla 3: Distribución por colonias (limitada a las 10 más frecuentes)
    Map<String, int> conteoColonias =
        datosEstadisticos['distribucionGeografica']['colonias'];

    if (conteoColonias.isNotEmpty) {
      List<List<dynamic>> filasColonias = [];

      conteoColonias.forEach((colonia, conteo) {
        filasColonias.add([
          colonia,
          conteo,
          '${((conteo / formatos.length) * 100).toStringAsFixed(2)}%',
        ]);
      });

      // Ordenar por frecuencia (descendente)
      filasColonias.sort((a, b) => (b[1] as int).compareTo(a[1] as int));

      // Limitar a las 10 más frecuentes
      if (filasColonias.length > 10) {
        filasColonias = filasColonias.sublist(0, 10);
      }

      tablas.add({
        'titulo': 'Distribución por Colonias (Top 10)',
        'descripcion':
            'Las 10 colonias con mayor cantidad de inmuebles evaluados.',
        'encabezados': ['Colonia', 'Cantidad', 'Porcentaje'],
        'filas': filasColonias,
      });
    }

    // Tabla 4: Distribución temporal por meses
    Map<String, int> conteoPorMes =
        datosEstadisticos['distribucionTemporal']['meses'];

    if (conteoPorMes.isNotEmpty) {
      List<List<dynamic>> filasMeses = [];

      conteoPorMes.forEach((mes, conteo) {
        filasMeses.add([
          mes,
          conteo,
          '${((conteo / formatos.length) * 100).toStringAsFixed(2)}%',
        ]);
      });

      // Ordenar por mes (cronológicamente)
      filasMeses.sort((a, b) {
        // Extraer mes y año para ordenar
        List<String> partsA = (a[0] as String).split(' ');
        List<String> partsB = (b[0] as String).split(' ');

        // Si los años son diferentes, ordenar por año
        if (partsA[1] != partsB[1]) {
          return int.parse(partsA[1]).compareTo(int.parse(partsB[1]));
        }

        // Si los años son iguales, ordenar por mes
        List<String> meses = [
          'enero',
          'febrero',
          'marzo',
          'abril',
          'mayo',
          'junio',
          'julio',
          'agosto',
          'septiembre',
          'octubre',
          'noviembre',
          'diciembre'
        ];

        return meses
            .indexOf(partsA[0].toLowerCase())
            .compareTo(meses.indexOf(partsB[0].toLowerCase()));
      });

      tablas.add({
        'titulo': 'Distribución Temporal',
        'descripcion': 'Cantidad de inmuebles evaluados por mes.',
        'encabezados': ['Mes', 'Cantidad', 'Porcentaje'],
        'filas': filasMeses,
      });
    }

    return tablas;
  }

  /// Generar gráficas para el resumen general
  Future<List<Uint8List>> _generarGraficasResumenGeneral(
      Map<String, dynamic> datosEstadisticos) async {
    // Al igual que en el otro método, usamos placeholders para que las gráficas
    // sean generadas directamente en el PDF
    List<Uint8List> graficas = [];

    // Placeholder para gráfica de distribución por ciudades
    if (datosEstadisticos['distribucionGeografica']['ciudades'].isNotEmpty) {
      graficas.add(Uint8List(0));
    }

    // Placeholder para gráfica de distribución por colonia
    if (datosEstadisticos['distribucionGeografica']['colonias'].isNotEmpty) {
      graficas.add(Uint8List(0));
    }

    /*// Placeholder para gráfica de distribución temporal
    if (datosEstadisticos['distribucionTemporal']['meses'].isNotEmpty) {
      graficas.add(Uint8List(0));
    }*/

    return graficas;
  }

  /// Obtener las áreas geográficas cubiertas por las evaluaciones
  String _obtenerAreasGeograficas(List<FormatoEvaluacion> formatos) {
    // Extraer conjuntos únicos de ubicaciones
    Set<String> colonias = {};
    Set<String> ciudades = {};
    Set<String> municipios = {};

    for (var formato in formatos) {
      String colonia = formato.informacionGeneral.colonia;
      String ciudad = formato.informacionGeneral.ciudadPueblo;
      String municipio = formato.informacionGeneral.delegacionMunicipio;

      if (colonia.isNotEmpty) colonias.add(colonia);
      if (ciudad.isNotEmpty) ciudades.add(ciudad);
      if (municipio.isNotEmpty) municipios.add(municipio);
    }

    // Construir una cadena que describa las áreas cubiertas
    StringBuffer areas = StringBuffer();

    if (colonias.isNotEmpty) {
      areas.write('Colonias: ${colonias.join(", ")}');
    }

    if (ciudades.isNotEmpty) {
      if (areas.isNotEmpty) areas.write('\n');
      areas.write('Ciudades: ${ciudades.join(", ")}');
    }

    if (municipios.isNotEmpty) {
      if (areas.isNotEmpty) areas.write('\n');
      areas.write('Municipios: ${municipios.join(", ")}');
    }

    return areas.toString();
  }

  /// Generar conclusiones para el resumen general
  String _generarConclusionesResumenGeneral(
      Map<String, dynamic> datosEstadisticos,
      List<FormatoEvaluacion> formatos) {
    StringBuffer conclusiones = StringBuffer();

    // Información general
    conclusiones.writeln(
        'Se analizaron un total de ${formatos.length} inmuebles en el período seleccionado.');

    // Distribución geográfica
    Map<String, int> conteoCiudades =
        datosEstadisticos['distribucionGeografica']['ciudades'];
    if (conteoCiudades.isNotEmpty) {
      // Encontrar la ciudad con más evaluaciones
      String? ciudadPrincipal;
      int maxCiudad = 0;

      conteoCiudades.forEach((ciudad, conteo) {
        if (conteo > maxCiudad) {
          maxCiudad = conteo;
          ciudadPrincipal = ciudad;
        }
      });

      if (ciudadPrincipal != null) {
        double porcentajeCiudad = (maxCiudad / formatos.length) * 100;
        conclusiones.writeln(
            '\nLa ciudad con mayor cantidad de evaluaciones fue "$ciudadPrincipal" con $maxCiudad inmuebles (${porcentajeCiudad.toStringAsFixed(2)}% del total).');
      }
    }

    // Distribución por colonias
    Map<String, int> conteoColonias =
        datosEstadisticos['distribucionGeografica']['colonias'];
    if (conteoColonias.isNotEmpty) {
      // Encontrar la colonia con más evaluaciones
      String? coloniaPrincipal;
      int maxColonia = 0;

      conteoColonias.forEach((colonia, conteo) {
        if (conteo > maxColonia) {
          maxColonia = conteo;
          coloniaPrincipal = colonia;
        }
      });

      if (coloniaPrincipal != null) {
        double porcentajeColonia = (maxColonia / formatos.length) * 100;
        conclusiones.writeln(
            '\nLa colonia con mayor cantidad de evaluaciones fue "$coloniaPrincipal" con $maxColonia inmuebles (${porcentajeColonia.toStringAsFixed(2)}% del total).');
      }
    }

    // Distribución temporal
    Map<String, int> conteoPorMes =
        datosEstadisticos['distribucionTemporal']['meses'];
    if (conteoPorMes.isNotEmpty) {
      // Encontrar el mes con más evaluaciones
      String? mesPrincipal;
      int maxMes = 0;

      conteoPorMes.forEach((mes, conteo) {
        if (conteo > maxMes) {
          maxMes = conteo;
          mesPrincipal = mes;
        }
      });

      if (mesPrincipal != null) {
        double porcentajeMes = (maxMes / formatos.length) * 100;
        conclusiones.writeln(
            '\nEl mes con mayor actividad de evaluaciones fue "$mesPrincipal" con $maxMes inmuebles evaluados (${porcentajeMes.toStringAsFixed(2)}% del total).');
      }
    }

    // Conclusión general
    conclusiones.writeln(
        '\nEste resumen proporciona una visión general de la distribución geográfica y temporal de las evaluaciones realizadas, lo que puede ser útil para la planificación de recursos y la identificación de áreas que requieren mayor atención en futuros períodos de evaluación.');

    return conclusiones.toString();
  }
}
