import 'package:flutter/material.dart';

import '../../style/app_style.dart';
import 'coach_client_detail_screen.dart';

/// Coach-side dashboard — the view a personal trainer sees to manage clients.
///
/// All data is hardcoded (early prototype). The coach's business model is
/// per-seat pricing: they pay per athlete on their roster.
class CoachDashboardScreen extends StatelessWidget {
  const CoachDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyle.feedBackground,
      body: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              slivers: [
                // Safe area top padding.
                SliverToBoxAdapter(
                  child: SizedBox(
                      height: MediaQuery.of(context).padding.top +
                          AppStyle.gapS),
                ),
                // Header.
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppStyle.gapL,
                    ),
                    child: _buildHeader(),
                  ),
                ),
                const SliverToBoxAdapter(
                    child: SizedBox(height: AppStyle.gapL)),
                // Search bar.
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppStyle.gapL,
                    ),
                    child: _buildSearchBar(),
                  ),
                ),
                const SliverToBoxAdapter(
                    child: SizedBox(height: AppStyle.gapM)),
                // Section label.
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppStyle.gapL,
                    ),
                    child: Text(
                      'Client Roster',
                      style: AppStyle.coachSectionTitleStyle,
                    ),
                  ),
                ),
                const SliverToBoxAdapter(
                    child: SizedBox(height: AppStyle.gapS)),
                // Client list.
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppStyle.gapL,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final client = _clients[index];
                        return Padding(
                          padding:
                              const EdgeInsets.only(bottom: AppStyle.gapS),
                          child: _ClientCard(client: client),
                        );
                      },
                      childCount: _clients.length,
                    ),
                  ),
                ),
                // Bottom breathing room above the sticky bar.
                const SliverToBoxAdapter(
                    child: SizedBox(height: AppStyle.gapL)),
              ],
            ),
          ),
          // Sticky bottom summary bar.
          _buildBottomBar(context),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Header
  // ---------------------------------------------------------------------------

  Widget _buildHeader() {
    return Container(
      padding: AppStyle.cardPadding,
      decoration: BoxDecoration(
        color: AppStyle.cardBackground,
        borderRadius: AppStyle.cardRadius,
        border: Border.all(color: AppStyle.cardBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: const BoxDecoration(
              color: AppStyle.coachTeal,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Text(
              'MR',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(width: AppStyle.gapM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('Marcus Reeves',
                        style: AppStyle.coachNameStyle),
                    const SizedBox(width: AppStyle.gapS),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppStyle.coachTealTint,
                        borderRadius: AppStyle.circleRadius,
                      ),
                      child: Text(
                        'Coach',
                        style: AppStyle.coachBadgeStyle.copyWith(
                          color: AppStyle.coachTeal,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppStyle.gapXS),
                Text(
                  'Pro Coach \u00b7 47 athletes \u00b7 \$141/mo',
                  style: AppStyle.coachTitleStyle.copyWith(
                    color: AppStyle.coachTeal,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Search
  // ---------------------------------------------------------------------------

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppStyle.cardBackground,
        borderRadius: AppStyle.pillRadius,
        border: Border.all(color: AppStyle.cardBorder),
      ),
      child: TextField(
        enabled: false, // No functionality needed.
        decoration: InputDecoration(
          hintText: 'Search athletes...',
          hintStyle: AppStyle.captionStyle.copyWith(
            color: AppStyle.textSecondary,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: AppStyle.textSecondary,
            size: 20,
          ),
          filled: false,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          border: InputBorder.none,
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Bottom bar
  // ---------------------------------------------------------------------------

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        AppStyle.gapL,
        AppStyle.gapM,
        AppStyle.gapL,
        MediaQuery.of(context).padding.bottom + AppStyle.gapM,
      ),
      decoration: BoxDecoration(
        color: AppStyle.cardBackground,
        border: Border(
          top: BorderSide(color: AppStyle.cardBorder),
        ),
      ),
      child: Text(
        '47 athletes \u00b7 38 active this week',
        textAlign: TextAlign.center,
        style: AppStyle.captionStyle.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// =============================================================================
// Data model
// =============================================================================

class _ClientData {
  const _ClientData({
    required this.name,
    required this.initials,
    required this.avatarColor,
    this.programName,
    this.currentWeek,
    this.totalWeeks,
    required this.lastActive,
  });

  final String name;
  final String initials;
  final Color avatarColor;
  final String? programName;
  final int? currentWeek;
  final int? totalWeeks;

  /// "Active today", "1 day ago", "3 days ago", "Never" etc.
  final String lastActive;

  bool get isActiveToday => lastActive == 'Active today';
  bool get isNeverActive => lastActive == 'Never';
  bool get isCompleted =>
      programName != null &&
      currentWeek != null &&
      totalWeeks != null &&
      currentWeek == totalWeeks;
  bool get hasProgram => programName != null;

  double get progress {
    if (currentWeek == null || totalWeeks == null || totalWeeks == 0) {
      return 0.0;
    }
    return currentWeek! / totalWeeks!;
  }
}

const _clients = [
  _ClientData(
    name: 'Anna K.',
    initials: 'AK',
    avatarColor: Color(0xFF6366F1), // indigo
    programName: '12-Week Strength Builder',
    currentWeek: 10,
    totalWeeks: 12,
    lastActive: 'Active today',
  ),
  _ClientData(
    name: 'Jonas M.',
    initials: 'JM',
    avatarColor: Color(0xFF0EA5E9), // sky blue
    programName: 'Beginner Fundamentals',
    currentWeek: 3,
    totalWeeks: 8,
    lastActive: 'Active today',
  ),
  _ClientData(
    name: 'Silje R.',
    initials: 'SR',
    avatarColor: Color(0xFFEC4899), // pink
    programName: '12-Week Strength Builder',
    currentWeek: 8,
    totalWeeks: 12,
    lastActive: '1 day ago',
  ),
  _ClientData(
    name: 'Erik B.',
    initials: 'EB',
    avatarColor: Color(0xFFF59E0B), // amber
    programName: 'Hypertrophy Block',
    currentWeek: 5,
    totalWeeks: 6,
    lastActive: 'Active today',
  ),
  _ClientData(
    name: 'Marte S.',
    initials: 'MS',
    avatarColor: Color(0xFF10B981), // emerald
    programName: 'Beginner Fundamentals',
    currentWeek: 1,
    totalWeeks: 8,
    lastActive: '3 days ago',
  ),
  _ClientData(
    name: 'Kristian L.',
    initials: 'KL',
    avatarColor: Color(0xFF8B5CF6), // violet
    programName: '12-Week Strength Builder',
    currentWeek: 12,
    totalWeeks: 12,
    lastActive: '2 days ago',
  ),
  _ClientData(
    name: 'Hanna T.',
    initials: 'HT',
    avatarColor: Color(0xFF94A3B8), // slate
    lastActive: 'Never',
  ),
];

// =============================================================================
// Client card widget
// =============================================================================

class _ClientCard extends StatelessWidget {
  const _ClientCard({required this.client});

  final _ClientData client;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CoachClientDetailScreen(
            clientName: client.name,
            clientInitials: client.initials,
            avatarColor: client.avatarColor,
          ),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppStyle.cardBackground,
          borderRadius: AppStyle.cardRadius,
          border: Border.all(color: AppStyle.cardBorder),
        ),
        child: Row(
          children: [
            // Initials avatar.
            _buildAvatar(),
            const SizedBox(width: AppStyle.gapM),
            // Info column.
            Expanded(child: _buildInfo()),
            const SizedBox(width: AppStyle.gapS),
            // Chevron.
            const Icon(
              Icons.chevron_right_rounded,
              color: AppStyle.textSecondary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: client.avatarColor,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        client.initials,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _buildInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Name row with activity indicator.
        Row(
          children: [
            Expanded(
              child: Text(
                client.name,
                style: AppStyle.feedUserNameStyle,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            _buildActivityIndicator(),
          ],
        ),
        const SizedBox(height: AppStyle.gapXS),
        // Program name or "No program" label.
        if (client.hasProgram) ...[
          _buildProgramRow(),
        ] else ...[
          _buildNoProgramLabel(),
        ],
      ],
    );
  }

  Widget _buildProgramRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Program name with optional "Completed" badge.
        Row(
          children: [
            Flexible(
              child: Text(
                client.programName!,
                style: AppStyle.captionStyle.copyWith(
                  color: AppStyle.textPrimary,
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (client.isCompleted) ...[
              const SizedBox(width: AppStyle.gapS),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: AppStyle.coachTeal,
                  borderRadius: AppStyle.circleRadius,
                ),
                child: const Text(
                  'Completed',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: AppStyle.gapXS),
        // Progress bar row.
        Row(
          children: [
            Text(
              'Week ${client.currentWeek}/${client.totalWeeks}',
              style: AppStyle.captionStyle.copyWith(fontSize: 12),
            ),
            const SizedBox(width: AppStyle.gapS),
            Expanded(
              child: ClipRRect(
                borderRadius: AppStyle.circleRadius,
                child: LinearProgressIndicator(
                  value: client.progress,
                  minHeight: 4,
                  backgroundColor: AppStyle.coachTealTint,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    client.isCompleted
                        ? AppStyle.coachTeal
                        : AppStyle.coachTealLight,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNoProgramLabel() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppStyle.inputPillBackground,
        borderRadius: AppStyle.circleRadius,
      ),
      child: Text(
        'No program',
        style: AppStyle.captionStyle.copyWith(
          fontSize: 12,
          color: AppStyle.textSecondary,
        ),
      ),
    );
  }

  Widget _buildActivityIndicator() {
    if (client.isNeverActive) {
      return Text(
        'Never active',
        style: AppStyle.captionStyle.copyWith(
          fontSize: 11,
          color: AppStyle.textSecondary,
        ),
      );
    }

    final isToday = client.isActiveToday;
    final dotColor = isToday ? const Color(0xFF22C55E) : AppStyle.textSecondary;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            color: dotColor,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: AppStyle.gapXS),
        Text(
          isToday ? 'Active today' : client.lastActive,
          style: AppStyle.captionStyle.copyWith(
            fontSize: 11,
            color: isToday ? const Color(0xFF22C55E) : AppStyle.textSecondary,
          ),
        ),
      ],
    );
  }
}
