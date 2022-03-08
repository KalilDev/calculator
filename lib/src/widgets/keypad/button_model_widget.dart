import 'package:calculator/src/controllers/calc.dart';
import 'package:flutter/material.dart';
import 'package:material_widgets/material_widgets.dart';

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

  static Color neutralBg(BuildContext context) {
    final scheme = context.colorScheme;
    return context.elevation.level2.overlaidColor(
      scheme.surface,
      MD3ElevationLevel.surfaceTint(scheme),
    );
  }

  static Color neutralFg(BuildContext context) => context.colorScheme.onSurface;

  @override
  Widget build(BuildContext context) {
    final model = this.model;
    final scheme = context.colorScheme;
    final stateLayerOpacity = context.stateOverlayOpacity;
    ButtonStyle style;
    if (KeypadDigits.kKeypadAccent1Keys.contains(model)) {
      style = FilledButton.styleFrom(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        disabledColor: scheme.onSurface,
        stateLayerOpacityTheme: stateLayerOpacity,
      );
    } else if (KeypadDigits.kKeypadAccent2Keys.contains(model)) {
      style = FilledButton.styleFrom(
        backgroundColor: scheme.secondary,
        foregroundColor: scheme.onSecondary,
        disabledColor: scheme.onSurface,
        stateLayerOpacityTheme: stateLayerOpacity,
      );
    } else if (KeypadDigits.kKeypadAccent3Keys.contains(model)) {
      style = FilledButton.styleFrom(
        backgroundColor: scheme.tertiary,
        foregroundColor: scheme.onTertiary,
        disabledColor: scheme.onSurface,
        stateLayerOpacityTheme: stateLayerOpacity,
      );
    } else if (KeypadDigits.kKeypadNeutralKeys.contains(model)) {
      style = FilledButton.styleFrom(
        backgroundColor: neutralBg(context),
        foregroundColor: neutralFg(context),
        disabledColor: scheme.onSurface,
        stateLayerOpacityTheme: stateLayerOpacity,
      );
    } else {
      style = FilledButton.styleFrom(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        disabledColor: scheme.onSurface,
        stateLayerOpacityTheme: stateLayerOpacity,
      );
    }

    return CalcButton(
      onPressed: _onPressed(context),
      child: _child(context),
      style: style.merge(ButtonStyle(
          padding: MaterialStateProperty.all(padding),
          fixedSize: MaterialStateProperty.all(fixedSize))),
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
