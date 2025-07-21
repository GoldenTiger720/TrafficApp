# Google Maps API Setup Instructions

The current Google Maps API key in `android/app/src/main/AndroidManifest.xml` is a placeholder and needs to be replaced with a valid key.

## Current Status
- **API Key**: `AIzaSyD77fP2k9f3p5eXc-HO3h5Bh-P_ZCyeelM` (PLACEHOLDER - NOT VALID)
- **Package Name**: `com.example.traffic_app`
- **Certificate Fingerprint**: `80:89:3F:68:E7:35:C9:60:67:8F:0C:D7:DB:F9:0A:3B:7B:8C:20:DA`
- **Location**: `android/app/src/main/AndroidManifest.xml` (line 59)
- **Error**: Authorization failure - API key doesn't exist or isn't configured

## How to Fix

### 1. Get a Google Maps API Key

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select an existing one
3. Enable the **Maps SDK for Android** API
4. Go to **Credentials** and create an **API Key**
5. Restrict the API key:
   - **Application restrictions**: Select "Android apps"
   - Add package name: `com.example.traffic_app`
   - Add SHA-1 certificate fingerprint: `80:89:3F:68:E7:35:C9:60:67:8F:0C:D7:DB:F9:0A:3B:7B:8C:20:DA`
   - **API restrictions**: Select "Maps SDK for Android"

### 2. Replace the API Key

Edit `android/app/src/main/AndroidManifest.xml` and replace line 55:

```xml
<!-- REPLACE THIS -->
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="AIzaSyD77fP2k9f3p5eXc-HO3h5Bh-P_ZCyeelM" />

<!-- WITH YOUR ACTUAL API KEY -->
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_ACTUAL_API_KEY_HERE" />
```

### 3. Alternative: Use OSM Map

If you don't want to set up Google Maps, you can switch to the OpenStreetMap implementation:

1. In `lib/widgets/app_navigation_scaffold.dart`, change the import from:
   ```dart
   import '../screens/map_screen.dart';
   ```
   to:
   ```dart
   import '../screens/map_screen_osm.dart';
   ```

2. Change the MapScreen reference to MapScreenOSM

## Current Issues

Without a valid API key:
- Maps will not display
- You'll see "Map temporarily unavailable" or loading screens
- Location services may work but map tiles won't load

## Testing

After setting up the API key:
1. Clean and rebuild the app: `flutter clean && flutter build apk`
2. Test location permissions
3. Verify map tiles load properly

## Billing Information

Google Maps API has usage limits:
- First $200/month is free
- After that, you'll be charged per API call
- Set up billing alerts to monitor usage