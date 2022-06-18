import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:strollog/lib/router/router_state.dart';
import 'package:strollog/pages/map/name_management/name_list_page.dart';
import 'package:strollog/router/app_location.dart';

class DefaultLayout extends StatelessWidget {
  final Widget _content;
  final Widget? _floatingActionButton;

  const DefaultLayout(Widget child, {Widget? floatingActionButton, Key? key})
      : _content = child,
        _floatingActionButton = floatingActionButton,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WalkShare'),
      ),
      drawer: _buildDrawer(context),
      body: SafeArea(child: _content),
      floatingActionButton: _floatingActionButton,
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
              Provider.of<RouterState>(context, listen: false).pushRoute(
                  // TODO: 現在選択中のマップのIDを渡す必要がある
                  AppLocationNameManagement(mapId: 'xxxx'));
            },
          ),
        ],
      ),
    );
  }
}
