import 'package:flutter/material.dart';

import '../../style/app_style.dart';
import 'screens/goal_selection_screen.dart';
import 'screens/experience_level_screen.dart';
import 'screens/workout_frequency_screen.dart';
import 'screens/building_plan_screen.dart';
import 'screens/paywall_screen.dart';

/// Local state bag holding the user's quiz selections.
class PaywallSelections {
  String? goal;
  String? experienceLevel;
  int? weeklyFrequency;
}

/// Root widget for the paywall onboarding flow.
///
/// Wraps five screens in a [PageView] with no swipe physics — the user
/// advances only by making selections.
class PaywallFlowScreen extends StatefulWidget {
  const PaywallFlowScreen({super.key});

  @override
  State<PaywallFlowScreen> createState() => _PaywallFlowScreenState();
}

class _PaywallFlowScreenState extends State<PaywallFlowScreen> {
  static const int _totalSteps = 5;

  final PageController _pageController = PageController();
  final PaywallSelections _selections = PaywallSelections();
  int _currentStep = 0;

  void _goToNext() {
    if (_currentStep < _totalSteps - 1) {
      setState(() => _currentStep++);
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyle.paywallBackground,
      body: SafeArea(
        child: Column(
          children: [
            _ProgressBar(
              currentStep: _currentStep,
              totalSteps: _totalSteps,
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  GoalSelectionScreen(
                    onSelected: (goal) {
                      _selections.goal = goal;
                      _goToNext();
                    },
                  ),
                  ExperienceLevelScreen(
                    onSelected: (level) {
                      _selections.experienceLevel = level;
                      _goToNext();
                    },
                  ),
                  WorkoutFrequencyScreen(
                    onSelected: (freq) {
                      _selections.weeklyFrequency = freq;
                      _goToNext();
                    },
                  ),
                  BuildingPlanScreen(
                    onComplete: _goToNext,
                  ),
                  PaywallScreen(
                    selections: _selections,
                    onClose: () => Navigator.of(context).pop(),
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

/// Thin animated progress bar at the top of the flow.
class _ProgressBar extends StatelessWidget {
  const _ProgressBar({
    required this.currentStep,
    required this.totalSteps,
  });

  final int currentStep;
  final int totalSteps;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final fraction = (currentStep + 1) / totalSteps;
          return Container(
            height: 3.0,
            decoration: BoxDecoration(
              color: AppStyle.paywallProgressTrack,
              borderRadius: AppStyle.circleRadius,
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOut,
                width: constraints.maxWidth * fraction,
                decoration: BoxDecoration(
                  color: AppStyle.premiumGold,
                  borderRadius: AppStyle.circleRadius,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
