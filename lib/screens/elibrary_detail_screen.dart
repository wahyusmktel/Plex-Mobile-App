import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import 'elibrary_reader_screen.dart';

class ELibraryDetailScreen extends StatefulWidget {
  final String itemId;

  const ELibraryDetailScreen({super.key, required this.itemId});

  @override
  State<ELibraryDetailScreen> createState() => _ELibraryDetailScreenState();
}

class _ELibraryDetailScreenState extends State<ELibraryDetailScreen> {
  Map<String, dynamic>? _item;
  bool _isLoading = true;
  bool _isBorrowing = false;

  @override
  void initState() {
    super.initState();
    _loadItem();
  }

  Future<void> _loadItem() async {
    setState(() => _isLoading = true);
    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final response = await auth.authService.dio.get(
        '/student/elibrary/item/${widget.itemId}',
        options: auth.authService.authOptions(auth.token!),
      );
      if (response.statusCode == 200 && response.data['success'] == true) {
        setState(() {
          _item = response.data['data'];
        });
      }
    } catch (e) {
      debugPrint("Error loading item: $e");
    }
    setState(() => _isLoading = false);
  }

  Future<void> _borrowItem(int durasi) async {
    setState(() => _isBorrowing = true);
    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final response = await auth.authService.dio.post(
        '/student/elibrary/borrow/${widget.itemId}',
        data: {'durasi_hari': durasi},
        options: auth.authService.authOptions(auth.token!),
      );
      if (response.statusCode == 200 && response.data['success'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.data['message'] ?? 'Berhasil meminjam'),
              backgroundColor: Colors.green,
            ),
          );
          _loadItem();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.data['message'] ?? 'Gagal meminjam'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint("Error borrowing: $e");
    }
    setState(() => _isBorrowing = false);
  }

  void _showBorrowDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pilih Durasi Peminjaman',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Setelah durasi berakhir, akses akan tertutup otomatis.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                3,
                7,
                14,
                30,
              ].map((d) => _buildDurationOption(d)).toList(),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildDurationOption(int days) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        _borrowItem(days);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.deepPurple.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.deepPurple.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(
              '$days',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            const Text(
              'hari',
              style: TextStyle(fontSize: 12, color: Colors.deepPurple),
            ),
          ],
        ),
      ),
    );
  }

  void _openReader() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ELibraryReaderScreen(
          itemId: widget.itemId,
          judul: _item?['judul'] ?? 'Reader',
          tipe: _item?['tipe'] ?? 'ebook',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _item == null
          ? const Center(child: Text("Item tidak ditemukan"))
          : CustomScrollView(
              slivers: [
                _buildAppBar(),
                SliverToBoxAdapter(child: _buildContent()),
              ],
            ),
      bottomNavigationBar: _item != null && !_isLoading
          ? _buildBottomBar()
          : null,
    );
  }

  Widget _buildAppBar() {
    final tipe = _item?['tipe'] ?? 'ebook';
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      backgroundColor: _getTypeColor(tipe),
      foregroundColor: Colors.white,
      flexibleSpace: FlexibleSpaceBar(
        background: _item?['cover_url'] != null
            ? Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(_item!['cover_url'], fit: BoxFit.cover),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
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
                    colors: [
                      _getTypeColor(tipe),
                      _getTypeColor(tipe).withOpacity(0.7),
                    ],
                  ),
                ),
                child: Center(
                  child: Icon(
                    _getTypeIcon(tipe),
                    size: 80,
                    color: Colors.white.withOpacity(0.5),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildContent() {
    final isBorrowed = _item?['is_borrowed'] == true;
    final borrowingInfo = _item?['borrowing_info'];
    final tipe = _item?['tipe'] ?? 'ebook';

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: _getTypeColor(tipe).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(_getTypeIcon(tipe), size: 14, color: _getTypeColor(tipe)),
                const SizedBox(width: 6),
                Text(
                  _getTypeLabel(tipe),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: _getTypeColor(tipe),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _item?['judul'] ?? 'Untitled',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          if (_item?['penulis'] != null)
            Text(
              'oleh ${_item!['penulis']}',
              style: TextStyle(fontSize: 15, color: Colors.grey[600]),
            ),
          const SizedBox(height: 20),
          if (isBorrowed && borrowingInfo != null) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.green.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_rounded, color: Colors.green),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Dipinjam',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        Text(
                          'Sampai ${borrowingInfo['tanggal_kembali']} (${(borrowingInfo['remaining_days'] as num).toInt()} hari lagi)',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
          _buildInfoRow('Penerbit', _item?['penerbit'] ?? '-'),
          _buildInfoRow('Tahun Terbit', _item?['tahun_terbit'] ?? '-'),
          _buildInfoRow('Kategori', _item?['kategori'] ?? '-'),
          if (tipe == 'ebook')
            _buildInfoRow(
              'Jumlah Halaman',
              '${_item?['jumlah_halaman'] ?? 0} halaman',
            ),
          if (tipe == 'audiobook' || tipe == 'videobook')
            _buildInfoRow('Durasi', '${_item?['durasi'] ?? 0} menit'),
          const SizedBox(height: 24),
          if (_item?['deskripsi'] != null) ...[
            const Text(
              'Deskripsi',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _item!['deskripsi'],
              style: const TextStyle(
                color: AppTheme.textSecondary,
                height: 1.6,
              ),
            ),
          ],
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(color: AppTheme.textSecondary),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    final isBorrowed = _item?['is_borrowed'] == true;
    final tipe = _item?['tipe'] ?? 'ebook';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            if (!isBorrowed)
              Expanded(
                child: ElevatedButton(
                  onPressed: _isBorrowing ? null : _showBorrowDialog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isBorrowing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Pinjam Sekarang',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              )
            else
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _openReader,
                  icon: Icon(_getActionIcon(tipe), color: Colors.white),
                  label: Text(
                    _getActionLabel(tipe),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _getTypeColor(String tipe) {
    switch (tipe) {
      case 'audiobook':
        return Colors.orange;
      case 'videobook':
        return Colors.red;
      default:
        return Colors.deepPurple;
    }
  }

  IconData _getTypeIcon(String tipe) {
    switch (tipe) {
      case 'audiobook':
        return Icons.headphones_rounded;
      case 'videobook':
        return Icons.video_library_rounded;
      default:
        return Icons.menu_book_rounded;
    }
  }

  String _getTypeLabel(String tipe) {
    switch (tipe) {
      case 'audiobook':
        return 'Audio Book';
      case 'videobook':
        return 'Video Book';
      default:
        return 'E-Book';
    }
  }

  IconData _getActionIcon(String tipe) {
    switch (tipe) {
      case 'audiobook':
        return Icons.play_circle_rounded;
      case 'videobook':
        return Icons.play_arrow_rounded;
      default:
        return Icons.chrome_reader_mode_rounded;
    }
  }

  String _getActionLabel(String tipe) {
    switch (tipe) {
      case 'audiobook':
        return 'Dengarkan';
      case 'videobook':
        return 'Tonton';
      default:
        return 'Baca Sekarang';
    }
  }
}
