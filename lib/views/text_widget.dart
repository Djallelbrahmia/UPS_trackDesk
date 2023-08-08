import 'package:flutter/material.dart';

class TextWidget extends StatelessWidget {
  const TextWidget(
      {super.key,
      required this.text,
      required this.color,
      required this.textsize,
      this.isTitle = false,
      this.maxLine = 10});
  final String text;
  final Color color;
  final double textsize;
  final bool isTitle;
  final int maxLine;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: textsize,
        fontWeight: isTitle ? FontWeight.bold : FontWeight.normal,
        color: color,
        overflow: TextOverflow.ellipsis,
      ),
      maxLines: maxLine,
    );
  }
}
