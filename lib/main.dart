import 'dart:ffi';

import 'package:flutter/material.dart';
import 'models/grocery.dart';
import 'models/dbhelper.dart';

void main(List<String> args) {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final textController = TextEditingController();
  int? selectedId;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () async {
            selectedId != null
                ? await DatabaseHelper.instance.update(
                    Grocery(id: selectedId, name: textController.text),
                  )
                : await DatabaseHelper.instance.add(
                    Grocery(name: textController.text),
                  );
            setState(() {
              textController.clear();
              selectedId = null;
            });
          },
        ),
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: TextField(
            decoration: const InputDecoration(
              hintText: 'Add grocery here!',
            ),
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            textAlign: TextAlign.center,
            controller: textController,
          ),
        ),
        body: Center(
          child: FutureBuilder<List<Grocery>>(
              future: DatabaseHelper.instance.getGroceries(),
              builder: (BuildContext context,
                  AsyncSnapshot<List<Grocery>> snapshot) {
                return snapshot.data!.isEmpty
                    ? const Center(
                        child: Text(
                        'No Groceries in this List',
                        style: TextStyle(fontSize: 25),
                      ))
                    : ListView(
                        children: snapshot.data!.map((grocery) {
                          return Center(
                            child: Card(
                              color: selectedId == grocery.id
                                  ? Colors.amber
                                  : Colors.white,
                              child: ListTile(
                                  onTap: () {
                                    if (selectedId == null) {
                                      textController.text = grocery.name;
                                      selectedId = grocery.id;
                                    } else {
                                      textController.text = '';
                                      selectedId = null;
                                    }
                                  },
                                  onLongPress: () {
                                    setState(() {
                                      DatabaseHelper.instance
                                          .remove(grocery.id!);
                                    });
                                  },
                                  dense: true,
                                  title: Text(
                                    grocery.name,
                                    style: const TextStyle(fontSize: 25),
                                  ),
                                  trailing: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                    size: 30,
                                  )),
                            ),
                          );
                        }).toList(),
                      );
              }),
        ),
      ),
    );
  }
}
