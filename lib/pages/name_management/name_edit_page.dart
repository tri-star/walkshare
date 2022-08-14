import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:strollog/components/cat_face_placeholder.dart';
import 'package:strollog/components/ws_button.dart';
import 'package:strollog/components/ws_form_label.dart';
import 'package:strollog/layouts/default_layout.dart';
import 'package:strollog/lib/router/router_state.dart';
import 'package:strollog/pages/app_page.dart';
import 'package:strollog/pages/name_management/name_edit_page_store.dart';
import 'package:strollog/pages/name_management/name_list_page_store.dart';

class NameEditPage extends AppPage {
  NameEditPage() {
    transition = PageTransition.scale;
  }

  @override
  Widget buildPage(BuildContext context) {
    return const NameEdit();
  }
}

class NameEdit extends StatefulWidget {
  const NameEdit({
    Key? key,
  }) : super(key: key);

  @override
  _NameEditState createState() => _NameEditState();
}

class _NameEditState extends State<NameEdit> {
  final _formKey = GlobalKey<FormState>();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    var routerState = Provider.of<RouterState>(context, listen: false);
    var store = Provider.of<NameEditPageStore>(context, listen: false);
    var mapId = routerState.currentRoute.parameters['mapId']!;
    var nameId = routerState.currentRoute.parameters['nameId']!;

    store.initialize(mapId, nameId);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultLayout(
      Consumer<NameEditPageStore>(builder: (context, store, _) {
        return store.loaded
            ? _buildForm(context, store)
            : _buildLoading(context);
      }),
    );
  }

  Widget _buildLoading(BuildContext context) {
    return const CircularProgressIndicator();
  }

  Widget _buildForm(BuildContext context, NameEditPageStore store) {
    return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
            key: _formKey,
            onChanged: () {
              store.setInteracted(true);
            },
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const WsFormLabel(
                  text: '顔写真',
                ),
                Center(
                    child: InkWell(
                        child: store.croppedPhotoPath == null
                            ? const CatFacePlaceholder(width: 80)
                            : _buildPhotoPreview(context, store),
                        onTap: () {
                          store.pickImage();
                        })),
              ]),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const SizedBox(height: 20),
                const WsFormLabel(
                  text: '名前',
                  required: true,
                ),
                TextFormField(
                  initialValue: store.name.name,
                  validator: store.validateName,
                  autovalidateMode: AutovalidateMode.always,
                  onSaved: (value) => {store.name.name = value ?? ''},
                ),
              ]),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const SizedBox(height: 20),
                const WsFormLabel(
                  text: '読み',
                  required: true,
                ),
                TextFormField(
                  initialValue: store.name.pronounce,
                  validator: store.validatePronounce,
                  autovalidateMode: AutovalidateMode.always,
                  onSaved: (value) => {store.name.pronounce = value ?? ''},
                ),
              ]),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const SizedBox(height: 20),
                const WsFormLabel(w: 100, text: '建物/場所'),
                TextFormField(
                  onSaved: (value) => {store.name.place = value ?? ''},
                ),
              ]),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const SizedBox(height: 20),
                const WsFormLabel(text: 'メモ'),
                TextFormField(
                  initialValue: store.name.memo,
                  maxLines: 3,
                  minLines: 3,
                  onSaved: (value) => {store.name.memo = value ?? ''},
                ),
              ]),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  WSButton(
                      title: '保存',
                      icon: const Icon(Icons.save),
                      onTap: _canSave()
                          ? () async {
                              _formKey.currentState!.save();
                              await store.save();
                              Provider.of<NameListPageStore>(context,
                                      listen: false)
                                  .loadList();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('名前を登録しました。')),
                              );
                              Navigator.of(context).pop();
                            }
                          : null),
                  WSButton(
                      title: 'キャンセル',
                      icon: const Icon(Icons.cancel),
                      onTap: () => Navigator.of(context).pop()),
                ],
              ),
            ])));
  }

  Widget _buildPhotoPreview(BuildContext context, NameEditPageStore store) {
    return Image.file(
      File(store.croppedPhotoPath!),
      width: 80,
    );
  }

  bool _canSave() {
    var store = Provider.of<NameEditPageStore>(context, listen: false);

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
}
