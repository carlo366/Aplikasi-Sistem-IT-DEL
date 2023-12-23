import 'user_model.dart';

class RequestSurat {
  int? id;
  User? user;
  int? approverId;
  String? reason;
  String? pengajuan; // Tambahkan kolom pengajuan
  String? status;

  RequestSurat({
    this.id,
    this.user,
    this.approverId,
    this.reason,
    this.pengajuan, // Tambahkan pengaturan untuk kolom pengajuan
    this.status,
  });

  factory RequestSurat.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return RequestSurat();
    }

    return RequestSurat(
      id: json['id'] as int?,
      approverId: json['approver_id'] as int?,
      reason: json['reason'] as String?,
      pengajuan: json['pengajuan'] as String?, // Tambahkan parsing untuk kolom pengajuan
      status: json['status'] as String?,
      user: json['user'] != null
          ? User.fromJson(json['user'] as Map<String, dynamic>)
          : null,
    );
  }
}
