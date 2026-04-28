import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../services/history_service.dart';
import '../quiz/quiz_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final HistoryService _historyService = HistoryService();
  late Future<List<QuizHistoryItem>> _historyFuture;

  @override
  void initState() {
    super.initState();
    _historyFuture = _historyService.getHistory();
  }

  void _clearHistory() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear History?'),
        content: const Text('This will permanently delete all past results.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Clear', style: TextStyle(color: AppColors.accent))),
        ],
      ),
    );

    if (confirmed == true) {
      await _historyService.clearHistory();
      setState(() {
        _historyFuture = _historyService.getHistory();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep_rounded, color: AppColors.accent),
            onPressed: _clearHistory,
          ),
        ],
      ),
      body: FutureBuilder<List<QuizHistoryItem>>(
        future: _historyFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history_rounded, size: 64, color: AppColors.textSecondaryLight.withValues(alpha: 0.3)),
                  const SizedBox(height: 16),
                  const Text('No history found yet.'),
                ],
              ),
            );
          }

          final history = snapshot.data!;
          return ListView.separated(
            padding: const EdgeInsets.all(24),
            itemCount: history.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final item = history[index];
              return Card(
                child: ListTile(
                  title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Score: ${item.score}/${item.mcqs.length} • ${DateFormat('MMM d, yyyy').format(item.date)}'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                     // Navigate to quiz results screen (re-view mode could be added later)
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
