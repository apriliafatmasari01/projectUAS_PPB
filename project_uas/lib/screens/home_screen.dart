import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:project_uas/screens/input_pendapatan_screen.dart';
import 'package:project_uas/screens/profile_screen.dart';
import 'package:project_uas/screens/transaksi_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  double _pendapatan = 0.0;
  double _pengeluaran = 0.0;
  double _sisaPendapatan = 0.0;
  String _activePage = 'home';

  @override
  void initState() {
    super.initState();
    _loadPendapatan();
    _calculatePengeluaran();
  }

  Future<void> _loadPendapatan() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final pendapatan = userDoc.data()?['pendapatan'] ?? 0.0;

      if (pendapatan is num) {
        setState(() {
          _pendapatan = pendapatan.toDouble();
          _sisaPendapatan = _pendapatan - _pengeluaran;
        });
      } else {
        setState(() {
          _pendapatan = 0.0;
          _sisaPendapatan = _pendapatan - _pengeluaran;
        });
      }
    } catch (e) {
      print('Error loading pendapatan: $e');
      setState(() {
        _pendapatan = 0.0;
        _sisaPendapatan = _pendapatan - _pengeluaran;
      });
    }
  }

  Future<void> _calculatePengeluaran() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final transactionsSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('transactions')
        .get();

    double totalPengeluaran = 0.0;

    for (var doc in transactionsSnapshot.docs) {
      final data = doc.data();
      final jumlah = (data['jumlah'] as num?)?.toDouble() ?? 0.0;
      totalPengeluaran += jumlah;
    }

    setState(() {
      _pengeluaran = totalPengeluaran;
      _sisaPendapatan = _pendapatan - _pengeluaran;
    });
  }

  String formatDate(Timestamp timestamp) {
    final DateFormat formatter = DateFormat('dd MMM yyyy');
    return formatter.format(timestamp.toDate());
  }

  Future<void> _editTransaksi(String transactionId, double updatedAmount,
      String updatedDescription, String updatedCategory) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('transactions')
          .doc(transactionId)
          .update({
        'jumlah': updatedAmount,
        'deskripsi': updatedDescription,
        'kategori': updatedCategory,
      });

      _calculatePengeluaran();
    } catch (e) {
      print('Error editing transaksi: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
          "Beranda",
          style: TextStyle(color: const Color.fromARGB(255, 0, 122, 156)),
        ),
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("images/BGbaru1.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color.fromARGB(150, 139, 203, 243),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color.fromARGB(255, 255, 255, 255),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 6,
                    offset: Offset(2, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Text(
                    "Ringkasan Keuangan",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: const Color.fromARGB(255, 255, 255, 255),
                    ),
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Pendapatan:",
                          style: TextStyle(
                              color: const Color.fromARGB(255, 0, 122, 156),
                              fontSize: 16)),
                      Text("Rp ${_pendapatan.toStringAsFixed(2)}",
                          style: const TextStyle(
                              color: const Color.fromARGB(255, 0, 122, 156),
                              fontSize: 16)),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Pengeluaran:",
                          style: TextStyle(
                              color: const Color.fromARGB(255, 255, 93, 93),
                              fontSize: 16)),
                      Text("Rp ${_pengeluaran.toStringAsFixed(2)}",
                          style: const TextStyle(
                              color: const Color.fromARGB(255, 255, 93, 93),
                              fontSize: 16)),
                    ],
                  ),
                  Divider(color: Colors.white),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Sisa Pendapatan: ",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: const Color.fromARGB(255, 255, 255, 255),
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        "Rp ${_sisaPendapatan.toStringAsFixed(2)}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: const Color.fromARGB(255, 255, 255, 255),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 139, 203, 243),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => InputPendapatanScreen(
                          onUpdatePendapatan: _loadPendapatan,
                        ),
                      ),
                    );
                    _loadPendapatan();
                  },
                  child: const Text(
                    "Input Pendapatan",
                    style: TextStyle(
                        color: Color.fromARGB(255, 255, 255, 255),
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(_auth.currentUser?.uid)
                    .collection('transactions')
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text("Belum ada riwayat transaksi."));
                  }

                  final transactions = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: transactions.length,
                    itemBuilder: (ctx, index) {
                      final transactionData =
                          transactions[index].data() as Map<String, dynamic>;

                      final transactionId = transactions[index].id;
                      final jumlah =
                          transactionData['jumlah']?.toDouble() ?? 0.0;
                      final deskripsi =
                          transactionData['deskripsi'] ?? 'Tidak ada deskripsi';
                      final kategori =
                          transactionData['kategori'] ?? 'Tidak ada kategori';
                      final timestamp =
                          transactionData['timestamp'] as Timestamp?;

                      return Container(
                        margin: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 16),
                        decoration: BoxDecoration(
                          color: Color.fromARGB(150, 139, 203, 243),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color.fromARGB(255, 255, 255, 255),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              spreadRadius: 2,
                              blurRadius: 6,
                              offset: const Offset(2, 4),
                            ),
                          ],
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.all(16),
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                kategori,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Color.fromARGB(255, 0, 122, 156),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Rp ${jumlah.toStringAsFixed(2)}",
                                style: const TextStyle(
                                    fontSize: 15,
                                    color:
                                        const Color.fromARGB(255, 255, 93, 93),
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "$deskripsi",
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold),
                              ),
                              if (timestamp != null)
                                Text("${formatDate(timestamp)}",
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 13)),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Container(
                                  decoration: const BoxDecoration(
                                    color: Color.fromARGB(255, 92, 194, 83),
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
                                  final amountController =
                                      TextEditingController(
                                          text: jumlah.toString());
                                  final descriptionController =
                                      TextEditingController(text: deskripsi);
                                  final categoryController =
                                      TextEditingController(text: kategori);

                                  showDialog(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      backgroundColor: const Color.fromARGB(
                                          255, 255, 255, 255),
                                      title: const Row(
                                        children: [
                                          Icon(Icons.edit_note,
                                              color: Color.fromARGB(
                                                  255, 0, 122, 156),
                                              size: 30),
                                          SizedBox(width: 12),
                                          Text(
                                            "Edit Transaksi",
                                            style: TextStyle(
                                              color: Color.fromARGB(
                                                  255, 0, 122, 156),
                                              fontWeight: FontWeight.bold,
                                              fontSize: 22,
                                            ),
                                          ),
                                        ],
                                      ),
                                      content: SingleChildScrollView(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            TextField(
                                              controller: amountController,
                                              style: const TextStyle(
                                                  color: Color.fromARGB(
                                                      255, 0, 122, 156)),
                                              decoration: InputDecoration(
                                                labelText: "Jumlah",
                                                labelStyle: const TextStyle(
                                                    color: Color.fromARGB(
                                                        255, 0, 122, 156)),
                                                hintText: "Masukkan jumlah",
                                                hintStyle: const TextStyle(
                                                    color: Color.fromARGB(
                                                        255, 0, 122, 156)),
                                                filled: true,
                                                fillColor: const Color.fromARGB(
                                                    109, 255, 237, 145),
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                  borderSide: const BorderSide(
                                                      color: Color.fromARGB(
                                                          255, 0, 122, 156)),
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderSide: const BorderSide(
                                                      color: Color.fromARGB(
                                                          255, 0, 122, 156),
                                                      width: 2),
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                              ),
                                              keyboardType:
                                                  TextInputType.number,
                                            ),
                                            const SizedBox(height: 20),
                                            TextField(
                                              controller: descriptionController,
                                              style: const TextStyle(
                                                  color: Color.fromARGB(
                                                      255, 0, 122, 156)),
                                              decoration: InputDecoration(
                                                labelText: "Deskripsi",
                                                labelStyle: const TextStyle(
                                                    color: Color.fromARGB(
                                                        255, 0, 122, 156)),
                                                hintText: "Masukkan deskripsi",
                                                hintStyle: const TextStyle(
                                                    color: Color.fromARGB(
                                                        255, 0, 122, 156)),
                                                filled: true,
                                                fillColor: const Color.fromARGB(
                                                    109, 255, 237, 145),
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                  borderSide: const BorderSide(
                                                      color: Color.fromARGB(
                                                          255, 0, 122, 156)),
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderSide: const BorderSide(
                                                      color: Color.fromARGB(
                                                          255, 0, 122, 156),
                                                      width: 2),
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 20),
                                            TextField(
                                              controller: categoryController,
                                              style: const TextStyle(
                                                  color: Color.fromARGB(
                                                      255, 0, 122, 156)),
                                              decoration: InputDecoration(
                                                labelText: "Kategori",
                                                labelStyle: const TextStyle(
                                                    color: Color.fromARGB(
                                                        255, 0, 122, 156)),
                                                hintText: "Masukkan kategori",
                                                hintStyle: const TextStyle(
                                                    color: Color.fromARGB(
                                                        255, 0, 122, 156)),
                                                filled: true,
                                                fillColor: const Color.fromARGB(
                                                    109, 255, 237, 145),
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                  borderSide: const BorderSide(
                                                      color: Color.fromARGB(
                                                          255, 0, 122, 156)),
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderSide: const BorderSide(
                                                      color: Color.fromARGB(
                                                          255, 0, 122, 156),
                                                      width: 2),
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      actionsAlignment: MainAxisAlignment.end,
                                      actions: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            ElevatedButton(
                                              onPressed: () {
                                                Navigator.pop(ctx);
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    const Color.fromARGB(
                                                        255, 250, 112, 112),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 20,
                                                        vertical: 10),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                ),
                                              ),
                                              child: const Row(
                                                children: [
                                                  Icon(Icons.cancel,
                                                      size: 18,
                                                      color: Colors.white),
                                                  SizedBox(width: 5),
                                                  Text(
                                                    "Batal",
                                                    style: TextStyle(
                                                        fontSize: 16,
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            ElevatedButton(
                                              onPressed: () {
                                                final updatedAmount =
                                                    double.tryParse(
                                                            amountController
                                                                .text) ??
                                                        0.0;
                                                final updatedDescription =
                                                    descriptionController.text;
                                                final updatedCategory =
                                                    categoryController.text;

                                                _editTransaksi(
                                                    transactionId,
                                                    updatedAmount,
                                                    updatedDescription,
                                                    updatedCategory);
                                                Navigator.pop(ctx);
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    const Color.fromARGB(
                                                        255, 92, 194, 83),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 20,
                                                        vertical: 10),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                ),
                                              ),
                                              child: const Row(
                                                children: [
                                                  Icon(
                                                    Icons.save,
                                                    size: 18,
                                                    color: Colors.white,
                                                  ),
                                                  SizedBox(width: 5),
                                                  Text(
                                                    "Simpan",
                                                    style: TextStyle(
                                                        fontSize: 16,
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
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
                                  onPressed: () async {
                                    final shouldDelete = await showDialog<bool>(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        backgroundColor: const Color.fromARGB(
                                            255, 255, 255, 255),
                                        title: const Row(
                                          children: [
                                            Icon(Icons.delete_forever,
                                                color: Color.fromARGB(
                                                    255, 250, 112, 112),
                                                size: 30),
                                            SizedBox(width: 12),
                                            Text(
                                              "Hapus Transaksi?",
                                              style: TextStyle(
                                                color: Color.fromARGB(
                                                    255, 250, 112, 112),
                                                fontWeight: FontWeight.bold,
                                                fontSize: 22,
                                              ),
                                            ),
                                          ],
                                        ),
                                        content: const Text(
                                          "Apakah Anda yakin ingin menghapus transaksi ini?",
                                          style: TextStyle(
                                              color: Color.fromARGB(
                                                  255, 0, 122, 156),
                                              fontSize: 16),
                                        ),
                                        actionsAlignment: MainAxisAlignment.end,
                                        actions: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              SizedBox(
                                                width: 120,
                                                child: ElevatedButton(
                                                  onPressed: () =>
                                                      Navigator.pop(ctx, false),
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        const Color.fromARGB(
                                                            255, 250, 112, 112),
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        vertical: 10),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20),
                                                    ),
                                                  ),
                                                  child: const Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Icon(
                                                        Icons.cancel,
                                                        size: 18,
                                                        color: Colors.white,
                                                      ),
                                                      SizedBox(width: 5),
                                                      Text(
                                                        "Tidak",
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
                                              ),
                                              const SizedBox(width: 8),
                                              SizedBox(
                                                width: 120,
                                                child: ElevatedButton(
                                                  onPressed: () =>
                                                      Navigator.pop(ctx, true),
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        const Color.fromARGB(
                                                            255, 92, 194, 83),
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        vertical: 10),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20),
                                                    ),
                                                  ),
                                                  child: const Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Icon(Icons.check,
                                                          size: 18,
                                                          color: Colors.white),
                                                      SizedBox(width: 5),
                                                      Text(
                                                        "Ya",
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
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    );

                                    if (shouldDelete == true) {
                                      try {
                                        await FirebaseFirestore.instance
                                            .collection('users')
                                            .doc(_auth.currentUser?.uid)
                                            .collection('transactions')
                                            .doc(transactionId)
                                            .delete();
                                        _calculatePengeluaran();
                                      } catch (e) {
                                        print('Error deleting transaksi: $e');
                                      }
                                    }
                                  }),
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
              _calculatePengeluaran();
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
