import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/quiz_provider.dart';
import '../../utils/export_helper.dart';

class QuizResultScreen extends ConsumerWidget {
  const QuizResultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quizState = ref.read(quizProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    int correctCount = 0;
    for (int i = 0; i < quizState.mcqs.length; i++) {
      final correctAnswer = quizState.mcqs[i]['answer'];
      if (quizState.selectedAnswers[i] == correctAnswer) {
        correctCount++;
      }
    }

    final scorePercentage = (correctCount / quizState.mcqs.length) * 100;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Results'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_rounded, color: AppColors.primary),
            tooltip: 'Export PDF',
            onPressed: () => ExportHelper.exportToPdf('Quiz Results', quizState.mcqs),
          ),
          IconButton(
            icon: const Icon(Icons.share_rounded, color: AppColors.primary),
            tooltip: 'Share JSON',
            onPressed: () => ExportHelper.exportToJson(quizState.mcqs),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              width: double.infinity,
              color: isDark ? AppColors.surfaceDark : AppColors.primary.withValues(alpha: 0.05),
              child: Column(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(
                        color: scorePercentage >= 50 ? Colors.green : AppColors.accent,
                        width: 8,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (scorePercentage >= 50 ? Colors.green : AppColors.accent).withValues(alpha: 0.3),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        '$correctCount / ${quizState.mcqs.length}',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: scorePercentage >= 50 ? Colors.green : AppColors.accent,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    scorePercentage >= 80
                        ? 'Excellent Work!'
                        : scorePercentage >= 50
                            ? 'Good Job!'
                            : 'Keep Practicing!',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(24),
                physics: const BouncingScrollPhysics(),
                itemCount: quizState.mcqs.length,
                separatorBuilder: (_, __) => const SizedBox(height: 24),
                itemBuilder: (context, index) {
                  final mcq = quizState.mcqs[index];
                  final question = mcq['question'];
                  final correctAnswerLabel = mcq['answer'];
                  final selectedAnswerLabel = quizState.selectedAnswers[index];
                  
                  // Get actual text for the correct and selected options
                  final options = List<String>.from(mcq['options']);
                  final labels = ['A', 'B', 'C', 'D'];
                  
                  String correctAnswerText = '';
                  String selectedAnswerText = 'Not answered';
                  
                  for (int i = 0; i < labels.length && i < options.length; i++) {
                    if (labels[i] == correctAnswerLabel) {
                      correctAnswerText = '${labels[i]}. ${options[i]}';
                    }
                    if (labels[i] == selectedAnswerLabel) {
                      selectedAnswerText = '${labels[i]}. ${options[i]}';
                    }
                  }

                  final isCorrect = correctAnswerLabel == selectedAnswerLabel;

                  return Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.cardDark : AppColors.cardLight,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isCorrect ? Colors.green.withValues(alpha: 0.5) : AppColors.accent.withValues(alpha: 0.5),
                        width: 2,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isCorrect ? Colors.green : AppColors.accent,
                              ),
                              child: Icon(
                                isCorrect ? Icons.check : Icons.close,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                question,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Text(
                                'Correct: ',
                                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                              ),
                              Expanded(
                                child: Text(
                                  correctAnswerText,
                                  style: const TextStyle(color: Colors.green),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (!isCorrect) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.accent.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Text(
                                  'Your Answer: ',
                                  style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.accent),
                                ),
                                Expanded(
                                  child: Text(
                                    selectedAnswerText,
                                    style: const TextStyle(color: AppColors.accent),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Navigate back to home
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  icon: const Icon(Icons.home_rounded, color: Colors.white),
                  label: const Text(
                    'Return to Home',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
