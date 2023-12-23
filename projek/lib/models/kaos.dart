class Kaos {
  int? id;
  String? ukuran;
  int? harga;

  Kaos({
    this.id,
    this.ukuran,
    this.harga,
  });

  factory Kaos.fromJson(Map<String, dynamic> json) {
    return Kaos(
      id: json['id'] as int?,
      ukuran: json['ukuran'] as String?,
      harga: json['harga'] as int?,
    );
  }
}
