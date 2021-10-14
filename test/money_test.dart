import 'package:flutter_test/flutter_test.dart';
import 'package:money/formatter.dart';

import 'package:money/money.dart';

void main() {
  group('Create and Parse', () {
    test('Const Zero value', () {
      final m = Money.zero;
      expect(m.value, isZero);
      expect(m.amount, isZero);
      expect(m.toString(), '0.00');
    });

    group('Int', () {
      test('Positive', () {
        final m = Money.parse(1);
        expect(m.value, 1.0);
        expect(m.amount, 10000);
        expect(m.toString(), '1.00');
      });
      test('Negative value', () {
        final m = Money.parse(-1);
        expect(m.value, -1.0);
        expect(m.amount, -10000);
        expect(m.toString(), '-1.00');
      });
    });

    group('Double', () {
      test('Positive value', () {
        final m = Money.parse(1.0);
        expect(m.value, 1.0);
        expect(m.amount, 10000);
        expect(m.toString(), '1.00');
      });

      test('Negative value', () {
        final m = Money.parse(-1.0);
        expect(m.value, -1.0);
        expect(m.amount, -10000);
        expect(m.toString(), '-1.00');
      });

      test('Infinity value', () {
        expect(() => Money.parse(double.infinity), throwsA(isA<Error>()));
        expect(
            () => Money.parse(double.negativeInfinity), throwsA(isA<Error>()));
      });

      test('NaN value', () {
        expect(() => Money.parse(double.nan), throwsA(isA<Error>()));
      });
    });

    group('String', () {
      test('Value int', () {
        final m = Money.parse('1');
        expect(m.value, 1.0);
        expect(m.amount, 10000);
        expect(m.toString(), '1.00');
      });

      test('Value double', () {
        final m = Money.parse('1.0');
        expect(m.value, 1.0);
        expect(m.amount, 10000);
        expect(m.toString(), '1.00');
      });

      test('Negative value', () {
        final m = Money.parse('-1.0');
        expect(m.value, -1.0);
        expect(m.amount, -10000);
        expect(m.toString(), '-1.00');
      });

      test('Invalid string value 1', () {
        expect(() => Money.parse('a'), throwsA(isA<FormatException>()));
      });

      test('Invalid string value 2', () {
        expect(() => Money.parse('1.1.1'), throwsA(isA<FormatException>()));
      });

      test('Invalid string value 3', () {
        expect(() => Money.parse('1.-1'), throwsA(isA<FormatException>()));
      });

      test('Invalid string value 4', () {
        expect(() => Money.parse('1.a'), throwsA(isA<FormatException>()));
      });

      test('Double infinity', () {
        expect(() => Money.parse(double.infinity.toString()),
            throwsA(isA<FormatException>()));
      });

      test('Double NaN', () {
        expect(() => Money.parse(double.nan.toString()),
            throwsA(isA<FormatException>()));
      });
    });

    group('Object', () {
      test('Other money', () {
        final m = Money.parse('1.0');
        final Money m2 = m;
        expect(m.value, 1.0);
        expect(m.amount, 10000);
        expect(m2.value, 1.0);
        expect(m2.amount, 10000);
      });

      test('Other money parse', () {
        final m = Money.parse('1.0');
        final m2 = Money.parse(m);
        expect(m.value, 1.0);
        expect(m.amount, 10000);
        expect(m2.value, 1.0);
        expect(m2.amount, 10000);
      });

      test('Invalid object', () {
        expect(
            () => Money.parse(DateTime.now()), throwsA(isA<FormatException>()));
      });
    });

    group('TryParse', () {
      test('Int', () {
        expect(Money.tryParse(1), isNotNull);
      });
      test('Double', () {
        expect(Money.tryParse(1.0), isNotNull);
      });
      test('Money', () {
        expect(Money.tryParse(Money.zero), isNotNull);
      });
      test('String', () {
        expect(Money.tryParse('1.0'), isNotNull);
      });
      test('Invalid double', () {
        expect(Money.tryParse(double.nan), isNull);
        expect(Money.tryParse(double.infinity), isNull);
        expect(Money.tryParse(double.negativeInfinity), isNull);
      });
      test('Invalid string', () {
        expect(Money.tryParse('1.a'), isNull);
      });
      test('Invalid object', () {
        expect(Money.tryParse(DateTime.now()), isNull);
      });
    });
  });

  group('Compare', () {
    group('Int', () {
      test('Operator greater than', () {
        final m = Money.parse(100);
        expect(m > Money.zero, true);
        expect(m > 10, true);
        expect(m > 100, false);
        expect(m > 1000, false);
      });

      test('Operator greater or eq than', () {
        final m = Money.parse(100);
        expect(m >= Money.zero, true);
        expect(m >= 10, true);
        expect(m >= 100, true);
        expect(m >= 1000, false);
      });

      test('Operator less than', () {
        final m = Money.parse(100);
        expect(m < 1000, true);
        expect(m < 100, false);
        expect(m < 10, false);
        expect(m < Money.zero, false);
      });

      test('Operator less or eq than', () {
        final m = Money.parse(100);
        expect(m <= 1000, true);
        expect(m <= 100, true);
        expect(m <= 10, false);
        expect(m <= Money.zero, false);
      });

      test('Operator eq', () {
        final m = Money.parse(100);
        expect(m == 1000, false);
        expect(m == 100, true);
        expect(m == 10, false);
        expect(m == Money.zero, false);
      });

      test('Operator not eq', () {
        final m = Money.parse(100);
        expect(m != 1000, true);
        expect(m != 100, false);
        expect(m != 10, true);
        expect(m != Money.zero, true);
      });
    });

    group('Double', () {
      test('Operator greater than', () {
        final m = Money.parse(100);
        expect(m > 10.0, true);
        expect(m > 100.0, false);
        expect(m > 1000.0, false);
        expect(m > double.infinity, false);
        expect(m > double.negativeInfinity, true);
      });

      test('Operator greater or eq than', () {
        final m = Money.parse(100);
        expect(m >= 10.0, true);
        expect(m >= 100.0, true);
        expect(m >= 1000.0, false);
        expect(m > double.infinity, false);
        expect(m > double.negativeInfinity, true);
      });

      test('Operator less than', () {
        final m = Money.parse(100);
        expect(m < 1000.0, true);
        expect(m < 100.0, false);
        expect(m < 10.0, false);
        expect(m < double.infinity, true);
        expect(m < double.negativeInfinity, false);
      });

      test('Operator greater or eq than', () {
        final m = Money.parse(100);
        expect(m <= 10.0, false);
        expect(m <= 100.0, true);
        expect(m <= 1000.0, true);
        expect(m < double.infinity, true);
        expect(m < double.negativeInfinity, false);
      });

      test('Operator eq', () {
        final m = Money.parse(100);
        expect(m == 1000.0, false);
        expect(m == 100.0, true);
        expect(m == 10.0, false);
        expect(m == double.infinity, false);
        expect(m == double.negativeInfinity, false);
        expect(m == double.nan, false);
      });

      test('Operator not eq', () {
        final m = Money.parse(100);
        expect(m != 1000.0, true);
        expect(m != 100.0, false);
        expect(m != 10.0, true);
        expect(m != double.infinity, true);
        expect(m != double.negativeInfinity, true);
        expect(m != double.nan, true);
      });
    });

    group('String', () {
      test('Operator greater than', () {
        final m = Money.parse(100);
        expect(m > '10.0', true);
        expect(m > '100.0', false);
        expect(m > '1000', false);
      });

      test('Operator greater or eq than', () {
        final m = Money.parse(100);
        expect(m >= '10.0', true);
        expect(m >= '100', true);
        expect(m >= '1000.0', false);
      });

      test('Operator less than', () {
        final m = Money.parse(100);
        expect(m < '1000.0', true);
        expect(m < '100.0', false);
        expect(m < '10', false);
      });

      test('Operator less than', () {
        final m = Money.parse(100);
        expect(m <= '1000.0', true);
        expect(m <= '100.0', true);
        expect(m <= '10', false);
      });

      test('Operator eq', () {
        final m = Money.parse(100);
        expect(m == '100.0', true);
        expect(m == '10', false);
      });

      test('Operator not eq', () {
        final m = Money.parse(100);
        expect(m != '1000.0', true);
        expect(m != '100', false);
      });
    });

    group('CompareTo', () {
      group('Int', () {
        test('Int greater argument', () {
          expect(Money.zero.compareTo(1), isNegative);
        });
        test('Int lesser argument', () {
          expect(Money.zero.compareTo(-1), isPositive);
        });
        test('Int eq', () {
          expect(Money.zero.compareTo(0), isZero);
        });
      });

      group('Double', () {
        test('Double greater argument', () {
          expect(Money.zero.compareTo(1.0), isNegative);
        });
        test('Double lesser argument', () {
          expect(Money.zero.compareTo(-1.0), isPositive);
        });
        test('Double eq', () {
          expect(Money.zero.compareTo(0.0), isZero);
        });
        test('Double infinity', () {
          expect(Money.zero.compareTo(double.infinity), isNegative);
        });
        test('Double negative infinity', () {
          expect(Money.zero.compareTo(double.negativeInfinity), isPositive);
        });
        test('Double nan', () {
          expect(() => Money.zero.compareTo(double.nan), throwsA(isA<Error>()));
        });
      });

      group('String', () {
        test('String greater argument', () {
          expect(Money.zero.compareTo('100'), isNegative);
        });
        test('String lesser argument', () {
          expect(Money.zero.compareTo('-100'), isPositive);
        });
        test('String eq', () {
          expect(Money.zero.compareTo('0'), isZero);
        });
      });
    });
  });

  group('Math', () {
    group('Zero', () {
      test('Add zero', () {
        final z = Money.zero;
        final m = Money.parse(100);
        final result = z + m;
        expect(result.value, 100.0);
        expect(result.amount, 1000000);
      });

      test('Subtract zero', () {
        final z = Money.zero;
        final m = Money.parse(100);
        final result = m - z;
        expect(result.value, 100.0);
        expect(result.amount, 1000000);
      });

      test('Subtract from zero', () {
        final z = Money.zero;
        final m = Money.parse(100);
        final result = z - m;
        expect(result.value, -100.0);
        expect(result.amount, -1000000);
      });

      test('Add', () {
        final result = Money.zero + 1;
        expect(result.value, 1.0);
        expect(result.amount, 10000);
      });

      test('Subtract', () {
        final result = Money.zero - 1;
        expect(result.value, -1.0);
        expect(result.amount, -10000);
      });

      test('Multiply', () {
        final result = Money.zero * 1;
        expect(result.value, isZero);
        expect(result.amount, isZero);
      });

      test('Divide', () {
        final result = Money.zero / 10;
        expect(result.value, isZero);
        expect(result.amount, isZero);
      });
    });

    group('Int', () {
      test('Add positive', () {
        final m = Money.parse(100);
        final result = m + 1;
        expect(result.value, 101.00);
        expect(result.amount, 1010000);
      });

      test('Add negative', () {
        final m = Money.parse(100);
        final result = m + (-1);
        expect(result.value, 99.0);
        expect(result.amount, 990000);
      });

      test('Subtract positive', () {
        final m = Money.parse(100);
        final result = m - 1;
        expect(result.value, 99);
        expect(result.amount, 990000);
      });

      test('Subtract negative', () {
        final m = Money.parse(100);
        final result = m - (-1);
        expect(result.value, 101.00);
        expect(result.amount, 1010000);
      });

      test('Multiply', () {
        final m = Money.parse(100);
        final result = m * 3;
        expect(result.value, 300.0);
        expect(result.amount, 3000000);
      });

      test('Multiply by zero', () {
        final m = Money.parse(100);
        final result = m * 0;
        expect(result.value, isZero);
        expect(result.amount, isZero);
      });

      test('Divide', () {
        final m = Money.parse(100);
        final result = m / 10;
        expect(result.value, 10.0);
        expect(result.amount, 100000);
      });

      test('Divide by zero', () {
        final m = Money.parse(100);
        expect(() => m / 0, throwsA(isA<Error>()));
      });
    });

    group('Double', () {
      test('Add positive', () {
        final m = Money.parse(100);
        final result = m + 1.01;
        expect(result.value, 101.01);
        expect(result.amount, 1010100);
      });

      test('Add negative', () {
        final m = Money.parse(100);
        final result = m + (-1.01);
        expect(result.value, 98.99);
        expect(result.amount, 989900);
      });

      test('Add infinity', () {
        final m = Money.parse(100);
        expect(() => m + double.infinity, throwsA(isA<Error>()));
        expect(() => m + double.negativeInfinity, throwsA(isA<Error>()));
      });

      test('Add nan', () {
        final m = Money.parse(100);
        expect(() => m + double.nan, throwsA(isA<Error>()));
      });

      test('Subtract from zero', () {
        final z = Money.zero;
        final m = Money.parse(100);
        final result = z - m;
        expect(result.value, -100.0);
        expect(result.amount, -1000000);
      });

      test('Subtract positive', () {
        final m = Money.parse(100);
        final result = m - 1.01;
        expect(result.value, 98.99);
        expect(result.amount, 989900);
      });

      test('Subtract negative', () {
        final m = Money.parse(100);
        final result = m - (-1.01);
        expect(result.value, 101.01);
        expect(result.amount, 1010100);
      });

      test('Subtract infinity', () {
        final m = Money.parse(100);
        expect(() => m - double.infinity, throwsA(isA<Error>()));
        expect(() => m - double.negativeInfinity, throwsA(isA<Error>()));
      });

      test('Subtract nan', () {
        final m = Money.parse(100);
        expect(() => m - double.nan, throwsA(isA<Error>()));
      });

      test('Multiply greater than 1 ratio', () {
        final m = Money.parse(100);
        final result = m * 3.1;
        expect(result.value, 310.0);
        expect(result.amount, 3100000);
      });

      test('Multiply less than 1 ratio', () {
        final m = Money.parse(100);
        final result = m * .1;
        expect(result.value, 10.0);
        expect(result.amount, 100000);
      });

      test('Multiply zero ratio', () {
        final m = Money.parse(100);
        final result = m * 0;
        expect(result.value, isZero);
        expect(result.amount, isZero);
      });

      test('Multiply infinity', () {
        final m = Money.parse(100);
        expect(() => m * double.infinity, throwsA(isA<Error>()));
        expect(() => m * double.infinity, throwsA(isA<Error>()));
      });

      test('Multiply nan', () {
        final m = Money.parse(100);
        expect(() => m * double.nan, throwsA(isA<Error>()));
      });

      test('Divide greater than 1 ratio', () {
        final m = Money.parse(100);
        final result = m / 10.0;
        expect(result.value, 10.0);
        expect(result.amount, 100000);
      });

      test('Divide less than 1 ratio', () {
        final m = Money.parse(100);
        final result = m / 0.1;
        expect(result.value, 1000.0);
        expect(result.amount, 10000000);
      });

      test('Divide by zero', () {
        final m = Money.parse(100);
        expect(() => m / 0, throwsA(isA<Error>()));
      });

      test('Divide infinity', () {
        final m = Money.parse(100);
        expect(() => m / double.infinity, throwsA(isA<Error>()));
        expect(() => m / double.negativeInfinity, throwsA(isA<Error>()));
      });

      test('Divide nan', () {
        final m = Money.parse(100);
        expect(() => m / double.nan, throwsA(isA<Error>()));
      });
    });

    group('String', () {
      test('Add positive', () {
        final m = Money.parse(100);
        final result = m + '1.01';
        expect(result.value, 101.01);
        expect(result.amount, 1010100);
      });

      test('Add negative', () {
        final m = Money.parse(100);
        final result = m + '-10';
        expect(result.value, 90.0);
        expect(result.amount, 900000);
      });

      test('Subtract positive', () {
        final m = Money.parse(100);
        final result = m - '19';
        expect(result.value, 81.0);
        expect(result.amount, 810000);
      });

      test('Subtract negative', () {
        final m = Money.parse(100);
        final result = m - '-1.01';
        expect(result.value, 100.99);
        expect(result.amount, 1009900);
      });

      test('Multiply', () {
        final m = Money.parse(100);
        final result = m * '-3.1';
        expect(result.value, -310.0);
        expect(result.amount, -3100000);
      });

      test('Multiply by zero', () {
        final m = Money.parse(100);
        final result = m * '0';
        expect(result.value, isZero);
        expect(result.amount, isZero);
      });

      test('Divide', () {
        final m = Money.parse(100);
        final result = m / 10;
        expect(result.value, 10.0);
        expect(result.amount, 100000);
      });

      test('Divide by zero', () {
        final m = Money.parse(100);
        expect(() => m / '0', throwsA(isA<Error>()));
      });
    });
  });

  group('Formatter', () {
    test("Change formatter", () {
      final m = Money.parse(-1234.567);
      expect(m.toString(), '-1234.56');
      m.formatter = MoneyFormatter("#`###,@@@s");
      expect(m.toString(), '1`234,567-');
    });
  });
}
