import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:project_uas/screens/home_screen.dart';

class AddTransactionScreen extends StatelessWidget {
  final String category;

  AddTransactionScreen({required this.category});

  final TextEditingController _jumlahController = TextEditingController();
  final TextEditingController _deskripsiController = TextEditingController();

  Future<void> _addTransaction(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final transaction = {
      'jumlah': double.tryParse(_jumlahController.text) ?? 0.0,
      'kategori': category,
      'deskripsi': _deskripsiController.text,
      'timestamp': Timestamp.now(),
    };

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('transactions')
        .add(transaction);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Tambah Transaksi",
          style: TextStyle(
            color: Color(0xFF007A9C),
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 4,
        iconTheme: const IconThemeData(color: Color(0xFF007A9C)),
      ),
      body: Container(
     
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("images/BGbaru1.png"),
            fit:
                BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Kategori: $category",
                  style: const TextStyle(
                    fontSize: 20,
                    color: Color(0xFF007A9C),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),
                _buildTextField(
                  controller: _jumlahController,
                  label: "Harga",
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 16),
                _buildTextField(
                  controller: _deskripsiController,
                  label: "Deskripsi",
                  keyboardType: TextInputType.text,
                ),
                SizedBox(height: 20),
                _buildSaveButton(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required TextInputType keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: Color(0xFF007A9C)),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF007A9C)),
        filled: true,
        fillColor: Colors.white
            .withOpacity(0.7), 
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF007A9C)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF007A9C)),
        ),
      ),
    );
  }

  Widget _buildSaveButton(BuildContext context) {
    return Center(
      
      child: Container(
        width: 200, 
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF8BCBF3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            padding: const EdgeInsets.symmetric(vertical: 10),
          ),
          onPressed: () => _addTransaction(context),
          child: const Text(
            "Simpan Transaksi",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
