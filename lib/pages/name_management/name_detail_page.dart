import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:strollog/components/cat_face_placeholder.dart';
import 'package:strollog/components/ws_button.dart';
import 'package:strollog/components/ws_form_label.dart';
import 'package:strollog/components/ws_form_value_label.dart';
import 'package:strollog/layouts/default_layout.dart';
import 'package:strollog/lib/router/router_state.dart';
import 'package:strollog/pages/app_page.dart';
import 'package:strollog/pages/name_management/name_detail_page_store.dart';
import 'package:strollog/router/app_location.dart';
import 'package:strollog/services/image_loader.dart';

class NameDetailPage extends AppPage {
  NameDetailPage() {
    transition = PageTransition.scale;
  }

  @override
  Widget buildPage(BuildContext context) {
    return const NameDetail();
  }
}

class NameDetail extends StatefulWidget {
  const NameDetail({Key? key}) : super(key: key);

  @override
  _NameDetailState createState() => _NameDetailState();
}

class _NameDetailState extends State<NameDetail> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    var routerState = Provider.of<RouterState>(context, listen: false);
    var store = Provider.of<NameDetailPageStore>(context, listen: false);
    var mapId = routerState.currentRoute.parameters['mapId']!;
    var nameId = routerState.currentRoute.parameters['nameId']!;

    store.initialize(mapId, nameId);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultLayout(
      Consumer<NameDetailPageStore>(builder: (context, store, _) {
        return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const WsFormLabel(
                  text: '顔写真',
                ),
                Center(
                  child: store.name!.facePhoto != null
                      ? _buildPhotoPreview(context, store)
                      : const CatFacePlaceholder(width: 80),
                ),
              ]),
              Container(
                margin: const EdgeInsets.only(top: 30),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const WsFormLabel(
                        text: '名前',
                      ),
                      WsFormValueLabel(value: store.name!.name),
                    ]),
              ),
              Container(
                margin: const EdgeInsets.only(top: 30),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const WsFormLabel(
                        text: '読み',
                        required: true,
                      ),
                      WsFormValueLabel(value: store.name!.pronounce),
                    ]),
              ),
              Container(
                margin: const EdgeInsets.only(top: 30),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const WsFormLabel(w: 100, text: '建物/場所'),
                      WsFormValueLabel(value: store.name!.place),
                    ]),
              ),
              Container(
                  margin: const EdgeInsets.only(top: 30),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const WsFormLabel(text: 'メモ'),
                        WsFormValueLabel(value: store.name!.memo),
                      ])),
              Container(
                margin: const EdgeInsets.only(top: 30),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    WSButton(
                        title: '編集',
                        icon: const Icon(Icons.edit),
                        onTap: () {
                          Provider.of<RouterState>(context, listen: false)
                              .pushRoute(AppLocationNameEdit(
                                  mapId: store.mapId, nameId: store.name!.id));
                        }),
                    WSButton(
                        title: 'キャンセル',
                        icon: const Icon(Icons.cancel),
                        onTap: () =>
                            Provider.of<RouterState>(context, listen: false)
                                .popRoute()),
                  ],
                ),
              ),
            ]));
      }),
    );
  }

  Widget _buildPhotoPreview(BuildContext context, NameDetailPageStore store) {
    var imageLoader = Provider.of<ImageLoaderFace>(context, listen: false);

    return FutureBuilder<File>(
      future: imageLoader.loadImageWithCache(
          store.mapInfo!, store.name!.facePhoto!.getFileName()),
      builder: (_context, imageFile) {
        if (imageFile.hasError) {
          return const Text('画像のロードに失敗しました。');
        }
        if (!imageFile.hasData) {
          return const CircularProgressIndicator();
        }

        return Image.file(
          imageFile.data!,
          width: 200,
        );
      },
    );
  }
}
