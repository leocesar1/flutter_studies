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
    super.initState();

    FirebaseAuth.instance.authStateChanges().listen((user) {
      setState(() {
        _currentUser = user;
      });
    });
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
    setState(() {});
    final User? user = await _getUser();
    // print(user!.displayName);

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
        'time': Timestamp.now(),
      };
    } else {
      data = {};
    }

    if (imgFile != null) {
      try {
        firebase_storage.Task task = firebase_storage.FirebaseStorage.instance
            .ref()
            .child(
                '${_currentUser!.uid.toString()}_${DateTime.now().millisecondsSinceEpoch.toString()}')
            .putData(imgFile);

        firebase_storage.TaskSnapshot snapshot = await task;
      } on FirebaseException catch (e) {
        print(e);
        // e.g, e.code == 'canceled'
      }
    }
    user != null
        ? FirebaseFirestore.instance.collection('messages').add(data)
        : null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          shadowColor: Colors.black,
          centerTitle: true,
          title: Text(_currentUser != null
              ? 'Olá, ${_currentUser!.displayName}'
              : 'Chat app'),
          elevation: 0,
          actions: <Widget>[
            _currentUser != null
                ? IconButton(
                    icon: Icon(Icons.exit_to_app),
                    onPressed: () {
                      FirebaseAuth.instance.signOut();
                      googleSignIn.signOut();
                      final snack = SnackBar(
                          content: Text('Você foi desconectado!'),
                          duration: Duration(seconds: 2));

                      ScaffoldMessenger.of(context).showSnackBar(snack);
                    })
                : IconButton(
                    icon: Icon(Icons.login_sharp),
                    onPressed: () {
                      if (_getUser() == null) {
                        final snack = SnackBar(
                            content:
                                Text('Não foi possível realizar a conexão!'),
                            backgroundColor: Colors.red,
                            duration: Duration(seconds: 4));
                        ScaffoldMessenger.of(context).showSnackBar(snack);
                      } else {
                        final snack = SnackBar(
                            content: Text('Conectado!!!'),
                            backgroundColor: Colors.green,
                            duration: Duration(seconds: 4));
                        ScaffoldMessenger.of(context).showSnackBar(snack);
                      }
                    })
          ],
        ),
        body: Column(
          children: <Widget>[
            Expanded(
                child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('messages')
                        .orderBy('time')
                        .snapshots(),
                    builder: (context, snapshot) {
                      switch (snapshot.connectionState) {
                        case ConnectionState.none:
                        case ConnectionState.waiting:
                          return Center(child: CircularProgressIndicator());
                        default:
                          try {
                            List<DocumentSnapshot> documents =
                                snapshot.data!.docs.reversed.toList();

                            return ListView.builder(
                                itemBuilder: (context, index) {
                                  // print(documents[index].data);
                                  // print(json.decode(documents[index].toString()));
                                  return ChatMessage(
                                      documents[index],
                                      documents[index]['uid'] ==
                                          _currentUser?.uid);
                                },
                                itemCount: documents.length,
                                reverse: true);
                          } catch (e) {
                            return Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Icon(
                                    Icons.block,
                                    size: 150,
                                    color: Colors.blue[300],
                                  ),
                                  Text(
                                    'Você não está conectado.',
                                    style: TextStyle(fontSize: 30),
                                  ),
                                ]);
                          }
                      }
                    })),
            TextComposer(_sendMessage)
          ],
        ));
  }
}
