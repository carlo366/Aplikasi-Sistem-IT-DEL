import 'package:projek/models/user_model.dart';

class RequestIzinBermalam {
  int id;
  User user;
  int approverId;
  String tujuan; // Tambahkan atribut tujuan
  String reason;
  DateTime startDate;
  DateTime endDate;
  String? status;

  RequestIzinBermalam({
    required this.id,
    required this.user,
    required this.approverId,
    required this.tujuan, // Tambahkan inisialisasi untuk tujuan
    required this.reason,
    required this.startDate,
    required this.endDate,
    required this.status,
  });

  factory RequestIzinBermalam.fromJson(Map<String, dynamic> json) {
    return RequestIzinBermalam(
      id: json['id'] as int? ?? 0,
      approverId: json['approver_id'] as int? ?? 0,
      tujuan: json['tujuan'] as String? ?? "", // Ambil nilai tujuan dari JSON
      reason: json['reason'] as String? ?? "",
      startDate: json['start_date'] != null
          ? DateTime.parse(json['start_date'])
          : DateTime.now(),
      endDate: json['end_date'] != null
          ? DateTime.parse(json['end_date'])
          : DateTime.now(),
      status: json['status'] as String?,
      user: json['user'] != null
          ? User(
              id: json['user']['id'] as int,
              fullname: json['user']['fullname'] as String)
          : User(id: 0, fullname: ""),
    );
  }
}
