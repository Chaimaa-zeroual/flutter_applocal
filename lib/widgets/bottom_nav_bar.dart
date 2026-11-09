import 'package:flutter/material.dart';
import '../pages/home_page.dart';
import '../pages/favorites_page.dart';
import '../pages/add_product_page.dart';
import '../pages/cart_page.dart';
import '../pages/profile_page.dart';
import '../pages/messages_page.dart'; 
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BottomNavBar extends StatefulWidget {
  final int index;
  BottomNavBar({required this.index});

  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<int> _getUnreadMessagesCount() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return Stream.value(0);

    return _firestore
        .collection('chats')
        .where('participants', arrayContains: currentUser.uid)
        .snapshots()
        .map((snapshot) {
      int count = 0;
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final readBy = data['readBy'] ?? {};
        if (!(readBy[currentUser.uid] == true)) {
          count++;
        }
      }
      return count;
    });
  }

  void _onItemTapped(BuildContext context, int selectedIndex) {
    if (selectedIndex == widget.index) return;

    Widget page;
    switch (selectedIndex) {
      case 0:
        page = HomePage();
        break;
      case 1:
        page = FavoritesPage();
        break;
      case 2:
        page = CartPage();
        break;
      case 3:
        page = AddProductPage();
        break;
      case 4:
        page = MessagesPage();
        break;
      case 5:
        page = ProfilePage();
        break;
      default:
        page = HomePage();
    }

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => page,
        transitionDuration: Duration(milliseconds: 300),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream: _getUnreadMessagesCount(),
      builder: (context, snapshot) {
        int unreadCount = snapshot.data ?? 0;

        return BottomNavigationBar(
          currentIndex: widget.index,
          selectedItemColor: Color(0xFF855386),
          unselectedItemColor: Colors.grey,
          onTap: (i) => _onItemTapped(context, i),
          type: BottomNavigationBarType.fixed,
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
            BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Favoris'),
            BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Panier'),
            BottomNavigationBarItem(icon: Icon(Icons.add_box), label: 'Vendre'),
            BottomNavigationBarItem(
              icon: Stack(
                children: [
                  Icon(Icons.message),
                  if (unreadCount > 0)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: BoxConstraints(minWidth: 12, minHeight: 12),
                      ),
                    ),
                ],
              ),
              label: 'Messages',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
          ],
        );
      },
    );
  }
}
