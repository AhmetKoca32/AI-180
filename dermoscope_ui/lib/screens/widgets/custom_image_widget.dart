import 'dart:io';
import 'package:flutter/material.dart';

class CustomImageWidget extends StatelessWidget {
  final String imageUrl;
  final double width;
  final double height;
  final BoxFit fit;
  const CustomImageWidget({Key? key, required this.imageUrl, required this.width, required this.height, required this.fit}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print('CustomImageWidget imageUrl: ' + imageUrl);
    if (imageUrl.startsWith('http') || imageUrl.startsWith('https')) {
      return Image.network(
        imageUrl,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          return Center(child: Text('Görsel yüklenemedi (network)'));
        },
      );
    } else {
      final file = File(imageUrl);
      print('File exists: ' + file.existsSync().toString());
      return Image.file(
        file,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          return Center(child: Text('Görsel yüklenemedi (dosya)'));
        },
      );
    }
  }
} 