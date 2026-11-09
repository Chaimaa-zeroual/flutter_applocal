import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/produit.dart';

class FavoritesProvider with ChangeNotifier {
  final List<Produit> _favorites = [];

  List<Produit> get favorites => List.unmodifiable(_favorites);

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Charger les favoris depuis Firestore à l'initialisation
  Future<void> loadFavorites() async {
    final user = _auth.currentUser;
    if (user == null) {
      _favorites.clear();
      notifyListeners();
      return;
    }

    final favsSnapshot = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .get();

    _favorites.clear();

    for (var doc in favsSnapshot.docs) {
      final data = doc.data();
      _favorites.add(
        Produit.fromJson(data['produit'], data['produit']['id'] ?? doc.id),
      );
    }
    notifyListeners();
  }

  bool isFavorite(Produit produit) {
    return _favorites.any((p) => p.id == produit.id);
  }

  Future<void> addFavorite(Produit produit) async {
    if (isFavorite(produit)) return;

    final user = _auth.currentUser;
    if (user == null) return;

    _favorites.add(produit);
    notifyListeners();

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .doc(produit.id)
        .set({'produit': produit.toMap()});
  }

  Future<void> removeFavorite(Produit produit) async {
    final user = _auth.currentUser;
    if (user == null) return;

    _favorites.removeWhere((p) => p.id == produit.id);
    notifyListeners();

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .doc(produit.id)
        .delete();
  }

  Future<void> toggleFavorite(Produit produit) async {
    if (isFavorite(produit)) {
      await removeFavorite(produit);
    } else {
      await addFavorite(produit);
    }
  }

  Future<void> removeFromFavorites(Produit produit) async {
    await removeFavorite(produit);
  }
}
