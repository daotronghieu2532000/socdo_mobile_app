class AppRating {
  final int? id;
  final int userId;
  final double rating;
  final String comment;
  final String? deviceInfo;
  final String? appVersion;
  final int? status;
  final int createdAt;
  final int? updatedAt;

  AppRating({
    this.id,
    required this.userId,
    required this.rating,
    required this.comment,
    this.deviceInfo,
    this.appVersion,
    this.status,
    required this.createdAt,
    this.updatedAt,
  });

  factory AppRating.fromJson(Map<String, dynamic> json) {
    return AppRating(
      id: json['id'] as int?,
      userId: json['user_id'] as int,
      rating: (json['rating'] as num).toDouble(),
      comment: json['comment'] as String,
      deviceInfo: json['device_info'] as String?,
      appVersion: json['app_version'] as String?,
      status: json['status'] as int?,
      createdAt: json['created_at'] as int,
      updatedAt: json['updated_at'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'rating': rating,
      'comment': comment,
      if (deviceInfo != null) 'device_info': deviceInfo,
      if (appVersion != null) 'app_version': appVersion,
      if (status != null) 'status': status,
      'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    };
  }
}

