import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../data/db/database.dart';
import '../../data/models/db_exercise_set.dart';
import '../../data/models/set_type.dart';
import '../../style/app_style.dart';
import 'active_workout_controller.dart';

/// Home route: the Hevy-style active-workout tracking screen. All visual
/// state is backed by SQLite via [ActiveWorkoutController] — editing a
/// value, toggling a ✓, adding a set, or swapping a variant is a real
/// mutation against `exercise_set` and is immediately readable on relaunch.
class ActiveWorkoutScreen extends StatefulWidget {
  const ActiveWorkoutScreen({
    super.key,
    required this.database,
    required this.templateId,
  });

  final AppDatabase database;
  final String templateId;

  @override
  State<ActiveWorkoutScreen> createState() => _ActiveWorkoutScreenState();
}

class _ActiveWorkoutScreenState extends State<ActiveWorkoutScreen> {
  late final ActiveWorkoutController _controller;

  // Elapsed and date are intentionally static placeholders — the acceptance
  // criteria explicitly exclude a real timer.
  static const String _elapsedPlaceholder = '0:00';
  static const String _datePlaceholder = '11 Apr 2026';

  @override
  void initState() {
    super.initState();
    _controller = ActiveWorkoutController(
      database: widget.database,
      templateId: widget.templateId,
    );
    _controller.addListener(_onControllerChanged);
    _controller.initialize();
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _openSwapSheet(int slotIndex) async {
    final slot = _controller.slots[slotIndex];
    final selected = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: AppStyle.cardBackground,
      shape: const RoundedRectangleBorder(borderRadius: AppStyle.sheetRadius),
      builder: (sheetContext) {
        return _SwapSheet(
          variantNames: [
            for (final v in slot.variants) slot.exerciseById[v.exerciseId]!.name,
          ],
          currentIndex: slot.currentVariantIndex,
        );
      },
    );
    if (selected != null && selected != slot.currentVariantIndex) {
      await _controller.swapVariant(
        slotIndex: slotIndex,
        newVariantIndex: selected,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_controller.loading) {
      return const Scaffold(
        backgroundColor: AppStyle.scaffoldBackground,
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (_controller.error != null) {
      return Scaffold(
        backgroundColor: AppStyle.scaffoldBackground,
        body: Padding(
          padding: AppStyle.screenPadding,
          child: Center(
            child: Text(
              _controller.error!,
              style: AppStyle.captionStyle,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppStyle.scaffoldBackground,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _TopBar(
              elapsed: _elapsedPlaceholder,
              onFinish: _controller.isFinished
                  ? null
                  : () => _controller.finishWorkout(),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(bottom: AppStyle.gapXL),
                children: [
                  _WorkoutHeader(
                    templateName:
                        _controller.template?.name.toLowerCase() ?? '',
                    date: _datePlaceholder,
                    elapsed: _elapsedPlaceholder,
                  ),
                  const SizedBox(height: AppStyle.gapL),
                  for (var i = 0; i < _controller.slots.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(
                        left: AppStyle.gapL,
                        right: AppStyle.gapL,
                        bottom: AppStyle.gapL,
                      ),
                      child: _SlotCard(
                        slot: _controller.slots[i],
                        slotIndex: i,
                        onTapSwap: _controller.slots[i].hasAlternatives
                            ? () => _openSwapSheet(i)
                            : null,
                        onTapAddSet: () => _controller.addSet(i),
                        onToggleCompleted: (setId, completed) =>
                            _controller.toggleSetCompleted(
                          slotIndex: i,
                          setId: setId,
                          completed: completed,
                        ),
                        onEditValues: (setId, weight, repCount) =>
                            _controller.updateSetValues(
                          slotIndex: i,
                          setId: setId,
                          weight: weight,
                          repCount: repCount,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Top bar
// ---------------------------------------------------------------------------

class _TopBar extends StatelessWidget {
  const _TopBar({required this.elapsed, required this.onFinish});

  final String elapsed;
  final VoidCallback? onFinish;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppStyle.topBarPadding,
      child: Row(
        children: [
          _CircleIconButton(icon: Icons.arrow_back_ios_new, onTap: () {}),
          Expanded(
            child: Center(
              child: Text(elapsed, style: AppStyle.topBarTimeStyle),
            ),
          ),
          _FinishButton(onTap: onFinish ?? () {}),
        ],
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppStyle.topBarBackground,
      borderRadius: AppStyle.circleRadius,
      child: InkWell(
        borderRadius: AppStyle.circleRadius,
        onTap: onTap,
        child: SizedBox(
          width: 36.0,
          height: 36.0,
          child: Icon(
            icon,
            size: AppStyle.topBarIconSize,
            color: AppStyle.textPrimary,
          ),
        ),
      ),
    );
  }
}

class _FinishButton extends StatelessWidget {
  const _FinishButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppStyle.finishGreen,
      borderRadius: AppStyle.pillRadius,
      child: InkWell(
        borderRadius: AppStyle.pillRadius,
        onTap: onTap,
        child: const Padding(
          padding: AppStyle.finishButtonPadding,
          child: Text('Finish', style: AppStyle.finishButtonStyle),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Workout header
// ---------------------------------------------------------------------------

class _WorkoutHeader extends StatelessWidget {
  const _WorkoutHeader({
    required this.templateName,
    required this.date,
    required this.elapsed,
  });

  final String templateName;
  final String date;
  final String elapsed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppStyle.gapL,
        AppStyle.gapM,
        AppStyle.gapL,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  templateName,
                  style: AppStyle.workoutTitleStyle,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: AppStyle.gapS),
              const _MoreOptionsPill(),
            ],
          ),
          const SizedBox(height: AppStyle.gapS),
          _MetaRow(icon: Icons.calendar_today_outlined, label: date),
          const SizedBox(height: AppStyle.gapXS),
          _MetaRow(icon: Icons.schedule_outlined, label: elapsed),
        ],
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: AppStyle.metaIconSize,
          color: AppStyle.textSecondary,
        ),
        const SizedBox(width: AppStyle.gapS),
        Text(label, style: AppStyle.headerMetaStyle),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Slot card with per-set table
// ---------------------------------------------------------------------------

typedef ToggleCompletedCallback = void Function(String setId, bool completed);
typedef EditValuesCallback = void Function(
  String setId,
  double? weight,
  int? repCount,
);

class _SlotCard extends StatelessWidget {
  const _SlotCard({
    required this.slot,
    required this.slotIndex,
    required this.onTapSwap,
    required this.onTapAddSet,
    required this.onToggleCompleted,
    required this.onEditValues,
  });

  final SlotState slot;
  final int slotIndex;
  final VoidCallback? onTapSwap;
  final VoidCallback onTapAddSet;
  final ToggleCompletedCallback onToggleCompleted;
  final EditValuesCallback onEditValues;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppStyle.cardBackground,
        borderRadius: AppStyle.cardRadius,
        border: Border.all(color: AppStyle.cardBorder),
      ),
      padding: AppStyle.cardPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  slot.currentExercise.name,
                  style: AppStyle.exerciseNameStyle,
                ),
              ),
              if (onTapSwap != null) ...[
                _SwapPill(onTap: onTapSwap!),
                const SizedBox(width: AppStyle.gapS),
              ],
              const _MoreOptionsPill(),
            ],
          ),
          const SizedBox(height: AppStyle.gapM),
          const _SetTableHeader(),
          for (final row in _indexedRows(slot.sets))
            _SetRow(
              key: ValueKey(row.set.id),
              set: row.set,
              workingSetNumber: row.workingSetNumber,
              previous: slot.previousForOrdering(row.set.ordering),
              onToggleCompleted: (completed) =>
                  onToggleCompleted(row.set.id, completed),
              onEditValues: (weight, repCount) =>
                  onEditValues(row.set.id, weight, repCount),
            ),
          const SizedBox(height: AppStyle.gapS),
          _AddSetButton(onTap: onTapAddSet),
        ],
      ),
    );
  }

  /// Walks the slot's sets and tags each one with its working-set number
  /// (1, 2, 3 ... skipping warmup rows). Warmup rows get the `W` badge
  /// and no number.
  Iterable<_IndexedSet> _indexedRows(List<DbExerciseSet> sets) sync* {
    var workingCount = 0;
    for (final set in sets) {
      int? workingNumber;
      if (set.setType != SetType.warmup) {
        workingCount += 1;
        workingNumber = workingCount;
      }
      yield _IndexedSet(set: set, workingSetNumber: workingNumber);
    }
  }
}

class _IndexedSet {
  final DbExerciseSet set;
  final int? workingSetNumber;
  const _IndexedSet({required this.set, required this.workingSetNumber});
}

class _SetTableHeader extends StatelessWidget {
  const _SetTableHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppStyle.setRowPadding,
      child: Row(
        children: const [
          SizedBox(
            width: AppStyle.checkCircleSize,
            child: Text(
              'Set',
              style: AppStyle.setTableHeaderStyle,
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(width: AppStyle.setRowHGap),
          Expanded(
            child: Text(
              'Previous',
              style: AppStyle.setTableHeaderStyle,
            ),
          ),
          SizedBox(width: AppStyle.setRowHGap),
          SizedBox(
            width: AppStyle.inputPillWidth,
            child: Text(
              'kg',
              style: AppStyle.setTableHeaderStyle,
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(width: AppStyle.setRowHGap),
          SizedBox(
            width: AppStyle.inputPillWidth,
            child: Text(
              'Reps',
              style: AppStyle.setTableHeaderStyle,
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(width: AppStyle.setRowHGap),
          SizedBox(
            width: AppStyle.checkCircleSize,
            child: Text(
              '✓',
              style: AppStyle.setTableHeaderStyle,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Set row — stateful for text field persistence across rebuilds.
// ---------------------------------------------------------------------------

class _SetRow extends StatefulWidget {
  const _SetRow({
    super.key,
    required this.set,
    required this.workingSetNumber,
    required this.previous,
    required this.onToggleCompleted,
    required this.onEditValues,
  });

  final DbExerciseSet set;
  final int? workingSetNumber;
  final DbExerciseSet? previous;
  final ValueChanged<bool> onToggleCompleted;
  final void Function(double? weight, int? repCount) onEditValues;

  @override
  State<_SetRow> createState() => _SetRowState();
}

class _SetRowState extends State<_SetRow> {
  late final TextEditingController _weightController;
  late final TextEditingController _repsController;
  late final FocusNode _weightFocus;
  late final FocusNode _repsFocus;

  @override
  void initState() {
    super.initState();
    _weightController = TextEditingController(
      text: _formatWeight(widget.set.weight),
    );
    _repsController = TextEditingController(
      text: widget.set.repCount?.toString() ?? '',
    );
    _weightFocus = FocusNode();
    _repsFocus = FocusNode();
    _weightFocus.addListener(_onWeightFocusChange);
    _repsFocus.addListener(_onRepsFocusChange);
  }

  @override
  void didUpdateWidget(covariant _SetRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If the backing row changed from underneath (e.g., after a re-query
    // following a different set's mutation) AND this field isn't focused,
    // reflect the new value. Focused fields are left alone so the user's
    // in-flight typing isn't clobbered.
    if (!_weightFocus.hasFocus) {
      final expected = _formatWeight(widget.set.weight);
      if (_weightController.text != expected) {
        _weightController.text = expected;
      }
    }
    if (!_repsFocus.hasFocus) {
      final expected = widget.set.repCount?.toString() ?? '';
      if (_repsController.text != expected) {
        _repsController.text = expected;
      }
    }
  }

  @override
  void dispose() {
    _weightFocus.removeListener(_onWeightFocusChange);
    _repsFocus.removeListener(_onRepsFocusChange);
    _weightController.dispose();
    _repsController.dispose();
    _weightFocus.dispose();
    _repsFocus.dispose();
    super.dispose();
  }

  void _onWeightFocusChange() {
    if (!_weightFocus.hasFocus) _commit();
  }

  void _onRepsFocusChange() {
    if (!_repsFocus.hasFocus) _commit();
  }

  void _commit() {
    final weight = _parseWeight(_weightController.text);
    final reps = _parseInt(_repsController.text);
    if (weight == widget.set.weight && reps == widget.set.repCount) return;
    widget.onEditValues(weight, reps);
  }

  /// Display formatter: integer weights drop the decimal; fractional
  /// weights use EU comma (`12,5 kg`). Reflects the screenshot convention.
  static String _formatWeight(double? weight) {
    if (weight == null) return '';
    if (weight == weight.truncateToDouble()) {
      return weight.toInt().toString();
    }
    return weight.toString().replaceAll('.', ',');
  }

  /// Inverse of [_formatWeight]: accepts `12,5` or `12.5` and returns a
  /// `double`. Empty → null. Unparseable → null (the user will see their
  /// text remain and can retry).
  static double? _parseWeight(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return null;
    return double.tryParse(trimmed.replaceAll(',', '.'));
  }

  static int? _parseInt(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return null;
    return int.tryParse(trimmed);
  }

  @override
  Widget build(BuildContext context) {
    final set = widget.set;
    final previous = widget.previous;
    final rowBackground = set.isCompleted
        ? AppStyle.completedRowTint
        : Colors.transparent;

    return Container(
      color: rowBackground,
      padding: AppStyle.setRowPadding,
      child: Row(
        children: [
          SizedBox(
            width: AppStyle.checkCircleSize,
            child: Center(child: _setNumberCell()),
          ),
          const SizedBox(width: AppStyle.setRowHGap),
          Expanded(child: _previousCell(previous)),
          const SizedBox(width: AppStyle.setRowHGap),
          _InputPill(
            controller: _weightController,
            focusNode: _weightFocus,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            // Digits plus comma and dot. Leading minus accepted so assisted
            // exercises (out of scope here) can still be typed.
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.,-]')),
            ],
            onSubmitted: (_) => _commit(),
          ),
          const SizedBox(width: AppStyle.setRowHGap),
          _InputPill(
            controller: _repsController,
            focusNode: _repsFocus,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onSubmitted: (_) => _commit(),
          ),
          const SizedBox(width: AppStyle.setRowHGap),
          _CheckCircle(
            completed: set.isCompleted,
            onTap: () {
              _commit(); // flush in-flight edits before toggling
              widget.onToggleCompleted(!set.isCompleted);
            },
          ),
        ],
      ),
    );
  }

  Widget _setNumberCell() {
    if (widget.set.setType == SetType.warmup) {
      return const Text('W', style: AppStyle.warmupBadgeStyle);
    }
    return Text(
      widget.workingSetNumber?.toString() ?? '—',
      style: AppStyle.setNumberStyle,
    );
  }

  Widget _previousCell(DbExerciseSet? previous) {
    if (previous == null || previous.weight == null || previous.repCount == null) {
      return const Text('—', style: AppStyle.previousColumnStyle);
    }
    final suffix = previous.setType == SetType.warmup ? ' (W)' : '';
    // Use the sign-aware AppStyle formatter so assistance (negative kg)
    // and bodyweight (`bw`) render correctly in the Previous column. Push
    // Day doesn't hit either branch, but the formatter is centralized so
    // future screens (assisted chin-up, push-up) reuse it.
    final weightText = AppStyle.formatWeightDisplay(previous.weight);
    return Text(
      '$weightText × ${previous.repCount}$suffix',
      style: AppStyle.previousColumnStyle,
    );
  }
}

class _InputPill extends StatelessWidget {
  const _InputPill({
    required this.controller,
    required this.focusNode,
    required this.keyboardType,
    required this.inputFormatters,
    required this.onSubmitted,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final TextInputType keyboardType;
  final List<TextInputFormatter> inputFormatters;
  final ValueChanged<String> onSubmitted;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: AppStyle.inputPillWidth,
      height: AppStyle.inputPillHeight,
      child: Container(
        decoration: const BoxDecoration(
          color: AppStyle.inputPillBackground,
          borderRadius: AppStyle.pillRadius,
        ),
        alignment: Alignment.center,
        child: TextField(
          controller: controller,
          focusNode: focusNode,
          textAlign: TextAlign.center,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          onSubmitted: onSubmitted,
          style: AppStyle.inputPillStyle,
          decoration: const InputDecoration(
            border: InputBorder.none,
            isCollapsed: true,
            contentPadding: EdgeInsets.symmetric(vertical: 6.0),
          ),
        ),
      ),
    );
  }
}

class _CheckCircle extends StatelessWidget {
  const _CheckCircle({required this.completed, required this.onTap});

  final bool completed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: AppStyle.checkCircleSize,
      height: AppStyle.checkCircleSize,
      child: Material(
        color: completed ? AppStyle.finishGreen : AppStyle.inputPillBackground,
        borderRadius: AppStyle.circleRadius,
        child: InkWell(
          borderRadius: AppStyle.circleRadius,
          onTap: onTap,
          child: Icon(
            Icons.check,
            size: AppStyle.checkIconSize,
            color: completed ? Colors.white : AppStyle.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _AddSetButton extends StatelessWidget {
  const _AddSetButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppStyle.inputPillBackground,
      borderRadius: AppStyle.pillRadius,
      child: InkWell(
        borderRadius: AppStyle.pillRadius,
        onTap: onTap,
        child: const Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppStyle.gapM,
            vertical: AppStyle.gapS,
          ),
          child: Center(
            child: Text('+ Add Set', style: AppStyle.addSetButtonStyle),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Swap pill + bottom sheet
// ---------------------------------------------------------------------------

class _SwapPill extends StatelessWidget {
  const _SwapPill({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppStyle.accentBlueTint,
      borderRadius: AppStyle.pillRadius,
      child: InkWell(
        borderRadius: AppStyle.pillRadius,
        onTap: onTap,
        child: const Padding(
          padding: AppStyle.pillPadding,
          child: Icon(
            Icons.swap_horiz,
            size: AppStyle.smallIconSize,
            color: AppStyle.primaryBlue,
          ),
        ),
      ),
    );
  }
}

class _MoreOptionsPill extends StatelessWidget {
  const _MoreOptionsPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppStyle.accentBlueTint,
        borderRadius: AppStyle.pillRadius,
      ),
      padding: AppStyle.pillPadding,
      child: const Icon(
        Icons.more_horiz,
        size: AppStyle.smallIconSize,
        color: AppStyle.primaryBlue,
      ),
    );
  }
}

class _SwapSheet extends StatelessWidget {
  const _SwapSheet({required this.variantNames, required this.currentIndex});

  final List<String> variantNames;
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppStyle.gapL,
          AppStyle.gapL,
          AppStyle.gapL,
          AppStyle.gapL,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: AppStyle.gapL),
              child: Text('Swap exercise', style: AppStyle.sheetTitleStyle),
            ),
            for (int i = 0; i < variantNames.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: AppStyle.gapS),
                child: _SwapSheetRow(
                  name: variantNames[i],
                  isCurrent: i == currentIndex,
                  onTap: () => Navigator.of(context).pop(i),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SwapSheetRow extends StatelessWidget {
  const _SwapSheetRow({
    required this.name,
    required this.isCurrent,
    required this.onTap,
  });

  final String name;
  final bool isCurrent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isCurrent ? AppStyle.accentBlueTint : AppStyle.cardBackground,
      borderRadius: AppStyle.pillRadius,
      child: InkWell(
        borderRadius: AppStyle.pillRadius,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppStyle.gapL,
            vertical: AppStyle.gapM,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(name, style: AppStyle.sheetVariantNameStyle),
              ),
              if (isCurrent)
                const Text('CURRENT', style: AppStyle.sheetCurrentLabelStyle),
            ],
          ),
        ),
      ),
    );
  }
}
