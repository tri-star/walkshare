import 'dart:io';

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:strollog/components/cat_face_placeholder.dart';
import 'package:strollog/domain/face_photo.dart';
import 'package:strollog/domain/name.dart';
import 'package:strollog/layouts/default_layout.dart';
import 'package:strollog/lib/router/router_state.dart';
import 'package:strollog/pages/app_page.dart';
import 'package:strollog/pages/name_management/name_add_page.dart';
import 'package:strollog/pages/name_management/name_list_page_store.dart';
import 'package:strollog/router/app_location.dart';
import 'package:strollog/services/image_loader.dart';

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
          return _buildRow(context, store, name);
        }).toList());
      },
    );
  }

  Widget _buildRow(BuildContext context, NameListPageStore store, Name name) {
    var theme = Theme.of(context);
    return InkWell(
        onTap: () {
          Provider.of<RouterState>(context, listen: false).pushRoute(
              AppLocationNameDetail(mapId: store.mapId, nameId: name.id));
        },
        child: ListTile(
            leading: name.facePhoto != null
                ? _buildFacePhoto(context, name)
                : const CatFacePlaceholder(width: 60),
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

  Widget _buildFacePhoto(BuildContext context, Name name) {
    var imageLoader = ImageLoader(PhotoType.face);
    var store = Provider.of<NameListPageStore>(context, listen: false);

    return FutureBuilder<File>(
      future: imageLoader.loadImageWithCache(
          store.mapInfo!, name.facePhoto!.getFileName()),
      builder: (context, snapshot) {
        if (snapshot.hasError || !snapshot.hasData) {
          return const CatFacePlaceholder(width: 60);
        }
        return Image.file(snapshot.data!, width: 60);
      },
    );
  }
}
