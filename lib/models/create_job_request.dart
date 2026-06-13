/// 구인 등록 API 요청 본문. [JobService.createJob]의 입력 타입으로 고정해 두면,
/// 실제 HTTP 연동 시에도 ViewModel·UI는 그대로 두고 서비스 구현만 교체하면 됩니다.
class CreateJobRequest {
  const CreateJobRequest({
    required this.title,
    required this.description,
    required this.amount,
    required this.requiredCount,
    required this.provinceId,
    required this.districtId,
    required this.address,
    required this.detailAddress,
    required this.workDate,
    required this.startTime,
    this.endTime,
    required this.role,
    required this.wageType,
    required this.isUrgent,
    this.imageLocalPaths = const [],
    this.shopDisplayName,
  });

  final String title;
  final String description;
  final int amount;
  final int requiredCount;
  final String provinceId;
  final String districtId;
  final String address;
  final String detailAddress;

  /// `yyyy-MM-dd`
  final String workDate;

  /// `HH:mm`
  final String startTime;
  final String? endTime;
  final String role;
  final String wageType;
  final bool isUrgent;

  /// 로컬 파일 경로(추후 멀티파트 업로드 시 사용). 목업 단계에서는 개수만 본문에 반영.
  final List<String> imageLocalPaths;

  /// 미등록 시 서버/목업에서 기본 문구 사용
  final String? shopDisplayName;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'title': title,
        'description': description,
        'amount': amount,
        'requiredCount': requiredCount,
        'provinceId': provinceId,
        'districtId': districtId,
        'address': address,
        'detailAddress': detailAddress,
        'workDate': workDate,
        'startTime': startTime,
        if (endTime != null) 'endTime': endTime,
        'role': role,
        'wageType': wageType,
        'isUrgent': isUrgent,
        'imageCount': imageLocalPaths.length,
        if (shopDisplayName != null && shopDisplayName!.isNotEmpty)
          'shopName': shopDisplayName,
      };
}
