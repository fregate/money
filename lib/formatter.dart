import 'dart:math';

/// Money formatter
///
/// Numbers, Negative numbers and Thousands separator
/// Decimal places + Padding
///
/// Numbers
///
/// Integral part operator: #
/// Example: # == 123; 0; 1
///
/// Thousand separator operator: #(op)### (4 integral operators and separator)
/// Valid symbols for separator (operator) are
/// period (.), comma (,), space ( ), apostrophe (‘) and single quote (')
/// Example: # ### == 1 234; 0; 123; 1 234 567 890
///          #,### == 1,234; 0; 123; 1,234,567,890
/// Negative numbers are declared as sign or parenthesis
/// Example: p# == (123); (1234)
/// Example: s# == -123 (default)
/// Example: #s == 123- (Netherlands)
/// Example: s#,### == -1,234
/// Example: p#,### == (1,234)
///
/// Decimal places operator @ and decimal part separator (valid symbols are period '.' and comma ',')
/// #.@@, where # - integral part format, '.' - decimal separator, @ - mandatory decimal place (max 4)
/// Example: #.@@ == 123.45; 0.00; -123.00
///
/// Padding operator for decimal places: '?'
/// Padding after decimal separator declare all decimal places are not mandatory
/// and prints all decimal places only if value has decimal part
/// Padding after decimal format prints only significant places
/// Example: #.@@ ==  123.01; 0.00; 0.10 (default)
/// Example: #.?@@ == 123.01; 0; 0.10
/// Example: #.?@@@ == 123.010; 0; 0.100
/// Example: #.@@? == 123.01; 0; 0.1
/// Example: #.@@@? == 123.01; 0; 0.1; 456.789
///
/// Full example: #,###.@@ == 0.00; -1.23; -1,234.56; 1,234,567.80
/// Full example: s#.@@ == 0.00; -1.23; -1234.56; 1234567.80
/// Full example: p#.@@ == 0.00; (1.23); (1234.56); 1234567.80
/// Full example: s#,###.?@@ == 0; -1.23; -1234.56; 1234567.80
/// Full example: s#,###.@@? == 0; -1.23; -1234.56; 1234567.8

class MoneyFormatParseError extends ArgumentError {
  MoneyFormatParseError(String pattern, [String name = "", String message = ""])
      : super.value(pattern, name, message);
}

enum _Sign {
  Sign,
  Parenthesis,
}

enum _Decimals {
  Mandatory,
  NotMandatory,
  MandatorySignificantOnly,
}

class MoneyFormatter {
  static final RegExp _re = RegExp(
      r"(^[s|p]?)((#[\s.,‘`']##)?#)((([.,])([\?]?)(@{2,4})([\?]?))?)([s]?$)");

  final String pattern;

  late final String _decimalSeparator;
  late final String _thousandsSeparator;

  late final _Sign _sign;
  late final bool _signAtEnd;

  late final int _decimalPlaces;
  late final _Decimals _decimalsMandatory;

  MoneyFormatter(this.pattern) {
    _parse();
  }

  String format(int integral, int decimal) {
    if (decimal < 0)
      throw ArgumentError.value(decimal, "decimal", "negative decimal");

    bool negative = integral.sign < 0;
    integral = integral.abs();

    String integralPart = "";
    if (_thousandsSeparator.isNotEmpty) {
      int separator = 3;
      while (integral > 0) {
        integralPart += (integral % 10).toString();
        integral ~/= 10;
        separator -= 1;
        if (separator == 0) {
          integralPart += _thousandsSeparator;
          separator = 3;
        }
      }
      if (integralPart[integralPart.length - 1] == _thousandsSeparator)
        integralPart = integralPart.substring(0, integralPart.length - 1);
      integralPart = integralPart.split('').reversed.join();
    } else {
      integralPart = integral.toString();
    }

    if (decimal > 9999) {
      print("warning: decimal part longer than 4 digits - truncated");
      while (decimal > 9999) decimal ~/= 10;
    }
    String decimalPart = "";
    if (_decimalsMandatory == _Decimals.Mandatory ||
        (_decimalsMandatory == _Decimals.NotMandatory && decimal != 0)) {
      while (decimal > pow(10, _decimalPlaces) - 1)
        decimal ~/= 10; // TODO rounding?

      decimalPart =
          _decimalSeparator + decimal.toString().padRight(_decimalPlaces, '0');
    } else if (decimal == 0) {
      // nothing to add - just print integral part
    } else if (_decimalsMandatory == _Decimals.MandatorySignificantOnly) {
      while (decimal > pow(10, _decimalPlaces) - 1)
        decimal ~/= 10; // TODO rounding?

      decimalPart = _decimalSeparator + decimal.toString();
    } else {
      print("whats here? $integral . $decimal");
    }

    String number = integralPart + decimalPart;

    // sign
    if (negative) {
      if (_sign == _Sign.Parenthesis) {
        number = "($number)";
      } else if (_sign == _Sign.Sign && _signAtEnd) {
        number = "$number-";
      } else {
        number = "-$number";
      }
    }

    return number;
  }

  void _parse() {
    RegExpMatch? match = _re.firstMatch(pattern);
    if (match == null) throw MoneyFormatParseError(pattern, "pattern");

    if (match.groupCount != 10)
      throw MoneyFormatParseError(
          pattern, "pattern", "not enough parsing groups");

    // Decimal separator
    var decimalSeparator = match.group(6);
    if (decimalSeparator == null)
      decimalSeparator = "."; // TODO get from locale
    _decimalSeparator = decimalSeparator;

    // Decimal places
    final decimals = match.group(8);
    _decimalPlaces =
        (decimals == null || decimals.isEmpty) ? 2 : decimals.length;

    // Decimal padding
    var decimalPart = match.group(6);
    if (decimalPart == null) decimalPart = "";
    var significantOnly = match.group(9);
    if (significantOnly == null) significantOnly = "";
    if (significantOnly.isNotEmpty && decimalPart.isNotEmpty)
      throw MoneyFormatParseError(
          pattern, "pattern", "error: 2 padding operators '?' in pattern");
    else
      _decimalsMandatory = significantOnly.isNotEmpty
          ? _Decimals.MandatorySignificantOnly
          : decimalPart.isNotEmpty
              ? _Decimals.NotMandatory
              : _Decimals.Mandatory;

    // Thousands separator
    var thousandSeparator = match.group(3);
    if (thousandSeparator == null) thousandSeparator = "";
    _thousandsSeparator = thousandSeparator;

    if (_thousandsSeparator == _decimalSeparator)
      throw MoneyFormatParseError(pattern, "pattern",
          "thousand '$_thousandsSeparator' and decimal '$_decimalSeparator' separators are equal");

    // Sign
    var prefixSign = match.group(1);
    if (prefixSign == null) prefixSign = "";
    var postfixSign = match.group(10);
    if (postfixSign == null) postfixSign = "";
    if (prefixSign.isEmpty && postfixSign.isEmpty) {
      _sign = _Sign.Sign;
      _signAtEnd = false;
    } else if (prefixSign.isNotEmpty && postfixSign.isNotEmpty) {
      throw MoneyFormatParseError(pattern, "pattern",
          "invalid sign attribute: prefix '$prefixSign' and postfix '$postfixSign'");
    } else if (postfixSign.isNotEmpty) {
      _sign = _Sign.Sign;
      _signAtEnd = true;
    } else {
      _signAtEnd = false;
      _sign = prefixSign == "s" ? _Sign.Sign : _Sign.Parenthesis;
    }
  }
}
