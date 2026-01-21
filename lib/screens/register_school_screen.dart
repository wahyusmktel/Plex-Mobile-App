import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import '../utils/notification_helper.dart';
import '../widgets/app_button.dart';
import '../widgets/app_text_field.dart';
import 'registration_success_screen.dart';

class RegisterSchoolScreen extends StatefulWidget {
  const RegisterSchoolScreen({super.key});

  @override
  State<RegisterSchoolScreen> createState() => _RegisterSchoolScreenState();
}

class _RegisterSchoolScreenState extends State<RegisterSchoolScreen> {
  int _currentStep = 0;
  final _formKey = GlobalKey<FormState>();

  // --- Controllers Langkah 1: Identitas Sekolah ---
  final TextEditingController _schoolNameController = TextEditingController();
  final TextEditingController _npsnController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  // Variabel Dropdown Langkah 1
  String? _selectedProvince;
  String? _selectedCity;
  String? _selectedDistrict;
  String? _selectedVillage;
  String _schoolStatus = 'Negeri';

  // --- Controllers Langkah 2: Info Admin ---
  final TextEditingController _adminNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  @override
  void dispose() {
    _schoolNameController.dispose();
    _npsnController.dispose();
    _addressController.dispose();
    _adminNameController.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text("Pendaftaran Sekolah Baru")),
      body: Theme(
        data: Theme.of(
          context,
        ).copyWith(colorScheme: ColorScheme.light(primary: AppTheme.primary)),
        child: Form(
          key: _formKey,
          child: Stepper(
            type: StepperType.vertical,
            currentStep: _currentStep,
            elevation: 0,
            onStepContinue: _handleContinue,
            onStepCancel: _handleCancel,
            controlsBuilder: (context, details) {
              return Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        text: _currentStep == 1 ? "Daftar Sekarang" : "Lanjut",
                        onPressed: details.onStepContinue ?? () {},
                      ),
                    ),
                    if (_currentStep > 0) ...[
                      const SizedBox(width: 15),
                      Expanded(
                        child: AppButton(
                          text: "Kembali",
                          onPressed: details.onStepCancel ?? () {},
                          isOutline: true,
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
            steps: [
              Step(
                title: const Text(
                  "Identitas Sekolah",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text("Informasi dasar institusi"),
                isActive: _currentStep >= 0,
                state: _currentStep > 0
                    ? StepState.complete
                    : StepState.editing,
                content: Column(
                  children: [
                    AppTextField(
                      controller: _schoolNameController,
                      label: "Nama Sekolah",
                      hint: "Contoh: SMAN 1 Literasia",
                      prefixIcon: Icons.school_rounded,
                    ),
                    const SizedBox(height: 15),
                    AppTextField(
                      controller: _npsnController,
                      label: "NPSN",
                      hint: "8 Digit Angka",
                      prefixIcon: Icons.numbers_rounded,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 15),
                    AppTextField(
                      controller: _addressController,
                      label: "Alamat Lengkap",
                      hint: "Jl. Pendidikan No. 1",
                      prefixIcon: Icons.location_on_rounded,
                      maxLines: 2,
                    ),
                    const SizedBox(height: 15),
                    _buildDropdown(
                      "Provinsi",
                      ["Jawa Barat", "Jawa Tengah", "Jawa Timur"],
                      (val) => setState(() => _selectedProvince = val),
                      _selectedProvince,
                    ),
                    const SizedBox(height: 15),
                    _buildDropdown(
                      "Kabupaten/Kota",
                      ["Kab. Bandung", "Kota Bandung", "Kab. Cianjur"],
                      (val) => setState(() => _selectedCity = val),
                      _selectedCity,
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Expanded(
                          child: _buildDropdown(
                            "Kecamatan",
                            ["Kec. A", "Kec. B"],
                            (val) => setState(() => _selectedDistrict = val),
                            _selectedDistrict,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildDropdown(
                            "Desa",
                            ["Desa X", "Desa Y"],
                            (val) => setState(() => _selectedVillage = val),
                            _selectedVillage,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Status Sekolah",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<String>(
                            title: const Text(
                              "Negeri",
                              style: TextStyle(fontSize: 14),
                            ),
                            value: "Negeri",
                            groupValue: _schoolStatus,
                            activeColor: AppTheme.primary,
                            contentPadding: EdgeInsets.zero,
                            onChanged: (value) =>
                                setState(() => _schoolStatus = value!),
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<String>(
                            title: const Text(
                              "Swasta",
                              style: TextStyle(fontSize: 14),
                            ),
                            value: "Swasta",
                            groupValue: _schoolStatus,
                            activeColor: AppTheme.primary,
                            contentPadding: EdgeInsets.zero,
                            onChanged: (value) =>
                                setState(() => _schoolStatus = value!),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Step(
                title: const Text(
                  "Informasi Admin",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text("Akun pengelola data sekolah"),
                isActive: _currentStep >= 1,
                state: StepState.editing,
                content: Column(
                  children: [
                    AppTextField(
                      controller: _adminNameController,
                      label: "Nama Lengkap Admin",
                      hint: "Nama Operator Sekolah",
                      prefixIcon: Icons.person_rounded,
                    ),
                    const SizedBox(height: 15),
                    AppTextField(
                      controller: _emailController,
                      label: "Email",
                      hint: "admin@sekolah.sch.id",
                      prefixIcon: Icons.email_rounded,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 15),
                    AppTextField(
                      controller: _usernameController,
                      label: "Username",
                      hint: "admin_sekolah",
                      prefixIcon: Icons.alternate_email_rounded,
                    ),
                    const SizedBox(height: 15),
                    AppTextField(
                      controller: _passwordController,
                      label: "Password",
                      hint: "Buat password kuat",
                      prefixIcon: Icons.lock_rounded,
                      isPassword: true,
                    ),
                    const SizedBox(height: 15),
                    AppTextField(
                      controller: _confirmPasswordController,
                      label: "Konfirmasi Password",
                      hint: "Ulangi password",
                      prefixIcon: Icons.lock_reset_rounded,
                      isPassword: true,
                      validator: (value) {
                        if (value != _passwordController.text)
                          return "Password tidak sama";
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleContinue() async {
    if (_currentStep == 0) {
      if (_schoolNameController.text.isNotEmpty &&
          _npsnController.text.isNotEmpty &&
          _selectedProvince != null) {
        setState(() => _currentStep += 1);
      } else {
        NotificationHelper.showInfo(
          context,
          "Harap lengkapi identitas sekolah",
        );
      }
    } else {
      if (_formKey.currentState!.validate()) {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final data = {
          'nama_sekolah': _schoolNameController.text,
          'npsn': _npsnController.text,
          'alamat': _addressController.text,
          'provinsi': _selectedProvince,
          'kabupaten_kota': _selectedCity,
          'kecamatan': _selectedDistrict,
          'desa_kelurahan': _selectedVillage,
          'status_sekolah': _schoolStatus,
          'admin_name': _adminNameController.text,
          'email': _emailController.text,
          'username': _usernameController.text,
          'password': _passwordController.text,
          'password_confirmation': _confirmPasswordController.text,
        };

        final result = await authProvider.registerSchool(data);
        if (result['success']) {
          if (mounted) {
            NotificationHelper.showSuccess(
              context,
              "Sekolah berhasil didaftarkan!",
            );
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const RegistrationSuccessScreen(),
              ),
            );
          }
        } else {
          NotificationHelper.showError(
            context,
            result['message'] ?? "Registrasi gagal",
          );
        }
      }
    }
  }

  void _handleCancel() {
    if (_currentStep > 0) {
      setState(() => _currentStep -= 1);
    } else {
      Navigator.pop(context);
    }
  }

  Widget _buildDropdown(
    String label,
    List<String> items,
    Function(String?) onChanged,
    String? value,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          isExpanded: true,
          decoration: InputDecoration(
            hintText: "Pilih $label",
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          items: items
              .map(
                (String item) => DropdownMenuItem(
                  value: item,
                  child: Text(item, style: const TextStyle(fontSize: 14)),
                ),
              )
              .toList(),
          onChanged: onChanged,
          validator: (val) => val == null ? "Field ini wajib diisi" : null,
        ),
      ],
    );
  }
}
