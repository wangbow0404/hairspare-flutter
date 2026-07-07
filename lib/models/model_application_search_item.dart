import 'hair_model.dart';

/// "날짜검색"에서 조회되는 모델 신청 항목 — 신청 날짜 정보 + 모델 프로필.
class ModelApplicationSearchItem {
  const ModelApplicationSearchItem({
    required this.dateId,
    required this.postId,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.keywords,
    required this.memo,
    required this.model,
  });

  factory ModelApplicationSearchItem.fromJson(Map<String, dynamic> json) {
    return ModelApplicationSearchItem(
      dateId: json['dateId']?.toString() ?? '',
      postId: json['postId']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
      startTime: json['startTime']?.toString() ?? '',
      endTime: json['endTime']?.toString() ?? '',
      keywords: json['keywords'] is List
          ? (json['keywords'] as List).map((e) => e.toString()).toList()
          : const <String>[],
      memo: json['memo']?.toString(),
      model: HairModel.fromJson(
        (json['model'] as Map?)?.cast<String, dynamic>() ?? const {},
      ),
    );
  }

  final String dateId;
  final String postId;
  final String date;
  final String startTime;
  final String endTime;
  final List<String> keywords;
  final String? memo;
  final HairModel model;
}
