import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:strollog/components/cat_face_placeholder.dart';
import 'package:strollog/components/image_thumbnail.dart';
import 'package:strollog/components/ws_button.dart';
import 'package:strollog/components/ws_form_label.dart';
import 'package:strollog/domain/map_info.dart';
import 'package:strollog/domain/photo.dart';
import 'package:strollog/domain/position.dart';
import 'package:strollog/layouts/default_layout.dart';
import 'package:strollog/lib/router/router_state.dart';
import 'package:strollog/pages/app_page.dart';
import 'package:strollog/pages/app_store.dart';
import 'package:strollog/pages/map/map_page_store.dart';
import 'package:strollog/pages/map/spot_create_page_store.dart';

class SpotCreatePage extends AppPage {
  @override
  Widget buildPage(BuildContext context) {
    var route = Provider.of<RouterState>(context, listen: false).currentRoute;
    final String mapId = route.parameters['mapId'] ?? '';
    final Position position = Position(double.parse(route.query['x'] ?? '0'),
        double.parse(route.query['y'] ?? '0'));

    return DefaultLayout(mapId == ''
        ? const CircularProgressIndicator()
        : SpotCreateForm(mapId, position));
  }
}

class SpotCreateForm extends StatefulWidget {
  final String mapId;
  final Position position;

  const SpotCreateForm(this.mapId, this.position, {Key? key}) : super(key: key);

  @override
  _SpotCreateFormState createState() => _SpotCreateFormState();
}

class _SpotCreateFormState extends State<SpotCreateForm> {
  late MapInfo _mapInfo;
  late SpotCreatePageStore _store;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _store = Provider.of<SpotCreatePageStore>(context, listen: false);
    _store.initialize();
    _mapInfo =
        Provider.of<AppStore>(context, listen: false).getMapInfo(widget.mapId)!;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Container(
      padding: const EdgeInsets.all(16),
      child: Consumer<SpotCreatePageStore>(
        builder: (context, store, child) {
          return Form(
            key: _formKey,
            onChanged: () {
              store.setInteracted(true);
            },
            autovalidateMode: AutovalidateMode.always,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const SizedBox(height: 20),
                const WsFormLabel(
                  text: 'タイトル',
                  required: true,
                ),
                TextFormField(
                  validator: store.validateTitle,
                  autovalidateMode: AutovalidateMode.always,
                  onSaved: (value) => {store.title = value ?? ''},
                ),
              ]),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const SizedBox(height: 20),
                const WsFormLabel(text: 'コメント'),
                TextFormField(
                  validator: null,
                  autovalidateMode: AutovalidateMode.always,
                  onSaved: (value) => {store.comment = value ?? ''},
                ),
              ]),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const SizedBox(height: 20),
                const WsFormLabel(text: '写真'),
                Center(
                  child: _createImagePreview(),
                ),
              ]),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      WSButton(
                          title: '保存',
                          icon: const Icon(Icons.save),
                          onTap: _canSave()
                              ? () async {
                                  _formKey.currentState!.save();
                                  var spot = await store.save(
                                      _mapInfo, widget.position);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text('スポットを登録しました。')),
                                  );
                                  Provider.of<RouterState>(context,
                                          listen: false)
                                      .popRoute();
                                }
                              : null),
                      WSButton(
                        title: 'キャンセル',
                        icon: const Icon(Icons.cancel),
                        onTap: () =>
                            Provider.of<RouterState>(context, listen: false)
                                .popRoute(),
                      )
                    ],
                  ),
                  Padding(
                      padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).viewInsets.bottom)),
                ],
              )
            ]),
          );
        },
      ),
    ));
  }

  bool _canSave() {
    if (_formKey.currentState == null) {
      return false;
    }
    if (!_store.interacted) {
      return false;
    }
    if (!_formKey.currentState!.validate()) {
      return false;
    }
    if (_store.saving) {
      return false;
    }
    return true;
  }

  Widget _createImagePreview() {
    List<Widget> imageList = _store.photos.map((DraftPhoto draftPhoto) {
      return Card(
          elevation: 2,
          child: Padding(
              padding: const EdgeInsets.all(3),
              child: Column(
                children: [
                  ImageThumbnail(File(draftPhoto.imagePath),
                      width: 100, height: 100,
                      imageLoadingCallBack: (context, child, event) {
                    if (event == null) {
                      return child;
                    }

                    return const SizedBox(
                      width: 75,
                      height: 100,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }, onTapCallBack: () {
                    //openContainer();
                  }),
                  const Padding(
                    padding: EdgeInsets.only(top: 3.0),
                    child: Text('名前なし'),
                  ),
                ],
              )));
    }).toList();

    var addPhotoCard = Card(
        elevation: 2,
        child: Padding(
            padding: const EdgeInsets.all(3),
            child: InkWell(
              child: const CatFacePlaceholder(width: 100, height: 100),
              onTap: () {
                _store.pickImage();
              },
            )));

    return Column(
      children: [
        Wrap(
          spacing: 2,
          children: [...imageList, addPhotoCard],
        )
      ],
    );
  }
}
