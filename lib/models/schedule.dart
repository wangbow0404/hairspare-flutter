import 'job.dart';

class SpareInfo {
  final String id;
  final String name;

  SpareInfo({
    required this.id,
    required this.name,
  });

  factory SpareInfo.fromJson(Map<String, dynamic> json) {
    return SpareInfo(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
    );
  }
}

class Schedule {
  final String id;
  final String jobId;
  final String spareId;
  final String shopId;
  final String date;
  final String startTime;
  final String? endTime;
  final String status; // "scheduled" | "completed" | "cancelled"
  final DateTime? checkInTime;
  final DateTime? checkOutTime;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Job? job;
  final SpareInfo? spare; // 스페어 정보 (API에서 제공되는 경우)

  Schedule({
    required this.id,
    required this.jobId,
    required this.spareId,
    required this.shopId,
    required this.date,
    required this.startTime,
    this.endTime,
    required this.status,
    this.checkInTime,
    this.checkOutTime,
    required this.createdAt,
    required this.updatedAt,
    this.job,
    this.spare,
  });

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      id: json['id']?.toString() ?? '',
      jobId: json['jobId']?.toString() ?? '',
      spareId: json['spareId']?.toString() ?? '',
      shopId: json['shopId']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
      startTime: json['startTime']?.toString() ?? '',
      endTime: json['endTime']?.toString(),
      status: json['status']?.toString() ?? 'scheduled',
      checkInTime: json['checkInTime'] != null
          ? _parseDateTime(json['checkInTime'])
          : null,
      checkOutTime: json['checkOutTime'] != null
          ? _parseDateTime(json['checkOutTime'])
          : null,
      createdAt: _parseDateTime(json['createdAt']),
      updatedAt: _parseDateTime(json['updatedAt']),
      job: json['job'] != null ? Job.fromJson(json['job']) : null,
      spare: json['spare'] != null ? SpareInfo.fromJson(json['spare']) : null,
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
    
    if (value is Map) {
      try {
        if (value['iso'] != null && value['iso'] is String) {
          return DateTime.parse(value['iso'] as String);
        }
        if (value['_value'] != null) {
          return DateTime.fromMillisecondsSinceEpoch(value['_value'] as int);
        }
      } catch (e) {
        // ignore
      }
    }
    
    return DateTime.now();
  }
}
