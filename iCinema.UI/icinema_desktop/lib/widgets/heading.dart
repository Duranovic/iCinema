import 'package:flutter/widgets.dart';

class Heading extends StatelessWidget {
  final String text;
  final TextAlign textAlign;
  final double? fontSize;
  final Color? color;

  const Heading(this.text, {super.key, this.textAlign = TextAlign.left, this.fontSize = 20.0, this.color});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: fontSize,
        color: color,
      ),
    );
  }
}
