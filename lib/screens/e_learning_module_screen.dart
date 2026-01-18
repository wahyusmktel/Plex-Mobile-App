import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import '../models/e_learning_model.dart';
import '../constants/api_constants.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:file_picker/file_picker.dart';
import 'cbt_token_screen.dart';

class ELearningModuleScreen extends StatefulWidget {
  final String moduleId;

  const ELearningModuleScreen({super.key, required this.moduleId});

  @override
  State<ELearningModuleScreen> createState() => _ELearningModuleScreenState();
}

class _ELearningModuleScreenState extends State<ELearningModuleScreen> {
  ELearningModuleModel? _module;
  bool _isInitLoading = true;
  bool _isSaving = false;

  // Assignment state
  final TextEditingController _assignmentController = TextEditingController();
  PlatformFile? _selectedFile;
  Map<String, dynamic>? _mySubmission;

  @override
  void initState() {
    super.initState();
    _fetchModule();
  }

  Future<void> _fetchModule() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    try {
      final response = await auth.getModuleDetail(widget.moduleId);
      if (response != null) {
        setState(() {
          _module = response;
        });

        if (_module!.type == 'assignment') {
          final submission = await auth.getSubmission(widget.moduleId);
          if (submission != null) {
            setState(() {
              _mySubmission = submission;
              _assignmentController.text = submission['content'] ?? '';
            });
          }
        }

        setState(() {
          _isInitLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Gagal memuat modul")));
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_module == null) {
      return const Scaffold(body: Center(child: Text("Modul tidak ditemukan")));
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(_module!.title),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppTheme.textPrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Module Info Tag
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _module!.type.toUpperCase(),
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Content
            if (_module!.content != null && _module!.content!.isNotEmpty)
              HtmlWidget(
                _module!.content!,
                textStyle: const TextStyle(
                  fontSize: 16,
                  color: AppTheme.textPrimary,
                  height: 1.5,
                ),
              )
            else
              const Text(
                "Tidak ada konten teks untuk modul ini.",
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),

            const SizedBox(height: 32),

            // File Attachment
            if (_module!.filePath != null) _buildFileSection(),

            const SizedBox(height: 32),

            // Assignment Form
            if (_module!.type == 'assignment') _buildAssignmentForm(),

            const SizedBox(height: 32),

            // Action Button
            if (!_module!.isCompleted)
              _buildActionButton()
            else
              _buildCompletedStatus(),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildAssignmentForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Kerjakan Tugas",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _assignmentController,
          maxLines: 5,
          enabled: _mySubmission == null,
          decoration: InputDecoration(
            hintText: "Ketik jawaban atau deskripsi tugas di sini...",
            filled: true,
            fillColor: AppTheme.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (_mySubmission == null)
          InkWell(
            onTap: _pickFile,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppTheme.primary.withOpacity(0.2),
                  style: BorderStyle.solid,
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.cloud_upload_rounded,
                    color: AppTheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _selectedFile != null
                          ? _selectedFile!.name
                          : "Unggah File Tugas (Opsional)",
                      style: const TextStyle(
                        color: AppTheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (_selectedFile != null)
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => setState(() => _selectedFile = null),
                    ),
                ],
              ),
            ),
          )
        else if (_mySubmission!['file_path'] != null)
          _buildSubmissionFileSection(),
      ],
    );
  }

  Widget _buildSubmissionFileSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green[200]!),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle_rounded, color: Colors.green),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              "File Tugas Telah Diunggah",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ),
          TextButton(
            onPressed: () => _launchURL(
              "${ApiConstants.baseStorageUrl}/${_mySubmission!['file_path']}",
            ),
            child: const Text("Lihat File"),
          ),
        ],
      ),
    );
  }

  Widget _buildFileSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          const Icon(Icons.attach_file_rounded, color: AppTheme.primary),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              "Lampiran File",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          TextButton.icon(
            onPressed: () => _launchURL(
              "${ApiConstants.baseStorageUrl}/${_module!.filePath}",
            ),
            icon: const Icon(Icons.download_rounded, size: 18),
            label: const Text("Unduh"),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton() {
    if (_module!.cbtId != null) {
      return SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CbtTokenScreen(
                  cbtId: _module!.cbtId!,
                  moduleId: _module!.id,
                  cbtName: _module!.title,
                ),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: const Text(
            "KERJAKAN UJIAN / TUGAS CBT",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _module!.type == 'assignment'
            ? _submitAssignment
            : _completeModule,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _isSaving
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(
                _module!.type == 'assignment'
                    ? "KIRIM TUGAS"
                    : "TANDAI SELESAI",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  Widget _buildCompletedStatus() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green[200]!),
      ),
      child: Column(
        children: [
          Icon(Icons.check_circle_rounded, color: Colors.green[600], size: 32),
          const SizedBox(height: 8),
          Text(
            "Modul Telah Diselesaikan",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.green[800],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _completeModule() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final success = await auth.markModuleAsCompleted(widget.moduleId);
    if (success) {
      setState(() {
        _module = ELearningModuleModel(
          id: _module!.id,
          type: _module!.type,
          title: _module!.title,
          content: _module!.content,
          filePath: _module!.filePath,
          cbtId: _module!.cbtId,
          dueDate: _module!.dueDate,
          order: _module!.order,
          isCompleted: true,
        );
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Modul berhasil diselesaikan!")),
        );
      }
    }
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      setState(() {
        _selectedFile = result.files.first;
      });
    }
  }

  Future<void> _submitAssignment() async {
    if (_assignmentController.text.isEmpty && _selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Harap isi jawaban atau unggah file")),
      );
      return;
    }

    setState(() => _isSaving = true);
    final auth = Provider.of<AuthProvider>(context, listen: false);

    final success = await auth.submitAssignment(
      moduleId: widget.moduleId,
      content: _assignmentController.text,
      filePath: _selectedFile?.path,
      bytes: _selectedFile?.bytes,
      fileName: _selectedFile?.name,
    );

    setState(() => _isSaving = false);

    if (success) {
      if (mounted) {
        setState(() {
          _module = ELearningModuleModel(
            id: _module!.id,
            type: _module!.type,
            title: _module!.title,
            content: _module!.content,
            filePath: _module!.filePath,
            cbtId: _module!.cbtId,
            dueDate: _module!.dueDate,
            order: _module!.order,
            isCompleted: true,
          );
          // Refresh submission status
          _fetchModule();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Tugas berhasil dikirim!")),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Gagal mengirim tugas")));
      }
    }
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    try {
      // In web, canLaunchUrl can be unreliable, so we prioritize launching
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint("Could not launch $url: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Gagal membuka tautan: $url"),
            action: SnackBarAction(
              label: "Salin",
              onPressed: () {
                // Future: Add clipboard support if needed
              },
            ),
          ),
        );
      }
    }
  }
}
