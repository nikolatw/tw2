import 'package:flutter/material.dart';
import 'package:taskwire2/components/colored.dart';
import 'package:taskwire2/ffi/ffi.dart';
import 'package:taskwire2/style/neomorgh.dart';
import 'package:taskwire2/tui/text.dart';

class TerminalInput extends StatefulWidget {
  const TerminalInput({
    Key? key,
    required this.runCommand,
    required this.controller,
    required this.prompt,
    required this.wink,
  }) : super(key: key);

  final Function() runCommand;
  final TextEditingController controller;
  final String prompt;
  final Function() wink;

  @override
  State<TerminalInput> createState() => _TerminalInputState();
}

class _TerminalInputState extends State<TerminalInput> {
  final _completer = plainCaller('local:complete');
  List<String> _suggestions = [];
  FocusNode focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        children: [
          _suggestions.isNotEmpty
              ? Row(
                  children: _suggestions.map((e) {
                    return NeoBox(
                      outside: 2,
                      inside: 2.5,
                      child: TextButton(
                        child: Text(
                          e,
                          style: neoTextStyle(context),
                        ),
                        onPressed: () {
                          widget.controller.text = e;
                          FocusScope.of(context).requestFocus(focusNode);
                          _onChange(e);
                          widget.wink();
                        },
                      ),
                    );
                  }).toList(),
                )
              : SizedBox(
                  height: 16.0 + 18 + (neoTextStyle(context)?.fontSize ?? 0),
                ),
          const SizedBox(
            height: 5,
          ),
          NeoBox(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Colored(out: parse(widget.prompt)),
                  ),
                  Expanded(
                    child: TextField(
                      onSubmitted: _onSubmit,
                      onChanged: _onChange,
                      controller: widget.controller,
                      focusNode: focusNode,
                      style: neoTextStyle(context),
                      decoration: const InputDecoration(
                        isDense: true,
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  _onSubmit(_) => widget.runCommand();

  _onChange(value) {
    List<String> suggestions = [];

    if (value != "") {
      var complete = _completer({
        "TermID": "",
        "Command": value,
      });
      var findings = complete['Output']['Suggestions'] as List<dynamic>;
      if (findings.length > 4) {
        findings = findings.sublist(0, 4);
      }
      suggestions = findings
          .where((e) => e != "")
          .where((e) => e != widget.controller.text)
          .map((e) {
        var s = e as String;
        return s;
      }).toList();
    }

    setState(() {
      _suggestions = suggestions;
    });
  }
}
