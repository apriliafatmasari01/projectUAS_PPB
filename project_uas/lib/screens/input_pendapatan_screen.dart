import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project_uas/screens/home_screen.dart';

class InputPendapatanScreen extends StatefulWidget {
  final VoidCallback onUpdatePendapatan;

  InputPendapatanScreen({required this.onUpdatePendapatan});

  @override
  _InputPendapatanScreenState createState() => _InputPendapatanScreenState();
}

class _InputPendapatanScreenState extends State<InputPendapatanScreen> {
  final TextEditingController _controller = TextEditingController();
  String _selectedCategory = 'Gaji';
  final List<Map<String, dynamic>> _categories = [
    {'name': 'Gaji', 'icon': Icons.attach_money},
    {'name': 'Investasi', 'icon': Icons.trending_up},
    {'name': 'Part-time', 'icon': Icons.work},
    {'name': 'Lainnya', 'icon': Icons.category},
  ];

  Future<void> _updatePendapatan(double newPendapatan, String category) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('pendapatan_categories')
        .add({
      'pendapatan': newPendapatan,
      'category': category,
      'timestamp': FieldValue.serverTimestamp(),
    });

    final userDoc =
        FirebaseFirestore.instance.collection('users').doc(user.uid);
    final userSnapshot = await userDoc.get();
    final currentPendapatan = userSnapshot.data()?['pendapatan'] ?? 0.0;

    await userDoc.update({
      'pendapatan': currentPendapatan + newPendapatan,
    });

    widget.onUpdatePendapatan();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomeScreen()),
    );
  }

  Future<void> _confirmDeletePendapatan(String pendapatanId) async {
    final bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: const Color.fromARGB(255, 255, 255, 255),
          title: const Row(
            children: [
              Icon(Icons.delete_forever,
                  color: const Color.fromARGB(255, 250, 112, 112), size: 30),
              const SizedBox(width: 12),
              Text(
                "Hapus Pendapatan?",
                style: TextStyle(
                  color: const Color.fromARGB(255, 250, 112, 112),
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
            ],
          ),
          content: const Text(
            "Apakah yakin ingin menghapus data ini?",
            style: TextStyle(
                color: const Color.fromARGB(255, 0, 122, 156), fontSize: 16),
          ),
          actionsAlignment: MainAxisAlignment.end,
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                  width: 120,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 250, 112, 112),
                      padding: EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.cancel,
                          size: 18,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          "Tidak",
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 120,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 92, 194, 83),
                      padding: EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check, size: 18, color: Colors.white),
                        const SizedBox(width: 5),
                        Text(
                          "Ya",
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
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

    if (shouldDelete == true) {
      await _deletePendapatan(pendapatanId);
    }
  }

  Future<void> _deletePendapatan(String pendapatanId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final pendapatanDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('pendapatan_categories')
        .doc(pendapatanId)
        .get();

    final pendapatan = pendapatanDoc.data()?['pendapatan'] ?? 0.0;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('pendapatan_categories')
        .doc(pendapatanId)
        .delete();

    final userDoc =
        FirebaseFirestore.instance.collection('users').doc(user.uid);
    final userSnapshot = await userDoc.get();
    final currentPendapatan = userSnapshot.data()?['pendapatan'] ?? 0.0;

    await userDoc.update({
      'pendapatan': currentPendapatan - pendapatan,
    });

    widget.onUpdatePendapatan();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomeScreen()),
    );
  }

  Future<void> _editPendapatan(
      String pendapatanId, double newPendapatan) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final pendapatanDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('pendapatan_categories')
        .doc(pendapatanId)
        .get();

    final oldPendapatan = pendapatanDoc.data()?['pendapatan'] ?? 0.0;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('pendapatan_categories')
        .doc(pendapatanId)
        .update({'pendapatan': newPendapatan});

    final userDoc =
        FirebaseFirestore.instance.collection('users').doc(user.uid);
    final userSnapshot = await userDoc.get();
    final currentPendapatan = userSnapshot.data()?['pendapatan'] ?? 0.0;

    await userDoc.update({
      'pendapatan': currentPendapatan - oldPendapatan + newPendapatan,
    });

    widget.onUpdatePendapatan();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomeScreen()),
    );
  }

  Stream<QuerySnapshot> _fetchPendapatanHistory() {
    final user = FirebaseAuth.instance.currentUser;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .collection('pendapatan_categories')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Input Pendapatan",
            style: TextStyle(color: const Color.fromARGB(255, 0, 122, 156))),
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        elevation: 0,
        iconTheme: IconThemeData(color: const Color.fromARGB(255, 0, 122, 156)),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("images/BGbaru1.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _controller,
                keyboardType: TextInputType.number,
                style: const TextStyle(
                  color: Color.fromARGB(255, 0, 122, 156),
                  fontWeight: FontWeight.bold,
                ),
                decoration: InputDecoration(
                  labelText: "Jumlah pendapatan",
                  labelStyle: const TextStyle(
                    color: Color.fromARGB(255, 0, 122, 156),
                  ),
                  filled: true,
                  fillColor: const Color.fromARGB(108, 255, 255, 255),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                        color: Color.fromARGB(255, 0, 122, 156)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                        color: Color.fromARGB(255, 0, 122, 156)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Icon(Icons.category,
                      color: const Color.fromARGB(255, 0, 122, 156)),
                  SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color.fromARGB(255, 0, 122, 156),
                        ),
                        color: const Color.fromARGB(108, 255, 255, 255),
                      ),
                      child: DropdownButton<String>(
                        value: _selectedCategory,
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedCategory = newValue!;
                          });
                        },
                        isExpanded: true,
                        underline: SizedBox(), 
                        borderRadius: BorderRadius.circular(20),
                        dropdownColor:
                            Colors.white,
                        icon: Icon(
                          Icons.arrow_drop_down,
                          color: const Color.fromARGB(255, 0, 122, 156),
                        ),
                        style: const TextStyle(
                          color: Color.fromARGB(255, 0, 122, 156),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        selectedItemBuilder: (BuildContext context) {
                          return _categories.map<Widget>((category) {
                            return Row(
                              children: [
                                Icon(category['icon'],
                                    color:
                                        const Color.fromARGB(255, 0, 122, 156)),
                                SizedBox(width: 10),
                                Text(
                                  category['name'],
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18),
                                ),
                              ],
                            );
                          }).toList();
                        },
                        items: _categories
                            .map<DropdownMenuItem<String>>((category) {
                          return DropdownMenuItem<String>(
                            value: category['name'],
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 15),
                              decoration: BoxDecoration(
                                color: Colors
                                    .white,
                                border: Border.all(
                                  color: const Color.fromARGB(
                                      255, 0, 122, 156), 
                                  width: 1, 
                                ),
                                borderRadius: BorderRadius.circular(
                                    10), 
                              ),
                              child: Row(
                                children: [
                                  Icon(category['icon'],
                                      color: const Color.fromARGB(
                                          255, 0, 122, 156)),
                                  SizedBox(width: 10),
                                  Text(
                                    category['name'],
                                    style: TextStyle(
                                      color: const Color.fromARGB(
                                          255, 0, 122, 156),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color.fromARGB(255, 139, 203, 243), 
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20), 
                  ),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical:
                          10),
                ),
                onPressed: () {
                  final input = double.tryParse(_controller.text);
                  if (input != null) {
                    _updatePendapatan(input, _selectedCategory);
                  }
                },
                child: const Text(
                  "Simpan Pendapatan",
                  style: TextStyle(
                    color: Color.fromARGB(255, 255, 255, 255), 
                    fontWeight: FontWeight.bold, 
                  ),
                ),
              ),
              SizedBox(height: 20),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _fetchPendapatanHistory(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Center(
                          child: Text("Belum ada riwayat pendapatan"));
                    }

                    final pendapatanDocs = snapshot.data!.docs;

                    return ListView.builder(
                      itemCount: pendapatanDocs.length,
                      itemBuilder: (context, index) {
                        final doc = pendapatanDocs[index];
                        final pendapatan = doc['pendapatan'];
                        final category = doc['category'];
                        final pendapatanId = doc.id;

                        return Card(
                          color: Color.fromARGB(150, 139, 203, 243),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: const BorderSide(
                              color: Colors.white,
                              width: 2,
                            ),
                          ),
                          child: ListTile(
                            title: Text("Rp ${pendapatan.toStringAsFixed(2)}",
                                style: const TextStyle(
                                    color:
                                        const Color.fromARGB(255, 0, 122, 156),
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold)),
                            subtitle: Text(
                              category,
                              style: TextStyle(color: Colors.white),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Container(
                                    decoration: const BoxDecoration(
                                      color: const Color.fromARGB(
                                          255, 92, 194, 83),
                                      shape: BoxShape.circle,
                                    ),
                                    padding: const EdgeInsets.all(8),
                                    child: const Icon(
                                      Icons.edit,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                  onPressed: () {
                                    final editController =
                                        TextEditingController(
                                            text: pendapatan.toString());
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          backgroundColor: const Color.fromARGB(
                                              255, 255, 255, 255),
                                          title: const Row(
                                            children: [
                                              Icon(Icons.edit_note,
                                                  color: const Color.fromARGB(
                                                      255, 0, 122, 156),
                                                  size: 30),
                                              const SizedBox(width: 12),
                                              Text(
                                                'Edit Pendapatan',
                                                style: TextStyle(
                                                  color: const Color.fromARGB(
                                                      255, 0, 122, 156),
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 22,
                                                ),
                                              ),
                                            ],
                                          ),
                                          content: TextField(
                                            controller: editController,
                                            keyboardType: TextInputType.number,
                                            style: const TextStyle(
                                                color: Color.fromARGB(
                                                    255, 0, 122, 156)),
                                            decoration: InputDecoration(
                                              hintText:
                                                  'Masukkan jumlah pendapatan',
                                              hintStyle: const TextStyle(
                                                  color: Color.fromARGB(
                                                      255, 0, 122, 156)),
                                              filled: true,
                                              fillColor: const Color.fromARGB(
                                                  109, 255, 237, 145),
                                              enabledBorder: OutlineInputBorder(
                                                borderSide: const BorderSide(
                                                    color: Color.fromARGB(
                                                        255, 0, 122, 156)),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: const BorderSide(
                                                    color: Color.fromARGB(
                                                        255, 0, 122, 156)),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                            ),
                                          ),
                                          actionsAlignment:
                                              MainAxisAlignment.end,
                                          actions: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                ElevatedButton(
                                                  onPressed: () =>
                                                      Navigator.pop(context),
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        const Color.fromARGB(
                                                            255, 250, 112, 112),
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 20,
                                                        vertical: 10),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20),
                                                    ),
                                                  ),
                                                  child: const Row(
                                                    children: [
                                                      Icon(
                                                        Icons.cancel,
                                                        size: 18,
                                                        color: Colors.white,
                                                      ),
                                                      const SizedBox(width: 5),
                                                      Text(
                                                        "Batal",
                                                        style: TextStyle(
                                                            fontSize: 16,
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                ElevatedButton(
                                                  onPressed: () {
                                                    final updatedPendapatan =
                                                        double.tryParse(
                                                                editController
                                                                    .text) ??
                                                            pendapatan;
                                                    _editPendapatan(
                                                        pendapatanId,
                                                        updatedPendapatan);
                                                  },
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        const Color.fromARGB(
                                                            255, 92, 194, 83),
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 20,
                                                        vertical: 10),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20),
                                                    ),
                                                  ),
                                                  child: const Row(
                                                    children: [
                                                      Icon(
                                                        Icons.save,
                                                        size: 18,
                                                        color: Colors.white,
                                                      ),
                                                      const SizedBox(width: 5),
                                                      Text(
                                                        "Simpan",
                                                        style: TextStyle(
                                                            fontSize: 16,
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
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
                                  },
                                ),
                                IconButton(
                                  icon: Container(
                                    decoration: const BoxDecoration(
                                      color: Color.fromARGB(255, 250, 112, 112),
                                      shape: BoxShape.circle,
                                    ),
                                    padding: const EdgeInsets.all(8),
                                    child: const Icon(
                                      Icons.delete,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                  onPressed: () =>
                                      _confirmDeletePendapatan(pendapatanId),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
