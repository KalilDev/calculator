import 'package:calculator/src/controllers/calc.dart';
import 'package:flutter/material.dart'
    show
        Animation,
        Curves,
        FocusNode,
        ScrollController,
        TextEditingController,
        WidgetsBinding;
import 'package:value_notifier/value_notifier.dart';

class CalcUiController
    extends SubcontrollerBase<CalcController, CalcUiController> {
  final ScrollController scrollController = ScrollController();
  late final TextEditingController textEditingController =
      TextEditingController();
  late final FocusNode textFocusNode = FocusNode();
  late final ScrollController textEditingScrollController = ScrollController();
  late final Animation<double> firstLevelScrollAnimation;
  late final Animation<double> secondLevelScrollAnimation;

  @override
  void dispose() {
    scrollController.dispose();
    textEditingController.dispose();
    textFocusNode.dispose();
    textEditingScrollController.dispose();
    super.dispose();
  }

  void scrollViewToHistory() {
    scrollController.animateTo(
      scrollController.position.viewportDimension * 2 / 3,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
    );
  }

  void scrollBack() {
    scrollController.animateTo(
      0.0,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  void scheduleScrollToEnd() {
    // On the next frame, the textEditingController.text will update the
    // dimensions of the scrollable viewport.
    WidgetsBinding.instance!.addPostFrameCallback(
      (_) => textEditingScrollController.animateTo(
        textEditingScrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeInOut,
      ),
    );
  }
}
