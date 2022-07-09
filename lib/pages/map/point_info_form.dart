import 'dart:io';

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:strollog/components/image_thumbnail.dart';
import 'package:strollog/lib/router/router_state.dart';
import 'package:strollog/pages/map/map_page_store.dart';
import 'package:strollog/pages/map/photo_preview_page.dart';
import 'package:strollog/pages/map/point_edit_form.dart';
import 'package:strollog/pages/map/point_edit_form_store.dart';
import 'package:strollog/router/app_location.dart';
import 'package:strollog/services/image_loader.dart';

class PointInfoForm extends StatelessWidget {
  final String _spotId;

  const PointInfoForm(this._spotId, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var store = Provider.of<MapPageStore>(context);
    var title = store.mapInfo!.spots[_spotId]!.title;
    var date = store.mapInfo!.spots[_spotId]!.date;
    final dateString = DateFormat('yyyy-MM-dd HH:mm').format(date);

    var editFormStore = Provider.of<PointEditFormStore>(context, listen: false);

    return Container(
      padding: const EdgeInsets.all(10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(children: [
            const SizedBox(width: 100, child: Text('日付')),
            Text(dateString),
          ]),
          Row(children: [
            const SizedBox(width: 100, child: Text('タイトル')),
            Text(title),
          ]),
          FutureBuilder<List<File>>(
            future: _loadImages(context),
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
                  Provider.of<RouterState>(context, listen: false).pushRoute(
                      AppLocationSpotEdit(
                          mapId: store.mapInfo!.id!, spotId: _spotId));
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

  Future<List<File>> _loadImages(BuildContext context) async {
    final store = Provider.of<MapPageStore>(context);
    final imageLoader = Provider.of<ImageLoader>(context, listen: false);

    final pendingImageFile = store.mapInfo!.spots[_spotId]!.photos.map((photo) {
      return imageLoader.loadImageWithCache(
          store.mapInfo!, photo.getFileName());
    }).toList();

    return await Future.wait(pendingImageFile);
  }

  Widget _buildPhotoList(BuildContext context, List<File> imageFiles) {
    var store = Provider.of<MapPageStore>(context);
    final List<Widget> photos = imageFiles.asMap().entries.map((entry) {
      var index = entry.key;
      var imageFile = entry.value;
      return OpenContainer(
          transitionType: ContainerTransitionType.fadeThrough,
          transitionDuration: const Duration(milliseconds: 500),
          openBuilder: (context, closeContainer) {
            var spotPhotos = store.mapInfo?.spots[_spotId]?.photos;
            return PhotoPreviewPage(
                map: store.mapInfo!, photos: spotPhotos ?? [], index: index);
          },
          closedElevation: 2.0,
          closedShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0),
          ),
          closedBuilder: (context, openContainer) {
            return Padding(
                padding: const EdgeInsets.all(3),
                child: ImageThumbnail(imageFile, width: 75, height: 100,
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
