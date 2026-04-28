import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class QuizHistoryItem {
  final String id;
  final String title;
  final DateTime date;
  final List<Map<String, dynamic>> mcqs;
  final Map<int, String> selectedAnswers;
  final int score;

  QuizHistoryItem({
    required this.id,
    required this.title,
    required this.date,
    required this.mcqs,
    required this.selectedAnswers,
    required this.score,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'date': date.toIso8601String(),
        'mcqs': mcqs,
        'selectedAnswers': selectedAnswers.map((k, v) => MapEntry(k.toString(), v)),
        'score': score,
      };

  factory QuizHistoryItem.fromJson(Map<String, dynamic> json) => QuizHistoryItem(
        id: json['id'],
        title: json['title'],
        date: DateTime.parse(json['date']),
        mcqs: List<Map<String, dynamic>>.from(json['mcqs']),
        selectedAnswers: (json['selectedAnswers'] as Map<String, dynamic>).map(
          (k, v) => MapEntry(int.parse(k), v.toString()),
        ),
        score: json['score'],
      );
}

class HistoryService {
  static const String _key = 'quiz_history';

  Future<void> saveQuiz(QuizHistoryItem item) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> history = prefs.getStringList(_key) ?? [];
    history.insert(0, jsonEncode(item.toJson()));
    
    // Limit history to last 50 items for performance
    if (history.length > 50) {
      history.removeRange(50, history.length);
    }
    
    await prefs.setStringList(_key, history);
  }

  Future<List<QuizHistoryItem>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> historyStrings = prefs.getStringList(_key) ?? [];
    return historyStrings.map((s) => QuizHistoryItem.fromJson(jsonDecode(s))).toList();
  }

  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
