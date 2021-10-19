import 'dart:ui';

import 'package:calculator/src/controllers/calc.dart';
import 'package:calculator/src/layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_you/material_you.dart';
import 'package:animations/animations.dart';
import '../model.dart';

class History extends StatelessWidget {
  const History({Key? key}) : super(key: key);

  Widget _appBar(BuildContext context) {
    final controller = CalcController.of(context);
    return _appBarTransition(
      context,
      AppBar(
        leading: IconButton(
          onPressed: controller.ui.scrollBack,
          icon: IconTheme.merge(
            data: const IconThemeData(opacity: 0.87),
            child: const Icon(Icons.arrow_back),
          ),
        ),
        titleTextStyle: Theme.of(context).textTheme.headline6!.copyWith(
              fontSize: lerpDouble(
                Theme.of(context).textTheme.headline6!.fontSize,
                Theme.of(context).textTheme.headline5!.fontSize,
                0.5,
              ),
            ),
        title: const Text(
          'Histórico',
        ),
        actions: [
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                child: const Text('Limpar'),
                onTap: controller.logic.clearHistory,
              ),
            ],
            icon: IconTheme.merge(
              data: const IconThemeData(opacity: 0.87),
              child: const Icon(Icons.more_vert),
            ),
          ),
        ],
      ),
    );
  }

  Widget _appBarTransition(BuildContext context, PreferredSizeWidget appBar) {
    final accent = context.materialYouColors.accent2;
    final bgColor = context.isDark ? accent.shade700 : accent.shade100;
    return SizeTransition(
      sizeFactor: CalcController.of(context).ui.secondLevelScrollAnimation,
      axisAlignment: 1,
      child: SizedBox.fromSize(
        size: appBar.preferredSize,
        child: Theme(
            data: Theme.of(context).copyWith(
              appBarTheme: AppBarTheme(
                backgroundColor: bgColor,
                foregroundColor: bgColor.textColor,
              ),
            ),
            child: appBar),
      ),
    );
  }

  Widget _noHistory(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.headline6!;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconTheme.merge(
            data: const IconThemeData(opacity: 0.6),
            child: const Icon(
              Icons.history,
            ),
          ),
          const SizedBox(height: 4.0),
          Text(
            'Sem histórico',
            style:
                textStyle.copyWith(color: textStyle.color!.withOpacity(0.87)),
          ),
        ],
      ),
    );
  }

  Widget _historyEntries(BuildContext context, List<HistoryEntry> entries) =>
      ListView.separated(
        padding: EdgeInsets.symmetric(
          horizontal: CalculatorLayout.of(context).margin,
          vertical: 2 * CalculatorLayout.of(context).margin,
        ),
        separatorBuilder: (_, __) => SizedBox(
          height: 3 * CalculatorLayout.of(context).margin,
        ),
        reverse: true,
        itemBuilder: (context, i) =>
            _HistoryEntryWidget(entry: entries[entries.length - i - 1]),
        itemCount: entries.length,
      );

  Widget _switcher(BuildContext context, Widget child) =>
      PageTransitionSwitcher(
        transitionBuilder: (child, animation, secondaryAnimation) =>
            FadeThroughTransition(
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          child: child,
          fillColor: Colors.transparent,
        ),
        child: child,
      );

  Widget _body(BuildContext context) =>
      ValueListenableBuilder<List<HistoryEntry>>(
        valueListenable: CalcController.of(context).logic.history,
        builder: (context, entries, _) => _switcher(
          context,
          entries.isEmpty
              ? _noHistory(context)
              : _historyEntries(context, entries),
        ),
      );

  static final _bodyOffsetTween = Tween(
    begin: const Offset(0, -1),
    end: Offset.zero,
  );

  Widget _bodyTransition(BuildContext context) {
    final anim = CalcController.of(context).ui.firstLevelScrollAnimation;
    final height = MediaQuery.of(context).size.height;
    final sizeBeforeAnim = height - (height / 2) - (height / 3);

    return ValueListenableBuilder<double>(
      valueListenable: anim,
      builder: (context, animVal, child) => OverflowBox(
        maxHeight: animVal == 1.0 ? null : sizeBeforeAnim,
        minHeight: animVal == 1.0 ? null : sizeBeforeAnim,
        child: child,
      ),
      child: SlideTransition(
        position: _bodyOffsetTween.animate(anim),
        child: _body(context),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.isDark
          ? context.materialYouColors.neutral1.shade800
          : context.materialYouColors.neutral1.shade50,
      child: Column(
        children: [
          _appBar(context),
          Expanded(child: _bodyTransition(context)),
        ],
      ),
    );
  }
}

class _HistoryEntryWidget extends StatelessWidget {
  final HistoryEntry entry;
  const _HistoryEntryWidget({
    Key? key,
    required this.entry,
  }) : super(key: key);

  Widget _expression(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.headline4!;
    return SelectableText(
      entry.expression,
      textAlign: TextAlign.right,
      onTap: () =>
          CalcController.of(context).logic.insertExpression(entry.expression),
      style: textStyle.copyWith(
        fontWeight: FontWeight.w400,
        color: textStyle.color!.withOpacity(0.87),
      ),
    );
  }

  Widget _result(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.headline4!;
    return SelectableText(
      entry.result,
      textAlign: TextAlign.right,
      onTap: () =>
          CalcController.of(context).logic.insertExpression(entry.result),
      style: textStyle.copyWith(
        fontWeight: FontWeight.w400,
        color: textStyle.color!.withOpacity(0.7),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _expression(context),
        SizedBox(
          height: CalculatorLayout.of(context).gutter,
        ),
        _result(context),
      ],
    );
  }
}
