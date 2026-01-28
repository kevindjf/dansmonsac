import 'shared_schedule_data.dart';

/// Represents a row in the shared_schedules Supabase table
class SharedSchedule {
  final String id;
  final String code;
  final String? sharerName;
  final SharedScheduleData data;
  final DateTime createdAt;

  SharedSchedule({
    required this.id,
    required this.code,
    this.sharerName,
    required this.data,
    required this.createdAt,
  });

  factory SharedSchedule.fromJson(Map<String, dynamic> json) {
    return SharedSchedule(
      id: json['id'] as String,
      code: json['code'] as String,
      sharerName: json['sharer_name'] as String?,
      data: SharedScheduleData.fromJson(json['data'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'sharer_name': sharerName,
      'data': data.toJson(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// For insert (without id and created_at which are auto-generated)
  Map<String, dynamic> toInsertJson() {
    return {
      'code': code,
      'sharer_name': sharerName,
      'data': data.toJson(),
    };
  }
}
