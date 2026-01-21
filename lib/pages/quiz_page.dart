import 'package:flutter/material.dart';

import '../services/daily_quiz_service.dart';
import '../supabase/supabase.dart';

class QuizPage extends StatefulWidget {
  const QuizPage({super.key});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  final DailyQuizService _quizService = DailyQuizService();

  DateTime _selectedDate = DateTime.now();

  final _questionController = TextEditingController();
  final _answerController = TextEditingController();
  final _explainController = TextEditingController();

  bool _loading = false;

  bool get isLoggedIn => SupabaseManager.client.auth.currentSession != null;

  // ---------------- 날짜 key ----------------
  String _dateKey(DateTime d) =>
      "${d.year}${d.month.toString().padLeft(2, '0')}${d.day.toString().padLeft(2, '0')}";

  // ---------------- 날짜 선택 ----------------
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(DateTime.now().year + 2),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
      await _loadQuiz();
    }
  }

  // ---------------- 퀴즈 불러오기 ----------------
  Future<void> _loadQuiz() async {
    final dateKey = _dateKey(_selectedDate);

    final quiz = await _quizService.getQuiz(dateKey);

    if (!mounted) return;

    if (quiz == null) {
      _questionController.clear();
      _answerController.clear();
      _explainController.clear();
      return;
    }

    _questionController.text = quiz.question;
    _answerController.text = quiz.answer;
    _explainController.text = quiz.explanation ?? '';
  }

  // ---------------- 저장 ----------------
  Future<void> _save() async {
    if (!isLoggedIn) return _snack("로그인 필요");
    if (_questionController.text.trim().isEmpty) {
      return _snack("문제를 입력하세요");
    }
    if (_answerController.text.trim().isEmpty) {
      return _snack("정답을 입력하세요");
    }

    setState(() => _loading = true);

    try {
      final dateKey = _dateKey(_selectedDate);

      final timestamp = DateTime.utc(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
      ).toIso8601String();

      await _quizService.saveQuiz(
        date: dateKey,
        question: _questionController.text.trim(),
        answer: _answerController.text.trim(),
        explanation: _explainController.text.trim(),
        timestamp: timestamp,
      );

      _snack("저장 완료");
    } catch (e) {
      _snack("저장 실패: $e");
    } finally {
      setState(() => _loading = false);
    }
  }

  // ---------------- 삭제 ----------------
  Future<void> _delete() async {
    if (!isLoggedIn) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("삭제"),
        content: const Text("이 날짜의 퀴즈를 삭제할까요?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("취소"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("삭제"),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    await _quizService.deleteQuiz(_dateKey(_selectedDate));

    _questionController.clear();
    _answerController.clear();
    _explainController.clear();

    _snack("삭제 완료");
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    final dateLabel = _dateKey(_selectedDate);

    return Scaffold(
      appBar: AppBar(
        title: const Text("퀴즈 관리"),
        actions: [
          IconButton(icon: const Icon(Icons.delete), onPressed: _delete),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 날짜
            Row(
              children: [
                Text("날짜: $dateLabel"),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _pickDate,
                  child: const Text("날짜 선택"),
                ),
              ],
            ),

            const SizedBox(height: 24),

            const Text("문제"),
            const SizedBox(height: 8),
            TextField(controller: _questionController),

            const SizedBox(height: 24),

            const Text("정답"),
            const SizedBox(height: 8),
            TextField(controller: _answerController),

            const SizedBox(height: 24),

            const Text("해설 (선택)"),
            const SizedBox(height: 8),
            TextField(controller: _explainController, maxLines: 5),

            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _loading ? null : _save,
                child: Text(_loading ? "저장 중..." : "저장"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
