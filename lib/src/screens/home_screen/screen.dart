import 'package:calculator/src/controllers/calc.dart';
import 'package:calculator/src/controllers/calc_logic.dart';
import 'package:calculator/src/controllers/calc_ui.dart';
import 'package:calculator/src/layout.dart';
import 'package:calculator/src/other/scroll_physics.dart';
import 'package:calculator/src/widgets/header.dart';
import 'package:calculator/src/widgets/history.dart';
import 'package:calculator/src/widgets/keypad.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  late final AnimationController firstLevelController =
      AnimationController(vsync: this);
  late final AnimationController secondLevelController =
      AnimationController(vsync: this);
  late final CalcController controller = CalcController(
      CalcUiController()
        ..firstLevelScrollAnimation = firstLevelController
        ..secondLevelScrollAnimation = secondLevelController,
      CalcLogicController());
  late final Animation<double> keypadHeight = firstLevelController;

  @override
  void initState() {
    super.initState();
    controller.ui.scrollController.addListener(_onScroll);
  }

  ScrollController get scrollController => controller.ui.scrollController;

  @override
  void dispose() {
    firstLevelController.dispose();
    secondLevelController.dispose();
    controller.dispose();
    super.dispose();
  }

  void _onScroll() {
    final p = scrollController.position;
    final viewHeight = p.viewportDimension;

    void updateFirst() {
      final maxHeight = viewHeight * 2 / 3;
      final minHeight = viewHeight / 2;
      final deltaHeight = maxHeight - minHeight;

      final fracExt = p.extentBefore / deltaHeight;
      firstLevelController.value = fracExt.clamp(0.0, 1.0);
    }

    void updateSecond() {
      final firstMaxHeight = viewHeight * 2 / 3;
      final firstMinHeight = viewHeight / 2;
      final firstDeltaHeight = firstMaxHeight - firstMinHeight;

      final maxHeight = viewHeight;
      final minHeight = viewHeight / 2;
      final deltaHeight = maxHeight - minHeight;

      final fracExt = (p.extentBefore - firstDeltaHeight) / deltaHeight;
      secondLevelController.value = fracExt.clamp(0.0, 1.0);
    }

    updateFirst();
    updateSecond();
  }

  Widget _keypadBuilder(BuildContext context, SliverConstraints constraints) {
    final viewHeight = constraints.viewportMainAxisExtent;
    final maxHeight = viewHeight * 2 / 3;
    final minHeight = viewHeight / 2;
    final deltaHeight = maxHeight - minHeight;

    return SliverToBoxAdapter(
      child: SizedBox(
        height: maxHeight,
        child: Padding(
          padding: EdgeInsets.only(
            bottom: constraints.scrollOffset.clamp(0.0, deltaHeight),
          ),
          child: const Keypad(),
        ),
      ),
    );
  }

  Widget _headerBuilder(BuildContext context, SliverConstraints constraints) {
    final viewHeight = constraints.viewportMainAxisExtent;
    final bottomPadding = 36 * secondLevelController.value;

    final height = viewHeight * 1 / 3;
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: bottomPadding,
        ),
        child: SizedBox(
          height: height,
          child: const Header(),
        ),
      ),
    );
  }

  Widget _historyBuilder(BuildContext context, SliverConstraints constraints) {
    final viewHeight = constraints.viewportMainAxisExtent;
    final fullHeight = viewHeight * 2 / 3 - 36;
    final height = constraints.remainingPaintExtent;

    return SliverToBoxAdapter(
      child: SizedBox(
        height: fullHeight,
        child: Padding(
          padding: EdgeInsets.only(top: fullHeight - height),
          child: const History(),
        ),
      ),
    );
  }

  final _scrollPhysicsPoints = <double>[];
  late final _scrollPhysics =
      SnapToEdgesAndPointsPhysics(points: _scrollPhysicsPoints);

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    final maxHeight = height * 2 / 3;
    final minHeight = height / 2;
    final deltaHeight = maxHeight - minHeight;

    // This is should not happen, an new instance of the scroll physics should
    // be created in the build method, with the correct points, but when this
    // is the case, the actual scroll physics does not get updated, therefore,
    // the points are always the ones set in the first construction of the
    // object, resulting in incorrect behavior.
    // TODO: Figure out what is going on.
    _scrollPhysicsPoints.clear();
    _scrollPhysicsPoints.addAll([
      if (CalculatorLayout.of(context).type != CalculatorLayoutType.tiny)
        deltaHeight,
    ]);

    return InheritedCalcController(
      controller: controller,
      child: CustomScrollView(
        reverse: true,
        controller: scrollController,
        physics: _scrollPhysics,
        slivers: [
          SliverLayoutBuilder(builder: _keypadBuilder),
          SliverLayoutBuilder(builder: _headerBuilder),
          SliverLayoutBuilder(builder: _historyBuilder),
        ],
      ),
    );
  }
}
