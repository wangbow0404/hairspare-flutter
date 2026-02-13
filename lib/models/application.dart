import 'job.dart';
import 'user.dart';

class Application {
  final String id;
  final String status; // "pending" | "approved" | "rejected"
  final DateTime createdAt;
  final Job job;
  final User spare;

  Application({
    required this.id,
    required this.status,
    required this.createdAt,
    required this.job,
    required this.spare,
  });

  factory Application.fromJson(Map<String, dynamic> json) {
    return Application(
      id: json['id']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
      createdAt: _parseDateTime(json['createdAt']),
      job: Job.fromJson(json['job'] ?? {}),
      spare: User.fromJson(json['spare'] ?? {}),
    );
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value == null) {
      return DateTime.now();
    }
    
    if (value is DateTime) {
      return value;
    }
    
    if (value is String) {
      if (value.isEmpty) {
        return DateTime.now();
      }
      try {
        return DateTime.parse(value);
      } catch (e) {
        return DateTime.now();
      }
    }
    
    if (value is int) {
      try {
        return DateTime.fromMillisecondsSinceEpoch(value);
      } catch (e) {
        return DateTime.now();
      }
    }
    
    return DateTime.now();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'job': job.toJson(),
      'spare': spare.toJson(),
    };
  }
}
