import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:admin_panel/supabase/supabase.dart';

class StorageService {
  final storage = SupabaseManager.client.storage;

  Future<String> uploadImage({
    required String dateKey,
    required Uint8List bytes,
  }) async {
    // 🔥 고유 파일명 생성 (날짜 + timestamp)
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final fileName = "${dateKey}_$timestamp.png";

    await storage
        .from('daily_images')
        .uploadBinary(
          fileName,
          bytes,
          fileOptions: const FileOptions(
            upsert: false,
            contentType: 'image/png',
          ),
        );

    return storage.from('daily_images').getPublicUrl(fileName);
  }
}
