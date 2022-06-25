import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:strollog/components/ws_button.dart';
import 'package:strollog/components/ws_form_label.dart';
import 'package:strollog/layouts/default_layout.dart';
import 'package:strollog/lib/router/router_state.dart';
import 'package:strollog/pages/map/name_management/name_add_page_store.dart';

class NameAdd extends StatefulWidget {
  const NameAdd({Key? key}) : super(key: key);

  @override
  _NameAddState createState() => _NameAddState();
}

class _NameAddState extends State<NameAdd> {
  final _formKey = GlobalKey<FormState>();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    var routerState = Provider.of<RouterState>(context, listen: false);
    var store = Provider.of<NameAddPageStore>(context, listen: false);
    var mapId = routerState.currentRoute.parameters['mapId']!;

    store.initialize(mapId);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultLayout(
      Consumer<NameAddPageStore>(builder: (context, store, _) {
        return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
                key: _formKey,
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const WsFormLabel(
                          text: '名前',
                          required: true,
                        ),
                        TextFormField(
                          validator: store.validateName,
                          autovalidateMode: AutovalidateMode.always,
                          onSaved: (value) => {store.name.name = value ?? ''},
                        ),
                      ]),
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        const WsFormLabel(
                          text: '読み',
                          required: true,
                        ),
                        TextFormField(
                          validator: store.validatePronounce,
                          autovalidateMode: AutovalidateMode.always,
                          onSaved: (value) =>
                              {store.name.pronounce = value ?? ''},
                        ),
                      ]),
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        const WsFormLabel(w: 100, text: '建物/場所'),
                        TextFormField(
                          onSaved: (value) =>
                              {store.name.pronounce = value ?? ''},
                        ),
                      ]),
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        const WsFormLabel(text: 'メモ'),
                        TextFormField(
                          maxLines: 3,
                          minLines: 3,
                          onSaved: (value) =>
                              {store.name.pronounce = value ?? ''},
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
                                  await store.save();
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
      }),
    );
  }

  bool _canSave() {
    var store = Provider.of<NameAddPageStore>(context, listen: false);

    if (!(_formKey.currentState?.validate() ?? false)) {
      return false;
    }
    if (store.saving) {
      return false;
    }
    return true;
  }
}
