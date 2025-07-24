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
                "startOverlayService" -> {
                    val serviceIntent = Intent(this, TrafficLightOverlayService::class.java).apply {
                        putExtra("transparency", call.argument<Double>("transparency") ?: 0.8)
                        putExtra("size", call.argument<Double>("size") ?: 1.0)
                        putExtra("positionX", call.argument<Double>("positionX") ?: 0.5)
                        putExtra("positionY", call.argument<Double>("positionY") ?: 0.5)
                    }
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                        startForegroundService(serviceIntent)
                    } else {
                        startService(serviceIntent)
                    }
                    result.success(true)
                }
                "stopOverlayService" -> {
                    val serviceIntent = Intent(this, TrafficLightOverlayService::class.java)
                    stopService(serviceIntent)
                    result.success(true)
                }
                "updateOverlayState" -> {
                    val color = call.argument<String>("color") ?: "red"
                    val countdown = call.argument<Int>("countdown") ?: 0
                    
                    val updateIntent = Intent(this, TrafficLightOverlayService::class.java).apply {
                        action = TrafficLightOverlayService.ACTION_UPDATE_STATE
                        putExtra(TrafficLightOverlayService.EXTRA_COLOR, color)
                        putExtra(TrafficLightOverlayService.EXTRA_COUNTDOWN, countdown)
                    }
                    startService(updateIntent)
                    result.success(true)
                }
                "updateOverlaySettings" -> {
                    val transparency = call.argument<Double>("transparency") ?: 0.8
                    val size = call.argument<Double>("size") ?: 1.0
                    val positionX = call.argument<Double>("positionX") ?: 0.5
                    val positionY = call.argument<Double>("positionY") ?: 0.5
                    
                    val updateIntent = Intent(this, TrafficLightOverlayService::class.java).apply {
                        action = TrafficLightOverlayService.ACTION_UPDATE_SETTINGS
                        putExtra("transparency", transparency)
                        putExtra("size", size)
                        putExtra("positionX", positionX)
                        putExtra("positionY", positionY)
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
