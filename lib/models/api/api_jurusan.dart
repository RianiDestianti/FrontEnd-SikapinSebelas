class Jurusan {
  final String idJurusan;
  final String namaJurusan;

  Jurusan({
    required this.idJurusan,
    required this.namaJurusan,
  });

  factory Jurusan.fromJson(Map<String, dynamic> json) {
    return Jurusan(
      idJurusan: json['id_jurusan']?.toString() ?? '',
      namaJurusan: json['nama_jurusan']?.toString() ?? '',
    );
  }
}