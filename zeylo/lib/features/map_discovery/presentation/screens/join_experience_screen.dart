import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/custom_button.dart';

/// Screen for joining an experience with user preview.
/// On desktop (≥800 px): left info/participants panel + right map preview.
/// On mobile: stacked layout (map → participants list).
class JoinExperienceScreen extends StatefulWidget {
  final String experienceId;
  final String? title;

  const JoinExperienceScreen({
    required this.experienceId,
    this.title,
    super.key,
  });

  @override
  State<JoinExperienceScreen> createState() => _JoinExperienceScreenState();
}

class _JoinExperienceScreenState extends State<JoinExperienceScreen> {
  bool _joining = false;

  final participants = [
    {'name': 'Shenuka Dias', 'avatar': 'url1', 'role': 'Host'},
    {'name': 'Thenu Sandul', 'avatar': 'url2', 'role': 'Participant'},
    {'name': 'Menath Perera', 'avatar': 'url3', 'role': 'Participant'},
  ];

  Future<void> _joinExperience() async {
    setState(() => _joining = true);
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      setState(() => _joining = false);
      Navigator.pop(context);
    }
  }

  // ─────────────────────────── SHARED WIDGETS ──────────────────────────

  Widget _buildMapPreview({bool rounded = true}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE8F0FE),
        borderRadius: rounded ? BorderRadius.circular(AppRadius.lg) : null,
        border: rounded ? Border.all(color: AppColors.border) : null,
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Grid background
          ClipRRect(
            borderRadius:
                rounded ? BorderRadius.circular(AppRadius.lg) : BorderRadius.zero,
            child: CustomPaint(painter: _MapGridPainter()),
          ),
          // Experience location pin
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.4),
                        blurRadius: 20,
                        spreadRadius: 6,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.place_rounded,
                      color: Colors.white, size: 24),
                ),
                const SizedBox(height: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(100),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Text(
                    widget.title ?? 'Experience',
                    style: AppTypography.labelSmall
                        .copyWith(color: Colors.white, fontWeight: FontWeight.w700),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          // Map attribution-style label
          Positioned(
            bottom: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.85),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'Beira Lake, Colombo',
                style: AppTypography.labelSmall
                    .copyWith(color: AppColors.textSecondary),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParticipantTile(Map<String, String> participant,
      {bool compact = false}) {
    final isHost = participant['role'] == 'Host';
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: isHost
              ? AppColors.primary.withOpacity(0.25)
              : AppColors.border,
        ),
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          // Avatar
          Stack(
            children: [
              Container(
                width: compact ? 44 : 52,
                height: compact ? 44 : 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isHost
                        ? AppColors.primary.withOpacity(0.4)
                        : AppColors.border,
                    width: isHost ? 2 : 1.5,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  child: CachedNetworkImage(
                    imageUrl: participant['avatar'] ?? '',
                    fit: BoxFit.cover,
                    placeholder: (_, __) =>
                        Container(color: AppColors.surfaceContainer),
                    errorWidget: (_, __, ___) => Container(
                      color: const Color(0xFFE5E7EB),
                      child: const Icon(Icons.person, size: 22),
                    ),
                  ),
                ),
              ),
              if (isHost)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    child: const Icon(Icons.star_rounded,
                        color: Colors.white, size: 10),
                  ),
                ),
            ],
          ),
          const SizedBox(width: AppSpacing.md),
          // Name + role
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  participant['name'] ?? '',
                  style: AppTypography.titleMedium
                      .copyWith(fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isHost
                            ? AppColors.primary.withOpacity(0.1)
                            : AppColors.surfaceContainer,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        participant['role'] ?? 'Participant',
                        style: AppTypography.labelSmall.copyWith(
                          color: isHost
                              ? AppColors.primary
                              : AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Connect button
          if (!isHost)
            GestureDetector(
              onTap: () {},
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.primary, width: 1.5),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Text(
                  'Connect',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ─────────────────────────── DESKTOP BUILD ───────────────────────────

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        // ── Left: Experience info + participants ──
        Container(
          width: 400,
          decoration: const BoxDecoration(
            color: AppColors.background,
            border: Border(right: BorderSide(color: AppColors.border)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xxl, AppSpacing.xxl, AppSpacing.xxl, AppSpacing.lg),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: AppColors.border)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainer,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.arrow_back_rounded,
                                color: AppColors.textPrimary, size: 18),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Text(
                            'Join Experience',
                            style: AppTypography.headlineSmall
                                .copyWith(fontWeight: FontWeight.w800),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.xxl),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Experience info card
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primary.withOpacity(0.08),
                              AppColors.primaryLight.withOpacity(0.04),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: AppColors.primary.withOpacity(0.15)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(Icons.kayaking_rounded,
                                      color: AppColors.primary, size: 22),
                                ),
                                const SizedBox(width: AppSpacing.md),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.title ?? 'Sunset Kayaking',
                                        style: AppTypography.headlineSmall
                                            .copyWith(
                                                fontWeight: FontWeight.w700),
                                      ),
                                      Text(
                                        'Beira Lake, Colombo',
                                        style: AppTypography.bodySmall.copyWith(
                                            color: AppColors.textSecondary),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            // Quick stats
                            Row(
                              children: [
                                _buildQuickStat(
                                    Icons.schedule_rounded, '4:00 PM'),
                                const SizedBox(width: AppSpacing.md),
                                _buildQuickStat(
                                    Icons.timer_outlined, '2 hrs'),
                                const SizedBox(width: AppSpacing.md),
                                _buildQuickStat(
                                    Icons.people_rounded, '${participants.length} joined'),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      // Add profile link
                      GestureDetector(
                        onTap: () {},
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: AppColors.primary.withOpacity(0.2)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.add_circle_outline_rounded,
                                  color: AppColors.primary, size: 16),
                              const SizedBox(width: 6),
                              Text(
                                'Add Profile',
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      // Participants section
                      Row(
                        children: [
                          Text(
                            'Who\'s Joining',
                            style: AppTypography.titleMedium
                                .copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Text(
                              '${participants.length}',
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      ...participants.map(
                        (p) => Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.md),
                          child: _buildParticipantTile(p),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Join button
              Container(
                padding: const EdgeInsets.all(AppSpacing.xxl),
                decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: AppColors.border)),
                ),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ZeyloButton(
                        onPressed: _joining ? null : _joinExperience,
                        label: 'Join Experience',
                        isLoading: _joining,
                        variant: ButtonVariant.filled,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'You\'ll be visible to other participants once you join.',
                      style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textHint),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // ── Right: Full map ──
        Expanded(child: _buildMapPreview(rounded: false)),
      ],
    );
  }

  Widget _buildQuickStat(IconData icon, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.primary),
        const SizedBox(width: 4),
        Text(
          value,
          style: AppTypography.labelSmall.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // ─────────────────────────── MOBILE BUILD ────────────────────────────

  Widget _buildMobileLayout() {
    return Column(
      children: [
        // Map preview
        Container(
          height: 220,
          margin: const EdgeInsets.all(AppSpacing.lg),
          child: _buildMapPreview(),
        ),

        // Add profile
        Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: GestureDetector(
            onTap: () {},
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.add, color: AppColors.primary, size: 16),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  'Add Profile',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // Participants list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg, vertical: AppSpacing.md),
            itemCount: participants.length,
            itemBuilder: (context, i) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: _buildParticipantTile(participants[i], compact: true),
            ),
          ),
        ),

        // Join CTA
        Padding(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.lg),
          child: SizedBox(
            width: double.infinity,
            child: ZeyloButton(
              onPressed: _joining ? null : _joinExperience,
              label: 'Join Experience',
              isLoading: _joining,
              variant: ButtonVariant.filled,
            ),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────── MAIN BUILD ──────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 800;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: isDesktop
          ? null
          : AppBar(
              backgroundColor: AppColors.background,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                color: AppColors.textPrimary,
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(
                widget.title ?? 'Join Experience',
                style: AppTypography.titleMedium
                    .copyWith(fontWeight: FontWeight.w700),
              ),
            ),
      body: SafeArea(
        child: isDesktop ? _buildDesktopLayout() : _buildMobileLayout(),
      ),
    );
  }
}

/// Simple map grid background painter
class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = const Color(0xFFD0DCF5)
      ..strokeWidth = 1;

    const step = 40.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final roadPaint = Paint()
      ..color = Colors.white.withOpacity(0.9)
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(Offset(0, size.height * 0.45),
        Offset(size.width, size.height * 0.45), roadPaint);
    canvas.drawLine(Offset(size.width * 0.4, 0),
        Offset(size.width * 0.4, size.height), roadPaint);
    canvas.drawLine(Offset(size.width * 0.75, 0),
        Offset(size.width * 0.75, size.height), roadPaint);
    canvas.drawLine(Offset(0, size.height * 0.7),
        Offset(size.width, size.height * 0.7), roadPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
