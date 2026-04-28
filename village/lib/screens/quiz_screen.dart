import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import '../providers/data_provider.dart';
import '../models/quiz_question.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentIndex = 0;
  int _score = 0;
  bool _isFinished = false;
  int? _selectedAnswer;
  bool _hasAnswered = false;
  
  Timer? _timer;
  int _timeLeft = 30; // 30 seconds per question

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _timeLeft = 30);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        setState(() => _timeLeft--);
      } else {
        _submitAnswer(-1); // Time out
      }
    });
  }

  void _submitAnswer(int index) {
    if (_hasAnswered) return;
    _timer?.cancel();
    
    final questions = Provider.of<DataProvider>(context, listen: false).questions;
    bool isCorrect = index == questions[_currentIndex].correctAnswerIndex;
    
    setState(() {
      _selectedAnswer = index;
      _hasAnswered = true;
      if (isCorrect) _score++;
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (_currentIndex < questions.length - 1) {
        setState(() {
          _currentIndex++;
          _selectedAnswer = null;
          _hasAnswered = false;
        });
        _startTimer();
      } else {
        setState(() => _isFinished = true);
      }
    });
  }

  void _restartQuiz() {
    setState(() {
      _currentIndex = 0;
      _score = 0;
      _isFinished = false;
      _selectedAnswer = null;
      _hasAnswered = false;
    });
    _startTimer();
  }

  @override
  Widget build(BuildContext context) {
    final questions = context.watch<DataProvider>().questions;

    return Container(
      color: Colors.grey[50],
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (questions.isEmpty)
                _buildNoQuestions()
              else if (_isFinished)
                _buildResultScreen(questions.length)
              else
                _buildQuizUI(questions[_currentIndex], questions.length),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoQuestions() {
    return Column(
      children: [
        Icon(Icons.quiz_outlined, size: 80, color: Colors.grey[300]),
        const SizedBox(height: 20),
        Text("No quiz questions available.", style: GoogleFonts.outfit(fontSize: 20)),
        Text("Admin is working on new questions for you!", style: GoogleFonts.inter(color: Colors.grey[500])),
      ],
    );
  }

  Widget _buildQuizUI(QuizQuestion question, int total) {
    if (_timer == null && !_hasAnswered) _startTimer();

    return Card(
      elevation: 10,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      color: Colors.white,
      margin: const EdgeInsets.all(20),
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            // Progress & Timer
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Question ${_currentIndex + 1} of $total", 
                  style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.grey[600])),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                  decoration: BoxDecoration(
                    color: _timeLeft < 10 ? Colors.red[50] : const Color(0xFF2D5A27).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.timer_outlined, size: 18, color: _timeLeft < 10 ? Colors.red : const Color(0xFF2D5A27)),
                      const SizedBox(width: 8),
                      Text("$_timeLeft s", style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: _timeLeft < 10 ? Colors.red : const Color(0xFF2D5A27))),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            LinearProgressIndicator(
              value: (_currentIndex + 1) / total,
              backgroundColor: Colors.grey[200],
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2D5A27)),
              minHeight: 8,
              borderRadius: BorderRadius.circular(10),
            ),
            const SizedBox(height: 40),
            Text(
              question.question,
              style: GoogleFonts.outfit(fontSize: 26, fontWeight: FontWeight.bold, height: 1.4),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            ...List.generate(question.options.length, (index) => _optionButton(index, question.options[index], question.correctAnswerIndex)),
          ],
        ),
      ),
    );
  }

  Widget _optionButton(int index, String text, int correctIdx) {
    bool isSelected = _selectedAnswer == index;
    bool showCorrect = _hasAnswered && index == correctIdx;
    bool showWrong = isSelected && _hasAnswered && index != correctIdx;

    Color borderColor = Colors.grey[200]!;
    Color bgColor = Colors.white;
    if (showCorrect) {
      borderColor = Colors.green;
      bgColor = Colors.green[50]!;
    } else if (showWrong) {
      borderColor = Colors.red;
      bgColor = Colors.red[50]!;
    } else if (isSelected) {
      borderColor = const Color(0xFF2D5A27);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: InkWell(
        onTap: () => _submitAnswer(index),
        borderRadius: BorderRadius.circular(15),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          decoration: BoxDecoration(
            color: bgColor,
            border: Border.all(color: borderColor, width: 2),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF2D5A27) : Colors.grey[100],
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    String.fromCharCode(65 + index),
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Text(text, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w500)),
              ),
              if (showCorrect) const Icon(Icons.check_circle, color: Colors.green),
              if (showWrong) const Icon(Icons.error, color: Colors.red),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultScreen(int total) {
    double percentage = (_score / total) * 100;
    String feedback = percentage > 80 ? "Amazing Knowledge!" : 
                       percentage > 50 ? "Good Job!" : "Keep Learning!";

    return Card(
      elevation: 10,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      child: Padding(
        padding: const EdgeInsets.all(50),
        child: Column(
          children: [
            Text("🎉 Quiz Completed!", style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.bold, color: const Color(0xFF2D5A27))),
            const SizedBox(height: 30),
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 150,
                  height: 150,
                  child: CircularProgressIndicator(
                    value: percentage / 100,
                    strokeWidth: 12,
                    backgroundColor: Colors.grey[100],
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2D5A27)),
                  ),
                ),
                Column(
                  children: [
                    Text("$_score/$total", style: GoogleFonts.outfit(fontSize: 38, fontWeight: FontWeight.bold)),
                    Text("SCORE", style: GoogleFonts.inter(color: Colors.grey[600], fontSize: 14)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 30),
            Text(feedback, style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: _restartQuiz,
              icon: const Icon(Icons.replay),
              label: const Text("RESTART QUIZ"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2D5A27),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
