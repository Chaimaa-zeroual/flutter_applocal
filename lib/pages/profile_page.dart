import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

import 'product_detail_page.dart';
import '../models/produit.dart';
import 'EditArticlePage.dart';

import '../services/auth_service.dart';
import 'auth/login_page.dart';
import '../widgets/bottom_nav_bar.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final user = FirebaseAuth.instance.currentUser;
  final authService = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late TextEditingController emailController;
  late TextEditingController telephoneController;
  late TextEditingController adresseController;
  late TextEditingController nomController;
  late TextEditingController prenomController;
  late TextEditingController genreController;

  File? _imageFile;
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = true;
  List<Produit> _articles = [];

  late String _initialEmail;

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
    telephoneController = TextEditingController();
    adresseController = TextEditingController();
    nomController = TextEditingController();
    prenomController = TextEditingController();
    genreController = TextEditingController();
    _loadUserData();
    _loadUserArticles();
  }

  @override
  void dispose() {
    emailController.dispose();
    telephoneController.dispose();
    adresseController.dispose();
    nomController.dispose();
    prenomController.dispose();
    genreController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    if (user == null) return;

    final doc = await _firestore.collection('users').doc(user!.uid).get();

    if (doc.exists) {
      final data = doc.data()!;
      setState(() {
        nomController.text = data['nom'] ?? "";
        prenomController.text = data['prenom'] ?? "";
        genreController.text = data['genre'] ?? "";

        emailController.text = data['email'] ?? "";
        _initialEmail = data['email'] ?? "";

        telephoneController.text = data['telephone'] ?? "";
        adresseController.text = data['adresse'] ?? "";

        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadUserArticles() async {
    if (user == null) return;

    try {
      final snapshot = await _firestore
          .collection('produits')
          .where('ownerId', isEqualTo: user!.uid)
          .get();

      setState(() {
        _articles = snapshot.docs
            .map((doc) => Produit.fromJson(doc.data(), doc.id))
            .toList();
      });
    } catch (e) {
      setState(() {
        _articles = [];
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur lors du chargement des articles")),
      );
    }
  }

  void logout(BuildContext context) async {
    await authService.logout();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => LoginPage()),
      (route) => false,
    );
  }

  void _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      final uid = user?.uid;
      if (uid == null) return;

      final newEmail = emailController.text.trim();
      final emailChanged = newEmail != _initialEmail;

      try {
        await _firestore.collection('users').doc(uid).update({
          'email': newEmail,
          'telephone': telephoneController.text.trim(),
          'adresse': adresseController.text.trim(),
        });

        _initialEmail = newEmail;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Profil sauvegardé !")),
        );

        if (emailChanged) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text("Attention"),
              content: Text(
                "Votre adresse e-mail a été modifiée uniquement dans votre profil.\n\n"
                "⚠️ Cela ne change PAS votre adresse e-mail de connexion.",
              ),
              actions: [
                TextButton(
                  child: Text("OK", style: TextStyle(color: Color(0xFF855386))),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur lors de la sauvegarde")),
        );
      }
    }
  }

  Future<void> _deleteArticle(Produit article) async {
    try {
      await _firestore.collection('produits').doc(article.id).delete();

      final usersSnapshot = await _firestore.collection('users').get();
      for (var userDoc in usersSnapshot.docs) {
        final favRef = _firestore
            .collection('users')
            .doc(userDoc.id)
            .collection('favorites')
            .doc(article.id);
        final favDoc = await favRef.get();
        if (favDoc.exists) {
          await favRef.delete();
        }

        final cartRef = _firestore
            .collection('users')
            .doc(userDoc.id)
            .collection('cart')
            .doc(article.id);
        final cartDoc = await cartRef.get();
        if (cartDoc.exists) {
          await cartRef.delete();
        }
      }

      setState(() {
        _articles.remove(article);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Article supprimé ainsi que ses favoris et paniers.")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur lors de la suppression")),
      );
    }
  }

  Future<void> _deleteAccount() async {
    try {
      final uid = user?.uid;
      if (uid == null) return;

      final produitsSnapshot = await _firestore
          .collection('produits')
          .where('ownerId', isEqualTo: uid)
          .get();

      for (var doc in produitsSnapshot.docs) {
        await doc.reference.delete();
      }

      await _firestore.collection('users').doc(uid).delete();
      await user!.delete();

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => LoginPage()),
        (route) => false,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Compte supprimé avec succès")),
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  "Veuillez vous reconnecter pour supprimer votre compte.")),
        );
        logout(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur: ${e.message}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur inconnue lors de la suppression.")),
      );
    }
  }

  void _confirmDeleteAccount() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Supprimer le compte"),
        content: Text(
            "Êtes-vous sûr de vouloir supprimer définitivement votre compte ? Cette action est irréversible."),
        actions: [
          TextButton(
            child: Text("Annuler"),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: Text("Supprimer", style: TextStyle(color: Colors.red)),
            onPressed: () {
              Navigator.of(context).pop();
              _deleteAccount();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStyledField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    String? placeholder,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    bool readOnly = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        controller: controller,
        readOnly: readOnly,
        decoration: InputDecoration(
          labelText: label,
          hintText: placeholder,
          labelStyle: TextStyle(color: Color(0xFF855386)),
          hintStyle: TextStyle(color: Colors.grey),
          prefixIcon: Icon(icon, color: Color(0xFF855386)),
          filled: true,
          fillColor: Color(0xFFF8F2F9),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        keyboardType: keyboardType,
        validator: validator,
      ),
    );
  }

  Widget _buildFieldRow({required Widget left, required Widget right}) {
    return Row(
      children: [
        Expanded(child: left),
        SizedBox(width: 16),
        Expanded(child: right),
      ],
    );
  }

  Widget _buildUserArticles() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 24),
        Text(
          "Mes articles",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF855386),
          ),
        ),
        Divider(thickness: 1, color: Color(0xFF855386)),
        _articles.isEmpty
            ? Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  "Aucun article pour le moment.",
                  style: TextStyle(color: Colors.grey),
                ),
              )
            : ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: _articles.length,
                itemBuilder: (context, index) {
                  final article = _articles[index];
                  return Card(
                    child: ListTile(
                      leading: (article.imageUrls.isNotEmpty)
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                article.imageUrls.first,
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Icon(Icons.image_not_supported, size: 48),
                      title: Text(
                        article.nom,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF855386),
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            article.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 4),
                          Text(
                            '${article.prix} €',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade700,
                            ),
                          ),
                        ],
                      ),
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) async {
                          if (value == 'edit') {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    EditArticlePage(produit: article),
                              ),
                            );

                            if (result == true) {
                              _loadUserArticles();
                            }
                          } else if (value == 'delete') {
                            _deleteArticle(article);
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'edit',
                            child: Text("Modifier"),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Text("Supprimer"),
                          ),
                        ],
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ProductDetailPage(produit: article),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profil',
          style: GoogleFonts.pacifico(
            textStyle: TextStyle(fontSize: 24, color: Colors.black),
          ),
        ),
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.logout),
          tooltip: "Se déconnecter",
          onPressed: () => logout(context),
        ),
        actions: [
          TextButton.icon(
            onPressed: _saveProfile,
            icon: Icon(Icons.save, color: Colors.black),
            label: Text(
              "Sauvegarder",
              style: GoogleFonts.pacifico(
                textStyle: TextStyle(fontSize: 18, color: Colors.black),
              ),
            ),
          ),
          TextButton.icon(
            onPressed: _confirmDeleteAccount,
            icon: Icon(Icons.delete_forever, color: Colors.red),
            label: Text(
              "Supprimer mon compte",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavBar(index: 5),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Color(0xFF855386), width: 1.5),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.shade200,
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundColor:
                                Color(0xFF855386).withOpacity(0.2),
                            backgroundImage: _imageFile != null
                                ? FileImage(_imageFile!)
                                : AssetImage(
                                    'assets/images/89d4b277e6c65224767ad167689bc17b.jpeg',
                                  ) as ImageProvider,
                          ),
                          SizedBox(width: 24),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Mes informations ",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF855386),
                                  ),
                                ),
                                Divider(thickness: 1, color: Color(0xFF855386)),
                                _buildFieldRow(
                                  left: _buildStyledField(
                                    label: "Nom",
                                    controller: nomController,
                                    icon: Icons.person,
                                    readOnly: true,
                                  ),
                                  right: _buildStyledField(
                                    label: "Email",
                                    controller: emailController,
                                    icon: Icons.email,
                                    keyboardType: TextInputType.emailAddress,
                                    validator: (val) {
                                      if (val == null || val.isEmpty) {
                                        return "Email obligatoire";
                                      }
                                      if (!RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w]{2,4}$")
                                          .hasMatch(val)) {
                                        return "Email invalide";
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                _buildFieldRow(
                                  left: _buildStyledField(
                                    label: "Prénom",
                                    controller: prenomController,
                                    icon: Icons.person_outline,
                                    readOnly: true,
                                  ),
                                  right: _buildStyledField(
                                    label: "Téléphone",
                                    controller: telephoneController,
                                    icon: Icons.phone,
                                    placeholder: "À remplir",
                                    keyboardType: TextInputType.phone,
                                  ),
                                ),
                                _buildFieldRow(
                                  left: _buildStyledField(
                                    label: "Genre",
                                    controller: genreController,
                                    icon: Icons.wc,
                                    readOnly: true,
                                  ),
                                  right: _buildStyledField(
                                    label: "Adresse",
                                    controller: adresseController,
                                    icon: Icons.home,
                                    placeholder: "À remplir",
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildUserArticles(),
                  ],
                ),
              ),
            ),
    );
  }
}
