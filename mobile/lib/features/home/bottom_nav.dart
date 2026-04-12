import 'package:flutter/material.dart';

import '../../style/app_style.dart';

/// Shared bottom navigation bar for the home page concepts.
/// Five tabs: Home, History, Start Workout (center), Exercises, Store.
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({super.key, this.currentIndex = 0});

  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppStyle.cardBackground,
        border: Border(top: BorderSide(color: AppStyle.cardBorder)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppStyle.gapS, vertical: AppStyle.gapS),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.home_rounded,
                label: 'Home',
                isSelected: currentIndex == 0,
              ),
              _NavItem(
                icon: Icons.history_rounded,
                label: 'History',
                isSelected: currentIndex == 1,
              ),
              _CenterButton(),
              _NavItem(
                icon: Icons.list_alt_rounded,
                label: 'Exercises',
                isSelected: currentIndex == 3,
              ),
              _NavItem(
                icon: Icons.store_rounded,
                label: 'Store',
                isSelected: currentIndex == 4,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
  });

  final IconData icon;
  final String label;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? AppStyle.primaryBlue : AppStyle.textSecondary;
    return SizedBox(
      width: 56.0,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 24.0),
          const SizedBox(height: 3.0),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10.0,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _CenterButton extends StatelessWidget {
  const _CenterButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56.0,
      height: 56.0,
      decoration: BoxDecoration(
        color: AppStyle.primaryBlue,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppStyle.primaryBlue.withAlpha(60),
            blurRadius: 12.0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Icon(Icons.add_rounded, color: Colors.white, size: 30.0),
    );
  }
}
