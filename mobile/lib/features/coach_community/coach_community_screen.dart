import 'package:flutter/material.dart';

import '../../style/app_style.dart';

/// Coach Community concept screen.
///
/// Shows a realistic preview of the coach/client relationship feature.
/// All data is hardcoded — this is an early prototype screen.
class CoachCommunityScreen extends StatefulWidget {
  const CoachCommunityScreen({super.key});

  @override
  State<CoachCommunityScreen> createState() => _CoachCommunityScreenState();
}

class _CoachCommunityScreenState extends State<CoachCommunityScreen> {
  /// Toggle between the "joined a coach" view and the "join a coach" view.
  bool _hasCoach = true;

  final TextEditingController _inviteCodeController = TextEditingController();

  @override
  void dispose() {
    _inviteCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyle.feedBackground,
      appBar: AppBar(
        backgroundColor: AppStyle.scaffoldBackground,
        title: const Text(
          'Coach',
          style: TextStyle(
            color: AppStyle.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        elevation: 0,
        scrolledUnderElevation: 0.5,
        actions: [
          // Dev toggle for switching views.
          IconButton(
            icon: Icon(
              _hasCoach ? Icons.link_off : Icons.link,
              color: AppStyle.textSecondary,
              size: AppStyle.topBarIconSize,
            ),
            tooltip: _hasCoach ? 'Show join view' : 'Show coach view',
            onPressed: () => setState(() => _hasCoach = !_hasCoach),
          ),
        ],
      ),
      body: _hasCoach ? _buildCoachView() : _buildJoinView(),
    );
  }

  // ---------------------------------------------------------------------------
  // Joined view (sections 1-4)
  // ---------------------------------------------------------------------------

  Widget _buildCoachView() {
    return ListView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppStyle.gapL,
        vertical: AppStyle.gapL,
      ),
      children: [
        _buildCoachProfileCard(),
        const SizedBox(height: AppStyle.gapM),
        _buildMembershipCard(),
        const SizedBox(height: AppStyle.gapM),
        _buildProgramCard(),
        const SizedBox(height: AppStyle.gapM),
        _buildMessagesCard(),
        const SizedBox(height: AppStyle.gapM),
        _buildLeaveCoachCard(),
        const SizedBox(height: AppStyle.gapXL),
      ],
    );
  }

  // -- 1. Coach Profile Card --------------------------------------------------

  Widget _buildCoachProfileCard() {
    return Container(
      padding: AppStyle.cardPadding,
      decoration: BoxDecoration(
        color: AppStyle.cardBackground,
        borderRadius: AppStyle.cardRadius,
        border: Border.all(color: AppStyle.cardBorder),
      ),
      child: Row(
        children: [
          // Avatar
          _buildInitialsAvatar('MR', AppStyle.coachTeal, size: 56),
          const SizedBox(width: AppStyle.gapM),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('Marcus Reeves', style: AppStyle.coachNameStyle),
                    const SizedBox(width: AppStyle.gapS),
                    _buildVerifiedBadge(),
                  ],
                ),
                const SizedBox(height: AppStyle.gapXS),
                const Text(
                  'Certified PT \u00b7 Strength & Conditioning',
                  style: AppStyle.coachTitleStyle,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerifiedBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppStyle.coachTeal,
        borderRadius: AppStyle.circleRadius,
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle, color: Colors.white, size: 12),
          SizedBox(width: 4),
          Text('Verified', style: AppStyle.coachBadgeStyle),
        ],
      ),
    );
  }

  // -- 2. Membership Card -----------------------------------------------------

  Widget _buildMembershipCard() {
    const features = [
      'Unlimited workouts',
      'Coach-assigned programs',
      'Progress tracking',
    ];

    return Container(
      padding: AppStyle.cardPadding,
      decoration: BoxDecoration(
        color: AppStyle.coachCardDark,
        borderRadius: AppStyle.cardRadius,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Plan header
          Row(
            children: [
              const Icon(Icons.shield_rounded,
                  color: AppStyle.coachTealLight, size: 20),
              const SizedBox(width: AppStyle.gapS),
              Text(
                'Pro Plan',
                style: AppStyle.coachSectionTitleStyle
                    .copyWith(color: Colors.white),
              ),
              const SizedBox(width: AppStyle.gapS),
              Container(
                padding: AppStyle.pillPadding,
                decoration: BoxDecoration(
                  color: AppStyle.coachTeal.withValues(alpha: 0.3),
                  borderRadius: AppStyle.circleRadius,
                ),
                child: Text(
                  'Paid by coach',
                  style: AppStyle.coachBadgeStyle.copyWith(
                    color: AppStyle.coachTealLight,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppStyle.gapM),
          // Per-seat pricing context
          Container(
            padding: AppStyle.pillPadding,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.07),
              borderRadius: AppStyle.pillRadius,
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded,
                    color: AppStyle.coachTealLight, size: 16),
                const SizedBox(width: AppStyle.gapS),
                Expanded(
                  child: Text(
                    'Your coach pays per athlete — your Pro plan is included',
                    style: AppStyle.coachFeatureStyle.copyWith(
                      color: AppStyle.coachCardTextMuted,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppStyle.gapL),
          // Feature list
          ...features.map((f) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    const Icon(Icons.check_rounded,
                        color: AppStyle.coachTealLight, size: 18),
                    const SizedBox(width: AppStyle.gapM),
                    Text(
                      f,
                      style: AppStyle.coachFeatureStyle
                          .copyWith(color: Colors.white),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  // -- 3. Program Card --------------------------------------------------------

  Widget _buildProgramCard() {
    const totalWeeks = 12;
    const currentWeek = 8;
    const progress = currentWeek / totalWeeks;

    return Container(
      padding: AppStyle.cardPadding,
      decoration: BoxDecoration(
        color: AppStyle.cardBackground,
        borderRadius: AppStyle.cardRadius,
        border: Border.all(color: AppStyle.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Icon(Icons.calendar_month_rounded,
                  color: AppStyle.coachTeal, size: 20),
              const SizedBox(width: AppStyle.gapS),
              const Text(
                'Your Program',
                style: AppStyle.coachSectionTitleStyle,
              ),
            ],
          ),
          const SizedBox(height: AppStyle.gapL),
          // Program name
          const Text(
            '12-Week Strength Builder',
            style: TextStyle(
              color: AppStyle.textPrimary,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppStyle.gapS),
          // Week progress label
          Text(
            'Week $currentWeek of $totalWeeks',
            style: AppStyle.captionStyle,
          ),
          const SizedBox(height: AppStyle.gapS),
          // Progress bar
          ClipRRect(
            borderRadius: AppStyle.circleRadius,
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: AppStyle.coachTealTint,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppStyle.coachTeal),
            ),
          ),
          const SizedBox(height: AppStyle.gapL),
          // Next session
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppStyle.coachTealTint,
              borderRadius: AppStyle.pillRadius,
            ),
            child: Row(
              children: [
                const Icon(Icons.arrow_forward_rounded,
                    color: AppStyle.coachTeal, size: 16),
                const SizedBox(width: AppStyle.gapS),
                Expanded(
                  child: Text(
                    'Next: Upper Body Push \u00b7 Tomorrow 07:00',
                    style: AppStyle.coachFeatureStyle.copyWith(
                      color: AppStyle.coachTeal,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppStyle.gapM),
          // View program button
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                foregroundColor: AppStyle.coachTeal,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: AppStyle.pillRadius,
                  side: const BorderSide(color: AppStyle.coachTeal),
                ),
              ),
              child: const Text(
                'View Program',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // -- Messages Card -----------------------------------------------------------

  Widget _buildMessagesCard() {
    const messages = [
      (
        text:
            'Great session yesterday! Let\'s increase bench press by 2.5 kg next week.',
        time: '2h ago',
      ),
      (
        text:
            'I\'ve updated your program for the next 2 weeks. Focus on progressive overload.',
        time: 'Yesterday',
      ),
      (
        text:
            'Remember to log your meals this week \u2014 we\'re tracking nutrition too.',
        time: '3 days ago',
      ),
    ];

    return Container(
      padding: AppStyle.cardPadding,
      decoration: BoxDecoration(
        color: AppStyle.cardBackground,
        borderRadius: AppStyle.cardRadius,
        border: Border.all(color: AppStyle.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Icon(Icons.chat_bubble_outline_rounded,
                  color: AppStyle.coachTeal, size: 20),
              const SizedBox(width: AppStyle.gapS),
              const Text('Messages', style: AppStyle.coachSectionTitleStyle),
            ],
          ),
          const SizedBox(height: AppStyle.gapL),
          // Message list
          ...messages.map((m) => Padding(
                padding: const EdgeInsets.only(bottom: AppStyle.gapM),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Coach name + timestamp
                    Row(
                      children: [
                        Text(
                          'Marcus',
                          style: AppStyle.captionStyle.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppStyle.coachTeal,
                          ),
                        ),
                        const SizedBox(width: AppStyle.gapS),
                        Text(m.time, style: AppStyle.captionStyle),
                      ],
                    ),
                    const SizedBox(height: AppStyle.gapXS),
                    // Message bubble
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppStyle.coachTealTint,
                        borderRadius: AppStyle.pillRadius,
                      ),
                      child: Text(
                        m.text,
                        style: AppStyle.coachFeatureStyle,
                      ),
                    ),
                  ],
                ),
              )),
          // Reply input
          Container(
            decoration: BoxDecoration(
              color: AppStyle.inputPillBackground,
              borderRadius: AppStyle.pillRadius,
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Reply to Marcus...',
                      hintStyle: TextStyle(
                        color: AppStyle.textSecondary.withValues(alpha: 0.5),
                        fontSize: 14,
                      ),
                      filled: true,
                      fillColor: Colors.transparent,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      border: InputBorder.none,
                    ),
                    style: const TextStyle(
                      color: AppStyle.textPrimary,
                      fontSize: 14,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.send_rounded,
                      color: AppStyle.coachTeal, size: 20),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // -- 4. Leave Coach Card -----------------------------------------------------

  Widget _buildLeaveCoachCard() {
    return Container(
      padding: AppStyle.cardPadding,
      decoration: BoxDecoration(
        color: AppStyle.cardBackground,
        borderRadius: AppStyle.cardRadius,
        border: Border.all(color: AppStyle.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Manage', style: AppStyle.coachSectionTitleStyle),
          const SizedBox(height: AppStyle.gapM),
          // Warning about what happens
          Container(
            padding: AppStyle.pillPadding,
            decoration: BoxDecoration(
              color: AppStyle.warmupOrangeTint,
              borderRadius: AppStyle.pillRadius,
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded,
                    color: AppStyle.warmupOrange, size: 16),
                const SizedBox(width: AppStyle.gapS),
                Expanded(
                  child: Text(
                    'If you leave, you\'ll need to pay for Pro yourself',
                    style: AppStyle.coachFeatureStyle.copyWith(
                      color: AppStyle.warmupOrange,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppStyle.gapM),
          // Leave button
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => setState(() => _hasCoach = false),
              style: TextButton.styleFrom(
                foregroundColor: AppStyle.textSecondary,
              ),
              child: const Text(
                'Leave coach',
                style: AppStyle.captionStyle,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Join a Coach view (section 5)
  // ---------------------------------------------------------------------------

  Widget _buildJoinView() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppStyle.gapL,
          vertical: AppStyle.gapXL,
        ),
        child: Column(
          children: [
            // Illustration
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppStyle.coachTealTint,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.people_alt_rounded,
                color: AppStyle.coachTeal,
                size: 40,
              ),
            ),
            const SizedBox(height: AppStyle.gapXL),
            const Text(
              'Join a Coach',
              style: TextStyle(
                color: AppStyle.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppStyle.gapS),
            const Text(
              'Your coach will be able to assign programs\nand track your progress',
              textAlign: TextAlign.center,
              style: AppStyle.coachTitleStyle,
            ),
            const SizedBox(height: AppStyle.gapXL),
            // Invite code field
            Container(
              padding: AppStyle.cardPadding,
              decoration: BoxDecoration(
                color: AppStyle.cardBackground,
                borderRadius: AppStyle.cardRadius,
                border: Border.all(color: AppStyle.cardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Invite Code',
                    style: AppStyle.coachSectionTitleStyle,
                  ),
                  const SizedBox(height: AppStyle.gapM),
                  TextField(
                    controller: _inviteCodeController,
                    textCapitalization: TextCapitalization.characters,
                    style: const TextStyle(
                      color: AppStyle.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.5,
                    ),
                    decoration: InputDecoration(
                      hintText: 'COACH-MR-2024',
                      hintStyle: TextStyle(
                        color: AppStyle.textSecondary.withValues(alpha: 0.5),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.5,
                      ),
                      filled: true,
                      fillColor: AppStyle.inputPillBackground,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: AppStyle.pillRadius,
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: AppStyle.pillRadius,
                        borderSide: const BorderSide(
                            color: AppStyle.coachTeal, width: 1.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppStyle.gapL),
                  // Join button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() => _hasCoach = true);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppStyle.coachTeal,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: AppStyle.pillRadius,
                        ),
                      ),
                      child: const Text(
                        'Join',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppStyle.gapL),
            // Info note
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppStyle.coachTealTint,
                borderRadius: AppStyle.pillRadius,
              ),
              child: Row(
                children: [
                  const Icon(Icons.auto_awesome,
                      color: AppStyle.coachTeal, size: 18),
                  const SizedBox(width: AppStyle.gapM),
                  Expanded(
                    child: Text(
                      'Coach subscription covers your Pro plan',
                      style: AppStyle.coachFeatureStyle.copyWith(
                        color: AppStyle.coachTeal,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Shared helpers
  // ---------------------------------------------------------------------------

  Widget _buildInitialsAvatar(String initials, Color color,
      {double size = 40}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: TextStyle(
          color: Colors.white,
          fontSize: size * 0.34,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
