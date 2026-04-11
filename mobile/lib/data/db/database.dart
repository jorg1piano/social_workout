import 'dart:developer' as developer;

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import 'bootstrap.dart';

/// Opens and manages the application's single SQLite database.
///
/// Schema lives in `sqlite/schema.sql` (the repo root) and is mirrored into
/// `mobile/assets/sqlite/schema.sql` via `just copy-schema`. On first launch
/// we exec the full schema + seeds from those asset files; on subsequent
/// launches we just re-open the existing file.
///
/// We intentionally do NOT use sqflite's `onCreate`/`onUpgrade` hooks —
/// those would force us to split schema DDL across Dart migration functions.
/// Instead we track a `PRAGMA user_version` ourselves and run the full
/// asset bootstrap once when it's 0.
class AppDatabase {
  AppDatabase._(this._db);

  final Database _db;

  /// The raw sqflite handle. DAOs take this and run statements against it.
  Database get raw => _db;

  /// Default filename inside the app's documents directory.
  static const String _dbFileName = 'social_workout.db';

  /// Bump when the asset-bootstrap shape changes (e.g. schema revs).
  static const int _currentUserVersion = 1;

  /// Resolves the DB path under the app documents directory, opens the
  /// file, enables foreign keys, and runs the first-launch bootstrap on
  /// fresh installs. This is the production entry point called from
  /// `main.dart`.
  static Future<AppDatabase> openAndInitialize() async {
    final docsDir = await getApplicationDocumentsDirectory();
    final dbPath = p.join(docsDir.path, _dbFileName);
    return openAt(dbPath);
  }

  /// Opens a database at an explicit path. Extracted so tests can pass
  /// `inMemoryDatabasePath` without pulling in `path_provider` (which
  /// has no host-side test harness).
  static Future<AppDatabase> openAt(String dbPath) async {
    final db = await openDatabase(
      dbPath,
      version: _currentUserVersion,
      // sqflite disables FK enforcement by default — we turn it on here so
      // ON DELETE CASCADE / RESTRICT behave consistently with the backend.
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      // `onCreate` fires when the file is missing (fresh install). We use
      // this signal to run the asset bootstrap. Note that once the DB file
      // exists, sqflite won't call this again — the `version` argument just
      // drives onCreate vs onUpgrade dispatch.
      onCreate: (db, version) async {
        developer.log(
          'fresh DB at $dbPath — running asset bootstrap',
          name: 'AppDatabase',
        );
        await DatabaseBootstrap.run(db);
      },
    );

    // Confirm FK enforcement stuck — logged once per launch for debugging.
    final fkResult = await db.rawQuery('PRAGMA foreign_keys');
    developer.log(
      'opened $dbPath (foreign_keys=${fkResult.first.values.first})',
      name: 'AppDatabase',
    );

    return AppDatabase._(db);
  }

  Future<void> close() => _db.close();
}
