import 'dart:io';

import 'package:flutter/material.dart';
import 'package:strollog/domain/photo.dart';

typedef ImageTapCallBack = void Function(int index);
typedef ImageLoadingCallBack = Widget Function(
    BuildContext, Widget, ImageChunkEvent?);
typedef ImageErrorCallBack = Widget Function(BuildContext, Object, StackTrace?);

typedef OnTapCallBack = void Function();

class SpotPhotoThumbnail extends StatelessWidget {
  final DraftPhoto _draftPhoto;

  final double? _width;
  final double? _height;
  final OnTapCallBack? _onTapCallBack;

  const SpotPhotoThumbnail(this._draftPhoto,
      {Key? key,
      double? width,
      double? height,
      ImageLoadingCallBack? imageLoadingCallBack,
      ImageErrorCallBack? imageErrorCallBack,
      OnTapCallBack? onTapCallBack})
      : _width = width,
        _height = height,
        _onTapCallBack = onTapCallBack,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _onTapCallBack?.call();
      },
      child: FutureBuilder<String>(
          future: _draftPhoto.getImagePath,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return Center(
                  child: SizedBox(
                      width: _width,
                      height: _height,
                      child: const Center(child: CircularProgressIndicator())));
            }
            if (snapshot.hasError) {
              return const Center(child: Text("画像のロードに失敗しました"));
            }
            if (!snapshot.hasData) {
              return const Center(child: Text("画像が見つかりません"));
            }

            return Image.file(File(snapshot.data!),
                width: _width, height: _height, fit: BoxFit.cover);
          }),
    );
  }
}
