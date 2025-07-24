import 'package:flutter/material.dart';
import 'package:animations/animations.dart';
import 'package:provider/provider.dart';
import 'bottom_navigation_bar.dart';
import '../screens/main_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/event_log_screen.dart';
import '../screens/routes_screen.dart';
import '../services/event_log_service.dart';
import '../l10n/app_localizations.dart';

class AppNavigationScaffold extends StatefulWidget {
  final Widget? child;
  final String? initialRoute;

  const AppNavigationScaffold({
    super.key,
    this.child,
    this.initialRoute,
  });

  @override
  State<AppNavigationScaffold> createState() => _AppNavigationScaffoldState();
}

class _AppNavigationScaffoldState extends State<AppNavigationScaffold> {
  String _currentRoute = '/home';
  late Widget _currentScreen;

  @override
  void initState() {
    super.initState();
    _currentRoute = widget.initialRoute ?? '/home';
    _currentScreen = _getScreenForRoute(_currentRoute);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getAppBarTitle()),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: _getAppBarActions(),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.topRight,
              colors: [
                Theme.of(context).colorScheme.surface,
                Theme.of(context).colorScheme.surface.withOpacity(0.9),
              ],
            ),
          ),
        ),
      ),
      body: PageTransitionSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation, secondaryAnimation) {
          return SharedAxisTransition(
            animation: animation,
            secondaryAnimation: secondaryAnimation,
            transitionType: SharedAxisTransitionType.horizontal,
            child: child,
          );
        },
        child: _currentScreen,
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentRoute: _currentRoute,
        onRouteSelected: _onRouteSelected,
      ),
    );
  }

  void _onRouteSelected(String route) {
    if (route == _currentRoute) return;
    
    setState(() {
      _currentRoute = route;
      _currentScreen = _getScreenForRoute(route);
    });
  }

  Widget _getScreenForRoute(String route) {
    switch (route) {
      case '/home':
        return const MainScreen();
      case '/routes':
        return const RoutesScreen();
      case '/event-log':
        return const EventLogScreen();
      case '/settings':
        return const SettingsScreen();
      case '/about':
        return const AboutScreen();
      default:
        return const MainScreen();
    }
  }

  String _getAppBarTitle() {
    final l10n = AppLocalizations.of(context);
    switch (_currentRoute) {
      case '/home':
        return l10n?.trafficLightMonitor ?? 'Traffic Monitor';
      case '/routes':
        return l10n?.routes ?? 'Routes';
      case '/event-log':
        return l10n?.eventLog ?? 'Event Log';
      case '/settings':
        return l10n?.settings ?? 'Settings';
      case '/about':
        return l10n?.about ?? 'About';
      default:
        return l10n?.trafficLightMonitor ?? 'Traffic Monitor';
    }
  }

  List<Widget>? _getAppBarActions() {
    if (_currentRoute != '/event-log') return null;
    
    final l10n = AppLocalizations.of(context);
    return [
      PopupMenuButton<String>(
        onSelected: _handleMenuAction,
        itemBuilder: (BuildContext context) => [
          PopupMenuItem<String>(
            value: 'share',
            child: Row(
              children: [
                const Icon(Icons.share),
                const SizedBox(width: 8),
                Text(l10n?.exportEventLog ?? 'Export Event Log'),
              ],
            ),
          ),
          const PopupMenuDivider(),
          PopupMenuItem<String>(
            value: 'clear',
            child: Row(
              children: [
                const Icon(Icons.delete_outline, color: Colors.red),
                const SizedBox(width: 8),
                Text(l10n?.clearEventLog ?? 'Clear Event Log'),
              ],
            ),
          ),
        ],
      ),
    ];
  }

  Future<void> _exportEventLog() async {
    try {
      await context.read<EventLogService>().shareEventLog();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)?.exportFailed(e.toString()) ?? 'Export failed: $e')),
      );
    }
  }

  Future<void> _handleMenuAction(String action) async {
    switch (action) {
      case 'share':
        _exportEventLog();
        break;
      case 'clear':
        _showClearDialog();
        break;
    }
  }

  Future<void> _showClearDialog() async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n?.clearEventLog ?? 'Clear Event Log'),
        content: Text(l10n?.clearEventLogConfirm ?? 'This will permanently delete all logged events. Continue?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n?.cancel ?? 'Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(l10n?.clear ?? 'Clear'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      context.read<EventLogService>().clearEvents();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n?.eventLogCleared ?? 'Event log cleared')),
      );
    }
  }
}

// Placeholder screens that we'll implement

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'About Screen - Coming Soon',
        style: TextStyle(fontSize: 18),
      ),
    );
  }
}