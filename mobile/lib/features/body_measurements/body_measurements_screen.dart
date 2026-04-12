import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../data/dao/body_measurement_dao.dart';
import '../../data/db/database.dart';
import '../../data/models/db_body_measurement.dart';
import '../../style/app_style.dart';
import 'add_measurement_screen.dart';
import 'measurement_history_screen.dart';
import 'measurement_types.dart';

/// Curated list of measurement categories in display order.
/// Each row shows the title, a sparkline of recent values, and the latest
/// reading. Tapping opens the full history.
const _categories = [
  MeasurementType.weight,
  MeasurementType.bodyFatPct,
  MeasurementType.waist,
  MeasurementType.hips,
  MeasurementType.chest,
  MeasurementType.bicepLeft,
  MeasurementType.bicepRight,
  MeasurementType.forearmLeft,
  MeasurementType.forearmRight,
  MeasurementType.thighLeft,
  MeasurementType.thighRight,
  MeasurementType.calfLeft,
  MeasurementType.calfRight,
  MeasurementType.neck,
  MeasurementType.shoulder,
];

class BodyMeasurementsScreen extends StatefulWidget {
  const BodyMeasurementsScreen({super.key, required this.database});

  final AppDatabase database;

  @override
  State<BodyMeasurementsScreen> createState() => _BodyMeasurementsScreenState();
}

class _BodyMeasurementsScreenState extends State<BodyMeasurementsScreen> {
  late final BodyMeasurementDao _dao;

  /// All measurements grouped by type wire value, ordered oldest-first
  /// (chronological) so the sparkline draws left-to-right in time.
  Map<String, List<DbBodyMeasurement>> _byType = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _dao = BodyMeasurementDao(widget.database.raw);
    _load();
  }

  Future<void> _load() async {
    final all = await _dao.getAllMeasurements(); // newest first
    final grouped = <String, List<DbBodyMeasurement>>{};
    for (final m in all) {
      (grouped[m.measurementType] ??= []).add(m);
    }
    // Reverse each list so oldest is first (sparkline reads left → right).
    for (final list in grouped.values) {
      list.sort((a, b) => a.measuredAt.compareTo(b.measuredAt));
    }
    if (mounted) {
      setState(() {
        _byType = grouped;
        _loading = false;
      });
    }
  }

  Future<void> _openAdd([MeasurementType? preselected]) async {
    final didSave = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AddMeasurementScreen(
          database: widget.database,
          preselectedType: preselected,
        ),
      ),
    );
    if (didSave == true) _load();
  }

  Future<void> _openHistory(MeasurementType type) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MeasurementHistoryScreen(
          database: widget.database,
          type: type,
        ),
      ),
    );
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyle.scaffoldBackground,
      appBar: AppBar(
        title: const Text('Body Measurements'),
        backgroundColor: AppStyle.topBarBackground,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: AppStyle.gapM),
              itemCount: _categories.length,
              separatorBuilder: (_, _) =>
                  const Divider(height: 1, color: AppStyle.dividerColor),
              itemBuilder: (context, index) {
                final type = _categories[index];
                final points = _byType[type.wireValue] ?? [];
                return _MeasurementRow(
                  type: type,
                  points: points,
                  onTap: () => _openHistory(type),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppStyle.primaryBlue,
        onPressed: () => _openAdd(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Row widget — title, sparkline, latest value
// ---------------------------------------------------------------------------

class _MeasurementRow extends StatelessWidget {
  const _MeasurementRow({
    required this.type,
    required this.points,
    required this.onTap,
  });

  final MeasurementType type;
  final List<DbBodyMeasurement> points; // chronological (oldest first)
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final latest = points.isNotEmpty ? points.last : null;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppStyle.gapL,
          vertical: AppStyle.gapM,
        ),
        child: Row(
          children: [
            // Title
            SizedBox(
              width: 110,
              child: Text(
                type.label,
                style: const TextStyle(
                  color: AppStyle.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            const SizedBox(width: AppStyle.gapM),

            // Sparkline — fills available space
            Expanded(
              child: points.length >= 2
                  ? SizedBox(
                      height: 32,
                      child: CustomPaint(
                        painter: _SparklinePainter(
                          values: points.map((p) => p.value).toList(),
                        ),
                        size: Size.infinite,
                      ),
                    )
                  : const SizedBox(height: 32),
            ),

            const SizedBox(width: AppStyle.gapM),

            // Latest value
            SizedBox(
              width: 80,
              child: latest != null
                  ? Text(
                      '${_fmtVal(latest.value)} ${latest.unit}',
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        color: AppStyle.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    )
                  : Text(
                      '--',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: AppStyle.textSecondary.withAlpha(120),
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
            ),

            const SizedBox(width: AppStyle.gapS),
            const Icon(
              Icons.chevron_right,
              color: AppStyle.textSecondary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  static String _fmtVal(double v) {
    if (v == v.truncateToDouble()) return v.toInt().toString();
    return v.toStringAsFixed(1);
  }
}

// ---------------------------------------------------------------------------
// Sparkline painter — simple line chart with gradient fill
// ---------------------------------------------------------------------------

class _SparklinePainter extends CustomPainter {
  _SparklinePainter({required this.values});

  final List<double> values;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;

    final minVal = values.reduce(math.min);
    final maxVal = values.reduce(math.max);
    final range = maxVal - minVal;

    // Normalise Y. If all values are equal, draw a flat line at 50%.
    double normalise(double v) {
      if (range == 0) return 0.5;
      return (v - minVal) / range;
    }

    final stepX = size.width / (values.length - 1);
    const vPad = 4.0; // vertical padding so peaks/valleys aren't clipped
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

    // Stroke
    final linePaint = Paint()
      ..color = AppStyle.primaryBlue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, linePaint);

    // Fill gradient under the line
    final fillPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppStyle.primaryBlue.withAlpha(40),
          AppStyle.primaryBlue.withAlpha(5),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(fillPath, fillPaint);

    // Dot on the latest (rightmost) value
    final lastX = (values.length - 1) * stepX;
    final lastY = vPad + chartH * (1 - normalise(values.last));
    canvas.drawCircle(
      Offset(lastX, lastY),
      3.5,
      Paint()..color = AppStyle.primaryBlue,
    );
  }

  @override
  bool shouldRepaint(_SparklinePainter old) => old.values != values;
}
