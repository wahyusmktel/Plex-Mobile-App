import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<dynamic> _notifications = [];
  bool _isLoading = true;
  int _currentPage = 1;
  int _lastPage = 1;
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _notifications = [];
    }

    setState(() => _isLoading = true);
    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final response = await auth.authService.dio.get(
        '/student/notifications?page=$_currentPage',
        options: auth.authService.authOptions(auth.token!),
      );

      if (mounted &&
          response.statusCode == 200 &&
          response.data != null &&
          response.data['success'] == true) {
        final newData = response.data['data']['items'] ?? [];
        setState(() {
          _notifications.addAll(newData);
          _unreadCount = response.data['data']['unread_count'] ?? 0;
          _lastPage = response.data['data']['meta']['last_page'] ?? 1;
        });
      }
    } catch (e) {
      if (mounted) {
        debugPrint("Error loading notifications: $e");
      }
    }
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _markAsRead(String id, int index) async {
    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final response = await auth.authService.dio.post(
        '/student/notifications/$id/mark-as-read',
        options: auth.authService.authOptions(auth.token!),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        setState(() {
          _notifications[index]['read_at'] = DateTime.now().toString();
          if (_unreadCount > 0) _unreadCount--;
        });
      }
    } catch (e) {
      debugPrint("Error marking as read: $e");
    }
  }

  Future<void> _markAsUnread(String id, int index) async {
    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final response = await auth.authService.dio.post(
        '/student/notifications/$id/mark-as-unread',
        options: auth.authService.authOptions(auth.token!),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        setState(() {
          _notifications[index]['read_at'] = null;
          _unreadCount++;
        });
      }
    } catch (e) {
      debugPrint("Error marking as unread: $e");
    }
  }

  Future<void> _markAllAsRead() async {
    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final response = await auth.authService.dio.post(
        '/student/notifications/mark-all-as-read',
        options: auth.authService.authOptions(auth.token!),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        setState(() {
          for (var item in _notifications) {
            item['read_at'] = DateTime.now().toString();
          }
          _unreadCount = 0;
        });
      }
    } catch (e) {
      debugPrint("Error marking all as read: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text(
          "Notifikasi",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (_unreadCount > 0)
            TextButton(
              onPressed: _markAllAsRead,
              child: const Text("Baca Semua"),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _loadNotifications(refresh: true),
        child: _notifications.isEmpty && !_isLoading
            ? _buildEmptyState()
            : ListView.builder(
                padding: const EdgeInsets.only(bottom: 100),
                itemCount:
                    _notifications.length + (_currentPage < _lastPage ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _notifications.length) {
                    _currentPage++;
                    _loadNotifications();
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  final item = _notifications[index];
                  final isRead = item['read_at'] != null;

                  return _buildNotificationItem(item, index, isRead);
                },
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
            Icons.notifications_none_rounded,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            "Belum ada notifikasi",
            style: TextStyle(color: Colors.grey[500], fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(dynamic item, int index, bool isRead) {
    return Dismissible(
      key: Key(item['id']),
      direction: DismissDirection.horizontal,
      background: Container(
        color: Colors.green,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Icon(Icons.mark_email_read_rounded, color: Colors.white),
      ),
      secondaryBackground: Container(
        color: Colors.orange,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Icon(Icons.mark_email_unread_rounded, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          if (!isRead) await _markAsRead(item['id'], index);
        } else {
          if (isRead) await _markAsUnread(item['id'], index);
        }
        return false;
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isRead ? Colors.white : Colors.deepPurple.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isRead
                ? Colors.grey[200]!
                : Colors.deepPurple.withOpacity(0.1),
          ),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _getNotificationColor(item['type']).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getNotificationIcon(item['type']),
              color: _getNotificationColor(item['type']),
              size: 24,
            ),
          ),
          title: Text(
            item['title'],
            style: TextStyle(
              fontWeight: isRead ? FontWeight.w600 : FontWeight.bold,
              fontSize: 14,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                item['message'],
                style: TextStyle(color: Colors.grey[700], fontSize: 13),
              ),
              const SizedBox(height: 6),
              Text(
                item['time_ago'],
                style: TextStyle(color: Colors.grey[500], fontSize: 11),
              ),
            ],
          ),
          onTap: () {
            if (!isRead) _markAsRead(item['id'], index);
            // Handle actions based on action_type
            _handleNotificationAction(item);
          },
        ),
      ),
    );
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'forum':
        return Icons.forum_rounded;
      case 'violation':
        return Icons.report_problem_rounded;
      case 'announcement':
        return Icons.campaign_rounded;
      case 'news':
        return Icons.newspaper_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'forum':
        return Colors.blue;
      case 'violation':
        return Colors.red;
      case 'announcement':
        return Colors.orange;
      case 'news':
        return Colors.green;
      default:
        return Colors.deepPurple;
    }
  }

  void _handleNotificationAction(dynamic item) {
    // Navigate based on action_type
    debugPrint("Action Type: ${item['action_type']}");
  }
}
