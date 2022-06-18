import 'package:animations/animations.dart';
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
                onPressed: () async {
                  var needReload = await showModalBottomSheet<bool>(
                      context: context,
                      builder: (context) {
                        return MultiProvider(providers: [
                          ListenableProvider<PointEditFormStore>.value(
                              value: editFormStore)
                        ], child: PointEditForm(store.mapInfo!, _spotId));
                      });
                  if (needReload!) {
                    store.reloadSpot(_spotId);
                  }
                },
                child: const Text('編集')),
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('閉じる'))
          ]),
          Row(children: const [SizedBox(height: 30, child: null)]),
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
    final List<Widget> photos = urls.asMap().entries.map((entry) {
      var index = entry.key;
      var url = entry.value;
      return OpenContainer(
          openBuilder: (context, closeContainer) {
            var spotPhotos = store.mapInfo?.spots[_spotId]?.photos;
            return PhotoPreviewPage(
                map: store.mapInfo!, photos: spotPhotos ?? [], index: index);
          },
          closedElevation: 2.0,
          closedShape: ContinuousRectangleBorder(
            borderRadius: BorderRadius.circular(0),
          ),
          closedBuilder: (context, openContainer) {
            return Padding(
                padding: const EdgeInsets.all(3),
                child: ImageThumbnail(url, height: 100,
                    imageLoadingCallBack: (context, child, event) {
                  if (event == null) {
                    return child;
                  }

                  return const SizedBox(
                    width: 75,
                    height: 100,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }, onTapCallBack: () {
                  openContainer();
                }));
          });
    }).toList();
    return Row(children: [
      Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Wrap(
            spacing: 5,
            runSpacing: 5,
            crossAxisAlignment: WrapCrossAlignment.start,
            children: photos)
      ]))
    ]);
  }
}
