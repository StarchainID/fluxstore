import 'package:extended_image/extended_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../utils/images.dart';

class FluxImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final Color? color;
  final String? package;

  const FluxImage({
    required this.imageUrl,
    Key? key,
    this.width,
    this.height,
    this.fit,
    this.color,
    this.package,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var imageProxy = '';

    if (imageUrl.isEmpty) {
      return const SizedBox();
    }

    if (!imageUrl.contains('http')) {
      return Image.asset(
        imageUrl,
        width: width,
        height: height,
        fit: fit,
        color: color,
        package: package,
      );
    }

    if (kIsWeb) {
      const resolution = 'q30';
      imageProxy = '$kImageProxy${width}x,$resolution/';
    }

    return ExtendedImage.network(
      '$imageProxy$imageUrl',
      width: width,
      height: height,
      fit: fit,
      color: color,
      loadStateChanged: (state) {
        switch (state.extendedImageLoadState) {
          case LoadState.completed:
            return state.completedWidget;
          case LoadState.loading:
          case LoadState.failed:
          default:
            return const SizedBox();
        }
      },
    );
  }
}
