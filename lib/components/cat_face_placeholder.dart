import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CatFacePlaceholder extends StatelessWidget {
  final double? width;
  final double? height;

  const CatFacePlaceholder({Key? key, this.width, this.height})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Theme.of(context).dividerColor,
        child: SizedBox(
          child: Center(
              child: SvgPicture.asset('assets/noface.svg',
                  width: width != null ? width! - 10 : null,
                  height: height != null ? height! - 10 : null)),
          width: width,
          height: width,
        ));
  }
}
