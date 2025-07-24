import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../models/app_settings.dart';
import '../providers/settings_provider.dart';
import '../providers/traffic_light_provider.dart';
import '../services/connection_service.dart';
import '../services/event_log_service.dart';
import '../services/overlay_service.dart';
import '../models/traffic_light_state.dart';
import '../l10n/app_localizations.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  List<String> _availableDevices = [];
  bool _isScanning = false;
  bool _hasOverlayPermission = false;

  @override
  void initState() {
    super.initState();
    _checkOverlayPermission();
  }

  Future<void> _checkOverlayPermission() async {
    if (Platform.isAndroid) {
      final hasPermission = await OverlayService.checkOverlayPermission();
      setState(() {
        _hasOverlayPermission = hasPermission;
      });
    } else {
      setState(() {
        _hasOverlayPermission = true;
      });
    }
  }

  Future<void> _requestOverlayPermission() async {
    if (Platform.isAndroid) {
      await OverlayService.requestOverlayPermission();
      // Check again after some delay
      await Future.delayed(const Duration(seconds: 1));
      _checkOverlayPermission();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)?.settings ?? 'Settings'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, child) {
          final settings = settingsProvider.settings;
          
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildSection(
                AppLocalizations.of(context)?.overlaySettings ?? 'Overlay Settings',
                [
                  if (Platform.isAndroid) ...[
                    ListTile(
                      title: Text(AppLocalizations.of(context)?.overlayPermission ?? 'Overlay Permission'),
                      subtitle: Text(_hasOverlayPermission 
                          ? (AppLocalizations.of(context)?.permissionGranted ?? 'Permission granted') 
                          : (AppLocalizations.of(context)?.permissionRequiredForBackgroundOverlay ?? 'Permission required for background overlay')),
                      trailing: _hasOverlayPermission
                          ? const Icon(Icons.check_circle, color: Colors.green)
                          : ElevatedButton(
                              onPressed: _requestOverlayPermission,
                              child: Text(AppLocalizations.of(context)?.grantPermission ?? 'Grant Permission'),
                            ),
                    ),
                  ],
                  _buildSwitchTile(
                    AppLocalizations.of(context)?.enableOverlay ?? 'Enable Overlay',
                    settings.overlayEnabled,
                    (value) => settingsProvider.updateOverlayEnabled(value),
                  ),
                  _buildSliderTile(
                    AppLocalizations.of(context)?.transparency ?? 'Transparency',
                    settings.overlayTransparency,
                    0.0,
                    1.0,
                    (value) => settingsProvider.updateOverlayTransparency(value),
                    valueFormatter: (value) => '${(value * 100).round()}%',
                  ),
                  _buildSliderTile(
                    AppLocalizations.of(context)?.size ?? 'Size',
                    settings.overlaySize,
                    0.5,
                    1.0,
                    (value) => settingsProvider.updateOverlaySize(value),
                    valueFormatter: (value) => '${(value * 100).round()}%',
                  ),
                  ListTile(
                    title: Text(AppLocalizations.of(context)?.resetPosition ?? 'Reset Position'),
                    subtitle: Text(AppLocalizations.of(context)?.moveOverlayToCenter ?? 'Move overlay to center'),
                    trailing: ElevatedButton(
                      onPressed: () => settingsProvider.resetOverlayPosition(),
                      child: Text(AppLocalizations.of(context)?.reset ?? 'Reset'),
                    ),
                  ),
                  ListTile(
                    title: Text(AppLocalizations.of(context)?.resetOverlaySettings ?? 'Reset Overlay Settings'),
                    subtitle: Text(AppLocalizations.of(context)?.resetTransparencySizeAndPosition ?? 'Reset transparency, size, and position'),
                    trailing: ElevatedButton(
                      onPressed: () => _resetOverlaySettings(context, settingsProvider),
                      child: Text(AppLocalizations.of(context)?.resetOverlay ?? 'Reset Overlay'),
                    ),
                  ),
                ],
              ),
              _buildSection(
                AppLocalizations.of(context)?.connectionSettings ?? 'Connection Settings',
                [
                  _buildDropdownTile<ConnectionType>(
                    AppLocalizations.of(context)?.connectionType ?? 'Connection Type',
                    settings.connectionType,
                    ConnectionType.values,
                    (value) => settingsProvider.updateConnectionType(value!),
                    itemBuilder: (type) => Text(type.name.toUpperCase()),
                  ),
                  _buildDeviceSelector(context, settings),
                  ListTile(
                    title: Text(AppLocalizations.of(context)?.testConnection ?? 'Test Connection'),
                    subtitle: Text(_getConnectionStatus(context)),
                    trailing: ElevatedButton(
                      onPressed: _testConnection,
                      child: Text(AppLocalizations.of(context)?.test ?? 'Test'),
                    ),
                  ),
                ],
              ),
              _buildSection(
                AppLocalizations.of(context)?.notifications ?? 'Notifications',
                [
                  _buildSwitchTile(
                    AppLocalizations.of(context)?.soundNotifications ?? 'Sound Notifications',
                    settings.soundNotifications,
                    (value) => settingsProvider.updateSoundNotifications(value),
                  ),
                  _buildSwitchTile(
                    AppLocalizations.of(context)?.vibrationNotifications ?? 'Vibration Notifications',
                    settings.vibrationNotifications,
                    (value) => settingsProvider.updateVibrationNotifications(value),
                  ),
                ],
              ),
              _buildSection(
                AppLocalizations.of(context)?.appearance ?? 'Appearance',
                [
                  _buildDropdownTile<AppTheme>(
                    AppLocalizations.of(context)?.theme ?? 'Theme',
                    settings.theme,
                    AppTheme.values,
                    (value) => settingsProvider.updateTheme(value!),
                    itemBuilder: (theme) => Text(_getThemeDisplayName(theme, context)),
                  ),
                  _buildDropdownTile<Language>(
                    AppLocalizations.of(context)?.language ?? 'Language',
                    settings.language,
                    Language.values,
                    (value) => settingsProvider.updateLanguage(value!),
                    itemBuilder: (lang) => Text(_getLanguageDisplayName(lang)),
                  ),
                  _buildDropdownTile<DisplayMode>(
                    AppLocalizations.of(context)?.displayMode ?? 'Display Mode',
                    settings.displayMode,
                    DisplayMode.values,
                    (value) => settingsProvider.updateDisplayMode(value!),
                    itemBuilder: (mode) => Text(_getDisplayModeDisplayName(mode, context)),
                  ),
                ],
              ),
              _buildSection(
                AppLocalizations.of(context)?.developerOptions ?? 'Developer Options',
                [
                  _buildSwitchTile(
                    AppLocalizations.of(context)?.demoMode ?? 'Demo Mode',
                    settings.demoMode,
                    (value) {
                      settingsProvider.updateDemoMode(value);
                      context.read<TrafficLightProvider>().setDemoMode(value);
                    },
                  ),
                  _buildSliderTile(
                    AppLocalizations.of(context)?.totalDurationSeconds ?? 'Total Duration (seconds)',
                    settings.totalDuration.toDouble(),
                    5.0,
                    60.0,
                    (value) => settingsProvider.updateTotalDuration(value.round()),
                    valueFormatter: (value) => '${value.round()}s',
                  ),
                  _buildSliderTile(
                    AppLocalizations.of(context)?.countdownDurationSeconds ?? 'Countdown Duration (seconds)',
                    settings.countdownDuration.toDouble(),
                    1.0,
                    settings.totalDuration.toDouble().clamp(1.0, 60.0), // Ensure valid range
                    (value) {
                      final newValue = value.round();
                      // Ensure countdown duration doesn't exceed total duration
                      final validValue = newValue.clamp(1, settings.totalDuration);
                      settingsProvider.updateCountdownDuration(validValue);
                    },
                    valueFormatter: (value) => '${value.round()}s',
                  ),
                  ListTile(
                    title: Text(AppLocalizations.of(context)?.resetAllSettings ?? 'Reset All Settings'),
                    subtitle: Text(AppLocalizations.of(context)?.resetAllSettingsToDefaultValues ?? 'Reset all settings to default values'),
                    trailing: ElevatedButton(
                      onPressed: () => _resetSettings(context, settingsProvider),
                      child: Text(AppLocalizations.of(context)?.resetAll ?? 'Reset All'),
                    ),
                  ),
                  _buildTestControls(context),
                ],
              ),
              _buildSection(
                AppLocalizations.of(context)?.dataPrivacy ?? 'Data & Privacy',
                [
                  ListTile(
                    title: Text(AppLocalizations.of(context)?.exportEventLog ?? 'Export Event Log'),
                    subtitle: Text(AppLocalizations.of(context)?.shareEventLogForDebugging ?? 'Share event log for debugging'),
                    trailing: const Icon(Icons.share),
                    onTap: () => _exportEventLog(context),
                  ),
                  ListTile(
                    title: Text(AppLocalizations.of(context)?.clearEventLog ?? 'Clear Event Log'),
                    subtitle: Text(AppLocalizations.of(context)?.deleteAllLoggedEvents ?? 'Delete all logged events'),
                    trailing: const Icon(Icons.delete_outline),
                    onTap: () => _clearEventLog(context),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSwitchTile(String title, bool value, Function(bool) onChanged) {
    return SwitchListTile(
      title: Text(title),
      value: value,
      onChanged: onChanged,
    );
  }

  Widget _buildSliderTile(
    String title,
    double value,
    double min,
    double max,
    Function(double) onChanged, {
    String Function(double)? valueFormatter,
  }) {
    return ListTile(
      title: Text(title),
      subtitle: Column(
        children: [
          Slider(
            value: value,
            min: min,
            max: max,
            onChanged: onChanged,
          ),
          Text(valueFormatter?.call(value) ?? value.toStringAsFixed(2)),
        ],
      ),
    );
  }

  Widget _buildDropdownTile<T>(
    String title,
    T value,
    List<T> items,
    Function(T?) onChanged, {
    required Widget Function(T) itemBuilder,
  }) {
    return ListTile(
      title: Text(title),
      trailing: DropdownButton<T>(
        value: value,
        items: items.map((item) => DropdownMenuItem<T>(
          value: item,
          child: itemBuilder(item),
        )).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildDeviceSelector(BuildContext context, AppSettings settings) {
    return Column(
      children: [
        ListTile(
          title: Text(AppLocalizations.of(context)?.availableDevices ?? 'Available Devices'),
          subtitle: Text(_isScanning 
              ? (AppLocalizations.of(context)?.scanning ?? 'Scanning...') 
              : (AppLocalizations.of(context)?.devicesFound(_availableDevices.length) ?? '${_availableDevices.length} devices found')),
          trailing: IconButton(
            icon: _isScanning ? const CircularProgressIndicator() : const Icon(Icons.refresh),
            onPressed: _isScanning ? null : _scanForDevices,
          ),
        ),
        if (_availableDevices.isNotEmpty)
          ..._availableDevices.map((device) => ListTile(
            title: Text(device),
            leading: Radio<String>(
              value: device,
              groupValue: settings.selectedDeviceId,
              onChanged: (value) => context.read<SettingsProvider>().updateSelectedDevice(value),
            ),
          )),
      ],
    );
  }

  Widget _buildTestControls(BuildContext context) {
    return Column(
      children: [
        const Divider(),
        ListTile(
          title: Text(AppLocalizations.of(context)?.manualOverlayTest ?? 'Manual Overlay Test'),
          subtitle: Text(AppLocalizations.of(context)?.testOverlayColors ?? 'Test overlay colors manually'),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => context.read<TrafficLightProvider>().testOverlay(TrafficLightColor.red),
              child: Text(AppLocalizations.of(context)?.red ?? 'Red', style: const TextStyle(color: Colors.white)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
              onPressed: () => context.read<TrafficLightProvider>().testOverlay(TrafficLightColor.yellow),
              child: Text(AppLocalizations.of(context)?.yellow ?? 'Yellow', style: const TextStyle(color: Colors.black)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              onPressed: () => context.read<TrafficLightProvider>().testOverlay(TrafficLightColor.green),
              child: Text(AppLocalizations.of(context)?.green ?? 'Green', style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  String _getThemeDisplayName(AppTheme theme, BuildContext context) {
    final l10n = AppLocalizations.of(context);
    switch (theme) {
      case AppTheme.light:
        return l10n?.light ?? 'Light';
      case AppTheme.dark:
        return l10n?.dark ?? 'Dark';
      case AppTheme.system:
        return l10n?.system ?? 'System';
    }
  }

  String _getLanguageDisplayName(Language language) {
    switch (language) {
      case Language.en:
        return 'English';
      case Language.ru:
        return 'Русский';
      case Language.pl:
        return 'Polski';
    }
  }

  String _getDisplayModeDisplayName(DisplayMode mode, BuildContext context) {
    final l10n = AppLocalizations.of(context);
    switch (mode) {
      case DisplayMode.minimalistic:
        return l10n?.minimalistic ?? 'Minimalistic';
      case DisplayMode.advanced:
        return l10n?.advanced ?? 'Advanced';
    }
  }

  String _getConnectionStatus(BuildContext context) {
    final isConnected = context.watch<TrafficLightProvider>().isConnected;
    final l10n = AppLocalizations.of(context);
    return isConnected ? (l10n?.connected ?? 'Connected') : (l10n?.disconnected ?? 'Disconnected');
  }

  Future<void> _scanForDevices() async {
    setState(() {
      _isScanning = true;
    });

    try {
      final settings = context.read<SettingsProvider>().settings;
      final connectionService = context.read<ConnectionService>();
      
      List<String> devices = [];
      if (settings.connectionType == ConnectionType.bluetooth) {
        final bluetoothDevices = await connectionService.scanForBluetoothDevices();
        devices = bluetoothDevices.map((d) => d.platformName.isNotEmpty ? d.platformName : 'Unknown Device').toList();
      } else {
        devices = await connectionService.scanForWiFiDevices();
      }

      setState(() {
        _availableDevices = devices;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)?.errorScanningForDevices(e.toString()) ?? 'Error scanning for devices: $e')),
      );
    } finally {
      setState(() {
        _isScanning = false;
      });
    }
  }

  Future<void> _testConnection() async {
    final settings = context.read<SettingsProvider>().settings;
    
    if (settings.selectedDeviceId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)?.pleaseSelectDeviceFirst ?? 'Please select a device first')),
      );
      return;
    }

    try {
      final connectionService = context.read<ConnectionService>();
      bool success = false;
      
      if (settings.connectionType == ConnectionType.bluetooth) {
        success = await connectionService.connectToBluetooth(settings.selectedDeviceId!);
      } else {
        success = await connectionService.connectToWiFi(settings.selectedDeviceId!);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success 
              ? (AppLocalizations.of(context)?.connectionSuccessful ?? 'Connection successful!') 
              : (AppLocalizations.of(context)?.connectionFailed ?? 'Connection failed')),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)?.connectionError(e.toString()) ?? 'Connection error: $e')),
      );
    }
  }

  Future<void> _exportEventLog(BuildContext context) async {
    try {
      await context.read<EventLogService>().shareEventLog();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)?.eventLogExportedSuccessfully ?? 'Event log exported successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)?.exportFailed(e.toString()) ?? 'Export failed: $e')),
      );
    }
  }

  Future<void> _clearEventLog(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)?.clearEventLog ?? 'Clear Event Log'),
        content: Text(AppLocalizations.of(context)?.clearEventLogConfirm ?? 'This will permanently delete all logged events. Continue?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(AppLocalizations.of(context)?.cancel ?? 'Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(AppLocalizations.of(context)?.clear ?? 'Clear'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      context.read<EventLogService>().clearEvents();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)?.eventLogCleared ?? 'Event log cleared')),
      );
    }
  }
  
  Future<void> _resetSettings(BuildContext context, SettingsProvider settingsProvider) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)?.resetAllSettings ?? 'Reset All Settings'),
        content: Text(AppLocalizations.of(context)?.resetAllSettingsConfirm ?? 'This will reset all settings to their default values. Continue?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(AppLocalizations.of(context)?.cancel ?? 'Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(AppLocalizations.of(context)?.reset ?? 'Reset'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await settingsProvider.resetToDefaults();
      context.read<TrafficLightProvider>().setDemoMode(false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)?.settingsResetToDefaults ?? 'Settings reset to defaults')),
      );
    }
  }
  
  Future<void> _resetOverlaySettings(BuildContext context, SettingsProvider settingsProvider) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)?.resetOverlaySettings ?? 'Reset Overlay Settings'),
        content: Text(AppLocalizations.of(context)?.resetOverlaySettingsConfirm ?? 'This will reset overlay transparency, size, and position to defaults. Continue?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(AppLocalizations.of(context)?.cancel ?? 'Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(AppLocalizations.of(context)?.reset ?? 'Reset'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await settingsProvider.resetOverlaySettings();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)?.overlaySettingsResetToDefaults ?? 'Overlay settings reset to defaults')),
      );
    }
  }
}