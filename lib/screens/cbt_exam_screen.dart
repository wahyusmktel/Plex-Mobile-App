import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../providers/auth_provider.dart';
import '../models/cbt_model.dart';

class CbtExamScreen extends StatefulWidget {
  final String cbtId;
  final String moduleId;
  final String token;

  const CbtExamScreen({
    super.key,
    required this.cbtId,
    required this.moduleId,
    required this.token,
  });

  @override
  State<CbtExamScreen> createState() => _CbtExamScreenState();
}

class _CbtExamScreenState extends State<CbtExamScreen> {
  bool _isLoading = true;
  bool _isSubmitLoading = false;
  CbtSessionModel? _session;
  List<CbtQuestionModel> _questions = [];
  int _currentIndex = 0;
  Map<String, String?> _userAnswers = {}; // questionId -> optionId/essay
  final TextEditingController _essayController = TextEditingController();
  Timer? _timer;
  Duration _timeLeft = Duration.zero;

  @override
  void initState() {
    super.initState();
    _initExam();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _initExam() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final session = await auth.startCbtSession(widget.cbtId, widget.token);

    if (session != null) {
      final questions = await auth.getCbtQuestions(session.id);

      // Calculate time left if possible (this is simplified, ideally backend returns endTime)
      // For now, let's assume session holds some time info or we just use a default
      // In a real app, you'd parse jam_selesai from the CBT model

      Duration timeLeft = const Duration(minutes: 60);
      if (session.cbt != null && session.cbt!['jam_selesai'] != null) {
        try {
          final now = DateTime.now();
          final endTimeStr = session.cbt!['jam_selesai']; // format HH:mm:ss
          final endTimeParts = endTimeStr.split(':');
          final endTime = DateTime(
            now.year,
            now.month,
            now.day,
            int.parse(endTimeParts[0]),
            int.parse(endTimeParts[1]),
            int.parse(endTimeParts[2]),
          );
          timeLeft = endTime.difference(now);
          if (timeLeft.isNegative) timeLeft = Duration.zero;
        } catch (e) {
          debugPrint("Error parsing CBT end time: $e");
        }
      }

      setState(() {
        _session = session;
        _questions = questions;
        _isLoading = false;
        _timeLeft = timeLeft;
      });

      if (_questions.isNotEmpty) {
        _changeQuestion(0);
      }

      _startTimer();
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Gagal memulai ujian atau Anda sudah selesai"),
          ),
        );
        Navigator.pop(context);
      }
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_timeLeft.inSeconds > 0) {
        setState(() {
          _timeLeft = _timeLeft - const Duration(seconds: 1);
        });
      } else {
        _timer?.cancel();
        _finishExam();
      }
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  Future<void> _saveAnswer(
    String questionId,
    String? optionId, {
    String? essay,
  }) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    await auth.submitCbtAnswer(
      sessionId: _session!.id,
      questionId: questionId,
      optionId: optionId,
      essayAnswer: essay,
    );
  }

  void _changeQuestion(int index) {
    setState(() {
      _currentIndex = index;
      final currentQuestion = _questions[_currentIndex];
      if (currentQuestion.type != 'pilihan_ganda') {
        _essayController.text = _userAnswers[currentQuestion.id] ?? '';
      }
    });
  }

  Future<void> _finishExam() async {
    if (!mounted) return;
    setState(() => _isSubmitLoading = true);
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final result = await auth.finishCbtSession(_session!.id);
    if (!mounted) return;
    setState(() => _isSubmitLoading = false);

    if (result != null) {
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text("Ujian Selesai"),
            content: Text(
              "Skor Anda: ${result['score']} / ${result['max_score']}",
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context, true); // Return to module screen
                },
                child: const Text("OK"),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text("Memuat Ujian..."),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
        body: const Center(child: CircularProgressIndicator(color: Colors.red)),
      );
    }

    if (_questions.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text("Ujian CBT"),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                size: 64,
                color: Colors.amber,
              ),
              const SizedBox(height: 16),
              const Text(
                "Tidak ada soal tersedia.",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Kembali"),
              ),
            ],
          ),
        ),
      );
    }

    final currentQuestion = _questions[_currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Computer Based Test"),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Text(
                _formatDuration(_timeLeft),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Question Progress
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            color: Colors.grey[100],
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: List.generate(_questions.length, (index) {
                  bool isCurrent = index == _currentIndex;
                  bool isAnswered = _userAnswers.containsKey(
                    _questions[index].id,
                  );
                  return InkWell(
                    onTap: () => _changeQuestion(index),
                    child: Container(
                      width: 40,
                      height: 40,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: isCurrent
                            ? Colors.red
                            : (isAnswered ? Colors.green : Colors.white),
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          "${index + 1}",
                          style: TextStyle(
                            color: isCurrent || isAnswered
                                ? Colors.white
                                : Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Pertanyaan ${_currentIndex + 1}",
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    currentQuestion.question,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 24),

                  if (currentQuestion.type == 'pilihan_ganda')
                    ...currentQuestion.options.map((option) {
                      bool isSelected =
                          _userAnswers[currentQuestion.id] == option.id;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.red.withOpacity(0.05)
                              : Colors.white,
                          border: Border.all(
                            color: isSelected ? Colors.red : Colors.grey[300]!,
                            width: isSelected ? 2 : 1,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          onTap: () {
                            setState(() {
                              _userAnswers[currentQuestion.id] = option.id;
                            });
                            _saveAnswer(currentQuestion.id, option.id);
                          },
                          leading: CircleAvatar(
                            radius: 14,
                            backgroundColor: isSelected
                                ? Colors.red
                                : Colors.grey[200],
                            child: Text(
                              String.fromCharCode(
                                65 + currentQuestion.options.indexOf(option),
                              ),
                              style: TextStyle(
                                fontSize: 12,
                                color: isSelected ? Colors.white : Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(option.optionText),
                        ),
                      );
                    }).toList()
                  else
                    TextField(
                      controller: _essayController,
                      maxLines: 5,
                      onChanged: (val) {
                        _userAnswers[currentQuestion.id] = val;
                        _saveAnswer(currentQuestion.id, null, essay: val);
                      },
                      decoration: const InputDecoration(
                        hintText: "Ketik jawaban Anda di sini...",
                        border: OutlineInputBorder(),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Bottom Navigation
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_currentIndex > 0)
                  OutlinedButton(
                    onPressed: () => _changeQuestion(_currentIndex - 1),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      minimumSize: const Size(0, 56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text("Sebelumnya"),
                  )
                else
                  const SizedBox.shrink(),

                if (_currentIndex < _questions.length - 1)
                  ElevatedButton(
                    onPressed: () => _changeQuestion(_currentIndex + 1),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      minimumSize: const Size(0, 56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text("Selanjutnya"),
                  )
                else
                  ElevatedButton(
                    onPressed: _isSubmitLoading ? null : _finishExam,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      minimumSize: const Size(0, 56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isSubmitLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text("Selesai Ujian"),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
