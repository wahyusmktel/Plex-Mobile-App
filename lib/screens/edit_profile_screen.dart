import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import '../utils/notification_helper.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _passwordController;
  late TextEditingController _passwordConfirmController;

  bool _isPasswordVisible = false;
  File? _imageFile;
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final user = auth.user;
    final detail = auth.profileData?['detail'] ?? {};

    _nameController = TextEditingController(text: user?.name);
    _emailController = TextEditingController(text: user?.email);
    _phoneController = TextEditingController(
      text: detail['no_hp']?.toString() ?? '',
    );
    _addressController = TextEditingController(
      text: detail['alamat']?.toString() ?? '',
    );
    _passwordController = TextEditingController();
    _passwordConfirmController = TextEditingController();

    // Fetch latest profile data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      auth.fetchProfile().then((_) {
        if (mounted) {
          final newDetail = auth.profileData?['detail'] ?? {};
          setState(() {
            _nameController.text =
                auth.profileData?['name'] ?? _nameController.text;
            _emailController.text =
                auth.profileData?['email'] ?? _emailController.text;
            _phoneController.text = newDetail['no_hp']?.toString() ?? '';
            _addressController.text = newDetail['alamat']?.toString() ?? '';
          });
        }
      });
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
      _handleAvatarUpload();
    }
  }

  Future<void> _handleAvatarUpload() async {
    if (_imageFile == null) return;

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final result = await auth.updateAvatar(_imageFile!.path);

    if (mounted) {
      if (result['success']) {
        NotificationHelper.showSuccess(context, result['message']);
      } else {
        NotificationHelper.showError(context, result['message']);
      }
    }
  }

  Future<void> _handleUpdateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final data = {
      'name': _nameController.text.trim(),
      'email': _emailController.text.trim(),
      'no_hp': _phoneController.text.trim(),
      'alamat': _addressController.text.trim(),
    };

    if (_passwordController.text.isNotEmpty) {
      data['password'] = _passwordController.text;
      data['password_confirmation'] = _passwordConfirmController.text;
    }

    final result = await auth.updateProfile(data);

    if (mounted) {
      if (result['success']) {
        NotificationHelper.showSuccess(context, result['message']);
        if (_passwordController.text.isNotEmpty) {
          _passwordController.clear();
          _passwordConfirmController.clear();
        }
      } else {
        String message = result['message'];
        if (result['errors'] != null) {
          final errors = result['errors'] as Map<String, dynamic>;
          message = errors.values.first[0].toString();
        }
        NotificationHelper.showError(context, message);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text("Edit Profil"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppTheme.textPrimary,
      ),
      body: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          final user = auth.user;
          final avatarUrl =
              user?.avatar ??
              "https://ui-avatars.com/api/?name=${Uri.encodeComponent(user?.name ?? 'User')}&background=random&size=256";

          return Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Stack(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const LinearGradient(
                                  colors: AppTheme.brandGradient,
                                ),
                                boxShadow: AppTheme.primaryShadow,
                              ),
                              child: CircleAvatar(
                                radius: 50,
                                backgroundImage: _imageFile != null
                                    ? FileImage(_imageFile!)
                                    : NetworkImage(avatarUrl) as ImageProvider,
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: _pickImage,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: const BoxDecoration(
                                    color: AppTheme.primary,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt_rounded,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      _buildSectionLabel("Informasi Dasar"),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _nameController,
                        label: "Nama Lengkap",
                        icon: Icons.person_outline_rounded,
                        validator: (v) =>
                            v!.isEmpty ? "Nama tidak boleh kosong" : null,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _emailController,
                        label: "Email",
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) =>
                            v!.isEmpty ? "Email tidak boleh kosong" : null,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _phoneController,
                        label: "Nomor Telepon",
                        icon: Icons.phone_android_rounded,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _addressController,
                        label: "Alamat",
                        icon: Icons.location_on_outlined,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 32),
                      _buildSectionLabel("Ubah Kata Sandi (Opsional)"),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _passwordController,
                        label: "Kata Sandi Baru",
                        icon: Icons.lock_outline_rounded,
                        isPassword: true,
                        obscureText: !_isPasswordVisible,
                        toggleVisibility: () => setState(
                          () => _isPasswordVisible = !_isPasswordVisible,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _passwordConfirmController,
                        label: "Konfirmasi Kata Sandi Baru",
                        icon: Icons.lock_reset_rounded,
                        isPassword: true,
                        obscureText: !_isPasswordVisible,
                        validator: (v) {
                          if (_passwordController.text.isNotEmpty &&
                              v != _passwordController.text) {
                            return "Konfirmasi kata sandi tidak cocok";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 40),
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: auth.isLoading
                              ? null
                              : _handleUpdateProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          child: auth.isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  "Simpan Perubahan",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
              if (auth.isLoading)
                Container(
                  color: Colors.black.withOpacity(0.1),
                  child: const Center(child: CircularProgressIndicator()),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: AppTheme.primary,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? toggleVisibility,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: AppTheme.textSecondary, size: 22),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    obscureText
                        ? Icons.visibility_off_rounded
                        : Icons.visibility_rounded,
                    color: AppTheme.textSecondary,
                    size: 22,
                  ),
                  onPressed: toggleVisibility,
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: AppTheme.surface,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }
}
