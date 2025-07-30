package com.example.traffic_app

import android.app.*
import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.graphics.PixelFormat
import android.graphics.drawable.GradientDrawable
import android.os.Build
import android.os.IBinder
import android.view.*
import android.widget.FrameLayout
import android.widget.TextView
import androidx.core.app.NotificationCompat
import kotlin.math.min

class SystemOverlayService : Service() {
    
    private lateinit var windowManager: WindowManager
    private var overlayView: View? = null
    private var params: WindowManager.LayoutParams? = null
    
    private var initialX = 0
    private var initialY = 0
    private var initialTouchX = 0f
    private var initialTouchY = 0f
    
    // Double tap detection
    private var lastTapTime = 0L
    private val DOUBLE_TAP_TIMEOUT = 300L
    
    private lateinit var redLight: View
    private lateinit var yellowLight: View
    private lateinit var greenLight: View
    private lateinit var timerText: TextView
    
    private var currentColor = "red"
    private var countdownSeconds = 0
    
    // Settings
    private var transparency = 0.9f
    private var size = 1.0f
    private var positionX = 0.5f
    private var positionY = 0.5f
    
    companion object {
        const val CHANNEL_ID = "SystemOverlayChannel"
        const val NOTIFICATION_ID = 2
        
        const val ACTION_UPDATE_STATE = "com.example.traffic_app.SYSTEM_UPDATE_STATE"
        const val ACTION_UPDATE_SETTINGS = "com.example.traffic_app.SYSTEM_UPDATE_SETTINGS"
        const val ACTION_STOP_OVERLAY = "com.example.traffic_app.SYSTEM_STOP_OVERLAY"
        
        const val EXTRA_COLOR = "color"
        const val EXTRA_COUNTDOWN = "countdown"
        const val EXTRA_TRANSPARENCY = "transparency"
        const val EXTRA_SIZE = "size"
        const val EXTRA_POSITION_X = "positionX"
        const val EXTRA_POSITION_Y = "positionY"
        
        var isServiceRunning = false
    }
    
    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()
        windowManager = getSystemService(WINDOW_SERVICE) as WindowManager
        isServiceRunning = true
    }
    
    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            ACTION_UPDATE_STATE -> {
                currentColor = intent.getStringExtra(EXTRA_COLOR) ?: "red"
                countdownSeconds = intent.getIntExtra(EXTRA_COUNTDOWN, 0)
                updateTrafficLight()
            }
            ACTION_UPDATE_SETTINGS -> {
                transparency = intent.getFloatExtra(EXTRA_TRANSPARENCY, 0.9f)
                size = intent.getFloatExtra(EXTRA_SIZE, 1.0f)
                positionX = intent.getFloatExtra(EXTRA_POSITION_X, 0.5f)
                positionY = intent.getFloatExtra(EXTRA_POSITION_Y, 0.5f)
                updateOverlaySettings()
            }
            ACTION_STOP_OVERLAY -> {
                stopSelf()
            }
            else -> {
                // Get initial settings from intent
                transparency = intent?.getFloatExtra(EXTRA_TRANSPARENCY, 0.9f) ?: 0.9f
                size = intent?.getFloatExtra(EXTRA_SIZE, 1.0f) ?: 1.0f
                positionX = intent?.getFloatExtra(EXTRA_POSITION_X, 0.5f) ?: 0.5f
                positionY = intent?.getFloatExtra(EXTRA_POSITION_Y, 0.5f) ?: 0.5f
                currentColor = intent?.getStringExtra(EXTRA_COLOR) ?: "red"
                countdownSeconds = intent?.getIntExtra(EXTRA_COUNTDOWN, 0) ?: 0
                
                startForeground(NOTIFICATION_ID, createNotification())
                createSystemOverlay()
            }
        }
        return START_STICKY // Restart if killed
    }
    
    override fun onBind(intent: Intent?): IBinder? = null
    
    override fun onDestroy() {
        super.onDestroy()
        removeOverlay()
        isServiceRunning = false
    }
    
    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "System Traffic Light Overlay",
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "System-wide traffic light overlay service"
                setShowBadge(false)
            }
            
            val notificationManager = getSystemService(NotificationManager::class.java)
            notificationManager.createNotificationChannel(channel)
        }
    }
    
    private fun createNotification(): Notification {
        val stopIntent = Intent(this, SystemOverlayService::class.java).apply {
            action = ACTION_STOP_OVERLAY
        }
        val stopPendingIntent = PendingIntent.getService(
            this, 0, stopIntent, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        
        val appIntent = packageManager.getLaunchIntentForPackage(packageName)
        val appPendingIntent = PendingIntent.getActivity(
            this, 0, appIntent, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        
        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("Traffic Light Overlay Active")
            .setContentText("Overlay is showing over other apps")
            .setSmallIcon(android.R.drawable.ic_dialog_info)
            .setContentIntent(appPendingIntent)
            .addAction(android.R.drawable.ic_delete, "Stop Overlay", stopPendingIntent)
            .setOngoing(true)
            .build()
    }
    
    private fun createSystemOverlay() {
        if (overlayView != null) return
        
        val layoutType = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
        } else {
            WindowManager.LayoutParams.TYPE_PHONE
        }
        
        // Calculate scaled dimensions
        val displayMetrics = resources.displayMetrics
        val screenWidth = displayMetrics.widthPixels
        val screenHeight = displayMetrics.heightPixels
        
        // Base dimensions (smaller for system overlay)
        val trafficLightWidth = (80 * size * displayMetrics.density).toInt()
        val trafficLightHeight = (200 * size * displayMetrics.density).toInt()
        val timerWidth = (60 * size * displayMetrics.density).toInt()
        val spacing = (12 * size * displayMetrics.density).toInt()
        val padding = (8 * size * displayMetrics.density).toInt()
        
        val totalWidth = trafficLightWidth + timerWidth + spacing + (padding * 2)
        val totalHeight = trafficLightHeight + (padding * 2)
        
        params = WindowManager.LayoutParams(
            totalWidth,
            totalHeight,
            layoutType,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE,
            PixelFormat.TRANSLUCENT
        ).apply {
            gravity = Gravity.TOP or Gravity.START
            x = (positionX * (screenWidth - totalWidth)).toInt()
            y = (positionY * (screenHeight - totalHeight)).toInt()
        }
        
        overlayView = createOverlayLayout()
        overlayView?.alpha = transparency
        
        setupTouchListener()
        
        try {
            windowManager.addView(overlayView, params)
            updateTrafficLight()
        } catch (e: Exception) {
            android.util.Log.e("SystemOverlay", "Failed to add overlay: ${e.message}")
        }
    }
    
    private fun createOverlayLayout(): View {
        val rootLayout = FrameLayout(this).apply {
            setBackgroundColor(Color.parseColor("#CC000000"))
            setPadding(
                (8 * size * resources.displayMetrics.density).toInt(),
                (8 * size * resources.displayMetrics.density).toInt(),
                (8 * size * resources.displayMetrics.density).toInt(),
                (8 * size * resources.displayMetrics.density).toInt()
            )
        }
        
        // Create traffic light container
        val trafficLightContainer = createTrafficLightView()
        val trafficLightLayoutParams = FrameLayout.LayoutParams(
            (80 * size * resources.displayMetrics.density).toInt(),
            (200 * size * resources.displayMetrics.density).toInt()
        ).apply {
            gravity = Gravity.CENTER_VERTICAL or Gravity.START
            marginEnd = (12 * size * resources.displayMetrics.density).toInt()
        }
        
        // Create timer
        timerText = TextView(this).apply {
            text = countdownSeconds.toString()
            textSize = (20 * size).toFloat()
            setTextColor(Color.WHITE)
            gravity = Gravity.CENTER
            setBackgroundColor(Color.RED)
            setPadding(
                (8 * size * resources.displayMetrics.density).toInt(),
                (8 * size * resources.displayMetrics.density).toInt(),
                (8 * size * resources.displayMetrics.density).toInt(),
                (8 * size * resources.displayMetrics.density).toInt()
            )
        }
        
        val timerLayoutParams = FrameLayout.LayoutParams(
            (60 * size * resources.displayMetrics.density).toInt(),
            (50 * size * resources.displayMetrics.density).toInt()
        ).apply {
            gravity = Gravity.CENTER_VERTICAL or Gravity.END
        }
        
        rootLayout.addView(trafficLightContainer, trafficLightLayoutParams)
        rootLayout.addView(timerText, timerLayoutParams)
        
        return rootLayout
    }
    
    private fun createTrafficLightView(): View {
        val container = FrameLayout(this).apply {
            setBackgroundColor(Color.parseColor("#FF555555"))
        }
        
        val lightSize = (32 * size * resources.displayMetrics.density).toInt()
        val lightMargin = (8 * size * resources.displayMetrics.density).toInt()
        
        // Create three lights
        redLight = View(this).apply {
            background = createCircleDrawable(Color.parseColor("#FF555555"))
        }
        
        yellowLight = View(this).apply {
            background = createCircleDrawable(Color.parseColor("#FF555555"))
        }
        
        greenLight = View(this).apply {
            background = createCircleDrawable(Color.parseColor("#FF555555"))
        }
        
        // Position lights vertically
        val redParams = FrameLayout.LayoutParams(lightSize, lightSize).apply {
            gravity = Gravity.CENTER_HORIZONTAL or Gravity.TOP
            topMargin = lightMargin
        }
        
        val yellowParams = FrameLayout.LayoutParams(lightSize, lightSize).apply {
            gravity = Gravity.CENTER
        }
        
        val greenParams = FrameLayout.LayoutParams(lightSize, lightSize).apply {
            gravity = Gravity.CENTER_HORIZONTAL or Gravity.BOTTOM
            bottomMargin = lightMargin
        }
        
        container.addView(redLight, redParams)
        container.addView(yellowLight, yellowParams)
        container.addView(greenLight, greenParams)
        
        return container
    }
    
    private fun setupTouchListener() {
        overlayView?.setOnTouchListener { _, event ->
            when (event.action) {
                MotionEvent.ACTION_DOWN -> {
                    initialX = params?.x ?: 0
                    initialY = params?.y ?: 0
                    initialTouchX = event.rawX
                    initialTouchY = event.rawY
                    
                    // Check for double tap to open app
                    val currentTime = System.currentTimeMillis()
                    if (currentTime - lastTapTime < DOUBLE_TAP_TIMEOUT) {
                        bringAppToForeground()
                    }
                    lastTapTime = currentTime
                    true
                }
                MotionEvent.ACTION_MOVE -> {
                    params?.let { p ->
                        p.x = initialX + (event.rawX - initialTouchX).toInt()
                        p.y = initialY + (event.rawY - initialTouchY).toInt()
                        
                        // Keep overlay on screen
                        val displayMetrics = resources.displayMetrics
                        p.x = p.x.coerceIn(0, displayMetrics.widthPixels - (overlayView?.width ?: 0))
                        p.y = p.y.coerceIn(0, displayMetrics.heightPixels - (overlayView?.height ?: 0))
                        
                        windowManager.updateViewLayout(overlayView, p)
                    }
                    true
                }
                else -> false
            }
        }
    }
    
    private fun createCircleDrawable(color: Int): GradientDrawable {
        return GradientDrawable().apply {
            shape = GradientDrawable.OVAL
            setColor(color)
        }
    }
    
    private fun updateTrafficLight() {
        val activeColor = when (currentColor) {
            "red" -> Color.RED
            "yellow" -> Color.YELLOW
            "green" -> Color.GREEN
            else -> Color.RED
        }
        
        val inactiveColor = Color.parseColor("#FF555555")
        
        redLight.background = createCircleDrawable(if (currentColor == "red") activeColor else inactiveColor)
        yellowLight.background = createCircleDrawable(if (currentColor == "yellow") activeColor else inactiveColor)
        greenLight.background = createCircleDrawable(if (currentColor == "green") activeColor else inactiveColor)
        
        timerText.text = countdownSeconds.toString()
        timerText.setBackgroundColor(activeColor)
    }
    
    private fun updateOverlaySettings() {
        overlayView?.alpha = transparency
        
        params?.let { p ->
            val displayMetrics = resources.displayMetrics
            val screenWidth = displayMetrics.widthPixels
            val screenHeight = displayMetrics.heightPixels
            
            // Update position
            p.x = (positionX * (screenWidth - (overlayView?.width ?: 0))).toInt()
            p.y = (positionY * (screenHeight - (overlayView?.height ?: 0))).toInt()
            
            windowManager.updateViewLayout(overlayView, p)
        }
    }
    
    private fun removeOverlay() {
        try {
            overlayView?.let { windowManager.removeView(it) }
            overlayView = null
            params = null
        } catch (e: Exception) {
            android.util.Log.e("SystemOverlay", "Failed to remove overlay: ${e.message}")
        }
    }
    
    private fun bringAppToForeground() {
        val launchIntent = packageManager.getLaunchIntentForPackage(packageName)
        launchIntent?.apply {
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_BROUGHT_TO_FRONT)
            startActivity(this)
        }
    }
}