import 'package:flutter/material.dart';

import '../../../style/app_style.dart';

/// Screen 4: Fake "Building your plan" loading screen.
///
/// Staggered animations show four analysis steps completing one by one,
/// then reveals a "Your plan is ready" CTA. This is a psychological
/// commitment device — the user feels invested before reaching the paywall.
class BuildingPlanScreen extends StatefulWidget {
  const BuildingPlanScreen({super.key, required this.onComplete});

  final VoidCallback onComplete;

  @override
  State<BuildingPlanScreen> createState() => _BuildingPlanScreenState();
}

class _BuildingPlanScreenState extends State<BuildingPlanScreen>
    with TickerProviderStateMixin {
  static const _steps = [
    'Analyzing your goals...',
    'Building your workout plan...',
    'Calculating your volume targets...',
    'Optimizing rest periods...',
  ];

  /// Index of the step currently animating. -1 = not started.
  int _completedUpTo = -1;
  bool _allDone = false;

  late final AnimationController _readyController;
  late final Animation<double> _readyOpacity;

  @override
  void initState() {
    super.initState();

    _readyController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _readyOpacity = CurvedAnimation(
      parent: _readyController,
      curve: Curves.easeIn,
    );

    _runSequence();
  }

  Future<void> _runSequence() async {
    // Initial pause before starting.
    await Future.delayed(const Duration(milliseconds: 600));

    for (var i = 0; i < _steps.length; i++) {
      if (!mounted) return;
      // Each step takes ~1 second to "complete".
      await Future.delayed(const Duration(milliseconds: 1000));
      if (!mounted) return;
      setState(() => _completedUpTo = i);
    }

    // Small pause before showing "ready" state.
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() => _allDone = true);
    _readyController.forward();
  }

  @override
  void dispose() {
    _readyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppStyle.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40.0),
          Text(
            'Building your\npersonal plan',
            style: AppStyle.paywallHeadlineStyle,
          ),
          const SizedBox(height: AppStyle.gapS),
          Text(
            'Hang tight while we crunch the numbers.',
            style: AppStyle.paywallSubheadlineStyle,
          ),
          const SizedBox(height: 48.0),

          // Step list
          ...List.generate(_steps.length, (i) {
            final isCompleted = i <= _completedUpTo;
            final isActive = i == _completedUpTo + 1 && !_allDone;

            return Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Row(
                children: [
                  _StepIndicator(
                    isCompleted: isCompleted,
                    isActive: isActive,
                  ),
                  const SizedBox(width: AppStyle.gapL),
                  Expanded(
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 300),
                      style: TextStyle(
                        color: isCompleted
                            ? AppStyle.paywallTextPrimary
                            : isActive
                                ? AppStyle.paywallTextSecondary
                                : AppStyle.paywallTextMuted,
                        fontSize: 16.0,
                        fontWeight: isCompleted
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                      child: Text(_steps[i]),
                    ),
                  ),
                ],
              ),
            );
          }),

          const Spacer(),

          // "Your plan is ready" CTA
          if (_allDone)
            FadeTransition(
              opacity: _readyOpacity,
              child: Column(
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    color: AppStyle.premiumGold,
                    size: 48.0,
                  ),
                  const SizedBox(height: AppStyle.gapL),
                  Text(
                    'Your plan is ready',
                    style: AppStyle.paywallHeadlineStyle.copyWith(fontSize: 22.0),
                  ),
                  const SizedBox(height: 24.0),
                  SizedBox(
                    width: double.infinity,
                    height: 56.0,
                    child: ElevatedButton(
                      onPressed: widget.onComplete,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppStyle.premiumGold,
                        shape: RoundedRectangleBorder(
                          borderRadius: AppStyle.pillRadius,
                        ),
                        elevation: 0,
                      ),
                      child: Text('Continue', style: AppStyle.paywallCtaStyle),
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 48.0),
        ],
      ),
    );
  }
}

/// Animated circle that starts empty, spins while active, and shows a
/// checkmark when complete.
class _StepIndicator extends StatelessWidget {
  const _StepIndicator({
    required this.isCompleted,
    required this.isActive,
  });

  final bool isCompleted;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    const size = 28.0;

    if (isCompleted) {
      return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppStyle.premiumGold,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.check_rounded, color: Colors.white, size: 18.0),
      );
    }

    if (isActive) {
      return SizedBox(
        width: size,
        height: size,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          color: AppStyle.premiumGold,
        ),
      );
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppStyle.paywallUnselectedBorder, width: 2.0),
      ),
    );
  }
}
