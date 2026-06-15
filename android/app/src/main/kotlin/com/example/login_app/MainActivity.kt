package com.example.login_app

import android.provider.Settings
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val SCREEN_CHANNEL = "com.example.login_app/screen_security"
    private val DEBUG_CHANNEL  = "com.example.login_app/debug_security"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // === Canal existente para FLAG_SECURE ===
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, SCREEN_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "enableProtection" -> {
                        window.setFlags(
                            WindowManager.LayoutParams.FLAG_SECURE,
                            WindowManager.LayoutParams.FLAG_SECURE
                        )
                        result.success(null)
                    }
                    "disableProtection" -> {
                        window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }

        // === NUEVO canal para detectar depuración USB ===
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, DEBUG_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "isUsbDebuggingEnabled" -> {
                        val enabled = Settings.Global.getInt(
                            contentResolver,
                            Settings.Global.ADB_ENABLED,
                            0
                        ) == 1
                        result.success(enabled)
                    }
                    else -> result.notImplemented()
                }
            }
    }
}