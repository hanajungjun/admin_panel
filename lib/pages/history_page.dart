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
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                "에러 발생: ${snapshot.error}",
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("히스토리가 없습니다"));
          }

          final list = snapshot.data!;

          return ListView.builder(
            itemCount: list.length,
            itemBuilder: (context, i) {
              final item = list[i];

              // ✅ 노출일 (date: text → 날짜만)
              final exposureDateStr = item['date']; // 예: 2025-12-28
              final exposureDate = exposureDateStr != null
                  ? exposureDateStr.replaceAll('-', '.')
                  : null;

              // ✅ 작성일 (updated_at)
              final updatedAtStr = item['updated_at'];
              final updatedAt = updatedAtStr != null
                  ? DateTime.tryParse(updatedAtStr)
                  : null;

              return ListTile(
                dense: true,
                title: Text(item['title'] ?? ''),
                subtitle: Text(
                  (() {
                    // ✅ 노출일 (YYYYMMDD → YYYY.MM.DD)
                    final rawDate = item['date'];
                    String? exposureDate;

                    if (rawDate != null && rawDate.length == 8) {
                      exposureDate =
                          '${rawDate.substring(0, 4)}.'
                          '${rawDate.substring(4, 6)}.'
                          '${rawDate.substring(6, 8)}';
                    }

                    // ✅ 작성일
                    final updatedAtStr = item['updated_at'];
                    final updatedAt = updatedAtStr != null
                        ? DateTime.tryParse(updatedAtStr)
                        : null;

                    if (exposureDate != null && updatedAt != null) {
                      return '노출일: $exposureDate · 작성일: ${formatDate(updatedAt)}';
                    }

                    return '날짜 정보 없음';
                  })(),
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
