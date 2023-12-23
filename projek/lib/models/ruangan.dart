class Ruangan {
  int? id;
  // ignore: non_constant_identifier_names
  String? NamaRuangan;

  Ruangan({
    this.id,
    // ignore: non_constant_identifier_names
    this.NamaRuangan,
  });

  factory Ruangan.fromJson(Map<String, dynamic> json) {
    return Ruangan(
      id: json['id'] as int?,
      NamaRuangan: json['NamaRuangan'] as String?,
    );
  }
}
