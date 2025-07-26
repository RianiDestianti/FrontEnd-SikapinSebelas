// walikelas/siswa.dart
import 'package:flutter/material.dart';

class SiswaScreen extends StatelessWidget {
  const SiswaScreen({Key? key}) : super(key: key);

  final List<Map<String, String>> students = const [
    {"name": "Ahmad Sudarji", "nisn": "23000001", "status": "Aman", "points": "20", "priority": ""},
    {"name": "Agus Berto", "nisn": "23000002", "status": "Aman", "points": "0", "priority": ""},
    {"name": "Bobby Dasta", "nisn": "23000003", "status": "Bermasalah", "points": "0", "priority": ""},
    {"name": "Berto", "nisn": "23000004", "status": "Prioritas", "points": "0", "priority": "red"},
    {"name": "Celine Agustinus", "nisn": "23000006", "status": "Aman", "points": "0", "priority": ""},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () {},
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.white),
            onPressed: () {},
          ),
          const CircleAvatar(
            backgroundImage: NetworkImage('https://via.placeholder.com/40'),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Colors.blue,
            child: Column(
              children: [
                const Text(
                  'Daftar Siswa XI RPL 2',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: const TextField(
                    decoration: InputDecoration(
                      hintText: 'Search',
                      prefixIcon: Icon(Icons.search),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(10),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Semua'),
                    ),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Aman'),
                    ),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Bermasalah'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: students.length,
              itemBuilder: (context, index) {
                final student = students[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.grey[300],
                      child: Text(
                        student['name']![0].toUpperCase(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                    title: Text(student['name']!),
                    subtitle: Text('NISN : ${student['nisn']}'),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getPointsColor(student['points']!),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Poin : ${student['points']}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    onTap: () {
                      // Navigasi ke detail siswa
                      _showStudentDetail(context, student);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Color _getPointsColor(String points) {
    int pointValue = int.tryParse(points) ?? 0;
    if (pointValue == 0) {
      return Colors.green;
    } else if (pointValue <= 50) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  void _showStudentDetail(BuildContext context, Map<String, String> student) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(student['name']!),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('NISN: ${student['nisn']}'),
              const SizedBox(height: 8),
              Text('Status: ${student['status']}'),
              const SizedBox(height: 8),
              Text('Poin: ${student['points']}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Tutup'),
            ),
          ],
        );
      },
    );
  }
}