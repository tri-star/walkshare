import 'dart:io';

import 'package:flutter/material.dart';
import 'package:strollog/domain/photo.dart';
import 'package:visibility_detector/visibility_detector.dart';

typedef ImageTapCallBack = void Function(int index);
typedef ImageLoadingCallBack = Widget Function(
    BuildContext, Widget, ImageChunkEvent?);
typedef ImageErrorCallBack = Widget Function(BuildContext, Object, StackTrace?);

typedef OnTapCallBack = void Function();

class SpotPhotoThumbnail extends StatefulWidget {
  final DraftPhoto _draftPhoto;

  final double? _width;
  final double? _height;
  final OnTapCallBack? _onTapCallBack;

  const SpotPhotoThumbnail(this._draftPhoto,
      {Key? key, double? width, double? height, OnTapCallBack? onTapCallBack})
      : _width = width,
        _height = height,
        _onTapCallBack = onTapCallBack,
        super(key: key);

  @override
  _SpotPhotoThumbnailState createState() => _SpotPhotoThumbnailState();
}

class _SpotPhotoThumbnailState extends State<SpotPhotoThumbnail> {
  bool _isVisible = false;

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key(widget._draftPhoto.hashCode.toString()),
      onVisibilityChanged: (visibilityInfo) {
        if (visibilityInfo.visibleFraction > 0.2) {
          setState(() {
            _isVisible = true;
          });
        } else {
          setState(() {
            _isVisible = false;
          });
        }
      },
      child: SizedBox(
          width: widget._width,
          height: widget._height,
          child: GestureDetector(
            onTap: () {
              widget._onTapCallBack?.call();
            },
            child: _isVisible
                ? FutureBuilder<String>(
                    future: widget._draftPhoto.getImagePath,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState != ConnectionState.done) {
                        return Center(
                            child: SizedBox(
                                width: widget._width,
                                height: widget._height,
                                child: const Center(
                                    child: CircularProgressIndicator())));
                      }
                      if (snapshot.hasError) {
                        return const Center(child: Text("画像のロードに失敗しました"));
                      }
                      if (!snapshot.hasData) {
                        return const Center(child: Text("画像が見つかりません"));
                      }

                      return SizedBox(
                          width: widget._width,
                          height: widget._height,
                          child: Image.file(File(snapshot.data!),
                              width: widget._width,
                              height: widget._height,
                              fit: BoxFit.cover));
                    },
                  )
                : SizedBox(
                    width: widget._width,
                    height: widget._height,
                    child: const Center(child: CircularProgressIndicator())),
          )),
    );
  }
}
