import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TextFormat {
  Color? fg;
  Color? bg;
  bool bold = false;
  bool faint = false;
  bool italic = false;
  bool underline = false;
  bool blink = false;
  bool inverse = false;
  bool invisible = false;
  bool strikethrough = false;

  TextFormat();
}

class FormatedText {
  final String text;
  final TextFormat form;

  const FormatedText(this.text, this.form);
}

final exp = RegExp(r"\x1B\[((\d+)m|(\d+;\d+)m|(\d+;\d+;\d+)m|m)");

List<FormatedText> parse(String text) {
  TextFormat form = TextFormat();
  List<FormatedText> formatted = [];
  int offset = 0;

  Iterable<RegExpMatch> matches = exp.allMatches(text);
  for (var match in matches) {
    formatted.add(FormatedText(text.substring(offset, match.start), form));
    final colorData = match.group(2) ?? match.group(3) ?? match.group(4) ?? "0";
    final codes = colorData.split(';').map((code) => int.parse(code));
    form = textFormat(codes.toList());
    offset = match.end;
  }

  formatted.add(FormatedText(text.substring(offset), form));

  return formatted;
}

TextFormat textFormat(List<int> codes) {
  TextFormat form = TextFormat();

  for (var i = 0; i < codes.length; i++) {
    final code = codes[i];
    switch (code) {
      case 1:
        form.bold = true;
        break;
      case 2:
        form.faint = true;
        break;
      case 3:
        form.italic = true;
        break;
      case 4:
        form.underline = true;
        break;
      case 5:
        form.blink = true;
        break;
      case 7:
        form.inverse = true;
        break;
      case 8:
        form.invisible = true;
        break;
      case 9:
        form.strikethrough = true;
        break;

      case 21:
        form.bold = false;
        break;
      case 22:
        form.faint = false;
        break;
      case 23:
        form.italic = false;
        break;
      case 24:
        form.underline = false;
        break;
      case 25:
        form.blink = false;
        break;
      case 27:
        form.inverse = false;
        break;
      case 28:
        form.invisible = false;
        break;
      case 29:
        form.strikethrough = false;
        break;
      case 39:
        form.fg = _colors[7];
        break;
      case 30:
        form.fg = _colors[0];
        break;
      case 31:
        form.fg = _colors[9];
        break;
      case 32:
        form.fg = _colors[10];
        break;
      case 33:
        form.fg = _colors[11];
        break;
      case 34:
        form.fg = _colors[12];
        break;
      case 35:
        form.fg = _colors[13];
        break;
      case 36:
        form.fg = _colors[14];
        break;
      case 37:
        form.fg = _colors[15];
        break;

      case 38:
        final cof = _parseAnsiColour(codes, i);
        if (cof.c != null) {
          form.fg = cof.c;
        }
        i += cof.o;
        break;
      case 48:
        final cof = _parseAnsiColour(codes, i);
        if (cof.c != null) {
          form.bg = cof.c;
        }
        i += cof.o;
        break;

      case 49:
        form.bg = _colors[0];
        break;
      case 40:
        form.bg = _colors[0];
        break;
      case 41:
        form.bg = _colors[1];
        break;
      case 42:
        form.bg = _colors[2];
        break;
      case 43:
        form.bg = _colors[3];
        break;
      case 44:
        form.bg = _colors[4];
        break;
      case 45:
        form.bg = _colors[5];
        break;
      case 46:
        form.bg = _colors[6];
        break;
      case 47:
        form.bg = _colors[7];
        break;

      case 90:
        form.fg = _colors[8];
        break;
      case 91:
        form.fg = _colors[1];
        break;
      case 92:
        form.fg = _colors[2];
        break;
      case 93:
        form.fg = _colors[3];
        break;
      case 94:
        form.fg = _colors[4];
        break;
      case 95:
        form.fg = _colors[5];
        break;
      case 96:
        form.fg = _colors[6];
        break;
      case 97:
        form.fg = _colors[7];
        break;

      case 100:
        form.bg = _colors[8];
        break;
      case 101:
        form.bg = _colors[9];
        break;
      case 102:
        form.bg = _colors[10];
        break;
      case 103:
        form.bg = _colors[11];
        break;
      case 104:
        form.bg = _colors[12];
        break;
      case 105:
        form.bg = _colors[13];
        break;
      case 106:
        form.bg = _colors[14];
        break;
      case 107:
        form.bg = _colors[15];
        break;
    }
  }

  return form;
}

class _ColorAndOffset {
  final Color? c;
  final int o;

  const _ColorAndOffset(this.c, this.o);
}

_ColorAndOffset _parseAnsiColour(List<int> codes, int offset) {
  final length = codes.length - offset;

  if (length > 2) {
    switch (codes[offset + 1]) {
      case 5:
        // 8 bit colour
        final colNum = codes[offset + 2];

        if (colNum >= 256 || colNum < 0) {
          return const _ColorAndOffset(null, 2);
        }

        return _ColorAndOffset(_colors[colNum], 2);

      case 2:
        if (length < 4) {
          return const _ColorAndOffset(null, 0);
        }

        // 24 bit colour
        if (length == 5) {
          final r = codes[offset + 2];
          final g = codes[offset + 3];
          final b = codes[offset + 4];
          return _ColorAndOffset(Color.fromARGB(0xff, r, g, b), 4);
        }

        if (length > 5) {
          // ISO/IEC International Standard 8613-6
          final r = codes[offset + 3];
          final g = codes[offset + 4];
          final b = codes[offset + 5];
          return _ColorAndOffset(Color.fromARGB(0xff, r, g, b), 5);
        }
    }
  }

  return const _ColorAndOffset(null, 0);
}

double colorDistance(Color a, Color b) {
  return sqrt(pow(a.red - b.red, 2) +
      pow(a.green - b.green, 2) +
      pow(a.blue - b.blue, 2));
}

List<Color> _gruvbox = [
  const Color.fromARGB(255, 255, 235, 238),
  const Color.fromARGB(255, 255, 205, 210),
  const Color.fromARGB(255, 239, 154, 154),
  const Color.fromARGB(255, 229, 115, 115),
  const Color.fromARGB(255, 239, 83, 80),
  const Color.fromARGB(255, 244, 67, 54),
  const Color.fromARGB(255, 229, 57, 53),
  const Color.fromARGB(255, 211, 47, 47),
  const Color.fromARGB(255, 198, 40, 40),
  const Color.fromARGB(255, 183, 28, 28),
  const Color.fromARGB(255, 255, 138, 128),
  const Color.fromARGB(255, 255, 82, 82),
  const Color.fromARGB(255, 255, 23, 68),
  const Color.fromARGB(255, 213, 0, 0),
  const Color.fromARGB(255, 252, 228, 236),
  const Color.fromARGB(255, 248, 187, 208),
  const Color.fromARGB(255, 244, 143, 177),
  const Color.fromARGB(255, 240, 98, 146),
  const Color.fromARGB(255, 236, 64, 122),
  const Color.fromARGB(255, 233, 30, 99),
  const Color.fromARGB(255, 216, 27, 96),
  const Color.fromARGB(255, 194, 24, 91),
  const Color.fromARGB(255, 173, 20, 87),
  const Color.fromARGB(255, 136, 14, 79),
  const Color.fromARGB(255, 255, 128, 171),
  const Color.fromARGB(255, 255, 64, 129),
  const Color.fromARGB(255, 245, 0, 87),
  const Color.fromARGB(255, 197, 17, 98),
  const Color.fromARGB(255, 243, 229, 245),
  const Color.fromARGB(255, 225, 190, 231),
  const Color.fromARGB(255, 206, 147, 216),
  const Color.fromARGB(255, 186, 104, 200),
  const Color.fromARGB(255, 171, 71, 188),
  const Color.fromARGB(255, 156, 39, 176),
  const Color.fromARGB(255, 142, 36, 170),
  const Color.fromARGB(255, 123, 31, 162),
  const Color.fromARGB(255, 106, 27, 154),
  const Color.fromARGB(255, 74, 20, 140),
  const Color.fromARGB(255, 234, 128, 252),
  const Color.fromARGB(255, 224, 64, 251),
  const Color.fromARGB(255, 213, 0, 249),
  const Color.fromARGB(255, 170, 0, 255),
  const Color.fromARGB(255, 237, 231, 246),
  const Color.fromARGB(255, 209, 196, 233),
  const Color.fromARGB(255, 179, 157, 219),
  const Color.fromARGB(255, 149, 117, 205),
  const Color.fromARGB(255, 126, 87, 194),
  const Color.fromARGB(255, 103, 58, 183),
  const Color.fromARGB(255, 94, 53, 177),
  const Color.fromARGB(255, 81, 45, 168),
  const Color.fromARGB(255, 69, 39, 160),
  const Color.fromARGB(255, 49, 27, 146),
  const Color.fromARGB(255, 179, 136, 255),
  const Color.fromARGB(255, 124, 77, 255),
  const Color.fromARGB(255, 101, 31, 255),
  const Color.fromARGB(255, 98, 0, 234),
  const Color.fromARGB(255, 232, 234, 246),
  const Color.fromARGB(255, 197, 202, 233),
  const Color.fromARGB(255, 159, 168, 218),
  const Color.fromARGB(255, 121, 134, 203),
  const Color.fromARGB(255, 92, 107, 192),
  const Color.fromARGB(255, 63, 81, 181),
  const Color.fromARGB(255, 57, 73, 171),
  const Color.fromARGB(255, 48, 63, 159),
  const Color.fromARGB(255, 40, 53, 147),
  const Color.fromARGB(255, 26, 35, 126),
  const Color.fromARGB(255, 140, 158, 255),
  const Color.fromARGB(255, 83, 109, 254),
  const Color.fromARGB(255, 61, 90, 254),
  const Color.fromARGB(255, 48, 79, 254),
  const Color.fromARGB(255, 227, 242, 253),
  const Color.fromARGB(255, 187, 222, 251),
  const Color.fromARGB(255, 144, 202, 249),
  const Color.fromARGB(255, 100, 181, 246),
  const Color.fromARGB(255, 66, 165, 245),
  const Color.fromARGB(255, 33, 150, 243),
  const Color.fromARGB(255, 30, 136, 229),
  const Color.fromARGB(255, 25, 118, 210),
  const Color.fromARGB(255, 21, 101, 192),
  const Color.fromARGB(255, 13, 71, 161),
  const Color.fromARGB(255, 130, 177, 255),
  const Color.fromARGB(255, 68, 138, 255),
  const Color.fromARGB(255, 41, 121, 255),
  const Color.fromARGB(255, 41, 98, 255),
  const Color.fromARGB(255, 225, 245, 254),
  const Color.fromARGB(255, 179, 229, 252),
  const Color.fromARGB(255, 129, 212, 250),
  const Color.fromARGB(255, 79, 195, 247),
  const Color.fromARGB(255, 41, 182, 246),
  const Color.fromARGB(255, 3, 169, 244),
  const Color.fromARGB(255, 3, 155, 229),
  const Color.fromARGB(255, 2, 136, 209),
  const Color.fromARGB(255, 2, 119, 189),
  const Color.fromARGB(255, 1, 87, 155),
  const Color.fromARGB(255, 128, 216, 255),
  const Color.fromARGB(255, 64, 196, 255),
  const Color.fromARGB(255, 0, 176, 255),
  const Color.fromARGB(255, 0, 145, 234),
  const Color.fromARGB(255, 224, 247, 250),
  const Color.fromARGB(255, 178, 235, 242),
  const Color.fromARGB(255, 128, 222, 234),
  const Color.fromARGB(255, 77, 208, 225),
  const Color.fromARGB(255, 38, 198, 218),
  const Color.fromARGB(255, 0, 188, 212),
  const Color.fromARGB(255, 0, 172, 193),
  const Color.fromARGB(255, 0, 151, 167),
  const Color.fromARGB(255, 0, 131, 143),
  const Color.fromARGB(255, 0, 96, 100),
  const Color.fromARGB(255, 132, 255, 255),
  const Color.fromARGB(255, 24, 255, 255),
  const Color.fromARGB(255, 0, 229, 255),
  const Color.fromARGB(255, 0, 184, 212),
  const Color.fromARGB(255, 224, 242, 241),
  const Color.fromARGB(255, 178, 223, 219),
  const Color.fromARGB(255, 128, 203, 196),
  const Color.fromARGB(255, 77, 182, 172),
  const Color.fromARGB(255, 38, 166, 154),
  const Color.fromARGB(255, 0, 150, 136),
  const Color.fromARGB(255, 0, 137, 123),
  const Color.fromARGB(255, 0, 121, 107),
  const Color.fromARGB(255, 0, 105, 92),
  const Color.fromARGB(255, 0, 77, 64),
  const Color.fromARGB(255, 167, 255, 235),
  const Color.fromARGB(255, 100, 255, 218),
  const Color.fromARGB(255, 29, 233, 182),
  const Color.fromARGB(255, 0, 191, 165),
  const Color.fromARGB(255, 232, 245, 233),
  const Color.fromARGB(255, 200, 230, 201),
  const Color.fromARGB(255, 165, 214, 167),
  const Color.fromARGB(255, 129, 199, 132),
  const Color.fromARGB(255, 102, 187, 106),
  const Color.fromARGB(255, 76, 175, 80),
  const Color.fromARGB(255, 67, 160, 71),
  const Color.fromARGB(255, 56, 142, 60),
  const Color.fromARGB(255, 46, 125, 50),
  const Color.fromARGB(255, 27, 94, 32),
  const Color.fromARGB(255, 185, 246, 202),
  const Color.fromARGB(255, 105, 240, 174),
  const Color.fromARGB(255, 0, 230, 118),
  const Color.fromARGB(255, 0, 200, 83),
  const Color.fromARGB(255, 241, 248, 233),
  const Color.fromARGB(255, 220, 237, 200),
  const Color.fromARGB(255, 197, 225, 165),
  const Color.fromARGB(255, 174, 213, 129),
  const Color.fromARGB(255, 156, 204, 101),
  const Color.fromARGB(255, 139, 195, 74),
  const Color.fromARGB(255, 124, 179, 66),
  const Color.fromARGB(255, 104, 159, 56),
  const Color.fromARGB(255, 85, 139, 47),
  const Color.fromARGB(255, 51, 105, 30),
  const Color.fromARGB(255, 204, 255, 144),
  const Color.fromARGB(255, 178, 255, 89),
  const Color.fromARGB(255, 118, 255, 3),
  const Color.fromARGB(255, 100, 221, 23),
  const Color.fromARGB(255, 249, 251, 231),
  const Color.fromARGB(255, 240, 244, 195),
  const Color.fromARGB(255, 230, 238, 156),
  const Color.fromARGB(255, 220, 231, 117),
  const Color.fromARGB(255, 212, 225, 87),
  const Color.fromARGB(255, 205, 220, 57),
  const Color.fromARGB(255, 192, 202, 51),
  const Color.fromARGB(255, 175, 180, 43),
  const Color.fromARGB(255, 158, 157, 36),
  const Color.fromARGB(255, 130, 119, 23),
  const Color.fromARGB(255, 244, 255, 129),
  const Color.fromARGB(255, 238, 255, 65),
  const Color.fromARGB(255, 198, 255, 0),
  const Color.fromARGB(255, 174, 234, 0),
  const Color.fromARGB(255, 255, 253, 231),
  const Color.fromARGB(255, 255, 249, 196),
  const Color.fromARGB(255, 255, 245, 157),
  const Color.fromARGB(255, 255, 241, 118),
  const Color.fromARGB(255, 255, 238, 88),
  const Color.fromARGB(255, 255, 235, 59),
  const Color.fromARGB(255, 253, 216, 53),
  const Color.fromARGB(255, 251, 192, 45),
  const Color.fromARGB(255, 249, 168, 37),
  const Color.fromARGB(255, 245, 127, 23),
  const Color.fromARGB(255, 255, 255, 141),
  const Color.fromARGB(255, 255, 255, 0),
  const Color.fromARGB(255, 255, 234, 0),
  const Color.fromARGB(255, 255, 214, 0),
  const Color.fromARGB(255, 255, 248, 225),
  const Color.fromARGB(255, 255, 236, 179),
  const Color.fromARGB(255, 255, 224, 130),
  const Color.fromARGB(255, 255, 213, 79),
  const Color.fromARGB(255, 255, 202, 40),
  const Color.fromARGB(255, 255, 193, 7),
  const Color.fromARGB(255, 255, 179, 0),
  const Color.fromARGB(255, 255, 160, 0),
  const Color.fromARGB(255, 255, 143, 0),
  const Color.fromARGB(255, 255, 111, 0),
  const Color.fromARGB(255, 255, 229, 127),
  const Color.fromARGB(255, 255, 215, 64),
  const Color.fromARGB(255, 255, 196, 0),
  const Color.fromARGB(255, 255, 171, 0),
  const Color.fromARGB(255, 255, 243, 224),
  const Color.fromARGB(255, 255, 224, 178),
  const Color.fromARGB(255, 255, 204, 128),
  const Color.fromARGB(255, 255, 183, 77),
  const Color.fromARGB(255, 255, 167, 38),
  const Color.fromARGB(255, 255, 152, 0),
  const Color.fromARGB(255, 251, 140, 0),
  const Color.fromARGB(255, 245, 124, 0),
  const Color.fromARGB(255, 239, 108, 0),
  const Color.fromARGB(255, 230, 81, 0),
  const Color.fromARGB(255, 255, 209, 128),
  const Color.fromARGB(255, 255, 171, 64),
  const Color.fromARGB(255, 255, 145, 0),
  const Color.fromARGB(255, 255, 109, 0),
  const Color.fromARGB(255, 251, 233, 231),
  const Color.fromARGB(255, 255, 204, 188),
  const Color.fromARGB(255, 255, 171, 145),
  const Color.fromARGB(255, 255, 138, 101),
  const Color.fromARGB(255, 255, 112, 67),
  const Color.fromARGB(255, 255, 87, 34),
  const Color.fromARGB(255, 244, 81, 30),
  const Color.fromARGB(255, 230, 74, 25),
  const Color.fromARGB(255, 216, 67, 21),
  const Color.fromARGB(255, 191, 54, 12),
  const Color.fromARGB(255, 255, 158, 128),
  const Color.fromARGB(255, 255, 110, 64),
  const Color.fromARGB(255, 255, 61, 0),
  const Color.fromARGB(255, 221, 44, 0),
  const Color.fromARGB(255, 239, 235, 233),
  const Color.fromARGB(255, 215, 204, 200),
  const Color.fromARGB(255, 188, 170, 164),
  const Color.fromARGB(255, 161, 136, 127),
  const Color.fromARGB(255, 141, 110, 99),
  const Color.fromARGB(255, 121, 85, 72),
  const Color.fromARGB(255, 109, 76, 65),
  const Color.fromARGB(255, 93, 64, 55),
  const Color.fromARGB(255, 78, 52, 46),
  const Color.fromARGB(255, 62, 39, 35),
  const Color.fromARGB(255, 250, 250, 250),
  const Color.fromARGB(255, 245, 245, 245),
  const Color.fromARGB(255, 238, 238, 238),
  const Color.fromARGB(255, 224, 224, 224),
  const Color.fromARGB(255, 189, 189, 189),
  const Color.fromARGB(255, 158, 158, 158),
  const Color.fromARGB(255, 117, 117, 117),
  const Color.fromARGB(255, 97, 97, 97),
  const Color.fromARGB(255, 66, 66, 66),
  const Color.fromARGB(255, 33, 33, 33),
  const Color.fromARGB(255, 236, 239, 241),
  const Color.fromARGB(255, 207, 216, 220),
  const Color.fromARGB(255, 176, 190, 197),
  const Color.fromARGB(255, 144, 164, 174),
  const Color.fromARGB(255, 120, 144, 156),
  const Color.fromARGB(255, 96, 125, 139),
  const Color.fromARGB(255, 84, 110, 122),
  const Color.fromARGB(255, 69, 90, 100),
  const Color.fromARGB(255, 55, 71, 79),
  const Color.fromARGB(255, 38, 50, 56),
];

Color colorNearest(Color a) {
  double nearest = double.infinity;
  int result = 11;

  for (var i = 0; i < _gruvbox.length; i++) {
    final dist = colorDistance(_gruvbox[i], a);
    if (dist < nearest) {
      nearest = dist;
      result = i;
    }
  }

  return _gruvbox[result];
}

Map<int, Color> _colors = {
  0: const Color(0xff16161c),
  1: const Color(0xffe95678),
  2: const Color(0xff29d398),
  3: const Color(0xfffab795),
  4: const Color(0xff26bbd9),
  5: const Color(0xffee64ae),
  6: const Color(0xff59e3e3),
  7: const Color(0xfffadad1),
  8: const Color(0xff404459),
  9: const Color(0xffec6a88),
  10: const Color(0xff3fdaa4),
  11: const Color(0xfffbc3a7),
  12: const Color(0xff3fc6de),
  13: const Color(0xfff075b7),
  14: const Color(0xff6be6e6),
  15: const Color(0xfffdf0ed),
  16: colorNearest(const Color(0xff000000)),
  17: colorNearest(const Color(0xff00005f)),
  18: colorNearest(const Color(0xff000087)),
  19: colorNearest(const Color(0xff0000af)),
  20: colorNearest(const Color(0xff0000d7)),
  21: colorNearest(const Color(0xff0000ff)),
  22: colorNearest(const Color(0xff005f00)),
  23: colorNearest(const Color(0xff005f5f)),
  24: colorNearest(const Color(0xff005f87)),
  25: colorNearest(const Color(0xff005faf)),
  26: colorNearest(const Color(0xff005fd7)),
  27: colorNearest(const Color(0xff005fff)),
  28: colorNearest(const Color(0xff008700)),
  29: colorNearest(const Color(0xff00875f)),
  30: colorNearest(const Color(0xff008787)),
  31: colorNearest(const Color(0xff0087af)),
  32: colorNearest(const Color(0xff0087d7)),
  33: colorNearest(const Color(0xff0087ff)),
  34: colorNearest(const Color(0xff00af00)),
  35: colorNearest(const Color(0xff00af5f)),
  36: colorNearest(const Color(0xff00af87)),
  37: colorNearest(const Color(0xff00afaf)),
  38: colorNearest(const Color(0xff00afd7)),
  39: colorNearest(const Color(0xff00afff)),
  40: colorNearest(const Color(0xff00d700)),
  41: colorNearest(const Color(0xff00d75f)),
  42: colorNearest(const Color(0xff00d787)),
  43: colorNearest(const Color(0xff00d7af)),
  44: colorNearest(const Color(0xff00d7d7)),
  45: colorNearest(const Color(0xff00d7ff)),
  46: colorNearest(const Color(0xff00ff00)),
  47: colorNearest(const Color(0xff00ff5f)),
  48: colorNearest(const Color(0xff00ff87)),
  49: colorNearest(const Color(0xff00ffaf)),
  50: colorNearest(const Color(0xff00ffd7)),
  51: colorNearest(const Color(0xff00ffff)),
  52: colorNearest(const Color(0xff5f0000)),
  53: colorNearest(const Color(0xff5f005f)),
  54: colorNearest(const Color(0xff5f0087)),
  55: colorNearest(const Color(0xff5f00af)),
  56: colorNearest(const Color(0xff5f00d7)),
  57: colorNearest(const Color(0xff5f00ff)),
  58: colorNearest(const Color(0xff5f5f00)),
  59: colorNearest(const Color(0xff5f5f5f)),
  60: colorNearest(const Color(0xff5f5f87)),
  61: colorNearest(const Color(0xff5f5faf)),
  62: colorNearest(const Color(0xff5f5fd7)),
  63: colorNearest(const Color(0xff5f5fff)),
  64: colorNearest(const Color(0xff5f8700)),
  65: colorNearest(const Color(0xff5f875f)),
  66: colorNearest(const Color(0xff5f8787)),
  67: colorNearest(const Color(0xff5f87af)),
  68: colorNearest(const Color(0xff5f87d7)),
  69: colorNearest(const Color(0xff5f87ff)),
  70: colorNearest(const Color(0xff5faf00)),
  71: colorNearest(const Color(0xff5faf5f)),
  72: colorNearest(const Color(0xff5faf87)),
  73: colorNearest(const Color(0xff5fafaf)),
  74: colorNearest(const Color(0xff5fafd7)),
  75: colorNearest(const Color(0xff5fafff)),
  76: colorNearest(const Color(0xff5fd700)),
  77: colorNearest(const Color(0xff5fd75f)),
  78: colorNearest(const Color(0xff5fd787)),
  79: colorNearest(const Color(0xff5fd7af)),
  80: colorNearest(const Color(0xff5fd7d7)),
  81: colorNearest(const Color(0xff5fd7ff)),
  82: colorNearest(const Color(0xff5fff00)),
  83: colorNearest(const Color(0xff5fff5f)),
  84: colorNearest(const Color(0xff5fff87)),
  85: colorNearest(const Color(0xff5fffaf)),
  86: colorNearest(const Color(0xff5fffd7)),
  87: colorNearest(const Color(0xff5fffff)),
  88: colorNearest(const Color(0xff870000)),
  89: colorNearest(const Color(0xff87005f)),
  90: colorNearest(const Color(0xff870087)),
  91: colorNearest(const Color(0xff8700af)),
  92: colorNearest(const Color(0xff8700d7)),
  93: colorNearest(const Color(0xff8700ff)),
  94: colorNearest(const Color(0xff875f00)),
  95: colorNearest(const Color(0xff875f5f)),
  96: colorNearest(const Color(0xff875f87)),
  97: colorNearest(const Color(0xff875faf)),
  98: colorNearest(const Color(0xff875fd7)),
  99: colorNearest(const Color(0xff875fff)),
  100: colorNearest(const Color(0xff878700)),
  101: colorNearest(const Color(0xff87875f)),
  102: colorNearest(const Color(0xff878787)),
  103: colorNearest(const Color(0xff8787af)),
  104: colorNearest(const Color(0xff8787d7)),
  105: colorNearest(const Color(0xff8787ff)),
  106: colorNearest(const Color(0xff87af00)),
  107: colorNearest(const Color(0xff87af5f)),
  108: colorNearest(const Color(0xff87af87)),
  109: colorNearest(const Color(0xff87afaf)),
  110: colorNearest(const Color(0xff87afd7)),
  111: colorNearest(const Color(0xff87afff)),
  112: colorNearest(const Color(0xff87d700)),
  113: colorNearest(const Color(0xff87d75f)),
  114: colorNearest(const Color(0xff87d787)),
  115: colorNearest(const Color(0xff87d7af)),
  116: colorNearest(const Color(0xff87d7d7)),
  117: colorNearest(const Color(0xff87d7ff)),
  118: colorNearest(const Color(0xff87ff00)),
  119: colorNearest(const Color(0xff87ff5f)),
  120: colorNearest(const Color(0xff87ff87)),
  121: colorNearest(const Color(0xff87ffaf)),
  122: colorNearest(const Color(0xff87ffd7)),
  123: colorNearest(const Color(0xff87ffff)),
  124: colorNearest(const Color(0xffaf0000)),
  125: colorNearest(const Color(0xffaf005f)),
  126: colorNearest(const Color(0xffaf0087)),
  127: colorNearest(const Color(0xffaf00af)),
  128: colorNearest(const Color(0xffaf00d7)),
  129: colorNearest(const Color(0xffaf00ff)),
  130: colorNearest(const Color(0xffaf5f00)),
  131: colorNearest(const Color(0xffaf5f5f)),
  132: colorNearest(const Color(0xffaf5f87)),
  133: colorNearest(const Color(0xffaf5faf)),
  134: colorNearest(const Color(0xffaf5fd7)),
  135: colorNearest(const Color(0xffaf5fff)),
  136: colorNearest(const Color(0xffaf8700)),
  137: colorNearest(const Color(0xffaf875f)),
  138: colorNearest(const Color(0xffaf8787)),
  139: colorNearest(const Color(0xffaf87af)),
  140: colorNearest(const Color(0xffaf87d7)),
  141: colorNearest(const Color(0xffaf87ff)),
  142: colorNearest(const Color(0xffafaf00)),
  143: colorNearest(const Color(0xffafaf5f)),
  144: colorNearest(const Color(0xffafaf87)),
  145: colorNearest(const Color(0xffafafaf)),
  146: colorNearest(const Color(0xffafafd7)),
  147: colorNearest(const Color(0xffafafff)),
  148: colorNearest(const Color(0xffafd700)),
  149: colorNearest(const Color(0xffafd75f)),
  150: colorNearest(const Color(0xffafd787)),
  151: colorNearest(const Color(0xffafd7af)),
  152: colorNearest(const Color(0xffafd7d7)),
  153: colorNearest(const Color(0xffafd7ff)),
  154: colorNearest(const Color(0xffafff00)),
  155: colorNearest(const Color(0xffafff5f)),
  156: colorNearest(const Color(0xffafff87)),
  157: colorNearest(const Color(0xffafffaf)),
  158: colorNearest(const Color(0xffafffd7)),
  159: colorNearest(const Color(0xffafffff)),
  160: colorNearest(const Color(0xffd70000)),
  161: colorNearest(const Color(0xffd7005f)),
  162: colorNearest(const Color(0xffd70087)),
  163: colorNearest(const Color(0xffd700af)),
  164: colorNearest(const Color(0xffd700d7)),
  165: colorNearest(const Color(0xffd700ff)),
  166: colorNearest(const Color(0xffd75f00)),
  167: colorNearest(const Color(0xffd75f5f)),
  168: colorNearest(const Color(0xffd75f87)),
  169: colorNearest(const Color(0xffd75faf)),
  170: colorNearest(const Color(0xffd75fd7)),
  171: colorNearest(const Color(0xffd75fff)),
  172: colorNearest(const Color(0xffd78700)),
  173: colorNearest(const Color(0xffd7875f)),
  174: colorNearest(const Color(0xffd78787)),
  175: colorNearest(const Color(0xffd787af)),
  176: colorNearest(const Color(0xffd787d7)),
  177: colorNearest(const Color(0xffd787ff)),
  178: colorNearest(const Color(0xffd7af00)),
  179: colorNearest(const Color(0xffd7af5f)),
  180: colorNearest(const Color(0xffd7af87)),
  181: colorNearest(const Color(0xffd7afaf)),
  182: colorNearest(const Color(0xffd7afd7)),
  183: colorNearest(const Color(0xffd7afff)),
  184: colorNearest(const Color(0xffd7d700)),
  185: colorNearest(const Color(0xffd7d75f)),
  186: colorNearest(const Color(0xffd7d787)),
  187: colorNearest(const Color(0xffd7d7af)),
  188: colorNearest(const Color(0xffd7d7d7)),
  189: colorNearest(const Color(0xffd7d7ff)),
  190: colorNearest(const Color(0xffd7ff00)),
  191: colorNearest(const Color(0xffd7ff5f)),
  192: colorNearest(const Color(0xffd7ff87)),
  193: colorNearest(const Color(0xffd7ffaf)),
  194: colorNearest(const Color(0xffd7ffd7)),
  195: colorNearest(const Color(0xffd7ffff)),
  196: colorNearest(const Color(0xffff0000)),
  197: colorNearest(const Color(0xffff005f)),
  198: colorNearest(const Color(0xffff0087)),
  199: colorNearest(const Color(0xffff00af)),
  200: colorNearest(const Color(0xffff00d7)),
  201: colorNearest(const Color(0xffff00ff)),
  202: colorNearest(const Color(0xffff5f00)),
  203: colorNearest(const Color(0xffff5f5f)),
  204: colorNearest(const Color(0xffff5f87)),
  205: colorNearest(const Color(0xffff5faf)),
  206: colorNearest(const Color(0xffff5fd7)),
  207: colorNearest(const Color(0xffff5fff)),
  208: colorNearest(const Color(0xffff8700)),
  209: colorNearest(const Color(0xffff875f)),
  210: colorNearest(const Color(0xffff8787)),
  211: colorNearest(const Color(0xffff87af)),
  212: colorNearest(const Color(0xffff87d7)),
  213: colorNearest(const Color(0xffff87ff)),
  214: colorNearest(const Color(0xffffaf00)),
  215: colorNearest(const Color(0xffffaf5f)),
  216: colorNearest(const Color(0xffffaf87)),
  217: colorNearest(const Color(0xffffafaf)),
  218: colorNearest(const Color(0xffffafd7)),
  219: colorNearest(const Color(0xffffafff)),
  220: colorNearest(const Color(0xffffd700)),
  221: colorNearest(const Color(0xffffd75f)),
  222: colorNearest(const Color(0xffffd787)),
  223: colorNearest(const Color(0xffffd7af)),
  224: colorNearest(const Color(0xffffd7d7)),
  225: colorNearest(const Color(0xffffd7ff)),
  226: colorNearest(const Color(0xffffff00)),
  227: colorNearest(const Color(0xffffff5f)),
  228: colorNearest(const Color(0xffffff87)),
  229: colorNearest(const Color(0xffffffaf)),
  230: colorNearest(const Color(0xffffffd7)),
  231: colorNearest(const Color(0xffffffff)),
  232: colorNearest(const Color(0xff080808)),
  233: colorNearest(const Color(0xff121212)),
  234: colorNearest(const Color(0xff1c1c1c)),
  235: colorNearest(const Color(0xff262626)),
  236: colorNearest(const Color(0xff303030)),
  237: colorNearest(const Color(0xff3a3a3a)),
  238: colorNearest(const Color(0xff444444)),
  239: colorNearest(const Color(0xff4e4e4e)),
  240: colorNearest(const Color(0xff585858)),
  241: colorNearest(const Color(0xff626262)),
  242: colorNearest(const Color(0xff6c6c6c)),
  243: colorNearest(const Color(0xff767676)),
  244: colorNearest(const Color(0xff808080)),
  245: colorNearest(const Color(0xff8a8a8a)),
  246: colorNearest(const Color(0xff949494)),
  247: colorNearest(const Color(0xff9e9e9e)),
  248: colorNearest(const Color(0xffa8a8a8)),
  249: colorNearest(const Color(0xffb2b2b2)),
  250: colorNearest(const Color(0xffbcbcbc)),
  251: colorNearest(const Color(0xffc6c6c6)),
  252: colorNearest(const Color(0xffd0d0d0)),
  253: colorNearest(const Color(0xffdadada)),
  254: colorNearest(const Color(0xffe4e4e4)),
  255: colorNearest(const Color(0xffeeeeee)),
};
