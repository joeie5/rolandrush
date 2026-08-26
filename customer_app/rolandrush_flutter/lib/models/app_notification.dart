class AppNotification {
  final String id;
  final String title;
  final String message;
  final bool isRead;
  final DateTime createdAt;

  const AppNotification({required this.id, required this.title, required this.message, this.isRead = false, required this.createdAt});

  factory AppNotification.fromSupabase(Map<String, dynamic> row) => AppNotification(
        id: row['id'] as String,
        title: row['title'] as String? ?? '',
        message: row['message'] as String? ?? '',
        isRead: row['is_read'] as bool? ?? false,
        createdAt: DateTime.parse(row['created_at'] as String),
      );
}
