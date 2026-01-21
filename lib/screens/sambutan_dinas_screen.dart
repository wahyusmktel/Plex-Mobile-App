import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/sambutan_model.dart';
import '../services/dinas_service.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart'
    hide ImageSource;
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class SambutanDinasScreen extends StatefulWidget {
  const SambutanDinasScreen({super.key});

  @override
  State<SambutanDinasScreen> createState() => _SambutanDinasScreenState();
}

class _SambutanDinasScreenState extends State<SambutanDinasScreen> {
  bool _isLoading = true;
  List<SambutanModel> _sambutans = [];

  @override
  void initState() {
    super.initState();
    _fetchSambutans();
  }

  Future<void> _fetchSambutans() async {
    setState(() => _isLoading = true);
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final dinasService = DinasService(auth.authService.dio, auth.token!);

    final result = await dinasService.getSambutans();
    if (mounted) {
      if (result['success']) {
        setState(() {
          _sambutans = result['sambutans'];
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Gagal mengambil data')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text("Sambutan Dinas"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppTheme.textPrimary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _sambutans.isEmpty
          ? _buildEmptyState()
          : RefreshIndicator(
              onRefresh: _fetchSambutans,
              child: ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: _sambutans.length,
                itemBuilder: (context, index) {
                  final item = _sambutans[index];
                  return _buildSambutanCard(item);
                },
              ),
            ),
      floatingActionButton: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          if (auth.user?.role == 'dinas') {
            return FloatingActionButton.extended(
              onPressed: () => _showCreateDialog(auth),
              backgroundColor: AppTheme.primary,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                "Pesan Baru",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  void _confirmDelete(AuthProvider auth, String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Hapus Sambutan?"),
        content: const Text("Data yang dihapus tidak dapat dikembalikan."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () async {
              final dinasService = DinasService(
                auth.authService.dio,
                auth.token!,
              );
              final res = await dinasService.deleteSambutan(id);
              if (res['success']) {
                Navigator.pop(context);
                _fetchSambutans();
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

  void _showCreateDialog(AuthProvider auth) {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    File? thumbnail;
    final picker = ImagePicker();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text(
            "Tambah Sambutan",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () async {
                    final picked = await picker.pickImage(
                      source: ImageSource.gallery,
                    );
                    if (picked != null) {
                      setModalState(() => thumbnail = File(picked.path));
                    }
                  },
                  child: Container(
                    height: 150,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: thumbnail == null
                        ? const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_a_photo_rounded,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 8),
                              Text(
                                "Pilih Thumbnail",
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.file(thumbnail!, fit: BoxFit.cover),
                          ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: "Judul"),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: contentController,
                  decoration: const InputDecoration(labelText: "Konten"),
                  maxLines: 5,
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
                if (titleController.text.isEmpty ||
                    contentController.text.isEmpty ||
                    thumbnail == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Semua field wajib diisi")),
                  );
                  return;
                }

                final dinasService = DinasService(
                  auth.authService.dio,
                  auth.token!,
                );
                final res = await dinasService.createSambutan(
                  judul: titleController.text,
                  konten: contentController.text,
                  thumbnailPath: thumbnail!.path,
                );

                if (res['success']) {
                  Navigator.pop(context);
                  _fetchSambutans();
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(res['message'])));
                } else {
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
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.record_voice_over_rounded,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            "Belum ada sambutan",
            style: TextStyle(
              color: Colors.grey[500],
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSambutanCard(SambutanModel item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (item.thumbnail != null)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
              child: Image.network(
                item.thumbnail!,
                width: double.infinity,
                height: 180,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 180,
                  color: Colors.grey[100],
                  child: const Icon(Icons.broken_image, color: Colors.grey),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.judul,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ),
                    Consumer<AuthProvider>(
                      builder: (context, auth, _) {
                        if (auth.user?.role == 'dinas') {
                          return IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.red,
                            ),
                            onPressed: () => _confirmDelete(auth, item.id),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  item.createdAt,
                  style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                ),
                const SizedBox(height: 16),
                HtmlWidget(
                  item.konten,
                  textStyle: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
