import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

import '../../style/app_style.dart';

/// A bottom-anchored sheet that cross-fades between a collapsed [headerBuilder]
/// and an expanded [pageBuilder]. The drag-handle thumb is owned by the sheet
/// itself and stays visible at every drag offset.
///
/// Two states:
///   - collapsed: only the thumb + header are visible, pinned above
///     [collapsedBottomInset] (reserve space for e.g. a bottom tab bar).
///   - expanded: the sheet covers the full screen (minus top safe area).
///
/// Drag the thumb or tap it to toggle. The sheet is laid out with a [Stack]
/// over [body]; there is no custom [RenderObject] — existing primitives are
/// enough for the interaction model.
class PersistentSheet extends StatefulWidget {
  const PersistentSheet({
    super.key,
    required this.body,
    required this.headerBuilder,
    required this.pageBuilder,
    this.collapsedHeight = 56.0,
    this.collapsedBottomInset = 0.0,
    this.thumbSize = const Size(36.0, 5.0),
  });

  /// Main app content. Rendered full-screen behind the sheet. The sheet does
  /// NOT add any bottom padding to this — the body is responsible for
  /// reserving space for the collapsed sheet via [bottomInsetForBody] if
  /// scrolling content would otherwise be hidden.
  final Widget body;

  /// Builds the collapsed header (the "mini-player" row). Visible only when
  /// the sheet is near its collapsed state; fades out as the sheet expands.
  final WidgetBuilder headerBuilder;

  /// Builds the full-size sheet content. Fades in as the sheet expands.
  final WidgetBuilder pageBuilder;

  /// Height of the collapsed header row (excluding the thumb).
  final double collapsedHeight;

  /// Space at the bottom of the screen the collapsed sheet should float
  /// above (e.g. a bottom tab bar's height). When fully expanded the sheet
  /// ignores this and reaches the bottom edge.
  final double collapsedBottomInset;

  /// Size of the always-visible drag handle. Default is a ~36×5 pill.
  final Size thumbSize;

  /// Total height occupied by the collapsed sheet + its bottom inset. Useful
  /// for padding the body's scrollable content.
  double get bottomInsetForBody =>
      collapsedHeight + _thumbBlockHeight + collapsedBottomInset;

  double get _thumbBlockHeight => thumbSize.height + AppStyle.gapS * 2;

  @override
  State<PersistentSheet> createState() => _PersistentSheetState();
}

class _PersistentSheetState extends State<PersistentSheet>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
      value: 0.0,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDragUpdate(DragUpdateDetails d, double travel) {
    if (travel <= 0) return;
    _controller.value -= d.primaryDelta! / travel;
  }

  void _onDragEnd(DragEndDetails d) {
    final v = d.velocity.pixelsPerSecond.dy;
    if (v < -400) {
      _controller.animateTo(1.0, curve: Curves.easeOut);
    } else if (v > 400) {
      _controller.animateTo(0.0, curve: Curves.easeOut);
    } else {
      _controller.animateTo(
        _controller.value > 0.5 ? 1.0 : 0.0,
        curve: Curves.easeOut,
      );
    }
  }

  void _toggle() {
    _controller.animateTo(
      _controller.value > 0.5 ? 0.0 : 1.0,
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenH = constraints.maxHeight;
        final topSafe = MediaQuery.of(context).padding.top;

        return Stack(
          children: [
            Positioned.fill(child: widget.body),
            AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                final t = _controller.value;
                final collapsedTop = screenH -
                    widget.collapsedHeight -
                    widget._thumbBlockHeight -
                    widget.collapsedBottomInset;
                final expandedTop = topSafe;
                final top = lerpDouble(collapsedTop, expandedTop, t)!;
                final bottom =
                    lerpDouble(widget.collapsedBottomInset, 0.0, t)!;
                final travel = collapsedTop - expandedTop;

                return Positioned(
                  top: top,
                  left: 0,
                  right: 0,
                  bottom: bottom,
                  child: _SheetShell(
                    thumbSize: widget.thumbSize,
                    onDragUpdate: (d) => _onDragUpdate(d, travel),
                    onDragEnd: _onDragEnd,
                    onThumbTap: _toggle,
                    child: _CrossfadeContents(
                      t: t,
                      collapsedHeight: widget.collapsedHeight,
                      header: widget.headerBuilder(context),
                      page: widget.pageBuilder(context),
                      onHeaderTap: t < 0.5 ? _toggle : null,
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}

class _SheetShell extends StatelessWidget {
  const _SheetShell({
    required this.thumbSize,
    required this.onDragUpdate,
    required this.onDragEnd,
    required this.onThumbTap,
    required this.child,
  });

  final Size thumbSize;
  final ValueChanged<DragUpdateDetails> onDragUpdate;
  final ValueChanged<DragEndDetails> onDragEnd;
  final VoidCallback onThumbTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppStyle.cardBackground,
      elevation: 12.0,
      borderRadius: AppStyle.sheetRadius,
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onVerticalDragUpdate: onDragUpdate,
            onVerticalDragEnd: onDragEnd,
            onTap: onThumbTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppStyle.gapS),
              child: Center(
                child: Container(
                  width: thumbSize.width,
                  height: thumbSize.height,
                  decoration: BoxDecoration(
                    color: AppStyle.dividerColor,
                    borderRadius: BorderRadius.circular(thumbSize.height),
                  ),
                ),
              ),
            ),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _CrossfadeContents extends StatelessWidget {
  const _CrossfadeContents({
    required this.t,
    required this.collapsedHeight,
    required this.header,
    required this.page,
    required this.onHeaderTap,
  });

  final double t;
  final double collapsedHeight;
  final Widget header;
  final Widget page;
  final VoidCallback? onHeaderTap;

  @override
  Widget build(BuildContext context) {
    final headerOpacity = (1.0 - t * 2.0).clamp(0.0, 1.0);
    final pageOpacity = (t * 2.0 - 1.0).clamp(0.0, 1.0);

    return Stack(
      children: [
        IgnorePointer(
          ignoring: pageOpacity < 0.5,
          child: Opacity(opacity: pageOpacity, child: page),
        ),
        IgnorePointer(
          ignoring: headerOpacity < 0.5,
          child: Opacity(
            opacity: headerOpacity,
            child: SizedBox(
              height: collapsedHeight,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onHeaderTap,
                child: header,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
