import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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
  PointAddFormStore? _store;

  _PointAddFormState(this._mapInfo, this._position);

  @override
  Widget build(BuildContext context) {
    if (_store == null) {
      _store = Provider.of<PointAddFormStore>(context);
      _titleController
          .addListener(() => _store!.setTitle(_titleController.text));
      _commentController
          .addListener(() => _store!.setComment(_commentController.text));
    }

    return Padding(
        padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Text('タイトル'),
                  Expanded(
                      child: TextField(
                    controller: _titleController,
                  )),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Text('コメント'),
                  Expanded(
                      child: TextField(
                    controller: _commentController,
                  )),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Text('写真'),
                  IconButton(
                    icon: Icon(Icons.photo),
                    onPressed: () {
                      _store!.pickImage();
                    },
                  ),
                  _createImagePreview()
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                    onPressed: _store!.isValidInput() ? _saveForm : null,
                    child: Text('登録')),
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('キャンセル')),
              ],
            ),
            Row(children: const [SizedBox(height: 30, child: null)]),
            Padding(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom)),
          ],
        ));
  }

  Future<void> _saveForm() async {
    await _store!.save(_mapInfo, _position);
    Navigator.pop(context);
  }

  Widget _createImagePreview() {
    if (_store!.photos.isEmpty) {
      return Container(child: Expanded(child: Text('写真を選択')));
    }

    List<Image> imageList = _store!.photos.map((XFile file) {
      return Image.file(File(file.path), height: 50);
    }).toList();

    return Row(
      children: imageList,
    );
  }
}
