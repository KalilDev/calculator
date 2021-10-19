import 'package:calculator/src/controllers/calc_logic.dart';
import 'package:calculator/src/screens/home_screen/screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_you/material_you.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'src/layout.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Hive.registerAdapter(const HistoryEntryAdapter());
  await path_provider
      .getApplicationSupportDirectory()
      .then((dir) => Hive.init(dir.path));
  runPlatformThemedApp(
    const MyApp(),
    initialOrFallback: () => const PlatformPalette(
      primaryColor: Color(0xFF57e362),
    ),
  );
}

TextTheme robotoLightTextTheme([TextTheme? textTheme]) {
  textTheme ??= ThemeData.light().textTheme;
  return TextTheme(
    headline1: textTheme.headline1!.copyWith(fontWeight: FontWeight.w400),
    headline2: textTheme.headline2!.copyWith(fontWeight: FontWeight.w400),
    headline3: textTheme.headline3!.copyWith(fontWeight: FontWeight.w400),
    headline4: textTheme.headline4!.copyWith(fontWeight: FontWeight.w400),
    headline5: textTheme.headline5!.copyWith(fontWeight: FontWeight.w400),
    headline6: textTheme.headline6!.copyWith(fontWeight: FontWeight.w400),
    subtitle1: textTheme.subtitle1!.copyWith(fontWeight: FontWeight.w400),
    subtitle2: textTheme.subtitle2!.copyWith(fontWeight: FontWeight.w400),
    bodyText1: textTheme.bodyText1!.copyWith(fontWeight: FontWeight.w400),
    bodyText2: textTheme.bodyText2!.copyWith(fontWeight: FontWeight.w400),
    caption: textTheme.caption!.copyWith(fontWeight: FontWeight.w400),
    button: textTheme.button!.copyWith(fontWeight: FontWeight.w400),
    overline: textTheme.overline!.copyWith(fontWeight: FontWeight.w400),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final textTheme = robotoLightTextTheme(Typography.englishLike2018);
    final themes = themesFrom(
      context.palette,
      lightTextTheme: textTheme,
      darkTextTheme: textTheme,
    );
    return MaterialApp(
      title: 'Flutter Demo',
      theme: themes.lightTheme,
      darkTheme: themes.darkTheme,
      debugShowCheckedModeBanner: false,
      home: InheritedMaterialYouColors(
        colors: themes.materialYouColors,
        child: Scaffold(
          body: Builder(
            builder: (context) => AnnotatedRegion<SystemUiOverlayStyle>(
              value: SystemUiOverlayStyle(
                statusBarColor: AppBarTheme.of(context).backgroundColor!,
              ),
              child: InheritedCalculatorLayout(
                layout: CalculatorLayout.fromViewSize(
                  MediaQuery.of(context).size,
                ),
                child: const SafeArea(
                  child: MainScreen(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
