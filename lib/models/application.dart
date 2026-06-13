import 'package:json_annotation/json_annotation.dart';

import 'job.dart';
import 'json_converters.dart';
import 'user.dart';

part 'application.g.dart';

Job _applicationJobFromJson(Object? json) => Job.fromJson(
      json is Map<String, dynamic> ? json : <String, dynamic>{},
    );

User _applicationSpareFromJson(Object? json) => User.fromJson(
      json is Map<String, dynamic> ? json : <String, dynamic>{},
    );

@JsonSerializable(explicitToJson: true)
class Application {
  const Application({
    required this.id,
    required this.status,
    required this.createdAt,
    required this.job,
    required this.spare,
  });

  @JsonKey(defaultValue: '')
  final String id;
  @JsonKey(defaultValue: 'pending')
  final String status;
  @DateTimeOrNowConverter()
  final DateTime createdAt;
  @JsonKey(fromJson: _applicationJobFromJson)
  final Job job;
  @JsonKey(fromJson: _applicationSpareFromJson)
  final User spare;

  factory Application.fromJson(Map<String, dynamic> json) =>
      _$ApplicationFromJson(json);

  Map<String, dynamic> toJson() => _$ApplicationToJson(this);
}
