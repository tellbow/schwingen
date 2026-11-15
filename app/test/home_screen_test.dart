import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:tellbow/data/queries.dart';
import 'package:tellbow/l10n/app_localizations.dart';
import 'package:tellbow/screens/home_screen.dart';

import 'queries_test.dart' as fixture;

Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 5; i++) {
    await tester.runAsync(() => Future.delayed(const Duration(milliseconds: 200)));
    await tester.pump(const Duration(milliseconds: 400));
  }
}

void main() {
  testWidgets('the wrestler picker list reaches down to the keyboard', (tester) async {
    tester.view.physicalSize = const Size(1206, 2622);
    tester.view.devicePixelRatio = 3;
    tester.view.padding = const FakeViewPadding(top: 62 * 3, bottom: 34 * 3);
    tester.view.viewPadding = const FakeViewPadding(top: 62 * 3, bottom: 34 * 3);
    addTearDown(tester.view.reset);
    late Database db;
    await tester.runAsync(() async {
      sqfliteFfiInit();
      db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
      for (final sql in [...fixture.schema, ...fixture.data]) {
        await db.execute(sql);
      }
      for (var i = 0; i < 30; i++) {
        await db.execute("INSERT INTO wrestler (id, name, vorname) VALUES ('x$i', 'Muster$i', 'Max')");
      }
    });
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('de'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: HomeScreen(queries: Queries(db), settings: (_) => const SizedBox(), client: http.Client(), dataTag: null),
      ),
    );
    await tester.runAsync(() => Future.delayed(const Duration(milliseconds: 300)));
    await tester.pump();
    await tester.tap(find.text('Vergleich'));
    await settle(tester);
    await tester.tap(find.byType(ListTile).first);
    await settle(tester);
    tester.view.viewInsets = const FakeViewPadding(bottom: 336 * 3);
    tester.view.padding = const FakeViewPadding(top: 62 * 3);
    for (var i = 0; i < 5; i++) {
      await tester.runAsync(() => Future.delayed(const Duration(milliseconds: 200)));
      await tester.pump(const Duration(milliseconds: 300));
    }
    expect(tester.getRect(find.byType(ListView).last).bottom, 874 - 336);
  });
}
