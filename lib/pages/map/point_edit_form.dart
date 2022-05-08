import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:strollog/domain/map_info.dart';
import 'package:strollog/pages/map/point_edit_form_store.dart';

class PointEditForm extends StatefulWidget {
  final MapInfo _mapInfo;
  final String _spotId;

  const PointEditForm(this._mapInfo, this._spotId, {Key? key})
      : super(key: key);

  @override
  _PointEditFormState createState() => _PointEditFormState(_mapInfo, _spotId);
}

class _PointEditFormState extends State<PointEditForm> {
  bool _initialized = false;
  late final TextEditingController _titleController;
  late final TextEditingController _commentController;
  final MapInfo _mapInfo;
  final String _spotId;
  PointEditFormStore? _store;

  _PointEditFormState(this._mapInfo, this._spotId);

  @override
  Widget build(BuildContext context) {
    _store ??= Provider.of<PointEditFormStore>(context);

    return FutureBuilder<bool>(
        future: _initForm(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
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
                        const Text('タイトル'),
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
                        const Text('コメント'),
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
                        const Text('写真'),
                        IconButton(
                          icon: const Icon(Icons.photo),
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
                          onPressed: _store!.canSave() ? _saveForm : null,
                          child:
                              Text(_store!.saving == true ? '保存中...' : '更新')),
                      TextButton(
                          onPressed: () {
                            Navigator.pop(context, false);
                          },
                          child: const Text('キャンセル')),
                    ],
                  ),
                  Row(children: const [SizedBox(height: 30, child: null)]),
                  Padding(
                      padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).viewInsets.bottom)),
                ],
              ));
        });
  }

  Future<bool> _initForm() async {
    if (_initialized) {
      return true;
    }
    await _store!.initBySpotId(_mapInfo, _spotId);
    _titleController = TextEditingController(text: _store!.title);
    _commentController = TextEditingController(text: _store!.comment);
    _titleController.addListener(() => _store!.setTitle(_titleController.text));
    _commentController
        .addListener(() => _store!.setComment(_commentController.text));
    _initialized = true;
    return true;
  }

  Future<void> _saveForm() async {
    await _store!.save();
    Navigator.pop(context, true);
  }

  Widget _createImagePreview() {
    if (_store!.photos.isEmpty) {
      return Container(child: const Expanded(child: Text('写真を選択')));
    }

    List<Image> imageList = _store!.photos.map((XFile file) {
      return Image.file(File(file.path), height: 50);
    }).toList();

    return Row(
      children: imageList,
    );
  }
}
