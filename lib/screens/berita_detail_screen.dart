import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';

class BeritaDetailScreen extends StatefulWidget {
  final String beritaId;

  const BeritaDetailScreen({super.key, required this.beritaId});

  @override
  State<BeritaDetailScreen> createState() => _BeritaDetailScreenState();
}

class _BeritaDetailScreenState extends State<BeritaDetailScreen> {
  Map<String, dynamic>? _berita;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBerita();
  }

  Future<void> _loadBerita() async {
    setState(() => _isLoading = true);
    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final response = await auth.authService.dio.get(
        '/student/berita/${widget.beritaId}',
        options: auth.authService.authOptions(auth.token!),
      );
      if (response.statusCode == 200 && response.data['success'] == true) {
        setState(() {
          _berita = response.data['data'];
        });
      }
    } catch (e) {
      debugPrint("Error loading berita: $e");
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _berita == null
          ? const Center(child: Text("Berita tidak ditemukan"))
          : CustomScrollView(
              slivers: [
                _buildAppBar(),
                SliverToBoxAdapter(child: _buildContent()),
              ],
            ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 250,
      pinned: true,
      backgroundColor: AppTheme.surface,
      foregroundColor: _berita?['thumbnail'] != null
          ? Colors.white
          : AppTheme.textPrimary,
      flexibleSpace: FlexibleSpaceBar(
        background: _berita?['thumbnail'] != null
            ? Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    _berita!['thumbnail'],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey[200],
                      child: const Icon(
                        Icons.image_not_supported,
                        color: Colors.grey,
                        size: 60,
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.6),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            : Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.deepPurple.shade400, Colors.pink.shade300],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildContent() {
    final source = _berita?['source']?.toString() ?? 'sekolah';
    final isDinas = source == 'dinas';

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isDinas
                      ? Colors.purple.withOpacity(0.1)
                      : Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  isDinas ? 'Berita Dinas' : 'Berita Sekolah',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isDinas ? Colors.purple : Colors.blue,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                _berita?['tanggal_terbit'] ?? '',
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            _berita?['judul'] ?? 'Berita',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: Colors.deepPurple.withOpacity(0.1),
                child: Text(
                  (_berita?['penulis'] ?? 'A').substring(0, 1).toUpperCase(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _berita?['penulis'] ?? 'Admin',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  Text(
                    'Penulis',
                    style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: _buildHtmlContent(_berita?['deskripsi'] ?? ''),
          ),
        ],
      ),
    );
  }

  Widget _buildHtmlContent(String html) {
    // Simple HTML stripping for plain text display
    final text = html
        .replaceAll(RegExp(r'<[^>]*>'), '\n')
        .replaceAll('&nbsp;', ' ')
        .replaceAll(RegExp(r'\n+'), '\n\n')
        .trim();
    return Text(
      text,
      style: const TextStyle(
        fontSize: 15,
        color: AppTheme.textPrimary,
        height: 1.7,
      ),
    );
  }
}
