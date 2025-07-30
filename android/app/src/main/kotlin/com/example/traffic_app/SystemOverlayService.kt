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
        const val ACTION_UPDATE_POSITION = "com.example.traffic_app.SYSTEM_UPDATE_POSITION"
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
            ACTION_UPDATE_POSITION -> {
                positionX = intent.getFloatExtra(EXTRA_POSITION_X, 0.5f)
                positionY = intent.getFloatExtra(EXTRA_POSITION_Y, 0.5f)
                updateOverlayPosition()
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
        
        // Base dimensions with enhanced scaling for 30% size
        val additionalScale = if (size <= 0.3f) 2.0f else (0.4f + (size * 0.6f))
        val effectiveSize = size * additionalScale
        
        val trafficLightWidth = (100 * effectiveSize * displayMetrics.density).toInt()
        val trafficLightHeight = (240 * effectiveSize * displayMetrics.density).toInt()
        val timerWidth = (80 * effectiveSize * displayMetrics.density).toInt()
        val spacing = (16 * effectiveSize * displayMetrics.density).toInt()
        val padding = (12 * effectiveSize * displayMetrics.density).toInt()
        
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
        val additionalScale = if (size <= 0.3f) 2.0f else (0.4f + (size * 0.6f))
        val effectiveSize = size * additionalScale
        
        val rootLayout = FrameLayout(this).apply {
            setBackgroundColor(Color.parseColor("#CC000000"))
            setPadding(
                (12 * effectiveSize * resources.displayMetrics.density).toInt(),
                (12 * effectiveSize * resources.displayMetrics.density).toInt(),
                (12 * effectiveSize * resources.displayMetrics.density).toInt(),
                (12 * effectiveSize * resources.displayMetrics.density).toInt()
            )
        }
        
        // Create traffic light container
        val trafficLightContainer = createTrafficLightView()
        val trafficLightLayoutParams = FrameLayout.LayoutParams(
            (100 * effectiveSize * resources.displayMetrics.density).toInt(),
            (240 * effectiveSize * resources.displayMetrics.density).toInt()
        ).apply {
            gravity = Gravity.CENTER_VERTICAL or Gravity.START
            marginEnd = (16 * effectiveSize * resources.displayMetrics.density).toInt()
        }
        
        // Create timer
        timerText = TextView(this).apply {
            text = countdownSeconds.toString()
            textSize = (24 * effectiveSize).toFloat()
            setTextColor(Color.BLACK)
            gravity = Gravity.CENTER
            setBackgroundColor(Color.RED)
            setPadding(
                (12 * effectiveSize * resources.displayMetrics.density).toInt(),
                (8 * effectiveSize * resources.displayMetrics.density).toInt(),
                (12 * effectiveSize * resources.displayMetrics.density).toInt(),
                (8 * effectiveSize * resources.displayMetrics.density).toInt()
            )
        }
        
        val timerLayoutParams = FrameLayout.LayoutParams(
            (80 * effectiveSize * resources.displayMetrics.density).toInt(),
            (60 * effectiveSize * resources.displayMetrics.density).toInt()
        ).apply {
            gravity = Gravity.CENTER_VERTICAL or Gravity.END
        }
        
        rootLayout.addView(trafficLightContainer, trafficLightLayoutParams)
        rootLayout.addView(timerText, timerLayoutParams)
        
        return rootLayout
    }
    
    private fun createTrafficLightView(): View {
        val additionalScale = if (size <= 0.3f) 2.0f else (0.4f + (size * 0.6f))
        val effectiveSize = size * additionalScale
        
        val container = FrameLayout(this).apply {
            setBackgroundColor(Color.parseColor("#FF888888"))
        }
        
        // Larger light size for better visibility
        val lightSize = (45 * effectiveSize * resources.displayMetrics.density).toInt()
        val containerHeight = (240 * effectiveSize * resources.displayMetrics.density).toInt()
        val verticalPadding = (20 * effectiveSize * resources.displayMetrics.density).toInt()
        val availableHeight = containerHeight - (verticalPadding * 2)
        val spacing = (availableHeight - (lightSize * 3)) / 2
        
        // Create three lights with inactive color initially
        redLight = View(this).apply {
            background = createCircleDrawable(Color.parseColor("#FF333333"))
        }
        
        yellowLight = View(this).apply {
            background = createCircleDrawable(Color.parseColor("#FF333333"))
        }
        
        greenLight = View(this).apply {
            background = createCircleDrawable(Color.parseColor("#FF333333"))
        }
        
        // Position lights vertically with equal spacing
        val redParams = FrameLayout.LayoutParams(lightSize, lightSize).apply {
            gravity = Gravity.CENTER_HORIZONTAL or Gravity.TOP
            topMargin = verticalPadding
        }
        
        val yellowParams = FrameLayout.LayoutParams(lightSize, lightSize).apply {
            gravity = Gravity.CENTER_HORIZONTAL or Gravity.TOP
            topMargin = verticalPadding + lightSize + spacing
        }
        
        val greenParams = FrameLayout.LayoutParams(lightSize, lightSize).apply {
            gravity = Gravity.CENTER_HORIZONTAL or Gravity.TOP
            topMargin = verticalPadding + (lightSize * 2) + (spacing * 2)
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
                        
                        // Update position ratios for persistence
                        val maxX = (displayMetrics.widthPixels - (overlayView?.width ?: 0)).toFloat()
                        val maxY = (displayMetrics.heightPixels - (overlayView?.height ?: 0)).toFloat()
                        
                        positionX = if (maxX > 0) p.x.toFloat() / maxX else 0.5f
                        positionY = if (maxY > 0) p.y.toFloat() / maxY else 0.5f
                        
                        // Ensure ratios are between 0 and 1
                        positionX = positionX.coerceIn(0f, 1f)
                        positionY = positionY.coerceIn(0f, 1f)
                        
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
        
        val inactiveColor = Color.parseColor("#FF333333")
        
        redLight.background = createCircleDrawable(if (currentColor == "red") activeColor else inactiveColor)
        yellowLight.background = createCircleDrawable(if (currentColor == "yellow") activeColor else inactiveColor)
        greenLight.background = createCircleDrawable(if (currentColor == "green") activeColor else inactiveColor)
        
        timerText.text = countdownSeconds.toString()
        timerText.setBackgroundColor(activeColor)
    }
    
    private fun updateOverlaySettings() {
        overlayView?.let { view ->
            // Update transparency smoothly
            view.alpha = transparency
            
            params?.let { p ->
                val displayMetrics = resources.displayMetrics
                val screenWidth = displayMetrics.widthPixels
                val screenHeight = displayMetrics.heightPixels
                
                // Store current absolute position before size changes
                val currentX = p.x
                val currentY = p.y
                
                // Calculate new dimensions with scaling
                val additionalScale = if (size <= 0.3f) 2.0f else (0.4f + (size * 0.6f))
                val effectiveSize = size * additionalScale
                
                val trafficLightWidth = (100 * effectiveSize * displayMetrics.density).toInt()
                val trafficLightHeight = (240 * effectiveSize * displayMetrics.density).toInt()
                val timerWidth = (80 * effectiveSize * displayMetrics.density).toInt()
                val spacing = (16 * effectiveSize * displayMetrics.density).toInt()
                val padding = (12 * effectiveSize * displayMetrics.density).toInt()
                
                val totalWidth = trafficLightWidth + timerWidth + spacing + (padding * 2)
                val totalHeight = trafficLightHeight + (padding * 2)
                
                // Update size
                p.width = totalWidth
                p.height = totalHeight
                
                // Preserve current position, but ensure it stays on screen
                p.x = currentX.coerceIn(0, screenWidth - totalWidth)
                p.y = currentY.coerceIn(0, screenHeight - totalHeight)
                
                // Update position ratios based on actual position for persistence
                val maxX = (screenWidth - totalWidth).toFloat()
                val maxY = (screenHeight - totalHeight).toFloat()
                
                positionX = if (maxX > 0) p.x.toFloat() / maxX else 0.5f
                positionY = if (maxY > 0) p.y.toFloat() / maxY else 0.5f
                
                // Ensure ratios are between 0 and 1
                positionX = positionX.coerceIn(0f, 1f)
                positionY = positionY.coerceIn(0f, 1f)
                
                // Apply layout changes
                windowManager.updateViewLayout(view, p)
                
                // Update child views with new scaling
                updateChildViewSizes(effectiveSize)
            }
        }
    }

    private fun updateOverlayPosition() {
        overlayView?.let { view ->
            params?.let { p ->
                val displayMetrics = resources.displayMetrics
                val screenWidth = displayMetrics.widthPixels
                val screenHeight = displayMetrics.heightPixels
                
                // Update position using stored ratios
                p.x = (positionX * (screenWidth - p.width)).toInt()
                p.y = (positionY * (screenHeight - p.height)).toInt()
                
                // Keep overlay on screen
                p.x = p.x.coerceIn(0, screenWidth - p.width)
                p.y = p.y.coerceIn(0, screenHeight - p.height)
                
                // Apply layout changes
                windowManager.updateViewLayout(view, p)
            }
        }
    }
    
    private fun updateChildViewSizes(effectiveSize: Float) {
        // Update root layout padding
        val rootLayout = overlayView as? FrameLayout
        rootLayout?.setPadding(
            (12 * effectiveSize * resources.displayMetrics.density).toInt(),
            (12 * effectiveSize * resources.displayMetrics.density).toInt(),
            (12 * effectiveSize * resources.displayMetrics.density).toInt(),
            (12 * effectiveSize * resources.displayMetrics.density).toInt()
        )
        
        // Update traffic light container size
        rootLayout?.let { root ->
            val trafficLightContainer = root.getChildAt(0)
            val trafficLightLayoutParams = trafficLightContainer.layoutParams as FrameLayout.LayoutParams
            trafficLightLayoutParams.width = (100 * effectiveSize * resources.displayMetrics.density).toInt()
            trafficLightLayoutParams.height = (240 * effectiveSize * resources.displayMetrics.density).toInt()
            trafficLightLayoutParams.marginEnd = (16 * effectiveSize * resources.displayMetrics.density).toInt()
            trafficLightContainer.layoutParams = trafficLightLayoutParams
            
            // Update timer size and text size
            val timerLayoutParams = timerText.layoutParams as FrameLayout.LayoutParams
            timerLayoutParams.width = (80 * effectiveSize * resources.displayMetrics.density).toInt()
            timerLayoutParams.height = (60 * effectiveSize * resources.displayMetrics.density).toInt()
            timerText.layoutParams = timerLayoutParams
            timerText.textSize = (24 * effectiveSize)
            timerText.setPadding(
                (12 * effectiveSize * resources.displayMetrics.density).toInt(),
                (8 * effectiveSize * resources.displayMetrics.density).toInt(),
                (12 * effectiveSize * resources.displayMetrics.density).toInt(),
                (8 * effectiveSize * resources.displayMetrics.density).toInt()
            )
            
            // Update traffic light sizes
            updateTrafficLightSizes(trafficLightContainer, effectiveSize)
        }
    }
    
    private fun updateTrafficLightSizes(container: View, effectiveSize: Float) {
        val frameContainer = container as? FrameLayout
        frameContainer?.let { frame ->
            val lightSize = (45 * effectiveSize * resources.displayMetrics.density).toInt()
            val containerHeight = (240 * effectiveSize * resources.displayMetrics.density).toInt()
            val verticalPadding = (20 * effectiveSize * resources.displayMetrics.density).toInt()
            val availableHeight = containerHeight - (verticalPadding * 2)
            val spacing = (availableHeight - (lightSize * 3)) / 2
            
            // Update red light
            val redParams = redLight.layoutParams as FrameLayout.LayoutParams
            redParams.width = lightSize
            redParams.height = lightSize
            redParams.topMargin = verticalPadding
            redLight.layoutParams = redParams
            
            // Update yellow light
            val yellowParams = yellowLight.layoutParams as FrameLayout.LayoutParams
            yellowParams.width = lightSize
            yellowParams.height = lightSize
            yellowParams.topMargin = verticalPadding + lightSize + spacing
            yellowLight.layoutParams = yellowParams
            
            // Update green light
            val greenParams = greenLight.layoutParams as FrameLayout.LayoutParams
            greenParams.width = lightSize
            greenParams.height = lightSize
            greenParams.topMargin = verticalPadding + (lightSize * 2) + (spacing * 2)
            greenLight.layoutParams = greenParams
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