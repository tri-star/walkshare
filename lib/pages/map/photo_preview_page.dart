import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:strollog/domain/map_info.dart';
import 'package:strollog/domain/photo.dart';
import 'package:strollog/services/image_loader.dart';

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
  final ImageLoader _imageLoader = ImageLoader();

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
          child: Column(children: [
        Expanded(
            child: FutureBuilder<String>(
          future:
              _imageLoader.getDownloadUrl(widget.map, widget.photos[_index]),
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
            return PhotoView(
              imageProvider: NetworkImage(snapshot.data!),
              minScale: PhotoViewComputedScale.contained * 0.8,
              initialScale: PhotoViewComputedScale.contained,
              basePosition: Alignment.center,
              backgroundDecoration: const BoxDecoration(color: Colors.black),
            );
          },
        )),
        // Text()
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
      ])),
    );
  }

  bool havePrev() {
    return _index > 0;
  }

  bool haveNext() {
    return _index < (_photoCount - 1);
  }

  // String getPhotoDate(Photo photo, int index) {
  //   return photo.
  // }
}
