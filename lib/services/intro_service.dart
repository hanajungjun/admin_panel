import 'package:supabase_flutter/supabase_flutter.dart';

class IntroService {
  static final _supabase = Supabase.instance.client;

  static Future<Map<String, dynamic>> fetchIntro() async {
    return await _supabase
        .from('app_intro')
        .select()
        .eq('is_active', true)
        .single();
  }

  static Future<void> updateIntro({
    required String title,
    required String subtitle,
    String? imageUrl,
  }) async {
    await _supabase
        .from('app_intro')
        .update({
          'title': title,
          'subtitle': subtitle,
          if (imageUrl != null) 'image_url': imageUrl,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('is_active', true);
  }
}
