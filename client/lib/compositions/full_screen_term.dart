import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:taskwire2/components/terminal_display.dart';
import 'package:taskwire2/components/terminal_input.dart';
import 'package:taskwire2/style/neomorgh.dart';
import 'package:taskwire2/tui/text.dart';
import 'package:taskwire2/assets/dev_icons.dart';
import 'package:taskwire2/ffi/ffi.dart';
import 'package:taskwire2/tui/tui.dart';

Random random = Random();

class FullscreenTerminal extends StatefulWidget {
  const FullscreenTerminal(
    this.term, {
    Key? key,
  }) : super(key: key);

  final String term;

  @override
  State<FullscreenTerminal> createState() => _FullscreenTerminalState();
}

class _FullscreenTerminalState extends State<FullscreenTerminal> {
  final List<Output> _out = [];
  String _prompt = "";

  final _localTerm = plainCaller('local:term');
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  int _face = 3;

  @override
  void initState() {
    super.initState();

    () async {
      var setTest = _localTerm(
        {'TermID': widget.term, 'Command': ''},
      );

      final prompt = setTest['Output']['Prompt'];

      _prompt = prompt;
    }();
  }

  void wink(int face) {
    Future.delayed(const Duration(milliseconds: 200), () {
      setState(() {
        _face = face;
      });
      Future.delayed(const Duration(milliseconds: 300), () {
        setState(() {
          _face = 3;
        });
      });
    });
  }

  void _runCommand() {
    String command = _controller.text;

    var setTest = _localTerm(
      {'TermID': widget.term, 'Command': command},
    );

    final String result = setTest['Output']['Out'];

    if (result.startsWith('{"TaskWireTUI')) {
      final rawUIData = jsonDecode(result);

      final out = Output(command, parse(_prompt), ui: UI(rawUIData));
      final nextPrompt = setTest['Output']['Prompt'];

      setState(() {
        _out.add(out);
        _prompt = nextPrompt;
      });
    } else {
      final out = Output(command, parse(_prompt), output: parse(result));
      final nextPrompt = setTest['Output']['Prompt'];

      setState(() {
        _out.add(out);
        _prompt = nextPrompt;
      });
      wink(1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: TerminalDisplay(
              scrollController: _scrollController,
              out: _out,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: () {
                  wink(random.nextInt(4));
                },
                child: Stack(
                  children: [
                    NeoBox(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 2),
                        child: Image.asset(
                          [
                            "assets/empty.png",
                            "assets/smile.png",
                            "assets/wink.png",
                            "assets/all.png",
                          ][_face],
                          width: 46,
                          height: 37,
                        ),
                      ),
                    ),
                    Container(
                      decoration: const BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xff29d398),
                            blurRadius: 20,
                            spreadRadius: -35,
                          )
                        ],
                      ),
                      width: 46 + 10 + 40,
                      height: 37 + 4 + 40,
                    )
                  ],
                ),
              ),
              Expanded(
                child: TerminalInput(
                  runCommand: _runCommand,
                  controller: _controller,
                  prompt: _prompt,
                  wink: () => wink(2),
                ),
              ),
              NeoBox(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: TextButton(
                    onPressed: () => _runCommand(),
                    child: DevIcons().terminal(color: Colors.white),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
