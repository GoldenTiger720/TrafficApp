// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppSettings _$AppSettingsFromJson(Map<String, dynamic> json) => AppSettings(
  overlayEnabled: json['overlayEnabled'] as bool? ?? true,
  overlayTransparency: (json['overlayTransparency'] as num?)?.toDouble() ?? 0.8,
  overlaySize: (json['overlaySize'] as num?)?.toDouble() ?? 1.0,
  overlayPositionX: (json['overlayPositionX'] as num?)?.toDouble() ?? 0.5,
  overlayPositionY: (json['overlayPositionY'] as num?)?.toDouble() ?? 0.5,
  connectionType:
      $enumDecodeNullable(_$ConnectionTypeEnumMap, json['connectionType']) ??
      ConnectionType.wifi,
  selectedDeviceId: json['selectedDeviceId'] as String?,
  soundNotifications: json['soundNotifications'] as bool? ?? true,
  vibrationNotifications: json['vibrationNotifications'] as bool? ?? true,
  theme:
      $enumDecodeNullable(_$AppThemeEnumMap, json['theme']) ?? AppTheme.system,
  language:
      $enumDecodeNullable(_$LanguageEnumMap, json['language']) ?? Language.en,
  displayMode:
      $enumDecodeNullable(_$DisplayModeEnumMap, json['displayMode']) ??
      DisplayMode.advanced,
  demoMode: json['demoMode'] as bool? ?? false,
);

Map<String, dynamic> _$AppSettingsToJson(AppSettings instance) =>
    <String, dynamic>{
      'overlayEnabled': instance.overlayEnabled,
      'overlayTransparency': instance.overlayTransparency,
      'overlaySize': instance.overlaySize,
      'overlayPositionX': instance.overlayPositionX,
      'overlayPositionY': instance.overlayPositionY,
      'connectionType': _$ConnectionTypeEnumMap[instance.connectionType]!,
      'selectedDeviceId': instance.selectedDeviceId,
      'soundNotifications': instance.soundNotifications,
      'vibrationNotifications': instance.vibrationNotifications,
      'theme': _$AppThemeEnumMap[instance.theme]!,
      'language': _$LanguageEnumMap[instance.language]!,
      'displayMode': _$DisplayModeEnumMap[instance.displayMode]!,
      'demoMode': instance.demoMode,
    };

const _$ConnectionTypeEnumMap = {
  ConnectionType.wifi: 'wifi',
  ConnectionType.bluetooth: 'bluetooth',
};

const _$AppThemeEnumMap = {
  AppTheme.light: 'light',
  AppTheme.dark: 'dark',
  AppTheme.system: 'system',
};

const _$LanguageEnumMap = {
  Language.en: 'en',
  Language.ru: 'ru',
  Language.pl: 'pl',
};

const _$DisplayModeEnumMap = {
  DisplayMode.minimalistic: 'minimalistic',
  DisplayMode.advanced: 'advanced',
};
