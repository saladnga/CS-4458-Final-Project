class FieldLog {
  final String id;
  final String notes;
  final String? userId;
  final double latitude;
  final double longitude;
  final String? weatherDescription;
  final String? localImagePath;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int syncedToServer;
  final String? remoteImagePath;

  FieldLog({
    required this.id,
    required this.notes,
    this.userId,
    required this.latitude,
    required this.longitude,
    this.weatherDescription,
    this.localImagePath,
    required this.createdAt,
    required this.updatedAt,
    required this.syncedToServer,
    this.remoteImagePath,
  });

  // For SQFlite Database
  Map<String, dynamic> toMap() => {
    'id': id,
    'notes': notes,
    'user_id': userId,
    'latitude': latitude,
    'longitude': longitude,
    'weather_description': weatherDescription,
    'local_image_path': localImagePath,
    'remote_image_url': remoteImagePath,
    'created_at': createdAt.millisecondsSinceEpoch,
    'updated_at': updatedAt.millisecondsSinceEpoch,
    'synced_to_server': syncedToServer,
  };

  factory FieldLog.fromMap(Map<String, dynamic> map) {
    return FieldLog(
      id: map['id'] as String,
      notes: map['notes'] as String,
      userId: map['user_id'] as String?,
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      weatherDescription: map['weather_description'] as String?,
      localImagePath: map['local_image_path'] as String?,
      remoteImagePath: map['remote_image_url'] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
      syncedToServer: map['synced_to_server'] as int,
    );
  }

  // For server-side
  Map<String, dynamic> toJson() => {
    'id': id,
    'notes': notes,
    'userId': userId,
    'latitude': latitude,
    'longitude': longitude,
    'weatherDescription': weatherDescription,
    'localImagePath': localImagePath,
    'remoteImageUrl': remoteImagePath,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'syncedToServer': syncedToServer,
  };

  factory FieldLog.fromJson(Map<String, dynamic> map) {
    return FieldLog(
      id: map['id'] as String,
      notes: map['notes'] as String,
      userId: map['userId'] as String?,
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      weatherDescription: map['weatherDescription'] as String?,
      localImagePath: map['localImagePath'] as String?,
      remoteImagePath: map['remoteImagePath'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
      syncedToServer: map['syncedToServer'] as int,
    );
  }

  FieldLog copyWith({
    String? id,
    String? notes,
    String? userId,
    double? latitude,
    double? longitude,
    String? weatherDescription,
    String? localImagePath,
    String? remoteImagePath,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? syncedToServer,
  }) {
    return FieldLog(
      id: id ?? this.id,
      notes: notes ?? this.notes,
      userId: userId ?? this.userId,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      weatherDescription: weatherDescription ?? this.weatherDescription,
      localImagePath: localImagePath ?? this.localImagePath,
      remoteImagePath: remoteImagePath ?? this.remoteImagePath,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncedToServer: syncedToServer ?? this.syncedToServer,
    );
  }
}
