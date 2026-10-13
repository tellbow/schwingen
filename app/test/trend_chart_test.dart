import 'package:flutter_test/flutter_test.dart';
import 'package:tellbow/screens/trend_chart.dart';

void main() {
  group('axisRange', () {
    (double, double, double) of(List<num> values) {
      final r = axisRange(values);
      return (r.min, r.max, r.step);
    }

    test('rounds to clean steps around the values', () {
      expect(of([1420, 1530, 1610]), (1400, 1650, 50));
      expect(of([55.2, 58.9]), (55, 59, 1));
    });

    test('gives a single value a range of one step', () {
      expect(of([1500]), (1500, 1500.5, 0.5));
    });
  });
}
