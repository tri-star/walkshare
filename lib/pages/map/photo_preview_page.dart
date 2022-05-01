import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:strollog/domain/photo.dart';

class PhotoPreviewPage extends StatefulWidget {
  final List<Photo> photos;
  final int index;

  const PhotoPreviewPage({Key? key, this.photos, this.index}) : super(key: key);

  @override
  _PhotoPreviewPageState createState() => _PhotoPreviewPageState();
}

class _PhotoPreviewPageState extends State<PhotoPreviewPage> {
  int _index;

  @override
  void initState() {
    super.initState();
    _index = widget.index ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('写真プレビュー'),
      ),
      body: Center(
        child: PhotoView(
          imageProvider: NetworkImage(widget.photos[_index].url),
          minScale: PhotoViewComputedScale.contained * 0.8,
          maxScale: PhotoViewComputedScale.covered * 1.1,
          initialScale: PhotoViewComputedScale.contained,
          basePosition: Alignment.center,
          backgroundDecoration: BoxDecoration(color: Colors.black),
          onTapUp: (details) {
            Navigator.pop(context);
          },
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          const BottomNavigationBarItem(
            icon: const Icon(Icons.arrow_back),
            label: '戻る',
          ),
          const BottomNavigationBarItem(
            icon: const Icon(Icons.arrow_forward),
            label: '次へ',
          ),
        ],
        currentIndex: _index,
        onTap: (index) {
          setState(() {
            _index = index;
          });
        },
      ),
    );
  }
}
