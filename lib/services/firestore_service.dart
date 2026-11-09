import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/produit.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<Produit>> getProduits() {
    return _db.collection('produits').snapshots().map((snapshot) =>
      snapshot.docs.map((doc) => Produit.fromJson(doc.data(), doc.id)).toList());
  }

  Future<void> addProduit(Produit produit) async {
    await _db.collection('produits').add(produit.toMap());
  }
  
} 