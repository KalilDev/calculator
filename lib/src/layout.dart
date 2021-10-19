import 'package:flutter/cupertino.dart';

class CalculatorLayout {
  final CalculatorLayoutType type;
  final double margin;
  final double gutter;
  final double minKeypadPadding, maxKeypadPadding, maxVisibleKeypadPadding;

  CalculatorLayout(
    this.type,
    this.margin,
    this.gutter,
    this.minKeypadPadding,
    this.maxKeypadPadding,
    this.maxVisibleKeypadPadding,
  );

  factory CalculatorLayout.fromViewSize(Size viewSize) {
    final aspectRatio = viewSize.aspectRatio;
    CalculatorLayoutType type;
    if (aspectRatio > 0.88) {
      type = viewSize.shortestSide > 300
          ? CalculatorLayoutType.horizontalExpanded
          : CalculatorLayoutType.tiny;
    } else {
      type = CalculatorLayoutType.standard;
    }
    double margin = 19;
    double gutter = 10;
    double additionalButtonSize = 48;
    double _estimateButtonSize(double keyboardHeight) {
      var size = keyboardHeight;
      if (type == CalculatorLayoutType.standard) {
        size -= additionalButtonSize;
        size -= gutter;
      }
      if (type != CalculatorLayoutType.tiny) {
        size -= 2 * margin;
      }
      if (type == CalculatorLayoutType.horizontalExpanded) {
        size -= 3 * gutter;
      } else if (type == CalculatorLayoutType.standard) {
        size -= 4 * gutter;
      }

      switch (type) {
        case CalculatorLayoutType.standard:
          return size / 5;
        case CalculatorLayoutType.horizontalExpanded:
        case CalculatorLayoutType.tiny:
          return size / 4;
      }
    }

    final standardMinButtonPaddingSize = viewSize.shortestSide / 60;
    final standardMaxButtonPaddingSize = 3 * standardMinButtonPaddingSize;

    final minButtonSize = _estimateButtonSize(viewSize.height / 2);
    final maxButtonSize = _estimateButtonSize(viewSize.height * 2 / 3);

    return CalculatorLayout(
      type,
      margin,
      gutter,
      standardMinButtonPaddingSize,
      standardMaxButtonPaddingSize.clamp(0.0, maxButtonSize / 4),
      minButtonSize / 4,
    );
  }

  static CalculatorLayout of(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<InheritedCalculatorLayout>()!
      .layout;
}

enum CalculatorLayoutType {
  standard,
  horizontalExpanded,
  tiny,
}

class InheritedCalculatorLayout extends InheritedWidget {
  final CalculatorLayout layout;

  const InheritedCalculatorLayout({
    Key? key,
    required this.layout,
    required Widget child,
  }) : super(key: key, child: child);

  @override
  bool updateShouldNotify(InheritedCalculatorLayout oldWidget) =>
      layout != oldWidget.layout;
}
