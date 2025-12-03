import 'package:supabase_flutter/supabase_flutter.dart';

class PushLogService {
  static final _client = Supabase.instance.client;

  /// 전체 로그 삭제
  static Future<void> clearAllLogs() async {
    final res = await _client.from('push_logs').delete().neq('id', -1);

    if (res.error != null) {
      throw Exception("로그 삭제 실패: ${res.error!.message}");
    }
  }
}
