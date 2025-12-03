import 'package:flutter/material.dart';

class PushLogDetailPage extends StatelessWidget {
  final Map<String, dynamic> log;

  const PushLogDetailPage({super.key, required this.log});

  @override
  Widget build(BuildContext context) {
    final mode = log['mode'] ?? '';
    final title = log['title'] ?? '';
    final body = log['body'] ?? '';
    final createdAt = log['created_at'] ?? '';

    final target = log['target_count'] ?? 0;
    final success = log['success_count'] ?? 0;
    final fail = log['fail_count'] ?? 0;

    final details = log['details']; // 실패 토큰 리스트

    return Scaffold(
      appBar: AppBar(title: const Text("알림 상세 기록")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _section("발송 모드", mode),
            _section("제목", title),
            _section("메시지 내용", body),
            _section("발송 시각", createdAt),

            const SizedBox(height: 20),
            const Divider(),

            _section("전체 대상", "$target명"),
            _section("성공", "$success명"),
            _section("실패", "$fail명"),

            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 20),

            const Text(
              "실패한 기기 토큰",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            if (details == null || (details is List && details.isEmpty))
              const Text(
                "모두 성공. 실패 없음 🎉",
                style: TextStyle(color: Colors.green),
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: (details as List)
                    .map(
                      (t) => Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          t.toString(),
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                    )
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _section(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(fontSize: 15)),
        ],
      ),
    );
  }
}
