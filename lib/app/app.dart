import '../../supabase/supabase.dart';

class AppBootstrap {
  static Future<void> run() async {
    await SupabaseManager.initialize();
  }
}
