import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:strollog/components/image_thumbnail.dart';
import 'package:strollog/pages/map/map_page_store.dart';
import 'package:strollog/pages/map/point_edit_form.dart';
import 'package:strollog/pages/map/point_edit_form_store.dart';
import 'package:strollog/services/image_loader.dart';

class PointInfoForm extends StatelessWidget {
  final int _index;

  const PointInfoForm(this._index, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var store = Provider.of<MapPageStore>(context);
    var title = store.mapInfo!.points[_index].title;
    var date = store.mapInfo!.points[_index].date.toIso8601String();

    var editFormStore = Provider.of<PointEditFormStore>(context, listen: false);

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
            TextButton(
                onPressed: () {
                  showModalBottomSheet(
                      context: context,
                      builder: (context) {
                        return MultiProvider(providers: [
                          ListenableProvider<PointEditFormStore>.value(
                              value: editFormStore)
                        ], child: PointEditForm(store.mapInfo!, _index));
                      });
                },
                child: Text('編集')),
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
