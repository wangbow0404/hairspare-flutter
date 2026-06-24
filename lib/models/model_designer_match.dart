/// 모델 ↔ 디자이너(샵) 매칭 — 채팅방과 1:1 연결.
class ModelDesignerMatch {
  const ModelDesignerMatch({
    required this.id,
    required this.chatId,
    required this.shopId,
    required this.designerName,
    required this.treatment,
    required this.region,
    this.interestId,
  });

  final String id;
  final String chatId;
  final String shopId;
  final String designerName;
  final String treatment;
  final String region;
  final String? interestId;
}
