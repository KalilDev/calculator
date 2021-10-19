import 'dart:developer';

import 'package:flutter/material.dart';

/// Scroll physics used by a [PageView].
///
/// These physics cause the page view to snap to page boundaries.
///
/// See also:
///
///  * [ScrollPhysics], the base class which defines the API for scrolling
///    physics.
///  * [PageView.physics], which can override the physics used by a page view.
class SnapToEdgesAndPointsPhysics extends ScrollPhysics {
  /// Creates physics for a [PageView].
  const SnapToEdgesAndPointsPhysics(
      {required this.points, ScrollPhysics? parent})
      : super(parent: parent);

  final List<double> points;

  @override
  SnapToEdgesAndPointsPhysics applyTo(ScrollPhysics? ancestor) {
    return SnapToEdgesAndPointsPhysics(
        points: points, parent: buildParent(ancestor));
  }

  // 0 = start of scroll
  // 1 = points[0]
  // 2 = points[1]..
  // n = n < points.length ? points[n] : end of scroll
  double _getPoint(ScrollMetrics position) {
    final sortedPoints = points.toList()..sort((a, b) => a.compareTo(b));
    final currentPos = position.pixels;
    int startI = 0;
    double start = 0.0;
    double? end;
    for (var i = 0; i < sortedPoints.length; i++) {
      final point = sortedPoints[i];
      if (point < currentPos) {
        start = point;
        startI = i + 1;
      } else {
        end = point;
        break;
      }
    }
    end ??= position.viewportDimension;
    final range = end - start;
    return startI + (currentPos - start) / range;
  }

  double _getPixels(ScrollMetrics position, int point) {
    if (point == 0) {
      return 0.0;
    }
    if (point > points.length) {
      return position.viewportDimension;
    }
    return points[point - 1];
  }

  List<double> _targetPoints(ScrollMetrics position) {
    return [
      if (!points.contains(0.0)) 0.0,
      ...points,
      if (!points.contains(position.maxScrollExtent)) position.maxScrollExtent,
    ]..sort();
  }

  double _getTargetPixels(
      ScrollMetrics position, Tolerance tolerance, double velocity) {
    double point = _getPoint(position);

    if (velocity < -tolerance.velocity) {
      point -= 0.1;
    } else if (velocity > tolerance.velocity) {
      point += 0.1;
    }
    return _getPixels(position, point.round());
  }

  // TODO: finish the new algorithm
  double _newGetTargetPixels(
      ScrollMetrics position, Tolerance tolerance, double velocity) {
    final pixels = position.pixels;

    final targets = _targetPoints(position);
    targets
      ..add(pixels)
      ..sort();
    final indexAfterPixels = targets.indexOf(pixels);
    targets.removeAt(indexAfterPixels);
    final indexBeforePixels =
        (indexAfterPixels - 1).clamp(0, double.infinity).toInt();
    final indexClosestToPixels = (targets[indexAfterPixels] - pixels).abs() >
            (targets[indexBeforePixels] - pixels).abs()
        ? indexBeforePixels
        : indexAfterPixels;

    if (velocity < -tolerance.velocity) {
      return targets[indexBeforePixels];
    } else if (velocity > tolerance.velocity) {
      return targets[indexAfterPixels];
    }
    return targets[indexClosestToPixels];
  }

  static const double _epsilon = 0.01;

  @override
  Simulation? createBallisticSimulation(
      ScrollMetrics position, double velocity) {
    final Tolerance tolerance = this.tolerance;
    final double target =
        _newGetTargetPixels(position, tolerance, velocity).clamp(
      position.minScrollExtent,
      position.maxScrollExtent,
    );
    // TODO: Remove this workaround for the broken _getTargetPixels
    /*if (velocity.abs() < _epsilon) {
      return null;
    }*/
    if ((target - position.pixels).abs() > _epsilon) {
      print('Moving to target $target, velocity: $velocity, '
          'pixels: ${position.pixels}');
      return ScrollSpringSimulation(spring, position.pixels, target, velocity,
          tolerance: tolerance);
    }
    return null;
  }

  @override
  bool get allowImplicitScrolling => false;
}
