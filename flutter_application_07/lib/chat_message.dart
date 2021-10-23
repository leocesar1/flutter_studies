import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChatMessage extends StatelessWidget {
  // const ChatMessage({ Key? key }) : super(key: key);
  ChatMessage(this.data);

  DocumentSnapshot data;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: Row(
        children: <Widget>[
          Padding(
              padding: EdgeInsets.all(10),
              child: CircleAvatar(
                backgroundImage: NetworkImage(data['senderPhotoUrl']),
              )),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                data['imgUrl'] != null
                    ? Image.network(data['imgUrl'])
                    : Text(
                        data['text'],
                        style: TextStyle(fontSize: 16),
                      ),
                Text(data['senderName'],
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold))
              ]))
        ],
      ),
    );
  }
}
