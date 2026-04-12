import 'package:flutter/material.dart';

import '../../../style/app_style.dart';
import '../paywall_flow_screen.dart';

/// Screen 5: The paywall.
///
/// Shows a personalized summary, benefit list, two pricing options
/// (monthly anchor + annual deal), and a green CTA. A dismiss X fades
/// in after 3 seconds.
class PaywallScreen extends StatefulWidget {
  const PaywallScreen({
    super.key,
    required this.selections,
    required this.onClose,
  });

  final PaywallSelections selections;
  final VoidCallback onClose;

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

enum _PricingPlan { monthly, annual }

class _PaywallScreenState extends State<PaywallScreen>
    with SingleTickerProviderStateMixin {
  _PricingPlan _selectedPlan = _PricingPlan.annual;

  late final AnimationController _closeButtonController;
  late final Animation<double> _closeButtonOpacity;

  @override
  void initState() {
    super.initState();

    _closeButtonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _closeButtonOpacity = CurvedAnimation(
      parent: _closeButtonController,
      curve: Curves.easeIn,
    );

    // Fade in the close button after 3 seconds.
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) _closeButtonController.forward();
    });
  }

  @override
  void dispose() {
    _closeButtonController.dispose();
    super.dispose();
  }

  String get _summaryText {
    final goal = widget.selections.goal ?? 'Your goal';
    final freq = widget.selections.weeklyFrequency ?? 4;
    return '$goal \u00B7 ${freq}x per week';
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Scrollable content
        SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20.0, 8.0, 20.0, 40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20.0),

              // Header
              Text(
                'Your Personal Plan',
                style: AppStyle.paywallHeadlineStyle,
              ),
              const SizedBox(height: AppStyle.gapS),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12.0,
                  vertical: 6.0,
                ),
                decoration: BoxDecoration(
                  color: AppStyle.premiumGoldTint,
                  borderRadius: AppStyle.pillRadius,
                ),
                child: Text(
                  _summaryText,
                  style: TextStyle(
                    color: AppStyle.premiumGold,
                    fontSize: 13.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const SizedBox(height: 32.0),

              // Benefits
              Text(
                "What you'll get",
                style: AppStyle.paywallCardTitleStyle,
              ),
              const SizedBox(height: AppStyle.gapL),
              ..._benefits.map(
                (b) => Padding(
                  padding: const EdgeInsets.only(bottom: 14.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.check_circle_rounded,
                        color: AppStyle.paywallCta,
                        size: 20.0,
                      ),
                      const SizedBox(width: AppStyle.gapM),
                      Expanded(
                        child: Text(b, style: AppStyle.paywallBenefitStyle),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 28.0),

              // Pricing cards
              _PricingCard(
                label: 'Annual',
                price: '499 kr/year',
                perMonth: '41 kr/month',
                badge: 'BEST VALUE',
                saveBadge: 'Save 48%',
                isSelected: _selectedPlan == _PricingPlan.annual,
                onTap: () => setState(() => _selectedPlan = _PricingPlan.annual),
              ),
              const SizedBox(height: AppStyle.gapM),
              _PricingCard(
                label: 'Monthly',
                price: '79 kr/month',
                perMonth: null,
                badge: null,
                saveBadge: null,
                isSelected: _selectedPlan == _PricingPlan.monthly,
                onTap: () =>
                    setState(() => _selectedPlan = _PricingPlan.monthly),
              ),

              const SizedBox(height: 28.0),

              // CTA
              SizedBox(
                width: double.infinity,
                height: 56.0,
                child: ElevatedButton(
                  onPressed: () {
                    // No actual payment logic.
                    widget.onClose();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppStyle.paywallCta,
                    shape: RoundedRectangleBorder(
                      borderRadius: AppStyle.pillRadius,
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Start Free Trial \u2014 7 Days Free',
                    style: AppStyle.paywallCtaStyle,
                  ),
                ),
              ),

              const SizedBox(height: AppStyle.gapM),

              // Fine print
              Center(
                child: Text(
                  "Cancel anytime. You won't be charged until the trial ends.",
                  textAlign: TextAlign.center,
                  style: AppStyle.paywallFinePrintStyle,
                ),
              ),

              const SizedBox(height: AppStyle.gapXL),

              // Restore purchase link
              Center(
                child: GestureDetector(
                  onTap: () {
                    // No-op — placeholder for restore logic.
                  },
                  child: Text(
                    'Restore Purchase',
                    style: AppStyle.paywallFinePrintStyle.copyWith(
                      decoration: TextDecoration.underline,
                      decorationColor: AppStyle.paywallTextMuted,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Close button — fades in after 3 seconds
        Positioned(
          top: 12.0,
          right: 12.0,
          child: FadeTransition(
            opacity: _closeButtonOpacity,
            child: GestureDetector(
              onTap: widget.onClose,
              child: Container(
                width: 32.0,
                height: 32.0,
                decoration: BoxDecoration(
                  color: AppStyle.paywallCardBackground,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.close_rounded,
                  color: AppStyle.paywallTextMuted,
                  size: 18.0,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

const _benefits = [
  'Personalized workout plans',
  'Smart progressive overload',
  'Unlimited workout history',
  'Progress charts & analytics',
  'Social feed & competitions',
  'Streak recovery',
];

/// A pricing option card with optional badges.
class _PricingCard extends StatelessWidget {
  const _PricingCard({
    required this.label,
    required this.price,
    required this.perMonth,
    required this.badge,
    required this.saveBadge,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final String price;
  final String? perMonth;
  final String? badge;
  final String? saveBadge;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: isSelected
              ? AppStyle.premiumGoldTint
              : AppStyle.paywallCardBackground,
          borderRadius: AppStyle.cardRadius,
          border: Border.all(
            color: isSelected
                ? AppStyle.premiumGold
                : AppStyle.paywallUnselectedBorder,
            width: isSelected ? 2.0 : 1.0,
          ),
        ),
        child: Row(
          children: [
            // Radio indicator
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 22.0,
              height: 22.0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? AppStyle.premiumGold
                      : AppStyle.paywallUnselectedBorder,
                  width: 2.0,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 12.0,
                        height: 12.0,
                        decoration: BoxDecoration(
                          color: AppStyle.premiumGold,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: AppStyle.gapL),

            // Plan details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(label, style: AppStyle.paywallCardTitleStyle),
                      if (badge != null) ...[
                        const SizedBox(width: AppStyle.gapS),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8.0,
                            vertical: 3.0,
                          ),
                          decoration: BoxDecoration(
                            color: AppStyle.premiumGold,
                            borderRadius: AppStyle.circleRadius,
                          ),
                          child: Text(badge!, style: AppStyle.paywallBadgeStyle),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4.0),
                  Row(
                    children: [
                      Text(price, style: AppStyle.paywallCardSubtitleStyle),
                      if (saveBadge != null) ...[
                        const SizedBox(width: AppStyle.gapS),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6.0,
                            vertical: 2.0,
                          ),
                          decoration: BoxDecoration(
                            color: AppStyle.paywallCta,
                            borderRadius: AppStyle.circleRadius,
                          ),
                          child: Text(
                            saveBadge!,
                            style: AppStyle.paywallSaveBadgeStyle.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            // Per-month breakdown for annual plan
            if (perMonth != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '41',
                    style: AppStyle.paywallPriceStyle.copyWith(
                      color: isSelected
                          ? AppStyle.premiumGold
                          : AppStyle.paywallTextPrimary,
                    ),
                  ),
                  Text('kr/mo', style: AppStyle.paywallPriceUnitStyle),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
