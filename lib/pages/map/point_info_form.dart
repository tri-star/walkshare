import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:strollog/components/image_thumbnail.dart';
import 'package:strollog/pages/map/map_page_store.dart';
import 'package:strollog/pages/map/photo_preview_page.dart';
import 'package:strollog/pages/map/point_edit_form.dart';
import 'package:strollog/pages/map/point_edit_form_store.dart';
import 'package:strollog/services/image_loader.dart';

class PointInfoForm extends StatelessWidget {
  final String _spotId;

  const PointInfoForm(this._spotId, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var store = Provider.of<MapPageStore>(context);
    var title = store.mapInfo!.spots[_spotId]!.title;
    var date = store.mapInfo!.spots[_spotId]!.date.toIso8601String();

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
                        ], child: PointEditForm(store.mapInfo!, _spotId));
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

    var pendingUrls = store.mapInfo!.spots[_spotId]!.photos.map((photo) {
      return imageLoader.getDownloadUrl(store.mapInfo!, photo);
    }).toList();

    return await Future.wait(pendingUrls);
    // return [];
  }

  Widget _buildPhotoList(BuildContext context, List<String> urls) {
    var store = Provider.of<MapPageStore>(context);
    List<Widget> photos = urls.asMap().entries.map((entry) {
      var index = entry.key;
      var url = entry.value;
      return ImageThumbnail(url, height: 100, onTapCallBack: () {
        var spotPhotos = store.mapInfo?.spots[_spotId]?.photos;
        if (spotPhotos != null) {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => PhotoPreviewPage(
                  map: store.mapInfo!, photos: spotPhotos, index: index)));
        }
      });
    }).toList();
    return Row(children: photos);
  }
}
