import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:workout/data/db/database.dart';
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
