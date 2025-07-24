import 'package:flutter/material.dart';
import 'package:animations/animations.dart';
import '../l10n/app_localizations.dart';
import '../models/traffic_route.dart';

class RoutesScreen extends StatefulWidget {
  const RoutesScreen({super.key});

  @override
  State<RoutesScreen> createState() => _RoutesScreenState();
}

class _RoutesScreenState extends State<RoutesScreen> 
    with TickerProviderStateMixin {
  final List<TrafficRoute> _frequentRoutes = [];
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadFrequentRoutes();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
    
    _fadeController.forward();
  }

  void _loadFrequentRoutes() {
    // Mock data for demonstration
    setState(() {
      _frequentRoutes.addAll([
        TrafficRoute(
          id: '1',
          name: 'Home to Work',
          startLocation: 'Home',
          endLocation: 'Office',
          distance: '15.2 km',
          duration: '25 minutes',
          frequency: 42,
          lastUsed: DateTime.now().subtract(const Duration(hours: 2)),
        ),
        TrafficRoute(
          id: '2',
          name: 'Shopping Center',
          startLocation: 'Home',
          endLocation: 'Mall',
          distance: '8.5 km',
          duration: '12 minutes',
          frequency: 28,
          lastUsed: DateTime.now().subtract(const Duration(days: 1)),
        ),
        TrafficRoute(
          id: '3',
          name: 'School Route',
          startLocation: 'Home',
          endLocation: 'School',
          distance: '4.2 km',
          duration: '8 minutes',
          frequency: 56,
          lastUsed: DateTime.now().subtract(const Duration(hours: 8)),
        ),
        TrafficRoute(
          id: '4',
          name: 'City Center',
          startLocation: 'Home',
          endLocation: 'Downtown',
          distance: '12.8 km',
          duration: '18 minutes',
          frequency: 15,
          lastUsed: DateTime.now().subtract(const Duration(days: 3)),
        ),
      ]);
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    
    return Stack(
      children: [
        FadeTransition(
          opacity: _fadeAnimation,
          child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      theme.colorScheme.primary.withOpacity(0.1),
                      theme.colorScheme.surface,
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.route,
                          size: 32,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          l10n?.frequentRoutes ?? 'Frequent Routes',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n?.routesDescription ?? 'Your most frequently used traffic routes',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final route = _frequentRoutes[index];
                    return AnimatedContainer(
                      duration: Duration(milliseconds: 300 + (index * 100)),
                      margin: const EdgeInsets.only(bottom: 16),
                      child: _buildRouteCard(route, theme),
                    );
                  },
                  childCount: _frequentRoutes.length,
                ),
              ),
            ),
          ],
        ),
      ),
      Positioned(
        right: 16,
        bottom: 16,
        child: FloatingActionButton.extended(
          onPressed: _addNewRoute,
          icon: const Icon(Icons.add),
          label: Text(l10n?.addRoute ?? 'Add Route'),
          backgroundColor: theme.colorScheme.primary,
        ),
      ),
    ],
  );
  }

  Widget _buildRouteCard(TrafficRoute route, ThemeData theme) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _selectRoute(route),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.directions_car,
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          route.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${route.startLocation} → ${route.endLocation}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getFrequencyColor(route.frequency).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${route.frequency} uses',
                      style: TextStyle(
                        color: _getFrequencyColor(route.frequency),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildInfoChip(
                    Icons.straighten,
                    route.distance,
                    theme.colorScheme.secondary,
                  ),
                  const SizedBox(width: 12),
                  _buildInfoChip(
                    Icons.access_time,
                    route.duration,
                    theme.colorScheme.tertiary,
                  ),
                  const Spacer(),
                  Text(
                    _formatLastUsed(route.lastUsed),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Color _getFrequencyColor(int frequency) {
    if (frequency >= 50) return Colors.green;
    if (frequency >= 30) return Colors.orange;
    return Colors.red;
  }

  String _formatLastUsed(DateTime lastUsed) {
    final now = DateTime.now();
    final difference = now.difference(lastUsed);
    
    if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  void _selectRoute(TrafficRoute route) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(route.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('From: ${route.startLocation}'),
            Text('To: ${route.endLocation}'),
            Text('Distance: ${route.distance}'),
            Text('Duration: ${route.duration}'),
            Text('Used: ${route.frequency} times'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)?.cancel ?? 'Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Navigate to map with this route
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Opening ${route.name} route...'),
                ),
              );
            },
            child: Text(AppLocalizations.of(context)?.navigate ?? 'Navigate'),
          ),
        ],
      ),
    );
  }

  void _addNewRoute() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)?.addRoute ?? 'Add Route'),
        content: const Text('Route creation functionality would be implemented here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)?.cancel ?? 'Cancel'),
          ),
        ],
      ),
    );
  }
}