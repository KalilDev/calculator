import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

extension MonadicValueListenable<T> on ValueListenable<T> {
  ValueListenable<T1> map<T1>(T1 Function(T) fn) =>
      _MappedValueListenable(this, fn);
  ValueListenable<T1> bind<T1>(ValueListenable<T1> Function(T) fn) =>
      _BoundValueListenable(this, fn);
}

class _MappedValueListenable<T, T1> extends ValueListenable<T1> {
  final ValueListenable<T> _base;
  final T1 Function(T) _mapper;

  _MappedValueListenable(this._base, this._mapper);

  @override
  void addListener(VoidCallback listener) => _base.addListener(listener);

  @override
  void removeListener(VoidCallback listener) => _base.removeListener(listener);

  @override
  T1 get value => _mapper(_base.value);
}

// TODO: This is not correct, because if an different instance is returned on
// mapped, it is not listened to.
class _BoundValueListenable<T, T1> extends ValueListenable<T1> {
  final ValueListenable<T> _base;
  final ValueListenable<T1> Function(T) _mapper;

  _BoundValueListenable(this._base, this._mapper);

  @override
  void addListener(VoidCallback listener) {
    _base.addListener(listener);
    _mapped.addListener(listener);
  }

  @override
  void removeListener(VoidCallback listener) {
    _base.removeListener(listener);
    _mapped.removeListener(listener);
  }

  ValueListenable<T1> get _mapped => _mapper(_base.value);

  @override
  T1 get value => _mapped.value;
}

Widget runValueListenableWidget(ValueListenable<Widget> self) =>
    ValueListenableBuilder<Widget>(
      valueListenable: self,
      builder: (context, child, _) => child,
    );

Widget runValueListenableWidgetBuilder(
  ValueListenable<Widget Function(BuildContext, Widget?)> self,
  Widget? child,
) =>
    ValueListenableBuilder<Widget Function(BuildContext, Widget?)>(
      valueListenable: self,
      builder: (context, childBuilder, child) => childBuilder(context, child),
      child: child,
    );
