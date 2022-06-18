import 'package:flutter/material.dart';
import 'package:strollog/layouts/default_layout.dart';
import 'package:strollog/pages/app_page.dart';

class NameListPage extends AppPage {
  @override
  Widget buildPage(BuildContext context) {
    return const NameList();
  }
}

class NameList extends StatefulWidget {
  const NameList({Key? key}) : super(key: key);

  @override
  NameListState createState() => NameListState();
}

class NameListState extends State<NameList> {
  @override
  Widget build(BuildContext context) {
    return DefaultLayout(Container(child: null),
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () => {Navigator.pop(context)},
        ));
  }
}
