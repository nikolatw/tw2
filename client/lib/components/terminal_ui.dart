import 'package:flutter/material.dart';
import 'package:taskwire2/tui/ls.dart';
import 'package:taskwire2/tui/tui.dart';

class TerminalUI extends StatefulWidget {
  const TerminalUI(this.ui, {Key? key}) : super(key: key);

  final UI ui;

  @override
  State<TerminalUI> createState() => _TerminalUIState();
}

class _TerminalUIState extends State<TerminalUI> {
  @override
  Widget build(BuildContext context) {
    final String schema = widget.ui.rawUIData['TaskWireTUISchema'];
    final dynamic tui = widget.ui.rawUIData['TaskWireTUI'];
    if (schema == 'files') {
      return DirOrFile(
        name: ".",
        content: tui,
        expand: true,
        top: true,
      );
    }

    return const Text("do not support tui schema: ");
  }
}
