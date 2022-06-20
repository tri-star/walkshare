import 'package:flutter/material.dart';
import 'package:strollog/components/ws_button.dart';
import 'package:strollog/layouts/default_layout.dart';

class NameAdd extends StatefulWidget {
  const NameAdd({Key? key}) : super(key: key);

  @override
  _NameAddState createState() => _NameAddState();
}

class _NameAddState extends State<NameAdd> {
  @override
  Widget build(BuildContext context) {
    return DefaultLayout(Container(
        child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(children: [
              Row(children: const [
                SizedBox(width: 100, child: Text('名前')),
                Expanded(child: TextField()),
              ]),
              Row(children: const [
                SizedBox(width: 100, child: Text('読み')),
                Expanded(
                    child: TextField(
                  keyboardType: TextInputType.emailAddress,
                )),
              ]),
              Row(children: const [
                SizedBox(width: 100, child: Text('建物/場所')),
                Expanded(child: TextField()),
              ]),
              Row(children: const [
                SizedBox(width: 100, child: Text('説明')),
                Expanded(child: TextField()),
              ]),
              Expanded(
                  child: Row(mainAxisSize: MainAxisSize.max, children: [])),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  WSButton(
                      title: '保存', icon: const Icon(Icons.save), onTap: null),
                  WSButton(
                      title: 'キャンセル',
                      icon: const Icon(Icons.cancel),
                      onTap: () => Navigator.of(context).pop()),
                ],
              )
            ]))));
  }
}
