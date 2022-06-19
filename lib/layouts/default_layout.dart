import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:strollog/lib/router/router_state.dart';
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
        bottomNavigationBar: _buildBottomAppBar(context),
        body: SafeArea(child: _content),
        floatingActionButton: _floatingActionButton,
        floatingActionButtonLocation:
            FloatingActionButtonLocation.centerDocked);
  }

  Widget _buildBottomAppBar(BuildContext context) {
    return BottomAppBar(
      elevation: 2,
      shape: const CircularNotchedRectangle(),
      notchMargin: 6,
      color: Theme.of(context).primaryColor,
      child: Container(
          padding: const EdgeInsets.all(16),
          height: kToolbarHeight,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              InkWell(
                  borderRadius: const BorderRadius.all(Radius.circular(16)),
                  onTap: () {
                    showBottomDrawer(context);
                  },
                  child: Row(children: [
                    Icon(Icons.menu,
                        color: Theme.of(context).colorScheme.onPrimary),
                    Text('メニュー',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary)),
                  ]))
            ],
          )),
    );
  }

  void showBottomDrawer(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(mainAxisSize: MainAxisSize.min, children: [
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
          const SizedBox(
            height: kBottomNavigationBarHeight,
          ),
        ]);
      },
    );
  }
}
