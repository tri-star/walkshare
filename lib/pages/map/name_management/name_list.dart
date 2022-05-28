import 'package:flutter/material.dart';
import 'package:strollog/layouts/default_layout.dart';

class NameListPage extends StatefulWidget {
  const NameListPage({Key? key}) : super(key: key);

  @override
  NameListPageState createState() => NameListPageState();
}

class NameListPageState extends State<NameListPage> {
  @override
  Widget build(BuildContext context) {
    return DefaultLayout(Container(child: null),
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () => {Navigator.pop(context)},
        ));
  }
}
