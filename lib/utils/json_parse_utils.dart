/// JSON / API 역직렬화용 공통 파서 (DRY).
/// 모델별 `_parseDateTime` 중복을 제거합니다.
class JsonParseUtils {
  JsonParseUtils._();

  static DateTime dateTimeOrNow(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    if (value is String) {
      if (value.isEmpty) return DateTime.now();
      try {
        return DateTime.parse(value);
      } catch (_) {
        return DateTime.now();
      }
    }
    if (value is Map) {
      try {
        if (value['iso'] != null && value['iso'] is String) {
          return DateTime.parse(value['iso'] as String);
        }
        final inner = value['_value'];
        if (inner is String) return DateTime.parse(inner);
        if (inner is int) {
          return DateTime.fromMillisecondsSinceEpoch(inner);
        }
      } catch (_) {}
    }
    if (value is int) {
      try {
        return DateTime.fromMillisecondsSinceEpoch(value);
      } catch (_) {
        return DateTime.now();
      }
    }
    return DateTime.now();
  }

  static DateTime? dateTimeNullable(dynamic value) {
    if (value == null) return null;
    return dateTimeOrNow(value);
  }

  static int? intValue(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  static double? doubleValue(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}
