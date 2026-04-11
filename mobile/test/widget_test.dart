import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:workout/data/dao/workout_dao.dart';
import 'package:workout/data/db/database.dart';
import 'package:workout/data/models/db_exercise_set.dart';
import 'package:workout/data/models/set_type.dart';
import 'package:workout/features/active_workout/active_workout_screen.dart';
import 'package:workout/style/app_style.dart';

const String _pushDayTemplateId = 'app-01KE6BHGJAFFKEAQ7X760EBPHJ';

Future<AppDatabase> _openTestDatabase(WidgetTester tester) async {
  // Use the FFI sqlite implementation in tests so we can run on the host
  // Dart VM without a connected device.
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  // Bootstrap reads `rootBundle` (real I/O) and runs FFI sqlite calls;
  // those need real wall time, which only `runAsync` provides inside a
  // widget test.
  late AppDatabase db;
  await tester.runAsync(() async {
    db = await AppDatabase.openAt(inMemoryDatabasePath);
  });
  return db;
}

/// Make the test surface tall enough that the four-card `ListView` builds
/// every slot. The default 800×600 viewport crops the lower slots and
/// `ListView` lazily skips building children that aren't laid out, which
/// breaks `find.text` lookups for off-screen exercise names.
Future<void> _useTallSurface(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(400, 2400));
  addTearDown(() => tester.binding.setSurfaceSize(null));
}

Widget _wrap(AppDatabase db) {
  return MaterialApp(
    theme: AppStyle.theme(),
    home: ActiveWorkoutScreen(
      database: db,
      templateId: _pushDayTemplateId,
    ),
  );
}

/// One step of the bounded poll loop. We have to advance two clocks:
///
///   1. **Real wall time** via `runAsync(Future.delayed)` — needed because
///      our async work hits real I/O (`rootBundle.loadString` for schema
///      assets and FFI calls into sqlite). `tester.pump` alone only runs
///      microtasks, so these real Futures can starve.
///   2. **The fake animation clock** via `tester.pump(step)` — needed
///      because Flutter `Ticker`s (e.g. the bottom-sheet slide-up) only
///      advance when the test driver explicitly ticks them. Without this
///      a freshly-shown modal sheet stays parked off-screen at the bottom
///      and `tester.tap` lands outside the viewport.
///
/// We can't use `pumpAndSettle` for the same reason we wrote this loop in
/// the first place: the loading `CircularProgressIndicator` is an infinite
/// animation and settle would never converge.
Future<void> _tick(WidgetTester tester, Duration step) async {
  await tester.runAsync(() => Future<void>.delayed(step));
  await tester.pump(step);
}

/// Pumps until [finder] matches at least one widget, or until [maxAttempts]
/// frames have passed. See [_tick] for why this is a custom loop.
Future<void> _pumpUntilFound(
  WidgetTester tester,
  Finder finder, {
  int maxAttempts = 100,
  Duration step = const Duration(milliseconds: 50),
}) async {
  for (var i = 0; i < maxAttempts; i++) {
    await _tick(tester, step);
    if (finder.evaluate().isNotEmpty) return;
  }
  throw StateError('Timed out waiting for $finder after $maxAttempts pumps');
}

/// Mirror of [_pumpUntilFound] that waits until [finder] no longer matches.
Future<void> _pumpUntilGone(
  WidgetTester tester,
  Finder finder, {
  int maxAttempts = 100,
  Duration step = const Duration(milliseconds: 50),
}) async {
  for (var i = 0; i < maxAttempts; i++) {
    await _tick(tester, step);
    if (finder.evaluate().isEmpty) return;
  }
  throw StateError('Timed out waiting for $finder to disappear');
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('active workout screen renders all four Push Day cards',
      (WidgetTester tester) async {
    await _useTallSurface(tester);
    final db = await _openTestDatabase(tester);
    addTearDown(db.close);

    await tester.pumpWidget(_wrap(db));
    await _pumpUntilFound(tester, find.text('push day'));

    expect(find.text('push day'), findsOneWidget);
    // The four canonical Push Day exercise names — index=0 variants.
    expect(find.text('Bench Press'), findsOneWidget);
    expect(find.text('Overhead Press'), findsOneWidget);
    expect(find.text('Lateral Raise'), findsOneWidget);
    expect(find.text('Triceps Pushdown'), findsOneWidget);
  });

  testWidgets('swap on slot 1 switches Bench Press to Incline Bench Press',
      (WidgetTester tester) async {
    // NOTE: keep the default 800×600 surface — `showModalBottomSheet`
    // anchors itself to the bottom of MediaQuery, so a tall surface
    // pushes the sheet contents off-screen and `tester.tap` misses.
    final db = await _openTestDatabase(tester);
    addTearDown(db.close);

    await tester.pumpWidget(_wrap(db));
    await _pumpUntilFound(tester, find.text('Bench Press'));

    expect(find.text('Bench Press'), findsOneWidget);
    expect(find.text('Incline Bench Press'), findsNothing);

    // First swap pill in the tree is slot 1 (Bench Press).
    await tester.tap(find.byIcon(Icons.swap_horiz).first);
    await _pumpUntilFound(tester, find.text('Incline Bench Press'));
    // The text appears in the tree on frame 1 of the bottom sheet's
    // slide-up, but its render box is still off-screen until the 250 ms
    // animation finishes. Tick the fake clock past the animation so the
    // tap below lands on the actual on-screen position.
    for (var i = 0; i < 10; i++) {
      await _tick(tester, const Duration(milliseconds: 50));
    }

    // Sheet open: both variants visible.
    expect(find.text('Bench Press'), findsWidgets);
    expect(find.text('Incline Bench Press'), findsOneWidget);

    await tester.tap(find.text('Incline Bench Press'));
    // After tapping, the bottom sheet pops and the card re-renders. The
    // strongest signal the swap committed (not just that the sheet is
    // open) is Bench Press disappearing from the tree.
    await _pumpUntilGone(tester, find.text('Bench Press'));

    expect(find.text('Incline Bench Press'), findsOneWidget);
    expect(find.text('Bench Press'), findsNothing);
  });

  testWidgets(
      'tap Set cell on Bench Press set 2 opens type sheet, '
      'selecting Failure persists set_type to disk', (WidgetTester tester) async {
    // Keep the default 800×600 surface so the modal bottom sheet renders
    // inside the viewport — same reason the swap test does.
    final db = await _openTestDatabase(tester);
    addTearDown(db.close);

    await tester.pumpWidget(_wrap(db));
    await _pumpUntilFound(tester, find.text('Bench Press'));

    // Initial seed: Bench Press has W (warmup) + 3 regular sets, so the
    // Set column reads `W 1 2 3`. No drop-set / failure rows exist yet.
    final ones = find.text('1');
    expect(ones, findsWidgets);
    expect(find.text('F'), findsNothing);

    // The first "1" in the tree is Bench Press's set 2 cell — the row
    // AC #7 says to mutate. Default surface keeps later cards out of
    // view so we don't pick up another card's "1".
    await tester.tap(ones.first);
    await _pumpUntilFound(tester, find.text('Set type'));
    // Settle the slide-up animation past 250 ms so the row's render box
    // lives inside the viewport and the tap below actually lands.
    for (var i = 0; i < 10; i++) {
      await _tick(tester, const Duration(milliseconds: 50));
    }

    // Sheet open: every type label is visible. Note "Regular" not
    // "Regular set" — the picker label is fixed, no position number.
    expect(find.text('Warm-up'), findsOneWidget);
    expect(find.text('Regular'), findsOneWidget);
    expect(find.text('Drop set'), findsOneWidget);
    expect(find.text('Failure'), findsOneWidget);

    await tester.tap(find.text('Failure'));
    // Wait until the sheet's title is fully gone before asserting on
    // the row — otherwise the sheet's preview F badge is still in the
    // tree alongside the new row badge.
    await _pumpUntilGone(tester, find.text('Set type'));

    // Sheet gone, row updated: an "F" badge appears in the Set column.
    // Non-warmup numbering still includes the failure row in the count,
    // so the slot now reads `W F 2 3` — exactly one F, no second "1".
    expect(find.text('F'), findsOneWidget);
    expect(find.text('Failure'), findsNothing);

    // AC #7 in-process verification: query the actual exercise_set row
    // through WorkoutDao.getSet and assert set_type made it to disk.
    // Look up by `set_type = 'failure'` to find the row id without
    // having to thread it through the widget tree.
    //
    // The DAO/raw-query calls hit FFI sqlite, which is real I/O and
    // needs real wall time — awaiting them inside the test's fake-async
    // zone hangs forever. `runAsync` opts the awaits into the real
    // event loop the same way `_tick` does for the UI ticks above.
    late final List<Map<String, Object?>> rows;
    DbExerciseSet? updated;
    await tester.runAsync(() async {
      final dao = WorkoutDao(db.raw);
      rows = await db.raw.query(
        'exercise_set',
        where: 'set_type = ?',
        whereArgs: ['failure'],
      );
      if (rows.isNotEmpty) {
        updated = await dao.getSet(rows.first['id']! as String);
      }
    });
    expect(rows, hasLength(1));
    expect(updated, isNotNull);
    expect(updated!.setType, SetType.failure);
  });

  testWidgets('add set inserts a new row at the bottom of the slot',
      (WidgetTester tester) async {
    // Default surface is fine — slot 1 (Bench Press) and its + Add Set
    // button are at the top of the ListView and always visible.
    final db = await _openTestDatabase(tester);
    addTearDown(db.close);

    await tester.pumpWidget(_wrap(db));
    await _pumpUntilFound(tester, find.text('Bench Press'));

    // Bench Press has 4 planned sets in the seed (1 warmup + 3 working).
    // Tap the first + Add Set button (which belongs to Bench Press).
    final addSetFinder = find.text('+ Add Set');
    expect(addSetFinder, findsWidgets);
    final initialAddCount = tester.widgetList(addSetFinder).length;

    await tester.tap(addSetFinder.first);
    await _pumpUntilFound(tester, find.text('4'));

    // The total number of "+ Add Set" buttons hasn't changed (one per
    // card), but the working-set numbering should now include a `4`.
    expect(find.text('+ Add Set'), findsNWidgets(initialAddCount));
    expect(find.text('4'), findsWidgets);
  });
}
