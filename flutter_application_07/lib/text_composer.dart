import 'package:flutter/material.dart';

class TextComposer extends StatefulWidget {
  // const TextComposer({Key? key}) : super(key: key);
  TextComposer(this.sendMessage);

  final Function({String text}) sendMessage;

  @override
  _TextComposerState createState() => _TextComposerState();
}

class _TextComposerState extends State<TextComposer> {
  bool _isComposing = false;

  final TextEditingController _controller = TextEditingController();

  void _reset() {
    setState(() {
      _controller.clear();
      _isComposing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.symmetric(horizontal: 8),
        child: Row(children: <Widget>[
          IconButton(
            icon: Icon(Icons.photo_camera),
            onPressed: () {},
          ),
          Expanded(
            child: TextField(
              controller: _controller,
              decoration:
                  InputDecoration.collapsed(hintText: "Enviar uma mensagem"),
              onChanged: (text) {
                setState(() {
                  _isComposing = text.isNotEmpty;
                });
              },
              onSubmitted: (text) {
                widget.sendMessage(text: text);
                _reset();
              },
            ),
          ),
          IconButton(
              onPressed: _isComposing
                  ? () {
                      widget.sendMessage(text: _controller.text);
                      _reset();
                    }
                  : null,
              icon: Icon(Icons.send))
        ]));
  }
}
