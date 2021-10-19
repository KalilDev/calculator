import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:math_expressions/math_expressions.dart';
import 'dart:math' as math;

class HistoryEntry {
  final String expression;
  final String result;

  HistoryEntry(this.expression, this.result);
}

class CalcController {
  final ValueNotifier<bool> isDeg = ValueNotifier(false);
  final ValueNotifier<bool> isInverted = ValueNotifier(false);
  final ValueNotifier<List<HistoryEntry>> history = ValueNotifier([]);
  final ValueNotifier<String> expressionResult = ValueNotifier('');
  final ScrollController scrollController = ScrollController();
  late final TextEditingController textEditingController =
      TextEditingController()..addListener(_onTextChanged);
  late final FocusNode textFocusNode = FocusNode(onKeyEvent: _onKeyEvent);
  late final ScrollController textEditingScrollController = ScrollController();
  late final Animation<double> firstLevelScrollAnimation;
  late final Animation<double> secondLevelScrollAnimation;
  static CalcController of(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<InheritedCalcController>()!
      .controller;
  void scrollViewToHistory() {
    scrollController.animateTo(
      scrollController.position.viewportDimension * 2 / 3,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
    );
  }

  void insertExpression(String expression) {
    textEditingController.text += expression;
  }

  void onEquals() {
    final result = expressionResult.value;
    if (result.isEmpty) {
      return;
    }
    if (result.trim() == 'ERRO') {
      return;
    }

    history.value = history.value
      ..add(HistoryEntry(textEditingController.text, result));
    textEditingController.text = result;
  }

  KeyEventResult _onKeyEvent(FocusNode node, KeyEvent event) {
    if (event.logicalKey == LogicalKeyboardKey.enter) {
      onEquals();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  final _parser = Parser();
  final _radContext = _createContext();
  final _degContext = _createDegContext();
  static ContextModel _createContext() {
    final ctx = ContextModel();
    ctx
      ..bindVariableName('pi', Number(math.pi))
      ..bindVariableName('e', Number(math.e));
    return ctx;
  }

  static ContextModel _createDegContext() {
    final ctx = _createContext();
    // TODO: Create the context with the modified trig functions
    return ctx;
  }

  String? lastString;

  static const _epsilon = 0.0000000000000000000001;

  String _resultToString(dynamic result) {
    if (result is double) {
      if ((result - result.round()).abs() <= _epsilon) {
        return _resultToString(result.round());
      }
      for (var i = 0; i < 10; i++) {
        final r = result;
        final ithTenth = i / 10;
        if ((r - (r.round() + ithTenth)).abs() <= _epsilon) {
          return (r.round() + ithTenth).toString();
        }
      }
      return result.toString();
    }
    if (result is int) {
      if (result >= 1000000) {
        return result.toStringAsExponential();
      }
      return result.toString();
    }
    return result.toString();
  }

  void _onTextChanged() {
    final content = textEditingController.text;
    if (content.isEmpty) {
      expressionResult.value = '';
      return;
    }
    void showLastOrError() {
      if (lastString == null) {
        return;
      }
      // The user added or removed an single character, which may be an operator
      if ((content.length - (lastString!.length + 1)).abs() == 1) {
        // Do nothing and keep the last result
      } else {
        expressionResult.value = 'ERRO';
      }
    }

    try {
      final exp = _parser.parse(content.replaceAll(',', '.'));
      if (exp is Literal) {
        expressionResult.value = '';
      } else {
        final result = exp.evaluate(
            EvaluationType.REAL, isDeg.value ? _degContext : _radContext);
        expressionResult.value = _resultToString(result);
      }
    } on ArgumentError {
      showLastOrError();
    } on StateError {
      showLastOrError();
    } on FormatException {
      showLastOrError();
    } finally {
      lastString = content;
    }
  }

  void clearHistory() => history.value = history.value..clear();

  void scrollBack() {
    scrollController.animateTo(
      0.0,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  void onPressedDigit(int digit) {
    assert(digit >= 0 && digit <= 9);
    _add(digit.toString());
  }

  void onClear() {
    textEditingController.text = '';
  }

  void _addOp(String op) {
    textEditingController.text += ' $op ';
  }

  void onParens() {
    final contents = textEditingController.text;
    if (contents.isEmpty || contents[contents.length - 1] == '(') {
      _add('(');
      return;
    }
    var opened = 0;
    final open = '('.codeUnits.single;
    final close = ')'.codeUnits.single;
    for (final s in contents.codeUnits) {
      if (s == open) {
        opened++;
      } else if (s == close) {
        opened--;
      }
    }
    if (opened > 0) {
      _add(')');
    } else {
      _add('(');
    }
  }

  void _add(String s) {
    textEditingController.text += s;

    // On the next frame, the textEditingController.text will update the
    // dimensions of the scrollable viewport.
    WidgetsBinding.instance!
        .addPostFrameCallback((_) => textEditingScrollController.animateTo(
              textEditingScrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 100),
              curve: Curves.easeInOut,
            ));
  }

  void onDel() {
    final contents = textEditingController.text;
    if (contents.isEmpty) {
      return;
    }
    textEditingController.text = contents.substring(0, contents.length - 1);
  }

  void onPressedSpecial(SpecialKind kind) {
    switch (kind) {
      case SpecialKind.ac:
        onClear();
        break;
      case SpecialKind.parens:
        onParens();
        break;
      case SpecialKind.mod:
        _addOp('%');
        break;
      case SpecialKind.div:
        _addOp('/');
        break;
      case SpecialKind.mul:
        _addOp('*');
        break;
      case SpecialKind.minus:
        _addOp('-');
        break;
      case SpecialKind.plus:
        _addOp('+');
        break;
      case SpecialKind.equals:
        onEquals();
        break;
      case SpecialKind.del:
        onDel();
        break;
      case SpecialKind.comma:
        _add(',');
        break;
      case SpecialKind.sqrt:
        _add('sqrt(');
        break;
      case SpecialKind.pi:
        _add('pi');
        break;
      case SpecialKind.pow:
        _addOp('^');
        break;
      case SpecialKind.fac:
        _add('!');
        break;
      case SpecialKind.degRad:
        isDeg.value = !isDeg.value;
        break;
      case SpecialKind.inv:
        isInverted.value = !isInverted.value;
        break;
      case SpecialKind.e:
        _add('e');
        break;
      case SpecialKind.ln:
        _add('ln(');
        break;
      case SpecialKind.log:
        _add('log(');
        break;
      case SpecialKind.sin:
        _add('sin(');
        break;
      case SpecialKind.cos:
        _add('cos(');
        break;
      case SpecialKind.tan:
        _add('tan(');
        break;
      case SpecialKind.squared:
        _add('^2');
        break;
      case SpecialKind.arcSin:
        _add('arcsin(');
        break;
      case SpecialKind.arcCos:
        _add('arccos(');
        break;
      case SpecialKind.arcTan:
        _add('arctan(');
        break;
      case SpecialKind.powE:
        _add('e^');
        break;
      case SpecialKind.pow10:
        _add('10^');
        break;
      case SpecialKind.pow2:
        _add('2^');
        break;
    }
  }
}

enum SpecialKind {
  ac,
  parens,
  mod,
  div,
  mul,
  minus,
  plus,
  equals,
  del,
  comma,
  sqrt,
  pi,
  pow,
  fac,
  degRad,
  inv,
  e,
  ln,
  log,
  sin,
  cos,
  tan,
  squared,
  arcSin,
  arcCos,
  arcTan,
  powE,
  pow10,
  pow2,
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
