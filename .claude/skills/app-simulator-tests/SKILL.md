---
name: app-simulator-tests
description: Runs the Tellbow app's integration test (app/integration_test/app_test.dart) on the iOS simulator; it downloads the newest release's data from GitHub and drives every tab. Use after changing app screens, navigation, queries or the data download.
---

# App integration test on the simulator

The test needs no dev stack: like the real app, it downloads the newest
GitHub release's `app.db.gz` (about 34 MB), so it needs the network and
tests against the schema that release shipped.

1. **Simulator:** `xcrun simctl list devices booted`; if none is booted,
   take an iPhone from `xcrun simctl list devices available`, then
   `xcrun simctl boot <id>` and `xcrun simctl bootstatus <id> -b`.
2. **Run:** `cd app && flutter test integration_test/app_test.dart -d <simulator id>`
   (a few minutes; the first build takes longest).
3. **Report** passed or the failing test with its message.

Pitfalls:
- The test finds widgets by their German text. With empty settings the
  app follows the simulator's language and falls back to German: a
  simulator set to French fails it.
- A schema change not yet released: test the queries with
  `TELLBOW_DB=<data.db> flutter test test/release_database_test.dart`
  instead (CLAUDE.md, «iOS App»).
- To see what the app shows: `xcrun simctl io <id> screenshot /path/to/shot.png`.
