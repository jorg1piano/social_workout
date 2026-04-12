import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../data/db/database.dart';
import '../../data/models/db_exercise_set.dart';
import '../../data/models/set_type.dart';
import '../../style/app_style.dart';
import '../../style/glass_surface.dart';
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
      // Transparent backdrop + no default shape — the sheet body paints its
      // own `GlassSurface` with the heavy-glass blur and top-rounded radius,
      // so the Material layer underneath must get out of the way.
      backgroundColor: Colors.transparent,
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

  /// Opens the bottom sheet that lets the user pick the `set_type` for a
  /// row. Mirrors [_openSwapSheet]: the sheet returns the chosen enum
  /// value (or null if the user dismissed it), and we only write back if
  /// it's actually different from the current value.
  Future<void> _openSetTypeSheet({
    required int slotIndex,
    required String setId,
    required SetType current,
  }) async {
    final selected = await showModalBottomSheet<SetType>(
      context: context,
      // Same rationale as _openSwapSheet — transparent so the glass pane
      // inside the sheet body is what the user actually sees.
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => _SetTypeSheet(currentType: current),
    );
    if (selected != null && selected != current) {
      await _controller.setSetType(
        slotIndex: slotIndex,
        setId: setId,
        setType: selected,
      );
    }
  }

  /// Wraps the screen body in the indigo → near-black gradient wash
  /// that lives behind every glass pane. Without something to refract,
  /// glass just looks like a flat tinted rectangle — this gradient is
  /// the "thing underneath the glass." All three screen states
  /// (loading / error / normal) share the same wash.
  Widget _glassScaffold(Widget body) {
    return Scaffold(
      // Transparent so the gradient Container paints the full surface.
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(gradient: AppStyle.backgroundGradient),
        child: SafeArea(child: body),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_controller.loading) {
      return _glassScaffold(
        const Center(child: CircularProgressIndicator()),
      );
    }
    if (_controller.error != null) {
      return _glassScaffold(
        Padding(
          padding: AppStyle.screenPadding,
          child: Center(
            child: Text(
              _controller.error!,
              style: AppStyle.glassCaptionStyle,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return _glassScaffold(
      Column(
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
                      onTapSetCell: (setId, current) => _openSetTypeSheet(
                        slotIndex: i,
                        setId: setId,
                        current: current,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
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
    // The top bar is a horizontal glass pane pinned under the safe-area.
    // Extra horizontal padding around the GlassSurface so the pane
    // doesn't touch the screen edge — the Liquid Glass reference always
    // has breathing room around floating glass elements.
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppStyle.gapM,
        AppStyle.gapS,
        AppStyle.gapM,
        AppStyle.gapS,
      ),
      child: GlassSurface(
        child: Padding(
          padding: AppStyle.topBarPadding,
          child: Row(
            children: [
              _CircleIconButton(icon: Icons.arrow_back_ios_new, onTap: () {}),
              Expanded(
                child: Center(
                  child: Text(elapsed, style: AppStyle.glassTopBarTimeStyle),
                ),
              ),
              _FinishButton(onTap: onFinish ?? () {}),
            ],
          ),
        ),
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
    // Glass chip: transparent fill (the outer top-bar GlassSurface already
    // owns the blur/tint), just the icon in glass-white on top of it.
    return Material(
      color: Colors.transparent,
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
            color: AppStyle.glassTextPrimary,
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
                  style: AppStyle.glassWorkoutTitleStyle,
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
          color: AppStyle.glassTextSecondary,
        ),
        const SizedBox(width: AppStyle.gapS),
        Text(label, style: AppStyle.glassHeaderMetaStyle),
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
typedef TapSetCellCallback = void Function(String setId, SetType current);

class _SlotCard extends StatelessWidget {
  const _SlotCard({
    required this.slot,
    required this.slotIndex,
    required this.onTapSwap,
    required this.onTapAddSet,
    required this.onToggleCompleted,
    required this.onEditValues,
    required this.onTapSetCell,
  });

  final SlotState slot;
  final int slotIndex;
  final VoidCallback? onTapSwap;
  final VoidCallback onTapAddSet;
  final ToggleCompletedCallback onToggleCompleted;
  final EditValuesCallback onEditValues;
  final TapSetCellCallback onTapSetCell;

  @override
  Widget build(BuildContext context) {
    // Each exercise card is its own glass pane floating over the gradient.
    // GlassSurface owns the radius / blur / tint / rim; the inner Padding
    // supplies the card content insets the old Container used.
    return GlassSurface(
      child: Padding(
        padding: AppStyle.cardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    slot.currentExercise.name,
                    style: AppStyle.glassExerciseNameStyle,
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
                onTapSetCell: () => onTapSetCell(row.set.id, row.set.setType),
              ),
            const SizedBox(height: AppStyle.gapS),
            _AddSetButton(onTap: onTapAddSet),
          ],
        ),
      ),
    );
  }

  /// Walks the slot's sets and tags each one with its working-set number
  /// (1, 2, 3 ...). The count increments for every **non-warmup** row,
  /// per the team-lead spec on this screen. Drop-set and failure rows
  /// still render as letter badges (D / F) — the underlying number is
  /// computed but not displayed for those types. The visible effect is
  /// that converting a row from `regularSet` → `dropSet` keeps the
  /// numbering of the rows below it intact (the slot still owns N
  /// non-warmup positions; the dropSet just paints a badge over its
  /// number).
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
              style: AppStyle.glassSetTableHeaderStyle,
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(width: AppStyle.setRowHGap),
          Expanded(
            child: Text(
              'Previous',
              style: AppStyle.glassSetTableHeaderStyle,
            ),
          ),
          SizedBox(width: AppStyle.setRowHGap),
          SizedBox(
            width: AppStyle.inputPillWidth,
            child: Text(
              'kg',
              style: AppStyle.glassSetTableHeaderStyle,
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(width: AppStyle.setRowHGap),
          SizedBox(
            width: AppStyle.inputPillWidth,
            child: Text(
              'Reps',
              style: AppStyle.glassSetTableHeaderStyle,
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(width: AppStyle.setRowHGap),
          SizedBox(
            width: AppStyle.checkCircleSize,
            child: Text(
              '✓',
              style: AppStyle.glassSetTableHeaderStyle,
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
    required this.onTapSetCell,
  });

  final DbExerciseSet set;
  final int? workingSetNumber;
  final DbExerciseSet? previous;
  final ValueChanged<bool> onToggleCompleted;
  final void Function(double? weight, int? repCount) onEditValues;
  final VoidCallback onTapSetCell;

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
    // On glass, a completed row glows with a slightly stronger green wash
    // than the flat theme — the gradient behind the pane eats contrast, so
    // the tint needs more alpha to read as "completed."
    final rowBackground = set.isCompleted
        ? AppStyle.glassCompletedRowTint
        : Colors.transparent;

    return Container(
      color: rowBackground,
      padding: AppStyle.setRowPadding,
      child: Row(
        children: [
          SizedBox(
            width: AppStyle.checkCircleSize,
            height: AppStyle.checkCircleSize,
            child: Material(
              color: Colors.transparent,
              borderRadius: AppStyle.circleRadius,
              child: InkWell(
                borderRadius: AppStyle.circleRadius,
                onTap: () {
                  // Flush in-flight kg/reps edits before opening the
                  // sheet — same pattern as the ✓ tap. The sheet pops
                  // the modal route, which doesn't always trigger blur
                  // first on every platform.
                  _commit();
                  widget.onTapSetCell();
                },
                child: Center(child: _setNumberCell()),
              ),
            ),
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

  /// Renders the Set column cell. Four cases, one per `SetType`:
  ///   * `warmup`     → orange `W`
  ///   * `regularSet` → working-set number (`1`, `2`, ...)
  ///   * `dropSet`    → purple `D`
  ///   * `failure`    → red `F`
  /// The em dash fallback only fires for an unexpected state where a
  /// `regularSet` row was somehow not numbered — keeps the column from
  /// going blank if the indexer ever drifts.
  Widget _setNumberCell() {
    switch (widget.set.setType) {
      case SetType.warmup:
        return _glowBadge(
          text: 'W',
          style: AppStyle.warmupBadgeStyle,
          glow: AppStyle.warmupGlowColor,
        );
      case SetType.dropSet:
        return _glowBadge(
          text: 'D',
          style: AppStyle.dropSetBadgeStyle,
          glow: AppStyle.dropSetGlowColor,
        );
      case SetType.failure:
        return _glowBadge(
          text: 'F',
          style: AppStyle.failureBadgeStyle,
          glow: AppStyle.failureGlowColor,
        );
      case SetType.regularSet:
        return Text(
          widget.workingSetNumber?.toString() ?? '—',
          style: AppStyle.glassSetNumberStyle,
        );
    }
  }

  /// Badge wrapper used for W/D/F on the glass surface. Without the glow
  /// the letters disappear against the desaturated backdrop; a soft halo
  /// in the badge's own color puts it back on top of the blur. The halo
  /// colors are pre-blended in [AppStyle] so this stays const-friendly.
  Widget _glowBadge({
    required String text,
    required TextStyle style,
    required Color glow,
  }) {
    return DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: AppStyle.glassBadgeGlow(glow),
      ),
      child: Text(text, style: style),
    );
  }

  Widget _previousCell(DbExerciseSet? previous) {
    if (previous == null || previous.weight == null || previous.repCount == null) {
      return const Text('—', style: AppStyle.glassPreviousColumnStyle);
    }
    final suffix = previous.setType == SetType.warmup ? ' (W)' : '';
    // Use the sign-aware AppStyle formatter so assistance (negative kg)
    // and bodyweight (`bw`) render correctly in the Previous column. Push
    // Day doesn't hit either branch, but the formatter is centralized so
    // future screens (assisted chin-up, push-up) reuse it.
    final weightText = AppStyle.formatWeightDisplay(previous.weight);
    return Text(
      '$weightText × ${previous.repCount}$suffix',
      style: AppStyle.glassPreviousColumnStyle,
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
          color: AppStyle.glassInputPillBackground,
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
          style: AppStyle.glassInputPillStyle,
          // Cursor + selection tuned for the dark glass pill; default
          // material cursor goes black and disappears on the dark fill.
          cursorColor: AppStyle.glassTextPrimary,
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
        // Completed = luminous translucent green (reads as "lit from
        // within" on the glass surface). Idle = dark translucent pill
        // matching the kg / reps cells so the row stays visually balanced.
        color: completed
            ? AppStyle.glassCompletedFill
            : AppStyle.glassInputPillBackground,
        borderRadius: AppStyle.circleRadius,
        child: InkWell(
          borderRadius: AppStyle.circleRadius,
          onTap: onTap,
          child: Icon(
            Icons.check,
            size: AppStyle.checkIconSize,
            color: completed
                ? AppStyle.glassTextPrimary
                : AppStyle.glassTextSecondary,
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
    // No background on glass — the action reads as a plain text affordance
    // in the card accent blue, like the exercise name at the top. The glass
    // card already provides the pane; a second filled pill would be noise.
    return Material(
      color: Colors.transparent,
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
            child: Text('+ Add Set', style: AppStyle.glassAddSetButtonStyle),
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
    // Glass-blue chip — brighter tint + brighter icon than the flat
    // variant so the chip stays legible on the desaturated card.
    return Material(
      color: AppStyle.glassAccentBlueTint,
      borderRadius: AppStyle.pillRadius,
      child: InkWell(
        borderRadius: AppStyle.pillRadius,
        onTap: onTap,
        child: const Padding(
          padding: AppStyle.pillPadding,
          child: Icon(
            Icons.swap_horiz,
            size: AppStyle.smallIconSize,
            color: AppStyle.glassAccentBlue,
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
        color: AppStyle.glassAccentBlueTint,
        borderRadius: AppStyle.pillRadius,
      ),
      padding: AppStyle.pillPadding,
      child: const Icon(
        Icons.more_horiz,
        size: AppStyle.smallIconSize,
        color: AppStyle.glassAccentBlue,
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
    // Heavy glass pane: bigger blur sigma, stronger tint, only top
    // corners rounded. Anchored to the bottom by `showModalBottomSheet`
    // itself — this widget just owns the pane shape + contents.
    return GlassSurface(
      borderRadius: AppStyle.glassSheetRadius,
      blurSigma: AppStyle.glassBlurSigmaHeavy,
      tint: AppStyle.glassTintHeavy,
      child: SafeArea(
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
                child: Text('Swap exercise', style: AppStyle.glassSheetTitleStyle),
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
    // On the glass sheet, the "current" row gets a translucent blue wash
    // instead of the flat card fill; non-current rows are transparent so
    // the glass backdrop shows through.
    return Material(
      color: isCurrent ? AppStyle.glassAccentBlueTint : Colors.transparent,
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
                child: Text(name, style: AppStyle.glassSheetVariantNameStyle),
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

// ---------------------------------------------------------------------------
// Set type bottom sheet
// ---------------------------------------------------------------------------

/// Bottom sheet that lists every `SetType` and pops with the user's pick.
/// Mirrors [_SwapSheet] in shape and styling so the two sheets feel like
/// the same family.
class _SetTypeSheet extends StatelessWidget {
  const _SetTypeSheet({required this.currentType});

  final SetType currentType;

  // Display order: the order users actually reach for. Warmup at the top
  // because it's used first in a session, then the default working set,
  // then the two intensity techniques.
  static const List<SetType> _displayOrder = [
    SetType.warmup,
    SetType.regularSet,
    SetType.dropSet,
    SetType.failure,
  ];

  static String _label(SetType type) {
    switch (type) {
      case SetType.warmup:
        return 'Warm-up';
      case SetType.regularSet:
        // Per spec: pickers should not show position. The cell number
        // is dynamic (1, 2, ...) but the picker label is always "Regular".
        return 'Regular';
      case SetType.dropSet:
        return 'Drop set';
      case SetType.failure:
        return 'Failure';
    }
  }

  static String _badgeText(SetType type) {
    switch (type) {
      case SetType.warmup:
        return 'W';
      case SetType.regularSet:
        return '1';
      case SetType.dropSet:
        return 'D';
      case SetType.failure:
        return 'F';
    }
  }

  static TextStyle _badgeStyle(SetType type) {
    switch (type) {
      case SetType.warmup:
        return AppStyle.warmupBadgeStyle;
      case SetType.regularSet:
        // Regular uses the glass number style so the "1" reads white on
        // the sheet's glass backdrop (flat `setNumberStyle` is near-black
        // and disappears).
        return AppStyle.glassSetNumberStyle;
      case SetType.dropSet:
        return AppStyle.dropSetBadgeStyle;
      case SetType.failure:
        return AppStyle.failureBadgeStyle;
    }
  }

  /// Pre-blended halo color for each badge on the picker rows. Keeps the
  /// W / D / F legible on the sheet's heavy-glass backdrop. Regular set
  /// rows don't get a halo — the "1" is big white text and doesn't need
  /// a color fill behind it.
  static Color? _badgeGlow(SetType type) {
    switch (type) {
      case SetType.warmup:
        return AppStyle.warmupGlowColor;
      case SetType.regularSet:
        return null;
      case SetType.dropSet:
        return AppStyle.dropSetGlowColor;
      case SetType.failure:
        return AppStyle.failureGlowColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GlassSurface(
      borderRadius: AppStyle.glassSheetRadius,
      blurSigma: AppStyle.glassBlurSigmaHeavy,
      tint: AppStyle.glassTintHeavy,
      child: SafeArea(
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
                child: Text('Set type', style: AppStyle.glassSheetTitleStyle),
              ),
              for (final type in _displayOrder)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppStyle.gapS),
                  child: _SetTypeSheetRow(
                    badgeText: _badgeText(type),
                    badgeStyle: _badgeStyle(type),
                    badgeGlow: _badgeGlow(type),
                    label: _label(type),
                    isCurrent: type == currentType,
                    onTap: () => Navigator.of(context).pop(type),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SetTypeSheetRow extends StatelessWidget {
  const _SetTypeSheetRow({
    required this.badgeText,
    required this.badgeStyle,
    required this.badgeGlow,
    required this.label,
    required this.isCurrent,
    required this.onTap,
  });

  final String badgeText;
  final TextStyle badgeStyle;
  final Color? badgeGlow;
  final String label;
  final bool isCurrent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // Current row gets the translucent blue wash; other rows are
    // transparent so the glass sheet shows through.
    return Material(
      color: isCurrent ? AppStyle.glassAccentBlueTint : Colors.transparent,
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
              SizedBox(
                width: AppStyle.checkCircleSize,
                child: Center(child: _badge()),
              ),
              const SizedBox(width: AppStyle.gapM),
              Expanded(
                child: Text(label, style: AppStyle.glassSheetVariantNameStyle),
              ),
              if (isCurrent)
                const Icon(
                  Icons.check,
                  size: AppStyle.smallIconSize,
                  color: AppStyle.glassAccentBlue,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _badge() {
    final text = Text(badgeText, style: badgeStyle);
    final glow = badgeGlow;
    if (glow == null) return text;
    return DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: AppStyle.glassBadgeGlow(glow),
      ),
      child: text,
    );
  }
}
