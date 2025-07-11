# Traffic Light App - Gesture Features Guide

## Overview

The Traffic Light Monitor app now includes intuitive gesture controls for enhanced user experience:

## 🔄 Display Mode Switching

### Long Press on Traffic Light
- **Action**: Long press anywhere on the traffic light (both in main view and overlay)
- **Function**: Toggles between Minimalistic and Advanced display modes
- **Feedback**: Shows a confirmation message with the new mode

### Display Modes:
1. **Minimalistic Mode**: Shows only the traffic light without additional information
2. **Advanced Mode**: Shows traffic light + countdown timer + recognized road signs

## 📱 Full-Screen Detailed View

### Double-Tap Gestures
- **Main Screen**: Double-tap the traffic light widget to open detailed view
- **Floating Overlay**: Double-tap the floating overlay to open detailed view

### Detailed View Features:
- **Large Traffic Light**: Enhanced visual with realistic lighting effects and shadows
- **Comprehensive Status**: Current signal, countdown, connection status, last update time
- **Recognized Signs**: Visual display of detected road signs with icons
- **Demo Controls**: Quick test buttons for red, yellow, green (when demo mode is enabled)
- **Quick Actions**: 
  - Toggle between Minimalistic/Advanced modes
  - Show/Hide overlay
- **Full Screen Experience**: Dark theme optimized for clear visibility

## 🎮 Interaction Examples

### Typical User Flow:
1. **View traffic light** in main screen or overlay
2. **Long press** to quickly switch between minimal/detailed info
3. **Double-tap** to open full-screen view for comprehensive analysis
4. **Use quick actions** in detailed view for immediate settings changes

### Overlay-Specific Behavior:
- **Drag**: Move the overlay around the screen
- **Double-tap**: Open detailed view (only when not actively dragging)
- **Long press**: Switch display mode

## 🌍 Localization Support

All gesture feedback and detailed view content is fully localized in:
- English
- Russian (Русский)
- Polish (Polski)

## ⚙️ Technical Implementation

### Gesture Detection:
- Long press detection with haptic feedback
- Double-tap with proper gesture conflict resolution
- Drag vs tap differentiation for overlay interactions

### Performance:
- Gesture detection doesn't interfere with normal app navigation
- Smooth animations for mode transitions
- Optimized rendering for detailed view

## 🔧 Customization

Users can still use traditional settings menu for:
- Permanent display mode changes
- Overlay position and appearance settings
- Language preferences
- Theme selection

## 📱 Platform Compatibility

These gesture features work on:
- Android devices with touch support
- Various screen sizes and orientations
- Both phone and tablet form factors

## 🎯 User Benefits

1. **Quick Mode Switching**: No need to navigate through settings
2. **Enhanced Visibility**: Full-screen view for detailed analysis
3. **Intuitive Controls**: Natural gesture-based interaction
4. **Accessibility**: Multiple ways to access the same functionality
5. **Efficient Workflow**: Seamless switching between overview and detail modes