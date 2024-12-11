import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project_uas/screens/transaksi_screen.dart';
import 'dart:ui';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String _activePage = 'profile';

  Future<Map<String, dynamic>?> _loadUserProfile() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      return userDoc.data();
    } catch (e) {
      print("Error loading user profile: $e");
      return null;
    }
  }

  Future<void> _updateUserProfile(
      {required String userId, String? newName}) async {
    final userRef = FirebaseFirestore.instance.collection('users').doc(userId);

    Map<String, dynamic> updates = {};

    if (newName != null) {
      updates['nama'] = newName;
    }

    if (updates.isNotEmpty) {
      await userRef.update(updates);
    }
  }

  void _editName(BuildContext context, String userId, String currentName) {
    final controller = TextEditingController(text: currentName);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: const Color.fromARGB(255, 255, 255, 255),
          title: const Row(
            children: [
              Icon(Icons.edit,
                  color: Color.fromARGB(255, 0, 122, 156), size: 30),
              SizedBox(width: 12),
              Text(
                "Edit Nama",
                style: TextStyle(
                  color: Color.fromARGB(255, 0, 122, 156),
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
            ],
          ),
          content: TextField(
            controller: controller,
            style: const TextStyle(color: Color.fromARGB(255, 0, 122, 156)),
            decoration: InputDecoration(
              labelText: "Nama Baru",
              labelStyle:
                  const TextStyle(color: Color.fromARGB(255, 0, 122, 156)),
              hintText: "Masukkan nama baru",
              hintStyle:
                  const TextStyle(color: Color.fromARGB(255, 0, 122, 156)),
              filled: true,
              fillColor: const Color.fromARGB(109, 255, 237, 145),
              enabledBorder: OutlineInputBorder(
                borderSide:
                    const BorderSide(color: Color.fromARGB(255, 0, 122, 156)),
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                    color: Color.fromARGB(255, 0, 122, 156), width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          actionsAlignment: MainAxisAlignment.end,
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 250, 112, 112),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.cancel, size: 18, color: Colors.white),
                      SizedBox(width: 5),
                      Text(
                        "Batal",
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () async {
                    final newName = controller.text.trim();
                    if (newName.isNotEmpty) {
                      await _updateUserProfile(
                          userId: userId, newName: newName);
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text("Nama berhasil diperbarui!")),
                      );
                      setState(() {});
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 92, 194, 83),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.save, size: 18, color: Colors.white),
                      SizedBox(width: 5),
                      Text(
                        "Simpan",
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Future<void> _signOut(BuildContext context) async {
    try {
      await _auth.signOut();
      Navigator.of(context).pushReplacementNamed('/login');
    } catch (e) {
      print("Error signing out: $e");
    }
  }

  void _showSignOutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 15,
          title: Row(
            children: [
              Icon(Icons.exit_to_app,
                  color: Color.fromARGB(255, 250, 112, 112), size: 30),
              SizedBox(width: 12),
              Text(
                "Konfirmasi Keluar",
                style: TextStyle(
                  color: Color.fromARGB(255, 250, 112, 112),
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
            ],
          ),
          content: Text(
            "Yakin ingin keluar?",
            style: TextStyle(
              color: Color.fromARGB(255, 0, 122, 156),
              fontSize: 16,
            ),
          ),
          actionsAlignment: MainAxisAlignment.end,
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // "Tidak" button (Red)
                SizedBox(
                  width: 120,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 250, 112, 112),
                      padding: EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.cancel, size: 18, color: Colors.white),
                        SizedBox(width: 5),
                        Text(
                          "Tidak",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 8),

                SizedBox(
                  width: 120,
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(context, true);
                      await _signOut(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 92, 194, 83),
                      padding: EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check, size: 18, color: Colors.white),
                        SizedBox(width: 5),
                        Text(
                          "Ya",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void _showAppInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 15,
          title: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blueAccent, size: 30),
              SizedBox(width: 12),
              Text(
                "Informasi Aplikasi",
                style: TextStyle(
                  color: Colors.blueAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 8),
              Text(
                "Arta Plan adalah aplikasi praktis yang dirancang untuk mencatat pendapatan dan pengeluaran Anda, membantu Anda mengelola keuangan dengan lebih mudah, terorganisir, dan efisien. Tetap terkendali atas keuangan Anda dengan Arta Plan!",
                style: TextStyle(
                  fontSize: 15,
                  height: 1.6,
                  color: Color.fromARGB(255, 0, 122, 156),
                ),
                textAlign: TextAlign.justify,
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.end,
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // "Tutup" button
                SizedBox(
                  width: 120,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      padding: EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.close, size: 18, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          "Tutup",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildInfoTile(
    IconData icon,
    String title,
    String content, {
    required Color boxColor,
    required Color iconColor,
    required TextStyle titleStyle,
    required TextStyle contentStyle,
    void Function()? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8.0),
        decoration: BoxDecoration(
          color: boxColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color.fromARGB(255, 255, 255, 255),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: ListTile(
          contentPadding:
              EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
          leading: CircleAvatar(
            backgroundColor: iconColor,
            child: Icon(icon, color: Colors.white),
          ),
          title: Text(title, style: titleStyle),
          subtitle: Text(content, style: contentStyle),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(
            left: 16.0,
            right: 2.0,
            top: 12.0,
            bottom: 12.0,
          ),
          child: Image.asset('images/logo1.png'),
        ),
        title: const Text(
          "Profil Pengguna",
          style: TextStyle(color: Color.fromARGB(255, 0, 122, 156)),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline, color: Colors.blue),
            onPressed: () {
              _showAppInfoDialog(context);
            },
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _loadUserProfile(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: Text("Gagal memuat profil pengguna."));
          }

          final userData = snapshot.data!;
          final user = _auth.currentUser;
          final userId = user?.uid ?? "";

          return Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('images/BGbaru1.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.vertical(bottom: Radius.circular(30)),
                    border: Border.all(
                      color: const Color.fromARGB(255, 255, 255, 255),
                      width: 2,
                    ),
                    image: DecorationImage(
                      image: AssetImage('images/login1.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: Container(
                          padding: EdgeInsets.all(5),
                          child: CircleAvatar(
                            radius: 45,
                            backgroundImage: userData['foto_profil'] != null
                                ? NetworkImage(userData['foto_profil'])
                                : null,
                            child: userData['foto_profil'] == null
                                ? Icon(Icons.person,
                                    size: 50,
                                    color:
                                        const Color.fromARGB(255, 0, 122, 156))
                                : null,
                          ),
                        ),
                      ),
                      SizedBox(width: 20),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Halo!!!',
                            style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                          GestureDetector(
                            onTap: () => _editName(
                                context, userId, userData['nama'] ?? ''),
                            child: Row(
                              children: [
                                Text(
                                  userData['nama'] ?? 'Tidak tersedia',
                                  style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                                SizedBox(width: 8),
                                Icon(Icons.edit, color: Colors.white, size: 20),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.all(16.0),
                    children: [
                      _buildInfoTile(
                        Icons.email,
                        "Email",
                        user?.email ?? "Tidak tersedia",
                        boxColor: const Color.fromARGB(150, 139, 203, 243),
                        iconColor: const Color.fromARGB(255, 4, 142, 255),
                        titleStyle: TextStyle(
                            color: const Color.fromARGB(255, 4, 142, 255),
                            fontWeight: FontWeight.bold),
                        contentStyle: TextStyle(color: Colors.white),
                      ),
                      _buildInfoTile(
                        Icons.monetization_on,
                        "Pendapatan",
                        "Rp ${userData['pendapatan']?.toStringAsFixed(2) ?? '0.00'}",
                        boxColor: const Color.fromARGB(150, 139, 203, 243),
                        iconColor: const Color.fromARGB(255, 18, 213, 0),
                        titleStyle: TextStyle(
                            color: const Color.fromARGB(255, 18, 213, 0),
                            fontWeight: FontWeight.bold),
                        contentStyle: TextStyle(color: Colors.white),
                      ),
                      _buildInfoTile(
                        Icons.logout,
                        "Keluar",
                        "Klik untuk keluar",
                        boxColor: const Color.fromARGB(150, 139, 203, 243),
                        iconColor: const Color.fromARGB(255, 250, 112, 112),
                        titleStyle: TextStyle(
                            color: const Color.fromARGB(255, 250, 112, 112),
                            fontWeight: FontWeight.bold),
                        contentStyle: TextStyle(color: Colors.white),
                        onTap: () => _showSignOutConfirmation(context),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: Container(
        height: 60,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30.0),
            topRight: Radius.circular(30.0),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10.0,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              onPressed: () {
                setState(() {
                  _activePage = 'home';
                });
                Navigator.pushNamed(context, '/homescreen');
              },
              icon: Icon(
                Icons.home,
                color: _activePage == 'home'
                    ? const Color.fromARGB(255, 139, 203, 243)
                    : Colors.grey,
                size: 30,
              ),
            ),
            const SizedBox(width: 56),
            IconButton(
              onPressed: () {
                setState(() {
                  _activePage = 'profile';
                });
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfileScreen()),
                );
              },
              icon: Icon(
                Icons.person,
                color: _activePage == 'profile'
                    ? const Color.fromARGB(255, 139, 203, 243)
                    : Colors.grey,
                size: 30,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Transform.translate(
        offset: const Offset(0, 15),
        child: SizedBox(
          width: 70,
          height: 70,
          child: FloatingActionButton(
            heroTag: "btnAdd",
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TransactionScreen()),
              );
            },
            backgroundColor: const Color.fromARGB(255, 250, 226, 110),
            foregroundColor: Colors.white,
            shape: CircleBorder(
              side: BorderSide(
                color: const Color.fromARGB(255, 255, 255, 255),
                width: 8.0,
              ),
            ),
            elevation: 0,
            highlightElevation: 0,
            child: const Icon(Icons.add, size: 30),
          ),
        ),
      ),
    );
  }
}
