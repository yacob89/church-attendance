class Saint {
  final int? id;
  final DateTime? createdAt;
  final String name;
  final String? city;
  final String? address;
  final String? phone;
  final String? school;
  final String? meetingHall;
  final DateTime? birthdate;
  final String? note;

  Saint({
    this.id,
    this.createdAt,
    required this.name,
    this.city,
    this.address,
    this.phone,
    this.school,
    this.meetingHall,
    this.birthdate,
    this.note,
  });

  factory Saint.fromJson(Map<String, dynamic> json) {
    return Saint(
      id: json['id'] as int?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      name: json['name'] as String,
      city: json['city'] as String?,
      address: json['address'] as String?,
      phone: json['phone'] as String?,
      school: json['school'] as String?,
      meetingHall: json['meeting_hall'] as String?,
      birthdate: json['birthdate'] != null
          ? DateTime.parse(json['birthdate'] as String)
          : null,
      note: json['note'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'city': city,
      'address': address,
      'phone': phone,
      'school': school,
      'meeting_hall': meetingHall,
      'birthdate': birthdate?.toIso8601String(),
      'note': note,
    };
  }
}
