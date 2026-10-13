import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;

import 'release.dart';

class DataStore {
  DataStore(this.dir, this.client);

  final Directory dir;
  final http.Client client;

  File get database => File(p.join(dir.path, 'data.db'));

  File get _tag => File(p.join(dir.path, 'release'));

  File get _partial => File(p.join(dir.path, 'data.db.part'));

  bool get installed => database.existsSync() && _tag.existsSync();

  String? get installedTag => _tag.existsSync() ? _tag.readAsStringSync().trim() : null;

  Future<Release?> newerRelease() async {
    final latest = await fetchLatestRelease(client);
    return latest == null || latest.tag == installedTag ? null : latest;
  }

  Future<File> fetch(Release release, void Function(double) onProgress) async {
    await dir.create(recursive: true);
    await download(client, release, _partial, onProgress);
    if (!await isSqlite(_partial)) {
      await _partial.delete();
      throw const FormatException('data.db is not a SQLite database');
    }
    return _partial;
  }

  Future<void> swap(File fetched, Release release) async {
    await fetched.rename(database.path);
    await _tag.writeAsString(release.tag);
  }
}

Future<bool> isSqlite(File file) async {
  final head = await file.openRead(0, 16).fold<List<int>>([], (all, chunk) => all..addAll(chunk));
  return String.fromCharCodes(head) == 'SQLite format 3\u0000';
}
