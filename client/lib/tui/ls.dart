import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:taskwire2/assets/vscode_icons.dart';

class DirOrFile extends StatefulWidget {
  const DirOrFile({
    Key? key,
    required this.name,
    required this.content,
    this.top = false,
    this.expand = false,
  }) : super(key: key);

  final String name;
  final dynamic content;
  final bool top;
  final bool expand;

  @override
  State<DirOrFile> createState() => _DirOrFileState();
}

class _DirOrFileState extends State<DirOrFile> {
  String pathName = "";
  bool expanded = false;
  bool isDir = false;

  @override
  void initState() {
    expanded = widget.expand;
    isDir = widget.content['Childs'] != null;

    if (widget.top) {
      pathName = widget.content['Stats']['FullPath'];
    } else {
      pathName = widget.name;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final rawTime = DateTime.parse(widget.content['Stats']['Time']);
    final time = rawTime.toString();
    final mod = widget.content['Stats']['Mod'];
    final size = (widget.content['Stats']['Size'] as String).padLeft(9);
    final element = GestureDetector(
      onTap: () => setState(() {
        expanded = !expanded;
      }),
      child: Row(
        children: [
          _fileIcon(),
          const SizedBox(width: 5),
          Expanded(child: Text(pathName)),
          Text(mod),
          const SizedBox(width: 10),
          Text(size),
          const SizedBox(width: 10),
          Text(time),
        ],
      ),
    );

    if (isDir) {
      List<Widget> list = [element];

      if (expanded) {
        final childs =
            (widget.content['Childs'] as Map<String, dynamic>).entries.toList();
        childs.sort((a, b) {
          final aIsDir = a.value['Childs'] != null;
          final bIsDir = b.value['Childs'] != null;
          if (aIsDir && !bIsDir) {
            return -1;
          }
          if (bIsDir && !aIsDir) {
            return 1;
          }

          return a.key.compareTo(b.key);
        });
        list.addAll(childs.map((child) {
          return Container(
            margin: const EdgeInsets.only(left: 8),
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(
                  color: Colors.grey.withAlpha(50),
                  width: 2,
                ),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.only(left: 8),
              child: DirOrFile(name: child.key, content: child.value),
            ),
          );
        }));
      }

      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: list,
      );
    }

    return element;
  }

  Widget _fileIcon() {
    final name = widget.name;
    final ext = name.split(".").last;
    Widget icon = SvgPicture.asset(
      vscodeIconsValid[ext] ?? vscodeIconsValid['file']!,
      width: 18,
    );

    if (isDir) {
      String folderName = "folder";
      String niceFolderName = "folder_$name";
      if (expanded) {
        folderName += "_open";
        niceFolderName += "_open";
      }

      icon = SvgPicture.asset(
        vscodeIconsValid[niceFolderName] ?? vscodeIconsValid[folderName]!,
        width: 18,
      );
    }
    return icon;
  }
}
