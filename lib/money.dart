import 'dart:math';

import 'package:money/formatter.dart';

class InfiniteDoubleParseError extends ArgumentError {
  InfiniteDoubleParseError(num value, [String name = "", String message = ""])
      : super.value(value, name, message);
}

class NanDoubleParseError extends ArgumentError {
  NanDoubleParseError([String name = "", String message = ""])
      : super.value(double.nan, name, message);
}

class Money {
  // according to ISO 4217 - maximum 4 decimal places for any currency
  static const _maxDecimalPlaces = 4;
  static const _e10 = 10000;

  Money(Money m, {MoneyFormatter? formatter})
      : _amount = m._amount,
        _formatter = formatter ??
            MoneyFormatter("#"); // TODO parse format from locale formatter for numbers and currency

  Money.parse(Object value, {MoneyFormatter? formatter})
      : _formatter = formatter ?? MoneyFormatter("#") {
    if (value is double) {
      if (value.isInfinite)
        throw InfiniteDoubleParseError(
            value, "value", "${value.runtimeType}: ${value.toString()}");

      if (value.isNaN)
        throw NanDoubleParseError(
            "value", "${value.runtimeType}: ${value.toString()}");

      _amount = (value * _e10).round();
      return;
    }

    if (value is int && value.isFinite && !value.isNaN) {
      _amount = value.toInt() * _e10;
      return;
    }

    if (value is String) {
      _amount = _parse(value)._amount;
      return;
    }

    if (value is Money) {
      _amount = value._amount;
      return;
    }

    throw FormatException(
        "invalid value ${value.runtimeType}: ${value.toString()}");
  }

  Money._raw(int amount, {MoneyFormatter? formatter})
      : _amount = amount,
        _formatter = formatter ?? MoneyFormatter("#");

  /// Compares this to `other`.
  ///
  /// Returns a negative number if `this` is less than `other`, zero if they are
  /// equal, and a positive number if `this` is greater than `other`.
  int compareTo(Object other) {
    try {
      final m = Money.parse(other);
      return _amount - m._amount;
    } on InfiniteDoubleParseError catch (e) {
      return e.invalidValue > 0 ? -1 : 1;
    }
  }

  @override
  bool operator ==(Object other) {
    try {
      final m = Money.parse(other);
      return m._amount == _amount;
    } on InfiniteDoubleParseError {
      return false;
    } on NanDoubleParseError {
      return false;
    }
  }

  bool operator >(Object other) {
    try {
      final m = Money.parse(other);
      return _amount > m._amount;
    } on InfiniteDoubleParseError catch (e) {
      return e.invalidValue.isNegative;
    }
  }

  bool operator >=(Object other) {
    try {
      final m = Money.parse(other);
      return _amount >= m._amount;
    } on InfiniteDoubleParseError catch (e) {
      return e.invalidValue.isNegative;
    }
  }

  bool operator <(Object other) {
    try {
      final m = Money.parse(other);
      return _amount < m._amount;
    } on InfiniteDoubleParseError catch (e) {
      return !e.invalidValue.isNegative;
    }
  }

  bool operator <=(Object other) {
    try {
      final m = Money.parse(other);
      return _amount <= m._amount;
    } on InfiniteDoubleParseError catch (e) {
      return !e.invalidValue.isNegative;
    }
  }

  Money operator +(Object other) {
    final m = Money.parse(other);
    return Money._raw(this._amount + m._amount);
  }

  Money operator -(Object other) {
    final m = Money.parse(other);
    return Money._raw(this._amount - m._amount);
  }

  // You can't multiplicate or divide money on money, so cast to numbers
  Money operator *(Object ratioObject) {
    num ratio = num.parse(ratioObject.toString());
    if (ratio.isNaN) throw NanDoubleParseError("ratioObject");
    if (ratio.isInfinite) throw InfiniteDoubleParseError(ratio, "ratioObject");
    return Money._raw((this._amount * ratio).round());
  }

  Money operator /(Object ratioObject) {
    num ratio = num.parse(ratioObject.toString());
    if (ratio == 0) throw ArgumentError("try to divide by zero");
    if (ratio.isNaN) throw NanDoubleParseError("ratioObject");
    if (ratio.isInfinite) throw InfiniteDoubleParseError(ratio, "ratioObject");
    return Money._raw((this._amount / ratio).round());
  }

  static Money? tryParse(Object other) {
    try {
      if (other is num) return Money.parse(other);
    } catch (e) {
      return null;
    }

    if (other is Money) return other;

    if (other is String) {
      try {
        return _parse(other);
      } on FormatException {
        return null;
      }
    }

    return null;
  }

  double get value => _amount.toDouble() / _e10;
  int get raw => _amount;

  set formatter(MoneyFormatter formatter) => _formatter = formatter;

  int get _integral => _amount ~/ _e10;
  int get _decimal => _amount.remainder(_e10).abs();

  @override
  String toString() {
    return _formatter.format(_integral, _decimal);
  }

  @override
  int get hashCode {
    return _amount.hashCode;
  }

  /// Parse Money from string
  /// \throws FormatException for invalid string (allowed symbols are digits, decimal part separator and sign '-/+')
  static Money _parse(String value) {
    value = value.trim();
    if (value.isEmpty) return Money.zero;

    var av = value.split('.');
    if (av.length > 2) {
      throw FormatException("invalid string value to parse '$value'");
    }

    if (av.length == 1) {
      return Money.parse(int.parse(av[0]));
    }

    final left = int.parse(av[0]);
    final decimal = av[1].substring(0, min(_maxDecimalPlaces, av[1].length));
    final right = int.parse(decimal); // rounding?
    if (right < 0) throw FormatException("invalid string $value}");

    final rs =
        (left * _e10 + right * pow(10, _maxDecimalPlaces - decimal.length))
            .round();
    return Money._raw(rs);
  }

  // immutable value
  late final int _amount;
  MoneyFormatter _formatter;

  static Money get zero => Money._raw(0);
}
