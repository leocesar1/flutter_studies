import 'package:flutter/material.dart';
import 'package:flutter_application_05/ui/gif_page.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:share_plus/share_plus.dart';
import 'package:transparent_image/transparent_image.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _search = "";
  int _offset = 0;
  Future<Map> _getGifs() async {
    http.Response response;
    String url;
    if (_search == "") {
      url =
          "https://api.giphy.com/v1/gifs/trending?api_key=u2fd5WH664b5TyhG0SxmgFIrBD3aqJce&limit=20&rating=g";
    } else {
      url =
          'https://api.giphy.com/v1/gifs/search?api_key=u2fd5WH664b5TyhG0SxmgFIrBD3aqJce&q=$_search&limit=19&offset=$_offset&rating=g&lang=pt';
    }
    response = await http.get(Uri.parse(url));

    return json.decode(response.body);
  }

  @override
  void initState() {
    super.initState();
    _getGifs().then((map) {
      // print(map);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Buscador de Gifs"),
        centerTitle: true,
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: Column(children: <Widget>[
        Padding(
          padding: EdgeInsets.fromLTRB(10, 20, 10, 10),
          child: TextField(
            decoration: InputDecoration(
                labelText: "Pesquise aqui",
                labelStyle: TextStyle(color: Colors.white),
                border: OutlineInputBorder(),
                disabledBorder: OutlineInputBorder()),
            style: TextStyle(color: Colors.white, fontSize: 18.0),
            textAlign: TextAlign.center,
            onSubmitted: (text) {
              setState(() {
                _offset = 0;
                _search = text;
              });
            },
          ),
        ),
        Expanded(
          child: FutureBuilder(
              future: _getGifs(),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                  case ConnectionState.none:
                    return Container(
                      width: 200,
                      height: 200,
                      alignment: Alignment.center,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 5.0,
                      ),
                    );
                  default:
                    if (snapshot.hasError) {
                      return Container();
                    } else
                      return _createGifTable(context, snapshot);
                }
              }),
        )
      ]),
    );
  }

  int _getCount(List data) {
    if (_search == "") {
      return data.length;
    } else {
      return data.length + 1;
    }
  }

  Widget _createGifTable(context, snapshot) {
    return GridView.builder(
      padding: EdgeInsets.all(10),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: _getCount(snapshot.data["data"]),
      itemBuilder: (context, index) {
        if (_search == "" || index < snapshot.data["data"].length) {
          return GestureDetector(
              onLongPress: () {
                Share.share(snapshot.data["data"][index]["images"]
                    ["fixed_height"]["url"]);
              },
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            GifPage(snapshot.data["data"][index])));
              },
              child: FadeInImage.memoryNetwork(
                  placeholder: kTransparentImage,
                  height: 200,
                  fit: BoxFit.cover,
                  image: snapshot.data["data"][index]["images"]["fixed_height"]
                      ["url"]));
        } else
          return Container(
            child: GestureDetector(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Icon(Icons.add, color: Colors.white, size: 70.0),
                    Text("Carregar mais",
                        style: TextStyle(fontSize: 22, color: Colors.white))
                  ]),
              onTap: () {
                setState(() {
                  _offset += 19;
                });
              },
            ),
          );
      },
    );
  }
}
