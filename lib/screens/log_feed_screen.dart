import 'package:flutter/material.dart';
import 'package:flutter_final_project/screens/settings_screen.dart';
import 'package:flutter_final_project/state/field_log_controller.dart';
import 'package:flutter_final_project/widgets/log_card.dart';
import 'package:provider/provider.dart';

class LogFeedScreen extends StatelessWidget {
  const LogFeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.watch<FieldLogController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Field Logs'),
        actions: [
          Builder(
            builder: (ctx) => IconButton(
              onPressed: () => Scaffold.of(ctx).openDrawer(),
              icon: Icon(Icons.settings),
            ),
          ),
        ],
      ),
      drawer: SettingsScreen(),
      body: c.loading
          ? const Center(child: CircularProgressIndicator())
          : c.logs.isEmpty
          ? const Center(child: Text('No logs yet.'))
          : ListView.builder(
              itemBuilder: (context, index) {
                final log = c.logs[index];
                return Dismissible(
                  key: Key(log.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 16),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (_) => c.deleteLog(log.id),
                  child: LogCard(
                    log: log,
                    onTap: () =>
                        Navigator.pushNamed(context, '/detail', arguments: log),
                  ),
                );
              },
              itemCount: c.logs.length,
            ),
    );
  }
}
