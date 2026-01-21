import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import '../providers/auth_provider.dart';
import '../services/dinas_service.dart';
import '../theme/app_theme.dart';
import '../utils/notification_helper.dart';

class AppSettingsScreen extends StatefulWidget {
  const AppSettingsScreen({super.key});

  @override
  State<AppSettingsScreen> createState() => _AppSettingsScreenState();
}

class _AppSettingsScreenState extends State<AppSettingsScreen> {
  final _appNameController = TextEditingController();
  File? _logoFile;
  String? _currentLogoUrl;
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);
    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final dinasService = DinasService(auth.authService.dio, auth.token!);
      final result = await dinasService.getAppSettings();
      if (result['success']) {
        final data = result['data'];
        _appNameController.text = data['app_name'] ?? '';
        _currentLogoUrl = data['app_logo'];
      }
    } catch (e) {
      debugPrint("Error loading app settings: $e");
    }
    setState(() => _isLoading = false);
  }

  Future<void> _pickLogo() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _logoFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveSettings() async {
    if (_appNameController.text.isEmpty) {
      NotificationHelper.showError(context, "Nama aplikasi tidak boleh kosong");
      return;
    }

    setState(() => _isSaving = true);
    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final dinasService = DinasService(auth.authService.dio, auth.token!);

      final Map<String, dynamic> formDataMap = {
        'app_name': _appNameController.text,
      };

      if (_logoFile != null) {
        formDataMap['app_logo'] = await MultipartFile.fromFile(
          _logoFile!.path,
          filename: 'app_logo.png',
        );
      }

      final result = await dinasService.updateAppSettings(
        FormData.fromMap(formDataMap),
      );
      if (mounted) {
        if (result['success']) {
          NotificationHelper.showSuccess(context, result['message']);
          _loadSettings(); // Reload to get the new logo URL
          setState(() => _logoFile = null);
        } else {
          NotificationHelper.showError(context, result['message']);
        }
      }
    } catch (e) {
      if (mounted)
        NotificationHelper.showError(context, "Terjadi kesalahan: $e");
    }
    setState(() => _isSaving = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text("Pengaturan Aplikasi"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppTheme.textPrimary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: AppTheme.surface,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: Colors.black.withOpacity(0.08),
                            ),
                            boxShadow: AppTheme.softShadow,
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: _logoFile != null
                                ? Image.file(_logoFile!, fit: BoxFit.contain)
                                : _currentLogoUrl != null
                                ? Image.network(
                                    _currentLogoUrl!,
                                    fit: BoxFit.contain,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const Icon(
                                              Icons.image_not_supported,
                                              size: 40,
                                              color: Colors.grey,
                                            ),
                                  )
                                : const Icon(
                                    Icons.business_rounded,
                                    size: 50,
                                    color: AppTheme.primary,
                                  ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextButton.icon(
                          onPressed: _pickLogo,
                          icon: const Icon(Icons.photo_library_rounded),
                          label: const Text("Pilih Logo Baru"),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    "Identitas Aplikasi",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _appNameController,
                    decoration: InputDecoration(
                      labelText: "Nama Aplikasi",
                      hintText: "Contoh: Literasia Edutekno Digital",
                      prefixIcon: const Icon(Icons.edit_rounded),
                      filled: true,
                      fillColor: AppTheme.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _saveSettings,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: _isSaving
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              "Simpan Perubahan",
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
}
