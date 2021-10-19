import 'package:calculator/src/controllers/calc.dart';
import 'package:flutter/material.dart';
import 'package:material_you/material_you.dart';

import '../buttons.dart';
import 'viewmodel.dart';

class ButtonModelWidget extends StatelessWidget {
  final ButtonViewModel model;
  final EdgeInsetsGeometry padding;
  final Size? fixedSize;

  ButtonModelWidget({
    required this.model,
    required this.padding,
    this.fixedSize,
  }) : super(key: ObjectKey(model));

  Widget _child(BuildContext context) {
    final model = this.model;
    if (model is Digit) {
      return Text(model.num.toString());
    }
    if (model is Special) {
      return model.child;
    }
    if (model is InversibleSpecial) {
      return ValueListenableBuilder<bool>(
        valueListenable: CalcController.of(context).logic.isInverted,
        builder: (context, isInverted, _) =>
            isInverted ? model.invertedChild : model.child,
      );
    }
    throw TypeError();
  }

  static Color neutralBg(BuildContext context) => context.isDark
      ? context.materialYouColors.neutral1[800]!
      : context.materialYouColors.neutral1[50]!;

  static Color neutralFg(BuildContext context) =>
      context.isDark ? Colors.white.withOpacity(0.87) : Colors.black87;

  @override
  Widget build(BuildContext context) {
    final model = this.model;
    final theme = context.materialYouColors;
    Color? fg, bg;
    if (KeypadDigits.kKeypadAccent1Keys.contains(model)) {
      bg = theme.accent1.shade100;
      fg = theme.accent1.shade800;
    } else if (KeypadDigits.kKeypadAccent2Keys.contains(model)) {
      bg = theme.accent2.shade100;
      fg = theme.accent2.shade800;
    } else if (KeypadDigits.kKeypadAccent3Keys.contains(model)) {
      bg = theme.accent3.shade100;
      fg = theme.accent3.shade800;
    } else if (KeypadDigits.kKeypadNeutralKeys.contains(model)) {
      bg = neutralBg(context);
      fg = neutralFg(context);
    }

    return CalcButton(
      onPressed: _onPressed(context),
      child: _child(context),
      style: ButtonStyle(
          foregroundColor: MaterialStateProperty.all(
              fg ?? DefaultTextStyle.of(context).style.color),
          backgroundColor: MaterialStateProperty.all(bg),
          padding: MaterialStateProperty.all(padding),
          fixedSize: MaterialStateProperty.all(fixedSize)),
    );
  }

  VoidCallback _onPressed(BuildContext context) => () {
        final controller = CalcController.of(context);
        final model = this.model;
        if (model is Digit) {
          controller.logic.onDigit(model.num);
          return;
        }
        if (model is Special) {
          controller.logic.onSpecial(model.kind);
          return;
        }
        if (model is InversibleSpecial) {
          controller.logic.onSpecial(controller.logic.isInverted.value
              ? model.invertedKind
              : model.kind);
          return;
        }
        throw TypeError();
      };
}
