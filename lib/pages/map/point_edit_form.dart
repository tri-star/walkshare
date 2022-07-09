import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:strollog/components/cat_face_placeholder.dart';
import 'package:strollog/components/image_thumbnail.dart';
import 'package:strollog/components/ws_button.dart';
import 'package:strollog/components/ws_form_label.dart';
import 'package:strollog/domain/map_info.dart';
import 'package:strollog/layouts/default_layout.dart';
import 'package:strollog/lib/router/router_state.dart';
import 'package:strollog/pages/app_page.dart';
import 'package:strollog/pages/app_store.dart';
import 'package:strollog/pages/map/point_edit_form_store.dart';

class SpotEditPage extends AppPage {
  @override
  Widget buildPage(BuildContext context) {
    var route = Provider.of<RouterState>(context, listen: false).currentRoute;
    final String mapId = route.parameters['mapId'] ?? '';
    final String spotId = route.parameters['spotId'] ?? '';

    return DefaultLayout(mapId == ''
        ? const CircularProgressIndicator()
        : PointEditForm(mapId, spotId));
  }
}

class PointEditForm extends StatefulWidget {
  final String mapId;
  final String spotId;

  const PointEditForm(this.mapId, this.spotId, {Key? key}) : super(key: key);

  @override
  _PointEditFormState createState() => _PointEditFormState();
}

class _PointEditFormState extends State<PointEditForm> {
  final _formKey = GlobalKey<FormState>();
  late final MapInfo mapInfo;

  @override
  void initState() {
    super.initState();
    var store = Provider.of<PointEditFormStore>(context, listen: false);
    mapInfo =
        Provider.of<AppStore>(context, listen: false).getMapInfo(widget.mapId)!;
    store.init(mapInfo, widget.spotId);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PointEditFormStore>(
      builder: (context, store, child) {
        if (!store.initialized) {
          return const Center(child: CircularProgressIndicator());
        }
        return SingleChildScrollView(
          child: Container(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                onChanged: () {
                  store.setInteracted(true);
                },
                autovalidateMode: AutovalidateMode.always,
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        const WsFormLabel(
                          text: 'タイトル',
                          required: true,
                        ),
                        TextFormField(
                          initialValue: store.title,
                          validator: store.validateTitle,
                          autovalidateMode: AutovalidateMode.always,
                          onSaved: (value) => {store.title = value ?? ''},
                        ),
                      ]),
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        const WsFormLabel(text: 'コメント'),
                        TextFormField(
                          initialValue: store.comment,
                          validator: null,
                          autovalidateMode: AutovalidateMode.always,
                          onSaved: (value) => {store.comment = value ?? ''},
                        ),
                      ]),
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        const WsFormLabel(text: '写真'),
                        Center(
                          child: _createImagePreview(store),
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
                              onTap: _canSave(store)
                                  ? () async {
                                      _formKey.currentState!.save();
                                      var spot = await store.save();
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                            content: Text('スポット情報を更新しました。')),
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
                              bottom:
                                  MediaQuery.of(context).viewInsets.bottom)),
                    ],
                  )
                ]),
              )),
        );
      },
    );
  }

  bool _canSave(PointEditFormStore store) {
    if (_formKey.currentState == null) {
      return false;
    }
    if (!store.interacted) {
      return false;
    }
    if (!_formKey.currentState!.validate()) {
      return false;
    }
    if (store.saving) {
      return false;
    }
    return true;
  }

  Widget _createImagePreview(PointEditFormStore store) {
    List<Widget> imageList = store.photos.map((XFile file) {
      return Card(
          elevation: 2,
          child: Padding(
              padding: const EdgeInsets.all(3),
              child: Column(
                children: [
                  ImageThumbnail(File(file.path), width: 100, height: 100,
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
                store.pickImage();
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
