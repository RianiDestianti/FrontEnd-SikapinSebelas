// class ApiAppreciation {
//   final int idPenghargaan;
//   final String tanggalPenghargaan;
//   final String levelPenghargaan;
//   final String alasan;
//   final String? createdAt;
//   final String? updatedAt;

//   ApiAppreciation({
//     required this.idPenghargaan,
//     required this.tanggalPenghargaan,
//     required this.levelPenghargaan,
//     required this.alasan,
//     this.createdAt,
//     this.updatedAt,
//   });

//   factory ApiAppreciation.fromJson(Map<String, dynamic> json) {
//     return ApiAppreciation(
//       idPenghargaan: json['id_penghargaan'],
//       tanggalPenghargaan: json['tanggal_penghargaan'],
//       levelPenghargaan: json['level_penghargaan'],
//       alasan: json['alasan'],
//       createdAt: json['created_at'],
//       updatedAt: json['updated_at'],
//     );
//   }
// }