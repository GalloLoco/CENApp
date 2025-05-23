// lib/data/services/estadisticos_service.dart

import 'dart:math';
import '../../logica/formato_evaluacion.dart';

class EstadisticosService {
  /// Analiza datos del sistema estructural
  static Map<String, dynamic> analizarSistemaEstructural(
      List<FormatoEvaluacion> formatos) {
    // Categorías a analizar en el sistema estructural
    final List<String> categorias = [
      'direccionX',
      'direccionY',
      'murosMamposteria',
      'sistemasPiso',
      'sistemasTecho',
      'cimentacion',
      'vulnerabilidad',
      'posicionManzana',
      'otrasCaracteristicas'
    ];

    // Mapa para almacenar los resultados
    Map<String, Map<String, int>> resultados = {};

    // Inicializar el mapa de resultados para cada categoría
    for (String categoria in categorias) {
      resultados[categoria] = {};
    }

    // Analizar cada formato
    for (var formato in formatos) {
      // Obtener el sistema estructural del formato
      SistemaEstructural sistema = formato.sistemaEstructural;

      // Procesar direccionX
      _contarSelecciones(sistema.direccionX, resultados['direccionX']!);

      // Procesar direccionY
      _contarSelecciones(sistema.direccionY, resultados['direccionY']!);

      // Procesar murosMamposteria
      _contarSelecciones(
          sistema.murosMamposteria, resultados['murosMamposteria']!);

      // Procesar sistemasPiso
      _contarSelecciones(sistema.sistemasPiso, resultados['sistemasPiso']!);

      // Procesar sistemasTecho
      _contarSelecciones(sistema.sistemasTecho, resultados['sistemasTecho']!);

      // Procesar cimentacion
      _contarSelecciones(sistema.cimentacion, resultados['cimentacion']!);

      // Procesar vulnerabilidad
      _contarSelecciones(sistema.vulnerabilidad, resultados['vulnerabilidad']!);

      // Procesar posicionManzana
      _contarSelecciones(
          sistema.posicionManzana, resultados['posicionManzana']!);

      // Procesar otrasCaracteristicas
      _contarSelecciones(
          sistema.otrasCaracteristicas, resultados['otrasCaracteristicas']!);
    }

    // Calcular estadísticas para cada categoría
    Map<String, Map<String, dynamic>> estadisticas = {};

    for (String categoria in categorias) {
      estadisticas[categoria] = {};
      
      // 📊 Calcular el TOTAL de selecciones para esta categoría
      int totalSeleccionesCategoria = resultados[categoria]!.values
          .fold(0, (sum, conteo) => sum + conteo);
      
      // Si no hay selecciones en esta categoría, usar el total de formatos como base
      int baseCalculo = totalSeleccionesCategoria > 0 
          ? totalSeleccionesCategoria 
          : formatos.length;

      // Para cada opción dentro de la categoría, calcular estadísticas corregidas
      resultados[categoria]!.forEach((opcion, conteo) {
        // ✅ PORCENTAJE CORRECTO: conteo / total de selecciones de la categoría
        double porcentajeRelativo = baseCalculo > 0 
            ? (conteo / baseCalculo) * 100 
            : 0.0;
        
        // 📈 PORCENTAJE ABSOLUTO: conteo / total de formatos analizados
        double porcentajeAbsoluto = formatos.isNotEmpty 
            ? (conteo / formatos.length) * 100 
            : 0.0;

        estadisticas[categoria]![opcion] = {
          'conteo': conteo,
          'porcentaje': porcentajeRelativo,           // Relativo a la categoría
          'porcentajeAbsoluto': porcentajeAbsoluto,   // Relativo al total de formatos
          'totalCategoria': totalSeleccionesCategoria,
        };
      });
    }

    return {
      'resultados': resultados,
      'estadisticas': estadisticas,
      'totalFormatos': formatos.length,
    };
  }

  /// Método auxiliar para contar las selecciones en un mapa de opciones
  static void _contarSelecciones(
      Map<String, bool> opciones, Map<String, int> resultados) {
    opciones.forEach((opcion, seleccionado) {
      if (seleccionado) {
        resultados[opcion] = (resultados[opcion] ?? 0) + 1;
      }
    });
  }

  /// Calcula estadísticas de una lista de valores
  static Map<String, dynamic> calcularEstadisticas(List<dynamic> valores) {
    if (valores.isEmpty) {
      return {
        'conteo': 0,
        'frecuencias': {},
        'media': 0.0,
        'mediana': 0.0,
        'moda': null,
        'rango': 0.0,
        'varianza': 0.0,
        'desviacionEstandar': 0.0,
      };
    }

    // Calcular frecuencias
    Map<dynamic, int> frecuencias = {};
    for (var valor in valores) {
      if (valor != null) {
        frecuencias[valor] = (frecuencias[valor] ?? 0) + 1;
      }
    }

    // Calcular moda (valor más repetido)
    dynamic moda;
    int maxFrecuencia = 0;
    frecuencias.forEach((valor, frecuencia) {
      if (frecuencia > maxFrecuencia) {
        maxFrecuencia = frecuencia;
        moda = valor;
      }
    });

    // Para valores numéricos, calcular estadísticas adicionales
    if (valores.first is num) {
      List<num> valoresNumericos = valores.cast<num>().toList();

      // Ordenar para cálculo de mediana
      valoresNumericos.sort();

      // Cálculo de la media
      double suma = valoresNumericos.fold(0, (prev, curr) => prev + curr);
      double media = suma / valoresNumericos.length;

      // Cálculo de la mediana
      double mediana;
      if (valoresNumericos.length % 2 == 0) {
        // Promedio de los dos elementos centrales
        int mitad = valoresNumericos.length ~/ 2;
        mediana = (valoresNumericos[mitad - 1] + valoresNumericos[mitad]) / 2;
      } else {
        // Elemento central
        mediana = valoresNumericos[valoresNumericos.length ~/ 2].toDouble();
      }

      // Cálculo del rango
      double rango =
          (valoresNumericos.last - valoresNumericos.first).toDouble();

      // Cálculo de la varianza
      double sumCuadrados = valoresNumericos.fold(
          0.0, (prev, curr) => prev + pow(curr - media, 2));
      double varianza = sumCuadrados / valoresNumericos.length;

      // Cálculo de la desviación estándar
      double desviacionEstandar = sqrt(varianza);

      return {
        'conteo': valores.length,
        'frecuencias': frecuencias,
        'media': media,
        'mediana': mediana,
        'moda': moda,
        'rango': rango,
        'varianza': varianza,
        'desviacionEstandar': desviacionEstandar,
      };
    } else {
      // Para valores no numéricos, solo retornamos conteo, frecuencias y moda
      return {
        'conteo': valores.length,
        'frecuencias': frecuencias,
        'moda': moda,
      };
    }
  }

  /// Analiza datos específicamente para uso de vivienda y topografía
  static Map<String, dynamic> analizarUsoViviendaTopografia(
      List<FormatoEvaluacion> formatos) {
    // Extraer usos de vivienda
    Map<String, List<dynamic>> usosVivienda = _extraerUsosVivienda(formatos);

    // Extraer topografía
    Map<String, List<dynamic>> topografia = _extraerTopografia(formatos);

    // Calcular estadísticas para cada categoría de uso de vivienda
    Map<String, Map<String, dynamic>> estadisticasUsos = {};
    usosVivienda.forEach((uso, valores) {
      estadisticasUsos[uso] = calcularEstadisticas(valores);
    });

    // Calcular estadísticas para cada categoría de topografía
    Map<String, Map<String, dynamic>> estadisticasTopografia = {};
    topografia.forEach((tipo, valores) {
      estadisticasTopografia[tipo] = calcularEstadisticas(valores);
    });

    return {
      'usosVivienda': {
        'datos': usosVivienda,
        'estadisticas': estadisticasUsos,
      },
      'topografia': {
        'datos': topografia,
        'estadisticas': estadisticasTopografia,
      },
    };
  }

  /// Extrae datos de uso de vivienda de los formatos
  static Map<String, List<dynamic>> _extraerUsosVivienda(
      List<FormatoEvaluacion> formatos) {
    Map<String, List<dynamic>> usos = {};

    // Categorías de uso predefinidas
    List<String> categoriasUso = [
      'Vivienda',
      'Hospital',
      'Oficinas',
      'Iglesia',
      'Comercio',
      'Reunión (cine/estadio/salón)',
      'Escuela',
      'Industrial (fábrica/bodega)',
      'Desocupada',
    ];

    // Inicializar categorías
    for (var categoria in categoriasUso) {
      usos[categoria] = [];
    }

    // Extraer datos
    for (var formato in formatos) {
      // Obtener valores booleanos de usos
      Map<String, bool> usosFormato = formato.informacionGeneral.usos;

      // Llenar listas por categoría
      for (var categoria in categoriasUso) {
        if (usosFormato.containsKey(categoria) &&
            usosFormato[categoria] == true) {
          usos[categoria]!
              .add(1); // Agregamos 1 para poder calcular estadísticas numéricas
        }
      }

      // Manejar "Otro uso" si existe
      if (formato.informacionGeneral.otroUso.isNotEmpty) {
        String otroUso = formato.informacionGeneral.otroUso;
        if (!usos.containsKey(otroUso)) {
          usos[otroUso] = [];
        }
        usos[otroUso]!.add(1);
      }
    }

    return usos;
  }

  /// Extrae datos de topografía de los formatos
  static Map<String, List<dynamic>> _extraerTopografia(
      List<FormatoEvaluacion> formatos) {
    Map<String, List<dynamic>> topografia = {};

    // Categorías de topografía predefinidas
    List<String> categoriasTopografia = [
      'Planicie',
      'Fondo de valle',
      'Ladera de cerro',
      'Depósitos lacustres',
      'Rivera río/lago',
      'Costa',
    ];

    // Inicializar categorías
    for (var categoria in categoriasTopografia) {
      topografia[categoria] = [];
    }

    // Extraer datos
    for (var formato in formatos) {
      // Obtener valores booleanos de topografía
      Map<String, bool> topografiaFormato =
          formato.informacionGeneral.topografia;

      // Llenar listas por categoría
      for (var categoria in categoriasTopografia) {
        if (topografiaFormato.containsKey(categoria) &&
            topografiaFormato[categoria] == true) {
          topografia[categoria]!
              .add(1); // Agregamos 1 para poder calcular estadísticas numéricas
        }
      }
    }

    return topografia;
  }
}
