import 'package:calculator/src/controllers/calc_logic.dart';
import 'package:calculator/src/screens/home_screen/screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_widgets/material_widgets.dart';
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

final GlobalKey<NavigatorState> navKey = GlobalKey();

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MD3Themes(
        builder: (context, light, dark) => MaterialApp(
              title: 'Flutter Demo',
              theme: light,
              darkTheme: dark,
              debugShowCheckedModeBanner: false,
              builder: (context, home) => DesktopOverlays(
                child: home!,
                navigatorKey: navKey,
              ),
              home: MD3AdaptativeScaffold(
                body: MD3ScaffoldBody.noMargin(
                  child: Builder(
                    builder: (context) => AnnotatedRegion<SystemUiOverlayStyle>(
                      value: SystemUiOverlayStyle(
                        statusBarColor: context.elevation.level2.overlaidColor(
                          context.colorScheme.surface,
                          context.colorScheme.primary,
                        ),
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
            ));
  }
}
