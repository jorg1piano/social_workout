import 'package:flutter/foundation.dart';

import '../../data/dao/template_dao.dart';
import '../../data/dao/workout_dao.dart';
import '../../data/db/database.dart';
import '../../data/models/db_exercise.dart';
import '../../data/models/db_exercise_for_workout_template.dart';
import '../../data/models/db_exercise_set.dart';
import '../../data/models/db_workout.dart';
import '../../data/models/db_workout_template.dart';
import '../../data/models/set_type.dart';

/// One render-ready slot: the ordered position in a workout, the sibling
/// variants the user can swap between, the currently-selected variant, the
/// `exercise_set` rows logged against that variant in the current workout,
/// and (if any) the set rows from the most recent prior workout.
///
/// This is the immutable snapshot the UI paints from; mutations go through
/// [ActiveWorkoutController] which re-reads the slot from SQL after every
/// write so UI state never diverges from disk.
@immutable
class SlotState {
  final int ordering;
  final List<DbExerciseForWorkoutTemplate> variants;
  final Map<String, DbExercise> exerciseById;
  final int currentVariantIndex;
  final List<DbExerciseSet> sets;
  final List<DbExerciseSet> previousSessionSets;

  const SlotState({
    required this.ordering,
    required this.variants,
    required this.exerciseById,
    required this.currentVariantIndex,
    required this.sets,
    required this.previousSessionSets,
  });

  DbExerciseForWorkoutTemplate get currentVariant =>
      variants[currentVariantIndex];

  DbExercise get currentExercise => exerciseById[currentVariant.exerciseId]!;

  bool get hasAlternatives => variants.length > 1;

  int get variantCount => variants.length;

  /// Returns the previous-session set that lines up by `ordering`, or null
  /// if there's no matching prior row. Used to paint the "Previous" column.
  DbExerciseSet? previousForOrdering(int? ordering) {
    if (ordering == null) return null;
    for (final s in previousSessionSets) {
      if (s.ordering == ordering) return s;
    }
    return null;
  }

  SlotState copyWith({
    int? currentVariantIndex,
    List<DbExerciseSet>? sets,
    List<DbExerciseSet>? previousSessionSets,
  }) {
    return SlotState(
      ordering: ordering,
      variants: variants,
      exerciseById: exerciseById,
      currentVariantIndex: currentVariantIndex ?? this.currentVariantIndex,
      sets: sets ?? this.sets,
      previousSessionSets: previousSessionSets ?? this.previousSessionSets,
    );
  }
}

/// Owns the active workout screen's state machine. Wraps [WorkoutDao] and
/// [TemplateDao] and re-queries the affected slot after every mutation so
/// the UI is always a faithful projection of what's on disk.
///
/// Deliberately simple — `ChangeNotifier` + `setState`, no Riverpod / Bloc.
/// The whole screen is four cards; a one-class state container is the
/// right size.
class ActiveWorkoutController extends ChangeNotifier {
  ActiveWorkoutController({
    required AppDatabase database,
    required this.templateId,
  })  : _workoutDao = WorkoutDao(database.raw),
        _templateDao = TemplateDao(database.raw);

  final String templateId;
  final WorkoutDao _workoutDao;
  final TemplateDao _templateDao;

  bool _loading = true;
  String? _error;
  DbWorkoutTemplate? _template;
  DbWorkout? _workout;
  List<SlotState> _slots = const [];

  bool get loading => _loading;
  String? get error => _error;
  DbWorkoutTemplate? get template => _template;
  DbWorkout? get workout => _workout;
  List<SlotState> get slots => _slots;
  bool get isFinished => _workout?.stopTime != null;

  // ---------------- Lifecycle ----------------

  /// Initial load. Resolves or creates the workout, reads all slots, and
  /// for each slot preloads planned sets if none are logged yet.
  Future<void> initialize() async {
    try {
      _template = await _templateDao.findById(templateId);
      if (_template == null) {
        _error = 'Template $templateId not found';
        _loading = false;
        notifyListeners();
        return;
      }

      _workout = await _workoutDao.findInProgressForTemplate(templateId) ??
          await _workoutDao.startWorkout(templateId: templateId);

      final allVariants = await _templateDao.slotsForTemplate(templateId);
      final slotBuckets =
          <int, List<DbExerciseForWorkoutTemplate>>{};
      for (final variant in allVariants) {
        slotBuckets
            .putIfAbsent(variant.ordering, () => [])
            .add(variant);
      }

      final exerciseIds = allVariants.map((v) => v.exerciseId).toSet().toList();
      final exerciseById = await _templateDao.exercisesByIds(exerciseIds);

      final builtSlots = <SlotState>[];
      final sortedOrderings = slotBuckets.keys.toList()..sort();
      for (final ordering in sortedOrderings) {
        final variants = slotBuckets[ordering]!
          ..sort((a, b) => a.exerciseIndex.compareTo(b.exerciseIndex));

        // Pick the current variant: if any variant in this slot already
        // has exercise_set rows in this workout, that's the user's prior
        // choice — resume it. Otherwise fall back to exercise_index = 0.
        var currentVariantIndex = 0;
        for (var i = 0; i < variants.length; i++) {
          final existing = await _workoutDao.setsForSlot(
            workoutId: _workout!.id,
            exerciseForWorkoutTemplateId: variants[i].id,
          );
          if (existing.isNotEmpty) {
            currentVariantIndex = i;
            break;
          }
        }

        final currentVariant = variants[currentVariantIndex];

        // If the chosen variant has zero sets logged, preload from the
        // template. Pre-existing workouts that already logged sets keep
        // what's there.
        var currentSets = await _workoutDao.setsForSlot(
          workoutId: _workout!.id,
          exerciseForWorkoutTemplateId: currentVariant.id,
        );
        if (currentSets.isEmpty) {
          final planned =
              await _templateDao.plannedSetsForVariant(currentVariant.id);
          currentSets = await _workoutDao.preloadSetsFromTemplate(
            workoutId: _workout!.id,
            exerciseForWorkoutTemplateId: currentVariant.id,
            exerciseId: currentVariant.exerciseId,
            plannedSets: planned,
          );
        }

        final previous = await _workoutDao.previousSessionSets(
          currentWorkoutId: _workout!.id,
          exerciseForWorkoutTemplateId: currentVariant.id,
        );

        builtSlots.add(
          SlotState(
            ordering: ordering,
            variants: variants,
            exerciseById: exerciseById,
            currentVariantIndex: currentVariantIndex,
            sets: currentSets,
            previousSessionSets: previous,
          ),
        );
      }

      _slots = builtSlots;
      _loading = false;
      notifyListeners();
    } catch (e, st) {
      _error = '$e\n$st';
      _loading = false;
      notifyListeners();
    }
  }

  // ---------------- Mutations ----------------

  /// Swaps the variant shown for a slot. The old variant's NOT-completed
  /// rows are wiped (and any completed rows are preserved as history);
  /// the new variant's planned sets are preloaded if it has none yet.
  Future<void> swapVariant({
    required int slotIndex,
    required int newVariantIndex,
  }) async {
    final slot = _slots[slotIndex];
    if (newVariantIndex == slot.currentVariantIndex) return;

    await _workoutDao.deleteIncompleteSetsForSlot(
      workoutId: _workout!.id,
      exerciseForWorkoutTemplateId: slot.currentVariant.id,
    );

    final newVariant = slot.variants[newVariantIndex];

    var sets = await _workoutDao.setsForSlot(
      workoutId: _workout!.id,
      exerciseForWorkoutTemplateId: newVariant.id,
    );
    if (sets.isEmpty) {
      final planned = await _templateDao.plannedSetsForVariant(newVariant.id);
      sets = await _workoutDao.preloadSetsFromTemplate(
        workoutId: _workout!.id,
        exerciseForWorkoutTemplateId: newVariant.id,
        exerciseId: newVariant.exerciseId,
        plannedSets: planned,
      );
    }

    final previous = await _workoutDao.previousSessionSets(
      currentWorkoutId: _workout!.id,
      exerciseForWorkoutTemplateId: newVariant.id,
    );

    _slots = [
      for (var i = 0; i < _slots.length; i++)
        if (i == slotIndex)
          _slots[i].copyWith(
            currentVariantIndex: newVariantIndex,
            sets: sets,
            previousSessionSets: previous,
          )
        else
          _slots[i],
    ];
    notifyListeners();
  }

  /// Updates weight + rep_count on a set, then re-reads the slot so the
  /// on-screen row matches the row on disk.
  Future<void> updateSetValues({
    required int slotIndex,
    required String setId,
    required double? weight,
    required int? repCount,
  }) async {
    await _workoutDao.updateSetValues(
      setId: setId,
      weight: weight,
      repCount: repCount,
    );
    await _refreshSlot(slotIndex);
  }

  /// Updates `set_type` on a set, then re-reads the slot so the cell badge
  /// re-renders against on-disk truth. Working-set numbering recomputes
  /// from the refreshed list — the count increments for every non-warmup
  /// row, so converting `regularSet` ↔ `dropSet`/`failure` does not shift
  /// the numbers of the rows below.
  Future<void> setSetType({
    required int slotIndex,
    required String setId,
    required SetType setType,
  }) async {
    await _workoutDao.updateSetType(setId: setId, setType: setType);
    await _refreshSlot(slotIndex);
  }

  /// Toggles the ✓ on a set. Updates in place.
  Future<void> toggleSetCompleted({
    required int slotIndex,
    required String setId,
    required bool completed,
  }) async {
    await _workoutDao.setCompleted(setId: setId, completed: completed);
    await _refreshSlot(slotIndex);
  }

  /// Inserts a blank regular set at the end of the slot's list.
  Future<void> addSet(int slotIndex) async {
    final slot = _slots[slotIndex];
    await _workoutDao.addSet(
      workoutId: _workout!.id,
      exerciseForWorkoutTemplateId: slot.currentVariant.id,
      exerciseId: slot.currentVariant.exerciseId,
    );
    await _refreshSlot(slotIndex);
  }

  /// Closes the workout — sets `stop_time`. UI can then show a completed
  /// state or navigate away.
  Future<void> finishWorkout() async {
    if (_workout == null || _workout!.stopTime != null) return;
    await _workoutDao.finishWorkout(_workout!.id);
    final nowSec = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    _workout = DbWorkout(
      id: _workout!.id,
      templateId: _workout!.templateId,
      startTime: _workout!.startTime,
      stopTime: nowSec,
    );
    notifyListeners();
  }

  Future<void> _refreshSlot(int slotIndex) async {
    final slot = _slots[slotIndex];
    final sets = await _workoutDao.setsForSlot(
      workoutId: _workout!.id,
      exerciseForWorkoutTemplateId: slot.currentVariant.id,
    );
    _slots = [
      for (var i = 0; i < _slots.length; i++)
        if (i == slotIndex) _slots[i].copyWith(sets: sets) else _slots[i],
    ];
    notifyListeners();
  }
}
