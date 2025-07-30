package com.example.traffic_app

import android.content.Intent
import android.net.Uri
import android.os.Build
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.traffic_app/overlay"
    
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "checkOverlayPermission" -> {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                        result.success(Settings.canDrawOverlays(this))
                    } else {
                        result.success(true)
                    }
                }
                "requestOverlayPermission" -> {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M && !Settings.canDrawOverlays(this)) {
                        val intent = Intent(Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                            Uri.parse("package:$packageName"))
                        startActivityForResult(intent, 1000)
                        result.success(true)
                    } else {
                        result.success(false)
                    }
                }
                "startSystemOverlay" -> {
                    val serviceIntent = Intent(this, SystemOverlayService::class.java).apply {
                        putExtra(SystemOverlayService.EXTRA_TRANSPARENCY, call.argument<Double>("transparency")?.toFloat() ?: 0.9f)
                        putExtra(SystemOverlayService.EXTRA_SIZE, call.argument<Double>("size")?.toFloat() ?: 1.0f)
                        putExtra(SystemOverlayService.EXTRA_POSITION_X, call.argument<Double>("positionX")?.toFloat() ?: 0.5f)
                        putExtra(SystemOverlayService.EXTRA_POSITION_Y, call.argument<Double>("positionY")?.toFloat() ?: 0.5f)
                        putExtra(SystemOverlayService.EXTRA_COLOR, call.argument<String>("color") ?: "red")
                        putExtra(SystemOverlayService.EXTRA_COUNTDOWN, call.argument<Int>("countdown") ?: 0)
                    }
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                        startForegroundService(serviceIntent)
                    } else {
                        startService(serviceIntent)
                    }
                    result.success(true)
                }
                "stopSystemOverlay" -> {
                    val serviceIntent = Intent(this, SystemOverlayService::class.java).apply {
                        action = SystemOverlayService.ACTION_STOP_OVERLAY
                    }
                    startService(serviceIntent)
                    result.success(true)
                }
                "updateSystemOverlayState" -> {
                    val color = call.argument<String>("color") ?: "red"
                    val countdown = call.argument<Int>("countdown") ?: 0
                    
                    val updateIntent = Intent(this, SystemOverlayService::class.java).apply {
                        action = SystemOverlayService.ACTION_UPDATE_STATE
                        putExtra(SystemOverlayService.EXTRA_COLOR, color)
                        putExtra(SystemOverlayService.EXTRA_COUNTDOWN, countdown)
                    }
                    startService(updateIntent)
                    result.success(true)
                }
                "updateSystemOverlaySettings" -> {
                    val transparency = call.argument<Double>("transparency")?.toFloat() ?: 0.9f
                    val size = call.argument<Double>("size")?.toFloat() ?: 1.0f
                    val positionX = call.argument<Double>("positionX")?.toFloat() ?: 0.5f
                    val positionY = call.argument<Double>("positionY")?.toFloat() ?: 0.5f
                    
                    val updateIntent = Intent(this, SystemOverlayService::class.java).apply {
                        action = SystemOverlayService.ACTION_UPDATE_SETTINGS
                        putExtra(SystemOverlayService.EXTRA_TRANSPARENCY, transparency)
                        putExtra(SystemOverlayService.EXTRA_SIZE, size)
                        putExtra(SystemOverlayService.EXTRA_POSITION_X, positionX)
                        putExtra(SystemOverlayService.EXTRA_POSITION_Y, positionY)
                    }
                    startService(updateIntent)
                    result.success(true)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }
}