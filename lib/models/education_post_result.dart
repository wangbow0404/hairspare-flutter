/// 교육 등록 성공 시 서비스가 반환하는 최소 정보(목업·실API 공통).
class EducationPostResult {
  const EducationPostResult({
    required this.id,
    required this.title,
  });

  final String id;
  final String title;
}
