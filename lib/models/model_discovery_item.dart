import 'hair_model.dart';

/// 추천 소진 후 노출되는 모델 피드 유형.
enum ModelDiscoveryKind {
  popular,
  newlyJoined,
}

/// 인기·신규 등 탐색 피드 항목.
class ModelDiscoveryItem {
  const ModelDiscoveryItem({
    required this.model,
    required this.kind,
  });

  final HairModel model;
  final ModelDiscoveryKind kind;

  String get badgeLabel => switch (kind) {
        ModelDiscoveryKind.popular => '인기',
        ModelDiscoveryKind.newlyJoined => 'NEW',
      };
}
