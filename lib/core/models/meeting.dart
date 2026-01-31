class Meeting {
  final int? id;
  final DateTime? createdAt;
  final String name;
  final DateTime? meetingDate;
  final String? note;

  Meeting({
    this.id,
    this.createdAt,
    required this.name,
    this.meetingDate,
    this.note,
  });

  factory Meeting.fromJson(Map<String, dynamic> json) {
    return Meeting(
      id: json['id'] as int?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      name: json['name'] as String,
      meetingDate: json['meeting_date'] != null
          ? DateTime.parse(json['meeting_date'] as String)
          : null,
      note: json['note'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'meeting_date': meetingDate?.toIso8601String(),
      'note': note,
    };
  }
}
