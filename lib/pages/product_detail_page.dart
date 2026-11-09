import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/produit.dart';
import '../providers/favorites_provider.dart';
import '../providers/cart_provider.dart';
import 'chat_page.dart';

class ProductDetailPage extends StatefulWidget {
  final Produit produit;

  ProductDetailPage({required this.produit});

  @override
  _ProductDetailPageState createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late TextEditingController nomController;
  late TextEditingController prenomController;
  late TextEditingController genreController;
  late TextEditingController emailController;
  late TextEditingController telephoneController;
  late TextEditingController adresseController;

  bool _isLoadingUser = true;

  String? _currentUserId;

  final PageController _pageController = PageController();
  int _currentPageIndex = 0;

  @override
  void initState() {
    super.initState();

    nomController = TextEditingController();
    prenomController = TextEditingController();
    genreController = TextEditingController();
    emailController = TextEditingController();
    telephoneController = TextEditingController();
    adresseController = TextEditingController();

    _currentUserId = FirebaseAuth.instance.currentUser?.uid;

    _loadUserData();

    _pageController.addListener(() {
      int newPage = _pageController.page?.round() ?? 0;
      if (newPage != _currentPageIndex) {
        setState(() {
          _currentPageIndex = newPage;
        });
      }
    });
  }

  @override
  void dispose() {
    nomController.dispose();
    prenomController.dispose();
    genreController.dispose();
    emailController.dispose();
    telephoneController.dispose();
    adresseController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final ownerId = widget.produit.ownerId;
    if (ownerId.isEmpty) {
      setState(() => _isLoadingUser = false);
      return;
    }

    try {
      final doc = await _firestore.collection('users').doc(ownerId).get();
      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          nomController.text = data['nom'] ?? '';
          prenomController.text = data['prenom'] ?? '';
          genreController.text = data['genre'] ?? '';
          emailController.text = data['email'] ?? '';
          telephoneController.text = data['telephone'] ?? '';
          adresseController.text = data['adresse'] ?? '';
          _isLoadingUser = false;
        });
      } else {
        setState(() => _isLoadingUser = false);
      }
    } catch (e) {
      setState(() => _isLoadingUser = false);
      print('Erreur récupération vendeur: $e');
    }
  }

  Widget _buildReadOnlySimpleField(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        initialValue: value,
        readOnly: true,
        maxLines: label == 'Description' ? null : 1,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          suffixIcon: Icon(icon, color: Color(0xFF855386)),
          filled: true,
          fillColor: Color(0xFFF8F2F9),
        ),
      ),
    );
  }

  Widget _infoTile(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, color: Color(0xFF855386), size: 20),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              "$label: $value",
              style: TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageCarousel() {
    final images = widget.produit.imageUrls;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 300,
          child: PageView.builder(
            controller: _pageController,
            itemCount: images.length,
            onPageChanged: (index) {
              setState(() {
                _currentPageIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    images[index],
                    width: double.infinity,
                    height: 300,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.broken_image,
                      size: 80,
                      color: Colors.grey,
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 12),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(images.length, (index) {
            final isActive = index == _currentPageIndex;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: isActive ? 18 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: isActive ? const Color(0xFF855386) : Colors.grey.shade400,
                borderRadius: BorderRadius.circular(8),
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        )
                      ]
                    : [],
              ),
            );
          }),
        ),

        const SizedBox(height: 12),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: _currentPageIndex == 0
                  ? null
                  : () {
                      _pageController.previousPage(
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
              child: AnimatedOpacity(
                duration: Duration(milliseconds: 300),
                opacity: _currentPageIndex == 0 ? 0.4 : 1,
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: const Color(0xFF855386),
                  child: const Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 20),

            GestureDetector(
              onTap: _currentPageIndex == images.length - 1
                  ? null
                  : () {
                      _pageController.nextPage(
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
              child: AnimatedOpacity(
                duration: Duration(milliseconds: 300),
                opacity: _currentPageIndex == images.length - 1 ? 0.4 : 1,
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: const Color(0xFF855386),
                  child: const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final favoritesProvider = Provider.of<FavoritesProvider>(context);
    final isFavorite = favoritesProvider.isFavorite(widget.produit);

    void toggleFavorite() {
      favoritesProvider.toggleFavorite(widget.produit);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isFavorite ? 'Retiré des favoris' : 'Ajouté aux favoris'),
          duration: Duration(seconds: 1),
        ),
      );
    }

    void addToCart() {
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      cartProvider.addToCart(widget.produit);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Article ajouté au panier'),
          duration: Duration(seconds: 1),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.black),
        backgroundColor: Color(0xFFFFF4FF),
        centerTitle: true,
        title: Text(
          'Détails de l\'article',
          style: GoogleFonts.pacifico(
            textStyle: TextStyle(fontSize: 24, color: Colors.black),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 5, child: _buildImageCarousel()),
                SizedBox(width: 20),
                Expanded(
                  flex: 6,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment: Alignment.topRight,
                        child: IconButton(
                          icon: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: Colors.pinkAccent,
                            size: 36,
                          ),
                          onPressed: toggleFavorite,
                          tooltip: isFavorite
                              ? 'Retirer des favoris'
                              : 'Ajouter aux favoris',
                        ),
                      ),
                      _buildReadOnlySimpleField(
                          "Nom", widget.produit.nom, Icons.label),
                      _buildReadOnlySimpleField(
                          "Description", widget.produit.description, Icons.description),
                      _buildReadOnlySimpleField(
                          "Prix",
                          '${widget.produit.prix.toStringAsFixed(2)} €',
                          Icons.euro),
                      SizedBox(height: 12),
                      Center(
                        child: ElevatedButton.icon(
                          icon: Icon(Icons.shopping_cart, color: Colors.white),
                          label: Text(
                            'Ajouter au panier',
                            style: TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            padding:
                                EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                            backgroundColor: Color(0xFF855386),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: addToCart,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 30),

            if (_isLoadingUser)
              Center(child: CircularProgressIndicator())
            else
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                color: Color(0xFFF8F2F9),
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.keyboard_arrow_right,
                            color: Color(0xFF855386),
                          ),
                          SizedBox(width: 8),
                          Text(
                            "Informations du vendeur",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF855386),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Ici, on supprime totalement l'avatar du vendeur

                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _infoTile("Nom", nomController.text, Icons.person),
                                SizedBox(height: 8),
                                _infoTile(
                                    "Prénom", prenomController.text, Icons.person_outline),
                                SizedBox(height: 8),
                                _infoTile("Genre", genreController.text, Icons.wc),
                              ],
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 60,
                            color: Colors.grey.shade400,
                            margin: EdgeInsets.symmetric(horizontal: 8),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _infoTile("Email", emailController.text, Icons.email),
                                SizedBox(height: 8),
                                _infoTile("Téléphone", telephoneController.text, Icons.phone),
                                SizedBox(height: 8),
                                _infoTile("Adresse", adresseController.text,
                                    Icons.location_on),
                              ],
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 20),

                      if (_currentUserId != widget.produit.ownerId)
                        Center(
                          child: ElevatedButton.icon(
                            icon: Icon(Icons.chat, color: Colors.white),
                            label: Text(
                              'Envoyer un message au vendeur',
                              style: TextStyle(color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 32, vertical: 14),
                              backgroundColor: Color(0xFF855386),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      ChatPage(ownerId: widget.produit.ownerId),
                                ),
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
