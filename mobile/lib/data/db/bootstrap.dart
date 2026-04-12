import 'package:flutter/services.dart' show rootBundle;
import 'package:sqflite/sqflite.dart';

/// First-launch bootstrap: load canonical SQL from assets and run it against
/// a fresh SQLite database. Schema parity is guaranteed by `just copy-schema`,
/// which keeps `mobile/assets/sqlite/*.sql` byte-equal to `sqlite/*.sql`.
///
/// The three assets, in dependency order:
///   1. `schema.sql`             — DDL for all tables + indexes.
///   2. `exercises_complete.sql` — the exercise library (297 rows).
///   3. `new-test-data.sql`      — templates, set plans, and historical
///                                 workouts the UI reads and writes against.
///
/// Everything runs in a single transaction so a bad seed file rolls back
/// cleanly instead of leaving a half-populated DB on disk.
class DatabaseBootstrap {
  DatabaseBootstrap._();

  static const List<String> _assetScripts = [
    'assets/sqlite/schema.sql',
    'assets/sqlite/exercises_complete.sql',
    'assets/sqlite/new-test-data.sql',
    'assets/sqlite/feed-seed-data.sql',
    'assets/sqlite/competition-seed-data.sql',
    'assets/sqlite/training-program-seed-data.sql',
  ];

  /// Runs the full schema + seed against [db]. Caller must ensure this is
  /// only invoked on a fresh database (gated by `PRAGMA user_version`).
  static Future<void> run(Database db) async {
    await db.transaction((txn) async {
      for (final assetPath in _assetScripts) {
        final script = await rootBundle.loadString(assetPath);
        for (final statement in _splitStatements(script)) {
          await txn.execute(statement);
        }
      }
    });
  }

  /// Splits a multi-statement SQL script into individual executable
  /// statements. Strips whole-line `--` comments (the style used throughout
  /// `sqlite/*.sql`) so they don't confuse the splitter, then splits on `;`.
  ///
  /// This is deliberately simple: our canonical SQL files only use
  /// whole-line comments and plain `;` terminators, and none of the string
  /// literals in the seeds contain a `;`. If that ever changes, this
  /// splitter will need real lexer logic.
  static Iterable<String> _splitStatements(String script) {
    final withoutLineComments = script
        .split('\n')
        .where((line) => !line.trimLeft().startsWith('--'))
        .join('\n');
    return withoutLineComments
        .split(';')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty);
  }
}
