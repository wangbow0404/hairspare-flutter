/// 사업자등록증 OCR 추출 결과 (서버·mock 공통).
class BusinessRegistrationOcrResult {
  const BusinessRegistrationOcrResult({
    required this.requestId,
    this.businessNumber,
    this.businessNumberConfidence,
    this.businessName,
    this.businessNameConfidence,
    this.representativeName,
    this.representativeNameConfidence,
    this.businessType,
    this.businessTypeConfidence,
    this.businessCategory,
    this.businessCategoryConfidence,
    this.address,
    this.addressConfidence,
    this.openingDate,
    this.openingDateConfidence,
  });

  factory BusinessRegistrationOcrResult.fromJson(Map<String, dynamic> json) {
    double? conf(Object? v) =>
        v is num ? v.toDouble() : double.tryParse(v?.toString() ?? '');

    return BusinessRegistrationOcrResult(
      requestId: json['requestId']?.toString() ?? '',
      businessNumber: json['businessNumber']?.toString(),
      businessNumberConfidence: conf(json['businessNumberConfidence']),
      businessName: json['businessName']?.toString(),
      businessNameConfidence: conf(json['businessNameConfidence']),
      representativeName: json['representativeName']?.toString(),
      representativeNameConfidence: conf(json['representativeNameConfidence']),
      businessType: json['businessType']?.toString(),
      businessTypeConfidence: conf(json['businessTypeConfidence']),
      businessCategory: json['businessCategory']?.toString(),
      businessCategoryConfidence: conf(json['businessCategoryConfidence']),
      address: json['address']?.toString(),
      addressConfidence: conf(json['addressConfidence']),
      openingDate: json['openingDate']?.toString(),
      openingDateConfidence: conf(json['openingDateConfidence']),
    );
  }

  final String requestId;
  final String? businessNumber;
  final double? businessNumberConfidence;
  final String? businessName;
  final double? businessNameConfidence;
  final String? representativeName;
  final double? representativeNameConfidence;
  final String? businessType;
  final double? businessTypeConfidence;
  final String? businessCategory;
  final double? businessCategoryConfidence;
  final String? address;
  final double? addressConfidence;
  final String? openingDate;
  final double? openingDateConfidence;

  static const double autoFillConfidenceThreshold = 0.85;

  bool get hasAnyField =>
      businessNumber != null ||
      businessName != null ||
      representativeName != null ||
      businessType != null ||
      businessCategory != null ||
      address != null;

  Map<String, dynamic> toJson() => {
        'requestId': requestId,
        'businessNumber': businessNumber,
        'businessNumberConfidence': businessNumberConfidence,
        'businessName': businessName,
        'businessNameConfidence': businessNameConfidence,
        'representativeName': representativeName,
        'representativeNameConfidence': representativeNameConfidence,
        'businessType': businessType,
        'businessTypeConfidence': businessTypeConfidence,
        'businessCategory': businessCategory,
        'businessCategoryConfidence': businessCategoryConfidence,
        'address': address,
        'addressConfidence': addressConfidence,
        'openingDate': openingDate,
        'openingDateConfidence': openingDateConfidence,
      };
}
