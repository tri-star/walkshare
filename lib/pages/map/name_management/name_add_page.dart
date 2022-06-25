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
  late final TextEditingController _nameController;
  late final TextEditingController _pronounceController;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    var routerState = Provider.of<RouterState>(context, listen: false);
    var store = Provider.of<NameAddPageStore>(context, listen: false);
    var mapId = routerState.currentRoute.parameters['mapId']!;

    store.initialize(mapId, () {});
    _nameController = TextEditingController();
    _pronounceController = TextEditingController();
    _nameController.addListener(() => {store.setName(_nameController.text)});
    _pronounceController
        .addListener(() => {store.setPronounce(_pronounceController.text)});
  }

  @override
  void dispose() {
    super.dispose();
    var store = Provider.of<NameAddPageStore>(context, listen: false);
    _nameController.removeListener(() => {store.setName(_nameController.text)});
    _pronounceController
        .removeListener(() => {store.setPronounce(_pronounceController.text)});
  }

  @override
  Widget build(BuildContext context) {
    return DefaultLayout(
      Consumer<NameAddPageStore>(builder: (context, store, _) {
        return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const WsFormLabel(
                  text: '名前',
                  required: true,
                ),
                TextField(controller: _nameController),
              ]),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const SizedBox(height: 20),
                const WsFormLabel(
                  text: '読み',
                  required: true,
                ),
                TextField(controller: _pronounceController),
              ]),
              Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    SizedBox(height: 20),
                    WsFormLabel(w: 100, text: '建物/場所'),
                    TextField(),
                  ]),
              Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    SizedBox(height: 20),
                    WsFormLabel(text: 'メモ'),
                    TextField(
                      minLines: 3,
                      maxLines: 10,
                      keyboardType: TextInputType.multiline,
                    ),
                  ]),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  WSButton(
                      title: '保存',
                      icon: const Icon(Icons.save),
                      onTap: store.canSave
                          ? () {
                              store.save();
                            }
                          : null),
                  WSButton(
                      title: 'キャンセル',
                      icon: const Icon(Icons.cancel),
                      onTap: () => Navigator.of(context).pop()),
                ],
              ),
            ]));
      }),
    );
  }
}
