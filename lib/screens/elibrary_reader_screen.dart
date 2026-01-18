import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import 'pdf_reader_screen.dart';
import 'audio_player_screen.dart';
import 'video_player_screen.dart';

class ELibraryReaderScreen extends StatefulWidget {
  final String itemId;
  final String judul;
  final String tipe;

  const ELibraryReaderScreen({
    super.key,
    required this.itemId,
    required this.judul,
    required this.tipe,
  });

  @override
  State<ELibraryReaderScreen> createState() => _ELibraryReaderScreenState();
}

class _ELibraryReaderScreenState extends State<ELibraryReaderScreen> {
  String? _fileUrl;
  String? _coverUrl;
  String? _author;
  bool _isLoading = true;
  int? _remainingDays;

  @override
  void initState() {
    super.initState();
    _loadContent();
  }

  Future<void> _loadContent() async {
    setState(() => _isLoading = true);
    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final response = await auth.authService.dio.get(
        '/student/elibrary/read/${widget.itemId}',
        options: auth.authService.authOptions(auth.token!),
      );
      if (response.statusCode == 200 && response.data['success'] == true) {
        setState(() {
          _fileUrl = response.data['data']['file_url'];
          _coverUrl = response.data['data']['cover_url'];
          _author = response.data['data']['penulis'];
          final days = response.data['data']['remaining_days'];
          _remainingDays = days is num ? days.toInt() : null;
        });
        // Automatically open the specific reader
        _openReader();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                response.data['message'] ?? 'Tidak dapat mengakses konten',
              ),
              backgroundColor: Colors.red,
            ),
          );
          Navigator.pop(context);
        }
      }
    } catch (e) {
      debugPrint("Error loading content: $e");
    }
    setState(() => _isLoading = false);
  }

  void _openReader() {
    if (_fileUrl == null) return;

    Widget screen;
    switch (widget.tipe) {
      case 'audiobook':
        screen = AudioPlayerScreen(
          audioUrl: _fileUrl!,
          title: widget.judul,
          coverUrl: _coverUrl,
          author: _author,
        );
        break;
      case 'videobook':
        screen = VideoPlayerScreen(videoUrl: _fileUrl!, title: widget.judul);
        break;
      default:
        screen = PDFReaderScreen(pdfUrl: _fileUrl!, title: widget.judul);
    }

    Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(widget.judul),
        backgroundColor: _getTypeColor(),
        foregroundColor: Colors.white,
        actions: [
          if (_remainingDays != null)
            Center(
              child: Container(
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$_remainingDays hari lagi',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _fileUrl == null
          ? _buildNoAccess()
          : _buildContentView(),
    );
  }

  Widget _buildNoAccess() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.lock_rounded, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text(
            "Anda harus meminjam terlebih dahulu",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildContentView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: _getTypeColor().withOpacity(0.1),
                borderRadius: BorderRadius.circular(32),
              ),
              child: Icon(_getTypeIcon(), size: 80, color: _getTypeColor()),
            ),
            const SizedBox(height: 32),
            Text(
              widget.judul,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(_getTypeLabel(), style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _openReader,
                icon: Icon(_getActionIcon(), color: Colors.white),
                label: Text(
                  _getActionLabel(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _getTypeColor(),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Konten akan dibuka dengan viewer Literasia',
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }

  Color _getTypeColor() {
    switch (widget.tipe) {
      case 'audiobook':
        return Colors.orange;
      case 'videobook':
        return Colors.red;
      default:
        return Colors.deepPurple;
    }
  }

  IconData _getTypeIcon() {
    switch (widget.tipe) {
      case 'audiobook':
        return Icons.headphones_rounded;
      case 'videobook':
        return Icons.video_library_rounded;
      default:
        return Icons.menu_book_rounded;
    }
  }

  String _getTypeLabel() {
    switch (widget.tipe) {
      case 'audiobook':
        return 'Audio Book';
      case 'videobook':
        return 'Video Book';
      default:
        return 'E-Book';
    }
  }

  IconData _getActionIcon() {
    switch (widget.tipe) {
      case 'audiobook':
        return Icons.play_circle_rounded;
      case 'videobook':
        return Icons.play_arrow_rounded;
      default:
        return Icons.chrome_reader_mode_rounded;
    }
  }

  String _getActionLabel() {
    switch (widget.tipe) {
      case 'audiobook':
        return 'Dengarkan Sekarang';
      case 'videobook':
        return 'Tonton Sekarang';
      default:
        return 'Baca Sekarang';
    }
  }
}
