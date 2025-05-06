// lib/data/services/export_optimization_service.dart

import 'dart:async';
import 'dart:isolate';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

/// Servicio para optimización de operaciones de exportación
class ExportOptimizationService {
  
  /// Ejecuta una tarea pesada en un isolate separado para no bloquear la UI
  static Future<T> ejecutarEnBackground<T>(
      FutureOr<T> Function() tarea,
      {Duration timeout = const Duration(seconds: 30)}) async {
    
    // En aplicaciones con Flutter web, compute es más apropiado
    if (kIsWeb) {
      return await compute((message) async => await tarea(), null);
    }
    
    // Para dispositivos móviles, usamos Isolate para mejor rendimiento
    final completer = Completer<T>();
    
    // Crear un puerto de recepción para comunicarnos con el isolate
    final receivePort = ReceivePort();
    late Isolate isolate;
    
    // Manejar timeout
    Timer? timer;
    if (timeout != Duration.zero) {
      timer = Timer(timeout, () {
        if (!completer.isCompleted) {
          receivePort.close();
          isolate.kill(priority: Isolate.immediate);
          completer.completeError(
            TimeoutException('La operación ha excedido el tiempo límite de $timeout')
          );
        }
      });
    }
    
    try {
      // Lanzar un nuevo isolate
      isolate = await Isolate.spawn(
        _isolateHandler,
        _IsolateMessage<T>(
          tarea: tarea,
          sendPort: receivePort.sendPort,
        ),
      );
      
      // Manejar los mensajes del isolate
      await for (final message in receivePort) {
        if (message is _IsolateResult<T>) {
          if (message.error != null) {
            completer.completeError(message.error!);
          } else {
            completer.complete(message.result);
          }
          break;
        }
      }
    } catch (e, st) {
      if (!completer.isCompleted) {
        completer.completeError(e, st);
      }
    } finally {
      timer?.cancel();
      receivePort.close();
    }
    
    return completer.future;
  }
  
  /// Optimiza el tamaño de un archivo Excel
  static Future<File> optimizarArchivoExcel(File archivoExcel) async {
    // En una implementación real, aquí aplicaríamos técnicas de optimización
    // como comprimir, eliminar metadatos innecesarios, etc.
    // Para este ejemplo, simplemente devolvemos el archivo original
    return archivoExcel;
  }
  
  /// Libera memoria después de operaciones pesadas
  static Future<void> liberarMemoria() async {
    // En plataformas donde no podemos forzar la liberación de memoria,
    // sugerimos al recolector de basura que ejecute un ciclo
    for (int i = 0; i < 5; i++) {
      await Future.delayed(Duration(milliseconds: 20));
    }
  }
  
  /// Manejador de isolate para ejecutar tareas en segundo plano
  static void _isolateHandler<T>(_IsolateMessage<T> message) async {
    dynamic result;
    dynamic error;
    
    try {
      result = await message.tarea();
    } catch (e) {
      error = e;
    } finally {
      Isolate.exit(
        message.sendPort,
        _IsolateResult<T>(
          result: result,
          error: error,
        ),
      );
    }
  }
}

/// Clase para encapsular mensajes enviados al isolate
class _IsolateMessage<T> {
  final FutureOr<T> Function() tarea;
  final SendPort sendPort;
  
  _IsolateMessage({
    required this.tarea,
    required this.sendPort,
  });
}

/// Clase para encapsular resultados del isolate
class _IsolateResult<T> {
  final T? result;
  final dynamic error;
  
  _IsolateResult({
    this.result,
    this.error,
  });
}