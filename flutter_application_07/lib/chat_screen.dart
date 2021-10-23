import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'text_composer.dart';
import 'chat_message.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  User? _currentUser;

  @override
  void initState() {
    FirebaseAuth.instance.authStateChanges().listen((user) {
      _currentUser = user;
    });
    super.initState();
  }

  Future<User?> _getUser() async {
    GoogleAuthProvider authProvider = GoogleAuthProvider();
    authProvider.addScope('https://www.googleapis.com/auth/contacts.readonly');
    authProvider.setCustomParameters({'login_hint': 'user@example.com'});

    if (_currentUser != null) return _currentUser;

    try {
      final UserCredential authResult =
          await FirebaseAuth.instance.signInWithPopup(authProvider); // web

      User? user = authResult.user;

      return user;
    } catch (e) {
      return null;
    }
  }

  void _sendMessage({String? text, Uint8List? imgFile}) async {
    final User? user = await _getUser();
    print(user);

    if (user == null) {
      final snack = SnackBar(
          content: Text('Não foi possível fazer o login. Tente novamente!'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2));

      ScaffoldMessenger.of(context).showSnackBar(snack);
    }

    Map<String, dynamic> data;
    if (user != null) {
      data = {
        'uid': user.uid,
        'senderName': user.displayName,
        'senderPhotoUrl': user.photoURL,
        'text': text,
        'imgUrl': imgFile,
      };
    } else {
      data = {
        'uid': "asdas das as das d",
        'senderName': "Leonardo",
        'senderPhotoUrl':
            "https://upload.wikimedia.org/wikipedia/commons/thumb/0/05/Flag_of_Brazil.svg/125px-Flag_of_Brazil.svg.png",
        'text': text,
        'imgUrl': imgFile,
      };
    }

    if (imgFile != null) {
      try {
        firebase_storage.Task task = firebase_storage.FirebaseStorage.instance
            .ref()
            .child(DateTime.now().millisecondsSinceEpoch.toString())
            .putData(imgFile);

        firebase_storage.TaskSnapshot snapshot = await task;
      } on FirebaseException catch (e) {
        print(e);
        // e.g, e.code == 'canceled'
      }
    }
    if (user != null)
      FirebaseFirestore.instance.collection('messages').add(data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text("Chat"),
          elevation: 0,
        ),
        body: Column(
          children: <Widget>[
            Expanded(
                child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('messages')
                        .snapshots(),
                    builder: (context, snapshot) {
                      switch (snapshot.connectionState) {
                        case ConnectionState.none:
                        case ConnectionState.waiting:
                          return Center(child: CircularProgressIndicator());
                        default:
                          List<DocumentSnapshot> documents =
                              snapshot.data!.docs.reversed.toList();

                          return ListView.builder(
                            itemBuilder: (context, index) {
                              // print(documents[index].data);
                              // print(json.decode(documents[index].toString()));
                              return ChatMessage(documents[index]);
                            },
                            itemCount: documents.length,
                            // reverse: true
                          );
                      }
                    })),
            TextComposer(_sendMessage)
          ],
        ));
  }
}
