/// 샵 교육 등록 API 요청. [EducationService.createEducation] 입력으로 고정합니다.
class CreateEducationRequest {
  const CreateEducationRequest({
    required this.title,
    required this.description,
    required this.price,
    required this.maxApplicants,
    required this.categoryId,
    required this.subCategory,
    required this.isOnline,
    required this.isUrgent,
    this.provinceId,
    this.districtId,
    required this.address,
    required this.detailAddress,
    required this.deadline,
    this.imageLocalPaths = const [],
  });

  final String title;
  final String description;
  final int price;
  final int maxApplicants;
  final String categoryId;
  final String subCategory;
  final bool isOnline;
  final bool isUrgent;
  final String? provinceId;
  final String? districtId;
  final String address;
  final String detailAddress;

  /// `yyyy-MM-dd`
  final String deadline;
  final List<String> imageLocalPaths;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'title': title,
        'description': description,
        'price': price,
        'maxApplicants': maxApplicants,
        'categoryId': categoryId,
        'subCategory': subCategory,
        'isOnline': isOnline,
        'isUrgent': isUrgent,
        if (provinceId != null) 'provinceId': provinceId,
        if (districtId != null) 'districtId': districtId,
        'address': address,
        'detailAddress': detailAddress,
        'deadline': deadline,
        'imageCount': imageLocalPaths.length,
      };
}
