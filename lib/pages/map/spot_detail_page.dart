import 'dart:io';

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:strollog/components/date_time_picker.dart';
import 'package:strollog/components/image_thumbnail.dart';
import 'package:strollog/components/ws_button.dart';
import 'package:strollog/domain/map_info.dart';
import 'package:strollog/domain/photo.dart';
import 'package:strollog/lib/router/router_state.dart';
import 'package:strollog/pages/map/map_page_store.dart';
import 'package:strollog/pages/map/photo_preview_page.dart';
import 'package:strollog/router/app_location.dart';
import 'package:strollog/services/image_loader.dart';

class SpotDetailPage extends StatelessWidget {
  final String _spotId;

  const SpotDetailPage(this._spotId, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var store = Provider.of<MapPageStore>(context);
    var title = store.mapInfo!.spots[_spotId]!.title;
    var comment = store.mapInfo!.spots[_spotId]!.comment;
    var date = store.mapInfo!.spots[_spotId]!.date;
    final dateString = DateFormat('yyyy-MM-dd HH:mm').format(date);

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
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SizedBox(width: 100, child: Text('コメント')),
            Container(
                child: Flexible(
              child: Text(comment),
            ))
          ]),
          Row(children: [
            const SizedBox(width: 100, child: Text('最終訪問日')),
            _buildLastVisited(context, store.mapInfo!.spots[_spotId]!),
          ]),
          FutureBuilder<List<DraftPhoto>>(
            future: _loadImages(context),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return _buildPhotoList(context, snapshot.data!);
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
          const SizedBox(height: 10),
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            WSButton(
                onTap: () {
                  Provider.of<RouterState>(context, listen: false).pushRoute(
                      AppLocationSpotEdit(
                          mapId: store.mapInfo!.id!, spotId: _spotId));
                },
                icon: const Icon(Icons.edit),
                title: '編集'),
            WSButton(
                onTap: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.close),
                title: '閉じる')
          ]),
          Row(children: const [SizedBox(height: 30, child: null)]),
        ],
      ),
    );
  }

  Future<List<DraftPhoto>> _loadImages(BuildContext context) async {
    final store = Provider.of<MapPageStore>(context);
    final imageLoader = Provider.of<ImageLoaderPhoto>(context, listen: false);

    final pendingPhotos =
        store.mapInfo!.spots[_spotId]!.photos.map((photo) async {
      var cacheFile = await imageLoader.loadImageWithCache(
          store.mapInfo!, photo.getFileName());
      return DraftPhoto.saved(photo, cachePath: cacheFile.path);
    }).toList();

    return await Future.wait(pendingPhotos);
  }

  Widget _buildPhotoList(BuildContext context, List<DraftPhoto> draftPhotos) {
    var store = Provider.of<MapPageStore>(context);
    final List<Widget> photos = draftPhotos.asMap().entries.map((entry) {
      var index = entry.key;
      var draftPhoto = entry.value;
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
                child: Column(children: [
                  ImageThumbnail(File(draftPhoto.imagePath),
                      width: 80, height: 80,
                      imageLoadingCallBack: (context, child, event) {
                    if (event == null) {
                      return child;
                    }

                    return const SizedBox(
                      width: 80,
                      height: 80,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }, onTapCallBack: () {
                    openContainer();
                  }),
                  Padding(
                      padding: const EdgeInsets.only(top: 5, bottom: 2),
                      child: Text(draftPhoto.name?.name ?? '名前なし')),
                ]));
          });
    }).toList();
    return Flexible(
        child: SingleChildScrollView(
            child: Row(children: [
      Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Wrap(
            spacing: 5,
            runSpacing: 5,
            crossAxisAlignment: WrapCrossAlignment.start,
            children: photos)
      ]))
    ])));
  }

  Widget _buildLastVisited(BuildContext context, Spot spot) {
    var dateString = spot.lastVisited != null
        ? DateFormat('yyyy-MM-DD HH:mm').format(spot.lastVisited!)
        : '未設定';

    return InkWell(
        child: Container(
            padding: const EdgeInsets.only(top: 8, bottom: 8),
            child: Row(children: [
              Text(dateString),
              const Icon(Icons.update, size: 32),
            ])),
        onTap: () async {
          await DateTimePicker.show(
            context,
            initialDate: spot.lastVisited ?? DateTime.now(),
            firstDate: DateTime(2000, 1, 1),
            lastDate: DateTime.now(),
          );
        });
  }
}
