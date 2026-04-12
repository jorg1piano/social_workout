import 'package:flutter/material.dart';

import '../../../style/app_style.dart';

/// Screen 1: "What's your fitness goal?"
///
/// Four tappable cards. Tapping one fires [onSelected] with the goal string
/// and the parent flow advances to the next page.
class GoalSelectionScreen extends StatelessWidget {
  const GoalSelectionScreen({super.key, required this.onSelected});

  final ValueChanged<String> onSelected;

  static const _goals = [
    _GoalOption(
      title: 'Build Muscle',
      subtitle: 'Gain size and definition',
      icon: Icons.fitness_center_rounded,
    ),
    _GoalOption(
      title: 'Lose Weight',
      subtitle: 'Burn fat and get lean',
      icon: Icons.local_fire_department_rounded,
    ),
    _GoalOption(
      title: 'Get Stronger',
      subtitle: 'Increase your max lifts',
      icon: Icons.bolt_rounded,
    ),
    _GoalOption(
      title: 'Stay Active',
      subtitle: 'General health and wellness',
      icon: Icons.favorite_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppStyle.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40.0),
          Text(
            "What's your\nfitness goal?",
            style: AppStyle.paywallHeadlineStyle,
          ),
          const SizedBox(height: AppStyle.gapS),
          Text(
            "We'll build a plan around your goals.",
            style: AppStyle.paywallSubheadlineStyle,
          ),
          const SizedBox(height: 32.0),
          ..._goals.map(
            (goal) => Padding(
              padding: const EdgeInsets.only(bottom: AppStyle.gapM),
              child: _GoalCard(
                goal: goal,
                onTap: () => onSelected(goal.title),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GoalOption {
  const _GoalOption({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;
}

class _GoalCard extends StatelessWidget {
  const _GoalCard({required this.goal, required this.onTap});

  final _GoalOption goal;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 18.0),
        decoration: BoxDecoration(
          color: AppStyle.paywallCardBackground,
          borderRadius: AppStyle.cardRadius,
          border: Border.all(color: AppStyle.paywallUnselectedBorder),
        ),
        child: Row(
          children: [
            Container(
              width: 48.0,
              height: 48.0,
              decoration: BoxDecoration(
                color: AppStyle.premiumGoldTint,
                borderRadius: AppStyle.pillRadius,
              ),
              child: Icon(
                goal.icon,
                color: AppStyle.premiumGold,
                size: 24.0,
              ),
            ),
            const SizedBox(width: AppStyle.gapL),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(goal.title, style: AppStyle.paywallCardTitleStyle),
                  const SizedBox(height: 2.0),
                  Text(goal.subtitle, style: AppStyle.paywallCardSubtitleStyle),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: AppStyle.paywallTextMuted,
              size: 24.0,
            ),
          ],
        ),
      ),
    );
  }
}
