import 'package:flutter/material.dart';
import 'package:project_uas/models/transaksi_model.dart';

class TransactionCard extends StatelessWidget {
  final transaksi transaction;

  TransactionCard(
      {required this.transaction, required Null Function() onDelete});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      child: ListTile(
        title: Text(transaction.kategori),
        subtitle: Text(transaction.deskripsi),
        trailing: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'Rp ${transaction.jumlah.toStringAsFixed(2)}',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              '${transaction.timestamp.toLocal()}'.split(' ')[0],
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
