import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';

class IntroImageUploadService {
  static final _supabase = Supabase.instance.client;

  static Future<String> uploadIntroImage(
    Uint8List bytes,
    String fileName,
  ) async {
    final path = 'main/$fileName';

    await _supabase.storage
        .from('intro')
        .uploadBinary(
          path,
          bytes,
          fileOptions: const FileOptions(upsert: true),
        );

    return _supabase.storage.from('intro').getPublicUrl(path);
  }
}
