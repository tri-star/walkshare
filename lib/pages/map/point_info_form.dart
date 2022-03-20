import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:strollog/pages/map/map_page_store.dart';

class PointInfoForm extends StatelessWidget {
  final int _index;

  const PointInfoForm(this._index, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var store = Provider.of<MapPageStore>(context);
    var title = store.mapInfo!.points[_index].title;
    var date = store.mapInfo!.points[_index].date.toIso8601String();

    return Container(
      padding: const EdgeInsets.all(10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(children: [
            const SizedBox(width: 100, child: Text('日付')),
            Text(date),
          ]),
          Row(children: [
            const SizedBox(width: 100, child: Text('タイトル')),
            Text(title),
          ]),
          Row(children: [
            TextButton(onPressed: null, child: Text('編集')),
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('閉じる'))
          ]),
        ],
      ),
    );
  }
}
