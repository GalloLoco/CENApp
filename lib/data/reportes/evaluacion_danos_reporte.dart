// lib/data/reportes/evaluacion_danos_reporte.dart

import 'dart:typed_data';

import 'package:pdf/widgets.dart' as pw;
import '../../logica/formato_evaluacion.dart';

import '../services/graficas_service.dart';

/// Clase para manejar la generación de reportes de evaluación de daños
/// Implementa métodos específicos para analizar daños estructurales
class EvaluacionDanosReport {
  
  /// Analiza un conjunto de formatos para extraer información de daños estructurales
  static Map<String, dynamic> analizarDatos(List<FormatoEvaluacion> formatos) {
    // Inicializar contadores para cada rubro de daños
    Map<String, Map<String, int>> conteosDanos = {
      'geotecnicos': {
        'Grietas en el terreno': 0,
        'Hundimientos': 0,
        'Inclinación del edificio': 0,
      },
      'losas': {
        'Colapso': 0,
        'Grietas máximas': 0,
        'Flecha máxima': 0,
      },
      'sistemaEstructuralDeficiente': {
        'Sistema deficiente': 0,
        'Sistema adecuado': 0,
      },
      'techoPesado': {
        'Techo pesado': 0,
        'Techo ligero': 0,
      },
      'murosDelgados': {
        'Muros sin refuerzo': 0,
        'Muros reforzados': 0,
      },
      'irregularidadPlanta': {
        'Geometría irregular': 0,
        'Geometría regular': 0,
      },
      'nivelDano': {
        'Colapso total': 0,
        'Daño severo': 0,
        'Daño medio': 0,
        'Daño ligero': 0,
        'Sin daño aparente': 0,
      },
    };
    
    // Analizar cada formato
    for (var formato in formatos) {
      _analizarDanosGeotecnicos(formato, conteosDanos['geotecnicos']!);
      _analizarDanosLosas(formato, conteosDanos['losas']!);
      _analizarSistemaEstructuralDeficiente(formato, conteosDanos['sistemaEstructuralDeficiente']!);
      _analizarTechoPesado(formato, conteosDanos['techoPesado']!);
      _analizarMurosDelgados(formato, conteosDanos['murosDelgados']!);
      _analizarIrregularidadPlanta(formato, conteosDanos['irregularidadPlanta']!);
      _analizarNivelDano(formato, conteosDanos['nivelDano']!);
    }
    
    // Calcular estadísticas (porcentajes)
    Map<String, Map<String, Map<String, dynamic>>> estadisticas = {};
    int totalFormatos = formatos.length;
    
    conteosDanos.forEach((rubro, conteos) {
      estadisticas[rubro] = {};
      conteos.forEach((tipo, conteo) {
        double porcentaje = totalFormatos > 0 ? (conteo / totalFormatos) * 100 : 0;
        
        estadisticas[rubro]![tipo] = {
          'conteo': conteo,
          'porcentaje': porcentaje,
        };
      });
    });
    
    return {
      'conteosDanos': conteosDanos,
      'estadisticas': estadisticas,
      'totalFormatos': totalFormatos,
      'resumenRiesgos': _calcularResumenRiesgos(conteosDanos, totalFormatos),
    };
  }
  
  /// Analiza daños geotécnicos de un formato específico
  static void _analizarDanosGeotecnicos(FormatoEvaluacion formato, Map<String, int> conteos) {
    Map<String, bool> geotecnicos = formato.evaluacionDanos.geotecnicos;
    
    // Verificar grietas en el terreno
    if (geotecnicos['Grietas en el terreno'] == true) {
      conteos['Grietas en el terreno'] = conteos['Grietas en el terreno']! + 1;
    }
    
    // Verificar hundimientos
    if (geotecnicos['Hundimientos'] == true) {
      conteos['Hundimientos'] = conteos['Hundimientos']! + 1;
    }
    
    // Verificar inclinación del edificio (consideramos >0% como inclinación significativa)
    if (formato.evaluacionDanos.inclinacionEdificio > 0) {
      conteos['Inclinación del edificio'] = conteos['Inclinación del edificio']! + 1;
    }
  }
  
  /// Analiza daños en losas de un formato específico
  static void _analizarDanosLosas(FormatoEvaluacion formato, Map<String, int> conteos) {
    // Verificar colapso
    if (formato.evaluacionDanos.losasColapso) {
      conteos['Colapso'] = conteos['Colapso']! + 1;
    }
    
    // Verificar grietas máximas (consideramos >5mm como significativo)
    if (formato.evaluacionDanos.losasGrietasMax > 5.0) {
      conteos['Grietas máximas'] = conteos['Grietas máximas']! + 1;
    }
    
    // Verificar flecha máxima (consideramos >2cm como significativo)
    if (formato.evaluacionDanos.losasFlechaMax > 2.0) {
      conteos['Flecha máxima'] = conteos['Flecha máxima']! + 1;
    }
  }
  
  /// Analiza si el sistema estructural es deficiente
  static void _analizarSistemaEstructuralDeficiente(FormatoEvaluacion formato, Map<String, int> conteos) {
    bool esDeficiente = false;
    
    // Elementos deficientes a buscar en Dirección X y Y
    List<String> elementosDeficientes = [
      'Muros de madera, lámina, otros',
      'Muros de adobe o bahareque',
    ];
    
    // Verificar en Dirección X
    for (String elemento in elementosDeficientes) {
      if (formato.sistemaEstructural.direccionX[elemento] == true) {
        esDeficiente = true;
        break;
      }
    }
    
    // Verificar en Dirección Y si no se encontró en X
    if (!esDeficiente) {
      for (String elemento in elementosDeficientes) {
        if (formato.sistemaEstructural.direccionY[elemento] == true) {
          esDeficiente = true;
          break;
        }
      }
    }
    
    if (esDeficiente) {
      conteos['Sistema deficiente'] = conteos['Sistema deficiente']! + 1;
    } else {
      conteos['Sistema adecuado'] = conteos['Sistema adecuado']! + 1;
    }
  }
  
  /// Analiza si el techo es pesado
  static void _analizarTechoPesado(FormatoEvaluacion formato, Map<String, int> conteos) {
    bool techoPesado = false;
    
    // Verificar si tiene teja
    if (formato.sistemaEstructural.sistemasTecho['Teja'] == true) {
      techoPesado = true;
    }
    
    // Verificar si es igual al piso y el piso es losa maciza
    if (formato.sistemaEstructural.sistemasTecho['Igual al piso'] == true &&
        formato.sistemaEstructural.sistemasPiso['Losa maciza'] == true) {
      techoPesado = true;
    }
    
    if (techoPesado) {
      conteos['Techo pesado'] = conteos['Techo pesado']! + 1;
    } else {
      conteos['Techo ligero'] = conteos['Techo ligero']! + 1;
    }
  }
  
  /// Analiza si los muros son delgados o sin refuerzo
  static void _analizarMurosDelgados(FormatoEvaluacion formato, Map<String, int> conteos) {
    bool murosSinRefuerzo = false;
    
    // Materiales que consideramos como muros delgados
    List<String> materialesDelgados = [
      'Tabique arcilla (ladrillo)',
      'Tabique hueco de arcilla',
      'Bloque concreto 20x40 cm',
      'Tabicón de concreto',
    ];
    
    // Verificar si tiene materiales delgados
    bool tieneMaterialDelgado = false;
    for (String material in materialesDelgados) {
      if (formato.sistemaEstructural.murosMamposteria[material] == true) {
        tieneMaterialDelgado = true;
        break;
      }
    }
    
    // Si tiene material delgado, verificar si NO tiene refuerzo
    if (tieneMaterialDelgado) {
      bool tieneRefuerzo = formato.sistemaEstructural.direccionX['Muros confinados'] == true ||
                          formato.sistemaEstructural.direccionX['Refuerzo interior'] == true ||
                          formato.sistemaEstructural.direccionY['Muros confinados'] == true ||
                          formato.sistemaEstructural.direccionY['Refuerzo interior'] == true;
      
      if (!tieneRefuerzo) {
        murosSinRefuerzo = true;
      }
    }
    
    if (murosSinRefuerzo) {
      conteos['Muros sin refuerzo'] = conteos['Muros sin refuerzo']! + 1;
    } else {
      conteos['Muros reforzados'] = conteos['Muros reforzados']! + 1;
    }
  }
  
  /// Analiza irregularidad en planta
  static void _analizarIrregularidadPlanta(FormatoEvaluacion formato, Map<String, int> conteos) {
    // Buscar geometría irregular en vulnerabilidad
    bool esIrregular = false;
    
    // Verificar todas las claves que contengan "irregular" o "geometría"
    formato.sistemaEstructural.vulnerabilidad.forEach((clave, valor) {
      if (valor == true && 
          (clave.toLowerCase().contains('irregular') || 
           clave.toLowerCase().contains('geometría'))) {
        esIrregular = true;
      }
    });
    
    if (esIrregular) {
      conteos['Geometría irregular'] = conteos['Geometría irregular']! + 1;
    } else {
      conteos['Geometría regular'] = conteos['Geometría regular']! + 1;
    }
  }
  
  /// Analiza el nivel de daño de la estructura
  static void _analizarNivelDano(FormatoEvaluacion formato, Map<String, int> conteos) {
    Map<String, bool> nivelDano = formato.evaluacionDanos.nivelDano;
    
    // Verificar en orden de severidad (de mayor a menor)
    if (nivelDano['Colapso total'] == true) {
      conteos['Colapso total'] = conteos['Colapso total']! + 1;
    } else if (nivelDano['Daño severo'] == true) {
      conteos['Daño severo'] = conteos['Daño severo']! + 1;
    } else if (nivelDano['Daño medio'] == true) {
      conteos['Daño medio'] = conteos['Daño medio']! + 1;
    } else if (nivelDano['Daño ligero'] == true) {
      conteos['Daño ligero'] = conteos['Daño ligero']! + 1;
    } else {
      // Si no tiene ningún nivel de daño marcado, asumimos sin daño aparente
      conteos['Sin daño aparente'] = conteos['Sin daño aparente']! + 1;
    }
  }
  
  /// Calcula un resumen de riesgos generales
  static Map<String, dynamic> _calcularResumenRiesgos(Map<String, Map<String, int>> conteosDanos, int totalFormatos) {
    Map<String, dynamic> resumen = {
      'riesgoAlto': 0,
      'riesgoMedio': 0,
      'riesgoBajo': 0,
    };
    
    // Elementos que consideramos de riesgo alto
    int riesgoAlto = conteosDanos['nivelDano']!['Colapso total']! +
                    conteosDanos['nivelDano']!['Daño severo']! +
                    conteosDanos['losas']!['Colapso']!;
    
    // Elementos que consideramos de riesgo medio
    int riesgoMedio = conteosDanos['nivelDano']!['Daño medio']! +
                     conteosDanos['sistemaEstructuralDeficiente']!['Sistema deficiente']! +
                     conteosDanos['murosDelgados']!['Muros sin refuerzo']!;
    
    // Elementos que consideramos de riesgo bajo
    int riesgoBajo = conteosDanos['nivelDano']!['Daño ligero']! +
                    conteosDanos['techoPesado']!['Techo pesado']! +
                    conteosDanos['irregularidadPlanta']!['Geometría irregular']!;
    
    resumen['riesgoAlto'] = riesgoAlto;
    resumen['riesgoMedio'] = riesgoMedio;
    resumen['riesgoBajo'] = riesgoBajo;
    resumen['totalEvaluados'] = totalFormatos;
    
    return resumen;
  }
  
  /// Prepara los datos para las tablas del reporte
  static List<Map<String, dynamic>> prepararTablas(Map<String, dynamic> datosEstadisticos) {
    List<Map<String, dynamic>> tablas = [];
    
    // Definir rubros con sus títulos y descripciones
    final List<Map<String, String>> rubros = [
      {
        'id': 'geotecnicos',
        'titulo': 'Daños Geotécnicos',
        'descripcion': 'Inmuebles que presentan problemas geotécnicos como grietas en terreno, hundimientos o inclinación.',
      },
      {
        'id': 'losas',
        'titulo': 'Daños en Losas',
        'descripcion': 'Inmuebles con daños en losas incluyendo colapso, grietas o flechas significativas.',
      },
      {
        'id': 'sistemaEstructuralDeficiente',
        'titulo': 'Sistema Estructural',
        'descripcion': 'Clasificación de inmuebles según la calidad de su sistema estructural.',
      },
      {
        'id': 'techoPesado',
        'titulo': 'Tipo de Techo',
        'descripcion': 'Clasificación de inmuebles según el peso de su sistema de techo.',
      },
      {
        'id': 'murosDelgados',
        'titulo': 'Refuerzo en Muros',
        'descripcion': 'Inmuebles clasificados según el refuerzo en sus muros de mampostería.',
      },
      {
        'id': 'irregularidadPlanta',
        'titulo': 'Geometría en Planta',
        'descripcion': 'Inmuebles clasificados según la regularidad de su geometría en planta.',
      },
      {
        'id': 'nivelDano',
        'titulo': 'Nivel de Daño Estructural',
        'descripcion': 'Distribución de inmuebles según su nivel de daño estructural general.',
      },
    ];
    
    // Total de formatos analizados
    int totalFormatos = datosEstadisticos['totalFormatos'];
    
    // Para cada rubro, crear una tabla
    for (var rubro in rubros) {
      String id = rubro['id']!;
      
      // Verificar si hay datos para este rubro
      if (datosEstadisticos['estadisticas'].containsKey(id)) {
        Map<String, Map<String, dynamic>> estadisticasRubro = datosEstadisticos['estadisticas'][id];
        
        // Crear filas para la tabla
        List<List<dynamic>> filas = [];
        
        // Ordenar opciones por frecuencia (de mayor a menor)
        var opcionesOrdenadas = estadisticasRubro.entries.toList()
          ..sort((a, b) => (b.value['conteo'] as int).compareTo(a.value['conteo'] as int));
        
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
            'titulo': rubro['titulo'],
            'descripcion': rubro['descripcion'],
            'encabezados': ['Condición', 'Cantidad', 'Porcentaje'],
            'filas': filas,
          });
        }
      }
    }
    
    // Tabla de resumen de riesgos
    Map<String, dynamic> resumenRiesgos = datosEstadisticos['resumenRiesgos'];
    
    tablas.add({
      'titulo': 'Resumen de Niveles de Riesgo',
      'descripcion': 'Clasificación general de inmuebles según su nivel de riesgo estructural.',
      'encabezados': ['Nivel de Riesgo', 'Cantidad', 'Porcentaje'],
      'filas': [
        [
          'Riesgo Alto',
          resumenRiesgos['riesgoAlto'],
          '${((resumenRiesgos['riesgoAlto'] / totalFormatos) * 100).toStringAsFixed(2)}%',
        ],
        [
          'Riesgo Medio',
          resumenRiesgos['riesgoMedio'],
          '${((resumenRiesgos['riesgoMedio'] / totalFormatos) * 100).toStringAsFixed(2)}%',
        ],
        [
          'Riesgo Bajo',
          resumenRiesgos['riesgoBajo'],
          '${((resumenRiesgos['riesgoBajo'] / totalFormatos) * 100).toStringAsFixed(2)}%',
        ],
      ],
    });
    
    return tablas;
  }
  
  /// Genera placeholders para las gráficas que se crearán en el PDF
  static Future<List<Uint8List>> generarPlaceholdersGraficas(Map<String, dynamic> datosEstadisticos) async {
    List<Uint8List> graficas = [];
    
    // Rubros principales para los que generaremos gráficos
    final List<String> rubrosPrincipales = [
      'geotecnicos',
      'losas',
      'sistemaEstructuralDeficiente',
      'techoPesado',
      'murosDelgados',
      'irregularidadPlanta',
      'nivelDano',
    ];
    
    // Añadir un placeholder por cada rubro que tenga datos significativos
    for (var rubro in rubrosPrincipales) {
      if (datosEstadisticos['estadisticas'].containsKey(rubro) &&
          datosEstadisticos['estadisticas'][rubro].isNotEmpty) {
        graficas.add(Uint8List(0)); // Placeholder vacío
      }
    }
    
    // Placeholder adicional para el gráfico de resumen de riesgos
    graficas.add(Uint8List(0));
    
    return graficas;
  }
  
  /// Genera las gráficas para el reporte en formato PDF
  static List<pw.Widget> generarGraficosPDF(Map<String, dynamic> datos) {
    List<pw.Widget> widgets = [];
    
    // Rubros a incluir en los gráficos con sus configuraciones
    final List<Map<String, dynamic>> configuracionRubros = [
      {
        'id': 'geotecnicos',
        'titulo': 'Daños Geotécnicos',
        'tipo': 'barras', // Tipo de gráfico preferido
      },
      {
        'id': 'losas',
        'titulo': 'Daños en Losas',
        'tipo': 'barras',
      },
      {
        'id': 'sistemaEstructuralDeficiente',
        'titulo': 'Calidad del Sistema Estructural',
        'tipo': 'circular',
      },
      {
        'id': 'techoPesado',
        'titulo': 'Tipo de Techo por Peso',
        'tipo': 'circular',
      },
      {
        'id': 'murosDelgados',
        'titulo': 'Refuerzo en Muros',
        'tipo': 'circular',
      },
      {
        'id': 'irregularidadPlanta',
        'titulo': 'Geometría en Planta',
        'tipo': 'circular',
      },
      {
        'id': 'nivelDano',
        'titulo': 'Nivel de Daño Estructural',
        'tipo': 'barras',
      },
    ];
    
    // Para cada rubro, generar su gráfico correspondiente
    for (var config in configuracionRubros) {
      String id = config['id'];
      String titulo = config['titulo'];
      String tipo = config['tipo'];
      
      // Verificar si hay datos para este rubro
      if (datos['estadisticas'].containsKey(id) && 
          datos['estadisticas'][id].isNotEmpty) {
        
        // Convertir los datos al formato esperado por el servicio de gráficas
        Map<String, int> datosGrafico = {};
        datos['estadisticas'][id].forEach((condicion, stats) {
          datosGrafico[condicion] = stats['conteo'];
        });
        
        // Añadir encabezado
        widgets.add(
          pw.Header(
            level: 2,
            text: 'Distribución: $titulo',
            textStyle: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold),
          ),
        );
        
        // Crear el gráfico según el tipo especificado
        
          widgets.add(
            GraficasService.crearGraficoBarrasHorizontalesPDF(
              datos: datosGrafico,
              titulo: 'Frecuencia de $titulo',
              ancho: 500,
              alto: 300,
            ),
          );
        
        
        widgets.add(pw.SizedBox(height: 20));
      }
    }
    
    // Gráfico especial para resumen de riesgos
    if (datos.containsKey('resumenRiesgos')) {
      Map<String, dynamic> resumenRiesgos = datos['resumenRiesgos'];
      
      Map<String, int> datosRiesgo = {
        'Riesgo Alto': resumenRiesgos['riesgoAlto'],
        'Riesgo Medio': resumenRiesgos['riesgoMedio'],
        'Riesgo Bajo': resumenRiesgos['riesgoBajo'],
      };
      
      // Solo mostrar si hay datos significativos
      int totalRiesgos = datosRiesgo.values.fold(0, (sum, val) => sum + val);
      if (totalRiesgos > 0) {
        widgets.add(
          pw.Header(
            level: 1,
            text: 'Resumen General de Riesgos',
            textStyle: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
        );
        
        widgets.add(
          GraficasService.crearGraficoBarrasPDF(
            datos: datosRiesgo,
            titulo: 'Distribución General de Niveles de Riesgo',
            ancho: 500,
            alto: 300,
          ),
        );
        
        widgets.add(pw.SizedBox(height: 20));
      }
    }
    
    return widgets;
  }
  
  /// Genera las conclusiones para el reporte
  static String generarConclusiones(Map<String, dynamic> datosEstadisticos, int totalFormatos) {
    StringBuffer conclusiones = StringBuffer();
    
    // Mensaje inicial
    conclusiones.writeln(
      'Se analizaron un total de $totalFormatos formatos de evaluación para determinar el estado de daños estructurales y condiciones de riesgo.');
    
    // Si no hay formatos analizados
    if (totalFormatos == 0) {
      conclusiones.writeln('\nNo se encontraron formatos que cumplieran con los criterios especificados.');
      return conclusiones.toString();
    }
    
    // Análisis del resumen de riesgos
    Map<String, dynamic> resumenRiesgos = datosEstadisticos['resumenRiesgos'];
    
    int riesgoAlto = resumenRiesgos['riesgoAlto'];
    int riesgoMedio = resumenRiesgos['riesgoMedio'];
    int riesgoBajo = resumenRiesgos['riesgoBajo'];
    
    double porcentajeRiesgoAlto = (riesgoAlto / totalFormatos) * 100;
    double porcentajeRiesgoMedio = (riesgoMedio / totalFormatos) * 100;
    double porcentajeRiesgoBajo = (riesgoBajo / totalFormatos) * 100;
    
    conclusiones.writeln(
      '\nDel total de inmuebles evaluados, ${porcentajeRiesgoAlto.toStringAsFixed(1)}% presenta condiciones de riesgo alto, '
      '${porcentajeRiesgoMedio.toStringAsFixed(1)}% riesgo medio, y ${porcentajeRiesgoBajo.toStringAsFixed(1)}% riesgo bajo.');
    
    // Análisis específico de daños más críticos
    Map<String, int> nivelDano = datosEstadisticos['conteosDanos']['nivelDano'];
    
    if (nivelDano['Colapso total']! > 0) {
      double porcentajeColapso = (nivelDano['Colapso total']! / totalFormatos) * 100;
      conclusiones.writeln(
        '\nSe identificaron ${nivelDano['Colapso total']} inmuebles con colapso total (${porcentajeColapso.toStringAsFixed(1)}%), '
        'requiriendo atención inmediata y posible demolición.');
    }
    
    if (nivelDano['Daño severo']! > 0) {
      double porcentajeSevero = (nivelDano['Daño severo']! / totalFormatos) * 100;
      conclusiones.writeln(
        '\nSe detectaron ${nivelDano['Daño severo']} inmuebles con daño severo (${porcentajeSevero.toStringAsFixed(1)}%), '
        'que requieren refuerzo estructural urgente.');
    }
    
    // Análisis de vulnerabilidades estructurales
    Map<String, int> sistemaDeficiente = datosEstadisticos['conteosDanos']['sistemaEstructuralDeficiente'];
    if (sistemaDeficiente['Sistema deficiente']! > 0) {
      double porcentajeDeficiente = (sistemaDeficiente['Sistema deficiente']! / totalFormatos) * 100;
      conclusiones.writeln(
        '\nEl ${porcentajeDeficiente.toStringAsFixed(1)}% de los inmuebles presenta sistemas estructurales deficientes '
        '(adobe, bahareque, madera), indicando alta vulnerabilidad sísmica.');
    }
    
    // Análisis de problemas geotécnicos
    Map<String, int> geotecnicos = datosEstadisticos['conteosDanos']['geotecnicos'];
    int problemasGeotecnicos = geotecnicos['Grietas en el terreno']! + 
                              geotecnicos['Hundimientos']! + 
                              geotecnicos['Inclinación del edificio']!;
    
    if (problemasGeotecnicos > 0) {
      double porcentajeGeotecnico = (problemasGeotecnicos / totalFormatos) * 100;
      conclusiones.writeln(
        '\nSe detectaron problemas geotécnicos en ${porcentajeGeotecnico.toStringAsFixed(1)}% de los casos, '
        'incluyendo grietas en terreno, hundimientos e inclinaciones de edificios.');
    }
    
    // Recomendaciones generales
    conclusiones.writeln(
      '\nRecomendaciones:');
    
    if (riesgoAlto > 0) {
      conclusiones.writeln(
        '• Priorizar intervención inmediata en inmuebles de riesgo alto');
    }
    
    if (sistemaDeficiente['Sistema deficiente']! > (totalFormatos * 0.3)) {
      conclusiones.writeln(
        '• Implementar programa de refuerzo estructural masivo debido al alto porcentaje de sistemas deficientes');
    }
    
    if (problemasGeotecnicos > (totalFormatos * 0.2)) {
      conclusiones.writeln(
        '• Realizar estudios geotécnicos detallados en la zona debido a la alta incidencia de problemas de suelo');
    }
    
    conclusiones.writeln(
      '• Establecer un programa de monitoreo continuo para inmuebles con daño medio');
    conclusiones.writeln(
      '• Desarrollar planes de evacuación para inmuebles en riesgo alto');
    
    // Conclusión general
    conclusiones.writeln(
      '\nEste reporte proporciona una evaluación integral del estado de daños y riesgos estructurales, '
      'permitiendo priorizar recursos y acciones preventivas para reducir la vulnerabilidad sísmica en la región.');
    
    return conclusiones.toString();
  }
}