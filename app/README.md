# Tellbow iOS app

Flutter app with the whole Tellbow database on the phone: wrestlers, festivals with their rankings,
head-to-head and the yearly statistics, without internet once the data is there.

## Data

The app reads the `data.db` of a GitHub release of `tellbow/schwingen` (the same file the
pocketbase initContainer loads), read-only with sqflite:

- First launch: it looks up the newest release with a `data.db` (`api.github.com`, no token) and
  downloads it (about 200 MB) to `Application Support/data/`, excluded from iCloud backup.
- Later launches: it opens the installed copy at once and checks for a newer release in the
  background; a banner offers it. The new file is checked to be SQLite before it replaces the old one.

Queries run on the PocketBase tables and views as they are in the release (`lib/data/queries.dart`).
A schema change on the web side (`pb_migrations/`) that renames a column or view breaks the app
until it follows.

## Run

```sh
flutter run -d <simulator id>
```

## Tests

```sh
flutter analyze
flutter test                                            # stats, download, queries on a fixture
TELLBOW_DB=/path/to/data.db flutter test test/release_database_test.dart   # every query on a real release
flutter test integration_test/app_test.dart -d <simulator id>             # download and every tab
```

`flutter test` uses the operating system's SQLite (`hooks.user_defines` in `pubspec.yaml`), Apple's
build on macOS like on the iPhone. The integration test downloads the real release on a fresh
install and prints `SHOT <name>` where a screenshot is worth taking
(`xcrun simctl io <id> screenshot <file>`).
