import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import '../services/history_service.dart';
import 'package:uuid/uuid.dart';

class QuizState {
  final List<Map<String, dynamic>> mcqs;
  final Map<int, String> selectedAnswers;
  final int currentIndex;
  final int timeLeft;
  final bool isFinished;
  final String currentLanguage;
  final Map<int, Map<String, dynamic>> teluguCache;
  final bool isTranslating;

  QuizState({
    required this.mcqs,
    this.selectedAnswers = const {},
    this.currentIndex = 0,
    this.timeLeft = 30,
    this.isFinished = false,
    this.currentLanguage = 'en',
    this.teluguCache = const {},
    this.isTranslating = false,
  });

  QuizState copyWith({
    List<Map<String, dynamic>>? mcqs,
    Map<int, String>? selectedAnswers,
    int? currentIndex,
    int? timeLeft,
    bool? isFinished,
    String? currentLanguage,
    Map<int, Map<String, dynamic>>? teluguCache,
    bool? isTranslating,
  }) {
    return QuizState(
      mcqs: mcqs ?? this.mcqs,
      selectedAnswers: selectedAnswers ?? this.selectedAnswers,
      currentIndex: currentIndex ?? this.currentIndex,
      timeLeft: timeLeft ?? this.timeLeft,
      isFinished: isFinished ?? this.isFinished,
      currentLanguage: currentLanguage ?? this.currentLanguage,
      teluguCache: teluguCache ?? this.teluguCache,
      isTranslating: isTranslating ?? this.isTranslating,
    );
  }
}

class QuizNotifier extends Notifier<QuizState> {
  Timer? _timer;
  static const int _timePerQuestion = 30;

  @override
  QuizState build() {
    ref.onDispose(() {
      _timer?.cancel();
    });
    return QuizState(mcqs: const <Map<String, dynamic>>[]);
  }

  void loadQuiz(List<Map<String, dynamic>> mcqs) {
    _timer?.cancel();
    state = QuizState(mcqs: mcqs, timeLeft: _timePerQuestion);
    startTimer();
  }

  void selectAnswer(String answer) {
    if (state.isFinished) return;
    final newAnswers = Map<int, String>.from(state.selectedAnswers);
    newAnswers[state.currentIndex] = answer;
    state = state.copyWith(selectedAnswers: newAnswers);
  }

  void startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.timeLeft > 0) {
        state = state.copyWith(timeLeft: state.timeLeft - 1);
      } else {
        // Time's up for this question
        if (state.currentIndex < state.mcqs.length - 1) {
          nextQuestion();
        } else {
          finishQuiz();
        }
      }
    });
  }

  void nextQuestion() {
    if (state.currentIndex < state.mcqs.length - 1) {
      state = state.copyWith(
        currentIndex: state.currentIndex + 1,
        timeLeft: _timePerQuestion,
      );
      
      // If language was Telugu, check cache for the next question
      if (state.currentLanguage == 'te') {
        _translateCurrentIfNeeded();
      }

      startTimer(); // Restart timer for next question
    }
  }

  void previousQuestion() {
    if (state.currentIndex > 0) {
      state = state.copyWith(
        currentIndex: state.currentIndex - 1,
        timeLeft: _timePerQuestion,
      );

      // If language was Telugu, check cache for the previous question
      if (state.currentLanguage == 'te') {
        _translateCurrentIfNeeded();
      }

      startTimer(); // Restart timer for previous question
    }
  }

  void _translateCurrentIfNeeded() async {
    final currentIndex = state.currentIndex;
    if (state.teluguCache.containsKey(currentIndex)) return;

    state = state.copyWith(isTranslating: true);
    try {
      final apiService = ApiService();
      final currentMcq = state.mcqs[currentIndex];
      final question = currentMcq['question'] as String;
      final options = List<String>.from(currentMcq['options']);

      final List<String> batch = [question, ...options];
      final translatedBatch = await apiService.translate(batch, 'tel');

      if (translatedBatch is List && translatedBatch.length == batch.length) {
        final newTeluguCache = Map<int, Map<String, dynamic>>.from(state.teluguCache);
        newTeluguCache[currentIndex] = {
          'question': translatedBatch[0],
          'options': List<String>.from(translatedBatch.sublist(1)),
        };

        state = state.copyWith(
          teluguCache: newTeluguCache,
          isTranslating: false,
        );
      }
    } catch (e) {
      print("Translation error: $e");
      state = state.copyWith(isTranslating: false, currentLanguage: 'en');
    }
  }

  void finishQuiz() {
    _timer?.cancel();
    state = state.copyWith(isFinished: true);
    _saveToHistory();
  }

  Future<void> _saveToHistory() async {
    try {
      final historyService = HistoryService();
      int correctCount = 0;
      for (int i = 0; i < state.mcqs.length; i++) {
        if (state.selectedAnswers[i] == state.mcqs[i]['answer']) {
          correctCount++;
        }
      }

      final item = QuizHistoryItem(
        id: const Uuid().v4(),
        title: 'Quiz - ${DateTime.now().toString().substring(0, 16)}',
        date: DateTime.now(),
        mcqs: state.mcqs,
        selectedAnswers: state.selectedAnswers,
        score: correctCount,
      );

      await historyService.saveQuiz(item);
    } catch (e) {
      print("Error saving to history: $e");
    }
  }

  void updateMcq(int index, Map<String, dynamic> updatedMcq) {
    final newList = List<Map<String, dynamic>>.from(state.mcqs);
    newList[index] = updatedMcq;
    state = state.copyWith(mcqs: newList);
  }

  void updateAllMcqs(List<Map<String, dynamic>> updatedMcqs) {
    state = state.copyWith(mcqs: updatedMcqs);
  }

  Future<void> toggleLanguage(String langCode) async {
    if (state.currentLanguage == langCode) return;

    if (langCode == 'en') {
      state = state.copyWith(currentLanguage: 'en');
      return;
    }

    state = state.copyWith(currentLanguage: 'te');
    _translateCurrentIfNeeded();
  }
}

final quizProvider = NotifierProvider<QuizNotifier, QuizState>(QuizNotifier.new);
