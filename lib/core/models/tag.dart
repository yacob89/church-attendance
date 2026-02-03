enum TagType {
  saints,
  meeting;

  String toJson() => name;
  static TagType fromJson(String json) => values.byName(json);
}

class Tag {
  final int? id;
  final DateTime? createdAt;
  final TagType type;
  final String name;

  Tag({this.id, this.createdAt, required this.type, required this.name});

  factory Tag.fromJson(Map<String, dynamic> json) {
    return Tag(
      id: json['id'] as int?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      type: TagType.fromJson(json['type'] as String),
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      // created_at is usually handled by Supabase default
      'type': type.toJson(),
      'name': name,
    };
  }
}
