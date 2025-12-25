import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../services/intro_service.dart';
import '../services/intro_image_upload_service.dart';

class AdminIntroPage extends StatefulWidget {
  const AdminIntroPage({super.key});

  @override
  State<AdminIntroPage> createState() => _AdminIntroPageState();
}

class _AdminIntroPageState extends State<AdminIntroPage> {
  final _titleCtrl = TextEditingController();
  final _subtitleCtrl = TextEditingController();

  Uint8List? _imageBytes; // 새로 선택한 이미지
  String? _imageUrl; // 현재 사용 중인 이미지 URL
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  // ---------------- 기존 인트로 불러오기 ----------------
  Future<void> _load() async {
    final data = await IntroService.fetchIntro();

    _titleCtrl.text = data['title'] ?? '';
    _subtitleCtrl.text = data['subtitle'] ?? '';
    _imageUrl = data['image_url'];

    setState(() => _loading = false);
  }

  // ---------------- 이미지 선택 ----------------
  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );
    if (result != null && result.files.single.bytes != null) {
      setState(() {
        _imageBytes = result.files.single.bytes;
      });
    }
  }

  // ---------------- 저장 ----------------
  Future<void> _save() async {
    String? imageUrl = _imageUrl;

    if (_imageBytes != null) {
      imageUrl = await IntroImageUploadService.uploadIntroImage(
        _imageBytes!,
        'intro_main.png',
      );
    }

    await IntroService.updateIntro(
      title: _titleCtrl.text.trim(),
      subtitle: _subtitleCtrl.text.trim(),
      imageUrl: imageUrl,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('인트로 저장 완료')));

    // 잠깐 보여주고 뒤로
    await Future.delayed(const Duration(milliseconds: 800));

    if (mounted) {
      Navigator.pop(context);
    }
  }

  // ---------------- 이미지 미리보기 ----------------
  Widget _buildImagePreview() {
    // 새로 선택한 이미지
    if (_imageBytes != null) {
      return Image.memory(_imageBytes!, fit: BoxFit.contain);
    }

    // 기존 저장된 이미지
    if (_imageUrl != null && _imageUrl!.isNotEmpty) {
      return Image.network(
        _imageUrl!,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) {
          return const Center(child: Text('이미지 로드 실패'));
        },
      );
    }

    // 아무것도 없을 때
    return const Center(
      child: Text('등록된 이미지 없음', style: TextStyle(color: Colors.black38)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('인트로 관리')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('메인 문구'),
                  const SizedBox(height: 8),
                  TextField(controller: _titleCtrl, maxLines: 2),

                  const SizedBox(height: 24),
                  const Text('서브 문구'),
                  const SizedBox(height: 8),
                  TextField(controller: _subtitleCtrl),

                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _pickImage,
                    child: const Text('이미지 선택'),
                  ),

                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    height: 220,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.black12,
                    ),
                    clipBehavior: Clip.hardEdge,
                    child: _buildImagePreview(),
                  ),

                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _save,
                      child: const Text('저장'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
