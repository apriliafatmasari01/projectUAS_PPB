import 'package:cloud_firestore/cloud_firestore.dart';

class transaksi {
  final double jumlah;
  final String kategori;
  final String deskripsi;
  final DateTime timestamp;

  transaksi({
    required this.jumlah,
    required this.kategori,
    required this.deskripsi,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'jumlah': jumlah,
      'kategori': kategori,
      'deskripsi': deskripsi,
      'timestamp': timestamp,
    };
  }

  factory transaksi.fromMap(Map<String, dynamic> map) {
    return transaksi(
      jumlah: (map['jumlah'] as num).toDouble(),
      kategori: map['kategori'] ?? 'Tidak Diketahui',
      deskripsi: map['deskripsi'] ?? 'Tidak Ada Deskripsi',
      timestamp: map['timestamp'] != null
          ? (map['timestamp'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  get id => null;
}
