import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

final bugReportUrl = Uri.parse('https://schwingen.tellbow.ch/api/bug-report');

const maxScreenshotBytes = 4 * 1024 * 1024;

class BugReportException implements Exception {
  const BugReportException(this.status);

  final int status;

  bool get busy => status == 429;

  @override
  String toString() => 'Bug report answered $status';
}

Future<void> sendBugReport(
  http.Client client, {
  required String description,
  required String place,
  required String version,
  required String system,
  Uint8List? screenshot,
}) async {
  final res = await client.post(
    bugReportUrl,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'description': description,
      'place': place,
      'platform': 'ios',
      'version': version,
      'system': system,
      if (screenshot != null) 'screenshot': base64Encode(screenshot),
    }),
  );
  if (res.statusCode != 201) throw BugReportException(res.statusCode);
}
