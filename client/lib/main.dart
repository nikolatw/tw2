import 'package:flutter/material.dart';
import 'package:taskwire2/assets/vscode_icons.dart';
import 'package:taskwire2/compositions/full_screen_term.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    vscodeIconsCompute();

    return MaterialApp(
      title: 'Taskwire',
      darkTheme: _theme(),
      themeMode: ThemeMode.dark,
      debugShowCheckedModeBanner: false,
      home: const Scaffold(
        body: FullscreenTerminal("T1"),
      ),
    );
  }

  ThemeData _theme() {
    var themeData = ThemeData(
      splashFactory: NoSplash.splashFactory,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      focusColor: Colors.transparent,
      hoverColor: Colors.transparent,
      scaffoldBackgroundColor: Colors.black,
      primarySwatch: Colors.grey,
      brightness: Brightness.dark,
      useMaterial3: true,
    );

    themeData = themeData.copyWith(
      textTheme: GoogleFonts.ibmPlexMonoTextTheme(
        themeData.textTheme,
      ),
    );

    return themeData;
  }
}
