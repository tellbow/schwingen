import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

final releasesUrl = Uri.parse('https://api.github.com/repos/tellbow/schwingen/releases?per_page=10');

class Release {
  const Release({required this.tag, required this.url, required this.size});

  final String tag;
  final Uri url;
  final int size;
}

Release? newestWithData(List<Object?> releases) {
  for (final release in releases.cast<Map<String, Object?>>()) {
    if (release['draft'] == true || release['prerelease'] == true) continue;
    for (final asset in (release['assets'] as List? ?? const []).cast<Map<String, Object?>>()) {
      if (asset['name'] == 'data.db') {
        return Release(
          tag: release['tag_name'] as String,
          url: Uri.parse(asset['browser_download_url'] as String),
          size: asset['size'] as int,
        );
      }
    }
  }
  return null;
}

Future<Release?> fetchLatestRelease(http.Client client) async {
  final res = await client.get(releasesUrl, headers: {'Accept': 'application/vnd.github+json'});
  if (res.statusCode != 200) throw HttpException('GitHub answered ${res.statusCode}', uri: releasesUrl);
  return newestWithData(jsonDecode(res.body) as List<Object?>);
}

Future<void> download(http.Client client, Release release, File target, void Function(double) onProgress) async {
  final res = await client.send(http.Request('GET', release.url));
  if (res.statusCode != 200) throw HttpException('Download answered ${res.statusCode}', uri: release.url);
  final total = res.contentLength ?? release.size;
  final sink = target.openWrite();
  var received = 0;
  try {
    await for (final chunk in res.stream) {
      sink.add(chunk);
      received += chunk.length;
      onProgress(total > 0 ? received / total : 0);
    }
  } finally {
    await sink.close();
  }
  if (received != total) throw HttpException('Download incomplete: $received of $total bytes', uri: release.url);
}
