import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

var request =
    Uri.https('economia.awesomeapi.com.br', '/last/USD-BRL,EUR-BRL,BTC-BRL');

void main() async {
  runApp(MaterialApp(
    theme: ThemeData(
      hintColor: Colors.amber,
      primaryColor: Colors.white,
      inputDecorationTheme: InputDecorationTheme(
        enabledBorder:
            OutlineInputBorder(borderSide: BorderSide(color: Colors.amber)),
        disabledBorder:
            OutlineInputBorder(borderSide: BorderSide(color: Colors.amber)),
        focusedBorder:
            OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
        focusedErrorBorder:
            OutlineInputBorder(borderSide: BorderSide(color: Colors.red)),
      ),
    ),
    home: Home(),
  ));
}

Future<Map> getData() async {
  http.Response response = await http.get(request);
  return json.decode(response.body);
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final realController = TextEditingController();
  final dolarController = TextEditingController();
  final btcController = TextEditingController();
  final euroController = TextEditingController();

  void _clearAll() {
    dolarController.text = "";
    euroController.text = "";
    btcController.text = "";
    realController.text = "";
  }

  String _replaceComma(String text) {
    return text.replaceFirst(",", ".");
  }

  void _realChanged(String text) {
    text = _replaceComma(text);
    realController.text = text;
    try {
      double.parse(realController.text);
    } on Exception catch (_) {
      realController.text =
          realController.text.substring(0, realController.text.length - 1);
    }
    realController.selection = TextSelection.fromPosition(
        TextPosition(offset: realController.text.length));
    if (text == "") {
      _clearAll();
    } else {
      double real = double.parse(text);
      dolarController.text = (real / _dolar).toStringAsFixed(2);
      euroController.text = (real / _euro).toStringAsFixed(2);
      btcController.text = (real / _btc / 1000).toStringAsFixed(8);
    }
  }

  void _dolarChanged(String text) {
    text = _replaceComma(text);
    dolarController.text = text;
    try {
      double.parse(dolarController.text);
    } on Exception catch (_) {
      dolarController.text =
          dolarController.text.substring(0, dolarController.text.length - 1);
    }
    dolarController.selection = TextSelection.fromPosition(
        TextPosition(offset: dolarController.text.length));
    if (text == "") {
      _clearAll();
    } else {
      double dolar = double.parse(text);
      realController.text = (dolar * _dolar).toStringAsFixed(2);
      btcController.text = (dolar * _dolar / _btc / 1000).toStringAsFixed(8);
      euroController.text = ((dolar * _dolar) / _euro).toStringAsFixed(2);
    }
  }

  void _btcChanged(String text) {
    text = _replaceComma(text);
    btcController.text = text;
    try {
      double.parse(btcController.text);
    } on Exception catch (_) {
      btcController.text =
          btcController.text.substring(0, btcController.text.length - 1);
    }
    btcController.selection = TextSelection.fromPosition(
        TextPosition(offset: btcController.text.length));
    if (text == "") {
      _clearAll();
    } else {
      double btc = double.parse(text);
      realController.text = (btc * 1000 * _btc).toStringAsFixed(2);
      euroController.text = (btc * 1000 * _btc / _euro).toStringAsFixed(8);
      dolarController.text = (btc * 1000 * _btc / _dolar).toStringAsFixed(2);
    }
  }

  void _euroChanged(String text) {
    text = _replaceComma(text);
    euroController.text = text;
    try {
      double.parse(euroController.text);
    } on Exception catch (_) {
      euroController.text =
          euroController.text.substring(0, euroController.text.length - 1);
    }

    euroController.selection = TextSelection.fromPosition(
        TextPosition(offset: euroController.text.length));
    if (text == "") {
      _clearAll();
    } else {
      double euro = double.parse(text);
      realController.text = (euro * _euro).toStringAsFixed(2);
      btcController.text = (euro * _euro / _btc / 1000).toStringAsFixed(8);
      dolarController.text = (euro * _euro / _dolar).toStringAsFixed(2);
    }
  }

  double _dolar = 0.0;
  double _euro = 0.0;
  double _btc = 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          'Conversor de moedas',
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.amber,
        centerTitle: true,
      ),
      body: FutureBuilder<Map>(
        future: getData(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Center(
                child: Text(
                  "Carregando dados...",
                  style: TextStyle(color: Colors.white, fontSize: 50),
                  textAlign: TextAlign.center,
                ),
              );
            default:
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    "Erro ao carregar dados...",
                    style: TextStyle(color: Colors.white, fontSize: 50),
                    textAlign: TextAlign.center,
                  ),
                );
              } else {
                Map<String, dynamic> data =
                    jsonDecode(json.encode(snapshot.data));

                _dolar = double.parse(data["USDBRL"]["high"]);
                _euro = double.parse(data["EURBRL"]["high"]);
                _btc = double.parse(data["BTCBRL"]["high"]);

                return SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(10, 20, 10, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Icon(
                        Icons.monetization_on,
                        size: 150,
                        color: Colors.amber,
                      ),
                      buildTextField(
                          "Reais", "R\$", realController, _realChanged),
                      buildTextField(
                          "Bitcoins", "BTC", btcController, _btcChanged),
                      buildTextField(
                          "Dólares", "US\$", dolarController, _dolarChanged),
                      buildTextField(
                          "Euros", "¢", euroController, _euroChanged),
                    ],
                  ),
                );
              }
          }
        },
      ),
    );
  }
}

Widget buildTextField(String label, String prefixText,
    TextEditingController controller, Function func) {
  return Padding(
    padding: EdgeInsets.only(top: 10, bottom: 10),
    child: TextFormField(
      keyboardType: TextInputType.number,
      onChanged: (value) {
        func(value);
      },
      style: TextStyle(color: Colors.amber),
      controller: controller,
      inputFormatters: <TextInputFormatter>[
        // FilteringTextInputFormatter.digitsOnly,
        FilteringTextInputFormatter.allow(RegExp('[0-9.,]')),
      ],
      decoration: InputDecoration(
          labelStyle: TextStyle(color: Colors.amber, fontSize: 20),
          labelText: label,
          prefixText: prefixText + "  "),
    ),
  );
}
