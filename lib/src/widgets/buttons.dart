// ignore_for_file: unnecessary_null_comparison

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

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

class CalcButton extends ButtonStyleButton {
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
  static ButtonStyle styleFrom({
    Color? primary,
    Color? onSurface,
    Color? backgroundColor,
    Color? shadowColor,
    double? elevation,
    TextStyle? textStyle,
    EdgeInsetsGeometry? padding,
    BorderSide? side,
    OutlinedBorder? shape,
    MouseCursor? enabledMouseCursor,
    MouseCursor? disabledMouseCursor,
    VisualDensity? visualDensity,
    MaterialTapTargetSize? tapTargetSize,
    Duration? animationDuration,
    bool? enableFeedback,
    AlignmentGeometry? alignment,
    InteractiveInkFeatureFactory? splashFactory,
  }) {
    final MaterialStateProperty<Color?>? foregroundColor =
        (onSurface == null && primary == null)
            ? null
            : _TextButtonDefaultForeground(primary, onSurface);
    final MaterialStateProperty<Color?>? overlayColor =
        (primary == null) ? null : _TextButtonDefaultOverlay(primary);
    final MaterialStateProperty<MouseCursor>? mouseCursor =
        (enabledMouseCursor == null && disabledMouseCursor == null)
            ? null
            : _TextButtonDefaultMouseCursor(
                enabledMouseCursor!, disabledMouseCursor!);

    return ButtonStyle(
      textStyle: ButtonStyleButton.allOrNull<TextStyle>(textStyle),
      backgroundColor: ButtonStyleButton.allOrNull<Color>(backgroundColor),
      foregroundColor: foregroundColor,
      overlayColor: overlayColor,
      shadowColor: ButtonStyleButton.allOrNull<Color>(shadowColor),
      elevation: ButtonStyleButton.allOrNull<double>(elevation),
      padding: ButtonStyleButton.allOrNull<EdgeInsetsGeometry>(padding),
      side: ButtonStyleButton.allOrNull<BorderSide>(side),
      shape: ButtonStyleButton.allOrNull<OutlinedBorder>(shape) ??
          _CalcButtonDefaultShape(),
      minimumSize: MaterialStateProperty.all(Size.zero),
      maximumSize: MaterialStateProperty.all(Size.infinite),
      mouseCursor: mouseCursor,
      visualDensity: visualDensity,
      tapTargetSize: tapTargetSize,
      animationDuration: animationDuration,
      enableFeedback: enableFeedback,
      alignment: alignment,
      splashFactory: splashFactory,
    );
  }

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

    return styleFrom(
      primary: colorScheme.primary,
      onSurface: colorScheme.onSurface,
      backgroundColor: Colors.transparent,
      shadowColor: theme.shadowColor,
      elevation: 0,
      textStyle: theme.textTheme.button,
      padding: scaledPadding,
      enabledMouseCursor: SystemMouseCursors.click,
      disabledMouseCursor: SystemMouseCursors.forbidden,
      visualDensity: theme.visualDensity,
      tapTargetSize: theme.materialTapTargetSize,
      animationDuration: kThemeChangeDuration,
      enableFeedback: true,
      alignment: Alignment.center,
      splashFactory: Theme.of(context).splashFactory,
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

@immutable
class _TextButtonDefaultForeground extends MaterialStateProperty<Color?> {
  _TextButtonDefaultForeground(this.primary, this.onSurface);

  final Color? primary;
  final Color? onSurface;

  @override
  Color? resolve(Set<MaterialState> states) {
    if (states.contains(MaterialState.disabled)) {
      return onSurface?.withOpacity(0.38);
    }
    return primary;
  }

  @override
  String toString() {
    return '{disabled: ${onSurface?.withOpacity(0.38)}, otherwise: $primary}';
  }
}

@immutable
class _TextButtonDefaultOverlay extends MaterialStateProperty<Color?> {
  _TextButtonDefaultOverlay(this.primary);

  final Color primary;

  @override
  Color? resolve(Set<MaterialState> states) {
    if (states.contains(MaterialState.hovered)) {
      return primary.withOpacity(0.04);
    }
    if (states.contains(MaterialState.focused) ||
        states.contains(MaterialState.pressed)) {
      return primary.withOpacity(0.12);
    }
    return null;
  }

  @override
  String toString() {
    return '{hovered: ${primary.withOpacity(0.04)}, focused,pressed: ${primary.withOpacity(0.12)}, otherwise: null}';
  }
}

@immutable
class _TextButtonDefaultMouseCursor extends MaterialStateProperty<MouseCursor>
    with Diagnosticable {
  _TextButtonDefaultMouseCursor(this.enabledCursor, this.disabledCursor);

  final MouseCursor enabledCursor;
  final MouseCursor disabledCursor;

  @override
  MouseCursor resolve(Set<MaterialState> states) {
    if (states.contains(MaterialState.disabled)) return disabledCursor;
    return enabledCursor;
  }
}
