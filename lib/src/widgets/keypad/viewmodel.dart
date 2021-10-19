import 'package:calculator/src/controllers/calc.dart';
import 'package:flutter/material.dart';

import '../../model.dart';

class ButtonViewModel {
  const ButtonViewModel._();
}

class Digit extends ButtonViewModel {
  final int num;

  const Digit(this.num) : super._();
}

class InversibleSpecial extends ButtonViewModel {
  final SpecialKind kind;
  final SpecialKind invertedKind;
  final Widget child;
  final Widget invertedChild;

  const InversibleSpecial(
    this.kind,
    this.invertedKind,
    this.child,
    this.invertedChild,
  ) : super._();
}

class Special extends ButtonViewModel {
  final SpecialKind kind;
  final Widget child;

  const Special(this.kind, this.child) : super._();
}

abstract class KeypadDigits {
  static const kAdditionalKeyboardVisibleKeys = [
    [$sqrt, $pi, $pow, $fac]
  ];
  static const kAdditionalKeyboardHiddenKeys = [
    [$degRad, $sin, $cos, $tan],
    [$inv, $e, $ln, $log],
  ];
  static const kKeypadKeys = [
    [$ac, $parens, $mod, $div],
    [$7, $8, $9, $mul],
    [$4, $5, $6, $minus],
    [$1, $2, $3, $plus],
    [$0, $comma, $del, $equals],
  ];
  static const kHorizontalTinyKeypadKeys = [
    [$7, $8, $9, $div, $ac],
    [$4, $5, $6, $mul, $parens],
    [$1, $2, $3, $minus, $mod],
    [$0, $comma, $del, $plus, $equals],
  ];
  static const kHorizontalKeypadKeys = [
    [$degRad, $sqrt, $pi, $7, $8, $9, $div, $ac],
    [$inv, $pow, $fac, $4, $5, $6, $mul, $parens],
    [$sin, $cos, $tan, $1, $2, $3, $minus, $mod],
    [$e, $ln, $log, $0, $comma, $del, $plus, $equals],
  ];

  static const kKeypadAccent1Keys = {$equals};
  static const kKeypadAccent2Keys = {$div, $mul, $parens, $minus, $mod, $plus};
  static const kKeypadAccent3Keys = {$ac};
  static const kKeypadNeutralKeys = {
    $0,
    $1,
    $2,
    $3,
    $4,
    $5,
    $6,
    $7,
    $8,
    $9,
    $comma,
    $del
  };

  /// Additional keypad fixed keys
  static const $sqrt = InversibleSpecial(
    SpecialKind.sqrt,
    SpecialKind.pow2,
    Text('√'),
    Text('x²'),
  );
  static const $pi = Special(SpecialKind.pi, Text('π'));
  static const $pow = Special(SpecialKind.pow, Text('^'));
  static const $fac = Special(SpecialKind.fac, Text('!'));

  /// Additional keypad hidden keys
  static const $degRad = Special(SpecialKind.degRad, _DegRad());
  static const $sin = InversibleSpecial(
    SpecialKind.sin,
    SpecialKind.arcSin,
    Text('sin'),
    Text('sin⁻¹'),
  );
  static const $cos = InversibleSpecial(
    SpecialKind.cos,
    SpecialKind.arcCos,
    Text('cos'),
    Text('cos⁻¹'),
  );
  static const $tan = InversibleSpecial(
    SpecialKind.tan,
    SpecialKind.arcTan,
    Text('tan'),
    Text('tan⁻¹'),
  );

  static const $inv = Special(SpecialKind.inv, Text('INV'));
  static const $e = Special(SpecialKind.e, Text('e'));
  static const $ln = InversibleSpecial(
    SpecialKind.ln,
    SpecialKind.powE,
    Text('ln'),
    Text('eⁿ'),
  );
  static const $log = InversibleSpecial(
    SpecialKind.log,
    SpecialKind.pow10,
    Text('log'),
    Text('10ⁿ'),
  );

  /// Digits
  static const $0 = Digit(0);
  static const $1 = Digit(1);
  static const $2 = Digit(2);
  static const $3 = Digit(3);
  static const $4 = Digit(4);
  static const $5 = Digit(5);
  static const $6 = Digit(6);
  static const $7 = Digit(7);
  static const $8 = Digit(8);
  static const $9 = Digit(9);

  /// Keypad additional keys
  static const $div = Special(SpecialKind.div, Text('÷'));
  static const $mod = Special(SpecialKind.mod, Text('%'));
  static const $parens = Special(SpecialKind.parens, Text('()'));
  static const $ac = Special(
      SpecialKind.ac,
      Padding(
        padding: EdgeInsets.all(1.0),
        child: Text('AC'),
      ));
  static const $equals = Special(SpecialKind.equals, Text('='));
  static const $del = Special(
      SpecialKind.del,
      Padding(
        padding: EdgeInsets.all(4.0),
        child: Icon(Icons.backspace_outlined),
      ));
  static const $comma = Special(SpecialKind.comma, Text(','));
  static const $plus = Special(SpecialKind.plus, Text('+'));
  static const $minus = Special(SpecialKind.minus, Text('-'));
  static const $mul = Special(
      SpecialKind.mul,
      Padding(
        padding: EdgeInsets.all(4.0),
        child: Icon(Icons.close),
      ));
}

class _DegRad extends StatelessWidget {
  const _DegRad({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: CalcController.of(context).logic.isDeg,
      builder: (_, __) => Text(
        CalcController.of(context).logic.isDeg.value ? 'DEG' : 'RAD',
      ),
    );
  }
}
