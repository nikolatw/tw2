import 'package:taskwire2/tui/text.dart';

class Output {
  final String cmd;
  final List<FormatedText> prompt;
  final List<FormatedText>? output;
  final UI? ui;

  const Output(
    this.cmd,
    this.prompt, {
    this.output,
    this.ui,
  });
}

class UI {
  final dynamic rawUIData;

  const UI(this.rawUIData);
}
