import 'package:flutter_test/flutter_test.dart';
import 'package:money/formatter.dart';

void main() {
  group('Parse pattern', () {
    test('Empty pattern', () {
      final f = MoneyFormatter("#");
      expect(() => MoneyFormatter(""), throwsA(isA<Error>()));
    });

    test('Wrong sign symbol', () {
      expect(() => MoneyFormatter("x#"), throwsA(isA<Error>()));
    });

    test('Wrong sign symbols place', () {
      expect(() => MoneyFormatter("sp#"), throwsA(isA<Error>()));
      expect(() => MoneyFormatter("#p"), throwsA(isA<Error>()));
    });

    test('No integral part', () {
      expect(() => MoneyFormatter("s"), throwsA(isA<Error>()));
      expect(() => MoneyFormatter("p"), throwsA(isA<Error>()));
    });

    test('Second sign operator', () {
      expect(() => MoneyFormatter("s#s"), throwsA(isA<Error>()));
      expect(() => MoneyFormatter("p#s"), throwsA(isA<Error>()));
    });

    test('Wrong integral part symbol', () {
      expect(() => MoneyFormatter("%"), throwsA(isA<Error>()));
      expect(() => MoneyFormatter("s%"), throwsA(isA<Error>()));
      expect(() => MoneyFormatter("%.@@"), throwsA(isA<Error>()));
    });

    test('No thousands separator', () {
      expect(() => MoneyFormatter("##"), throwsA(isA<Error>()));
      expect(() => MoneyFormatter("###"), throwsA(isA<Error>()));
      expect(() => MoneyFormatter("####"), throwsA(isA<Error>()));
    });

    test('Wrong thousands separator', () {
      expect(() => MoneyFormatter("#s###"), throwsA(isA<Error>()));
      expect(() => MoneyFormatter("#/###"), throwsA(isA<Error>()));
      expect(() => MoneyFormatter("#''###"), throwsA(isA<Error>()));
      expect(() => MoneyFormatter("#'###'###"), throwsA(isA<Error>()));
      expect(() => MoneyFormatter("#'#"), throwsA(isA<Error>()));
    });

    test('No decimal separator', () {
      expect(() => MoneyFormatter("#@@"), throwsA(isA<Error>()));
    });

    test('Wrong decimal separator', () {
      expect(() => MoneyFormatter("#;@@"), throwsA(isA<Error>()));
      expect(() => MoneyFormatter("#.,@@"), throwsA(isA<Error>()));
    });

    test('Same thousand and decimal separators', () {
      expect(() => MoneyFormatter("#.###.@@"), throwsA(isA<Error>()));
      expect(() => MoneyFormatter("#,###,@@"), throwsA(isA<Error>()));
      expect(MoneyFormatter("#,###.@@"), isNotNull);
    });

    test('No decimal part', () {
      expect(MoneyFormatter("#"), isNotNull);
    });

    test('Sole decimal place', () {
      expect(() => MoneyFormatter("#.@"), throwsA(isA<Error>()));
    });

    test('5 decimal places', () {
      expect(() => MoneyFormatter("#.@@@@@"), throwsA(isA<Error>()));
    });

    test('Wrong decimal place symbol', () {
      expect(() => MoneyFormatter("#.&"), throwsA(isA<Error>()));
    });

    test('Wrong padding operator symbol', () {
      expect(() => MoneyFormatter("#.&@@"), throwsA(isA<Error>()));
      expect(() => MoneyFormatter("#.@@)"), throwsA(isA<Error>()));
      expect(() => MoneyFormatter("#.??@@"), throwsA(isA<Error>()));
      expect(() => MoneyFormatter("#.@@??"), throwsA(isA<Error>()));
    });

    test('Second padding operator', () {
      expect(() => MoneyFormatter("#.?@@?"), throwsA(isA<Error>()));
    });
  });

  test("Negative decimal", () {
    final f = MoneyFormatter("#");
    expect(() => f.format(0, -1), throwsA(isA<Error>()));
  });

  group("Format", () {
    test("Defaults", () {
      final f = MoneyFormatter("#");
      expect(f.format(0, 0), "0.00");
      expect(f.format(10, 1), "10.10");
      expect(f.format(10, 10), "10.10");
      expect(f.format(10, 109), "10.10");
      expect(f.format(1000, 0), "1000.00");
      expect(f.format(-1234, 0), "-1234.00");
    });

    group("Sign", () {
      test("Prefix sign", () {
        final f = MoneyFormatter("s#");
        expect(f.format(-1234, 0), "-1234.00");
      });

      test("Postfix sign", () {
        final f = MoneyFormatter("#s");
        expect(f.format(-1234, 0), "1234.00-");
      });

      test("Parenthesis sign", () {
        final f = MoneyFormatter("p#");
        expect(f.format(-1234, 0), "(1234.00)");
      });
    });

    group("Thousand separator", () {
      test("Thousand separator: - (space) -", () {
        final f = MoneyFormatter("# ###");
        expect(f.format(0, 0), "0.00"); // no separator
        expect(f.format(1000, 0), "1 000.00");
        expect(f.format(-1234, 0), "-1 234.00");
      });

      test("Thousand separator: - ' -", () {
        final f = MoneyFormatter("#'###");
        expect(f.format(999, 0), "999.00"); // no separator
        expect(f.format(1000, 0), "1'000.00");
        expect(f.format(-1234, 0), "-1'234.00");
      });

      test("Thousand separator: - . -", () {
        final f = MoneyFormatter("#.###");
        expect(f.format(999, 0), "999,00"); // no separator
        expect(f.format(1000, 0), "1.000,00");
        expect(f.format(-1234, 0), "-1.234,00");
      });

      test("Thousand separator: - , -", () {
        final f = MoneyFormatter("#,###");
        expect(f.format(999, 0), "999.00"); // no separator
        expect(f.format(1000, 0), "1,000.00");
        expect(f.format(-1234, 0), "-1,234.00");
      });

      test("Thousand separator: - ‘ -", () {
        final f = MoneyFormatter("#‘###");
        expect(f.format(999, 0), "999.00"); // no separator
        expect(f.format(1000, 0), "1‘000.00");
        expect(f.format(-1234, 0), "-1‘234.00");
      });

      test("Thousand separator: - ` -", () {
        final f = MoneyFormatter("#`###");
        expect(f.format(999, 0), "999.00"); // no separator
        expect(f.format(1000, 0), "1`000.00");
        expect(f.format(-1234, 0), "-1`234.00");
      });
    });

    group("Decimals", () {
      test("2 Places", () {
        final f = MoneyFormatter("#.@@");
        expect(f.format(0, 0), "0.00");
        expect(f.format(10, 1), "10.10");
        expect(f.format(10, 101), "10.10");
        expect(f.format(10, 1012), "10.10");
        expect(f.format(10, 1010), "10.10");
        expect(f.format(-1234, 0), "-1234.00");
      });
      test("3 Places", () {
        final f = MoneyFormatter("#.@@@");
        expect(f.format(0, 0), "0.000");
        expect(f.format(10, 1), "10.100");
        expect(f.format(10, 101), "10.101");
        expect(f.format(10, 1012), "10.101");
        expect(f.format(10, 1010), "10.101");
        expect(f.format(-1234, 0), "-1234.000");
      });
      test("4 Places", () {
        final f = MoneyFormatter("#.@@@@");
        expect(f.format(0, 0), "0.0000");
        expect(f.format(10, 1), "10.1000");
        expect(f.format(10, 101), "10.1010");
        expect(f.format(10, 1012), "10.1012");
        expect(f.format(10, 1010), "10.1010");
        expect(f.format(-1234, 0), "-1234.0000");
      });
    });
  });
}
