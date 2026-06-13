import 'package:hairspare/models/business_registration_ocr_result.dart';
import 'package:hairspare/models/business_registration_validation.dart';

/// 사업자등록번호·OCR 교차검증 (클라이언트 UX용).
class BusinessRegistrationValidator {
  BusinessRegistrationValidator._();

  static const _weights = [1, 3, 7, 1, 3, 7, 1, 3, 5];

  /// 하이픈 제거 10자리.
  static String normalizeNumber(String input) {
    return input.replaceAll(RegExp(r'[^0-9]'), '');
  }

  /// 표시용 `XXX-XX-XXXXX`.
  static String formatDisplay(String input) {
    final digits = normalizeNumber(input);
    if (digits.length != 10) return input.trim();
    return '${digits.substring(0, 3)}-${digits.substring(3, 5)}-${digits.substring(5)}';
  }

  /// 국세청 표준 체크섬.
  static bool isValidChecksum(String input) {
    final digits = normalizeNumber(input);
    if (digits.length != 10 || !RegExp(r'^\d{10}$').hasMatch(digits)) {
      return false;
    }
    var sum = 0;
    for (var i = 0; i < 9; i++) {
      sum += int.parse(digits[i]) * _weights[i];
    }
    sum += (int.parse(digits[8]) * 5) ~/ 10;
    final check = (10 - (sum % 10)) % 10;
    return check == int.parse(digits[9]);
  }

  static BusinessRegistrationValidation validateNumberFormat(String input) {
    final digits = normalizeNumber(input);
    if (digits.isEmpty) {
      return const BusinessRegistrationValidation(
        isNumberFormatValid: false,
        numberFormatMessage: '사업자등록번호를 입력해주세요',
      );
    }
    if (digits.length != 10) {
      return const BusinessRegistrationValidation(
        isNumberFormatValid: false,
        numberFormatMessage: '사업자등록번호는 10자리입니다',
      );
    }
    if (!isValidChecksum(input)) {
      return const BusinessRegistrationValidation(
        isNumberFormatValid: false,
        numberFormatMessage: '올바른 사업자등록번호 형식이 아닙니다',
      );
    }
    return const BusinessRegistrationValidation(
      isNumberFormatValid: true,
      requiresNtsCheck: true,
    );
  }

  static String? formValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '사업자등록번호를 입력해주세요';
    }
    final result = validateNumberFormat(value);
    return result.isNumberFormatValid ? null : result.numberFormatMessage;
  }

  /// OCR 추출값 vs 사용자 입력 불일치 (정규화 후 비교).
  static List<String> compareWithOcr({
    required BusinessRegistrationOcrResult ocr,
    required String businessNumber,
    required String businessName,
    required String representativeName,
    required String businessType,
    required String businessCategory,
    required String address,
  }) {
    final mismatches = <String>[];

    void compare(String field, String? ocrValue, String userValue) {
      if (ocrValue == null || ocrValue.trim().isEmpty) return;
      final a = userValue.trim().replaceAll(RegExp(r'\s+'), '');
      final b = ocrValue.trim().replaceAll(RegExp(r'\s+'), '');
      if (field == 'businessNumber') {
        if (normalizeNumber(a) != normalizeNumber(b)) {
          mismatches.add(field);
        }
        return;
      }
      if (a != b) mismatches.add(field);
    }

    compare('businessNumber', ocr.businessNumber, businessNumber);
    compare('businessName', ocr.businessName, businessName);
    compare('representativeName', ocr.representativeName, representativeName);
    compare('businessType', ocr.businessType, businessType);
    compare('businessCategory', ocr.businessCategory, businessCategory);
    compare('address', ocr.address, address);

    return mismatches;
  }

  static BusinessRegistrationValidation buildClientValidation({
    required String businessNumber,
    BusinessRegistrationOcrResult? ocr,
    required String businessName,
    required String representativeName,
    required String businessType,
    required String businessCategory,
    required String address,
  }) {
    final numberResult = validateNumberFormat(businessNumber);
    if (!numberResult.isNumberFormatValid) return numberResult;

    final mismatches = ocr == null
        ? const <String>[]
        : compareWithOcr(
            ocr: ocr,
            businessNumber: businessNumber,
            businessName: businessName,
            representativeName: representativeName,
            businessType: businessType,
            businessCategory: businessCategory,
            address: address,
          );

    return BusinessRegistrationValidation(
      isNumberFormatValid: true,
      ocrMismatches: mismatches,
      requiresNtsCheck: true,
      ntsVerified: null,
      ntsStatusMessage: '국세청 진위·상태 확인은 제출 후 서버에서 진행됩니다',
    );
  }
}
