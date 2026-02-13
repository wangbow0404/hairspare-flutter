enum RegionType {
  province,
  city,
  district,
}

class Region {
  final String id;
  final String name;
  final String? parentId;
  final RegionType type;

  Region({
    required this.id,
    required this.name,
    this.parentId,
    required this.type,
  });

  factory Region.fromJson(Map<String, dynamic> json) {
    return Region(
      id: json['id'] as String,
      name: json['name'] as String,
      parentId: json['parentId'] as String?,
      type: RegionType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => RegionType.district,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'parentId': parentId,
      'type': type.name,
    };
  }
}
