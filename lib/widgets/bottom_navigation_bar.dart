import 'package:flutter/material.dart';
import 'package:animations/animations.dart';
import '../l10n/app_localizations.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final String currentRoute;
  final Function(String) onRouteSelected;

  const CustomBottomNavigationBar({
    super.key,
    required this.currentRoute,
    required this.onRouteSelected,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outline.withOpacity(0.2),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                context,
                icon: Icons.home,
                label: l10n?.home ?? 'Home',
                route: '/home',
                isSelected: currentRoute == '/home',
              ),
              _buildNavItem(
                context,
                icon: Icons.map,
                label: l10n?.map ?? 'Map',
                route: '/map',
                isSelected: currentRoute == '/map',
              ),
              _buildNavItem(
                context,
                icon: Icons.route,
                label: l10n?.routes ?? 'Routes',
                route: '/routes',
                isSelected: currentRoute == '/routes',
              ),
              _buildNavItem(
                context,
                icon: Icons.history,
                label: l10n?.eventLog ?? 'Event Log',
                route: '/event-log',
                isSelected: currentRoute == '/event-log',
              ),
              _buildNavItem(
                context,
                icon: Icons.settings,
                label: l10n?.settings ?? 'Settings',
                route: '/settings',
                isSelected: currentRoute == '/settings',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String route,
    required bool isSelected,
  }) {
    final theme = Theme.of(context);
    
    return Expanded(
      child: GestureDetector(
        onTap: () => onRouteSelected(route),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: isSelected 
                ? theme.colorScheme.primaryContainer.withOpacity(0.8)
                : Colors.transparent,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: isSelected 
                      ? theme.colorScheme.primary.withOpacity(0.2)
                      : Colors.transparent,
                ),
                child: Icon(
                  icon,
                  color: isSelected 
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface.withOpacity(0.7),
                  size: 24,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSelected 
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface.withOpacity(0.7),
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}