import 'package:flutter/material.dart';
import '../models/daily_word.dart';
import '../services/daily_word_service.dart';
import 'edit_page.dart';
import '../utils/date_formatter.dart';

class HistoryDetailPage extends StatelessWidget {
  final DailyWord word;

  const HistoryDetailPage({super.key, required this.word});

  @override
  Widget build(BuildContext context) {
    final dailyWordService = DailyWordService();

    return Scaffold(
      appBar: AppBar(
        title: Text("${word.title} (${formatDate(word.updatedAt)})"),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final changed = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => EditPage(word: word)),
              );

              if (changed == true) {
                Navigator.pop(context, true);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () async {
              final confirm = await showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("삭제하시겠습니까?"),
                  content: const Text("이 항목은 영구적으로 삭제됩니다."),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text("취소"),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text(
                        "삭제",
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                await dailyWordService.deleteWord(word.id);
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text("삭제 완료!")));
                Navigator.pop(context, true);
              }
            },
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔥 이미지 크기 안정화 + contain + 둥근 모서리
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: SizedBox(
                width: double.infinity,
                height: 350, // ← 원하는 크기
                child: Image.network(
                  word.imageUrl,
                  fit: BoxFit.contain, // 안 짤림
                ),
              ),
            ),

            const SizedBox(height: 24),

            Text(
              word.title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 24),

            Text(word.description, style: const TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
