import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_final_project/state/field_log_controller.dart';
import 'package:provider/provider.dart';

class NewLogScreen extends StatefulWidget {
  const NewLogScreen({super.key});
  @override
  State<NewLogScreen> createState() => _NewLogScreen();
}

class _NewLogScreen extends State<NewLogScreen> {
  final _notesCtrl = TextEditingController();
  String? _imagePath;

  @override
  Widget build(BuildContext context) {
    final c = context.watch<FieldLogController>();
    return Scaffold(
      appBar: AppBar(title: const Text('New Log Entry')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _notesCtrl,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Field notes',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () async {
                    final path = await c.pickImageFromCamera();
                    if (path != null) {
                      setState(() {
                        _imagePath = path;
                      });
                    }
                  },
                  label: const Text('Camera'),
                  icon: const Icon(Icons.camera_alt),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () async {
                    final path = await c.pickImageFromGallery();
                    if (path != null) {
                      setState(() {
                        _imagePath = path;
                      });
                    }
                  },
                  label: const Text('Gallery'),
                  icon: const Icon(Icons.photo_library),
                ),
              ],
            ),
            if (_imagePath != null) ...[
              const SizedBox(height: 12),
              Image.file(File(_imagePath!), height: 120, fit: BoxFit.cover),
            ],
            const SizedBox(height: 24),
            if (c.loading)
              const CircularProgressIndicator()
            else
              ElevatedButton(
                onPressed: () async {
                  if (_notesCtrl.text.isEmpty) return;
                  await c.createLog(
                    notes: _notesCtrl.text,
                    localImagePath: _imagePath,
                  );
                  _notesCtrl.clear();
                  setState(() => _imagePath = null);
                },
                child: const Text('Save Log'),
              ),
            if (c.error != null)
              Text(c.error!, style: const TextStyle(color: Colors.redAccent)),
          ],
        ),
      ),
    );
  }
}
