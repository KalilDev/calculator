import 'package:calculator/src/other/initable.dart';
import 'package:flutter/foundation.dart' show ValueChanged, ValueNotifier;
import 'package:math_expressions/math_expressions.dart';
import 'dart:math' as math;
import '../model.dart';
import 'package:hive/hive.dart';

class _LogicSnapshot {
  final List<HistoryEntry> historyEntries;
  final String currentExpression;
  final bool isDeg;
  final bool isInverted;

  _LogicSnapshot(
    this.historyEntries,
    this.currentExpression,
    this.isDeg,
    this.isInverted,
  );
}

class HistoryEntryAdapter implements TypeAdapter<HistoryEntry> {
  const HistoryEntryAdapter();
  HistoryEntry _readV0(BinaryReader reader) => HistoryEntry(
        reader.readString(),
        reader.readString(),
      );

  @override
  HistoryEntry read(BinaryReader reader) {
    // version
    switch (reader.readUint32()) {
      case 0:
        return _readV0(reader);
      default:
        throw StateError('Invalid HistoryEntry reader version!');
    }
  }

  @override
  final int typeId = 1;

  @override
  void write(BinaryWriter writer, HistoryEntry obj) {
    writer
      // version
      ..writeUint32(0)
      ..writeString(obj.expression)
      ..writeString(obj.result);
  }
}

class _CalcLogicStorage extends InitableDisposable {
  final ValueChanged<_LogicSnapshot> onLoad;
  _CalcLogicStorage(this.onLoad);

  late Box _box;

  @override
  void init() async {
    super.init();
    _box = await Hive.openBox('calcLogicStorage');
    _maybeSendOnLoad();
  }

  @override
  void dispose() async {
    await _box.close();
    super.dispose();
  }

  void store(_LogicSnapshot snapshot) {
    _box.put('expression', snapshot.currentExpression);
    _box.put('historyEntries', snapshot.historyEntries);
    _box.put('isDeg', snapshot.isDeg);
    _box.put('isInverted', snapshot.isInverted);
  }

  void _maybeSendOnLoad() {
    if (!_box.containsKey('expression')) {
      return;
    }
    final expression = _box.get('expression') as String;
    final history = (_box.get('historyEntries') as List).cast<HistoryEntry>();
    final isDeg = _box.get('isDeg') as bool;
    final isInverted = _box.get('isInverted') as bool;
    onLoad(_LogicSnapshot(history, expression, isDeg, isInverted));
  }
}

/// The logical part of the Calculator
class CalcLogicController extends InitableDisposable {
  late final ValueNotifier<bool> isDeg = ValueNotifier(false)
    ..addListener(_onStateUpdate);
  late final ValueNotifier<bool> isInverted = ValueNotifier(false)
    ..addListener(_onStateUpdate);
  late final ValueNotifier<List<HistoryEntry>> history = ValueNotifier([])
    ..addListener(_onStateUpdate);
  late final ValueNotifier<String> expression = ValueNotifier('')
    ..addListener(_onExpressionChanged)
    ..addListener(_onStateUpdate);
  final ValueNotifier<String> expressionResult = ValueNotifier('');
  late final _CalcLogicStorage storage;

  void init() {
    super.init();
    storage = _CalcLogicStorage(_onStorageLoad);
  }

  bool _isLoadingStorage = false;
  void _onStateUpdate() {
    if (_isLoadingStorage) {
      return;
    }
    storage.store(_LogicSnapshot(
      history.value,
      expression.value,
      isDeg.value,
      isInverted.value,
    ));
  }

  void _onStorageLoad(_LogicSnapshot snap) {
    _isLoadingStorage = true;

    history.value = snap.historyEntries;
    expression.value = snap.currentExpression;
    isDeg.value = snap.isDeg;
    isInverted.value = snap.isInverted;

    _isLoadingStorage = false;
  }

  @override
  void dispose() {
    isDeg.dispose();
    isInverted.dispose();
    history.dispose();
    expression.dispose();
    expressionResult.dispose();
    storage.dispose();
    super.dispose();
  }

  void insertExpression(String expression) {
    expressionResult.value += expression;
  }

  void onEquals() {
    final result = expressionResult.value;
    if (result.isEmpty) {
      return;
    }
    if (result.trim() == 'ERRO') {
      return;
    }

    final newHistory = history.value.toList()
      ..add(HistoryEntry(expression.value, result));
    history.value = newHistory;
    expression.value = result;
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
    // TODO
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

  void _onExpressionChanged() {
    final content = expression.value;
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

  void clearHistory() => history.value = [];

  void onDigit(int digit) {
    assert(digit >= 0 && digit <= 9);
    _add(digit.toString());
  }

  void onClear() {
    expression.value = '';
  }

  void _addOp(String op) {
    _add(' $op ');
  }

  void onParens() {
    final contents = expression.value;
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
    expression.value += s;
  }

  void onDel() {
    final contents = expression.value;
    if (contents.isEmpty) {
      return;
    }
    expression.value = contents.substring(0, contents.length - 1);
  }

  void onSpecial(SpecialKind kind) {
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
