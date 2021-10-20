import 'package:flutter/material.dart';
import 'text_composer.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  void _sendMessage(String text) {
    FirebaseFirestore.instance.collection('col').add({
      'teste': text, // John Doe
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chat"),
        elevation: 0,
      ),
      body: TextComposer((text) {
        print(text);
        _sendMessage(text);
      }),
    );
  }
}
