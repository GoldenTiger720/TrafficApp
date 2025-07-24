import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/event_log_service.dart';
import '../models/event_log.dart';
import '../l10n/app_localizations.dart';

class EventLogScreen extends StatefulWidget {
  const EventLogScreen({super.key});

  @override
  State<EventLogScreen> createState() => _EventLogScreenState();
}

class _EventLogScreenState extends State<EventLogScreen> {
  EventType? _selectedFilter;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Consumer<EventLogService>(
      builder: (context, eventLogService, child) {
        final events = _getFilteredEvents(eventLogService.events);
        
        return Column(
            children: [
              _buildFiltersSection(),
              _buildStatistics(eventLogService),
              Expanded(
                child: events.isEmpty
                    ? _buildEmptyState()
                    : _buildEventsList(events),
              ),
            ],
          );
        },
      );
  }

  Widget _buildFiltersSection() {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)?.searchEvents ?? 'Search events...',
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text(AppLocalizations.of(context)?.filterByType ?? 'Filter by type: '),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButton<EventType?>(
                    value: _selectedFilter,
                    isExpanded: true,
                    items: [
                      DropdownMenuItem<EventType?>(
                        value: null,
                        child: Text(AppLocalizations.of(context)?.allEvents ?? 'All Events'),
                      ),
                      ...EventType.values.map((type) => DropdownMenuItem<EventType?>(
                        value: type,
                        child: Text(_getEventTypeDisplayName(type)),
                      )),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedFilter = value;
                      });
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatistics(EventLogService eventLogService) {
    final counts = eventLogService.getEventTypeCounts();
    final totalEvents = eventLogService.events.length;
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)?.statistics ?? 'Statistics',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text('${AppLocalizations.of(context)?.totalEvents ?? 'Total Events'}: $totalEvents'),
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: EventType.values.map((type) {
                final count = counts[type] ?? 0;
                return Chip(
                  label: Text('${_getEventTypeDisplayName(type)}: $count'),
                  backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                  labelStyle: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)?.noEventsFound ?? 'No events found',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)?.eventsWillAppearHere ?? 'Events will appear here as they occur',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventsList(List<EventLog> events) {
    return ListView.builder(
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        return _buildEventTile(event);
      },
    );
  }

  Widget _buildEventTile(EventLog event) {
    final eventColor = _getEventTypeColor(event.type);
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ExpansionTile(
        leading: Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: eventColor,
            shape: BoxShape.circle,
          ),
        ),
        title: Text(
          event.message,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          '${_getEventTypeDisplayName(event.type)} • ${_formatTimestamp(event.timestamp)}',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow(AppLocalizations.of(context)?.eventId ?? 'Event ID', event.id),
                _buildDetailRow(AppLocalizations.of(context)?.type ?? 'Type', _getEventTypeDisplayName(event.type)),
                _buildDetailRow(AppLocalizations.of(context)?.timestamp ?? 'Timestamp', event.timestamp.toIso8601String()),
                if (event.previousColor != null && event.newColor != null) ...[
                  _buildDetailRow(AppLocalizations.of(context)?.colorChange ?? 'Color Change', 
                    '${event.previousColor!.name} → ${event.newColor!.name}'),
                ],
                if (event.recognizedSigns?.isNotEmpty == true) ...[
                  _buildDetailRow(AppLocalizations.of(context)?.signs ?? 'Signs', 
                    event.recognizedSigns!.map((s) => s.name).join(', ')),
                ],
                if (event.additionalData?.isNotEmpty == true) ...[
                  const SizedBox(height: 8),
                  Text(
                    '${AppLocalizations.of(context)?.additionalData ?? 'Additional Data'}:',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      event.additionalData.toString(),
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  List<EventLog> _getFilteredEvents(List<EventLog> events) {
    var filtered = events;
    
    if (_selectedFilter != null) {
      filtered = filtered.where((event) => event.type == _selectedFilter).toList();
    }
    
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((event) =>
        event.message.toLowerCase().contains(_searchQuery) ||
        event.type.name.toLowerCase().contains(_searchQuery)
      ).toList();
    }
    
    return filtered;
  }

  String _getEventTypeDisplayName(EventType type) {
    final l10n = AppLocalizations.of(context);
    switch (type) {
      case EventType.signalChange:
        return l10n?.signalChange ?? 'Signal Change';
      case EventType.signRecognition:
        return l10n?.signRecognition ?? 'Sign Recognition';
      case EventType.connectionStatusChange:
        return l10n?.connectionStatusChange ?? 'Connection';
      case EventType.error:
        return l10n?.error ?? 'Error';
      case EventType.userAction:
        return l10n?.userAction ?? 'User Action';
    }
  }

  Color _getEventTypeColor(EventType type) {
    switch (type) {
      case EventType.signalChange:
        return Colors.blue;
      case EventType.signRecognition:
        return Colors.green;
      case EventType.connectionStatusChange:
        return Colors.orange;
      case EventType.error:
        return Colors.red;
      case EventType.userAction:
        return Colors.purple;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inSeconds < 60) {
      return '${difference.inSeconds}s ago';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${timestamp.day}/${timestamp.month} ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    }
  }

}