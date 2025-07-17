import 'package:flutter/material.dart';
import 'package:animations/animations.dart';
import '../l10n/app_localizations.dart';

class ModernNavigationDrawer extends StatelessWidget {
  final String currentRoute;
  final Function(String) onRouteSelected;

  const ModernNavigationDrawer({
    super.key,
    required this.currentRoute,
    required this.onRouteSelected,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    
    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.surface,
              theme.colorScheme.surface.withOpacity(0.9),
            ],
          ),
        ),
        child: Column(
          children: [
            _buildDrawerHeader(context, theme),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildAnimatedTile(
                    context,
                    icon: Icons.home,
                    title: l10n?.home ?? 'Home',
                    route: '/home',
                    isSelected: currentRoute == '/home',
                  ),
                  _buildAnimatedTile(
                    context,
                    icon: Icons.map,
                    title: l10n?.map ?? 'Map',
                    route: '/map',
                    isSelected: currentRoute == '/map',
                  ),
                  _buildAnimatedTile(
                    context,
                    icon: Icons.route,
                    title: l10n?.routes ?? 'Routes',
                    route: '/routes',
                    isSelected: currentRoute == '/routes',
                  ),
                  _buildAnimatedTile(
                    context,
                    icon: Icons.history,
                    title: l10n?.eventLog ?? 'Event Log',
                    route: '/event-log',
                    isSelected: currentRoute == '/event-log',
                  ),
                  _buildAnimatedTile(
                    context,
                    icon: Icons.settings,
                    title: l10n?.settings ?? 'Settings',
                    route: '/settings',
                    isSelected: currentRoute == '/settings',
                  ),
                  const Divider(height: 32),
                  _buildAnimatedTile(
                    context,
                    icon: Icons.info,
                    title: l10n?.about ?? 'About',
                    route: '/about',
                    isSelected: currentRoute == '/about',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerHeader(BuildContext context, ThemeData theme) {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primaryContainer,
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: theme.colorScheme.onPrimary.withOpacity(0.2),
            child: Icon(
              Icons.traffic,
              size: 32,
              color: theme.colorScheme.onPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Traffic Monitor',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'Smart Traffic Management',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onPrimary.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String route,
    required bool isSelected,
  }) {
    final theme = Theme.of(context);
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: isSelected 
            ? theme.colorScheme.primaryContainer.withOpacity(0.8)
            : Colors.transparent,
      ),
      child: ListTile(
        leading: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: isSelected 
                ? theme.colorScheme.primary.withOpacity(0.2)
                : Colors.transparent,
          ),
          child: Icon(
            icon,
            color: isSelected 
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurface,
            size: 24,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected 
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurface,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        onTap: () {
          Navigator.of(context).pop();
          onRouteSelected(route);
        },
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}