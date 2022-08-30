import 'package:flutter/material.dart';
import 'package:taskwire2/tui/text.dart';

class Colored extends StatelessWidget {
  const Colored({
    Key? key,
    required List<FormatedText> out,
  })  : _out = out,
        super(key: key);

  final List<FormatedText> _out;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: _out.map(
          (e) {
            List<TextDecoration> decorations = [];
            if (e.form.underline) decorations.add(TextDecoration.underline);
            if (e.form.strikethrough) {
              decorations.add(TextDecoration.lineThrough);
            }
            return TextSpan(
              text: e.text,
              style: Theme.of(context).textTheme.bodyText2!.copyWith(
                    color: e.form.fg,
                    backgroundColor: e.form.bg,
                    fontWeight:
                        e.form.bold ? FontWeight.bold : FontWeight.normal,
                    fontStyle:
                        e.form.italic ? FontStyle.italic : FontStyle.normal,
                    decoration: TextDecoration.combine(decorations),
                  ),
            );
          },
        ).toList(),
      ),
    );
  }
}
