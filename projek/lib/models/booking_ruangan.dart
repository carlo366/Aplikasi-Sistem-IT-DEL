class BookingRuangan {
  int id;
  int approverId;
  String reason;
  DateTime startTime;
  DateTime endTime;
  String status;
  int userId;
  int roomId;
  DateTime createdAt;
  DateTime updatedAt;
  DateTime startDate;
  DateTime endDate;
  // ignore: non_constant_identifier_names
  String ruangan_name;

  BookingRuangan(
      {required this.id,
      required this.approverId,
      required this.reason,
      required this.startTime,
      required this.endTime,
      required this.status,
      required this.userId,
      required this.roomId,
      required this.createdAt,
      required this.updatedAt,
      required this.startDate,
      required this.endDate,
      // ignore: non_constant_identifier_names
      required this.ruangan_name,
      required});

  factory BookingRuangan.fromJson(Map<String, dynamic> json) {
    return BookingRuangan(
      id: json['id'],
      approverId: json['approver_id'] ?? 0, // handle null if needed
      reason: json['reason'] ?? '',
      startTime: DateTime.parse(json['start_time']),
      endTime: DateTime.parse(json['end_time']),
      status: json['status'] ?? '',
      userId: json['user_id'],
      roomId: json['room_id'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      startDate: json['start_date'] != null
          ? DateTime.parse(json['start_date'])
          : DateTime.now(), // adjust default value if needed
      endDate: json['end_date'] != null
          ? DateTime.parse(json['end_date'])
          : DateTime.now(), // adjust default value if needed
      ruangan_name: json['ruangan_name'],
    );
  }
}
