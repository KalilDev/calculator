import 'package:flutter/foundation.dart';

abstract class InitableDisposable {
  InitableDisposable() {
    init();
  }

  @mustCallSuper
  void init() {}

  @mustCallSuper
  void dispose() {}
}
