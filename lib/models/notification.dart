import 'package:json_annotation/json_annotation.dart';

import 'json_converters.dart';

part 'notification.g.dart';

@JsonSerializable()
class AppNotification {
  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.isRead,
    required this.createdAt,
    this.relatedJobId,
    this.relatedUserId,
    this.relatedScheduleId,
    this.relatedBookingId,
    this.scheduleTime,
    this.scheduleDate,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) =>
      _$AppNotificationFromJson(json);

  @JsonKey(defaultValue: '')
  final String id;
  @JsonKey(defaultValue: '')
  final String type;
  @JsonKey(defaultValue: '')
  final String title;
  @JsonKey(defaultValue: '')
  final String message;
  @JsonKey(defaultValue: false)
  final bool isRead;
  @DateTimeOrNowConverter()
  final DateTime createdAt;
  final String? relatedJobId;
  final String? relatedUserId;
  final String? relatedScheduleId;
  final String? relatedBookingId;
  final String? scheduleTime;
  final String? scheduleDate;

  Map<String, dynamic> toJson() => _$AppNotificationToJson(this);

  AppNotification copyWith({
    bool? isRead,
    DateTime? createdAt,
  }) {
    return AppNotification(
      id: id,
      type: type,
      title: title,
      message: message,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      relatedJobId: relatedJobId,
      relatedUserId: relatedUserId,
      relatedScheduleId: relatedScheduleId,
      relatedBookingId: relatedBookingId,
      scheduleTime: scheduleTime,
      scheduleDate: scheduleDate,
    );
  }
}
