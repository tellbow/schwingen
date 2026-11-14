import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tellbow/l10n/app_localizations.dart';
import 'package:tellbow/screens/widgets.dart';

Future<void> pumpSection(WidgetTester tester, List<String> items) => tester.pumpWidget(
  MaterialApp(
    locale: const Locale('de'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: SingleChildScrollView(
        child: SearchableSection<String>(
          title: 'Ranglisten',
          hint: 'Schwingfest suchen',
          items: items,
          text: (s) => s,
          tile: (s) => Text(s),
        ),
      ),
    ),
  ),
);

void main() {
  final festivals = [for (var i = 1; i <= 25; i++) 'Schwingfest $i'];

  testWidgets('shows ten at a time', (tester) async {
    await pumpSection(tester, festivals);
    expect(find.textContaining('Schwingfest '), findsNWidgets(11));
    await tester.tap(find.text('Mehr anzeigen'));
    await tester.pump();
    expect(find.textContaining('Schwingfest '), findsNWidgets(21));
  });

  testWidgets('filters by every word typed', (tester) async {
    await pumpSection(tester, festivals);
    await tester.enterText(find.byType(TextField), 'fest 2');
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Schwingfest 2'), findsOneWidget);
    expect(find.text('Schwingfest 25'), findsOneWidget);
    expect(find.text('Schwingfest 3'), findsNothing);
    expect(find.text('Mehr anzeigen'), findsNothing);
  });

  testWidgets('a short list has neither search nor more', (tester) async {
    await pumpSection(tester, festivals.take(3).toList());
    expect(find.byType(TextField), findsNothing);
    expect(find.text('Mehr anzeigen'), findsNothing);
  });
}
