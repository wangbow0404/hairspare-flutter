/// 교육 사전 자료 (PDF 등).
class EducationMaterial {
  const EducationMaterial({
    required this.title,
    required this.url,
    this.fileType = 'pdf',
  });

  factory EducationMaterial.fromJson(Map<String, dynamic> json) {
    return EducationMaterial(
      title: json['title']?.toString() ?? '자료',
      url: json['url']?.toString() ?? '',
      fileType: json['fileType']?.toString() ?? 'pdf',
    );
  }

  final String title;
  final String url;
  final String fileType;

  Map<String, dynamic> toJson() => {
        'title': title,
        'url': url,
        'fileType': fileType,
      };
}
