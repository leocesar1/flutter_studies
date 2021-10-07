import 'package:flutter/material.dart';

void main() {
  runApp(new MaterialApp(title: "Contador de Pessoas", home: Home()));
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _people = 0;
  String _infoText = "Pode entrar!";

  void _changePeople(int delta) {
    setState(() {
      if (_people < 1) {
        if (delta == 1) {
          _people += delta;
        }
        ;
      } else if (_people < 10) {
        _people += delta;
      } else if (_people >= 10) {
        if (delta == -1) {
          _people += delta;
        }
        ;
      }
      ;
      if (_people >= 10) {
        _infoText = "Entrada proibida, evite aglomerações!";
      } else {
        _infoText = "Pode entrar!";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Image.asset(
          "images/Manaus.jpg",
          fit: BoxFit.cover,
          height: 4000.0,
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "Pessoas: $_people",
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(10.0),
                  child: TextButton(
                      onPressed: () {
                        _changePeople(-1);
                        debugPrint("-1");
                      },
                      child: Text(
                        "-1",
                        style: TextStyle(color: Colors.white, fontSize: 25.0),
                      )),
                ),
                Padding(
                  padding: EdgeInsets.all(10.0),
                  child: TextButton(
                      onPressed: () {
                        _changePeople(1);
                        debugPrint("+1");
                      },
                      child: Text(
                        "+1",
                        style: TextStyle(color: Colors.white, fontSize: 25.0),
                      )),
                ),
              ],
            ),
            Text(
              _infoText,
              style: TextStyle(
                  color: Colors.white,
                  fontStyle: FontStyle.italic,
                  fontSize: 30.0),
            )
          ],
        )
      ],
    );
  }
}
