import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/favorites_provider.dart';
import '../widgets/bottom_nav_bar.dart';
import '../models/produit.dart';

class FavoritesPage extends StatefulWidget {
  @override
  _FavoritesPageState createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    final favoritesProvider = Provider.of<FavoritesProvider>(context, listen: false);
    favoritesProvider.loadFavorites().then((_) {
      setState(() {
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final favoritesProvider = Provider.of<FavoritesProvider>(context);
    final favorites = favoritesProvider.favorites;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Color(0xFF855386)),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Mes favoris',
              style: TextStyle(
                fontFamily: 'pacifico',
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: Color(0xFF855386),
              ),
            ),
            SizedBox(width: 10),
            CircleAvatar(
              radius: 17,
              backgroundColor: Color(0xFF855386),
              child: Icon(Icons.favorite, color: Colors.pinkAccent, size: 18),
            ),
          ],
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : favorites.isEmpty
              ? Center(
                  child: Text(
                    'Aucun article en favoris',
                    style: TextStyle(fontSize: 16),
                  ),
                )
              : ListView.builder(
                  itemCount: favorites.length,
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  itemBuilder: (context, index) {
                    final produit = favorites[index];
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                      child: Padding(
                        padding: EdgeInsets.all(10),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                produit.imageUrls.first,
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Icon(Icons.broken_image, size: 80, color: Colors.grey),
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    produit.nom,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    produit.description ?? "Aucune description",
                                    style: TextStyle(
                                      fontStyle: FontStyle.italic,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    '${produit.prix.toStringAsFixed(2)} €',
                                    style: TextStyle(
                                      color: Color(0xFF855386),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.favorite, color: Colors.pinkAccent),
                              onPressed: () {
                                favoritesProvider.removeFromFavorites(produit);
                                setState(() {}); // Rafraîchir l'UI
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('${produit.nom} retiré des favoris'),
                                    duration: Duration(seconds: 1),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      bottomNavigationBar: BottomNavBar(index: 1),
      backgroundColor: Colors.white,
    );
  }
}
