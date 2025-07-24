package com.example.traffic_app

import android.app.*
import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.graphics.PixelFormat
import android.os.Build
import android.os.IBinder
import android.view.*
import android.widget.FrameLayout
import android.widget.ImageView
import android.widget.TextView
import androidx.core.app.NotificationCompat
import kotlin.math.abs

class TrafficLightOverlayService : Service() {
    
    private lateinit var windowManager: WindowManager
    private lateinit var overlayView: View
    private lateinit var params: WindowManager.LayoutParams
    
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
    private var transparency = 0.8f
    private var size = 1.0f
    private var positionX = 0.5f
    private var positionY = 0.5f
    
    companion object {
        const val CHANNEL_ID = "TrafficLightOverlayChannel"
        const val NOTIFICATION_ID = 1
        
        const val ACTION_UPDATE_STATE = "com.example.traffic_app.UPDATE_STATE"
        const val ACTION_UPDATE_SETTINGS = "com.example.traffic_app.UPDATE_SETTINGS"
        const val EXTRA_COLOR = "color"
        const val EXTRA_COUNTDOWN = "countdown"
    }
    
    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()
        windowManager = getSystemService(WINDOW_SERVICE) as WindowManager
    }
    
    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            ACTION_UPDATE_STATE -> {
                currentColor = intent.getStringExtra(EXTRA_COLOR) ?: "red"
                countdownSeconds = intent.getIntExtra(EXTRA_COUNTDOWN, 0)
                updateTrafficLight()
            }
            ACTION_UPDATE_SETTINGS -> {
                transparency = intent.getDoubleExtra("transparency", 0.8).toFloat()
                size = intent.getDoubleExtra("size", 1.0).toFloat()
                positionX = intent.getDoubleExtra("positionX", 0.5).toFloat()
                positionY = intent.getDoubleExtra("positionY", 0.5).toFloat()
                updateOverlaySettings()
            }
            else -> {
                // Get initial settings from intent
                transparency = intent?.getDoubleExtra("transparency", 0.8)?.toFloat() ?: 0.8f
                size = intent?.getDoubleExtra("size", 1.0)?.toFloat() ?: 1.0f
                positionX = intent?.getDoubleExtra("positionX", 0.5)?.toFloat() ?: 0.5f
                positionY = intent?.getDoubleExtra("positionY", 0.5)?.toFloat() ?: 0.5f
                
                startForeground(NOTIFICATION_ID, createNotification())
                createOverlayView()
            }
        }
        return START_STICKY
    }
    
    override fun onBind(intent: Intent?): IBinder? = null
    
    override fun onDestroy() {
        super.onDestroy()
        if (::overlayView.isInitialized) {
            windowManager.removeView(overlayView)
        }
    }
    
    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "Traffic Light Overlay",
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "Traffic light overlay service"
                setShowBadge(false)
            }
            
            val notificationManager = getSystemService(NotificationManager::class.java)
            notificationManager.createNotificationChannel(channel)
        }
    }
    
    private fun createNotification(): Notification {
        val pendingIntent = PendingIntent.getActivity(
            this,
            0,
            packageManager.getLaunchIntentForPackage(packageName),
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        
        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("Traffic Light Overlay")
            .setContentText("Overlay is active")
            .setSmallIcon(android.R.drawable.ic_dialog_info)
            .setContentIntent(pendingIntent)
            .setOngoing(true)
            .build()
    }
    
    private fun createOverlayView() {
        val layoutType = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
        } else {
            WindowManager.LayoutParams.TYPE_PHONE
        }
        
        // Calculate scaled dimensions based on actual content
        val displayMetrics = resources.displayMetrics
        
        // Proportional scaling based on size percentage  
        val additionalScale = 0.5f + (size * 0.4f) // Range: 0.5 to 0.9
        
        // Traffic light container: 120dp width + 8dp padding + 8dp margin = 136dp
        val trafficLightWidth = (120 * displayMetrics.density * size * additionalScale + 16 * displayMetrics.density * size).toInt()
        // Traffic light container: 360dp height + 8dp padding (top+bottom) = 368dp
        val trafficLightHeight = (360 * displayMetrics.density * size * additionalScale + 8 * displayMetrics.density * size).toInt()
        
        // Timer: 80dp width + 8dp margin = 88dp (but timer is centered vertically) - larger scale
        val timerCircleScale = 0.7f + (size * 0.25f) // Range: 0.7 to 0.95
        val timerWidth = (80 * displayMetrics.density * size * additionalScale * timerCircleScale + 8 * displayMetrics.density * size).toInt()
        val timerHeight = (80 * displayMetrics.density * size * additionalScale * timerCircleScale).toInt()
        
        // Total container size: traffic light + timer + root padding
        val rootPadding = (16 * displayMetrics.density * size).toInt() // 8dp padding on both sides
        
        // Ensure timer width is never cut off - add extra padding for timer width
        val timerWidthPadding = (8 * displayMetrics.density * size).toInt() // Extra padding for timer width
        val scaledWidth = trafficLightWidth + timerWidth + timerWidthPadding + rootPadding
        
        // Ensure timer is never hidden - add extra padding for timer
        val timerPadding = (16 * displayMetrics.density * size).toInt() // Extra padding for timer
        val minHeightForTimer = timerHeight + timerPadding
        val scaledHeight = kotlin.math.max(trafficLightHeight, minHeightForTimer) + rootPadding
        
        params = WindowManager.LayoutParams(
            scaledWidth,
            scaledHeight,
            layoutType,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE,
            PixelFormat.TRANSLUCENT
        ).apply {
            gravity = Gravity.TOP or Gravity.START
            x = (positionX).toInt()
            y = (positionY).toInt()
        }
        
        overlayView = LayoutInflater.from(this).inflate(R.layout.overlay_traffic_light, null)
        
        redLight = overlayView.findViewById(R.id.red_light)
        yellowLight = overlayView.findViewById(R.id.yellow_light)
        greenLight = overlayView.findViewById(R.id.green_light)
        timerText = overlayView.findViewById(R.id.timer_text)
        
        // Apply initial settings
        overlayView.alpha = transparency
        // Size is now handled by WindowManager.LayoutParams dimensions
        
        // Scale internal elements based on size
        scaleInternalElements()
        
        updateTrafficLight()
        
        overlayView.setOnTouchListener { _, event ->
            when (event.action) {
                MotionEvent.ACTION_DOWN -> {
                    initialX = params.x
                    initialY = params.y
                    initialTouchX = event.rawX
                    initialTouchY = event.rawY
                    
                    // Check for double tap
                    val currentTime = System.currentTimeMillis()
                    if (currentTime - lastTapTime < DOUBLE_TAP_TIMEOUT) {
                        // Double tap detected, bring app to foreground
                        bringAppToForeground()
                    }
                    lastTapTime = currentTime
                    
                    true
                }
                MotionEvent.ACTION_MOVE -> {
                    params.x = initialX + (event.rawX - initialTouchX).toInt()
                    params.y = initialY + (event.rawY - initialTouchY).toInt()
                    windowManager.updateViewLayout(overlayView, params)
                    true
                }
                else -> false
            }
        }
        
        windowManager.addView(overlayView, params)
    }
    
    private fun updateTrafficLight() {
        if (!::overlayView.isInitialized) return
        
        redLight.setBackgroundResource(
            if (currentColor == "red") R.drawable.light_on_red else R.drawable.light_off
        )
        yellowLight.setBackgroundResource(
            if (currentColor == "yellow") R.drawable.light_on_yellow else R.drawable.light_off
        )
        greenLight.setBackgroundResource(
            if (currentColor == "green") R.drawable.light_on_green else R.drawable.light_off
        )
        
        timerText.text = countdownSeconds.toString()
        timerText.setTextColor(when (currentColor) {
            "red" -> Color.RED
            "yellow" -> Color.YELLOW
            "green" -> Color.GREEN
            else -> Color.WHITE
        })
    }
    
    private fun scaleInternalElements() {
        val displayMetrics = resources.displayMetrics
        
        // Proportional scaling based on size percentage
        // At 100% (size=1.0): additionalScale = 0.9 (slightly smaller)
        // At 30% (size=0.3): additionalScale = 0.5 (much smaller)
        val additionalScale = 0.5f + (size * 0.4f) // Range: 0.5 to 0.9
        
        // Circle scaling also proportional to size
        // At 100%: circleScale = 0.85 (slightly smaller circles)
        // At 30%: circleScale = 0.5 (much smaller circles)
        val circleScale = 0.5f + (size * 0.35f) // Range: 0.5 to 0.85
        
        // Scale traffic light container (first LinearLayout child)
        val rootLayout = overlayView as ViewGroup
        if (rootLayout.childCount > 0) {
            val trafficLightContainer = rootLayout.getChildAt(0) as ViewGroup
            val containerParams = trafficLightContainer.layoutParams
            containerParams.width = (120 * displayMetrics.density * size * additionalScale).toInt()
            containerParams.height = (360 * displayMetrics.density * size * additionalScale).toInt()
            trafficLightContainer.layoutParams = containerParams
        }
        
        // Scale individual traffic lights - make circles smaller
        val lightSize = (100 * displayMetrics.density * size * additionalScale * circleScale).toInt()
        listOf(redLight, yellowLight, greenLight).forEach { light ->
            val lightParams = light.layoutParams
            lightParams.width = lightSize
            lightParams.height = lightSize
            light.layoutParams = lightParams
        }
        
        // Scale timer text - make timer circle larger than other circles
        val timerCircleScale = 0.7f + (size * 0.25f) // Range: 0.7 to 0.95 (larger than circleScale)
        val timerSize = (80 * displayMetrics.density * size * additionalScale * timerCircleScale).toInt()
        val timerParams = timerText.layoutParams
        timerParams.width = timerSize
        timerParams.height = timerSize
        timerText.layoutParams = timerParams
        
        // Scale text size - slightly larger text too
        val textSize = 36 * size * additionalScale * timerCircleScale
        timerText.textSize = textSize
    }
    
    private fun updateOverlaySettings() {
        if (!::overlayView.isInitialized || !::params.isInitialized) return
        
        // Update position
        val displayMetrics = resources.displayMetrics
        params.x = (positionX).toInt()
        params.y = (positionY).toInt()
        
        // Update transparency
        overlayView.alpha = transparency
        
        // Update size by changing layout parameters based on actual content
        // Proportional scaling based on size percentage  
        val additionalScale = 0.5f + (size * 0.4f) // Range: 0.5 to 0.9
        
        // Traffic light container: 120dp width + 8dp padding + 8dp margin = 136dp
        val trafficLightWidth = (120 * displayMetrics.density * size * additionalScale + 16 * displayMetrics.density * size).toInt()
        // Traffic light container: 360dp height + 8dp padding (top+bottom) = 368dp
        val trafficLightHeight = (360 * displayMetrics.density * size * additionalScale + 8 * displayMetrics.density * size).toInt()
        
        // Timer: 80dp width + 8dp margin = 88dp (but timer is centered vertically) - larger scale
        val timerCircleScale = 0.7f + (size * 0.25f) // Range: 0.7 to 0.95
        val timerWidth = (80 * displayMetrics.density * size * additionalScale * timerCircleScale + 8 * displayMetrics.density * size).toInt()
        val timerHeight = (80 * displayMetrics.density * size * additionalScale * timerCircleScale).toInt()
        
        // Total container size: traffic light + timer + root padding
        val rootPadding = (16 * displayMetrics.density * size).toInt() // 8dp padding on both sides
        
        // Ensure timer width is never cut off - add extra padding for timer width
        val timerWidthPadding = (8 * displayMetrics.density * size).toInt() // Extra padding for timer width
        params.width = trafficLightWidth + timerWidth + timerWidthPadding + rootPadding
        
        // Ensure timer is never hidden - add extra padding for timer
        val timerPadding = (16 * displayMetrics.density * size).toInt() // Extra padding for timer
        val minHeightForTimer = timerHeight + timerPadding
        params.height = kotlin.math.max(trafficLightHeight, minHeightForTimer) + rootPadding
        
        // Scale internal elements when size changes
        scaleInternalElements()
        
        // Apply changes
        windowManager.updateViewLayout(overlayView, params)
    }
    
    private fun bringAppToForeground() {
        val launchIntent = packageManager.getLaunchIntentForPackage(packageName)
        launchIntent?.apply {
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_BROUGHT_TO_FRONT)
            startActivity(this)
        }
    }
}