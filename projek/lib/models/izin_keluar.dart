import 'package:projek/models/user_model.dart';

class RequestIzinKeluar {
  int id;
  User user;
  int approverId;
  String reason;
  DateTime startDate;
  DateTime endDate;
  String? status;

  RequestIzinKeluar({
    required this.id,
    required this.user,
    required this.approverId,
    required this.reason,
    required this.startDate,
    required this.endDate,
    required this.status,
  });

  factory RequestIzinKeluar.fromJson(Map<String, dynamic> json) {
    return RequestIzinKeluar(
      id: json['id'] as int? ??
          0, // Provide a default value for non-nullable fields
      approverId: json['approver_id'] as int? ?? 0,
      reason: json['reason'] as String? ?? "",
      startDate: json['start_date'] != null
          ? DateTime.parse(json['start_date'])
          : DateTime.now(), // Provide a default value if 'start_date' is null
      endDate: json['end_date'] != null
          ? DateTime.parse(json['end_date'])
          : DateTime.now(), // Provide a default value if 'end_date' is null
      status: json['status'] as String?,
      user: json['user'] != null
          ? User(
              id: json['user']['id'] as int,
              fullname: json['user']['fullname'] as String)
          : User(
              id: 0,
              fullname: ""), // Provide default values for User if 'user' is null
    );
  }
}