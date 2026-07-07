import 'package:flutter/material.dart';
import 'log_store.dart';

class LogPage extends StatelessWidget {
  const LogPage({super.key});

  @override
  Widget build(BuildContext context) {
    final entries = LogStore.instance.entries;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Log'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              LogStore.instance.clear();
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Log cleared')));
              Navigator.pop(context);
            },
          )
        ],
      ),
      body: entries.isEmpty
          ? const Center(child: Text('No entries yet'))
          : ListView.builder(
              itemCount: entries.length,
              itemBuilder: (context, i) {
                final e = entries[i];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: ListTile(
                    title: Text(e.name),
                    subtitle: Text('${e.calories != null ? '${e.calories!.toStringAsFixed(0)} kcal' : 'N/A'} • ${e.proteins != null ? '${e.proteins!.toStringAsFixed(1)}g protein' : ''}'),
                    trailing: Text('${e.time.hour.toString().padLeft(2, '0')}:${e.time.minute.toString().padLeft(2, '0')}'),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: Text(e.name),
                          content: SingleChildScrollView(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxHeight: 400),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Barcode: ${e.barcode}'),
                                  const SizedBox(height: 8),
                                  Text('Calories: ${e.calories ?? 'N/A'}'),
                                  Text('Protein: ${e.proteins ?? 'N/A'}'),
                                  Text('Fat: ${e.fats ?? 'N/A'}'),
                                  Text('Carbs: ${e.carbs ?? 'N/A'}'),
                                  Text('Sugar: ${e.sugar ?? 'N/A'}'),
                                  if (e.ingredients != null) ...[
                                    const SizedBox(height: 8),
                                    const Text('Ingredients:', style: TextStyle(fontWeight: FontWeight.bold)),
                                    Text(e.ingredients!),
                                  ]
                                ],
                              ),
                            ),
                          ),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
