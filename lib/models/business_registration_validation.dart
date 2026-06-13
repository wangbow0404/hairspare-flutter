/// 사업자등록 클라이언트·서버 검증 결과.
class BusinessRegistrationValidation {
  const BusinessRegistrationValidation({
    required this.isNumberFormatValid,
    this.numberFormatMessage,
    this.ocrMismatches = const [],
    this.requiresNtsCheck = true,
    this.ntsVerified,
    this.ntsStatusMessage,
    this.serverValidated = false,
  });

  factory BusinessRegistrationValidation.fromJson(Map<String, dynamic> json) {
    final mismatches = json['mismatches'];
    return BusinessRegistrationValidation(
      isNumberFormatValid: json['isNumberFormatValid'] as bool? ?? false,
      numberFormatMessage: json['numberFormatMessage']?.toString(),
      ocrMismatches: mismatches is List
          ? mismatches.map((e) => e.toString()).toList()
          : const [],
      requiresNtsCheck: json['requiresNtsCheck'] as bool? ?? true,
      ntsVerified: json['ntsVerified'] as bool?,
      ntsStatusMessage: json['ntsStatusMessage']?.toString(),
      serverValidated: json['serverValidated'] as bool? ?? false,
    );
  }

  final bool isNumberFormatValid;
  final String? numberFormatMessage;
  final List<String> ocrMismatches;
  final bool requiresNtsCheck;
  final bool? ntsVerified;
  final String? ntsStatusMessage;
  final bool serverValidated;

  bool get hasOcrMismatch => ocrMismatches.isNotEmpty;

  Map<String, dynamic> toJson() => {
        'isNumberFormatValid': isNumberFormatValid,
        'numberFormatMessage': numberFormatMessage,
        'mismatches': ocrMismatches,
        'requiresNtsCheck': requiresNtsCheck,
        'ntsVerified': ntsVerified,
        'ntsStatusMessage': ntsStatusMessage,
        'serverValidated': serverValidated,
      };
}
