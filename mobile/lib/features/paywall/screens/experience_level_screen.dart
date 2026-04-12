import 'package:flutter/material.dart';

import '../../../style/app_style.dart';

/// Screen 2: "How long have you been training?"
///
/// Three horizontal pill selectors. Tapping one fires [onSelected].
class ExperienceLevelScreen extends StatefulWidget {
  const ExperienceLevelScreen({super.key, required this.onSelected});

  final ValueChanged<String> onSelected;

  @override
  State<ExperienceLevelScreen> createState() => _ExperienceLevelScreenState();
}

class _ExperienceLevelScreenState extends State<ExperienceLevelScreen> {
  String? _selected;

  static const _levels = [
    _Level(label: 'Just starting', detail: '< 6 months', icon: Icons.spa_rounded),
    _Level(label: 'Intermediate', detail: '1 \u2013 3 years', icon: Icons.trending_up_rounded),
    _Level(label: 'Advanced', detail: '3+ years', icon: Icons.emoji_events_rounded),
  ];

  void _handleSelect(String label) {
    setState(() => _selected = label);
    // Small delay so the user sees the selection highlight before advancing.
    Future.delayed(const Duration(milliseconds: 350), () {
      if (mounted) widget.onSelected(label);
    });
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
            'How long have you\nbeen training?',
            style: AppStyle.paywallHeadlineStyle,
          ),
          const SizedBox(height: AppStyle.gapS),
          Text(
            "This helps us set the right starting weights.",
            style: AppStyle.paywallSubheadlineStyle,
          ),
          const SizedBox(height: 32.0),
          ..._levels.map(
            (level) => Padding(
              padding: const EdgeInsets.only(bottom: AppStyle.gapM),
              child: _LevelPill(
                level: level,
                isSelected: _selected == level.label,
                onTap: () => _handleSelect(level.label),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Level {
  const _Level({required this.label, required this.detail, required this.icon});

  final String label;
  final String detail;
  final IconData icon;
}

class _LevelPill extends StatelessWidget {
  const _LevelPill({
    required this.level,
    required this.isSelected,
    required this.onTap,
  });

  final _Level level;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final borderColor =
        isSelected ? AppStyle.premiumGold : AppStyle.paywallUnselectedBorder;
    final bgColor = isSelected
        ? AppStyle.premiumGoldTint
        : AppStyle.paywallCardBackground;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 18.0),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: AppStyle.cardRadius,
          border: Border.all(color: borderColor, width: isSelected ? 2.0 : 1.0),
        ),
        child: Row(
          children: [
            Icon(level.icon, color: AppStyle.premiumGold, size: 24.0),
            const SizedBox(width: AppStyle.gapL),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(level.label, style: AppStyle.paywallCardTitleStyle),
                  const SizedBox(height: 2.0),
                  Text(level.detail, style: AppStyle.paywallCardSubtitleStyle),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle_rounded,
                  color: AppStyle.premiumGold, size: 24.0),
          ],
        ),
      ),
    );
  }
}
