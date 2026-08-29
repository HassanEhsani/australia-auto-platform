class NotificationCandidate {
  const NotificationCandidate({
    required this.id,
    required this.savedSearchId,
    required this.vehicleId,
    required this.title,
    required this.body,
    required this.createdAt,
  });

  final String id;
  final String savedSearchId;
  final String vehicleId;
  final String title;
  final String body;
  final DateTime createdAt;
}
