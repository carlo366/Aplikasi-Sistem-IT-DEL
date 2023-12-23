class Pemesanan {
  int id;
  int user_id;
  int kaos_id;
  int jumlah_pesanan;
  int total_harga;

  Pemesanan(
      {required this.id,
      required this.user_id,
      required this.kaos_id,
      required this.jumlah_pesanan,
      required this.total_harga,
      required});

  factory Pemesanan.fromJson(Map<String, dynamic> json) {
    return Pemesanan(
      id: json['id'],
      user_id: json['user_id'] ?? 0, // handle null if needed
      kaos_id: json['kaos_id'] ?? '',
      jumlah_pesanan: json['jumlah_pesanan'] ?? '',
      total_harga: json['total_harga'] ?? '',
    );
  }
}
