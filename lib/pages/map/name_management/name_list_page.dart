import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:strollog/domain/name.dart';
import 'package:strollog/layouts/default_layout.dart';
import 'package:strollog/lib/router/router_state.dart';
import 'package:strollog/pages/app_page.dart';
import 'package:strollog/pages/map/name_management/name_add_page.dart';
import 'package:strollog/pages/map/name_management/name_list_page_store.dart';

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
    return DefaultLayout(Container(child: _buildList(context)),
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

  @override
  void initState() {
    super.initState();

    var routerState = Provider.of<RouterState>(context, listen: false);
    var store = Provider.of<NameListPageStore>(context, listen: false);

    var mapId = routerState.currentRoute.parameters['mapId']!;
    store.initialize(mapId);
  }

  Widget _buildList(BuildContext context) {
    return Consumer<NameListPageStore>(
      builder: (context, store, child) {
        switch (store.loadState) {
          case LoadState.neutral:
            store.loadList();
            return const Center(child: CircularProgressIndicator());
          case LoadState.loading:
            return const Center(child: CircularProgressIndicator());
          default:
        }

        return ListView(
            children: store.names.map((name) {
          return _buildRow(context, name);
        }).toList());
      },
    );
  }

  Widget _buildRow(BuildContext context, Name name) {
    var theme = Theme.of(context);
    return InkWell(
        onTap: () {},
        child: ListTile(
            leading: Container(
                color: Theme.of(context).dividerColor,
                child: SizedBox(
                  child: Center(
                      child: SvgPicture.asset('assets/noface.svg',
                          width: 50, height: 50)),
                  width: 60,
                  height: 60,
                )),
            title: Text(name.name, style: theme.textTheme.headline5),
            subtitle: Column(children: [
              Row(children: [
                const SizedBox(
                  child: Text('登録日'),
                  width: 50,
                ),
                Text(
                  DateFormat('yyyy-MM-dd HH:mm').format(name.created),
                )
              ]),
              Row(children: [
                const SizedBox(
                  child: Text('場所'),
                  width: 50,
                ),
                Text(
                  name.place,
                )
              ]),
            ])));
  }
}
