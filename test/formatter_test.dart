import 'package:flutter_test/flutter_test.dart';
import 'package:money/formatter.dart';

void main() {
  test('check', () {
    final f1 = MoneyFormatter("# ###,@@s");
    final f2 = MoneyFormatter("p#");
    final f3 = MoneyFormatter("#");
  });
}
