import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:tellbow/l10n/app_localizations.dart';
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

final tabs = find.byWidgetPredicate((w) => w is NavigationBar || w is NavigationRail);

Finder tab(String label) => find.descendant(of: tabs, matching: find.text(label));

final page = find.byWidgetPredicate((w) => w is Scrollable && w.axisDirection == AxisDirection.down).first;

Finder rich(String text) => find.textContaining(text, findRichText: true);

const language = String.fromEnvironment('TELLBOW_TEST_LANG', defaultValue: 'de');

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  WidgetController.hitTestWarningShouldBeFatal = true;

  testWidgets('downloads the data and shows every tab', (tester) async {
    SharedPreferencesAsyncPlatform.instance = InMemorySharedPreferencesAsync.empty();
    final settings = await Settings.load();
    await settings.setLocale(const Locale(language));
    final l10n = lookupAppLocalizations(const Locale(language));
    await tester.pumpWidget(TellbowApp(store: openStore(), settings: settings));
    await pumpUntil(
      tester,
      find.byWidgetPredicate((w) => w is NavigationBar || w is NavigationRail || w is Text && w.data == l10n.download),
    );

    if (tabs.evaluate().isEmpty) {
      await shot(tester, 'first-launch');
      await tester.tap(find.widgetWithText(FilledButton, l10n.download));
      await pumpUntil(tester, find.byType(LinearProgressIndicator));
      await shot(tester, 'downloading');
      await pumpUntil(tester, tabs, timeout: const Duration(minutes: 10));
    }
    await pumpUntil(tester, find.byType(ListTile));
    await shot(tester, 'wrestlers');

    await tester.enterText(find.byType(TextField), 'staudenmann fabian');
    await pumpUntil(tester, rich('Fabian Staudenmann'));
    await tester.tap(rich('Fabian Staudenmann').first);
    await pumpUntil(tester, find.text(l10n.draws));
    await shot(tester, 'wrestler');

    await tester.scrollUntilVisible(find.byType(LineChart).first, 300, scrollable: page);
    await tester.ensureVisible(find.text(l10n.trends));
    await tester.pump(const Duration(milliseconds: 300));
    await shot(tester, 'trends');
    await tester.scrollUntilVisible(find.text(l10n.outcomesBySeason), 300, scrollable: page);
    await shot(tester, 'outcomes');
    await tester.scrollUntilVisible(find.text('2025'), -300, scrollable: page);

    await tester.tap(find.text('2025'));
    await pumpUntil(tester, find.text(l10n.eloOfYear(2025)));
    await shot(tester, 'wrestler-2025');
    await tester.scrollUntilVisible(find.text(l10n.festivalRanks), 300, scrollable: page);
    await tester.ensureVisible(find.text(l10n.festivalRanks));
    await tester.pump(const Duration(milliseconds: 300));
    await shot(tester, 'festival-charts');

    final firstOpponent = find.descendant(
      of: find.ancestor(of: find.text(l10n.opponents), matching: find.byType(Card)),
      matching: find.byType(ListTile),
    );
    await tester.scrollUntilVisible(firstOpponent.first, 300, scrollable: page);
    await tester.ensureVisible(firstOpponent.first);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(firstOpponent.first);
    await pumpUntil(tester, find.text(l10n.meetings));
    await shot(tester, 'head-to-head');
    await tester.scrollUntilVisible(find.text(l10n.rankBySeason), 300, scrollable: page);
    await tester.pump(const Duration(milliseconds: 300));
    await shot(tester, 'rank-duel');

    await tester.tap(tab(l10n.navPlaces));
    await pumpUntil(tester, find.byType(ListTile));
    await shot(tester, 'places');
    await tester.tap(find.byType(ListTile).first);
    await pumpUntil(tester, find.byType(ExpansionTile));
    await shot(tester, 'points-distribution');
    await tester.tap(find.byType(ExpansionTile).first);
    await tester.pump(const Duration(milliseconds: 500));
    await shot(tester, 'place');

    await tester.tap(tab(l10n.tabStatistics));
    await pumpUntil(tester, find.text(l10n.topWins));
    await shot(tester, 'statistics');
    await tester.scrollUntilVisible(find.text(l10n.topWreaths), 300, scrollable: page);
    await tester.pump(const Duration(milliseconds: 300));
    await shot(tester, 'statistics-bars');

    Finder tilesIn(String section) => find.descendant(
      of: find.ancestor(of: find.text(section), matching: find.byType(Card)),
      matching: find.byType(ListTile),
    );

    await tester.tap(tab(l10n.tabAssociations));
    await pumpUntil(tester, find.byType(CantonMap));
    await shot(tester, 'associations-map');
    await tester.tap(find.textContaining('(BKSV)'));
    await pumpUntil(tester, tilesIn(l10n.cantons));
    await pumpUntil(tester, find.byType(CantonMap));
    final map = find.descendant(of: find.byType(CantonMap), matching: find.byType(GestureDetector)).first;
    await tester.ensureVisible(map);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(map);
    await tester.pump(const Duration(milliseconds: 300));
    await shot(tester, 'association');
    await tester.ensureVisible(tilesIn(l10n.cantons).first);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(tilesIn(l10n.cantons).first);
    await pumpUntil(tester, tilesIn(l10n.clubs));
    await tester.tap(tilesIn(l10n.clubs).first);
    await pumpUntil(tester, tilesIn(l10n.tabWrestlers));
    await shot(tester, 'club');

    await tester.tap(find.byTooltip(l10n.bugReport));
    await pumpUntil(tester, find.text(l10n.bugWhat));
    await tester.enterText(find.byType(TextField).last, 'Der Klub hat zu wenige Schwinger.');
    await tester.pump(const Duration(milliseconds: 300));
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pump(const Duration(milliseconds: 500));
    await shot(tester, 'bug-report');
    await tester.tap(find.text(l10n.cancel));
    await tester.pump(const Duration(seconds: 1));

    await tester.tap(tab(l10n.tabAssociations));
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.byTooltip(l10n.settings));
    await pumpUntil(tester, find.text(l10n.appearance));
    await shot(tester, 'settings');
    await tester.tap(find.text(l10n.dark));
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
