import 'dart:ui';

import 'package:flutter/material.dart';

import 'app_style.dart';

/// A single reusable glass pane for the Liquid Glass reskin (task #14).
///
/// Paints a translucent frosted-glass surface by stacking:
///
///   1. `ClipRRect` — clips everything to the rounded-rect shape.
///   2. `BackdropFilter(ImageFilter.blur(...))` — blurs whatever is
///      behind the pane; the stronger the sigma, the more substantial
///      the glass feels. Bottom sheets use `glassBlurSigmaHeavy`,
///      everything else uses `glassBlurSigma`.
///   3. A translucent white fill (`glassTint` or `glassTintHeavy`) —
///      the "frost" on top of the blur.
///   4. A 1px rim-light gradient border painted by [_RimPainter], fake
///      "specular edge" that real Liquid Glass has. The gradient is
///      brightest at the top-left corner and fades to transparent at
///      the bottom-right, which is what makes the pane feel lit from
///      the top-left in Apple's reference.
///
/// Caller supplies the child — usually a `Padding(child: Column(...))`.
/// Caller can override the default [borderRadius] so the widget works
/// for both rounded-rect cards and the top-rounded-only sheet shape.
///
/// Approximation note: real iOS 26 Liquid Glass is a native GPU shader
/// (`UIGlassEffect` / SwiftUI `.glassEffect()`) that actually refracts
/// the pixels beneath it with per-pane chromatic aberration and
/// specular highlights. Flutter can't call into that, so this widget
/// is a "good enough to show the design direction" approximation using
/// core Flutter primitives only — no new deps.
class GlassSurface extends StatelessWidget {
  const GlassSurface({
    super.key,
    required this.child,
    this.borderRadius = AppStyle.glassRadius,
    this.blurSigma = AppStyle.glassBlurSigma,
    this.tint = AppStyle.glassTint,
  });

  final Widget child;
  final BorderRadius borderRadius;
  final double blurSigma;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: CustomPaint(
          // Paint the rim on top of the child so it sits above the
          // tint fill and any card content. Uses `foregroundPainter`
          // so hit-testing still goes through to the child.
          foregroundPainter: _RimPainter(borderRadius: borderRadius),
          child: Container(
            decoration: BoxDecoration(
              color: tint,
              borderRadius: borderRadius,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Paints a 1px rim-light stroke around a rounded-rect shape, filled
/// with the [AppStyle.glassRimGradient] shader. The gradient's origin
/// is the pane's top-left corner so the pane always feels lit from
/// that direction.
///
/// Flutter core's `BoxBorder` can't take a gradient paint directly
/// (only solid colors), so we do it as a CustomPaint overlay and stroke
/// the rounded rect with a `Paint..shader = gradient.createShader(...)`.
class _RimPainter extends CustomPainter {
  _RimPainter({required this.borderRadius});

  final BorderRadius borderRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = borderRadius.toRRect(rect);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..shader = AppStyle.glassRimGradient.createShader(rect);
    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(covariant _RimPainter oldDelegate) =>
      oldDelegate.borderRadius != borderRadius;
}
