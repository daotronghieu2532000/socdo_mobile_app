class AppReport {
  final int? id;
  final int userId;
  final String? imageUrl;
  final String description;
  final String? deviceInfo;
  final String? appVersion;
  final String status;
  final String? adminNotes;
  final int createdAt;
  final int? updatedAt;
  final int? reviewedAt;

  AppReport({
    this.id,
    required this.userId,
    this.imageUrl,
    required this.description,
    this.deviceInfo,
    this.appVersion,
    this.status = 'pending',
    this.adminNotes,
    required this.createdAt,
    this.updatedAt,
    this.reviewedAt,
  });

  factory AppReport.fromJson(Map<String, dynamic> json) {
    return AppReport(
      id: json['id'] as int?,
      userId: json['user_id'] as int,
      imageUrl: json['image_url'] as String?,
      description: json['description'] as String,
      deviceInfo: json['device_info'] as String?,
      appVersion: json['app_version'] as String?,
      status: json['status'] as String,
      adminNotes: json['admin_notes'] as String?,
      createdAt: json['created_at'] as int,
      updatedAt: json['updated_at'] as int?,
      reviewedAt: json['reviewed_at'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      if (imageUrl != null) 'image_url': imageUrl,
      'description': description,
      if (deviceInfo != null) 'device_info': deviceInfo,
      if (appVersion != null) 'app_version': appVersion,
      'status': status,
      if (adminNotes != null) 'admin_notes': adminNotes,
      'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (reviewedAt != null) 'reviewed_at': reviewedAt,
    };
  }
}

