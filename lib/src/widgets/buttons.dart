// ignore_for_file: unnecessary_null_comparison

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:material_widgets/material_widgets.dart';

class _CalcButtonChildWrapper extends StatelessWidget {
  final Widget child;
  const _CalcButtonChildWrapper({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints.expand(),
      child: FittedBox(
        fit: BoxFit.contain,
        child: child,
      ),
    );
  }
}

class CalcButton extends FilledButton {
  CalcButton({
    Key? key,
    required VoidCallback? onPressed,
    VoidCallback? onLongPress,
    ValueChanged<bool>? onHover,
    ValueChanged<bool>? onFocusChange,
    ButtonStyle? style,
    FocusNode? focusNode,
    bool autofocus = false,
    Clip clipBehavior = Clip.none,
    bool wrapChild = true,
    required Widget child,
  }) : super(
          key: key,
          onPressed: onPressed,
          onLongPress: onLongPress,
          onHover: onHover,
          onFocusChange: onFocusChange,
          style: style,
          focusNode: focusNode,
          autofocus: autofocus,
          clipBehavior: clipBehavior,
          child: wrapChild ? _CalcButtonChildWrapper(child: child) : child,
        );
  factory CalcButton.digit(
    String digit, {
    required VoidCallback onTap,
    Color? backgroundColor,
    Color? foregroundColor,
    MaterialStateProperty<EdgeInsetsGeometry?>? padding,
  }) =>
      CalcButton(
        onPressed: onTap,
        child: Text(digit),
        style: ButtonStyle(
          padding: padding,
          backgroundColor: backgroundColor == null
              ? null
              : MaterialStateColor.resolveWith((states) => backgroundColor),
          foregroundColor: foregroundColor == null
              ? null
              : MaterialStateColor.resolveWith((states) => foregroundColor),
        ),
      );

  @override
  ButtonStyle defaultStyleOf(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    final EdgeInsetsGeometry scaledPadding = ButtonStyleButton.scaledPadding(
      /*const EdgeInsets.all(8),
      const EdgeInsets.symmetric(horizontal: 8),
      const EdgeInsets.symmetric(horizontal: 4),*/
      const EdgeInsets.symmetric(vertical: 24),
      const EdgeInsets.symmetric(vertical: 24),
      const EdgeInsets.symmetric(vertical: 24),
      MediaQuery.maybeOf(context)?.textScaleFactor ?? 1,
    );

    return super.defaultStyleOf(context).copyWith(
          padding: MaterialStateProperty.all(scaledPadding),
          shape: _CalcButtonDefaultShape(),
          fixedSize: MaterialStateProperty.all(Size.infinite),
          maximumSize: MaterialStateProperty.all(Size.infinite),
          minimumSize: MaterialStateProperty.all(Size.zero),
        );
  }

  @override
  ButtonStyle? themeStyleOf(BuildContext context) =>
      CalcButtonTheme.of(context).style;
}

class CalcButtonThemeData with Diagnosticable {
  const CalcButtonThemeData({this.style});

  final ButtonStyle? style;

  static CalcButtonThemeData? lerp(
      CalcButtonThemeData? a, CalcButtonThemeData? b, double t) {
    assert(t != null);
    if (a == null && b == null) return null;
    return CalcButtonThemeData(
      style: ButtonStyle.lerp(a?.style, b?.style, t),
    );
  }

  @override
  int get hashCode {
    return style.hashCode;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is CalcButtonThemeData && other.style == style;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(
        DiagnosticsProperty<ButtonStyle>('style', style, defaultValue: null));
  }
}

class CalcButtonTheme extends InheritedTheme {
  const CalcButtonTheme({
    Key? key,
    required this.data,
    required Widget child,
  })  : assert(data != null),
        super(key: key, child: child);

  /// The configuration of this theme.
  final CalcButtonThemeData data;

  static CalcButtonThemeData of(BuildContext context) {
    final CalcButtonTheme? buttonTheme =
        context.dependOnInheritedWidgetOfExactType<CalcButtonTheme>();
    return buttonTheme?.data ?? const CalcButtonThemeData();
  }

  @override
  Widget wrap(BuildContext context, Widget child) {
    return CalcButtonTheme(data: data, child: child);
  }

  @override
  bool updateShouldNotify(CalcButtonTheme oldWidget) => data != oldWidget.data;
}

class _CalcButtonDefaultShape extends MaterialStateProperty<OutlinedBorder> {
  @override
  OutlinedBorder resolve(Set<MaterialState> states) {
    if (states.contains(MaterialState.pressed)) {
      return RoundedRectangleBorder(borderRadius: BorderRadius.circular(16));
    }
    return const StadiumBorder();
  }
}
