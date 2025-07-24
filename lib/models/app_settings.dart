import 'package:json_annotation/json_annotation.dart';

part 'app_settings.g.dart';

enum ConnectionType { wifi, bluetooth }
enum AppTheme { light, dark, system }
enum Language { en, ru, pl }
enum DisplayMode { minimalistic, advanced }

@JsonSerializable()
class AppSettings {
  final bool overlayEnabled;
  final double overlayTransparency;
  final double overlaySize;
  final double overlayPositionX;
  final double overlayPositionY;
  final ConnectionType connectionType;
  final String? selectedDeviceId;
  final bool soundNotifications;
  final bool vibrationNotifications;
  final AppTheme theme;
  final Language language;
  final DisplayMode displayMode;
  final bool demoMode;
  final int totalDuration;
  final int countdownDuration;

  const AppSettings({
    this.overlayEnabled = false,
    this.overlayTransparency = 0.8,
    this.overlaySize = 1.0,
    this.overlayPositionX = 0.5,
    this.overlayPositionY = 0.5,
    this.connectionType = ConnectionType.wifi,
    this.selectedDeviceId,
    this.soundNotifications = true,
    this.vibrationNotifications = true,
    this.theme = AppTheme.system,
    this.language = Language.en,
    this.displayMode = DisplayMode.advanced,
    this.demoMode = false,
    this.totalDuration = 30,
    this.countdownDuration = 5,
  });

  factory AppSettings.fromJson(Map<String, dynamic> json) =>
      _$AppSettingsFromJson(json);

  Map<String, dynamic> toJson() => _$AppSettingsToJson(this);

  AppSettings copyWith({
    bool? overlayEnabled,
    double? overlayTransparency,
    double? overlaySize,
    double? overlayPositionX,
    double? overlayPositionY,
    ConnectionType? connectionType,
    String? selectedDeviceId,
    bool? soundNotifications,
    bool? vibrationNotifications,
    AppTheme? theme,
    Language? language,
    DisplayMode? displayMode,
    bool? demoMode,
    int? totalDuration,
    int? countdownDuration,
  }) {
    return AppSettings(
      overlayEnabled: overlayEnabled ?? this.overlayEnabled,
      overlayTransparency: overlayTransparency ?? this.overlayTransparency,
      overlaySize: overlaySize ?? this.overlaySize,
      overlayPositionX: overlayPositionX ?? this.overlayPositionX,
      overlayPositionY: overlayPositionY ?? this.overlayPositionY,
      connectionType: connectionType ?? this.connectionType,
      selectedDeviceId: selectedDeviceId ?? this.selectedDeviceId,
      soundNotifications: soundNotifications ?? this.soundNotifications,
      vibrationNotifications: vibrationNotifications ?? this.vibrationNotifications,
      theme: theme ?? this.theme,
      language: language ?? this.language,
      displayMode: displayMode ?? this.displayMode,
      demoMode: demoMode ?? this.demoMode,
      totalDuration: totalDuration ?? this.totalDuration,
      countdownDuration: countdownDuration ?? this.countdownDuration,
    );
  }
}