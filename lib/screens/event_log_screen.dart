import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/event_log_service.dart';
import '../models/event_log.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Log'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _exportLog,
            tooltip: 'Export Log',
          ),
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: _showClearDialog,
            tooltip: 'Clear Log',
          ),
        ],
      ),
      body: Consumer<EventLogService>(
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
      ),
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
              decoration: const InputDecoration(
                hintText: 'Search events...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
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
                const Text('Filter by type: '),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButton<EventType?>(
                    value: _selectedFilter,
                    isExpanded: true,
                    items: [
                      const DropdownMenuItem<EventType?>(
                        value: null,
                        child: Text('All Events'),
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
              'Statistics',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text('Total Events: $totalEvents'),
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: EventType.values.map((type) {
                final count = counts[type] ?? 0;
                return Chip(
                  label: Text('${_getEventTypeDisplayName(type)}: $count'),
                  backgroundColor: _getEventTypeColor(type).withOpacity(0.2),
                  labelStyle: TextStyle(
                    color: _getEventTypeColor(type),
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
            'No events found',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Events will appear here as they occur',
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
                _buildDetailRow('Event ID', event.id),
                _buildDetailRow('Type', _getEventTypeDisplayName(event.type)),
                _buildDetailRow('Timestamp', event.timestamp.toIso8601String()),
                if (event.previousColor != null && event.newColor != null) ...[
                  _buildDetailRow('Color Change', 
                    '${event.previousColor!.name} → ${event.newColor!.name}'),
                ],
                if (event.recognizedSigns?.isNotEmpty == true) ...[
                  _buildDetailRow('Signs', 
                    event.recognizedSigns!.map((s) => s.name).join(', ')),
                ],
                if (event.additionalData?.isNotEmpty == true) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Additional Data:',
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
    switch (type) {
      case EventType.signalChange:
        return 'Signal Change';
      case EventType.signRecognition:
        return 'Sign Recognition';
      case EventType.connectionStatusChange:
        return 'Connection';
      case EventType.error:
        return 'Error';
      case EventType.userAction:
        return 'User Action';
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

  Future<void> _exportLog() async {
    try {
      await context.read<EventLogService>().shareEventLog();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Export failed: $e')),
      );
    }
  }

  Future<void> _showClearDialog() async {
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
            style: TextButton.styleFrom(foregroundColor: Colors.red),
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