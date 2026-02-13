class Job {
  final String id;
  final String title;
  final String shopName;
  final String date;
  final String time;
  final String? endTime;
  final int amount;
  final int energy;
  final int requiredCount;
  final String regionId;
  final String? description;
  final String? requirements;
  final List<String>? images;
  final bool isUrgent;
  final bool isPremium;
  final int? countdown;
  final DateTime createdAt;
  final String? ownerId;
  final String status; // "published" | "closed" | "draft"

  Job({
    required this.id,
    required this.title,
    required this.shopName,
    required this.date,
    required this.time,
    this.endTime,
    required this.amount,
    required this.energy,
    required this.requiredCount,
    required this.regionId,
    this.description,
    this.requirements,
    this.images,
    required this.isUrgent,
    required this.isPremium,
    this.countdown,
    required this.createdAt,
    this.ownerId,
    this.status = 'published',
  });

  factory Job.fromJson(Map<String, dynamic> json) {
    return Job(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      shopName: json['shopName']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
      time: json['time']?.toString() ?? '',
      endTime: json['endTime']?.toString(),
      amount: _parseInt(json['amount']) ?? 0,
      energy: _parseInt(json['energy']) ?? 0,
      requiredCount: _parseInt(json['requiredCount']) ?? 1,
      regionId: json['regionId']?.toString() ?? '',
      description: json['description']?.toString(),
      requirements: json['requirements']?.toString(),
      images: json['images'] != null
          ? List<String>.from(
              (json['images'] as List).map((e) => e?.toString() ?? ''))
          : null,
      isUrgent: json['isUrgent'] as bool? ?? false,
      isPremium: json['isPremium'] as bool? ?? false,
      countdown: _parseInt(json['countdown']),
      createdAt: _parseDateTime(json['createdAt']),
      ownerId: json['ownerId']?.toString(),
      status: json['status']?.toString() ?? 'published',
    );
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value == null) {
      return DateTime.now();
    }
    
    // DateTime 객체인 경우
    if (value is DateTime) {
      return value;
    }
    
    // String인 경우
    if (value is String) {
      if (value.isEmpty) {
        return DateTime.now();
      }
      try {
        // ISO 8601 형식 파싱
        return DateTime.parse(value);
      } catch (e) {
        // 파싱 실패 시 현재 시간 반환
        return DateTime.now();
      }
    }
    
    // Map인 경우 (일부 환경에서 DateTime이 Map으로 직렬화될 수 있음)
    if (value is Map) {
      try {
        // ISO 문자열이 있는지 확인
        if (value['iso'] != null && value['iso'] is String) {
          return DateTime.parse(value['iso'] as String);
        }
        // 또는 직접 파싱 시도
        if (value['_value'] != null) {
          final val = value['_value'];
          if (val is String) {
            return DateTime.parse(val);
          }
          if (val is int) {
            return DateTime.fromMillisecondsSinceEpoch(val);
          }
        }
      } catch (e) {
        // 무시하고 계속
      }
    }
    
    // 숫자인 경우 (타임스탬프)
    if (value is int) {
      try {
        return DateTime.fromMillisecondsSinceEpoch(value);
      } catch (e) {
        return DateTime.now();
      }
    }
    
    // 모든 파싱 실패 시 현재 시간 반환
    return DateTime.now();
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      return int.tryParse(value);
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'shopName': shopName,
      'date': date,
      'time': time,
      'endTime': endTime,
      'amount': amount,
      'energy': energy,
      'requiredCount': requiredCount,
      'regionId': regionId,
      'description': description,
      'requirements': requirements,
      'images': images,
      'isUrgent': isUrgent,
      'isPremium': isPremium,
      'countdown': countdown,
      'createdAt': createdAt.toIso8601String(),
      'ownerId': ownerId,
      'status': status,
    };
  }
}
