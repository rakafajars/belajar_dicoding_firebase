import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dicoding_chatting/pages/login_page.dart';
import 'package:dicoding_chatting/widgets/message_bubble.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  static const String id = 'chat_page';

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _auth = FirebaseAuth.instance;

  final _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    // TODO: implement initState
    getCurrentUser();
  }

  // Method untuk mengecek siapa yang login
  User _activeUser;

  void getCurrentUser() async {
    try {
      var currentUser = await _auth.currentUser;

      if (currentUser != null) {
        _activeUser = currentUser;
      }
    } catch (e) {
      print(e);
    }
  }

  // Fitur pesan yang disimpan ke firestore
  final _messageTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat Room'),
        actions: [
          IconButton(
            icon: Icon(Icons.close),
            tooltip: 'Logout',
            onPressed: () async {
              await _auth.signOut();
              Navigator.pushReplacementNamed(context, LoginPage.id);
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('users')
                    .orderBy(
                      'dateCreated',
                      descending: true,
                    )
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  final messages = snapshot.data.docs;
                  List<MessageBubble> messageBubble = [];
                  for (var message in messages) {
                    final messageText = message.data()['text'];
                    final messageSender = message.data()['sender'];

                    final messageBuble = MessageBubble(
                      sender: messageSender,
                      text: messageText,
                      isMyChat: messageSender == _activeUser.email,
                    );

                    messageBubble.add(messageBuble);
                  }

                  return ListView(
                    reverse: true,
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: 16.0,
                    ),
                    children: messageBubble,
                  );
                },
              ),
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageTextController,
                    decoration: InputDecoration(
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                MaterialButton(
                  child: Text('SEND'),
                  color: Theme.of(context).primaryColor,
                  textTheme: ButtonTextTheme.primary,
                  onPressed: () {
                    _firestore.collection("users").add(
                      {
                        'text': _messageTextController.text,
                        'sender': _activeUser.email,
                        'dateCreated' : Timestamp.now(),
                      },
                    );

                    _messageTextController.clear();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
