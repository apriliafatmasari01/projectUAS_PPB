import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();

  final GoogleSignIn _googleSignIn = GoogleSignIn();

  void loginUser() async {
    try {
      // Login menggunakan email dan password
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // Mendapatkan UID dari user yang berhasil login
      String uid = userCredential.user!.uid;

      // Mengecek apakah user terdaftar di database Firestore
      final userDoc = await _firestore.collection('users').doc(uid).get();

      if (!userDoc.exists || (userDoc.data()?['nama'] ?? '').isEmpty) {
        // Jika user tidak ditemukan di database Firestore
        showErrorDialog(
            "Akun Anda belum terdaftar. Silakan registrasi terlebih dahulu.");
        return;
      }

      // Jika user ditemukan, navigasi ke halaman utama
      Navigator.pushReplacementNamed(context, '/homescreen');
    } on FirebaseAuthException catch (e) {
      // Penanganan error untuk Firebase Auth
      if (e.code == 'user-not-found') {
        showErrorDialog(
            "Akun tidak ditemukan. Silakan registrasi terlebih dahulu.");
      } else if (e.code == 'wrong-password') {
        showErrorDialog("Password yang Anda masukkan salah.");
      } else if (e.code == 'invalid-email') {
        showErrorDialog("Format email tidak valid.");
      } else {
        // Pesan kesalahan umum
        showErrorDialog(e.message ?? "Terjadi kesalahan. Silakan coba lagi.");
      }
    } catch (e) {
      // Penanganan error umum lainnya
      showErrorDialog("Terjadi kesalahan tak terduga. Silakan coba lagi.");
    }
  }

  void loginWithGoogle() async {
    try {
      // ignore: body_might_complete_normally_catch_error
      await _googleSignIn.disconnect().catchError((e) {});

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        final UserCredential userCredential =
            await _auth.signInWithCredential(credential);

        final email = googleUser.email;

        final isRegistered = await isEmailRegistered(email);

        if (!isRegistered) {
          showErrorDialog(
              "Akun Google ini belum terdaftar. Silakan daftar terlebih dahulu.");
          return;
        }

        final userDoc = await _firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .get();

        if (!userDoc.exists || (userDoc.data()?['nama'] ?? '').isEmpty) {
          final name = nameController.text.trim();

          if (name.isNotEmpty) {
            await _firestore
                .collection('users')
                .doc(userCredential.user!.uid)
                .set(
              {'nama': name},
              SetOptions(merge: true),
            );
          } else {
            showErrorDialog("Nama tidak boleh kosong.");
            return;
          }
        }

        Navigator.pushReplacementNamed(context, '/homescreen');
      }
    } catch (e) {
      showErrorDialog("Gagal login menggunakan Google: $e");
    }
  }

  Future<bool> isEmailRegistered(String email) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  void showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 15,
          title: const Row(
            children: [
              Icon(Icons.warning,
                  color: Color.fromARGB(255, 250, 112, 112), size: 30),
              SizedBox(width: 12),
              Text(
                "Belum Daftar",
                style: TextStyle(
                  color: Color.fromARGB(255, 250, 112, 112),
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
            ],
          ),
          content: Text(
            message,
            style: const TextStyle(
              color: Color.fromARGB(255, 0, 122, 156),
              fontSize: 16,
            ),
          ),
          actionsAlignment: MainAxisAlignment.end,
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                  width: 120,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 250, 112, 112),
                      padding: EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.cancel, size: 18, color: Colors.white),
                        SizedBox(width: 5),
                        Text(
                          "Batal",
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
                if (message.contains("belum terdaftar")) ...[
                  SizedBox(width: 8),
                  SizedBox(
                    width: 120,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/register');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 92, 194, 83),
                        padding: EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.app_registration,
                              size: 18, color: Colors.white),
                          SizedBox(width: 5),
                          Text(
                            "Daftar",
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
                ]
              ],
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Image.asset(
            'images/BGbaru1.png',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          Center(
            child: SingleChildScrollView(
              child: Container(
                width: 320,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        height: 170,
                        child: Stack(
                          children: [
                            Positioned(
                              top: 0,
                              left: 0,
                              right: 0,
                              child: Image.asset(
                                'images/login.png',
                                height: 170,
                                fit: BoxFit.contain,
                              ),
                            ),
                            const Positioned(
                              bottom: 10,
                              left: 0,
                              right: 0,
                              child: Column(),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      TextField(
                        controller: emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(
                            Icons.email,
                            color: Colors.grey,
                          ),
                          filled: true,
                          fillColor: const Color.fromARGB(109, 255, 237, 145),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      TextField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: Icon(
                            Icons.lock,
                            color: Colors.grey,
                          ),
                          filled: true,
                          fillColor: const Color.fromARGB(109, 255, 237, 145),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: loginUser,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 139, 203, 243),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        child: const Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 80,
                            vertical: 12,
                          ),
                          child: Text(
                            'Login',
                            style: TextStyle(
                                fontSize: 16,
                                color: Color.fromARGB(255, 0, 0, 0),
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: loginWithGoogle,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 255, 255, 255),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                            side: BorderSide(
                                color: const Color.fromARGB(255, 139, 203, 243),
                                width: 2.0),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 22,
                            vertical: 12,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset(
                                'images/logoG.png',
                                height: 17.0,
                                width: 17.0,
                              ),
                              const SizedBox(width: 12.0),
                              const Text(
                                'Login with Google',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Color.fromARGB(255, 139, 203, 243),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 30),
                      Column(
                        children: [
                          Text(
                            'BELUM MEMPUNYAI AKUN?',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[700],
                            ),
                          ),
                          SizedBox(height: 2),
                          ElevatedButton(
                            onPressed: () =>
                                Navigator.pushNamed(context, '/register'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Color.fromARGB(255, 250, 226, 110),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: const Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 10,
                              ),
                              child: Text(
                                'Create Account',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Color.fromARGB(255, 0, 0, 0),
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
