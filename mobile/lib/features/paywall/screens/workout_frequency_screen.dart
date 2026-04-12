import 'package:flutter/material.dart';

import '../../../style/app_style.dart';

/// Screen 3: "How often do you want to train?"
///
/// Tappable frequency options with a mini weekly calendar preview.
class WorkoutFrequencyScreen extends StatefulWidget {
  const WorkoutFrequencyScreen({super.key, required this.onSelected});

  final ValueChanged<int> onSelected;

  @override
  State<WorkoutFrequencyScreen> createState() => _WorkoutFrequencyScreenState();
}

class _WorkoutFrequencyScreenState extends State<WorkoutFrequencyScreen> {
  int? _selected;

  static const _options = [2, 3, 4, 5, 6];

  void _handleSelect(int freq) {
    setState(() => _selected = freq);
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) widget.onSelected(freq);
    });
  }

  /// Returns which day indices (0=Mon..6=Sun) to highlight for a given
  /// frequency. Spreads them evenly across the week.
  Set<int> _activeDays(int freq) {
    switch (freq) {
      case 2:
        return {0, 3}; // Mon, Thu
      case 3:
        return {0, 2, 4}; // Mon, Wed, Fri
      case 4:
        return {0, 1, 3, 4}; // Mon, Tue, Thu, Fri
      case 5:
        return {0, 1, 2, 3, 4}; // Mon-Fri
      case 6:
        return {0, 1, 2, 3, 4, 5}; // Mon-Sat
      default:
        return {};
    }
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
            'How often do you\nwant to train?',
            style: AppStyle.paywallHeadlineStyle,
          ),
          const SizedBox(height: AppStyle.gapS),
          Text(
            "We'll schedule your workouts accordingly.",
            style: AppStyle.paywallSubheadlineStyle,
          ),
          const SizedBox(height: 32.0),
          // Frequency option chips
          Row(
            children: _options.map((freq) {
              final isSelected = _selected == freq;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: freq == _options.last ? 0.0 : AppStyle.gapS,
                  ),
                  child: GestureDetector(
                    onTap: () => _handleSelect(freq),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppStyle.premiumGoldTint
                            : AppStyle.paywallCardBackground,
                        borderRadius: AppStyle.pillRadius,
                        border: Border.all(
                          color: isSelected
                              ? AppStyle.premiumGold
                              : AppStyle.paywallUnselectedBorder,
                          width: isSelected ? 2.0 : 1.0,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '${freq}x',
                          style: TextStyle(
                            color: isSelected
                                ? AppStyle.premiumGold
                                : AppStyle.paywallTextPrimary,
                            fontSize: 18.0,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 32.0),
          // Weekly calendar preview
          if (_selected != null) ...[
            Text(
              'Your week',
              style: AppStyle.paywallSubheadlineStyle.copyWith(
                fontSize: 14.0,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppStyle.gapM),
            _WeekCalendar(activeDays: _activeDays(_selected!)),
          ],
        ],
      ),
    );
  }
}

class _WeekCalendar extends StatelessWidget {
  const _WeekCalendar({required this.activeDays});

  final Set<int> activeDays;

  static const _labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (i) {
        final active = activeDays.contains(i);
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 42.0,
          child: Column(
            children: [
              Text(
                _labels[i],
                style: TextStyle(
                  color: active
                      ? AppStyle.paywallTextPrimary
                      : AppStyle.paywallTextMuted,
                  fontSize: 12.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppStyle.gapS),
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 36.0,
                height: 36.0,
                decoration: BoxDecoration(
                  color: active
                      ? AppStyle.premiumGold
                      : AppStyle.paywallCardBackground,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: active
                        ? AppStyle.premiumGold
                        : AppStyle.paywallUnselectedBorder,
                  ),
                ),
                child: Center(
                  child: active
                      ? const Icon(
                          Icons.fitness_center_rounded,
                          color: Colors.white,
                          size: 16.0,
                        )
                      : Text(
                          'Rest',
                          style: TextStyle(
                            color: AppStyle.paywallTextMuted,
                            fontSize: 9.0,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
