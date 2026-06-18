/// 스페어 계정 하위 유형 — 전문가(구직) vs 모델(매칭 수신).
enum SpareSubtype {
  professional,
  model,
}

SpareSubtype? spareSubtypeFromJson(Object? json) {
  if (json == null) return null;
  final value = json.toString();
  for (final subtype in SpareSubtype.values) {
    if (subtype.name == value) return subtype;
  }
  return SpareSubtype.professional;
}

Object? spareSubtypeToJson(SpareSubtype? subtype) => subtype?.name;

extension SpareSubtypeX on SpareSubtype {
  String get label => switch (this) {
        SpareSubtype.professional => '스페어·디자이너',
        SpareSubtype.model => '모델',
      };

  bool get isModel => this == SpareSubtype.model;
}
