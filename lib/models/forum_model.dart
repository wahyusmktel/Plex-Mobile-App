class ForumModel {
  final String id;
  final String title;
  final String description;
  final String creator;
  final String visibility;
  final int topicsCount;
  final String createdAt;
  final List<ForumTopicModel>? topics;

  ForumModel({
    required this.id,
    required this.title,
    required this.description,
    required this.creator,
    required this.visibility,
    required this.topicsCount,
    required this.createdAt,
    this.topics,
  });

  factory ForumModel.fromJson(Map<String, dynamic> json) {
    return ForumModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      creator: json['creator']?.toString() ?? 'N/A',
      visibility: json['visibility']?.toString() ?? 'school',
      topicsCount: int.tryParse(json['topics_count']?.toString() ?? '0') ?? 0,
      createdAt: json['created_at']?.toString() ?? '',
      topics: json['topics'] != null
          ? (json['topics'] as List)
                .map((i) => ForumTopicModel.fromJson(i))
                .toList()
          : null,
    );
  }
}

class ForumTopicModel {
  final String id;
  final String title;
  final String content;
  final String user;
  final int postsCount;
  final bool isPinned;
  final bool isLocked;
  final String status;
  final String createdAt;
  final List<ForumPostModel>? posts;
  final bool isBookmarked;
  final bool isMuted;

  ForumTopicModel({
    required this.id,
    required this.title,
    required this.content,
    required this.user,
    required this.postsCount,
    required this.isPinned,
    required this.isLocked,
    required this.status,
    required this.createdAt,
    this.posts,
    this.isBookmarked = false,
    this.isMuted = false,
  });

  factory ForumTopicModel.fromJson(Map<String, dynamic> json) {
    return ForumTopicModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      user: json['user']?.toString() ?? 'Anonim',
      postsCount: int.tryParse(json['posts_count']?.toString() ?? '0') ?? 0,
      isPinned: json['is_pinned'] == true,
      isLocked: json['is_locked'] == true,
      status: json['status']?.toString() ?? 'active',
      createdAt: json['created_at']?.toString() ?? '',
      posts: json['posts'] != null
          ? (json['posts'] as List)
                .map((i) => ForumPostModel.fromJson(i))
                .toList()
          : null,
      isBookmarked: json['is_bookmarked'] == true,
      isMuted: json['is_muted'] == true,
    );
  }
}

class ForumPostModel {
  final String id;
  final String content;
  final String user;
  final String createdAt;
  final List<ForumPostModel> replies;

  ForumPostModel({
    required this.id,
    required this.content,
    required this.user,
    required this.createdAt,
    this.replies = const [],
  });

  factory ForumPostModel.fromJson(Map<String, dynamic> json) {
    return ForumPostModel(
      id: json['id']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      user: json['user']?.toString() ?? 'Anonim',
      createdAt: json['created_at']?.toString() ?? '',
      replies: json['replies'] != null
          ? (json['replies'] as List)
                .map((i) => ForumPostModel.fromJson(i))
                .toList()
          : [],
    );
  }
}
