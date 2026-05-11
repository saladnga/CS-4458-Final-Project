import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_final_project/state/field_log_controller.dart';
import 'package:provider/provider.dart';

class NewLogScreen extends StatefulWidget {
  const NewLogScreen({super.key});
  @override
  State<NewLogScreen> createState() => _NewLogScreenState();
}

class _NewLogScreenState extends State<NewLogScreen> {
  static const int _maxTitleLength = 120;

  final _titleCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  String? _imagePath;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  // Retake photo
  Future<void> _retake(FieldLogController c) async {
    final path = await c.pickImageFromCamera();
    if (path != null && mounted) setState(() => _imagePath = path);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.watch<FieldLogController>();
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'New Log Entry',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: 16 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _titleCtrl,
              maxLength: _maxTitleLength,
              maxLines: 1,
              decoration: const InputDecoration(
                labelText: 'Log Field title',
                border: OutlineInputBorder(),
                counterText: '',
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _notesCtrl,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Log Field notes',
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            if (_imagePath == null) ...[
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final path = await c.pickImageFromCamera();
                        if (path != null && mounted) {
                          setState(() => _imagePath = path);
                        }
                      },
                      icon: const Icon(Icons.camera_alt, size: 20),
                      label: const Text('Camera'),
                    ),
                  ),
                  const SizedBox(width: 12),

                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final path = await c.pickImageFromGallery();
                        if (path != null && mounted) {
                          setState(() => _imagePath = path);
                        }
                      },
                      icon: const Icon(Icons.photo_library, size: 20),
                      label: const Text('Gallery'),
                    ),
                  ),
                ],
              ),
            ] else ...[
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Material(
                    color: colorScheme.surfaceContainerHighest,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.file(File(_imagePath!), fit: BoxFit.cover),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  Colors.black.withValues(alpha: 0.75),
                                  Colors.transparent,
                                ],
                              ),
                            ),

                            child: SafeArea(
                              top: false,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 10,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: FilledButton.tonalIcon(
                                        onPressed: () =>
                                            setState(() => _imagePath = null),
                                        icon: const Icon(Icons.delete_outline),
                                        label: const Text('Delete'),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: FilledButton.tonalIcon(
                                        onPressed: c.loading
                                            ? null
                                            : () => _retake(c),
                                        icon: const Icon(
                                          Icons.photo_camera_outlined,
                                        ),
                                        label: const Text('Retake'),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 20),
            if (c.loading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: CircularProgressIndicator(),
                ),
              )
            else
              FilledButton(
                onPressed: () async {
                  if (_notesCtrl.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Notes are required.'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }
                  final t = _titleCtrl.text.trim();
                  if (t.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Title is required.'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }
                  if (t.length > _maxTitleLength) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Title must be at most $_maxTitleLength characters.',
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }
                  await c.createLog(
                    title: t,
                    notes: _notesCtrl.text,
                    localImagePath: _imagePath,
                  );
                  if (!context.mounted) return;
                  if (c.error != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(c.error!),
                        backgroundColor: Colors.red,
                      ),
                    );
                  } else {
                    _titleCtrl.clear();
                    _notesCtrl.clear();
                    setState(() => _imagePath = null);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Log created'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                },
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Save log'),
              ),
            if (c.error != null) ...[
              const SizedBox(height: 12),
              Text(c.error!, style: TextStyle(color: colorScheme.error)),
            ],
          ],
        ),
      ),
    );
  }
}
