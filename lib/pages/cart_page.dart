import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../widgets/bottom_nav_bar.dart';
import '../models/produit.dart';

class CartPage extends StatefulWidget {
  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final Map<String, bool> _selectedItems = {};

  @override
  void initState() {
    super.initState();
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    cartProvider.loadCart().then((_) {
      for (var produit in cartProvider.cartItems) {
        _selectedItems[produit.id] = false;
      }
      setState(() {});
    });
  }

  double getTotalSelected(List<Produit> cartItems) {
    return cartItems
        .where((p) => _selectedItems[p.id] ?? false)
        .fold(0.0, (sum, p) => sum + p.prix);
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final cartItems = cartProvider.cartItems;

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
              'Mon Panier',
              style: TextStyle(
                fontFamily: 'pacifico',
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: Color(0xFF855386),
              ),
            ),
            SizedBox(width: 10),
            CircleAvatar(
              backgroundColor: Color(0xFF855386),
              radius: 17,
              child: Icon(Icons.shopping_cart, color: Colors.white, size: 18),
            ),
          ],
        ),
      ),
      body: cartItems.isEmpty
          ? Center(
              child: Text(
                'Votre panier est vide',
                style: TextStyle(fontSize: 16),
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                final produit = cartItems[index];
                final isSelected = _selectedItems[produit.id] ?? false;

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
                        Checkbox(
                          value: isSelected,
                          onChanged: (value) {
                            setState(() {
                              _selectedItems[produit.id] = value ?? false;
                            });
                          },
                        ),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            produit.imageUrls.first,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Icon(Icons.broken_image),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                produit.nom,
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            await cartProvider.removeFromCart(produit);
                            setState(() {
                              _selectedItems.remove(produit.id);
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Article retiré du panier')),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      bottomSheet: cartItems.isNotEmpty
          ? Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xFF855386).withOpacity(0.1),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total :',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text(
                        '${getTotalSelected(cartItems).toStringAsFixed(2)} €',
                        style: TextStyle(fontSize: 18, color: Color(0xFF855386)),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: getTotalSelected(cartItems) > 0
                        ? () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Paiement effectué')),
                            );
                          }
                        : null,
                    child: Text('Payer mes achats'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF855386),
                      foregroundColor: Colors.white,
                      minimumSize: Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            )
          : null,
      bottomNavigationBar: BottomNavBar(index: 2),
      backgroundColor: Colors.white,
    );
  }
}
