import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_final_project/model/field_log.dart';
import 'package:flutter_final_project/state/field_log_controller.dart';
import 'package:provider/provider.dart';

class LogDetailScreen extends StatefulWidget {
  const LogDetailScreen({super.key, required this.log});
  final FieldLog log;

  @override
  State<LogDetailScreen> createState() => _LogDetailScreenState();
}

class _LogDetailScreenState extends State<LogDetailScreen> {
  static const int _maxTitleLength = 120;

  late FieldLog _log;
  late final TextEditingController _titleCtrl;
  late final TextEditingController _notesCtrl;
  String? _titleError;
  bool _saving = false;

  // Format Date
  String _formatDateTime(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} '
        'at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  void initState() {
    super.initState();
    _log = widget.log;
    _titleCtrl = TextEditingController(text: widget.log.title);
    _notesCtrl = TextEditingController(text: widget.log.notes);
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  // Validate Title
  bool _validateTitle() {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) {
      setState(() => _titleError = 'Title cannot be empty.');
      return false;
    }
    if (title.length > _maxTitleLength) {
      setState(() {
        _titleError = 'Title cannot exceed $_maxTitleLength characters.';
      });
      return false;
    }
    setState(() => _titleError = null);
    return true;
  }

  // Save Log
  Future<void> _save() async {
    if (!_validateTitle()) return;

    final updated = _log.copyWith(
      title: _titleCtrl.text.trim(),
      notes: _notesCtrl.text,
      updatedAt: DateTime.now(),
    );

    setState(() => _saving = true);
    try {
      await context.read<FieldLogController>().updateLog(updated);
      if (!mounted) return;
      setState(() => _log = updated);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Log saved'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not save: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Log Detail'),
        actions: [
          if (_saving)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            TextButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.save),
              label: const Text('Save Changes'),
            ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_log.localImagePath != null ||
                _log.remoteImagePath != null) ...[
              Hero(
                tag: _log.id,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: _log.remoteImagePath != null
                      ? Image.network(
                          _log.remoteImagePath!,
                          width: double.infinity,
                          height: 220,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: double.infinity,
                            height: 220,
                            color: Colors.grey.shade300,
                            alignment: Alignment.center,
                            child: const Icon(Icons.broken_image_outlined, size: 48),
                          ),
                        )
                      : Image.file(
                          File(_log.localImagePath!),
                          width: double.infinity,
                          height: 220,
                          fit: BoxFit.cover,
                        ),
                ),
              ),
              const SizedBox(height: 20),
            ],
            const Text(
              'Title',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _titleCtrl,
              maxLength: _maxTitleLength,
              maxLines: 1,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: 'Log title',
                errorText: _titleError,
                border: const OutlineInputBorder(),
                counterText: '',
              ),
              onChanged: (_) {
                if (_titleError != null) setState(() => _titleError = null);
              },
            ),
            const SizedBox(height: 20),

            const Text(
              'Notes:',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _notesCtrl,
              minLines: 3,
              maxLines: 10,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                hintText: 'Description',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            const Text(
              'Location:',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
            const SizedBox(height: 8),

            Text(
              'Latitude: ${_log.latitude.toStringAsFixed(6)}\nLongitude: ${_log.longitude.toStringAsFixed(6)}',
              style: const TextStyle(fontSize: 16),
            ),
            if (_log.weatherDescription != null) ...[
              const SizedBox(height: 20),
              const Text(
                'Weather:',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
              const SizedBox(height: 8),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ..._log.weatherDescription!
                      .split('\n')
                      .where((s) => s.trim().isNotEmpty)
                      .map(
                        (line) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Text(
                            line,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                ],
              ),
            ],
            const SizedBox(height: 20),

            const Text(
              'Created:',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
            const SizedBox(height: 8),

            Text(
              _formatDateTime(_log.createdAt),
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
