import 'package:flutter/material.dart';

class NeoBox extends StatelessWidget {
  const NeoBox({
    Key? key,
    required this.child,
    this.outside = 5,
    this.inside = 4,
  }) : super(key: key);

  final Widget child;
  final double outside;
  final double inside;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4 * outside),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(150)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(10),
            blurRadius: 1,
          ),
          BoxShadow(
            color: Colors.white.withAlpha(20),
            spreadRadius: -4 * outside,
            blurRadius: 4 * outside,
          ),
          BoxShadow(
            color: Colors.black,
            spreadRadius: -3 * outside,
            // blurRadius: 1,
          ),
          BoxShadow(
            color: Colors.white.withAlpha(20),
            spreadRadius: -3 * inside,
            blurRadius: 3 * inside,
          ),
        ],
      ),
      child: child,
    );
  }
}

TextStyle? neoTextStyle(BuildContext context) {
  return Theme.of(context).textTheme.bodyText2?.copyWith(
    color: Colors.white,
    shadows: [
      Shadow(
        color: Colors.white.withAlpha(80),
        offset: const Offset(0, 2),
        blurRadius: 2,
      ),
      Shadow(
        color: Colors.white.withAlpha(40),
        offset: const Offset(0, 1),
        blurRadius: 1,
      ),
    ],
  );
}
