import 'package:flutter/material.dart';
import 'score.dart';

class Student {
  final String name;
  final int totalPoin;
  final int apresiasi;
  final int pelanggaran;
  final bool isPositive;
  final Color color;
  final String avatar;
  final List<Score> scores;

  Student({
    required this.name,
    required this.totalPoin,
    required this.apresiasi,
    required this.pelanggaran,
    required this.isPositive,
    required this.color,
    required this.avatar,
    required this.scores,
  });
}

class BestStudent {
  final String nama;
  final String kelas;
  final int poin;
  final String prestasi;
  final IconData avatar;
  final int rank;

  BestStudent({
    required this.nama,
    required this.kelas,
    required this.poin,
    required this.prestasi,
    required this.avatar,
    required this.rank,
  });
}

class ViolationStudent {
  final String nama;
  final String kelas;
  final String pelanggaran;
  final int poin;
  final IconData avatar;
  final String severity;

  ViolationStudent({
    required this.nama,
    required this.kelas,
    required this.pelanggaran,
    required this.poin,
    required this.avatar,
    required this.severity,
  });
}

