class ApiViolation {
  final int idSp;
  final String tanggalSp;
  final String levelSp;
  final String alasan;
  final String? createdAt;
  final String? updatedAt;

  ApiViolation({
    required this.idSp,
    required this.tanggalSp,
    required this.levelSp,
    required this.alasan,
    this.createdAt,
    this.updatedAt,
  });

  factory ApiViolation.fromJson(Map<String, dynamic> json) {
    return ApiViolation(
      idSp: json['id_sp'],
      tanggalSp: json['tanggal_sp'],
      levelSp: json['level_sp'],
      alasan: json['alasan'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}