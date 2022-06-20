import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:strollog/layouts/default_layout.dart';
import 'package:strollog/pages/app_page.dart';
import 'package:strollog/pages/map/name_management/name_add_page.dart';

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
        floatingActionButton: OpenContainer(
            transitionType: ContainerTransitionType.fadeThrough,
            transitionDuration: const Duration(milliseconds: 800),
            closedElevation: 2.0,
            closedShape: const CircleBorder(),
            closedBuilder: (context, openContainer) {
              return FloatingActionButton(
                child: const Icon(Icons.add),
                onPressed: () => openContainer(),
              );
            },
            openBuilder: (context, closeContainer) {
              return const NameAdd();
            }));
  }
}
