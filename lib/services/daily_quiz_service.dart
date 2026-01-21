import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../supabase/supabase.dart';
import '../models/quiz_model.dart';

class DailyQuizService {
  final SupabaseClient _client = SupabaseManager.client;

  /// ===============================
  /// 날짜 기준 퀴즈 조회 (yyyyMMdd)
  /// ===============================
  Future<DailyQuizModel?> getQuiz(String date) async {
    try {
      final res = await _client
          .from('daily_quiz')
          .select()
          .eq('date', date)
          .maybeSingle(); // ❗ single() 대신 maybeSingle()

      if (res == null) return null;

      return DailyQuizModel.fromJson(res);
    } catch (e) {
      debugPrint('❌ getQuiz error: $e');
      return null;
    }
  }

  /// ===============================
  /// 퀴즈 저장 (insert / update)
  /// - date 기준 upsert
  /// ===============================
  Future<bool> saveQuiz({
    required String date,
    required String question,
    required String answer,
    String? explanation,
    required String timestamp,
  }) async {
    try {
      await _client.from('daily_quiz').upsert({
        'date': date,
        'question': question,
        'answer': answer,
        'explanation': explanation, // nullable OK
        'date_timestamp': timestamp,
        'updated_at': DateTime.now().toIso8601String(),
      }, onConflict: 'date');

      return true;
    } catch (e) {
      debugPrint('❌ saveQuiz error: $e');
      return false;
    }
  }

  /// ===============================
  /// 퀴즈 삭제
  /// ===============================
  Future<bool> deleteQuiz(String date) async {
    try {
      await _client.from('daily_quiz').delete().eq('date', date);

      return true;
    } catch (e) {
      debugPrint('❌ deleteQuiz error: $e');
      return false;
    }
  }
}
