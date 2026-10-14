import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:tellbow/data/bug_report.dart';
import 'package:tellbow/l10n/app_localizations.dart';
import 'package:tellbow/screens/bug_report_sheet.dart';
import 'package:tellbow/screens/place_observer.dart';

void main() {
  group('sendBugReport', () {
    test('posts the report from the app to the website', () async {
      late http.Request sent;
      final client = MockClient((request) async {
        sent = request;
        return http.Response('{"ok":true}', 201);
      });
      await sendBugReport(
        client,
        description: 'Rang falsch',
        place: '/wrestler/w1',
        version: '0.1.0',
        system: 'iOS 26',
      );
      expect(sent.url, bugReportUrl);
      expect(jsonDecode(sent.body), {
        'description': 'Rang falsch',
        'place': '/wrestler/w1',
        'platform': 'ios',
        'version': '0.1.0',
        'system': 'iOS 26',
      });
    });

    test('fails with the status, telling a rate limit apart', () async {
      Future<void> answer(int status) => sendBugReport(
        MockClient((_) async => http.Response('', status)),
        description: 'x',
        place: '/',
        version: '',
        system: '',
      );
      await expectLater(answer(429), throwsA(isA<BugReportException>().having((e) => e.busy, 'busy', isTrue)));
      await expectLater(answer(502), throwsA(isA<BugReportException>().having((e) => e.busy, 'busy', isFalse)));
    });
  });

  group('PlaceObserver', () {
    PageRoute<void> page(String? name) => MaterialPageRoute(
      settings: RouteSettings(name: name),
      builder: (_) => const SizedBox(),
    );

    test('follows the named page on top', () {
      final observer = PlaceObserver('/wrestler');
      final profile = page('/wrestler/w1');
      observer.didPush(profile, page('/wrestler'));
      expect(observer.place, '/wrestler/w1');
      observer.didPop(page('/head2head/w1-w2'), profile);
      expect(observer.place, '/wrestler/w1');
    });

    test('ignores routes without a name', () {
      final observer = PlaceObserver('/places');
      observer.didPush(page(null), null);
      expect(observer.place, '/places');
    });
  });

  group('BugReportSheet', () {
    Future<void> pump(WidgetTester tester, Future<void> Function(String) send) => tester.pumpWidget(
      MaterialApp(
        locale: const Locale('de'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: BugReportSheet(place: '/wrestler/w1', send: send),
        ),
      ),
    );

    testWidgets('sends the description and confirms', (tester) async {
      String? sent;
      await pump(tester, (description) async => sent = description);
      expect(find.textContaining('(/wrestler/w1)'), findsOneWidget);
      await tester.enterText(find.byType(TextField), '  Rang falsch  ');
      await tester.pump();
      await tester.tap(find.text('Senden'));
      await tester.pumpAndSettle();
      expect(sent, 'Rang falsch');
      expect(find.text('Danke! Dein Bericht ist angekommen.'), findsOneWidget);
    });

    testWidgets('keeps the text after a failure and says when it is rate limited', (tester) async {
      var answer = 502;
      await pump(tester, (_) async => throw BugReportException(answer));
      await tester.enterText(find.byType(TextField), 'Rang falsch');
      await tester.pump();
      await tester.tap(find.text('Senden'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Dein Text bleibt hier'), findsOneWidget);
      expect(find.text('Rang falsch'), findsOneWidget);

      answer = 429;
      await tester.tap(find.text('Senden'));
      await tester.pumpAndSettle();
      expect(find.textContaining('zu viele Berichte'), findsOneWidget);
    });
  });
}
