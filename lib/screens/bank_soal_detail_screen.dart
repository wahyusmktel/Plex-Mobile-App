import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import '../models/bank_soal_model.dart';

class BankSoalDetailScreen extends StatefulWidget {
  final String bankSoalId;

  const BankSoalDetailScreen({super.key, required this.bankSoalId});

  @override
  State<BankSoalDetailScreen> createState() => _BankSoalDetailScreenState();
}

class _BankSoalDetailScreenState extends State<BankSoalDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AuthProvider>(
        context,
        listen: false,
      ).fetchBankSoalDetail(widget.bankSoalId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text("Detail Soal"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppTheme.textPrimary,
      ),
      body: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          final bankSoal = auth.selectedBankSoal;

          if (auth.isLoading ||
              bankSoal == null ||
              bankSoal.id != widget.bankSoalId) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(bankSoal),
                const SizedBox(height: 32),
                const Text(
                  "Daftar Soal",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: bankSoal.questions?.length ?? 0,
                  itemBuilder: (context, index) {
                    final question = bankSoal.questions![index];
                    return _buildQuestionCard(question, index + 1);
                  },
                ),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BankSoalModel bankSoal) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            bankSoal.subject.toUpperCase(),
            style: const TextStyle(
              color: Colors.indigo,
              fontWeight: FontWeight.w900,
              fontSize: 12,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            bankSoal.title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildHeaderStat(Icons.person_rounded, bankSoal.teacher),
              const SizedBox(width: 24),
              _buildHeaderStat(Icons.layers_rounded, "Level ${bankSoal.level}"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderStat(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppTheme.textSecondary),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: AppTheme.textSecondary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionCard(BankSoalQuestionModel question, int number) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    number.toString(),
                    style: const TextStyle(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  question.type == 'pilihan_ganda' ? "Pilihan Ganda" : "Essay",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            question.question,
            style: const TextStyle(
              fontSize: 16,
              color: AppTheme.textPrimary,
              height: 1.5,
            ),
          ),
          if (question.image != null) ...[
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(question.image!),
            ),
          ],
          const SizedBox(height: 24),
          if (question.type == 'pilihan_ganda') ...[
            ...question.options.map((opt) => _buildOption(opt)),
          ] else ...[
            const Text(
              "Kunci Jawaban (Essay):",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.green.withOpacity(0.1)),
              ),
              child: const Text(
                "Sesuai standar penilaian guru.",
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.green,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOption(BankSoalOptionModel option) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: option.isCorrect
            ? Colors.green.withOpacity(0.05)
            : Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: option.isCorrect
              ? Colors.green.withOpacity(0.3)
              : Colors.transparent,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            option.isCorrect
                ? Icons.check_circle_rounded
                : Icons.radio_button_unchecked_rounded,
            size: 20,
            color: option.isCorrect ? Colors.green : Colors.grey[400],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              option.text,
              style: TextStyle(
                fontSize: 14,
                color: option.isCorrect
                    ? Colors.green[700]
                    : AppTheme.textPrimary,
                fontWeight: option.isCorrect
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
          ),
          if (option.isCorrect)
            const Text(
              "BENAR",
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
        ],
      ),
    );
  }
}
