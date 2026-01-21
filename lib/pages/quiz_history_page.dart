import 'package:flutter/material.dart';

import '../services/daily_quiz_service.dart';
import '../models/quiz_model.dart';
import 'quiz_history_detail_page.dart';

class QuizHistoryPage extends StatefulWidget {
  const QuizHistoryPage({super.key});

  @override
  State<QuizHistoryPage> createState() => _QuizHistoryPageState();
}

class _QuizHistoryPageState extends State<QuizHistoryPage> {
  final DailyQuizService quizService = DailyQuizService();
  late Future<List<DailyQuizModel>> historyFuture;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    setState(() {
      historyFuture = quizService.fetchHistory();
    });
  }

  String _formatDate(String raw) {
    if (raw.length != 8) return raw;
    return '${raw.substring(0, 4)}.'
        '${raw.substring(4, 6)}.'
        '${raw.substring(6, 8)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('퀴즈 관리 히스토리')),
      body: FutureBuilder<List<DailyQuizModel>>(
        future: historyFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                '에러 발생: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          final list = snapshot.data ?? [];

          if (list.isEmpty) {
            return const Center(child: Text('퀴즈 히스토리가 없습니다'));
          }

          return ListView.builder(
            itemCount: list.length,
            itemBuilder: (context, index) {
              final quiz = list[index];

              return ListTile(
                dense: true,
                title: Text(
                  quiz.question,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  '노출일: ${_formatDate(quiz.date)}'
                  '${quiz.updatedAt != null ? ' · 수정일: ${quiz.updatedAt!.toLocal()}' : ''}',
                  style: const TextStyle(fontSize: 13),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () async {
                  final changed = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => QuizHistoryDetailPage(quiz: quiz),
                    ),
                  );

                  if (changed == true) {
                    _reload();
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}
