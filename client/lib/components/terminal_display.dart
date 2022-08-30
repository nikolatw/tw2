import 'package:flutter/material.dart';
import 'package:taskwire2/components/following_output.dart';
import 'package:taskwire2/components/terminal_line.dart';
import 'package:taskwire2/tui/tui.dart';

class TerminalDisplay extends StatelessWidget {
  const TerminalDisplay({
    Key? key,
    required ScrollController scrollController,
    required List<Output> out,
  })  : _scrollController = scrollController,
        _out = out,
        super(key: key);

  final ScrollController _scrollController;
  final List<Output> _out;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(10),
            blurRadius: 1,
          ),
          BoxShadow(
            color: Colors.white.withAlpha(20),
            spreadRadius: -4,
            blurRadius: 4,
          ),
          const BoxShadow(
            color: Colors.black,
            spreadRadius: -3,
            // blurRadius: 1,
          ),
          BoxShadow(
            color: Colors.white.withAlpha(10),
            spreadRadius: -15,
            blurRadius: 1,
          ),
          BoxShadow(
            color: Colors.white.withAlpha(20),
            spreadRadius: -50,
            blurRadius: 100,
          ),
        ],
      ),
      child: OutputFollowingScrollView(
        scrollController: _scrollController,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: _out.map((output) => TerminalLine(output)).toList(),
        ),
      ),
    );
  }
}
