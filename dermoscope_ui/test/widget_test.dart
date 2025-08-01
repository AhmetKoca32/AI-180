
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

void main() {
  runApp(
    MaterialApp(
      home: Scaffold(
        body: Center(
          child: Html(
            data:
                "<ol><li><strong>Test Başlık:</strong> Test açıklama</li></ol>",
          ),
        ),
      ),
    ),
  );
}
