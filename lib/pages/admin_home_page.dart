import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../supabase/supabase.dart';

import 'admin_intro_page.dart';
import 'word_page.dart';
import 'quiz_page.dart';
import 'history_page.dart';
import 'push_log_page.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  static const String supabaseFunctionUrl =
      "https://uyonjhjgmwbisocdedtw.supabase.co/functions/v1/sendPush";

  bool get isLoggedIn => SupabaseManager.client.auth.currentSession != null;

  // ================= PUSH =================
  Future<void> _sendPush({required String mode, String? testToken}) async {
    final client = SupabaseManager.client;

    try {
      await http.post(
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

      _snack("전송 완료");
    } catch (e) {
      _snack("오류: $e");
    }
  }

  Future<void> _sendTestPush() async {
    final ctrl = TextEditingController();

    final token = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("테스트 토큰"),
        content: TextField(controller: ctrl),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("취소"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, ctrl.text.trim()),
            child: const Text("발송"),
          ),
        ],
      ),
    );

    if (token != null && token.isNotEmpty) {
      await _sendPush(mode: "test", testToken: token);
    }
  }

  Future<void> _sendAllPush() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("전체 발송"),
        content: const Text("모든 사용자에게 전송할까요?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("취소"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("발송"),
          ),
        ],
      ),
    );

    if (ok == true) {
      await _sendPush(mode: "all");
    }
  }

  // ================= AUTH =================
  Future<void> _login() async {
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
            onPressed: () => Navigator.pop(context),
            child: const Text("취소"),
          ),
          TextButton(
            onPressed: () async {
              await SupabaseManager.client.auth.signInWithPassword(
                email: emailCtrl.text.trim(),
                password: pwCtrl.text.trim(),
              );
              Navigator.pop(context);
              setState(() {});
            },
            child: const Text("로그인"),
          ),
        ],
      ),
    );
  }

  Future<void> _logout() async {
    await SupabaseManager.client.auth.signOut();
    setState(() {});
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F12),
      body: Center(
        child: Container(
          width: 860,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1F),
            borderRadius: BorderRadius.circular(28),
            boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 30)],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ===== HEADER =====
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Admin Dashboard",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: isLoggedIn ? _logout : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2A2A30),
                    ),
                    child: Text(isLoggedIn ? "로그아웃" : "로그인"),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // ===== MAIN =====
              _section("🖼 메인 관리"),
              _grid(
                [
                  _card("인트로 관리", () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AdminIntroPage()),
                    );
                  }),
                  _card("단어 관리", () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const WordPage()),
                    );
                  }),
                  _card("퀴즈 관리", () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const QuizPage()),
                    );
                  }),
                ],
                crossAxisCount: 3,
                ratio: 3.2,
              ),

              const SizedBox(height: 28),

              // ===== NOTIFICATION =====
              _section("🔔 알림 관리"),
              _grid(
                [
                  _card("테스트 발송", _sendTestPush),
                  _card("전체 발송", _sendAllPush),
                  _card("알림 로그", () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const PushLogPage()),
                    );
                  }),
                ],
                crossAxisCount: 3,
                ratio: 4.2, // 🔽 작게
              ),

              const SizedBox(height: 28),

              // ===== HISTORY =====
              _section("📂 히스토리"),
              _grid(
                [
                  _card("히스토리 관리", () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const HistoryPage()),
                    );
                  }),
                ],
                crossAxisCount: 3,
                ratio: 4.2, // 🔽 작게
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= COMPONENT =================
  Widget _section(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 15,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _grid(
    List<Widget> children, {
    required int crossAxisCount,
    required double ratio,
  }) {
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: crossAxisCount,
      mainAxisSpacing: 14,
      crossAxisSpacing: 14,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: ratio,
      children: children,
    );
  }

  Widget _card(String title, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF24242B),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white12),
        ),
        child: Center(
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
