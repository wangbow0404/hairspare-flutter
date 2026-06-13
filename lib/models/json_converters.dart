import 'package:json_annotation/json_annotation.dart';

import '../utils/json_parse_utils.dart';

/// API가 날짜를 문자·맵·밀리초 등으로 줄 때 기존 [JsonParseUtils.dateTimeOrNow]와 동일하게 파싱합니다.
class DateTimeOrNowConverter implements JsonConverter<DateTime, dynamic> {
  const DateTimeOrNowConverter();

  @override
  DateTime fromJson(dynamic json) => JsonParseUtils.dateTimeOrNow(json);

  @override
  dynamic toJson(DateTime object) => object.toIso8601String();
}

/// Nullable 버전 (null 이면 null 유지, 비-null 이면 [DateTimeOrNowConverter]와 동일).
class DateTimeNullableConverter implements JsonConverter<DateTime?, dynamic> {
  const DateTimeNullableConverter();

  @override
  DateTime? fromJson(dynamic json) => JsonParseUtils.dateTimeNullable(json);

  @override
  dynamic toJson(DateTime? object) => object?.toIso8601String();
}

/// API가 int를 문자·실수로 줄 때 [JsonParseUtils.intValue] ?? 0.
class LooseIntAsZeroConverter implements JsonConverter<int, dynamic> {
  const LooseIntAsZeroConverter();

  @override
  int fromJson(dynamic json) => JsonParseUtils.intValue(json) ?? 0;

  @override
  dynamic toJson(int object) => object;
}

/// [JsonParseUtils.intValue] ?? 1 (필수 인원 등).
class LooseIntAsOneConverter implements JsonConverter<int, dynamic> {
  const LooseIntAsOneConverter();

  @override
  int fromJson(dynamic json) => JsonParseUtils.intValue(json) ?? 1;

  @override
  dynamic toJson(int object) => object;
}

class LooseIntNullableConverter implements JsonConverter<int?, dynamic> {
  const LooseIntNullableConverter();

  @override
  int? fromJson(dynamic json) => JsonParseUtils.intValue(json);

  @override
  dynamic toJson(int? object) => object;
}

/// [JsonParseUtils.doubleValue] ?? 0.0
class LooseDoubleAsZeroConverter implements JsonConverter<double, dynamic> {
  const LooseDoubleAsZeroConverter();

  @override
  double fromJson(dynamic json) => JsonParseUtils.doubleValue(json) ?? 0.0;

  @override
  dynamic toJson(double object) => object;
}

class LooseDoubleNullableConverter implements JsonConverter<double?, dynamic> {
  const LooseDoubleNullableConverter();

  @override
  double? fromJson(dynamic json) => JsonParseUtils.doubleValue(json);

  @override
  dynamic toJson(double? object) => object;
}

/// `DateTime.parse` 실패 시 `DateTime.now()` (기존 모델의 단순 parse 패턴).
class IsoDateTimeOrNowConverter implements JsonConverter<DateTime, dynamic> {
  const IsoDateTimeOrNowConverter();

  @override
  DateTime fromJson(dynamic json) {
    if (json == null) return DateTime.now();
    if (json is DateTime) return json;
    try {
      return DateTime.parse(json.toString());
    } catch (_) {
      return DateTime.now();
    }
  }

  @override
  dynamic toJson(DateTime object) => object.toIso8601String();
}

class IsoDateTimeNullableConverter implements JsonConverter<DateTime?, dynamic> {
  const IsoDateTimeNullableConverter();

  @override
  DateTime? fromJson(dynamic json) {
    if (json == null) return null;
    try {
      return DateTime.parse(json.toString());
    } catch (_) {
      return null;
    }
  }

  @override
  dynamic toJson(DateTime? object) => object?.toIso8601String();
}
