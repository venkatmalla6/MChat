import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/quiz_provider.dart';
import 'quiz_screen.dart';

class EditQuizScreen extends ConsumerStatefulWidget {
  final List<Map<String, dynamic>> mcqs;

  const EditQuizScreen({super.key, required this.mcqs});

  @override
  ConsumerState<EditQuizScreen> createState() => _EditQuizScreenState();
}

class _EditQuizScreenState extends ConsumerState<EditQuizScreen> {
  late List<Map<String, dynamic>> _editableMcqs;

  @override
  void initState() {
    super.initState();
    _editableMcqs = List<Map<String, dynamic>>.from(
      widget.mcqs.map((m) => Map<String, dynamic>.from(m)),
    );
  }

  void _editMcq(int index) async {
    final mcq = _editableMcqs[index];
    final questionController = TextEditingController(text: mcq['question']);
    final List<TextEditingController> optionControllers = (mcq['options'] as List)
        .map((opt) => TextEditingController(text: opt.toString()))
        .toList();
    String currentAnswer = mcq['answer'];

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Question'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: questionController,
                decoration: const InputDecoration(labelText: 'Question'),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              ...List.generate(4, (i) {
                return TextField(
                  controller: optionControllers[i],
                  decoration: InputDecoration(labelText: 'Option ${['A', 'B', 'C', 'D'][i]}'),
                );
              }),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: currentAnswer,
                items: ['A', 'B', 'C', 'D']
                    .map((label) => DropdownMenuItem(value: label, child: Text('Correct: $label')))
                    .toList(),
                onChanged: (val) => currentAnswer = val!,
                decoration: const InputDecoration(labelText: 'Correct Answer'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context, {
                'question': questionController.text,
                'options': optionControllers.map((c) => c.text).toList(),
                'answer': currentAnswer,
              });
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result != null) {
      setState(() {
        _editableMcqs[index] = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Review & Edit'),
        actions: [
          TextButton.icon(
            onPressed: () {
              ref.read(quizProvider.notifier).updateAllMcqs(_editableMcqs);
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => QuizScreen(mcqs: _editableMcqs)),
              );
            },
            icon: const Icon(Icons.play_arrow_rounded, color: AppColors.primary),
            label: const Text('Start Quiz', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(24),
        itemCount: _editableMcqs.length,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final mcq = _editableMcqs[index];
          return Card(
            child: ListTile(
              title: Text(mcq['question'], maxLines: 2, overflow: TextOverflow.ellipsis),
              subtitle: Text('Correct Answer: ${mcq['answer']}'),
              trailing: IconButton(
                icon: const Icon(Icons.edit_note_rounded, color: AppColors.primary),
                onPressed: () => _editMcq(index),
              ),
            ),
          );
        },
      ),
    );
  }
}
