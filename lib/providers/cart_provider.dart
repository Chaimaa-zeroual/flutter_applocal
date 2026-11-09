import 'package:flutter/material.dart';
import '../models/produit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CartProvider with ChangeNotifier {
  final List<Produit> _cartItems = [];

  List<Produit> get cartItems => List.unmodifiable(_cartItems);

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> loadCart() async {
    final user = _auth.currentUser;
    if (user == null) {
      _cartItems.clear();
      notifyListeners();
      return;
    }

    final cartSnapshot = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('cart')
        .get();

    _cartItems.clear();
    for (var doc in cartSnapshot.docs) {
      final data = doc.data();
      _cartItems.add(
        Produit.fromJson(data['produit'], data['produit']['id'] ?? doc.id),
      );
    }
    notifyListeners();
  }

  Future<void> addToCart(Produit produit) async {
    if (_cartItems.any((p) => p.id == produit.id)) return; // évite doublons
    _cartItems.add(produit);
    notifyListeners();

    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('cart')
        .doc(produit.id)
        .set({'produit': produit.toMap()});
  }

  Future<void> removeFromCart(Produit produit) async {
    _cartItems.removeWhere((p) => p.id == produit.id);
    notifyListeners();

    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('cart')
        .doc(produit.id)
        .delete();
  }

  Future<void> clearCart() async {
    _cartItems.clear();
    notifyListeners();

    final user = _auth.currentUser;
    if (user == null) return;

    final cartCollection = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('cart');

    final snapshots = await cartCollection.get();
    for (var doc in snapshots.docs) {
      await doc.reference.delete();
    }
  }

  int get itemCount => _cartItems.length;
}
