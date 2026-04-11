import 'package:flutter/material.dart';

/// Centralized visual styling for the app.
///
/// Hard rule from `.claude/agents/mobile.md`: never hardcode colors, paddings,
/// or text sizes in widget code — everything routes through this class.
class AppStyle {
  AppStyle._();

  // ---------- Colors ----------

  static const Color scaffoldBackground = Color(0xFFFFFFFF);
  static const Color topBarBackground = Color(0xFFF2F2F4);

  /// Primary blue used for exercise names and interactive affordances.
  static const Color primaryBlue = Color(0xFF1E88E5);

  /// Translucent blue used as a background for swap / more-options pills.
  static const Color accentBlueTint = Color(0x141E88E5); // 8% alpha primaryBlue

  /// Green used for the "Finish" pill.
  static const Color finishGreen = Color(0xFF2ECC71);

  static const Color textPrimary = Color(0xFF111111);
  static const Color textSecondary = Color(0xFF8A8A8E);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color cardBorder = Color(0xFFEDEDEF);
  static const Color dividerColor = Color(0xFFE5E5EA);

  /// Background tint for numeric-input pills (weight / reps).
  static const Color inputPillBackground = Color(0xFFF2F2F4);

  /// Accent used for warmup badges and the "W" marker.
  static const Color warmupOrange = Color(0xFFF28C18);
  static const Color warmupOrangeTint = Color(0x1FF28C18); // 12% warmupOrange

  /// Accent used for drop-set badges and the "D" marker.
  /// Purple is the conventional drop-set color in tracking apps; chosen so
  /// it doesn't clash with the warmup orange or the failure red.
  static const Color dropSetPurple = Color(0xFF8E44AD);

  /// Accent used for failure-set badges and the "F" marker.
  /// Red signals "went to failure" — distinct from the green completed
  /// flood so it's still legible on a completed row.
  static const Color failureRed = Color(0xFFE74C3C);

  /// Completed-row tint — a soft green flood over a completed set row.
  static const Color completedRowTint = Color(0x1F2ECC71); // 12% finishGreen

  // ---------- Spacing ----------

  static const double gapXS = 4.0;
  static const double gapS = 8.0;
  static const double gapM = 12.0;
  static const double gapL = 16.0;
  static const double gapXL = 24.0;

  static const EdgeInsets screenPadding = EdgeInsets.symmetric(horizontal: 20.0);
  static const EdgeInsets topBarPadding = EdgeInsets.fromLTRB(12.0, 8.0, 12.0, 8.0);
  static const EdgeInsets cardPadding = EdgeInsets.all(16.0);
  static const EdgeInsets pillPadding = EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0);
  static const EdgeInsets finishButtonPadding = EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0);

  // ---------- Radii ----------

  static const BorderRadius cardRadius = BorderRadius.all(Radius.circular(16.0));
  static const BorderRadius pillRadius = BorderRadius.all(Radius.circular(12.0));
  static const BorderRadius circleRadius = BorderRadius.all(Radius.circular(999.0));
  static const BorderRadius sheetRadius = BorderRadius.only(
    topLeft: Radius.circular(24.0),
    topRight: Radius.circular(24.0),
  );

  // ---------- Icon sizing ----------

  static const double topBarIconSize = 18.0;
  static const double smallIconSize = 16.0;
  static const double metaIconSize = 14.0;
  static const double checkIconSize = 18.0;

  // ---------- Set row layout ----------

  /// Width of a numeric-input pill (kg / reps). Wide enough to hold 3
  /// digits in the default text style without cropping.
  static const double inputPillWidth = 56.0;
  static const double inputPillHeight = 32.0;

  /// Width of the round ✓ cell.
  static const double checkCircleSize = 32.0;

  /// Row spacing between the set-table column cells.
  static const double setRowHGap = 10.0;
  static const double setRowVGap = 8.0;

  static const EdgeInsets setRowPadding = EdgeInsets.symmetric(vertical: 6.0);

  // ---------- Text styles ----------

  static const TextStyle topBarTimeStyle = TextStyle(color: textPrimary, fontSize: 15.0, fontWeight: FontWeight.w500);

  static const TextStyle finishButtonStyle = TextStyle(
    color: Colors.white,
    fontSize: 15.0,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle workoutTitleStyle = TextStyle(
    color: textPrimary,
    fontSize: 28.0,
    fontWeight: FontWeight.w800,
    height: 1.1,
  );

  static const TextStyle headerMetaStyle = TextStyle(color: textSecondary, fontSize: 13.0, fontWeight: FontWeight.w500);

  static const TextStyle exerciseNameStyle = TextStyle(color: primaryBlue, fontSize: 17.0, fontWeight: FontWeight.w700);

  static const TextStyle captionStyle = TextStyle(color: textSecondary, fontSize: 13.0, fontWeight: FontWeight.w500);

  static const TextStyle sheetTitleStyle = TextStyle(color: textPrimary, fontSize: 18.0, fontWeight: FontWeight.w700);

  static const TextStyle sheetVariantNameStyle = TextStyle(
    color: textPrimary,
    fontSize: 16.0,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle sheetCurrentLabelStyle = TextStyle(
    color: primaryBlue,
    fontSize: 12.0,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.4,
  );

  /// Column-header text style for "Set / Previous / kg / Reps / ✓".
  static const TextStyle setTableHeaderStyle = TextStyle(
    color: textSecondary,
    fontSize: 12.0,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.3,
  );

  /// "1" / "2" / "3" working-set numbers in the Set column.
  static const TextStyle setNumberStyle = TextStyle(color: textPrimary, fontSize: 15.0, fontWeight: FontWeight.w700);

  /// Orange "W" inside the warmup badge.
  static const TextStyle warmupBadgeStyle = TextStyle(
    color: warmupOrange,
    fontSize: 13.0,
    fontWeight: FontWeight.w800,
    letterSpacing: 0.4,
  );

  /// Purple "D" inside the drop-set badge. Same weight/size as the warmup
  /// badge so the column stays visually balanced.
  static const TextStyle dropSetBadgeStyle = TextStyle(
    color: dropSetPurple,
    fontSize: 13.0,
    fontWeight: FontWeight.w800,
    letterSpacing: 0.4,
  );

  /// Red "F" inside the failure badge.
  static const TextStyle failureBadgeStyle = TextStyle(
    color: failureRed,
    fontSize: 13.0,
    fontWeight: FontWeight.w800,
    letterSpacing: 0.4,
  );

  /// Grey small caption for the Previous column.
  static const TextStyle previousColumnStyle = TextStyle(
    color: textSecondary,
    fontSize: 13.0,
    fontWeight: FontWeight.w500,
  );

  /// Editable value text inside the kg / reps input pill.
  static const TextStyle inputPillStyle = TextStyle(color: textPrimary, fontSize: 15.0, fontWeight: FontWeight.w600);

  /// Blue "+ Add Set" action at the bottom of each card.
  static const TextStyle addSetButtonStyle = TextStyle(color: primaryBlue, fontSize: 14.0, fontWeight: FontWeight.w700);

  // ---------- Formatters ----------

  /// Sign-aware weight display formatter for the "Previous" column and any
  /// other read-only weight rendering. Per the schema, `exercise_set.weight`
  /// is a signed `DECIMAL(5,2)`:
  ///
  ///   * `null`     → em dash (no value logged)
  ///   * positive   → `12,5 kg` — EU comma, integers drop the decimal
  ///   * zero       → `bw`     — bodyweight movement (e.g. push-up)
  ///   * negative   → `15 kg (−)` — assistance (e.g. assisted chin-up)
  ///
  /// The negative branch isn't reachable from the Push Day template (no
  /// assisted exercises in that seed), but the formatter is sign-aware
  /// from day one so we don't have to retrofit when the assisted-pulldown
  /// screen lands. Input fields keep their own positive-only formatter —
  /// this one is for display.
  static String formatWeightDisplay(double? kg) {
    if (kg == null) return '—';
    if (kg == 0) return 'bw';
    final magnitude = kg.abs();
    final magnitudeText = magnitude == magnitude.truncateToDouble()
        ? magnitude.toInt().toString()
        : magnitude.toString().replaceAll('.', ',');
    if (kg > 0) return '$magnitudeText kg';
    return '$magnitudeText kg (−)';
  }

  // ---------- Theme ----------

  static ThemeData theme() {
    final base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: scaffoldBackground,
      colorScheme: base.colorScheme.copyWith(primary: primaryBlue, surface: scaffoldBackground),
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
    );
  }
}
