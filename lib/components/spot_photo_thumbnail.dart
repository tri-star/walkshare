import 'dart:developer';
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
  String? _imagePath;

  final double? _width;
  final double? _height;
  final OnTapCallBack? _onTapCallBack;

  SpotPhotoThumbnail(this._draftPhoto,
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
    return SizedBox(
      width: widget._width,
      height: widget._height,
      child: VisibilityDetector(
          key: Key(widget._draftPhoto.keyString()),
          onVisibilityChanged: (visibilityInfo) {
            if (visibilityInfo.visibleFraction > 0.1) {
              setState(() {
                _isVisible = true;
              });
            } else {
              setState(() {
                _isVisible = false;
              });
            }
          },
          child: GestureDetector(
            onTap: () {
              widget._onTapCallBack?.call();
            },
            child: imageLoaded()
                ? FutureBuilder<String>(
                    future: widget._draftPhoto.getImagePath,
                    builder: (context, snapshot) {
                      if (widget._imagePath != null) {
                        return _Thumbnail(widget._imagePath!, widget._width!,
                            widget._height!);
                      }
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

                      widget._imagePath = snapshot.data!;
                      return _Thumbnail(
                          widget._imagePath!, widget._width!, widget._height!);
                    })
                : SizedBox(
                    width: widget._width,
                    height: widget._height,
                    child: Container()),
          )),
    );
  }

  bool imageLoaded() {
    return _isVisible || widget._imagePath != null;
  }
}

class _Thumbnail extends StatelessWidget {
  final String _imagePath;
  final double _width;
  final double _height;

  const _Thumbnail(this._imagePath, this._width, this._height, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: _width,
        height: _height,
        child: Image.file(File(_imagePath),
            width: _width, height: _height, fit: BoxFit.cover));
  }
}
