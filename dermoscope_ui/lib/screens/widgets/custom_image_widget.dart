import 'package:flutter/material.dart';

class CustomImageWidget extends StatelessWidget {
  final String imageUrl;
  final double width;
  final double height;
  final BoxFit fit;
  const CustomImageWidget({Key? key, required this.imageUrl, required this.width, required this.height, required this.fit}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Image.network(imageUrl, width: width, height: height, fit: fit);
  }
} 