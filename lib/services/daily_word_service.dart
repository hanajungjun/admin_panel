import 'package:admin_panel/supabase/supabase.dart';

class DailyWordService {
  final supabase = SupabaseManager.client;

  // ============================================
  // 🔥 저장 (INSERT)
  // ============================================
  Future<void> saveDailyWord({
    required String date,
    required String title,
    required String description,
    required String imageUrl,
    required String timestampOverride,
  }) async {
    await supabase.from('daily_words').insert({
      'date': date,
      'title': title,
      'description': description,
      'image_url': imageUrl,
      'updated_at': DateTime.now().toIso8601String(),
      'date_timestamp': timestampOverride,
    });
  }

  // ============================================
  // 🔥 수정
  // ============================================
  Future<void> updateWord(int id, Map<String, dynamic> data) async {
    await supabase.from('daily_words').update(data).eq('id', id);
  }

  // ============================================
  // 🔥 삭제
  // ============================================
  Future<void> deleteWord(int id) async {
    await supabase.from('daily_words').delete().eq('id', id);
  }

  // ============================================
  // 🔥 모든 단어 가져오기 (기본)
  // ============================================
  Future<List<Map<String, dynamic>>> getAllWords() async {
    final res = await supabase
        .from('daily_words')
        .select()
        .order('date_timestamp', ascending: false);

    return List<Map<String, dynamic>>.from(res);
  }

  // ============================================
  // 🔥 히스토리 페이지 전용
  // ============================================
  Future<List<Map<String, dynamic>>> fetchHistory() async {
    final res = await supabase
        .from('daily_words')
        .select()
        .order('updated_at', ascending: false);

    return List<Map<String, dynamic>>.from(res);
  }

  Future<void> updateExposureDate({
    required int id,
    required DateTime date,
  }) async {
    final formatted =
        '${date.year}'
        '${date.month.toString().padLeft(2, '0')}'
        '${date.day.toString().padLeft(2, '0')}';

    await supabase
        .from('daily_words')
        .update({
          'date': formatted,
          'date_timestamp': date.toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', id);
  }
}
