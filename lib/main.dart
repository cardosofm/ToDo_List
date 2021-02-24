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
  @override
  void initState() {
    super.initState();
    setState(() {
      _readData().then((data) => _todoList = json.decode(data));
    });
  }

  List _todoList = [];
  Map<String, dynamic> _lastRemoved;
  int _lastRemovedPos;

  final txtTaskController = TextEditingController();

  void _addTodo() {
    setState(() {
      Map<String, dynamic> newToDo = Map();
      newToDo["title"] = txtTaskController.text;
      newToDo["checked"] = false;
      _todoList.add(newToDo);
      _showToast(txtTaskController.text);
      txtTaskController.text = "";
      _saveData();
    });
  }

  void _showToast(String msg) {
    Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.indigo,
        textColor: Colors.white,
        fontSize: 16.0);
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
                      labelText: "Task name",
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
                        _showToast("Empty task cannot be inserted!");
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
            child: ListView.builder(
                padding: EdgeInsets.only(top: 8.0),
                itemCount: _todoList.length,
                itemBuilder: buildItem),
          )
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
      ),
      onDismissed: (direction) {
        setState(() {
          _lastRemoved = Map.from(_todoList[index]);
          _lastRemovedPos = index;
          _todoList.removeAt(index);
          _saveData();
        });
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
