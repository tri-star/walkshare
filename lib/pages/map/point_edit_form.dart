import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:strollog/domain/map_info.dart';
import 'package:strollog/pages/map/point_edit_form_store.dart';

class PointEditForm extends StatefulWidget {
  final MapInfo _mapInfo;
  final int _index;

  const PointEditForm(this._mapInfo, this._index, {Key? key}) : super(key: key);

  @override
  _PointEditFormState createState() => _PointEditFormState(_mapInfo, _index);
}

class _PointEditFormState extends State<PointEditForm> {
  late final TextEditingController _titleController;
  late final TextEditingController _commentController;
  final MapInfo _mapInfo;
  final int _index;
  PointEditFormStore? _store;

  _PointEditFormState(this._mapInfo, this._index);

  @override
  Widget build(BuildContext context) {
    if (_store == null) {
      _store = Provider.of<PointEditFormStore>(context);
      _store!.initByIndex(_mapInfo, _index);
      _titleController = TextEditingController(text: _store!.title);
      _commentController = TextEditingController(text: _store!.comment);
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
                    child: Text('更新')),
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
        ));
  }

  Future<void> _saveForm() async {
    await _store!.save();
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
