import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tellbow/screens/wide.dart';

Future<void> pumpAt(WidgetTester tester, double width, Widget child) async {
  tester.view.physicalSize = Size(width, 1000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(MaterialApp(home: Scaffold(body: child)));
}

const card = SizedBox(height: 100);

void main() {
  testWidgets('a phone keeps one column', (tester) async {
    await pumpAt(tester, 390, const Columns([card, card, card]));
    expect(find.byType(Row), findsNothing);
    expect(tester.getSize(find.byType(SizedBox).first).width, 390);
  });

  testWidgets('a wide screen alternates two columns', (tester) async {
    await pumpAt(tester, 1000, Columns([for (var i = 0; i < 3; i++) SizedBox(key: Key('$i'), height: 100)]));
    expect(tester.getTopLeft(find.byKey(const Key('0'))), const Offset(0, 0));
    expect(tester.getTopLeft(find.byKey(const Key('1'))), const Offset(500, 0));
    expect(tester.getTopLeft(find.byKey(const Key('2'))), const Offset(0, 100));
  });

  testWidgets('a single card takes the whole width', (tester) async {
    await pumpAt(tester, 1000, const Columns([card]));
    expect(tester.getSize(find.byType(SizedBox).first).width, 1000);
  });

  testWidgets('Readable limits the width in the middle', (tester) async {
    await pumpAt(tester, 1000, const Readable(child: SizedBox.expand()));
    expect(tester.getSize(find.byType(SizedBox)).width, listWidth);
    expect(tester.getTopLeft(find.byType(SizedBox)).dx, (1000 - listWidth) / 2);
  });

  testWidgets('isWide from 820 points', (tester) async {
    late bool wide;
    await pumpAt(tester, 819, Builder(builder: (context) => Text('${wide = isWide(context)}')));
    expect(wide, isFalse);
    await pumpAt(tester, 820, Builder(builder: (context) => Text('${wide = isWide(context)}')));
    expect(wide, isTrue);
  });
}
