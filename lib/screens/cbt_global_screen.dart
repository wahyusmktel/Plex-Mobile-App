import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/dinas_service.dart';
import '../theme/app_theme.dart';
import 'package:intl/intl.dart';

class CbtGlobalScreen extends StatefulWidget {
  const CbtGlobalScreen({super.key});

  @override
  State<CbtGlobalScreen> createState() => _CbtGlobalScreenState();
}

class _CbtGlobalScreenState extends State<CbtGlobalScreen> {
  List<dynamic> _cbtList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCbtList();
  }

  Future<void> _loadCbtList() async {
    setState(() => _isLoading = true);
    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final dinasService = DinasService(auth.authService.dio, auth.token!);
      final result = await dinasService.getGlobalCbts();
      if (result['success']) {
        setState(() {
          _cbtList = result['data'] ?? [];
        });
      }
    } catch (e) {
      debugPrint("Error loading CBT list: $e");
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text("CBT Global"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppTheme.textPrimary,
        actions: [
          IconButton(onPressed: _loadCbtList, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _cbtList.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(24),
              itemCount: _cbtList.length,
              itemBuilder: (context, index) {
                final cbt = _cbtList[index];
                return _buildCbtCard(cbt);
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCbtDialog(),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          "Tambah CBT",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppTheme.primary,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.quiz_rounded, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            "Belum ada CBT Global",
            style: TextStyle(
              color: Colors.grey[500],
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCbtCard(dynamic cbt) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cbt['nama_cbt']?.toString() ?? 'CBT',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      Text(
                        cbt['subject']?.toString() ?? 'N/A',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                  onPressed: () => _showCbtDialog(cbt: cbt),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => _confirmDelete(cbt['id'].toString()),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoItem(
                  Icons.calendar_today_rounded,
                  cbt['tanggal'] ?? '',
                ),
                _buildInfoItem(
                  Icons.access_time_rounded,
                  '${cbt['jam_mulai']} - ${cbt['jam_selesai']}',
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoItem(Icons.vpn_key_rounded, 'Token: ${cbt['token']}'),
                _buildInfoItem(
                  Icons.help_outline_rounded,
                  '${cbt['questions_count'] ?? 0} Soal',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppTheme.textSecondary),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
        ),
      ],
    );
  }

  void _confirmDelete(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Hapus CBT?"),
        content: const Text("Tindakan ini tidak dapat dikembalikan."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () async {
              final auth = Provider.of<AuthProvider>(context, listen: false);
              final dinasService = DinasService(
                auth.authService.dio,
                auth.token!,
              );
              final res = await dinasService.deleteCbtGlobal(id);
              if (mounted) {
                Navigator.pop(context);
                if (res['success']) {
                  _loadCbtList();
                }
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(res['message'])));
              }
            },
            child: const Text("Hapus", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showCbtDialog({dynamic cbt}) {
    final isEdit = cbt != null;
    final nameController = TextEditingController(text: cbt?['nama_cbt'] ?? '');
    final dateController = TextEditingController(text: cbt?['tanggal'] ?? '');
    final startController = TextEditingController(
      text: cbt?['jam_mulai'] ?? '',
    );
    final endController = TextEditingController(
      text: cbt?['jam_selesai'] ?? '',
    );
    final scoreController = TextEditingController(
      text: cbt?['skor_maksimal']?.toString() ?? '100',
    );
    String? selectedSubjectId = cbt?['subject_id']?.toString();
    bool showResult = cbt?['show_result'] == true;
    List<dynamic> subjects = [];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          if (subjects.isEmpty) {
            final auth = Provider.of<AuthProvider>(context, listen: false);
            final dinasService = DinasService(
              auth.authService.dio,
              auth.token!,
            );
            dinasService.getGlobalSubjects().then((res) {
              if (res['success']) {
                setModalState(() => subjects = res['data']);
              }
            });
          }

          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            title: Text(
              isEdit ? "Edit CBT Global" : "Tambah CBT Global",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: "Nama CBT"),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: selectedSubjectId,
                    items: subjects
                        .map(
                          (s) => DropdownMenuItem(
                            value: s['id'].toString(),
                            child: Text(s['nama_pelajaran']),
                          ),
                        )
                        .toList(),
                    onChanged: (val) =>
                        setModalState(() => selectedSubjectId = val),
                    decoration: const InputDecoration(
                      labelText: "Mata Pelajaran",
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: dateController,
                    decoration: const InputDecoration(
                      labelText: "Tanggal",
                      prefixIcon: Icon(Icons.calendar_today),
                    ),
                    readOnly: true,
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null) {
                        dateController.text = DateFormat(
                          'yyyy-MM-dd',
                        ).format(picked);
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: startController,
                          decoration: const InputDecoration(
                            labelText: "Jam Mulai",
                          ),
                          readOnly: true,
                          onTap: () async {
                            final picked = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.now(),
                            );
                            if (picked != null)
                              startController.text =
                                  "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}";
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: endController,
                          decoration: const InputDecoration(
                            labelText: "Jam Selesai",
                          ),
                          readOnly: true,
                          onTap: () async {
                            final picked = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.now(),
                            );
                            if (picked != null)
                              endController.text =
                                  "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}";
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: scoreController,
                    decoration: const InputDecoration(
                      labelText: "Skor Maksimal",
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    title: const Text(
                      "Tampilkan Hasil",
                      style: TextStyle(fontSize: 14),
                    ),
                    value: showResult,
                    onChanged: (val) => setModalState(() => showResult = val),
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Batal"),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (nameController.text.isEmpty ||
                      selectedSubjectId == null ||
                      dateController.text.isEmpty ||
                      startController.text.isEmpty ||
                      endController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Mohon lengkapi semua field"),
                      ),
                    );
                    return;
                  }
                  final auth = Provider.of<AuthProvider>(
                    context,
                    listen: false,
                  );
                  final dinasService = DinasService(
                    auth.authService.dio,
                    auth.token!,
                  );
                  final data = {
                    'nama_cbt': nameController.text,
                    'subject_id': selectedSubjectId,
                    'tanggal': dateController.text,
                    'jam_mulai': startController.text,
                    'jam_selesai': endController.text,
                    'skor_maksimal': int.tryParse(scoreController.text) ?? 100,
                    'show_result': showResult,
                  };
                  final res = isEdit
                      ? await dinasService.updateCbtGlobal(
                          cbt['id'].toString(),
                          data,
                        )
                      : await dinasService.createCbtGlobal(data);
                  if (mounted) {
                    Navigator.pop(context);
                    if (res['success']) _loadCbtList();
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(res['message'])));
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Simpan",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
