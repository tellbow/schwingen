import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:tellbow/data/release.dart';
import 'package:tellbow/data/store.dart';

final sqliteBytes = [...utf8.encode('SQLite format 3'), 0, ...List.filled(100, 1)];

Map<String, Object?> releaseJson(String tag, {bool draft = false, bool prerelease = false, bool withData = true}) => {
  'tag_name': tag,
  'draft': draft,
  'prerelease': prerelease,
  'assets': [
    {'name': 'notes.txt', 'browser_download_url': 'https://example.test/notes', 'size': 1},
    if (withData) {'name': 'data.db', 'browser_download_url': 'https://example.test/$tag/data.db', 'size': 116},
  ],
};

MockClient github(List<Map<String, Object?>> releases, {List<int>? body, int status = 200, int? announced}) =>
    MockClient.streaming((request, _) async {
      final bytes = request.url == releasesUrl ? utf8.encode(jsonEncode(releases)) : body ?? sqliteBytes;
      return http.StreamedResponse(
        Stream.value(bytes),
        request.url == releasesUrl ? 200 : status,
        contentLength: announced ?? bytes.length,
      );
    });

void main() {
  group('newestWithData', () {
    test('skips drafts, prereleases and releases without data.db', () {
      final release = newestWithData([
        releaseJson('v3.0.0', draft: true),
        releaseJson('v2.2.0', prerelease: true),
        releaseJson('v2.1.3', withData: false),
        releaseJson('v2.1.2'),
        releaseJson('v2.1.1'),
      ]);
      expect(release?.tag, 'v2.1.2');
      expect(release?.url, Uri.parse('https://example.test/v2.1.2/data.db'));
      expect(release?.size, 116);
    });

    test('is null when no release has data', () {
      expect(newestWithData([releaseJson('v1.0.0', withData: false)]), isNull);
      expect(newestWithData([]), isNull);
    });
  });

  test('fetchLatestRelease fails on an error answer', () {
    final client = MockClient((_) async => http.Response('rate limited', 403));
    expect(fetchLatestRelease(client), throwsA(isA<HttpException>()));
  });

  group('DataStore', () {
    late Directory dir;

    setUp(() async => dir = await Directory.systemTemp.createTemp('tellbow'));
    tearDown(() => dir.delete(recursive: true));

    test('installs a release and then finds nothing newer', () async {
      final store = DataStore(dir, github([releaseJson('v2.1.2')]));
      expect(store.installed, isFalse);

      final release = await store.newerRelease();
      expect(release?.tag, 'v2.1.2');
      final progress = <double>[];
      final fetched = await store.fetch(release!, progress.add);
      await store.swap(fetched, release);

      expect(store.installed, isTrue);
      expect(store.installedTag, 'v2.1.2');
      expect(await store.database.readAsBytes(), sqliteBytes);
      expect(progress.last, 1);
      expect(await store.newerRelease(), isNull);
    });

    test('offers a newer release', () async {
      await File('${dir.path}/release').writeAsString('v2.1.1');
      expect((await DataStore(dir, github([releaseJson('v2.1.2')])).newerRelease())?.tag, 'v2.1.2');
    });

    test('rejects a download that is not SQLite and keeps the installed database', () async {
      await File('${dir.path}/data.db').writeAsBytes(sqliteBytes);
      await File('${dir.path}/release').writeAsString('v2.1.1');
      final store = DataStore(dir, github([releaseJson('v2.1.2')], body: List.filled(116, 0)));
      final release = (await store.newerRelease())!;

      await expectLater(store.fetch(release, (_) {}), throwsFormatException);
      expect(store.installedTag, 'v2.1.1');
      expect(await store.database.readAsBytes(), sqliteBytes);
      expect(File('${dir.path}/data.db.part').existsSync(), isFalse);
    });

    test('rejects an incomplete or failed download', () async {
      final short = DataStore(dir, github([releaseJson('v2.1.2')], body: sqliteBytes.sublist(0, 50), announced: 116));
      final release = (await short.newerRelease())!;
      await expectLater(short.fetch(release, (_) {}), throwsA(isA<HttpException>()));

      final failing = DataStore(dir, github([releaseJson('v2.1.2')], status: 404));
      await expectLater(failing.fetch(release, (_) {}), throwsA(isA<HttpException>()));
      expect(failing.installed, isFalse);
    });
  });
}
