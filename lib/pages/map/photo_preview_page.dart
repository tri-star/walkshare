import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';
import 'package:strollog/domain/map_info.dart';
import 'package:strollog/domain/photo.dart';
import 'package:strollog/services/image_loader/image_loader.dart';

class PhotoPreviewPage extends StatefulWidget {
  final MapInfo map;
  final List<Photo> photos;
  final int index;

  const PhotoPreviewPage(
      {Key? key, required this.map, required this.photos, required this.index})
      : super(key: key);

  @override
  _PhotoPreviewPageState createState() => _PhotoPreviewPageState();
}

class _PhotoPreviewPageState extends State<PhotoPreviewPage> {
  late int _index;
  late int _photoCount;

  @override
  void initState() {
    super.initState();
    _index = widget.index;
    _photoCount = widget.photos.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('写真プレビュー'),
      ),
      body: Container(
        child: FutureBuilder<_PhotoPreviewData>(
            future: _loadPhoto(),
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return const Center(child: Text("画像のロードに失敗しました"));
              }
              if (!snapshot.hasData) {
                return const Center(child: Text("画像が見つかりません"));
              }
              var draftPhoto = snapshot.data!.photo;
              var cachePath = snapshot.data!.cachePath;
              return Column(children: [
                Expanded(
                    child: GestureDetector(
                  onHorizontalDragEnd: (details) => {
                    if (details.primaryVelocity! > 0)
                      {
                        if (_index > 0) {setState(() => _index--)}
                      }
                    else if (details.primaryVelocity! < 0)
                      {
                        if (_index < _photoCount - 1) {setState(() => _index++)}
                      }
                  },
                  onVerticalDragEnd: (details) {
                    if ((details.primaryVelocity?.abs() ?? 0) > 500) {
                      Navigator.of(context).pop();
                    }
                  },
                  child: PhotoView(
                    imageProvider: FileImage(File(cachePath)),
                    minScale: PhotoViewComputedScale.contained * 0.8,
                    initialScale: PhotoViewComputedScale.contained,
                    basePosition: Alignment.center,
                    backgroundDecoration:
                        const BoxDecoration(color: Colors.black),
                  ),
                )),
                Container(
                  padding: const EdgeInsets.all(8),
                  child: Row(children: [
                    const SizedBox(
                      width: 60,
                      child: Text('名前'),
                    ),
                    Text(draftPhoto.name?.name ?? '名前なし'),
                  ]),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  child: Row(children: [
                    const SizedBox(
                      width: 60,
                      child: Text('登録日'),
                    ),
                    Text(draftPhoto.savedPhoto?.date != null
                        ? DateFormat('yyyy-MM-dd HH:mm')
                            .format(draftPhoto.savedPhoto!.date!)
                        : '-'),
                  ]),
                ),
                Row(children: [
                  Expanded(
                      child: TextButton.icon(
                          onPressed: havePrev()
                              ? () {
                                  setState(() {
                                    _index--;
                                  });
                                }
                              : null,
                          icon: const Icon(Icons.arrow_back),
                          label: const Text("前"))),
                  Expanded(
                      child: TextButton.icon(
                          onPressed: haveNext()
                              ? () {
                                  setState(() {
                                    _index++;
                                  });
                                }
                              : null,
                          icon: const Icon(Icons.arrow_forward),
                          label: const Text("次"))),
                ])
              ]);
            }),
      ),
    );
  }

  bool havePrev() {
    return _index > 0;
  }

  bool haveNext() {
    return _index < (_photoCount - 1);
  }

  Future<_PhotoPreviewData> _loadPhoto() async {
    final draftPhoto =
        DraftPhoto.saved(widget.photos[_index], loadCacheCallback: () async {
      return Provider.of<PhotoImageLoader>(context, listen: false)
          .load(widget.map, widget.photos[_index].getFileName());
    });

    final cachePath = await draftPhoto.getImagePath;

    return _PhotoPreviewData(draftPhoto, cachePath);
  }
}

class _PhotoPreviewData {
  final DraftPhoto photo;
  final String cachePath;

  _PhotoPreviewData(this.photo, this.cachePath);
}
