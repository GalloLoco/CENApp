// android/app/src/main/kotlin/com/example/cenapp/MainActivity.kt

package com.example.cenapp

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.media.MediaScannerConnection
import android.content.Context

class MainActivity: FlutterActivity() {
    private val CHANNEL = "cenapp/media_scanner"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "scanFile" -> {
                    val path = call.argument<String>("path")
                    if (path != null) {
                        scanFile(path, result)
                    } else {
                        result.error("INVALID_ARGUMENT", "Path is required", null)
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    /**
     * 🔄 Escanea un archivo específico para que aparezca en la galería
     */
    private fun scanFile(filePath: String, result: MethodChannel.Result) {
        try {
            MediaScannerConnection.scanFile(
                this as Context,
                arrayOf(filePath),
                null
            ) { path, uri ->
                if (uri != null) {
                    println("✅ [NATIVE] MediaScanner éxito: $path")
                    result.success("File scanned successfully: $path")
                } else {
                    println("❌ [NATIVE] MediaScanner falló: $path")
                    result.error("SCAN_FAILED", "Failed to scan file: $path", null)
                }
            }
        } catch (e: Exception) {
            println("❌ [NATIVE] MediaScanner excepción: ${e.message}")
            result.error("SCAN_ERROR", "Error scanning file: ${e.message}", null)
        }
    }
}