// Package imports:
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class ImageWidget extends StatelessWidget {
  const ImageWidget({required this.src, this.width, this.height, super.key});

  final String src;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) => CachedNetworkImage(
    imageUrl: src,
    width: width,
    height: height,
    fit: BoxFit.cover,
    placeholder: (_, _) => Shimmer(
      duration: const Duration(seconds: 2),
      interval: const Duration(milliseconds: 350),
      child: const SizedBox(),
    ),
    errorWidget: (_, _, _) => const Icon(Icons.image, size: 18),
  );
}
