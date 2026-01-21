import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../supabase/supabase.dart';
import '../models/quiz_model.dart';

class DailyQuizService {
  final SupabaseClient _client = SupabaseManager.client;

  /// ===============================
  /// 오늘 퀴즈 조회 (date 기준)
  /// ===============================
  Future<DailyQuizModel?> getQuiz(String date) async {
    try {
      final res = await _client
          .from('daily_quiz')
          .select()
          .eq('date', date)
          .maybeSingle();

      if (res == null) return null;
      return DailyQuizModel.fromJson(res);
    } catch (e) {
      debugPrint('❌ getQuiz error: $e');
      return null;
    }
  }

  /// ===============================
  /// 퀴즈 히스토리 조회 (최신순)
  /// ===============================
  Future<List<DailyQuizModel>> fetchHistory() async {
    try {
      final res = await _client
          .from('daily_quiz')
          .select()
          .order('date', ascending: false);

      return (res as List).map((e) => DailyQuizModel.fromJson(e)).toList();
    } catch (e) {
      debugPrint('❌ fetchHistory error: $e');
      return [];
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
    required String dateTimestamp, // UI에서 넘겨주는 날짜 기반 타임스탬프
  }) async {
    try {
      await _client.from('daily_quiz').upsert({
        'date': date,
        'question': question,
        'answer': answer,
        'explanation': explanation,
        'updated_at': DateTime.now().toIso8601String(),
        'date_timestamp': dateTimestamp, // 전달받은 값 사용
      }, onConflict: 'date');

      return true;
    } catch (e) {
      debugPrint('❌ saveQuiz error: $e');
      return false;
    }
  }

  /// ===============================
  /// 퀴즈 삭제 (date 기준)
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
