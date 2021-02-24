import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:fluttertoast/fluttertoast.dart';

void main() {
  runApp(MaterialApp(home: Home()));
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {


  List _todoList = [];
  Map<String, dynamic> _lastRemoved;

  //override para trazer os itens quando o app for aberto
  @override
  void initState() {
    super.initState();
    _readData().then((data) {
      setState(() {
        _todoList = json.decode(data);
      });
    });
  }

  int _lastRemovedPos;

  final txtTaskController = TextEditingController();

  void _addTodo() {
    setState(() {
      Map<String, dynamic> newToDo = Map();
      newToDo["title"] = txtTaskController.text;
      newToDo["checked"] = false;
      _todoList.add(newToDo);
      _showToastBlue("${txtTaskController.text} has been added");
      txtTaskController.text = "";
      _saveData();
    });
  }

//Toast para mensagens
  void _showToastBlue(String msg) {
    Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.blue,
        textColor: Colors.white,
        fontSize: 16.0);
  }

//Toast para warnings
  void _showToastRed(String msg) {
    Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  //função para ordenar os itens da lista
  Future<Null> _refreshList() async {
    await Future.delayed(Duration(seconds: 1));
    // fazendo ordenação usando uma função de comparação passando dois argumentos
    // esse comando percorre a lista executando a função de checagem que
    // será retornado 1 se A>B, 0 se A=B, -1 se A<B
    // lembrando que A e B serão listas
    setState(() {
      _todoList.sort((a, b) {
        if (a["checked"] && !b["checked"])
          return 1;
        else if (!a["checked"] && b["checked"])
          return -1;
        else
          return 0;
      });
      _saveData();
    });
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("ToDo List"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: txtTaskController,
                    decoration: InputDecoration(
                      labelStyle: TextStyle(color: Colors.blue),
                      labelText: "Task",
                      helperText: "Insert a new task",
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: RaisedButton(
                    textColor: Colors.white,
                    child: Text("Add"),
                    color: Colors.blue,
                    onPressed: () {
                      if (txtTaskController.text.trim() == "") {
                        _showToastRed("Empty task cannot be inserted!");
                      } else {
                        _addTodo();
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              // função para ordenar os itens da lista
              onRefresh: _refreshList,
              child: ListView.builder(
                  padding: EdgeInsets.only(top: 8.0),
                  itemCount: _todoList.length,
                  itemBuilder: buildItem),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildItem(BuildContext context, int index) {
    return Dismissible(
      key: Key(DateTime.now().millisecondsSinceEpoch.toString()),
      background: Container(
        color: Colors.red,
        child: Align(
          alignment: Alignment(-0.9, 0.0),
          child: Icon(
            Icons.delete_outline,
            color: Colors.white,
          ),
        ),
      ),
      direction: DismissDirection.startToEnd,
      child: CheckboxListTile(
        title: Text(_todoList[index]["title"] ?? "No Data"),
        value: _todoList[index]["checked"],
        secondary: CircleAvatar(
          child: Icon(_todoList[index]["checked"] ? Icons.check : Icons.error),
        ),
        onChanged: (c) {
          setState(() {
            _todoList[index]["checked"] = c;
            _saveData();
          });
        },
      ),
      onDismissed: (direction) {
        setState(
          () {
            _lastRemoved = Map.from(_todoList[index]);
            _lastRemovedPos = index;
            _todoList.removeAt(index);
            _saveData();

            final snack = SnackBar(
              content: Text("${_lastRemoved["title"]} has been removed"),
              action: SnackBarAction(
                label: "Desmiss",
                onPressed: () {
                  setState(() {
                    // retornando o elemento de volta a lista no mesmo lugar
                    _todoList.insert(_lastRemovedPos, _lastRemoved);
                    _saveData();
                  });
                },
              ),
              // configurando a duração do snack bar
              duration: Duration(seconds: 5),
            );
            // removendo a snack bar anterior para não criar uma pilha de snackbar
            Scaffold.of(context).removeCurrentSnackBar();
            // chamando a snack bar
            Scaffold.of(context).showSnackBar(snack);
          },
        );
      },
    );
  }

  /*CheckboxListTile(
      title: Text(_todoList[index]["title"]),
      value: _todoList[index]["checked"],
      secondary: CircleAvatar(
        child: Icon(_todoList[index]["checked"] ? Icons.check : Icons.error),
      ),
      onChanged: (c) {
        setState(() {
          _todoList[index]["checked"] = c;
          _saveData();
        });
      },
    );*/

  Future<File> _getFile() async {
    var _appDocumentsDirectory = await getApplicationDocumentsDirectory();
    return File("${_appDocumentsDirectory.path}/data.json");
  }

  Future<File> _saveData() async {
    String data = json.encode(_todoList);
    final file = await _getFile();
    return file.writeAsString(data);
  }

  Future<String> _readData() async {
    try {
      final file = await _getFile();
      return file.readAsString();
    } catch (e) {
      return null;
    }
  }
}
