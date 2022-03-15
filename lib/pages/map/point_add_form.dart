import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:strollog/domain/map_info.dart';
import 'package:strollog/domain/position.dart';
import 'package:strollog/pages/map/point_add_form_store.dart';

class PointAddForm extends StatefulWidget {
  final MapInfo _mapInfo;
  final Position _position;

  const PointAddForm(this._mapInfo, this._position, {Key? key})
      : super(key: key);

  @override
  _PointAddFormState createState() => _PointAddFormState(_mapInfo, _position);
}

class _PointAddFormState extends State<PointAddForm> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();
  final MapInfo _mapInfo;
  final Position _position;
  PointAddFormStore? _state;

  _PointAddFormState(this._mapInfo, this._position);

  @override
  Widget build(BuildContext context) {
    if (_state == null) {
      _state = Provider.of<PointAddFormStore>(context);
      _titleController
          .addListener(() => _state!.setTitle(_titleController.text));
      _commentController
          .addListener(() => _state!.setComment(_commentController.text));
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Text('タイトル'),
            Expanded(
                child: TextField(
              controller: _titleController,
            )),
          ],
        ),
        Row(
          children: [
            Text('コメント'),
            Expanded(
                child: TextField(
              controller: _commentController,
            )),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton(
                onPressed: _state!.isValidInput() ? _saveForm : null,
                child: Text('登録')),
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('キャンセル')),
          ],
        ),
        Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom)),
      ],
    );
  }

  Future<void> _saveForm() async {
    await _state!.save(_mapInfo, _position);
    Navigator.pop(context);
  }
}
