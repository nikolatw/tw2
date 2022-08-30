import 'package:flutter/material.dart';
import 'package:taskwire2/components/colored.dart';
import 'package:taskwire2/components/terminal_ui.dart';
import 'package:taskwire2/tui/text.dart';
import 'package:taskwire2/tui/tui.dart';

class TerminalLine extends StatelessWidget {
  const TerminalLine(
    this.output, {
    Key? key,
  }) : super(key: key);

  final Output output;

  @override
  Widget build(BuildContext context) {
    List<Widget> chunks = [];

    chunks.add(
      Colored(
        out: output.prompt + [FormatedText(output.cmd, TextFormat())],
      ),
    );
    if (output.output != null) {
      chunks.add(Colored(out: output.output!));
    }
    if (output.ui != null) {
      chunks.add(Container(
        padding: const EdgeInsets.all(15),
        child: TerminalUI(output.ui!),
      ));
    }

    return Container(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: chunks,
        ),
      ),
    );
  }
}
