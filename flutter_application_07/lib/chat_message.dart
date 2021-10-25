import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChatMessage extends StatelessWidget {
  // const ChatMessage({ Key? key }) : super(key: key);
  ChatMessage(this.data, this.mine);

  final bool mine;
  DocumentSnapshot data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          !mine
              ? Padding(
                  padding: EdgeInsets.only(right: 5, top: 20),
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(data['senderPhotoUrl']),
                  ))
              : Container(
                  padding: EdgeInsets.only(left: 100),
                ),
          Expanded(
            child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 800),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    vertical: 15,
                  ),
                  child: Column(
                      crossAxisAlignment: mine
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(data['senderName'],
                            textAlign: mine ? TextAlign.end : TextAlign.start,
                            style: TextStyle(
                                fontSize: 13, fontWeight: FontWeight.bold)),
                        Container(
                            padding: EdgeInsets.symmetric(
                                vertical: 15, horizontal: 15),
                            color: mine ? Colors.blue[50] : Colors.grey[200],
                            margin: const EdgeInsets.symmetric(vertical: 5),
                            child: Column(
                                crossAxisAlignment: mine
                                    ? CrossAxisAlignment.end
                                    : CrossAxisAlignment.start,
                                children: <Widget>[
                                  data['imgUrl'] != null
                                      ? Image.network(
                                          data['imgUrl'],
                                          width: 500,
                                        )
                                      : Text(
                                          data['text'],
                                          style: TextStyle(fontSize: 16),
                                        ),
                                ])),
                      ]),
                )),
          ),
          mine
              ? Padding(
                  padding: EdgeInsets.all(5),
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(data['senderPhotoUrl']),
                  ))
              : Container(
                  padding: EdgeInsets.only(right: 100),
                ),
        ],
      ),
    );
  }
}
