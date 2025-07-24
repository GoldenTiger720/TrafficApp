import 'package:flutter/material.dart';
import 'package:animations/animations.dart';
import 'bottom_navigation_bar.dart';
import '../screens/main_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/event_log_screen.dart';
import '../screens/routes_screen.dart';
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