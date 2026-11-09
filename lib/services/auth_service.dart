// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class AuthService {
//   final FirebaseAuth _auth = FirebaseAuth.instance;

//   // Inscription avec infos supplémentaires + déconnexion après création
//   Future<void> register({
//     required String email,
//     required String password,
//     required String nom,
//     required String prenom,
//     String? genre,
//     String? telephone,   
//     String? adresse,     
//   }) async {
//     // Création utilisateur
//     UserCredential result = await _auth.createUserWithEmailAndPassword(
//       email: email,
//       password: password,
//     );

//     // Récupérer l'UID
//     String uid = result.user!.uid;

//     // Enregistrer infos utilisateur dans Firestore
//     await FirebaseFirestore.instance.collection('users').doc(uid).set({
//       'nom': nom,
//       'prenom': prenom,
//       'email': email,
//       'genre': genre ?? '',
//       'telephone': telephone ?? '',
//       'adresse': adresse ?? '',
//       'createdAt': FieldValue.serverTimestamp(),
//     });

//     // Déconnexion après inscription
//     await _auth.signOut();
//   }

//   // Connexion
//   Future<void> login(String email, String password) async {
//     await _auth.signInWithEmailAndPassword(email: email, password: password);
//   }

//   // Déconnexion
//   Future<void> logout() async {
//     await _auth.signOut();
//   }
// } 


import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Inscription avec infos supplémentaires + envoi mail de vérification + déconnexion après création
  Future<void> register({
    required String email,
    required String password,
    required String nom,
    required String prenom,
    String? genre,
    String? telephone,
    String? adresse,
  }) async {
    // Création utilisateur
    UserCredential result = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    User? user = result.user;

    // Envoi email de vérification si l'utilisateur existe et n'est pas encore vérifié
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }

    // Récupérer l'UID
    String uid = user!.uid;

    // Enregistrer infos utilisateur dans Firestore
    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'nom': nom,
      'prenom': prenom,
      'email': email,
      'genre': genre ?? '',
      'telephone': telephone ?? '',
      'adresse': adresse ?? '',
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Déconnexion après inscription
    await _auth.signOut();
  }

  // Connexion
  Future<void> login(String email, String password) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  // Déconnexion
  Future<void> logout() async {
    await _auth.signOut();
  }
}
