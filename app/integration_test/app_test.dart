import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:tellbow/main.dart';
import 'package:tellbow/screens/canton_map.dart';
import 'package:tellbow/screens/data_gate.dart';
import 'package:tellbow/settings.dart';

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
    SharedPreferencesAsyncPlatform.instance = InMemorySharedPreferencesAsync.empty();
    await tester.pumpWidget(TellbowApp(store: openStore(), settings: await Settings.load()));
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

    await tester.scrollUntilVisible(find.byType(LineChart).first, 300, scrollable: page);
    await tester.ensureVisible(find.text('Verlauf'));
    await tester.pump(const Duration(milliseconds: 300));
    await shot(tester, 'trends');
    await tester.scrollUntilVisible(find.text('Siege, Gestellte und Niederlagen pro Saison'), 300, scrollable: page);
    await shot(tester, 'outcomes');
    await tester.scrollUntilVisible(find.text('2025'), -300, scrollable: page);

    await tester.tap(find.text('2025'));
    await pumpUntil(tester, find.text('ELO 2025'));
    await shot(tester, 'wrestler-2025');
    await tester.scrollUntilVisible(find.text('Rang pro Fest'), 300, scrollable: page);
    await tester.ensureVisible(find.text('Rang pro Fest'));
    await tester.pump(const Duration(milliseconds: 300));
    await shot(tester, 'festival-charts');

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
    await tester.scrollUntilVisible(find.text('Ø Rang pro Saison (Rang 1 oben)'), 300, scrollable: page);
    await tester.pump(const Duration(milliseconds: 300));
    await shot(tester, 'rank-duel');

    await tester.tap(tab('Feste'));
    await pumpUntil(tester, find.byType(ListTile));
    await shot(tester, 'places');
    await tester.tap(find.byType(ListTile).first);
    await pumpUntil(tester, find.byType(ExpansionTile));
    await shot(tester, 'points-distribution');
    await tester.tap(find.byType(ExpansionTile).first);
    await tester.pump(const Duration(milliseconds: 500));
    await shot(tester, 'place');

    await tester.tap(tab('Statistiken'));
    await pumpUntil(tester, find.text('Top 5 – meiste Siege'));
    await shot(tester, 'statistics');
    await tester.scrollUntilVisible(find.text('Top 5 – meiste Kränze'), 300, scrollable: page);
    await tester.pump(const Duration(milliseconds: 300));
    await shot(tester, 'statistics-bars');

    Finder tilesIn(String section) => find.descendant(
      of: find.ancestor(of: find.text(section), matching: find.byType(Card)),
      matching: find.byType(ListTile),
    );

    await tester.tap(tab('Verbände'));
    await pumpUntil(tester, find.byType(CantonMap));
    await shot(tester, 'associations-map');
    await tester.tap(find.textContaining('(BKSV)'));
    await pumpUntil(tester, tilesIn('Kantone / Gauverbände'));
    await pumpUntil(tester, find.byType(CantonMap));
    final map = find.descendant(of: find.byType(CantonMap), matching: find.byType(GestureDetector)).first;
    await tester.ensureVisible(map);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(map);
    await tester.pump(const Duration(milliseconds: 300));
    await shot(tester, 'association');
    await tester.ensureVisible(tilesIn('Kantone / Gauverbände').first);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(tilesIn('Kantone / Gauverbände').first);
    await pumpUntil(tester, tilesIn('Schwingklubs'));
    await tester.tap(tilesIn('Schwingklubs').first);
    await pumpUntil(tester, tilesIn('Schwinger'));
    await shot(tester, 'club');

    await tester.tap(find.byTooltip('Fehler melden'));
    await pumpUntil(tester, find.text('Was ist passiert?'));
    await tester.enterText(find.byType(TextField).last, 'Der Klub hat zu wenige Schwinger.');
    await tester.pump(const Duration(milliseconds: 300));
    await shot(tester, 'bug-report');
    await tester.tap(find.text('Abbrechen'));
    await tester.pump(const Duration(seconds: 1));

    await tester.tap(tab('Verbände'));
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.byTooltip('Einstellungen'));
    await pumpUntil(tester, find.text('Darstellung'));
    await shot(tester, 'settings');
    await tester.tap(find.text('Dunkel'));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.tap(find.text('Français'));
    await pumpUntil(tester, find.text('Apparence'));
    await shot(tester, 'settings-dark-fr');
    await tester.tap(find.text('Rechercher de nouvelles données'));
    await pumpUntil(tester, find.textContaining(RegExp('à jour|Nouvelles données|Erreur')));
    await shot(tester, 'settings-checked');
    await tester.tap(tab('Associations'));
    await tester.pump(const Duration(seconds: 1));
    await shot(tester, 'associations-dark');
    await tester.tap(tab('Lutteurs'));
    await tester.pump(const Duration(seconds: 1));
    await shot(tester, 'rank-duel-dark');
  });
}
