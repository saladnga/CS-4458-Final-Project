import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_final_project/model/field_log.dart';

class LogDetailScreen extends StatelessWidget {
  const LogDetailScreen({super.key, required this.log});
  final FieldLog log;

  String _formatDateTime(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} '
        'at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Log Detail')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (log.localImagePath != null || log.remoteImagePath != null) ...[
              Hero(
                tag: log.id,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: log.remoteImagePath != null
                      ? Image.network(
                          log.remoteImagePath!,
                          width: double.infinity,
                          height: 250,
                          fit: BoxFit.cover,
                        )
                      : Image.file(
                          File(log.localImagePath!),
                          width: double.infinity,
                          height: 250,
                          fit: BoxFit.cover,
                        ),
                ),
              ),
              const SizedBox(height: 20),
            ],
            const Text(
              'Notes',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Text(log.notes, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            const Text(
              'Location',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Latitude: ${log.latitude.toStringAsFixed(6)}\nLongitude: ${log.longitude.toStringAsFixed(6)}',
              style: const TextStyle(fontSize: 16),
            ),
            if (log.weatherDescription != null) ...[
              const SizedBox(height: 20),
              const Text(
                'Weather',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                log.weatherDescription!,
                style: const TextStyle(fontSize: 16),
              ),
            ],
            const SizedBox(height: 20),
            const Text(
              'Created',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _formatDateTime(log.createdAt),
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
