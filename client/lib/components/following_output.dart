import 'package:flutter/material.dart';

class OutputFollowingScrollView extends StatelessWidget {
  const OutputFollowingScrollView({
    Key? key,
    required this.scrollController,
    required this.child,
  }) : super(key: key);

  final ScrollController scrollController;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 400),
        curve: Curves.fastOutSlowIn,
      ),
    );

    return SingleChildScrollView(
      controller: scrollController,
      child: child,
    );
  }
}
