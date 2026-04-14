import 'package:flutter/material.dart';

import '../../style/app_style.dart';

/// Coach-side detail view for a single client/athlete.
///
/// Shows the coach everything about one athlete: current program progress,
/// recent activity, message thread, and roster management.
/// All data is hardcoded (early prototype).
class CoachClientDetailScreen extends StatelessWidget {
  const CoachClientDetailScreen({
    super.key,
    this.clientName = 'Anna K.',
    this.clientInitials = 'AK',
    this.avatarColor = const Color(0xFF6366F1),
  });

  final String clientName;
  final String clientInitials;
  final Color avatarColor;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyle.feedBackground,
      appBar: AppBar(
        backgroundColor: AppStyle.scaffoldBackground,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: AppStyle.textPrimary,
            size: 22,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          clientName,
          style: const TextStyle(
            color: AppStyle.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppStyle.gapL,
          vertical: AppStyle.gapL,
        ),
        children: [
          _buildClientHeader(),
          const SizedBox(height: AppStyle.gapM),
          _buildCurrentProgramCard(),
          const SizedBox(height: AppStyle.gapM),
          _buildRecentActivityCard(),
          const SizedBox(height: AppStyle.gapM),
          _buildMessagesCard(),
          const SizedBox(height: AppStyle.gapM),
          _buildManageSection(),
          const SizedBox(height: AppStyle.gapXL),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 1. Client header
  // ---------------------------------------------------------------------------

  Widget _buildClientHeader() {
    return Container(
      padding: AppStyle.cardPadding,
      decoration: BoxDecoration(
        color: AppStyle.cardBackground,
        borderRadius: AppStyle.cardRadius,
        border: Border.all(color: AppStyle.cardBorder),
      ),
      child: Column(
        children: [
          // Avatar + name + activity status.
          Row(
            children: [
              _buildAvatar(64),
              const SizedBox(width: AppStyle.gapM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(clientName, style: AppStyle.coachNameStyle),
                    const SizedBox(height: AppStyle.gapXS),
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFF22C55E),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: AppStyle.gapXS),
                        Text(
                          'Active today',
                          style: AppStyle.captionStyle.copyWith(
                            color: const Color(0xFF22C55E),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppStyle.gapL),
          // Stat chips row.
          Row(
            children: [
              _buildStatChip('142 workouts'),
              const SizedBox(width: AppStyle.gapS),
              _buildStatChip('10 months'),
              const SizedBox(width: AppStyle.gapS),
              _buildStatChip('96% adherence'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: avatarColor,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        clientInitials,
        style: TextStyle(
          color: Colors.white,
          fontSize: size * 0.34,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildStatChip(String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: AppStyle.coachTealTint,
          borderRadius: AppStyle.pillRadius,
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: AppStyle.captionStyle.copyWith(
            color: AppStyle.coachTeal,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 2. Current Program card
  // ---------------------------------------------------------------------------

  Widget _buildCurrentProgramCard() {
    const currentWeek = 10;
    const totalWeeks = 12;
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
          // Header.
          Row(
            children: [
              const Icon(Icons.calendar_month_rounded,
                  color: AppStyle.coachTeal, size: 20),
              const SizedBox(width: AppStyle.gapS),
              const Text('Current Program',
                  style: AppStyle.coachSectionTitleStyle),
            ],
          ),
          const SizedBox(height: AppStyle.gapL),
          // Program name.
          const Text(
            '12-Week Strength Builder',
            style: TextStyle(
              color: AppStyle.textPrimary,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppStyle.gapS),
          // Week progress.
          Text(
            'Week $currentWeek of $totalWeeks',
            style: AppStyle.captionStyle,
          ),
          const SizedBox(height: AppStyle.gapS),
          // Progress bar.
          ClipRRect(
            borderRadius: AppStyle.circleRadius,
            child: const LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: AppStyle.coachTealTint,
              valueColor: AlwaysStoppedAnimation<Color>(AppStyle.coachTeal),
            ),
          ),
          const SizedBox(height: AppStyle.gapL),
          // This week's schedule.
          _buildScheduleRow(
            day: 'Mon',
            name: 'Upper Push',
            completed: true,
          ),
          const SizedBox(height: AppStyle.gapS),
          _buildScheduleRow(
            day: 'Wed',
            name: 'Lower Pull',
            completed: true,
          ),
          const SizedBox(height: AppStyle.gapS),
          _buildScheduleRow(
            day: 'Fri',
            name: 'Upper Pull',
            completed: false,
          ),
          const SizedBox(height: AppStyle.gapL),
          // Assign new program button.
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                foregroundColor: AppStyle.coachTeal,
                side: const BorderSide(color: AppStyle.coachTeal),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: AppStyle.pillRadius,
                ),
              ),
              child: const Text(
                'Assign New Program',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleRow({
    required String day,
    required String name,
    required bool completed,
  }) {
    return Row(
      children: [
        SizedBox(
          width: 36,
          child: Text(
            day,
            style: AppStyle.captionStyle.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: AppStyle.gapS),
        Expanded(
          child: Text(
            name,
            style: AppStyle.coachFeatureStyle,
          ),
        ),
        if (completed)
          const Icon(
            Icons.check_circle_rounded,
            color: AppStyle.finishGreen,
            size: 20,
          )
        else
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppStyle.textSecondary,
                width: 1.5,
              ),
            ),
          ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // 3. Recent Activity card
  // ---------------------------------------------------------------------------

  Widget _buildRecentActivityCard() {
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
          // Header.
          Row(
            children: [
              const Icon(Icons.fitness_center_rounded,
                  color: AppStyle.coachTeal, size: 20),
              const SizedBox(width: AppStyle.gapS),
              const Text('Recent Activity',
                  style: AppStyle.coachSectionTitleStyle),
            ],
          ),
          const SizedBox(height: AppStyle.gapL),
          _buildActivityRow(
            title: 'Upper Push',
            when: 'Today',
            detail: '4 exercises \u00b7 42 min',
            hasPR: true,
          ),
          const Divider(color: AppStyle.dividerColor, height: 24),
          _buildActivityRow(
            title: 'Lower Pull',
            when: 'Yesterday',
            detail: '5 exercises \u00b7 51 min',
            hasPR: false,
          ),
          const Divider(color: AppStyle.dividerColor, height: 24),
          _buildActivityRow(
            title: 'Upper Push',
            when: 'Monday',
            detail: '4 exercises \u00b7 38 min',
            hasPR: false,
          ),
        ],
      ),
    );
  }

  Widget _buildActivityRow({
    required String title,
    required String when,
    required String detail,
    required bool hasPR,
  }) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    '$title \u00b7 $when',
                    style: AppStyle.coachFeatureStyle.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (hasPR) ...[
                    const SizedBox(width: AppStyle.gapS),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppStyle.prGoldTint,
                        borderRadius: AppStyle.circleRadius,
                      ),
                      child: Text(
                        'PR',
                        style: AppStyle.feedBadgeStyle.copyWith(
                          color: AppStyle.prGold,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: AppStyle.gapXS),
              Text(detail, style: AppStyle.captionStyle),
            ],
          ),
        ),
        const Icon(
          Icons.chevron_right_rounded,
          color: AppStyle.textSecondary,
          size: 20,
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // 4. Messages card
  // ---------------------------------------------------------------------------

  Widget _buildMessagesCard() {
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
          // Header.
          Row(
            children: [
              const Icon(Icons.chat_bubble_outline_rounded,
                  color: AppStyle.coachTeal, size: 20),
              const SizedBox(width: AppStyle.gapS),
              const Text('Messages', style: AppStyle.coachSectionTitleStyle),
            ],
          ),
          const SizedBox(height: AppStyle.gapL),
          // Coach message (right-aligned, teal bubble).
          _buildCoachMessage(
            text:
                'Great session yesterday! Let\'s increase bench press by 2.5 kg next week.',
            time: '2h ago',
          ),
          const SizedBox(height: AppStyle.gapM),
          // Client message (left-aligned, grey bubble).
          _buildClientMessage(
            text:
                'Thanks coach! Should I also increase the incline press?',
            time: '1h ago',
          ),
          const SizedBox(height: AppStyle.gapL),
          // Reply input.
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
                      hintText: 'Message ${clientName.split(' ').first}...',
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

  Widget _buildCoachMessage({
    required String text,
    required String time,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(time, style: AppStyle.captionStyle),
            const SizedBox(width: AppStyle.gapS),
            Text(
              'You',
              style: AppStyle.captionStyle.copyWith(
                fontWeight: FontWeight.w600,
                color: AppStyle.coachTeal,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppStyle.gapXS),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: AppStyle.coachTealTint,
            borderRadius: AppStyle.pillRadius,
          ),
          child: Text(text, style: AppStyle.coachFeatureStyle),
        ),
      ],
    );
  }

  Widget _buildClientMessage({
    required String text,
    required String time,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              clientName.split(' ').first,
              style: AppStyle.captionStyle.copyWith(
                fontWeight: FontWeight.w600,
                color: AppStyle.textPrimary,
              ),
            ),
            const SizedBox(width: AppStyle.gapS),
            Text(time, style: AppStyle.captionStyle),
          ],
        ),
        const SizedBox(height: AppStyle.gapXS),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: AppStyle.inputPillBackground,
            borderRadius: AppStyle.pillRadius,
          ),
          child: Text(text, style: AppStyle.coachFeatureStyle),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // 5. Manage section
  // ---------------------------------------------------------------------------

  Widget _buildManageSection() {
    return Container(
      padding: AppStyle.cardPadding,
      decoration: BoxDecoration(
        color: AppStyle.cardBackground,
        borderRadius: AppStyle.cardRadius,
        border: Border.all(color: AppStyle.cardBorder),
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: TextButton(
          onPressed: () {},
          style: TextButton.styleFrom(
            foregroundColor: AppStyle.textSecondary,
            padding: EdgeInsets.zero,
          ),
          child: Text(
            'Remove from roster',
            style: AppStyle.captionStyle.copyWith(
              color: AppStyle.failureRed.withValues(alpha: 0.7),
            ),
          ),
        ),
      ),
    );
  }
}
