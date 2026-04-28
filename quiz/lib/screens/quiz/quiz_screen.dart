import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/quiz_provider.dart';
import 'quiz_result_screen.dart';

class QuizScreen extends ConsumerStatefulWidget {
  final List<Map<String, dynamic>> mcqs;

  const QuizScreen({super.key, required this.mcqs});

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(quizProvider.notifier).loadQuiz(widget.mcqs);
    });
  }

  @override
  Widget build(BuildContext context) {
    final quizState = ref.watch(quizProvider);
    final quizNotifier = ref.read(quizProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Navigate to results if quiz is finished
    ref.listen<QuizState>(quizProvider, (previous, next) {
      if (next.isFinished && !(previous?.isFinished ?? false)) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const QuizResultScreen(),
          ),
        );
      }
    });

    if (quizState.mcqs.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final currentIndex = quizState.currentIndex;
    final currentMcq = quizState.mcqs[currentIndex];
    
    String question = currentMcq['question'] as String? ?? 'Unknown Question';
    List<String> options = List<String>.from(currentMcq['options'] ?? []);

    if (quizState.currentLanguage == 'te' && quizState.teluguCache.containsKey(currentIndex)) {
      final cached = quizState.teluguCache[currentIndex]!;
      question = cached['question'] as String;
      options = List<String>.from(cached['options']);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Question ${currentIndex + 1}/${quizState.mcqs.length}'),
        leading: IconButton(
          icon: Icon(
            Icons.close_rounded,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            size: 24,
          ),
          onPressed: () => _confirmExit(context),
        ),
        actions: [
          // Language Toggle
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: PopupMenuButton<String>(
              onSelected: (String lang) => quizNotifier.toggleLanguage(lang),
              offset: const Offset(0, 48),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              icon: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.primary),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.language_rounded, size: 18, color: AppColors.primary),
                    const SizedBox(width: 4),
                    Text(
                      quizState.currentLanguage == 'en' ? 'EN' : 'TE',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'en',
                  child: Text('English'),
                ),
                const PopupMenuItem(
                  value: 'te',
                  child: Text('తెలుగు (Telugu)'),
                ),
              ],
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: quizState.timeLeft <= 5 
                      ? AppColors.accent.withValues(alpha: 0.1) 
                      : AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: quizState.timeLeft <= 5 ? AppColors.accent : AppColors.primary,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.timer_outlined,
                      size: 16,
                      color: quizState.timeLeft <= 5 ? AppColors.accent : AppColors.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${quizState.timeLeft}s',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: quizState.timeLeft <= 5 ? AppColors.accent : AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress bar
            LinearProgressIndicator(
              value: (currentIndex + 1) / quizState.mcqs.length,
              backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              minHeight: 4,
            ),
            Expanded(
              child: quizState.isTranslating
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Translating to Telugu...'),
                        ],
                      ),
                    ).animate().fadeIn()
                  : SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.all(24),
                      child: _QuizCard(
                        questionIndex: currentIndex,
                        question: question,
                        options: options,
                        selectedAnswer: quizState.selectedAnswers[currentIndex],
                        onOptionSelected: (String letter) {
                          quizNotifier.selectAnswer(letter);
                        },
                      ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0, curve: Curves.easeOut),
                    ),
            ),
            // Bottom Navigation
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  if (currentIndex > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: quizNotifier.previousQuestion,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(color: AppColors.primary),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Previous',
                          style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                        ),
                      ),
                    )
                  else
                    const Spacer(),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: quizState.selectedAnswers[currentIndex] == null
                          ? null
                          : () {
                              if (currentIndex < quizState.mcqs.length - 1) {
                                quizNotifier.nextQuestion();
                              } else {
                                quizNotifier.finishQuiz();
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        disabledBackgroundColor: Colors.grey.withValues(alpha: 0.3),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        currentIndex < quizState.mcqs.length - 1 ? 'Next' : 'Submit',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmExit(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit Quiz?'),
        content: const Text('Your progress will be lost. Are you sure you want to exit?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Exit', style: TextStyle(color: AppColors.accent)),
          ),
        ],
      ),
    );
  }
}

class _QuizCard extends StatelessWidget {
  final int questionIndex;
  final String question;
  final List<String> options;
  final String? selectedAnswer;
  final Function(String) onOptionSelected;

  const _QuizCard({
    required this.questionIndex,
    required this.question,
    required this.options,
    required this.selectedAnswer,
    required this.onOptionSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final labels = ['A', 'B', 'C', 'D'];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.15),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : Colors.black12).withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  height: 1.4,
                ),
          ).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 32),
          ...List.generate(options.length, (index) {
            if (index >= labels.length) return const SizedBox.shrink();
            
            final letter = labels[index];
            final optionText = options[index];
            final isSelected = selectedAnswer == letter;

            Color borderColor = isDark ? Colors.grey.shade800 : Colors.grey.shade300;
            Color bgColor = Colors.transparent;
            Color textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

            if (isSelected) {
              borderColor = AppColors.primary;
              bgColor = AppColors.primary.withValues(alpha: 0.1);
              textColor = AppColors.primary;
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: InkWell(
                onTap: () => onOptionSelected(letter),
                borderRadius: BorderRadius.circular(16),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderColor, width: 2),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected ? AppColors.primary : Colors.transparent,
                          border: Border.all(
                            color: isSelected ? AppColors.primary : borderColor,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            letter,
                            style: TextStyle(
                              color: isSelected ? Colors.white : textColor,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          optionText,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 16,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ).animate().fadeIn(delay: (400 + (index * 100)).ms).slideX(begin: 0.05, end: 0);
          }),
        ],
      ),
    );
  }
}
