import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:strollog/domain/photo.dart';
import 'package:strollog/pages/map/map_page_store.dart';
import 'package:strollog/services/image_loader.dart';

typedef ImageTapCallBack = void Function(int index);
typedef ImageLoadingCallBack = Widget Function(
    BuildContext, Widget, ImageChunkEvent?);
typedef ImageErrorCallBack = Widget Function(BuildContext, Object, StackTrace?);

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
          FutureBuilder<List<String>>(
            future: _loadImageUrls(context),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return _buildPhotoList(context, snapshot.data!);
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
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

  Future<List<String>> _loadImageUrls(BuildContext context) async {
    var store = Provider.of<MapPageStore>(context);
    var imageLoader = Provider.of<ImageLoader>(context, listen: false);

    var pendingUrls = store.mapInfo!.points[_index].photos.map((photo) {
      return imageLoader.getDownloadUrl(store.mapInfo!, photo);
    }).toList();

    return await Future.wait(pendingUrls);
    // return [];
  }

  Widget _buildPhotoList(BuildContext context, List<String> urls) {
    List<Widget> photos = urls.map((url) {
      return ImageThumbnail(url, height: 100);
    }).toList();
    return Row(children: photos);
  }
}

class ImageThumbnail extends StatelessWidget {
  final String _url;

  final double? _width;
  final double? _height;
  final ImageLoadingCallBack? _imageLoadingCallBack;
  final ImageErrorCallBack? _imageErrorCallBack;

  const ImageThumbnail(this._url,
      {Key? key,
      double? width,
      double? height,
      ImageLoadingCallBack? imageLoadingCallBack,
      ImageErrorCallBack? imageErrorCallBack})
      : _width = width,
        _height = height,
        _imageLoadingCallBack = imageLoadingCallBack,
        _imageErrorCallBack = imageErrorCallBack,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    print(_url);
    return GestureDetector(
      onTap: () {},
      child: Image.network(
        _url,
        width: _width,
        height: _height,
        loadingBuilder: _imageLoadingCallBack ??
            (context, child, event) {
              if (event == null) {
                return child;
              }
              return const Center(child: CircularProgressIndicator());
            },
      ),
    );
  }
}
