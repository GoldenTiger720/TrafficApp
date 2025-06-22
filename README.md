# Traffic Light Monitor App

A comprehensive Flutter mobile application for receiving and displaying real-time traffic light data from Raspberry Pi devices.

## Features

### 🚦 Main Functionality
- **Real-time data reception** from Raspberry Pi via Wi-Fi or Bluetooth
- **Visual traffic light display** showing current signal color (red/yellow/green)
- **Countdown timer** display when available
- **Road sign recognition** display

### 📱 On-Screen Overlay
- **Draggable floating overlay** that can be moved anywhere on screen
- **Resizable overlay** with adjustable size (pinch or slider)
- **Transparency control** (0%-100%)
- **Always on top** functionality

### ⚙️ Comprehensive Settings
- **Overlay Controls**: Enable/disable, transparency, size, position reset
- **Connection Settings**: Wi-Fi/Bluetooth selection, device discovery, connection testing
- **Notifications**: Sound and vibration alerts for signal changes
- **Appearance**: Light/dark/system theme, minimalistic/advanced display modes
- **Localization**: Support for English, Russian, and Polish languages
- **Developer Options**: Demo mode, manual overlay testing

### 📊 Advanced Features
- **Event logging** with detailed timestamps and event types
- **Export functionality** for debugging and analysis
- **Screenshot capability** for documentation
- **Bug report** feature with automatic log export
- **Demo mode** for testing without hardware connection

## Technology Stack

- **Framework**: Flutter 3.x
- **State Management**: Provider pattern
- **Connectivity**: 
  - Bluetooth Low Energy (flutter_blue_plus)
  - Wi-Fi networking (wifi_iot)
- **Notifications**: Local notifications with sound and vibration
- **Storage**: SharedPreferences for settings persistence
- **Internationalization**: Built-in support for 3 languages

## Architecture

```
lib/
├── models/           # Data models (traffic light state, settings, events)
├── providers/        # State management (traffic light, settings)
├── services/         # Business logic (connection, notifications, logging)
├── screens/          # UI screens (main, settings, event log)
├── widgets/          # Reusable UI components
├── l10n/            # Localization support
└── main.dart        # App entry point
```

## Getting Started

### Prerequisites
- Flutter SDK 3.8.1 or higher
- Android Studio / VS Code
- Android device/emulator or iOS device/simulator

### Installation
1. Clone the repository
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Generate required files:
   ```bash
   dart run build_runner build
   ```
4. Run the app:
   ```bash
   flutter run
   ```

### Permissions Required
- **Bluetooth**: For connecting to Raspberry Pi devices
- **Location**: Required for Bluetooth scanning on Android
- **Notifications**: For signal change alerts
- **Vibration**: For haptic feedback

## Configuration

### Raspberry Pi Setup
The app expects JSON data in the following format:
```json
{
  "color": "red|yellow|green",
  "countdown": 30,
  "signs": ["stop", "yield", "speedLimit"]
}
```

### Supported Connection Methods
1. **Bluetooth**: Direct connection to Raspberry Pi Bluetooth module
2. **Wi-Fi**: TCP/UDP connection over local network

## Features in Detail

### Overlay System
- Fully draggable and resizable overlay
- Maintains position across app restarts
- Transparency and size controls
- Works over other applications

### Event Logging
- Automatic logging of all traffic light changes
- Sign recognition events
- Connection status changes
- User actions and errors
- Export functionality for debugging

### Demo Mode
- Simulates traffic light changes
- Manual color testing
- Useful for development and demonstrations
- No hardware connection required

### Localization
Currently supported languages:
- 🇺🇸 English
- 🇷🇺 Russian (Русский)
- 🇵🇱 Polish (Polski)

## Development

### Code Generation
The app uses code generation for JSON serialization:
```bash
dart run build_runner build --delete-conflicting-outputs
```

### Adding New Languages
1. Add language to `Language` enum in `models/app_settings.dart`
2. Add translations to `l10n/app_localizations.dart`
3. Update `supportedLocales` in `main.dart`

### Testing
Run tests with:
```bash
flutter test
```

## Troubleshooting

### Common Issues
1. **Bluetooth connection fails**: Check permissions and device pairing
2. **Overlay not showing**: Verify overlay is enabled in settings
3. **App crashes on startup**: Clear app data and restart

### Debug Mode
Enable demo mode in settings to test functionality without hardware.

## Hardware Integration

### Raspberry Pi Configuration
For optimal integration with this app, configure your Raspberry Pi to:
1. Enable Bluetooth or Wi-Fi connectivity
2. Send JSON data in the expected format
3. Include traffic light status and any recognized road signs
4. Provide countdown timers when available

### Data Format Examples
```json
// Basic traffic light
{
  "color": "red",
  "countdown": 25,
  "timestamp": "2024-01-15T10:30:00Z"
}

// With road signs
{
  "color": "green", 
  "countdown": 15,
  "signs": ["pedestrianCrossing", "turnLeft"],
  "timestamp": "2024-01-15T10:30:00Z"
}
```