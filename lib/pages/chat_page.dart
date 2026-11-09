import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

class ChatPage extends StatefulWidget {
  final String ownerId;

  ChatPage({required this.ownerId});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController messageController = TextEditingController();

  String _generateChatId(String userId1, String userId2) {
    return userId1.hashCode <= userId2.hashCode
        ? '$userId1-$userId2'
        : '$userId2-$userId1';
  }

  @override
  void initState() {
    super.initState();
    _markMessagesAsRead();
  }

  Future<void> _markMessagesAsRead() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final chatId = _generateChatId(currentUser.uid, widget.ownerId);

    final chatDocRef =
        FirebaseFirestore.instance.collection('chats').doc(chatId);

    try {
      final snapshot = await chatDocRef.get();
      Map<String, dynamic> data = {};
      if (snapshot.exists) {
        data = snapshot.data() as Map<String, dynamic>;
      }

      Map<String, dynamic> readBy = {};
      if (data.containsKey('readBy')) {
        readBy = Map<String, dynamic>.from(data['readBy']);
      }

      readBy[currentUser.uid] = true;

      await chatDocRef.set({'readBy': readBy}, SetOptions(merge: true));
    } catch (e) {
      print('Erreur lors de la mise à jour readBy: $e');
    }
  }

  Stream<QuerySnapshot> getMessagesStream() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return const Stream.empty();

    final chatId = _generateChatId(currentUser.uid, widget.ownerId);

    return FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Future<void> _sendMessage() async {
    final message = messageController.text.trim();
    if (message.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veuillez écrire un message')),
      );
      return;
    }

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vous devez être connecté')),
      );
      return;
    }

    try {
      final chatId = _generateChatId(currentUser.uid, widget.ownerId);

      final chatDocRef =
          FirebaseFirestore.instance.collection('chats').doc(chatId);

      await chatDocRef.set({
        'participants': [currentUser.uid, widget.ownerId],
        'lastMessageTimestamp': FieldValue.serverTimestamp(),
        'lastMessage': message,
        'readBy': {
          currentUser.uid: true,
          widget.ownerId: false,
        },
      }, SetOptions(merge: true));

      await chatDocRef.collection('messages').add({
        'senderId': currentUser.uid,
        'receiverId': widget.ownerId,
        'message': message,
        'timestamp': FieldValue.serverTimestamp(),
        'read': false,
      });

      messageController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de l\'envoi du message')),
      );
      print('Erreur _sendMessage: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Chat avec le vendeur',
          style: GoogleFonts.pacifico(
            textStyle: TextStyle(fontSize: 24, color: Colors.black),
          ),
        ),
        backgroundColor: Color(0xFF855386),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: getMessagesStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Erreur chargement messages'));
                }

                final messages = snapshot.data?.docs ?? [];

                if (messages.isEmpty) {
                  return Center(child: Text('Aucun message'));
                }

                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isMe = msg['senderId'] == currentUser?.uid;

                    return Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                      alignment: isMe
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        decoration: BoxDecoration(
                          color: isMe
                              ? Colors.pink.shade100
                              : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                        child: Text(
                          msg['message'],
                          style: TextStyle(color: Colors.black87),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: messageController,
                      decoration: InputDecoration(
                        hintText: 'Écrire un message...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _sendMessage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF855386),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.all(12),
                    ),
                    child: Icon(Icons.send, color: Colors.white), // <-- Blanc ici
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
