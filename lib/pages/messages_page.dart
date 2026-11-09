import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:google_fonts/google_fonts.dart';

import '../widgets/bottom_nav_bar.dart';
import 'chat_page.dart';

class MessagesPage extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? currentUser = FirebaseAuth.instance.currentUser;

  String _generateChatId(String userId1, String userId2) {
    return userId1.hashCode <= userId2.hashCode
        ? '$userId1-$userId2'
        : '$userId2-$userId1';
  }

  @override
  Widget build(BuildContext context) {
    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Messages')),
        body: Center(child: Text('Vous devez être connecté pour voir vos messages')),
        bottomNavigationBar: BottomNavBar(index: 4),
      );
    }

    // Stream des conversations avec tri par dernier message
    Stream<QuerySnapshot> chatStream;
    try {
      chatStream = _firestore
          .collection('chats')
          .where('participants', arrayContains: currentUser!.uid)
          .orderBy('lastMessageTimestamp', descending: true)
          .snapshots();
    } catch (e) {
      // Si pas de timestamp, on récupère sans tri
      chatStream = _firestore
          .collection('chats')
          .where('participants', arrayContains: currentUser!.uid)
          .snapshots();
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Mes Conversations',
          style: GoogleFonts.pacifico(
            textStyle: TextStyle(fontSize: 24, color: Colors.black),
          ),
        ),
        backgroundColor: Color(0xFF855386),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: chatStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Erreur lors du chargement des conversations'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final chats = snapshot.data?.docs ?? [];

          if (chats.isEmpty) {
            return Center(child: Text('Aucune conversation pour le moment'));
          }

          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chatDoc = chats[index];
              final chatData = chatDoc.data() as Map<String, dynamic>;

              final participants = List<String>.from(chatData['participants'] ?? []);
              if (!participants.contains(currentUser!.uid)) {
                return SizedBox.shrink();
              }

              final otherUserId = participants.firstWhere(
                (id) => id != currentUser!.uid,
                orElse: () => 'unknown',
              );

              final lastMessage = (chatData['lastMessage'] as String?) ?? '[Pas de message]';

              // Lecture du champ 'readBy' pour currentUser
              final readByMap = chatData['readBy'] is Map<String, dynamic>
                  ? Map<String, dynamic>.from(chatData['readBy'])
                  : {};

              final hasUnreadMessages = !(readByMap[currentUser!.uid] == true);

              return FutureBuilder<DocumentSnapshot>(
                future: _firestore.collection('users').doc(otherUserId).get(),
                builder: (context, userSnapshot) {
                  if (userSnapshot.hasError || !userSnapshot.hasData || !userSnapshot.data!.exists) {
                    return ListTile(
                      title: Text('Utilisateur inconnu'),
                      subtitle: Text('Chargement...'),
                    );
                  }

                  final userData = userSnapshot.data!.data() as Map<String, dynamic>;
                  final fullName = '${userData['prenom'] ?? ''} ${userData['nom'] ?? ''}';
                  final email = userData['email'] ?? '';
                  final telephone = userData['telephone'] ?? '';
                  final genre = userData['genre'] ?? '';
                  final adresse = userData['adresse'] ?? '';

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChatPage(ownerId: otherUserId),
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          // Couleur différente si message non lu
                          color: hasUnreadMessages ? Colors.deepPurple.shade50 : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        padding: EdgeInsets.all(16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 6,
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 24,
                                    backgroundColor: Color(0xFF855386),
                                    child: Icon(Icons.person, color: Colors.white),
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          fullName,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        SizedBox(height: 6),
                                        Text('📧 $email', style: TextStyle(fontSize: 13)),
                                        Text('📞 $telephone', style: TextStyle(fontSize: 13)),
                                        Text('🚻 $genre', style: TextStyle(fontSize: 13)),
                                        Text('📍 $adresse', style: TextStyle(fontSize: 13)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.symmetric(horizontal: 12),
                              height: 80,
                              width: 1,
                              color: Colors.grey[400],
                            ),
                            Expanded(
                              flex: 4,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Messages',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF855386),
                                        ),
                                      ),
                                      // Icône indiquant état lu/non lu
                                      hasUnreadMessages
                                          ? Icon(Icons.markunread, color: Colors.redAccent)
                                          : Icon(Icons.done_all, color: Colors.grey),
                                      PopupMenuButton<String>(
                                        onSelected: (value) async {
                                          if (value == 'delete') {
                                            final confirm = await showDialog<bool>(
                                              context: context,
                                              builder: (ctx) => AlertDialog(
                                                title: Text('Confirmer la suppression'),
                                                content: Text('Voulez-vous vraiment supprimer cette conversation ?'),
                                                actions: [
                                                  TextButton(
                                                    child: Text('Annuler'),
                                                    onPressed: () => Navigator.of(ctx).pop(false),
                                                  ),
                                                  TextButton(
                                                    child: Text('Supprimer', style: TextStyle(color: Colors.red)),
                                                    onPressed: () => Navigator.of(ctx).pop(true),
                                                  ),
                                                ],
                                              ),
                                            );

                                            if (confirm == true) {
                                              await chatDoc.reference.delete();
                                            }
                                          }
                                        },
                                        itemBuilder: (context) => [
                                          PopupMenuItem(
                                            value: 'delete',
                                            child: Text('🗑️ Supprimer'),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    lastMessage,
                                    maxLines: 5,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontStyle: FontStyle.italic,
                                      color: Colors.black87,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      bottomNavigationBar: BottomNavBar(index: 4),
    );
  }
}
