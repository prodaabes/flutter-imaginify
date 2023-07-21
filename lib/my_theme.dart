import 'package:flutter/material.dart';

enum MyThemeKeys { LIGHT, DARK }

class MyThemes {

  static final ThemeData lightTheme = ThemeData(
    primaryColor: Colors.blue,
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: AppBarTheme(color: Color(0xff171d49),),
    textSelectionTheme: TextSelectionThemeData(
      selectionColor: Colors.grey,
      cursorColor: Color(0xff171d49),
      selectionHandleColor: Color(0xff005e91),
    ),
    backgroundColor: Colors.white,
    brightness: Brightness.light,
    highlightColor: Colors.white,
    floatingActionButtonTheme:
    FloatingActionButtonThemeData (backgroundColor: Colors.blue,focusColor: Colors.blueAccent , splashColor: Colors.lightBlue),
    colorScheme: ColorScheme.fromSwatch().copyWith(secondary: Colors.white),

  );

  static final ThemeData darkTheme = ThemeData(
    primaryColor: Colors.grey,
    scaffoldBackgroundColor: Colors.white,
    brightness: Brightness.dark,
    highlightColor: Colors.white,
    backgroundColor: Colors.black54,
    textSelectionTheme: TextSelectionThemeData(selectionColor: Colors.grey),
  );

  static ThemeData getThemeFromKey(MyThemeKeys themeKey) {
    switch (themeKey) {
      case MyThemeKeys.LIGHT:
        return lightTheme;
      case MyThemeKeys.DARK:
        return darkTheme;
      default:
        return lightTheme;
    }
  }
}

class _CustomTheme extends InheritedWidget {
  final CustomThemeState data;

  _CustomTheme({
    required this.data,
    Key? key,
    required Widget child,
  }) : super(key: key, child: child);

  @override
  bool updateShouldNotify(_CustomTheme oldWidget) {
    return true;
  }
}

class CustomTheme extends StatefulWidget {
  final Widget child;
  final MyThemeKeys initialThemeKey;

  const CustomTheme({
    Key? key,
    required this.initialThemeKey,
    required this.child,
  }) : super(key: key);

  @override
  CustomThemeState createState() => new CustomThemeState();

  static ThemeData? of(BuildContext context) {
    _CustomTheme? inherited =
     (context.dependOnInheritedWidgetOfExactType<_CustomTheme>());
    return inherited?.data.theme;
  }

  static CustomThemeState? instanceOf(BuildContext context) {
    _CustomTheme? inherited =
     (context.dependOnInheritedWidgetOfExactType<_CustomTheme>());
    return inherited?.data;
  }
}

class CustomThemeState extends State<CustomTheme> {
  late ThemeData _theme;

  ThemeData get theme => _theme;

  @override
  void initState() {
    _theme = MyThemes.getThemeFromKey(widget.initialThemeKey);
    super.initState();
  }

  void changeTheme(MyThemeKeys themeKey) {
    setState(() {
      _theme = MyThemes.getThemeFromKey(themeKey);
    });
  }

  @override
  Widget build(BuildContext context) {
    return _CustomTheme(
      data: this,
      child: widget.child,
    );
  }
}