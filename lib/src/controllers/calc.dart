import 'package:calculator/src/other/initable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import 'calc_ui.dart';
import 'calc_logic.dart';

/// Provides an glue between the [CalcUiController] and the
/// [CalcLogicController].
class CalcController extends InitableDisposable {
  final CalcUiController ui;
  final CalcLogicController logic;

  CalcController(this.ui, this.logic);

  @override
  void init() {
    super.init();
    ui.textFocusNode.onKeyEvent = _onKeyEvent;
    ui.textEditingController.addListener(_onTextChangedEvent);
    logic.expression.addListener(_onLogicExpressionChanged);
  }

  @override
  void dispose() {
    ui.dispose();
    logic.dispose();
    super.dispose();
  }

  static CalcController of(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<InheritedCalcController>()!
      .controller;

  KeyEventResult _onKeyEvent(FocusNode node, KeyEvent event) {
    if (event.logicalKey == LogicalKeyboardKey.enter) {
      logic.onEquals();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  void _onTextChangedEvent() {
    // Forward the ui text to the logic expression
    logic.expression.value = ui.textEditingController.text;
  }

  void _onLogicExpressionChanged() {
    final logicExpression = logic.expression.value;
    final oldEditingText = ui.textEditingController.text;
    if (oldEditingText == logicExpression) {
      return;
    }
    ui.textEditingController.text = logicExpression;
    if (logicExpression.startsWith(oldEditingText)) {
      // We need to scroll to the end, because an new string was added to the
      // end.
      ui.scheduleScrollToEnd();
    }
  }
}

class InheritedCalcController extends InheritedWidget {
  final CalcController controller;

  const InheritedCalcController({
    Key? key,
    required this.controller,
    required Widget child,
  }) : super(
          key: key,
          child: child,
        );
  @override
  bool updateShouldNotify(InheritedCalcController oldWidget) =>
      oldWidget.controller != controller;
}
