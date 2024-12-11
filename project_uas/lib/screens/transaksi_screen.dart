import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:project_uas/screens/add_transaksi_screen.dart';

class TransactionScreen extends StatefulWidget {
  @override
  _TransactionScreenState createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  List<Map<String, dynamic>> categories = [
    {"name": "Makanan", "icon": Icons.fastfood},
    {"name": "Rumah", "icon": Icons.home},
    {"name": "Elektronik", "icon": Icons.devices},
    {"name": "Belanja", "icon": Icons.shopping_cart},
    {"name": "Pendidikan", "icon": Icons.school},
    {"name": "Transportasi", "icon": Icons.directions_car},
    {"name": "Kesehatan", "icon": Icons.health_and_safety},
    {"name": "Pakaian", "icon": Icons.checkroom},
    {"name": "Telepon", "icon": Icons.call},
    {"name": "Penerbangan", "icon": Icons.local_airport},
    {"name": "Travelling", "icon": Icons.travel_explore},
    {"name": "Coffee", "icon": Icons.coffee},
    {"name": "WiFi", "icon": Icons.wifi},
    {"name": "Birthday", "icon": Icons.cake},
    {"name": "Transaksi", "icon": Icons.local_atm},
    {"name": "Games", "icon": Icons.videogame_asset},
    {"name": "Peliharaan", "icon": Icons.pets},
    {"name": "Olahraga", "icon": Icons.sports},
    {"name": "Musik", "icon": Icons.music_note},
    {"name": "Film", "icon": Icons.movie},
    {"name": "Fotografi", "icon": Icons.camera_alt},
    {"name": "Keuangan", "icon": Icons.account_balance_wallet},
    {"name": "Kecantikan", "icon": Icons.brush},
    {"name": "Kerja", "icon": Icons.work},
    {"name": "Teknologi", "icon": Icons.computer},
    {"name": "Kegiatan Sosial", "icon": Icons.groups},
    {"name": "Energi", "icon": Icons.bolt},
    {"name": "Lingkungan", "icon": Icons.eco},
    {"name": "Keamanan", "icon": Icons.security},
    {"name": "Konstruksi", "icon": Icons.construction},
    {"name": "Fasilitas Umum", "icon": Icons.local_hospital},
    {"name": "Cuaca", "icon": Icons.wb_sunny},
    {"name": "Cinta", "icon": Icons.favorite},
    {"name": "Dokumen", "icon": Icons.insert_drive_file},
    {"name": "Chat", "icon": Icons.chat},
    {"name": "Hobi", "icon": Icons.palette},
  ];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  void _loadCategories() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? savedCategories = prefs.getStringList('categories');

    if (savedCategories != null) {
      setState(() {
        categories = savedCategories.map((category) {
          final parts = category.split('|');
          return {
            "name": parts[0],
            "icon": IconData(
              int.parse(parts[1]),
              fontFamily: parts[2],
            ),
          };
        }).toList();
      });
    }
  }

  void _saveCategories() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> savedCategories = categories.map((category) {
      final icon = category["icon"] as IconData;
      return "${category["name"]}|${icon.codePoint}|${icon.fontFamily}";
    }).toList();
    await prefs.setStringList('categories', savedCategories);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/BGbaru.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: const Text(
              "Kategori Transaksi",
              style: TextStyle(color: const Color.fromARGB(255, 0, 122, 156)),
            ),
            backgroundColor: const Color.fromARGB(255, 255, 255, 255),
            elevation: 0,
            iconTheme:
                IconThemeData(color: const Color.fromARGB(255, 0, 122, 156)),
          ),
          body: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              final isAddCategory = category["name"] == "Tambah Kategori";

              return GestureDetector(
                onTap: () {
                  if (isAddCategory) {
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            AddTransactionScreen(category: category["name"]),
                      ),
                    );
                  }
                },
                child: Card(
                  color: const Color.fromARGB(150, 139, 203, 243),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(
                      color: Colors.white,
                      width: 2,
                    ),
                  ),
                  elevation: 6,
                  shadowColor: Colors.black.withOpacity(0.8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        category["icon"],
                        size: 40,
                        color: const Color.fromARGB(255, 255, 255, 255),
                      ),
                      SizedBox(height: 8),
                      Text(
                        category["name"],
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
