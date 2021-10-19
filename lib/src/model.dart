enum SpecialKind {
  ac,
  parens,
  mod,
  div,
  mul,
  minus,
  plus,
  equals,
  del,
  comma,
  sqrt,
  pi,
  pow,
  fac,
  degRad,
  inv,
  e,
  ln,
  log,
  sin,
  cos,
  tan,
  squared,
  arcSin,
  arcCos,
  arcTan,
  powE,
  pow10,
  pow2,
}

class HistoryEntry {
  final String expression;
  final String result;

  HistoryEntry(this.expression, this.result);
}
