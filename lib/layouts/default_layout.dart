import 'package:flutter/material.dart';
import 'package:strollog/pages/map/name_management/name_list.dart';

class DefaultLayout extends StatelessWidget {
  Widget content;

  DefaultLayout(this.content, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WalkShare'),
      ),
      drawer: _buildDrawer(context),
      body: SafeArea(child: content),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        children: <Widget>[
          const ListTile(
            title: Text('現在表示中のマップ'),
            subtitle: Text('猫'),
          ),
          ListTile(
            title: const Text('名前の管理'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NameListPage(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
