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
import 'history_page.dart';
import 'push_log_page.dart';
import '../supabase/supabase.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  final dailyWordService = DailyWordService();
  final storageService = StorageService();

  DateTime _selectedDate = DateTime.now();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();

  Uint8List? _imageBytes;
  String? _imageName;

  bool _isSaving = false;

  static const String supabaseFunctionUrl =
      "https://uyonjhjgmwbisocdedtw.supabase.co/functions/v1/sendPush";

  bool get isLoggedIn => SupabaseManager.client.auth.currentSession != null;

  // ---------------- 날짜 key ----------------
  String _dateKey(DateTime d) =>
      "${d.year}${d.month.toString().padLeft(2, '0')}${d.day.toString().padLeft(2, '0')}";

  // ---------------- 날짜 선택 ----------------
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(DateTime.now().year + 2),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  // ---------------- 이미지 선택 ----------------
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

  // ---------------- 단어 저장 ----------------
  Future<void> _save() async {
    if (!isLoggedIn) return _showSnack("로그인 후 저장 가능합니다.");
    if (_imageBytes == null) return _showSnack("이미지를 선택하세요.");
    if (_titleController.text.trim().isEmpty) return _showSnack("제목을 입력하세요.");
    if (_descController.text.trim().isEmpty) return _showSnack("내용을 입력하세요.");

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

      _showSnack("저장 완료!");

      _titleController.clear();
      _descController.clear();
      setState(() {
        _imageBytes = null;
        _imageName = null;
      });
    } catch (e) {
      _showSnack("저장 실패: $e");
    } finally {
      setState(() => _isSaving = false);
    }
  }

  // ---------------- 공통 Push 함수 ----------------
  Future<void> _sendPush({required String mode, String? testToken}) async {
    final client = SupabaseManager.client;

    try {
      final res = await http.post(
        Uri.parse(supabaseFunctionUrl),
        headers: {
          "Content-Type": "application/json",
          "Authorization":
              "Bearer ${client.auth.currentSession?.accessToken ?? ''}",
        },
        body: jsonEncode({
          "mode": mode,
          if (testToken != null) "testToken": testToken,
          "title": mode == "test" ? "테스트 알림" : "굿모닝 🙂",
          "body": mode == "test" ? "이건 테스트 발송입니다!" : "오늘의 단어가 업데이트되었습니다!",
        }),
      );

      _showSnack("결과: ${res.body}");
    } catch (e) {
      _showSnack("오류: $e");
    }
  }

  // ---------------- 테스트 발송 ----------------
  Future<void> _sendTestPush() async {
    final textCtrl = TextEditingController();

    final token = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("테스트 기기 Token 입력"),
        content: TextField(
          controller: textCtrl,
          decoration: const InputDecoration(hintText: "FCM Token"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("취소"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, textCtrl.text.trim()),
            child: const Text("발송"),
          ),
        ],
      ),
    );

    if (token != null && token.isNotEmpty) {
      await _sendPush(mode: "test", testToken: token);
    }
  }

  // ---------------- 전체 발송 ----------------
  Future<void> _sendAllPush() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("전체 발송"),
        content: const Text("정말 모든 유저에게 전송할까요?"),
        actions: [
          TextButton(
            child: const Text("취소"),
            onPressed: () => Navigator.pop(context, false),
          ),
          TextButton(
            child: const Text("발송"),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _sendPush(mode: "all");
    }
  }

  // ---------------- Cloudflare 실행 ----------------
  Future<void> _runCloudflare() async {
    _showSnack("Cloudflare Worker 실행 중…");

    try {
      await http.get(
        Uri.parse("https://daily-push-worker.goodday-02.workers.dev/run"),
      );

      _showSnack("Cloudflare 실행 요청 완료");
    } catch (e) {
      _showSnack("Cloudflare 오류: $e");
    }
  }

  // ---------------- 로그인 ----------------
  Future<void> _showLoginDialog() async {
    final emailCtrl = TextEditingController(text: "kodero@kakao.com");
    final pwCtrl = TextEditingController(text: "0000");

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("관리자 로그인"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: emailCtrl,
              decoration: const InputDecoration(labelText: "이메일"),
            ),
            TextField(
              controller: pwCtrl,
              obscureText: true,
              decoration: const InputDecoration(labelText: "비밀번호"),
            ),
          ],
        ),
        actions: [
          TextButton(
            child: const Text("취소"),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text("로그인"),
            onPressed: () async {
              try {
                await SupabaseManager.client.auth.signInWithPassword(
                  email: emailCtrl.text.trim(),
                  password: pwCtrl.text.trim(),
                );
                Navigator.pop(context);
                setState(() {});
                _showSnack("로그인 성공");
              } catch (e) {
                _showSnack("로그인 실패: $e");
              }
            },
          ),
        ],
      ),
    );
  }

  Future<void> _logout() async {
    await SupabaseManager.client.auth.signOut();
    setState(() {});
  }

  void _showSnack(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    final dateLabel = _dateKey(_selectedDate);

    return Scaffold(
      body: Row(
        children: [
          // ---------------- LEFT: 입력 폼 + 저장 버튼 ----------------
          Expanded(
            child: Column(
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
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(controller: _titleController),

                        const SizedBox(height: 24),
                        const Text(
                          "내용",
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _descController,
                          maxLines: 10,
                          decoration: const InputDecoration(
                            hintText: "HTML 입력 가능",
                          ),
                        ),

                        const SizedBox(height: 24),
                        const Text(
                          "미리보기 (HTML)",
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 12),
                        HtmlPreview(text: _descController.text),

                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),

                // 항상 보이는 저장 버튼
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  color: const Color(0xFF1A1A1A),
                  child: SafeArea(
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: _isSaving ? null : _save,
                        icon: _isSaving
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.cloud_upload),
                        label: Text(_isSaving ? "저장 중..." : "저장"),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ---------------- RIGHT: 사이드 메뉴 ----------------
          SizedBox(
            width: 260,
            child: Container(
              color: const Color(0xFF1B1B1B),
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 로그인 버튼
                  SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: isLoggedIn ? _logout : _showLoginDialog,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        backgroundColor: const Color(0xFF2A2A2A),
                        foregroundColor: Colors.white,
                        elevation: 0,
                      ),
                      child: Text(isLoggedIn ? "로그아웃" : "로그인"),
                    ),
                  ),

                  const SizedBox(height: 32),
                  const Text(
                    "🔔 알림 관리",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),

                  _sideButton("테스트 발송", _sendTestPush),
                  _sideButton("전체 발송", _sendAllPush),
                  _sideButton("Cloudflare 실행", _runCloudflare),
                  _sideButton("알림 로그", () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const PushLogPage()),
                    );
                  }),

                  const SizedBox(height: 32),
                  Container(height: 1, color: Colors.white24),
                  const SizedBox(height: 32),

                  const Text(
                    "📂 히스토리",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),

                  _sideButton("히스토리 관리", () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const HistoryPage()),
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 예쁜 사이드 버튼 UI
  Widget _sideButton(String label, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: SizedBox(
        height: 46,
        child: OutlinedButton(
          onPressed: onTap,
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Colors.white24, width: 1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            foregroundColor: const Color(0xFFDAD0FF),
          ),
          child: Text(label),
        ),
      ),
    );
  }
}

class TextFieldController extends TextEditingController {}
