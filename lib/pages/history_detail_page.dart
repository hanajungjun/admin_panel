import 'package:flutter/material.dart';
import '../models/daily_word.dart';
import '../services/daily_word_service.dart';
import 'edit_page.dart';
import '../utils/date_formatter.dart';

class HistoryDetailPage extends StatefulWidget {
  final DailyWord word;

  const HistoryDetailPage({super.key, required this.word});

  @override
  State<HistoryDetailPage> createState() => _HistoryDetailPageState();
}

class _HistoryDetailPageState extends State<HistoryDetailPage> {
  late DailyWord word;
  final dailyWordService = DailyWordService();

  @override
  void initState() {
    super.initState();
    word = widget.word;
  }

  String get exposureDateFormatted {
    final raw = word.date; // YYYYMMDD
    if (raw.length != 8) return '날짜 없음';
    return '${raw.substring(0, 4)}.'
        '${raw.substring(4, 6)}.'
        '${raw.substring(6, 8)}';
  }

  Future<void> _changeExposureDate() async {
    final initial = DateTime(
      int.parse(word.date.substring(0, 4)),
      int.parse(word.date.substring(4, 6)),
      int.parse(word.date.substring(6, 8)),
    );

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked == null) return;

    await dailyWordService.updateExposureDate(id: word.id, date: picked);

    setState(() {
      word = word.copyWith(
        date:
            '${picked.year}'
            '${picked.month.toString().padLeft(2, '0')}'
            '${picked.day.toString().padLeft(2, '0')}',
        updatedAt: DateTime.now(),
      );
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('노출일이 수정되었습니다')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(word.title),
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
                builder: (_) => AlertDialog(
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
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: SizedBox(
                width: double.infinity,
                height: 350,
                child: Image.network(word.imageUrl, fit: BoxFit.contain),
              ),
            ),

            const SizedBox(height: 24),

            Text(
              word.title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            // 🔥 노출일 수정 영역
            InkWell(
              onTap: _changeExposureDate,
              child: Row(
                children: [
                  Text(
                    '노출일: $exposureDateFormatted',
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.edit, size: 16, color: Colors.grey),
                ],
              ),
            ),

            const SizedBox(height: 8),

            Text(
              '작성일: ${formatDate(word.updatedAt)}',
              style: const TextStyle(fontSize: 13, color: Colors.grey),
            ),

            const SizedBox(height: 24),

            Text(word.description, style: const TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
