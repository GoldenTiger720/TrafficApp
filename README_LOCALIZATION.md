# Traffic App Localization Guide

The Traffic Light Monitor app now supports multiple languages: English (en), Russian (ru), and Polish (pl).

## How Language Selection Works

1. Open the app and navigate to **Settings** by tapping the gear icon
2. Scroll down to the **Appearance** section
3. Find the **Language** dropdown
4. Select your preferred language:
   - English
   - Русский (Russian)
   - Polski (Polish)

## What Gets Translated

When you change the language, all UI elements are immediately updated:

- App titles and navigation
- Settings labels and descriptions
- Button texts
- Status messages
- Notifications and alerts
- Error messages
- Tooltips

## Technical Implementation

The app uses Flutter's built-in localization system:

- Language strings are defined in `lib/l10n/app_localizations.dart`
- The app automatically persists your language choice using SharedPreferences
- Language changes take effect immediately without restarting the app
- The entire UI updates dynamically when the language is changed

## Adding New Languages

To add support for additional languages:

1. Add the language code to the `Language` enum in `app_settings.dart`
2. Add translations for all strings in `app_localizations.dart`
3. Add the locale to `supportedLocales` in `main.dart`
4. Update the language display names in `settings_screen.dart`

## Testing Language Support

1. Launch the app
2. Go to Settings → Appearance → Language
3. Select a different language
4. Verify all text throughout the app updates to the selected language
5. Navigate through different screens to ensure translations are complete
6. Test that the language preference persists after app restart