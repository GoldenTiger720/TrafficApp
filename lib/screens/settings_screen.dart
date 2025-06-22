import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_settings.dart';
import '../providers/settings_provider.dart';
import '../providers/traffic_light_provider.dart';
import '../services/connection_service.dart';
import '../services/event_log_service.dart';
import '../models/traffic_light_state.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  List<String> _availableDevices = [];
  bool _isScanning = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, child) {
          final settings = settingsProvider.settings;
          
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildSection(
                'Overlay Settings',
                [
                  _buildSwitchTile(
                    'Enable Overlay',
                    settings.overlayEnabled,
                    (value) => settingsProvider.updateOverlayEnabled(value),
                  ),
                  _buildSliderTile(
                    'Transparency',
                    settings.overlayTransparency,
                    0.0,
                    1.0,
                    (value) => settingsProvider.updateOverlayTransparency(value),
                    valueFormatter: (value) => '${(value * 100).round()}%',
                  ),
                  _buildSliderTile(
                    'Size',
                    settings.overlaySize,
                    0.5,
                    2.0,
                    (value) => settingsProvider.updateOverlaySize(value),
                    valueFormatter: (value) => '${(value * 100).round()}%',
                  ),
                  ListTile(
                    title: const Text('Reset Position'),
                    subtitle: const Text('Move overlay to center'),
                    trailing: ElevatedButton(
                      onPressed: () => settingsProvider.resetOverlayPosition(),
                      child: const Text('Reset'),
                    ),
                  ),
                ],
              ),
              _buildSection(
                'Connection Settings',
                [
                  _buildDropdownTile<ConnectionType>(
                    'Connection Type',
                    settings.connectionType,
                    ConnectionType.values,
                    (value) => settingsProvider.updateConnectionType(value!),
                    itemBuilder: (type) => Text(type.name.toUpperCase()),
                  ),
                  _buildDeviceSelector(context, settings),
                  ListTile(
                    title: const Text('Test Connection'),
                    subtitle: Text(_getConnectionStatus(context)),
                    trailing: ElevatedButton(
                      onPressed: _testConnection,
                      child: const Text('Test'),
                    ),
                  ),
                ],
              ),
              _buildSection(
                'Notifications',
                [
                  _buildSwitchTile(
                    'Sound Notifications',
                    settings.soundNotifications,
                    (value) => settingsProvider.updateSoundNotifications(value),
                  ),
                  _buildSwitchTile(
                    'Vibration Notifications',
                    settings.vibrationNotifications,
                    (value) => settingsProvider.updateVibrationNotifications(value),
                  ),
                ],
              ),
              _buildSection(
                'Appearance',
                [
                  _buildDropdownTile<AppTheme>(
                    'Theme',
                    settings.theme,
                    AppTheme.values,
                    (value) => settingsProvider.updateTheme(value!),
                    itemBuilder: (theme) => Text(_getThemeDisplayName(theme)),
                  ),
                  _buildDropdownTile<Language>(
                    'Language',
                    settings.language,
                    Language.values,
                    (value) => settingsProvider.updateLanguage(value!),
                    itemBuilder: (lang) => Text(_getLanguageDisplayName(lang)),
                  ),
                  _buildDropdownTile<DisplayMode>(
                    'Display Mode',
                    settings.displayMode,
                    DisplayMode.values,
                    (value) => settingsProvider.updateDisplayMode(value!),
                    itemBuilder: (mode) => Text(_getDisplayModeDisplayName(mode)),
                  ),
                ],
              ),
              _buildSection(
                'Developer Options',
                [
                  _buildSwitchTile(
                    'Demo Mode',
                    settings.demoMode,
                    (value) {
                      settingsProvider.updateDemoMode(value);
                      context.read<TrafficLightProvider>().setDemoMode(value);
                    },
                  ),
                  _buildTestControls(context),
                ],
              ),
              _buildSection(
                'Data & Privacy',
                [
                  ListTile(
                    title: const Text('Export Event Log'),
                    subtitle: const Text('Share event log for debugging'),
                    trailing: const Icon(Icons.share),
                    onTap: () => _exportEventLog(context),
                  ),
                  ListTile(
                    title: const Text('Clear Event Log'),
                    subtitle: const Text('Delete all logged events'),
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
          title: const Text('Available Devices'),
          subtitle: Text(_isScanning ? 'Scanning...' : '${_availableDevices.length} devices found'),
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
        const ListTile(
          title: Text('Manual Overlay Test'),
          subtitle: Text('Test overlay colors manually'),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => context.read<TrafficLightProvider>().testOverlay(TrafficLightColor.red),
              child: const Text('Red', style: TextStyle(color: Colors.white)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
              onPressed: () => context.read<TrafficLightProvider>().testOverlay(TrafficLightColor.yellow),
              child: const Text('Yellow', style: TextStyle(color: Colors.black)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              onPressed: () => context.read<TrafficLightProvider>().testOverlay(TrafficLightColor.green),
              child: const Text('Green', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  String _getThemeDisplayName(AppTheme theme) {
    switch (theme) {
      case AppTheme.light:
        return 'Light';
      case AppTheme.dark:
        return 'Dark';
      case AppTheme.system:
        return 'System';
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

  String _getDisplayModeDisplayName(DisplayMode mode) {
    switch (mode) {
      case DisplayMode.minimalistic:
        return 'Minimalistic';
      case DisplayMode.advanced:
        return 'Advanced';
    }
  }

  String _getConnectionStatus(BuildContext context) {
    final isConnected = context.watch<TrafficLightProvider>().isConnected;
    return isConnected ? 'Connected' : 'Disconnected';
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
        SnackBar(content: Text('Error scanning for devices: $e')),
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
        const SnackBar(content: Text('Please select a device first')),
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
          content: Text(success ? 'Connection successful!' : 'Connection failed'),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Connection error: $e')),
      );
    }
  }

  Future<void> _exportEventLog(BuildContext context) async {
    try {
      await context.read<EventLogService>().shareEventLog();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Event log exported successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Export failed: $e')),
      );
    }
  }

  Future<void> _clearEventLog(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Event Log'),
        content: const Text('This will permanently delete all logged events. Continue?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      context.read<EventLogService>().clearEvents();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Event log cleared')),
      );
    }
  }
}