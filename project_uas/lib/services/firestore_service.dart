import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final CollectionReference _expenses =
      FirebaseFirestore.instance.collection('expenses');

  Future<void> addExpense(Map<String, dynamic> expenseData) {
    return _expenses.add(expenseData);
  }

  Stream<QuerySnapshot> getExpenses() {
    return _expenses.snapshots();
  }
}
