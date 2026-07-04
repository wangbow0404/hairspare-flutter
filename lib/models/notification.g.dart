// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppNotification _$AppNotificationFromJson(Map<String, dynamic> json) =>
    AppNotification(
      id: json['id'] as String? ?? '',
      type: json['type'] as String? ?? '',
      title: json['title'] as String? ?? '',
      message: json['message'] as String? ?? '',
      isRead: json['isRead'] as bool? ?? false,
      createdAt: const DateTimeOrNowConverter().fromJson(json['createdAt']),
      relatedJobId: json['relatedJobId'] as String?,
      relatedUserId: json['relatedUserId'] as String?,
      relatedScheduleId: json['relatedScheduleId'] as String?,
      relatedBookingId: json['relatedBookingId'] as String?,
      relatedChatId: json['relatedChatId'] as String?,
      scheduleTime: json['scheduleTime'] as String?,
      scheduleDate: json['scheduleDate'] as String?,
    );

Map<String, dynamic> _$AppNotificationToJson(AppNotification instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'title': instance.title,
      'message': instance.message,
      'isRead': instance.isRead,
      'createdAt': const DateTimeOrNowConverter().toJson(instance.createdAt),
      'relatedJobId': instance.relatedJobId,
      'relatedUserId': instance.relatedUserId,
      'relatedScheduleId': instance.relatedScheduleId,
      'relatedBookingId': instance.relatedBookingId,
      'relatedChatId': instance.relatedChatId,
      'scheduleTime': instance.scheduleTime,
      'scheduleDate': instance.scheduleDate,
    };
