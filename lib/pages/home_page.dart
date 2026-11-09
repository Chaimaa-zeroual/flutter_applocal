import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/firestore_service.dart';
import '../widgets/product_card.dart';
import '../widgets/bottom_nav_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/produit.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final firestoreService = FirestoreService();

  String selectedCategory = 'Homme';
  String? selectedSubCategory;
  final TextEditingController searchController = TextEditingController();

  final Map<String, List<String>> subCategories = {
    'Homme': ['T-shirts', 'Chemises', 'Pantalons', 'Vestes'],
    'Femme': ['Robes', 'Jupes', 'Tops', 'Manteaux'],
    'Enfants': ['Bébés', 'Garçons', 'Filles', 'Chaussures'],
  };

  void logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }

  final Color customPurple = Color(0xFF855386);

  @override
  Widget build(BuildContext context) {
    List<String> currentSubCategories = subCategories[selectedCategory] ?? [];

    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: null,
        title: Text(
          'Chaïnal – La mode marocaine',
          style: GoogleFonts.pacifico(
            fontSize: 35,
            color: customPurple,
          ),
          textAlign: TextAlign.center,
        ),
        centerTitle: true,
        actions: [
          Container(
            margin: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: customPurple,
              border: Border.all(color: customPurple, width: 2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              padding: EdgeInsets.all(4),
              icon: Icon(Icons.logout, size: 30, color: Colors.black),
              onPressed: () => logout(context),
              tooltip: 'Se déconnecter',
            ),
          ),
        ],
      ),

      bottomNavigationBar: BottomNavBar(index: 0),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Barre de recherche
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 55, vertical: 18),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: customPurple, width: 2),
              ),
              child: TextField(
                controller: searchController,
                onChanged: (_) => setState(() {}),
                style: TextStyle(fontSize: 15),
                decoration: InputDecoration(
                  hintText: 'Rechercher...',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 12),
                  suffixIcon: Icon(Icons.search, color: customPurple),
                ),
              ),
            ),
          ),

          // Catégories
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: ['Homme', 'Femme', 'Enfants'].map((cat) {
                bool isSelected = cat == selectedCategory;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedCategory = cat;
                      selectedSubCategory = null;
                    });
                  },
                  child: Text(
                    cat,
                    style: GoogleFonts.pacifico(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? customPurple : Colors.black87,
                      decoration: isSelected ? TextDecoration.underline : null,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // Sous-catégories
          Expanded(
            flex: 2,
            child: Center(
              child: Wrap(
                spacing: 16,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: currentSubCategories.map((subCat) {
                  bool isSelected = subCat == selectedSubCategory;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedSubCategory = subCat;
                      });
                    },
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 250),
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: isSelected ? customPurple.withOpacity(0.15) : Colors.grey.shade200,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? customPurple : Colors.grey.shade400,
                          width: isSelected ? 3 : 1.5,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: customPurple.withOpacity(0.3),
                                  blurRadius: 6,
                                  offset: Offset(0, 3),
                                )
                              ]
                            : [],
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        subCat,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.pacifico(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? customPurple.withOpacity(0.9) : Colors.black87,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // Liste de produits filtrés
          Container(
            height: 300,
            child: StreamBuilder<List<Produit>>(
              stream: firestoreService.getProduits(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

                var produits = snapshot.data!;
                var filteredProduits = produits.where((produit) {
                  final searchQuery = searchController.text.trim().toLowerCase();
                  bool matchesCategory = produit.categorie == selectedCategory;
                  bool matchesSubCategory = selectedSubCategory == null
                      ? true
                      : produit.sousCategorie == selectedSubCategory;
                  bool matchesSearch = searchQuery.isEmpty
                      ? true
                      : (produit.nom.toLowerCase().contains(searchQuery) ||
                         produit.description.toLowerCase().contains(searchQuery));

                  return matchesCategory && matchesSubCategory && matchesSearch;
                }).toList();

                if (filteredProduits.isEmpty) {
                  return Center(child: Text('Aucun article trouvé'));
                }

                return GridView.builder(
                  padding: EdgeInsets.all(10),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.7,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: filteredProduits.length,
                  itemBuilder: (context, index) =>
                      ProductCard(produit: filteredProduits[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
