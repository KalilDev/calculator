import 'package:calculator/src/controllers/calc.dart';
import 'package:calculator/src/layout.dart';
import 'package:calculator/src/other/monadic_value_listenable.dart';
import 'package:calculator/src/widgets/buttons.dart';
import 'package:flutter/material.dart';
import 'package:material_you/material_you.dart';
import 'dart:math' as math;

import 'keypad/button_model_widget.dart';
import 'keypad/viewmodel.dart';

extension Separated<T> on Iterable<T> {
  Iterable<T> separatedWith(T separator) sync* {
    bool isFirst = true;
    for (final v in this) {
      if (isFirst) {
        isFirst = false;
      } else {
        yield separator;
      }
      yield v;
    }
  }
}

class Keypad extends StatefulWidget {
  const Keypad({Key? key}) : super(key: key);

  @override
  State<Keypad> createState() => _KeypadState();
}

class _KeypadState extends State<Keypad> with SingleTickerProviderStateMixin {
  late final AnimationController _expansionController = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 200));
  late final Animation<double> _expansion =
      CurvedAnimation(curve: Curves.easeInOut, parent: _expansionController);
  final Animatable<double> _keypadPaddingTween = Tween(begin: 24.0, end: 16.0);
  final Animatable<double> _firstLevelPaddingFactorTween =
      Tween<double>(begin: 0.0, end: -6.0);

  @override
  void dispose() {
    _expansionController.dispose();
    super.dispose();
  }

  void _toggle() {
    if (_expansionController.isAnimating) {
      _expansionController.velocity > 0
          ? _expansionController.reverse()
          : _expansionController.forward();
      return;
    }
    _expansionController.isCompleted
        ? _expansionController.reverse()
        : _expansionController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final layout = CalculatorLayout.of(context);
    return GestureDetector(
      onVerticalDragStart: (_) {},
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: layout.margin,
          vertical:
              layout.type == CalculatorLayoutType.tiny ? 1.0 : layout.margin,
        ),
        child: Column(
          children: [
            if (layout.type == CalculatorLayoutType.standard) ...[
              _AdditionalKeypad(
                expansion: _expansion,
                onToggle: _toggle,
              ),
              SizedBox(height: layout.margin),
            ],
            Expanded(
              child: _keypad(
                context,
                _gutterTweenFrom(context),
                _maxKeypadPaddingTweenFrom(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Tween<double> _gutterTweenFrom(BuildContext context) =>
      Tween<double>(begin: CalculatorLayout.of(context).gutter, end: 4.0);

  static Tween<double> _maxKeypadPaddingTweenFrom(BuildContext context) {
    final layout = CalculatorLayout.of(context);

    return Tween(
      begin: layout.maxKeypadPadding,
      end: layout.maxVisibleKeypadPadding,
    );
  }

  Widget _keypad(
    BuildContext context,
    Tween<double> gutterTween,
    Tween<double> maxKeypadPaddingTween,
  ) {
    final layout = CalculatorLayout.of(context);
    final firstLevelScrollPadding = _firstLevelPaddingFactorTween
        .animate(CalcController.of(context).ui.firstLevelScrollAnimation);
    final firstLevelScrollGutter = gutterTween
        .animate(CalcController.of(context).ui.firstLevelScrollAnimation);
    final expansionPadding = _keypadPaddingTween.animate(_expansion);
    final expansionGutter = gutterTween.animate(_expansion);
    final maximumPadding = maxKeypadPaddingTween
        .animate(CalcController.of(context).ui.firstLevelScrollAnimation);

    Widget buildWidget(
      double expansionPadding,
      double firstLevelPaddingFactor,
      double maximumPadding,
      double expansionGutter,
      double firstLevelScrollGutter,
    ) =>
        _DigitsAndSpecialsKeypad(
          keypadPadding: (expansionPadding + firstLevelPaddingFactor)
              .clamp(layout.minKeypadPadding, maximumPadding)
              .toDouble(),
          gutter: math.min(expansionGutter, firstLevelScrollGutter),
        );

    return runValueListenableWidget(
      firstLevelScrollPadding.bind(
        (firstLevelScrollPadding) => firstLevelScrollGutter.bind(
          (firstLevelScrollGutter) => expansionPadding.bind(
            (expansionPadding) => expansionGutter.bind(
              (expansionGutter) => maximumPadding.map(
                (maximumPadding) => buildWidget(
                    expansionPadding,
                    firstLevelScrollPadding,
                    maximumPadding,
                    expansionGutter,
                    firstLevelScrollGutter),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AdditionalKeypad extends StatelessWidget {
  final Animation<double> expansion;
  final VoidCallback onToggle;
  const _AdditionalKeypad({
    Key? key,
    required this.expansion,
    required this.onToggle,
  }) : super(key: key);

  Widget button(BuildContext context) => SizedBox(
        height: 48,
        child: Center(
          child: CalcButton(
            wrapChild: false,
            onPressed: onToggle,
            child: RotationTransition(
              turns: Tween(begin: 0.0, end: 0.5).animate(expansion),
              child: const Icon(
                Icons.expand_less,
                size: 14,
              ),
            ),
            style: ButtonStyle(
              fixedSize: MaterialStateProperty.all(const Size.square(36)),
              foregroundColor: MaterialStateProperty.all(
                context.colorScheme.onSurfaceVariant,
              ),
              backgroundColor: MaterialStateProperty.all(
                ButtonModelWidget.neutralBg(context),
              ),
              padding: MaterialStateProperty.all(const EdgeInsets.all(12)),
              shape: MaterialStateProperty.resolveWith(
                (states) => states.contains(MaterialState.pressed)
                    ? RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4.0))
                    : const CircleBorder(),
              ),
            ),
          ),
        ),
      );

  Widget col(BuildContext context, List<Widget> rows) => Column(
        children: rows.toList(),
      );

  Widget _model(BuildContext context, ButtonViewModel model) =>
      ButtonModelWidget(
        model: model,
        padding: const EdgeInsets.all(8.0),
        fixedSize: const Size.fromHeight(48),
      );

  Widget mrow(BuildContext context, List<ButtonViewModel> models) => Row(
        children:
            models.map((e) => Expanded(child: _model(context, e))).toList(),
      );

  Widget transitionCol(BuildContext context, List<Widget> children) =>
      SizeTransition(
        sizeFactor: expansion,
        axisAlignment: 1,
        child: FadeTransition(
          opacity: Tween(begin: -2.0, end: 1.0).animate(expansion),
          child: Column(mainAxisSize: MainAxisSize.min, children: children),
        ),
      );

  Widget keypad(BuildContext context) => col(context, [
        for (final row in KeypadDigits.kAdditionalKeyboardVisibleKeys)
          mrow(context, row),
        transitionCol(
          context,
          [
            for (final row in KeypadDigits.kAdditionalKeyboardHiddenKeys)
              mrow(context, row)
          ],
        )
      ]);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: keypad(context)),
        SizedBox(width: CalculatorLayout.of(context).gutter),
        button(context),
      ],
    );
  }
}

class _DigitsAndSpecialsKeypad extends StatelessWidget {
  final double keypadPadding;
  final double gutter;
  const _DigitsAndSpecialsKeypad({
    Key? key,
    required this.keypadPadding,
    required this.gutter,
  }) : super(key: key);

  Widget col(BuildContext context, List<Widget> rows) {
    final layout = CalculatorLayout.of(context);
    return Column(
      children: rows
          .map((e) => Expanded(child: e))
          .cast<Widget>()
          .separatedWith(SizedBox(
            height:
                layout.type == CalculatorLayoutType.tiny ? 1.0 : layout.gutter,
          ))
          .toList(),
    );
  }

  Widget _model(BuildContext context, ButtonViewModel model) =>
      ButtonModelWidget(
        model: model,
        padding: EdgeInsets.symmetric(
          vertical: keypadPadding,
          horizontal: 2.0,
        ),
      );

  Widget mrow(BuildContext context, List<ButtonViewModel> models) => Row(
        children: models
            .map((e) => Expanded(child: _model(context, e)))
            .cast<Widget>()
            .separatedWith(SizedBox(
              width: CalculatorLayout.of(context).gutter,
            ))
            .toList(),
      );

  List<List<ButtonViewModel>> keys(BuildContext context) {
    switch (CalculatorLayout.of(context).type) {
      case CalculatorLayoutType.standard:
        return KeypadDigits.kKeypadKeys;
      case CalculatorLayoutType.horizontalExpanded:
        return KeypadDigits.kHorizontalKeypadKeys;
      case CalculatorLayoutType.tiny:
        return KeypadDigits.kHorizontalTinyKeypadKeys;
    }
  }

  @override
  Widget build(BuildContext context) {
    return col(context, [
      for (final row in keys(context)) mrow(context, row),
    ]);
  }
}
