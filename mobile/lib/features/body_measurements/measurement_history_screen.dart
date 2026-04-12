import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../data/dao/body_measurement_dao.dart';
import '../../data/db/database.dart';
import '../../data/models/db_body_measurement.dart';
import '../../style/app_style.dart';
import 'measurement_types.dart';

/// History screen for a single measurement type. A collapsing chart header
/// shows the full trend at the top; as the user scrolls, it shrinks into a
/// compact sparkline row (title + sparkline + latest value) pinned in the
/// app bar — matching the overview list row exactly.
class MeasurementHistoryScreen extends StatefulWidget {
  const MeasurementHistoryScreen({
    super.key,
    required this.database,
    required this.type,
  });

  final AppDatabase database;
  final MeasurementType type;

  @override
  State<MeasurementHistoryScreen> createState() =>
      _MeasurementHistoryScreenState();
}

class _MeasurementHistoryScreenState extends State<MeasurementHistoryScreen> {
  late final BodyMeasurementDao _dao;
  List<DbBodyMeasurement> _measurements = []; // newest first
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _dao = BodyMeasurementDao(widget.database.raw);
    _load();
  }

  Future<void> _load() async {
    final list = await _dao.getMeasurementsByType(widget.type.wireValue);
    if (mounted) {
      setState(() {
        _measurements = list;
        _loading = false;
      });
    }
  }

  Future<void> _delete(DbBodyMeasurement m) async {
    await _dao.deleteMeasurement(m.id);
    _load();
  }

  /// Values in chronological order (oldest first) for the chart.
  List<double> get _chartValues =>
      _measurements.reversed.map((m) => m.value).toList();

  String get _latestLabel {
    if (_measurements.isEmpty) return '--';
    final m = _measurements.first;
    return '${_fmtVal(m.value)} ${m.unit}';
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: AppStyle.scaffoldBackground,
        appBar: AppBar(
          title: Text(widget.type.label),
          backgroundColor: AppStyle.topBarBackground,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final hasChart = _chartValues.length >= 2;
    final topPadding = MediaQuery.of(context).padding.top;

    // Expanded: top padding + toolbar + chart area
    // Collapsed: top padding + single compact row (56 dp)
    const chartAreaHeight = 160.0;
    const collapsedBarHeight = 56.0;
    final expandedHeight = hasChart
        ? topPadding + kToolbarHeight + chartAreaHeight
        : topPadding + collapsedBarHeight;

    return Scaffold(
      backgroundColor: AppStyle.scaffoldBackground,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: AppStyle.topBarBackground,
            expandedHeight: hasChart ? expandedHeight - topPadding : null,
            collapsedHeight: collapsedBarHeight,
            // Hide the default title — we draw our own in flexibleSpace
            title: hasChart ? null : Text(widget.type.label),
            flexibleSpace: hasChart
                ? LayoutBuilder(
                    builder: (context, constraints) {
                      final maxH = expandedHeight;
                      final minH = topPadding + collapsedBarHeight;
                      final t = ((maxH - constraints.maxHeight) /
                              (maxH - minH))
                          .clamp(0.0, 1.0);

                      return _CollapsingHeader(
                        label: widget.type.label,
                        latestValue: _latestLabel,
                        values: _chartValues,
                        collapseT: t,
                        topPadding: topPadding,
                        chartAreaHeight: chartAreaHeight,
                      );
                    },
                  )
                : null,
          ),

          if (_measurements.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Text(
                  'No ${widget.type.label.toLowerCase()} measurements yet',
                  style: AppStyle.captionStyle,
                ),
              ),
            ),

          if (_measurements.isNotEmpty)
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final m = _measurements[index];
                  return Column(
                    children: [
                      _MeasurementRow(
                        measurement: m,
                        onDelete: () => _delete(m),
                      ),
                      if (index < _measurements.length - 1)
                        const Divider(
                          color: AppStyle.dividerColor,
                          height: 1,
                          indent: AppStyle.gapL,
                          endIndent: AppStyle.gapL,
                        ),
                    ],
                  );
                },
                childCount: _measurements.length,
              ),
            ),
        ],
      ),
    );
  }

  static String _fmtVal(double v) {
    if (v == v.truncateToDouble()) return v.toInt().toString();
    return v.toStringAsFixed(1);
  }
}

// ---------------------------------------------------------------------------
// Collapsing header — morphs between full chart and compact sparkline row
// ---------------------------------------------------------------------------

class _CollapsingHeader extends StatelessWidget {
  const _CollapsingHeader({
    required this.label,
    required this.latestValue,
    required this.values,
    required this.collapseT,
    required this.topPadding,
    required this.chartAreaHeight,
  });

  final String label;
  final String latestValue;
  final List<double> values;
  final double collapseT; // 0 = expanded, 1 = collapsed
  final double topPadding;
  final double chartAreaHeight;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // --- Expanded state: title row + big chart below ---
        Opacity(
          opacity: (1 - collapseT * 2).clamp(0.0, 1.0),
          child: Padding(
            padding: EdgeInsets.only(top: topPadding + kToolbarHeight),
            child: SizedBox(
              height: chartAreaHeight,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppStyle.gapL, AppStyle.gapS, AppStyle.gapL, AppStyle.gapM,
                ),
                child: CustomPaint(
                  painter: _ChartPainter(values: values, showLabels: true),
                  size: Size.infinite,
                ),
              ),
            ),
          ),
        ),

        // --- Collapsed state: compact row matching the overview list ---
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height: 56,
          child: Opacity(
            opacity: ((collapseT - 0.5) * 2).clamp(0.0, 1.0),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppStyle.gapL),
              child: Row(
                children: [
                  // Back arrow space (48 dp from leading)
                  const SizedBox(width: 40),
                  SizedBox(
                    width: 70,
                    child: Text(
                      label,
                      style: const TextStyle(
                        color: AppStyle.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppStyle.gapM),
                  Expanded(
                    child: SizedBox(
                      height: 28,
                      child: CustomPaint(
                        painter: _ChartPainter(
                          values: values,
                          showLabels: false,
                        ),
                        size: Size.infinite,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppStyle.gapM),
                  Text(
                    latestValue,
                    style: const TextStyle(
                      color: AppStyle.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Chart painter — used for both expanded and collapsed states
// ---------------------------------------------------------------------------

class _ChartPainter extends CustomPainter {
  _ChartPainter({required this.values, required this.showLabels});

  final List<double> values; // chronological
  final bool showLabels;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;

    final minVal = values.reduce(math.min);
    final maxVal = values.reduce(math.max);
    final range = maxVal - minVal;

    double normalise(double v) {
      if (range == 0) return 0.5;
      return (v - minVal) / range;
    }

    final stepX = size.width / (values.length - 1);
    const vPad = 4.0;
    final chartH = size.height - vPad * 2;

    final path = Path();
    for (var i = 0; i < values.length; i++) {
      final x = i * stepX;
      final y = vPad + chartH * (1 - normalise(values[i]));
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    // Line
    final linePaint = Paint()
      ..color = AppStyle.primaryBlue
      ..style = PaintingStyle.stroke
      ..strokeWidth = showLabels ? 2.5 : 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, linePaint);

    // Gradient fill
    final fillPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppStyle.primaryBlue.withAlpha(showLabels ? 35 : 20),
          AppStyle.primaryBlue.withAlpha(3),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(fillPath, fillPaint);

    // Dot on latest value
    final lastX = (values.length - 1) * stepX;
    final lastY = vPad + chartH * (1 - normalise(values.last));
    canvas.drawCircle(
      Offset(lastX, lastY),
      showLabels ? 4.0 : 3.0,
      Paint()..color = AppStyle.primaryBlue,
    );

    // Value labels (expanded only)
    if (showLabels && size.height > 50) {
      _drawLabels(canvas, size, stepX, vPad, chartH, normalise);
    }
  }

  void _drawLabels(Canvas canvas, Size size, double stepX, double vPad,
      double chartH, double Function(double) normalise) {
    final indices = <int>{0, values.length - 1};
    var minI = 0, maxI = 0;
    for (var i = 1; i < values.length; i++) {
      if (values[i] < values[minI]) minI = i;
      if (values[i] > values[maxI]) maxI = i;
    }
    indices.addAll([minI, maxI]);

    for (final i in indices) {
      final x = i * stepX;
      final y = vPad + chartH * (1 - normalise(values[i]));
      final text = _fmtVal(values[i]);

      final tp = TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(
            color: AppStyle.textSecondary.withAlpha(200),
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      var lx = (x - tp.width / 2).clamp(0.0, size.width - tp.width);
      var ly = y - tp.height - 6;
      if (ly < 0) ly = y + 8;

      tp.paint(canvas, Offset(lx, ly));
    }
  }

  static String _fmtVal(double v) {
    if (v == v.truncateToDouble()) return v.toInt().toString();
    return v.toStringAsFixed(1);
  }

  @override
  bool shouldRepaint(_ChartPainter old) =>
      old.values != values || old.showLabels != showLabels;
}

// ---------------------------------------------------------------------------
// Measurement row — value, date, notes, swipe to delete
// ---------------------------------------------------------------------------

class _MeasurementRow extends StatelessWidget {
  const _MeasurementRow({
    required this.measurement,
    required this.onDelete,
  });

  final DbBodyMeasurement measurement;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(measurement.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppStyle.gapL),
        color: AppStyle.failureRed,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => onDelete(),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppStyle.gapL,
          vertical: AppStyle.gapM,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_fmtVal(measurement.value)} ${measurement.unit}',
                    style: AppStyle.exerciseNameStyle,
                  ),
                  const SizedBox(height: AppStyle.gapXS),
                  Text(
                    _formatDate(measurement.measuredAt),
                    style: AppStyle.captionStyle,
                  ),
                  if (measurement.notes != null) ...[
                    const SizedBox(height: AppStyle.gapXS),
                    Text(
                      measurement.notes!,
                      style: AppStyle.captionStyle,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _fmtVal(double value) {
    if (value == value.truncateToDouble()) return value.toInt().toString();
    return value.toStringAsFixed(1);
  }

  static String _formatDate(int epochSeconds) {
    final dt = DateTime.fromMillisecondsSinceEpoch(epochSeconds * 1000);
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }
}
