import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import 'elibrary_detail_screen.dart';

class ELibraryScreen extends StatefulWidget {
  const ELibraryScreen({super.key});

  @override
  State<ELibraryScreen> createState() => _ELibraryScreenState();
}

class _ELibraryScreenState extends State<ELibraryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<dynamic> _items = [];
  List<String> _categories = [];
  bool _isLoading = true;
  String? _selectedKategori;
  String _searchQuery = '';
  final _searchController = TextEditingController();

  final _tabs = [
    {'type': 'ebook', 'label': 'E-Book', 'icon': Icons.menu_book_rounded},
    {
      'type': 'audiobook',
      'label': 'Audio Book',
      'icon': Icons.headphones_rounded,
    },
    {
      'type': 'videobook',
      'label': 'Video Book',
      'icon': Icons.video_library_rounded,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        _loadCatalog();
      }
    });
    _loadCatalog();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCatalog() async {
    setState(() => _isLoading = true);
    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final type = _tabs[_tabController.index]['type'];
      String url = '/student/elibrary/catalog?type=$type';
      if (_searchQuery.isNotEmpty) url += '&search=$_searchQuery';
      if (_selectedKategori != null) url += '&kategori=$_selectedKategori';

      final response = await auth.authService.dio.get(
        url,
        options: auth.authService.authOptions(auth.token!),
      );
      if (response.statusCode == 200 && response.data['success'] == true) {
        setState(() {
          _items = response.data['data']['items'] ?? [];
          _categories = List<String>.from(
            response.data['data']['categories'] ?? [],
          );
        });
      }
    } catch (e) {
      debugPrint("Error loading catalog: $e");
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text("E-Library"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppTheme.textPrimary,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.deepPurple,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.deepPurple,
          tabs: _tabs
              .map(
                (t) => Tab(
                  icon: Icon(t['icon'] as IconData, size: 20),
                  text: t['label'] as String,
                ),
              )
              .toList(),
        ),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildCategoryList(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: _tabs.map((t) => _buildCatalogView()).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black.withOpacity(0.05)),
        ),
        child: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Cari judul atau penulis...',
            prefixIcon: const Icon(Icons.search_rounded, color: Colors.grey),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                      _loadCatalog();
                    },
                  )
                : null,
          ),
          onSubmitted: (value) {
            setState(() => _searchQuery = value);
            _loadCatalog();
          },
        ),
      ),
    );
  }

  Widget _buildCategoryList() {
    if (_categories.isEmpty) return const SizedBox.shrink();

    return Container(
      height: 40,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length + 1,
        itemBuilder: (context, index) {
          final isAll = index == 0;
          final category = isAll ? null : _categories[index - 1];
          final isSelected = _selectedKategori == category;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              selected: isSelected,
              label: Text(
                isAll ? 'Semua' : category!,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey[700],
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              backgroundColor: Colors.white,
              selectedColor: Colors.deepPurple,
              checkmarkColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(
                  color: isSelected ? Colors.deepPurple : Colors.grey[200]!,
                ),
              ),
              onSelected: (selected) {
                setState(() => _selectedKategori = category);
                _loadCatalog();
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildCatalogView() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.library_books_rounded,
              size: 80,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              "Tidak ada item ditemukan",
              style: TextStyle(
                color: Colors.grey[500],
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadCatalog,
      child: GridView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.65,
        ),
        itemCount: _items.length,
        itemBuilder: (context, index) {
          final item = _items[index];
          return _buildItemCard(item);
        },
      ),
    );
  }

  Widget _buildItemCard(dynamic item) {
    final isBorrowed = item['is_borrowed'] == true;
    final tipe = item['tipe']?.toString() ?? 'ebook';

    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                ELibraryDetailScreen(itemId: item['id']?.toString() ?? ''),
          ),
        );
        if (result == true) _loadCatalog();
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  child: item['cover_url'] != null
                      ? Image.network(
                          item['cover_url'],
                          height: 150,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              _buildPlaceholderCover(tipe),
                        )
                      : _buildPlaceholderCover(tipe),
                ),
                if (isBorrowed)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Dipinjam',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['judul'] ?? 'Untitled',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Text(
                      item['penulis'] ?? 'Unknown',
                      style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          _getTypeIcon(tipe),
                          size: 12,
                          color: Colors.deepPurple,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _getTypeInfo(item),
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.deepPurple,
                          ),
                        ),
                        if (item['kategori'] != null) ...[
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.deepPurple.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              item['kategori'].toString().toUpperCase(),
                              style: const TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepPurple,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderCover(String tipe) {
    return Container(
      height: 150,
      color: Colors.deepPurple.withOpacity(0.1),
      child: Center(
        child: Icon(
          _getTypeIcon(tipe),
          size: 50,
          color: Colors.deepPurple.withOpacity(0.5),
        ),
      ),
    );
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

  String _getTypeInfo(dynamic item) {
    final tipe = item['tipe']?.toString() ?? 'ebook';
    switch (tipe) {
      case 'audiobook':
      case 'videobook':
        final durasi = item['durasi'] ?? 0;
        return '$durasi menit';
      default:
        final halaman = item['jumlah_halaman'] ?? 0;
        return '$halaman halaman';
    }
  }
}
