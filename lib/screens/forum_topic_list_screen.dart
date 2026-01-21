import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import 'forum_topic_detail_screen.dart';

class ForumTopicListScreen extends StatefulWidget {
  final String forumId;

  const ForumTopicListScreen({super.key, required this.forumId});

  @override
  State<ForumTopicListScreen> createState() => _ForumTopicListScreenState();
}

class _ForumTopicListScreenState extends State<ForumTopicListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AuthProvider>(
        context,
        listen: false,
      ).fetchForumDetail(widget.forumId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        final forum = auth.selectedForum;

        return Scaffold(
          backgroundColor: AppTheme.background,
          appBar: AppBar(
            title: Text(forum?.title ?? "Forum"),
            backgroundColor: Colors.transparent,
            elevation: 0,
            foregroundColor: AppTheme.textPrimary,
          ),
          body: auth.isLoading || forum == null || forum.id != widget.forumId
              ? const Center(child: CircularProgressIndicator())
              : _buildTopicList(forum),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () =>
                _showCreateTopicDialog(context, auth, widget.forumId),
            backgroundColor: AppTheme.primary,
            icon: const Icon(Icons.add_comment_rounded, color: Colors.white),
            label: const Text(
              "Mulai Diskusi",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );
  }

  void _showCreateTopicDialog(
    BuildContext context,
    AuthProvider auth,
    String forumId,
  ) {
    final titleController = TextEditingController();
    final contentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text(
          "Mulai Diskusi Baru",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: "Judul Topik",
                  hintText: "Contoh: Tanya Soal Fisika",
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: contentController,
                decoration: const InputDecoration(
                  labelText: "Isi Konten",
                  hintText: "Apa yang ingin Anda diskusikan?",
                ),
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
                  contentController.text.isEmpty)
                return;

              final success = await auth.createTopic(
                forumId: forumId,
                title: titleController.text,
                content: contentController.text,
              );

              if (success) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Topik berhasil dibuat")),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Gagal membuat topik")),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text("Kirim", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildTopicList(dynamic forum) {
    final topics = forum.topics ?? [];

    if (topics.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline_rounded,
              size: 80,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              "Belum ada topik diskusi",
              style: TextStyle(
                color: Colors.grey[500],
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: topics.length,
      itemBuilder: (context, index) {
        final topic = topics[index];
        return _buildTopicCard(topic);
      },
    );
  }

  Widget _buildTopicCard(dynamic topic) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ForumTopicDetailScreen(topicId: topic.id),
              ),
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (topic.isPinned)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.push_pin_rounded,
                              size: 12,
                              color: Colors.amber,
                            ),
                            SizedBox(width: 4),
                            Text(
                              "Disematkan",
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.amber,
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (topic.isLocked)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.lock_rounded,
                              size: 12,
                              color: Colors.red,
                            ),
                            SizedBox(width: 4),
                            Text(
                              "Dikunci",
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  topic.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  topic.content,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: Colors.deepPurple.withOpacity(0.1),
                      child: Text(
                        topic.user.substring(0, 1).toUpperCase(),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      topic.user,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.chat_bubble_outline_rounded,
                      size: 14,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "${topic.postsCount}",
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      topic.createdAt,
                      style: TextStyle(fontSize: 11, color: Colors.grey[400]),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
