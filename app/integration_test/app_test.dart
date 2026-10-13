import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:tellbow/main.dart';
import 'package:tellbow/screens/data_gate.dart';

Future<void> pumpUntil(WidgetTester tester, Finder finder, {Duration timeout = const Duration(seconds: 30)}) async {
  final end = DateTime.now().add(timeout);
  while (finder.evaluate().isEmpty) {
    if (DateTime.now().isAfter(end)) throw TestFailure('Timed out waiting for $finder');
    await tester.pump(const Duration(milliseconds: 200));
  }
}

Future<void> shot(WidgetTester tester, String name) async {
  debugPrint('SHOT $name');
  for (var i = 0; i < 25; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Finder tab(String label) => find.descendant(of: find.byType(NavigationBar), matching: find.text(label));

final page = find.byWidgetPredicate((w) => w is Scrollable && w.axisDirection == AxisDirection.down).first;

Finder rich(String text) => find.textContaining(text, findRichText: true);

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  WidgetController.hitTestWarningShouldBeFatal = true;

  testWidgets('downloads the data and shows every tab', (tester) async {
    await tester.pumpWidget(TellbowApp(store: openStore()));
    await pumpUntil(tester, find.byWidgetPredicate((w) => w is NavigationBar || w is Text && w.data == 'Laden'));

    if (find.byType(NavigationBar).evaluate().isEmpty) {
      await shot(tester, 'first-launch');
      await tester.tap(find.widgetWithText(FilledButton, 'Laden'));
      await pumpUntil(tester, find.byType(LinearProgressIndicator));
      await shot(tester, 'downloading');
      await pumpUntil(tester, find.byType(NavigationBar), timeout: const Duration(minutes: 10));
    }
    await pumpUntil(tester, find.byType(ListTile));
    await shot(tester, 'wrestlers');

    await tester.enterText(find.byType(TextField), 'staudenmann fabian');
    await pumpUntil(tester, rich('Fabian Staudenmann'));
    await tester.tap(rich('Fabian Staudenmann').first);
    await pumpUntil(tester, find.text('Gestellte'));
    await shot(tester, 'wrestler');

    await tester.tap(find.text('2025'));
    await pumpUntil(tester, find.text('ELO 2025'));
    await shot(tester, 'wrestler-2025');

    final firstOpponent = find.descendant(
      of: find.ancestor(of: find.text('Häufigste Gegner'), matching: find.byType(Card)),
      matching: find.byType(ListTile),
    );
    await tester.scrollUntilVisible(firstOpponent.first, 300, scrollable: page);
    await tester.ensureVisible(firstOpponent.first);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(firstOpponent.first);
    await pumpUntil(tester, find.text('Begegnungen'));
    await shot(tester, 'head-to-head');

    await tester.tap(tab('Feste'));
    await pumpUntil(tester, find.byType(ListTile));
    await shot(tester, 'places');
    await tester.tap(find.byType(ListTile).first);
    await pumpUntil(tester, find.byType(ExpansionTile));
    await tester.tap(find.byType(ExpansionTile).first);
    await tester.pump(const Duration(milliseconds: 500));
    await shot(tester, 'place');

    await tester.tap(tab('Statistiken'));
    await pumpUntil(tester, find.text('Top 5 – meiste Siege'));
    await shot(tester, 'statistics');

    Finder tilesIn(String section) => find.descendant(
      of: find.ancestor(of: find.text(section), matching: find.byType(Card)),
      matching: find.byType(ListTile),
    );

    await tester.tap(tab('Verbände'));
    await pumpUntil(tester, find.textContaining('(BKSV)'));
    await tester.tap(find.textContaining('(BKSV)'));
    await pumpUntil(tester, tilesIn('Kantone / Gauverbände'));
    await shot(tester, 'association');
    await tester.tap(tilesIn('Kantone / Gauverbände').first);
    await pumpUntil(tester, tilesIn('Schwingklubs'));
    await tester.tap(tilesIn('Schwingklubs').first);
    await pumpUntil(tester, tilesIn('Schwinger'));
    await shot(tester, 'club');
  });
}
