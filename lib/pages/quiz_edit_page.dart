import 'package:flutter/material.dart';
import '../models/quiz_model.dart';
import '../services/daily_quiz_service.dart';

class QuizEditPage extends StatefulWidget {
  final DailyQuizModel quiz;

  const QuizEditPage({super.key, required this.quiz});

  @override
  State<QuizEditPage> createState() => _QuizEditPageState();
}

class _QuizEditPageState extends State<QuizEditPage> {
  final _quizService = DailyQuizService();
  late TextEditingController _questionController;
  late TextEditingController _answerController;
  late TextEditingController _explainController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _questionController = TextEditingController(text: widget.quiz.question);
    _answerController = TextEditingController(text: widget.quiz.answer);
    _explainController = TextEditingController(
      text: widget.quiz.explanation ?? '',
    );
  }

  String _generateTimestamp(String dateKey) {
    final year = int.parse(dateKey.substring(0, 4));
    final month = int.parse(dateKey.substring(4, 6));
    final day = int.parse(dateKey.substring(6, 8));
    return DateTime.utc(year, month, day).toIso8601String();
  }

  Future<void> _save() async {
    if (_questionController.text.trim().isEmpty ||
        _answerController.text.trim().isEmpty)
      return;

    setState(() => _isSaving = true);

    // 1. 수정된 데이터 객체 생성
    final updatedQuiz = widget.quiz.copyWith(
      question: _questionController.text.trim(),
      answer: _answerController.text.trim(),
      explanation: _explainController.text.trim().isEmpty
          ? null
          : _explainController.text.trim(),
    );

    // 2. 서버 저장
    final ok = await _quizService.saveQuiz(
      date: updatedQuiz.date,
      question: updatedQuiz.question,
      answer: updatedQuiz.answer,
      explanation: updatedQuiz.explanation,
      dateTimestamp: _generateTimestamp(updatedQuiz.date),
    );

    setState(() => _isSaving = false);

    if (ok) {
      // 🔥 핵심: 수정된 객체를 그대로 돌려보냄 (이게 없으면 상세화면 갱신이 안됨)
      Navigator.pop(context, updatedQuiz);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('저장 실패')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("퀴즈 수정하기"),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isSaving ? null : _save,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("문제", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _questionController,
              maxLines: 3,
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
            const SizedBox(height: 24),
            const Text("정답", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _answerController,
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
            const SizedBox(height: 24),
            const Text(
              "해설 (선택)",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _explainController,
              maxLines: 5,
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _questionController.dispose();
    _answerController.dispose();
    _explainController.dispose();
    super.dispose();
  }
}
