import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:core';
import 'dart:async';
import "dart:convert";

void main() {
  runApp(MaterialApp(
    home: Home(),
  ));
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List _toDoList = [];

  final _toDoController = TextEditingController();
  Map<String, dynamic> _lastRemoved = {};
  int _lastRemovedPos = 0;

  @override
  void initState() {
    super.initState();

    _readData().then((data) {
      setState(() {
        _toDoList = json.decode(data);
      });
    });
  }

  void _addToDo() {
    setState(() {
      Map<String, dynamic> newToDo = Map();
      newToDo["title"] = _toDoController.text;
      _toDoController.text = "";
      newToDo["ok"] = false;
      _toDoList.add(newToDo);
      _saveData();
    });
  }

  Future<Null> _refresh() async {
    await Future.delayed(Duration(seconds: 1));

    setState(() {
      _toDoList.sort((a, b) {
        if (a["ok"] && !b["ok"]) {
          return 1;
        } else if (!a["ok"] && b["ok"]) {
          return -1;
        } else
          return 0;
      });
    });

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Lista de Tarefas"),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body:
          // SingleChildScrollView(
          //   child:
          Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.fromLTRB(17, 5, 7, 1),
            child: Row(
              children: <Widget>[
                Expanded(
                    flex: 2,
                    child: TextField(
                      controller: _toDoController,
                      decoration: InputDecoration(
                          labelText: "Nova tarefa",
                          labelStyle: TextStyle(color: Colors.blueAccent)),
                    )),
                Container(
                  padding: EdgeInsets.only(left: 10),
                  height: 60,
                  child: ElevatedButton(
                      onPressed: _addToDo,
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all<Color>(Colors.blueAccent),
                        shape: MaterialStateProperty.all<CircleBorder>(
                          CircleBorder(
                            // borderRadius: BorderRadius.circular(40.0),
                            side: BorderSide(color: Colors.transparent),
                          ),
                        ),
                      ),
                      child: const Icon(Icons.add) //(
                      // 'Add',
                      // style: TextStyle(color: Colors.white, fontSize: 30),
                      ),
                ),
              ],
            ),
          ),
          Expanded(
              child: RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.builder(
              padding: EdgeInsets.only(top: 10),
              itemCount: _toDoList.length,
              itemBuilder: buildItem,
            ),
          )),
        ],
      ),
      // ),
    );
  }

  Widget buildItem(context, index) {
    return Dismissible(
        onDismissed: (direction) {
          setState(() {
            _lastRemoved = Map.from(_toDoList[index]);
            _lastRemovedPos = index;
            _toDoList.removeAt(index);

            _saveData();

            final snack = SnackBar(
                content: Text("Tarefa '${_lastRemoved["title"]}' removida"),
                duration: Duration(seconds: 2),
                action: SnackBarAction(
                    label: "Desfazer",
                    onPressed: () {
                      setState(() {
                        _toDoList.insert(_lastRemovedPos, _lastRemoved);
                        _saveData();
                      });
                    }));

            ScaffoldMessenger.of(context).showSnackBar(snack);
          });
        },
        key: Key(DateTime.now().millisecondsSinceEpoch.toString()),
        direction: DismissDirection.startToEnd,
        child: CheckboxListTile(
          title: Text(_toDoList[index]["title"]),
          value: _toDoList[index]["ok"],
          onChanged: (bool? value) {
            setState(() {
              _toDoList[index]["ok"] = value;
              _saveData();
            });
          },
          secondary: CircleAvatar(
            child: Icon(_toDoList[index]["ok"] ? Icons.check : Icons.error),
          ),
        ),
        background: Container(
            color: Colors.red,
            child: Align(
              alignment: Alignment(-0.09, 0.0),
              child: Icon(Icons.delete, color: Colors.white),
            )));
  }

  Future<File> _getFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File("${directory.path}/data.json");
  }

  Future<File> _saveData() async {
    String data = json.encode(_toDoList);
    final file = await _getFile();
    return file.writeAsString(data);
  }

  Future<String> _readData() async {
    try {
      final file = await _getFile();
      return file.readAsString();
    } catch (e) {
      return "";
    }
  }
}
