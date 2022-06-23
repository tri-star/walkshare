import 'package:flutter/material.dart';
import 'package:strollog/components/ws_button.dart';
import 'package:strollog/components/ws_form_label.dart';
import 'package:strollog/layouts/default_layout.dart';

class NameAdd extends StatefulWidget {
  const NameAdd({Key? key}) : super(key: key);

  @override
  _NameAddState createState() => _NameAddState();
}

class _NameAddState extends State<NameAdd> {
  @override
  Widget build(BuildContext context) {
    return DefaultLayout(SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
            WsFormLabel(
              text: '名前',
              required: true,
            ),
            TextField(),
          ]),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
            SizedBox(height: 20),
            WsFormLabel(
              text: '読み',
              required: true,
            ),
            TextField(),
          ]),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
            SizedBox(height: 20),
            WsFormLabel(w: 100, text: '建物/場所'),
            TextField(),
          ]),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
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
              WSButton(title: '保存', icon: const Icon(Icons.save), onTap: null),
              WSButton(
                  title: 'キャンセル',
                  icon: const Icon(Icons.cancel),
                  onTap: () => Navigator.of(context).pop()),
            ],
          ),
        ])));
  }
}
