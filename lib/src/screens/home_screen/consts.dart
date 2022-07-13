abstract class HomeViewConstants {
  static const maxKeypadHeightFrac = 0.7;
  static const minKeypadHeightFrac = 0.5;
  static const keypadDeltaFrac = maxKeypadHeightFrac - minKeypadHeightFrac;
  static const headerHeightFrac = 1 - maxKeypadHeightFrac;
  // 22 on 1080
  static const minHeaderBottomPadding = 22.0;
  // 54 on 1080
  static const maxHeaderBottomPadding = 54.0;
  static const headerBottomPaddingDelta =
      minHeaderBottomPadding - maxHeaderBottomPadding;
}
