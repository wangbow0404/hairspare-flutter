enum UserRole {
  spare,
  shop,
}

enum SpareRole {
  step,
  designer,
}

class User {
  final String id;
  final String username;
  final String? email;
  final String? name;
  final String? phone;
  final UserRole role;
  final String? profileImage;
  final DateTime createdAt;

  User({
    required this.id,
    required this.username,
    this.email,
    this.name,
    this.phone,
    required this.role,
    this.profileImage,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      email: json['email']?.toString(),
      name: json['name']?.toString(),
      phone: json['phone']?.toString(),
      role: UserRole.values.firstWhere(
        (e) => e.name == json['role']?.toString(),
        orElse: () => UserRole.spare,
      ),
      profileImage: json['profileImage']?.toString(),
      createdAt: _parseDateTime(json['createdAt']),
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'name': name,
      'phone': phone,
      'role': role.name,
      'profileImage': profileImage,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
