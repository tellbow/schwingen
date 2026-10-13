# Tellbow iOS app

Flutter app with the whole Tellbow database on the phone: wrestlers, festivals with their rankings,
head-to-head and the yearly statistics, without internet once the data is there.

## Data

The app reads a GitHub release of `tellbow/schwingen`, read-only with sqflite. Since the release
workflow builds it, a release carries `app.db.gz` (`scripts/build-app-db.sh`): only the tables,
columns and views the app reads, about 34 MB to download and 120 MB on the phone. Older releases
have only `data.db` (about 200 MB), which the app takes instead.

- First launch: it looks up the newest release with either file (`api.github.com`, no token),
  downloads it, decompressing on the way, to `Application Support/data/`, excluded from iCloud backup.
- Later launches: it opens the installed copy at once and checks for a newer release in the
  background; a banner offers it. A new file replaces the old one only when its size matches the
  page count in its SQLite header.

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
TELLBOW_DB=/path/to/app.db flutter test test/release_database_test.dart    # every query on a real release (app.db or data.db)
flutter test integration_test/app_test.dart -d <simulator id>             # download and every tab
```

`flutter test` uses the operating system's SQLite (`hooks.user_defines` in `pubspec.yaml`), Apple's
build on macOS like on the iPhone. The integration test downloads the real release on a fresh
install and prints `SHOT <name>` where a screenshot is worth taking
(`xcrun simctl io <id> screenshot <file>`).
