import 'package:flutter/material.dart';
import 'cbt_exam_screen.dart';

class CbtTokenScreen extends StatefulWidget {
  final String cbtId;
  final String moduleId;
  final String cbtName;

  const CbtTokenScreen({
    super.key,
    required this.cbtId,
    required this.moduleId,
    required this.cbtName,
  });

  @override
  State<CbtTokenScreen> createState() => _CbtTokenScreenState();
}

class _CbtTokenScreenState extends State<CbtTokenScreen> {
  final TextEditingController _tokenController = TextEditingController();
  bool _isError = false;

  @override
  void dispose() {
    _tokenController.dispose();
    super.dispose();
  }

  void _startTest() {
    final token = _tokenController.text.trim().toUpperCase();
    if (token.isEmpty) {
      setState(() => _isError = true);
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => CbtExamScreen(
          cbtId: widget.cbtId,
          moduleId: widget.moduleId,
          token: token,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101219), // Dark background like in image
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon Header
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Icon(
                    Icons.laptop_mac_rounded,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 32),

                // Title
                Text(
                  widget.cbtName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 16),

                // Description
                Text(
                  "Ujian ini memerlukan token akses untuk memulai. Pastikan Anda sudah siap.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 40),

                // Token Input Box
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: _isError
                          ? Colors.red
                          : Colors.white.withOpacity(0.1),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        "GUNAKAN TOKEN INI",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.3),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _tokenController,
                        textAlign: TextAlign.center,
                        textCapitalization: TextCapitalization.characters,
                        cursorColor: Colors.white,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 8,
                        ),
                        decoration: const InputDecoration(
                          hintText: "_____",
                          hintStyle: TextStyle(color: Colors.white24),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                        onChanged: (val) {
                          if (_isError && val.isNotEmpty) {
                            setState(() => _isError = false);
                          }
                        },
                      ),
                    ],
                  ),
                ),
                if (_isError)
                  const Padding(
                    padding: EdgeInsets.only(top: 12),
                    child: Text(
                      "Harap masukkan token akses",
                      style: TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),
                const SizedBox(height: 60),

                // Start Button
                Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFBA80E8), Color(0xFFD90D8B)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFD90D8B).withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: _startTest,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      "MULAI KERJAKAN TEST",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Back Button
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    "BATAL",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.3),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
