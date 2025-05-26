import 'package:intl/intl.dart';

enum AlertType { weather, health, security, traffic, other }

class Alert {
  final String id;
  final String title;
  final String description;
  final DateTime timeStamp;
  final AlertType type;
  final String source;
  final String? imgUrl;
  final bool isActive;
  final Map<String, dynamic>? additionalData;

  Alert({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.timeStamp,
    required this.source,
    this.imgUrl,
    this.isActive = true,
    this.additionalData,
  });

  // Format the timestamp as a readable string
  String get formattedTime {
    final formatter = DateFormat('MMM d, h:mm a');
    return formatter.format(timeStamp);
  }

  // Create from JSON for API responses
  factory Alert.fromJson(Map<String, dynamic> json) {
    // Parse alert type from string
    final alertTypeString = json['type'] as String? ?? 'other';
    final alertType = AlertType.values.firstWhere(
      (type) => type.toString() == 'AlertType.$alertTypeString',
      orElse: () => AlertType.other,
    );

    return Alert(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      type: alertType,
      timeStamp: DateTime.parse(json['timeStamp'] as String),
      source: json['source'] as String,
      imgUrl: json['imageUrl'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      additionalData: json['additionalData'] as Map<String, dynamic>?,
    );
  }

  // For Weather API specifically since it has a different format
  factory Alert.fromWeatherApi(Map<String, dynamic> json) {
    final alert = json['alert'] ?? {};

    return Alert(
      id:
          alert['uid'] as String? ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      title: alert['headline'] as String? ?? 'Weather Alert',
      description: alert['desc'] as String? ?? 'No details available',
      type: AlertType.weather,
      timeStamp: DateTime.parse(
        alert['effective'] as String? ?? DateTime.now().toIso8601String(),
      ),
      source: alert['sender_name'] as String? ?? 'Weather Service',
      isActive: true,
      additionalData: {
        'severity': alert['severity'] as String? ?? 'Unknown',
        'areas': alert['areas'] as String? ?? '',
        'expires': alert['expires'] as String? ?? '',
      },
    );
  }
}
