import 'package:flutter/material.dart';
import '../services/daily_quiz_service.dart';

class QuizPage extends StatefulWidget {
  const QuizPage({super.key});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  final DailyQuizService _quizService = DailyQuizService();

  final _questionController = TextEditingController();
  final _answerController = TextEditingController();
  final _explainController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false; // 데이터를 불러오는 중인지 확인
  bool _isSaving = false; // 저장 중인지 확인

  @override
  void initState() {
    super.initState();
    _loadQuiz();
  }

  // 날짜 키 생성 (예: 20240522)
  String _dateKey(DateTime d) =>
      '${d.year}${d.month.toString().padLeft(2, '0')}${d.day.toString().padLeft(2, '0')}';

  // 날짜 선택 팝업
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
      _loadQuiz();
    }
  }

  // 데이터 로드
  Future<void> _loadQuiz() async {
    setState(() => _isLoading = true);

    final dateKey = _dateKey(_selectedDate);
    final quiz = await _quizService.getQuiz(dateKey);

    if (!mounted) return;

    if (quiz == null) {
      _questionController.clear();
      _answerController.clear();
      _explainController.clear();
    } else {
      _questionController.text = quiz.question;
      _answerController.text = quiz.answer;
      _explainController.text = quiz.explanation ?? '';
    }

    setState(() => _isLoading = false);
  }

  // 저장 로직
  Future<void> _save() async {
    if (_questionController.text.trim().isEmpty) {
      _snack('문제를 입력하세요');
      return;
    }
    if (_answerController.text.trim().isEmpty) {
      _snack('정답을 입력하세요');
      return;
    }

    setState(() => _isSaving = true);

    final dateKey = _dateKey(_selectedDate);

    // 선택된 날짜의 UTC 타임스탬프 생성
    final String timestamp = DateTime.utc(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
    ).toIso8601String();

    final ok = await _quizService.saveQuiz(
      date: dateKey,
      question: _questionController.text.trim(),
      answer: _answerController.text.trim(),
      explanation: _explainController.text.trim().isEmpty
          ? null
          : _explainController.text.trim(),
      dateTimestamp: timestamp, // 서비스의 매개변수명과 일치시킴
    );

    setState(() => _isSaving = false);

    if (ok) {
      _snack('퀴즈 저장 완료');
    } else {
      _snack('저장 실패');
    }
  }

  // 삭제 로직
  Future<void> _delete() async {
    final dateKey = _dateKey(_selectedDate);

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('삭제'),
        content: const Text('해당 날짜의 퀴즈를 삭제할까요?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('삭제', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final ok = await _quizService.deleteQuiz(dateKey);

    if (ok) {
      _questionController.clear();
      _answerController.clear();
      _explainController.clear();
      _snack('삭제 완료');
    } else {
      _snack('삭제 실패');
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  void dispose() {
    _questionController.dispose();
    _answerController.dispose();
    _explainController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('퀴즈 관리'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            onPressed: _isLoading || _isSaving ? null : _delete,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator()) // 로딩 중 표시
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 날짜 선택 영역
                  InkWell(
                    onTap: _pickDate,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '날짜: ${_dateKey(_selectedDate)}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Icon(Icons.calendar_month),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  _buildLabel('문제'),
                  TextField(
                    controller: _questionController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: '문제를 입력하세요',
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 24),

                  _buildLabel('정답'),
                  TextField(
                    controller: _answerController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      hintText: '정답을 입력하세요',
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 24),

                  _buildLabel('설명 (선택)'),
                  TextField(
                    controller: _explainController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      hintText: '추가 설명을 입력하세요',
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 40),

                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: _isSaving ? null : _save,
                      child: _isSaving
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              '저장하기',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
      ),
    );
  }
}
