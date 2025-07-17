# Google Maps Setup Guide

## Steps to Get Google Maps API Key:

1. **Go to Google Cloud Console**
   - Visit: https://console.cloud.google.com/

2. **Create or Select a Project**
   - Click "Select a project" → "New Project"
   - Name it (e.g., "Traffic App")
   - Click "Create"

3. **Enable Maps SDK for Android**
   - Go to "APIs & Services" → "Library"
   - Search for "Maps SDK for Android"
   - Click on it and press "Enable"

4. **Create API Key**
   - Go to "APIs & Services" → "Credentials"
   - Click "+ CREATE CREDENTIALS" → "API Key"
   - Copy the generated API key

5. **Restrict API Key (Recommended)**
   - Click on the created API key
   - Under "Application restrictions":
     - Select "Android apps"
     - Add your app's SHA-1 fingerprint and package name:
       - Package name: `com.example.traffic_app`
       - SHA-1: `80:89:3F:68:E7:35:C9:60:67:8F:0C:D7:DB:F9:0A:3B:7B:8C:20:DA`
   - Under "API restrictions":
     - Select "Restrict key"
     - Choose "Maps SDK for Android"
   - Click "Save"

## Add API Key to Your App:

1. Open `/android/app/src/main/AndroidManifest.xml`
2. Replace `YOUR_GOOGLE_MAPS_API_KEY_HERE` with your actual API key

## For Development/Testing:

If you want to quickly test without restrictions:
- Use an unrestricted API key temporarily
- Remember to add restrictions before production!

## Troubleshooting:

- Make sure billing is enabled on your Google Cloud project
- Maps SDK for Android has a free tier with generous limits
- Check that the API key is correctly copied (no extra spaces)