import 'package:calculator/src/controllers/calc.dart';
import 'package:calculator/src/layout.dart';
import 'package:flutter/material.dart';
import 'package:material_you/material_you.dart';

class Header extends StatelessWidget {
  const Header({Key? key}) : super(key: key);

  Widget _label(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.headline5!;
    return FadeTransition(
      opacity: CalcController.of(context).ui.firstLevelScrollAnimation,
      child: Text(
        'Expressão atual',
        style: textStyle.copyWith(
          color: textStyle.color!.withOpacity(0.70),
        ),
      ),
    );
  }

  Widget _icon(BuildContext context) => PopupMenuButton(
        itemBuilder: (context) => [
          PopupMenuItem(
            child: const Text('Histórico'),
            onTap: CalcController.of(context).ui.scrollViewToHistory,
          ),
          const PopupMenuItem(child: Text('Escolher tema')),
          const PopupMenuItem(child: Text('Enviar feedback')),
          const PopupMenuItem(child: Text('Ajuda')),
        ],
        icon: const Icon(
          Icons.more_vert,
          size: 24,
        ),
      );

  @override
  Widget build(BuildContext context) {
    final layout = CalculatorLayout.of(context);
    final margin = layout.margin;
    final accent = context.materialYouColors.accent2;
    final isTiny = layout.type == CalculatorLayoutType.tiny;
    return Material(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadiusDirectional.vertical(
          bottom: Radius.circular(margin),
        ),
      ),
      color: context.isDark ? accent.shade700 : accent.shade100,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!isTiny) _headerRow(context),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: margin),
              child: const _ExpressionField(),
            ),
          ),
          if (!isTiny)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: margin),
              child: _result(context),
            ),
          if (!isTiny) _footerRow(context),
        ],
      ),
    );
  }

  Widget _result(BuildContext context) => ValueListenableBuilder<String>(
        valueListenable: CalcController.of(context).logic.expressionResult,
        builder: (context, result, _) => SelectableText(
          result,
          textAlign: TextAlign.right,
          style: Theme.of(context)
              .textTheme
              .headline4!
              .copyWith(fontWeight: FontWeight.w400),
        ),
      );

  Widget _footerRow(BuildContext context) => SizedBox(
        height: 20,
        child: Center(
          child: SizedBox(
            width: 24,
            height: 4,
            child: DecoratedBox(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  color: context.isDark
                      ? context.materialYouColors.neutral1.shade50
                      : context.materialYouColors.neutral1.shade700),
            ),
          ),
        ),
      );

  Widget _headerRow(BuildContext context) {
    return SizedBox(
      height: 56,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: CalculatorLayout.of(context).margin + 4,
          ),
          _label(context),
          const Spacer(),
          _icon(context),
        ],
      ),
    );
  }
}

class _ExpressionField extends StatelessWidget {
  const _ExpressionField({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = CalcController.of(context);
    final textStyle = Theme.of(context).textTheme.headline1!;
    return EditableText(
      controller: controller.ui.textEditingController,
      focusNode: controller.ui.textFocusNode,
      textAlign: TextAlign.right,
      scrollController: controller.ui.textEditingScrollController,
      keyboardType: TextInputType.none,
      autofocus: true,
      style: textStyle.copyWith(
          fontWeight: FontWeight.normal,
          color: textStyle.color!.withOpacity(0.87),
          wordSpacing: -4),
      cursorColor: TextSelectionTheme.of(context).cursorColor ??
          // ignore: deprecated_member_use
          Theme.of(context).cursorColor,
      backgroundCursorColor: Colors.red,
    );
  }
}
