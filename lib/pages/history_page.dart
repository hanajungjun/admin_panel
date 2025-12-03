import 'package:flutter/material.dart';
import '../services/daily_word_service.dart';
import '../models/daily_word.dart';
import 'history_detail_page.dart';
import '../utils/date_formatter.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final dailyWordService = DailyWordService();
  late Future<List<Map<String, dynamic>>> historyFuture;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    setState(() {
      historyFuture = dailyWordService.fetchHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("히스토리")),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: historyFuture,
        builder: (context, snapshot) {
          // 로딩 중
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // 에러 발생
          if (snapshot.hasError) {
            return Center(
              child: Text(
                "에러 발생: ${snapshot.error}",
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          // 데이터 없음
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("히스토리가 없습니다"));
          }

          final list = snapshot.data!;

          return ListView.builder(
            itemCount: list.length,
            itemBuilder: (context, i) {
              final item = list[i];

              final updatedAtStr = item['updated_at'];
              final updatedAt = updatedAtStr != null
                  ? DateTime.tryParse(updatedAtStr)
                  : null;

              return ListTile(
                dense: true,
                title: Text(item['title'] ?? ''),
                subtitle: Text(
                  updatedAt != null ? formatDate(updatedAt) : "날짜 없음",
                  style: const TextStyle(fontSize: 13),
                ),
                trailing: const Icon(Icons.chevron_right),

                onTap: () async {
                  final changed = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          HistoryDetailPage(word: DailyWord.fromMap(item)),
                    ),
                  );

                  if (changed == true) _reload();
                },
              );
            },
          );
        },
      ),
    );
  }
}
