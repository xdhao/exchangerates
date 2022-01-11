import 'package:flutter/material.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;
import 'package:exchangerates/cp1251.dart';
import 'dart:async';

var list;

void main() async{
  list = await parser();
  initState();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
        title: 'Мировые валюты',
        theme: new ThemeData(
        primarySwatch: Colors.blue,
    ),
    home: new MyHomePage());
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

var items = [];

@override
void initState() {
  items.addAll(list);
}

class _MyHomePageState  extends State<MyHomePage> {
  TextEditingController editingController = TextEditingController();

  void filterSearchResults(String query) {
    var dummySearchList = [];
    dummySearchList.addAll(list);
    if(query.isNotEmpty) {
      var dummyListData = [];
      dummySearchList.forEach((item) {
        if(item['CharCode'] == query) {
          dummyListData.add(item);
        }
      });
      setState(() {
        items.clear();
        items.addAll(dummyListData);
      });
      return;
    } else {
      setState(() {
        items.clear();
        items.addAll(list);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primaryColor: Colors.blueGrey),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Мировые валюты'),
          centerTitle: true,
        ),
        body: Container(
          child: Column(
            children: <Widget>[
              Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    onChanged: (value) {
                      filterSearchResults(value);
                    },
                    controller: editingController,
                    decoration:  InputDecoration(
                        labelText: "Search",
                        hintText: "Enter the charcode",
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(25.0)))),
                  ),
              ),
              Expanded(
                child: ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: items.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Card(
                          child: Text('NumCode: ' + items[index]['NumCode']+'\n'
                              +'CharCode: ' + items[index]['CharCode']+'\n'
                              +'Nominal: ' + items[index]['Nominal']+'\n'
                              +'Name: ' + items[index]['Name']+'\n'
                              +'Value: ' + items[index]['Value'], style: TextStyle(fontSize: 18)));
                    }
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<List> parser() async {
  final response = await http.Client()
      .get(Uri.parse('http://www.cbr.ru/scripts/XML_daily.asp'));

  if (response.statusCode == 200) {
    var document = parse(response.body);
    var currencies =
        document.getElementsByTagName("body")[0].children[0].children;
    var map = [];
    for (var prop in currencies) {
      map.add({
        "NumCode" : decodeCp1251(prop.children[0].text),
        "CharCode" :decodeCp1251(prop.children[1].text),
        "Nominal" : decodeCp1251(prop.children[2].text),
        "Name" : decodeCp1251(prop.children[3].text),
        "Value" : decodeCp1251(prop.children[4].text)
      });
    }
    return map;
  } else {
    throw Exception();
  }
}

