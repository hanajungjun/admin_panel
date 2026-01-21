import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../services/daily_word_service.dart';
import '../services/storage_service.dart';
import '../widgets/date_picker_row.dart';
import '../widgets/image_preview.dart';
import '../widgets/html_preview.dart';

import '../supabase/supabase.dart';

class WordPage extends StatefulWidget {
  const WordPage({super.key});

  @override
  State<WordPage> createState() => _AdminWordPageState();
}

class _AdminWordPageState extends State<WordPage> {
  final dailyWordService = DailyWordService();
  final storageService = StorageService();

  DateTime _selectedDate = DateTime.now();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();

  Uint8List? _imageBytes;
  String? _imageName;

  bool _isSaving = false;

  bool get isLoggedIn => SupabaseManager.client.auth.currentSession != null;

  String _dateKey(DateTime d) =>
      "${d.year}${d.month.toString().padLeft(2, '0')}${d.day.toString().padLeft(2, '0')}";

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(DateTime.now().year + 2),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _imageBytes = result.files.single.bytes;
        _imageName = result.files.single.name;
      });
    }
  }

  Future<void> _save() async {
    if (!isLoggedIn) return _snack("로그인 후 저장 가능");
    if (_imageBytes == null) return _snack("이미지 선택");
    if (_titleController.text.trim().isEmpty) return _snack("제목 입력");
    if (_descController.text.trim().isEmpty) return _snack("내용 입력");

    setState(() => _isSaving = true);

    try {
      final dateKey = _dateKey(_selectedDate);

      final imageUrl = await storageService.uploadImage(
        dateKey: dateKey,
        bytes: _imageBytes!,
      );

      final timestamp = DateTime.utc(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
      ).toIso8601String();

      await dailyWordService.saveDailyWord(
        date: dateKey,
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        imageUrl: imageUrl,
        timestampOverride: timestamp,
      );

      _snack("저장 완료");
      _titleController.clear();
      _descController.clear();
      setState(() {
        _imageBytes = null;
        _imageName = null;
      });
    } catch (e) {
      _snack("저장 실패: $e");
    } finally {
      setState(() => _isSaving = false);
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final dateLabel = _dateKey(_selectedDate);

    return Scaffold(
      appBar: AppBar(
        title: const Text("단어 관리"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DatePickerRow(
                    dateLabel: dateLabel,
                    onPickDate: _pickDate,
                    onPickImage: _pickImage,
                    imageName: _imageName,
                  ),
                  const SizedBox(height: 16),
                  ImagePreview(bytes: _imageBytes),
                  const SizedBox(height: 24),

                  const Text(
                    "제목",
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  TextField(controller: _titleController),

                  const SizedBox(height: 24),
                  const Text(
                    "내용",
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _descController,
                    maxLines: 10,
                    decoration: const InputDecoration(hintText: "HTML 입력 가능"),
                  ),

                  const SizedBox(height: 24),
                  const Text(
                    "미리보기 (HTML)",
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  HtmlPreview(text: _descController.text),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _save,
                  child: Text(_isSaving ? "저장 중..." : "저장"),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
