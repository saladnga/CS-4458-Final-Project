import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_final_project/model/field_log.dart';

class LogCard extends StatelessWidget {
  const LogCard({super.key, required this.log, required this.onTap});

  final FieldLog log;
  final VoidCallback onTap;

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      return 'Today at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} days ago';
    } else {
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Hero(
                tag: log.id,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: log.remoteImagePath != null
                      ? Image.network(
                          log.remoteImagePath!,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                width: 60,
                                height: 60,
                                color: Colors.grey.shade300,
                                child: const Icon(Icons.broken_image_outlined),
                              ),
                        )
                      : log.localImagePath != null
                      ? Image.file(
                          File(log.localImagePath!),
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          width: 60,
                          height: 60,
                          color: Colors.grey,
                          child: const Icon(Icons.image_not_supported),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      log.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),

                    Text(
                      'Lat: ${log.latitude.toStringAsFixed(4)}, Lng: ${log.longitude.toStringAsFixed(4)}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    if (log.weatherDescription != null)
                      Text(
                        log.weatherDescription!.split('\n').first.trim(),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.blueGrey,
                        ),
                      ),
                    const SizedBox(height: 2),

                    Text(
                      _formatDate(log.createdAt),
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
