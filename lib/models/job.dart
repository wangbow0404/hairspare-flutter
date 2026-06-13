import 'package:json_annotation/json_annotation.dart';

import 'json_converters.dart';

part 'job.g.dart';

List<String>? _jobImagesFromJson(dynamic json) {
  if (json == null) return null;
  if (json is! List) return null;
  return json.map((e) => e?.toString() ?? '').toList();
}

dynamic _jobImagesToJson(List<String>? images) => images;

@JsonSerializable()
class Job {
  const Job({
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
    this.isHidden = false,
  });

  @JsonKey(defaultValue: '')
  final String id;
  @JsonKey(defaultValue: '')
  final String title;
  @JsonKey(defaultValue: '')
  final String shopName;
  @JsonKey(defaultValue: '')
  final String date;
  @JsonKey(defaultValue: '')
  final String time;
  final String? endTime;
  @LooseIntAsZeroConverter()
  final int amount;
  @LooseIntAsZeroConverter()
  final int energy;
  @LooseIntAsOneConverter()
  final int requiredCount;
  @JsonKey(defaultValue: '')
  final String regionId;
  final String? description;
  final String? requirements;
  @JsonKey(fromJson: _jobImagesFromJson, toJson: _jobImagesToJson)
  final List<String>? images;
  @JsonKey(defaultValue: false)
  final bool isUrgent;
  @JsonKey(defaultValue: false)
  final bool isPremium;
  @LooseIntNullableConverter()
  final int? countdown;
  @DateTimeOrNowConverter()
  final DateTime createdAt;
  final String? ownerId;
  @JsonKey(defaultValue: 'published')
  final String status;
  @JsonKey(defaultValue: false)
  final bool isHidden;

  factory Job.fromJson(Map<String, dynamic> json) => _$JobFromJson(json);

  Job copyWith({
    String? id,
    String? title,
    String? shopName,
    String? date,
    String? time,
    String? endTime,
    int? amount,
    int? energy,
    int? requiredCount,
    String? regionId,
    String? description,
    String? requirements,
    List<String>? images,
    bool? isUrgent,
    bool? isPremium,
    int? countdown,
    DateTime? createdAt,
    String? ownerId,
    String? status,
    bool? isHidden,
  }) {
    return Job(
      id: id ?? this.id,
      title: title ?? this.title,
      shopName: shopName ?? this.shopName,
      date: date ?? this.date,
      time: time ?? this.time,
      endTime: endTime ?? this.endTime,
      amount: amount ?? this.amount,
      energy: energy ?? this.energy,
      requiredCount: requiredCount ?? this.requiredCount,
      regionId: regionId ?? this.regionId,
      description: description ?? this.description,
      requirements: requirements ?? this.requirements,
      images: images ?? this.images,
      isUrgent: isUrgent ?? this.isUrgent,
      isPremium: isPremium ?? this.isPremium,
      countdown: countdown ?? this.countdown,
      createdAt: createdAt ?? this.createdAt,
      ownerId: ownerId ?? this.ownerId,
      status: status ?? this.status,
      isHidden: isHidden ?? this.isHidden,
    );
  }

  Map<String, dynamic> toJson() => _$JobToJson(this);
}
