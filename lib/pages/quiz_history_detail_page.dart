import 'package:flutter/material.dart';
import '../models/quiz_model.dart';
import '../services/daily_quiz_service.dart';
import 'quiz_edit_page.dart';

class QuizHistoryDetailPage extends StatefulWidget {
  final DailyQuizModel quiz;

  const QuizHistoryDetailPage({super.key, required this.quiz});

  @override
  State<QuizHistoryDetailPage> createState() => _QuizHistoryDetailPageState();
}

class _QuizHistoryDetailPageState extends State<QuizHistoryDetailPage> {
  late DailyQuizModel quiz;
  final _quizService = DailyQuizService();

  @override
  void initState() {
    super.initState();
    quiz = widget.quiz;
  }

  String get formattedDate {
    final raw = quiz.date;
    if (raw.length != 8) return raw;
    return '${raw.substring(0, 4)}.${raw.substring(4, 6)}.${raw.substring(6, 8)}';
  }

  // 날짜 변경 로직 (기존 삭제 후 새 날짜 생성)
  Future<void> _changeDate() async {
    final initial = DateTime(
      int.parse(quiz.date.substring(0, 4)),
      int.parse(quiz.date.substring(4, 6)),
      int.parse(quiz.date.substring(6, 8)),
    );

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked == null || picked == initial) return;

    final newDateKey =
        '${picked.year}${picked.month.toString().padLeft(2, '0')}${picked.day.toString().padLeft(2, '0')}';

    await _quizService.saveQuiz(
      date: newDateKey,
      question: quiz.question,
      answer: quiz.answer,
      explanation: quiz.explanation,
      dateTimestamp: picked.toIso8601String(),
    );

    await _quizService.deleteQuiz(quiz.date);

    setState(() {
      quiz = quiz.copyWith(date: newDateKey);
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('날짜가 변경되었습니다.')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('퀴즈 상세'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              // 🔥 반환값을 dynamic으로 받아 타입 에러 방지
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => QuizEditPage(quiz: quiz)),
              );

              // 수정된 모델 객체가 돌아오면 상태 업데이트
              if (result != null && result is DailyQuizModel) {
                setState(() => quiz = result);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: _confirmDelete,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: _changeDate,
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: Colors.blue,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '퀴즈 날짜: $formattedDate',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.edit, size: 14, color: Colors.grey),
                ],
              ),
            ),
            const Divider(height: 40),
            const Text(
              '💡 문제',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              quiz.question,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            const Text(
              '✅ 정답',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                quiz.answer,
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.green,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              '📝 해설',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              quiz.explanation ?? '해설 없음',
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('삭제', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (ok == true) {
      await _quizService.deleteQuiz(quiz.date);
      if (mounted) Navigator.pop(context, true);
    }
  }
}
