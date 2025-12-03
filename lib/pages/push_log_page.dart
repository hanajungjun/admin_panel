import 'package:flutter/material.dart';
import 'package:admin_panel/supabase/supabase.dart';
import 'push_log_detail_page.dart';

class PushLogPage extends StatefulWidget {
  const PushLogPage({super.key});

  @override
  State<PushLogPage> createState() => _PushLogPageState();
}

class _PushLogPageState extends State<PushLogPage> {
  final supabase = SupabaseManager.client;

  Future<void> _clearAllLogs() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("전체 로그 삭제"),
        content: const Text("정말 전체 로그를 삭제할까요?\n한번 삭제하면 복구할 수 없습니다."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("취소"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("삭제"),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    // 전체 삭제 실행
    await supabase.from('push_logs').delete().neq('id', -1);

    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("전체 로그 삭제 완료")));

    setState(() {}); // 새로고침
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("알림 로그"),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever),
            tooltip: "전체 삭제",
            onPressed: _clearAllLogs,
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: supabase
            .from('push_logs')
            .select()
            .order('created_at', ascending: false),
        builder: (context, snapshot) {
          // 로딩 상태
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // 에러 상태
          if (snapshot.hasError) {
            return Center(
              child: Text(
                "불러오기 오류: ${snapshot.error}",
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          // 빈 상태
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("알림 로그가 없습니다."));
          }

          final logs = snapshot.data!;

          return ListView.separated(
            itemCount: logs.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final log = logs[index];

              final mode = log['mode'] ?? 'unknown';
              final title = log['title'] ?? '(제목 없음)';
              final ts = log['created_at'] ?? '';
              final success = log['success_count'] ?? 0;
              final fail = log['fail_count'] ?? 0;

              return ListTile(
                title: Text("[$mode] $title"),
                subtitle: Text(
                  "$ts\n성공: $success / 실패: $fail",
                  style: const TextStyle(height: 1.4),
                ),
                isThreeLine: true,
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PushLogDetailPage(log: log),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
