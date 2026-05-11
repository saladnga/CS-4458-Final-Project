import 'package:flutter/material.dart';
import 'package:flutter_final_project/screens/settings_screen.dart';
import 'package:flutter_final_project/state/field_log_controller.dart';
import 'package:flutter_final_project/widgets/log_card.dart';
import 'package:provider/provider.dart';
import 'package:flutter_final_project/screens/log_detail_screen.dart';

class LogFeedScreen extends StatelessWidget {
  const LogFeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.watch<FieldLogController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Field Logs', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueAccent,
      ),
      drawer: SettingsScreen(),
      body: c.loading
          ? const Center(child: CircularProgressIndicator())
          : c.logs.isEmpty
          ? const Center(child: Text('No logs yet.')) // Fallback if no log
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 8, 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: const InputDecoration(
                            hintText: 'Search by title',
                            prefixIcon: Icon(Icons.search),
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          onChanged: c.setSearchQuery,
                        ),
                      ),
                      // Sort Panel
                      PopupMenuButton<LogSort>(
                        icon: const Icon(Icons.sort),
                        tooltip: 'Sort',
                        initialValue: c.logSort,
                        onSelected: c.setLogSort,
                        itemBuilder: (context) => const [
                          PopupMenuItem(
                            value: LogSort.newest,
                            child: Text('Newest first'),
                          ),
                          PopupMenuItem(
                            value: LogSort.oldest,
                            child: Text('Oldest first'),
                          ),
                          PopupMenuItem(
                            value: LogSort.titleAZ,
                            child: Text('Title A–Z'),
                          ),
                          PopupMenuItem(
                            value: LogSort.titleZA,
                            child: Text('Title Z–A'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: c.filteredLogs.isEmpty
                      ? const Center(child: Text('No logs match your search.'))
                      : ListView.builder(
                          itemCount: c.filteredLogs.length,
                          itemBuilder: (context, index) {
                            final log = c.filteredLogs[index];
                            return Dismissible(
                              key: Key(log.id),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                color: Colors.red,
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 16),
                                child: const Icon(
                                  Icons.delete,
                                  color: Colors.white,
                                ),
                              ),
                              onDismissed: (_) async {
                                try {
                                  await c.deleteLog(log.id);
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Log deleted'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                } catch (e) {
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Could not delete: $e'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              },
                              child: LogCard(
                                log: log,
                                onTap: () {
                                  final ctrl = context
                                      .read<FieldLogController>();
                                  Navigator.of(context).push<void>(
                                    MaterialPageRoute<void>(
                                      builder: (_) =>
                                          ChangeNotifierProvider<
                                            FieldLogController
                                          >.value(
                                            value: ctrl,
                                            child: LogDetailScreen(log: log),
                                          ),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
