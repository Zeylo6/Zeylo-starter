import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

/// Screen for an ongoing/live experience.
/// On desktop (≥800 px) shows a map view + info dashboard panel side by side.
/// On mobile keeps the bottom-sheet overlay over the map.
class LiveExperienceScreen extends StatefulWidget {
  final String experienceId;
  final String? title;
  final List<String>? participants;

  const LiveExperienceScreen({
    required this.experienceId,
    this.title = 'Sunset Kayaking',
    this.participants,
    super.key,
  });

  @override
  State<LiveExperienceScreen> createState() => _LiveExperienceScreenState();
}

class _LiveExperienceScreenState extends State<LiveExperienceScreen>
    with TickerProviderStateMixin {
  late Duration elapsedTime;
  Timer? _timer;
  late AnimationController _pulseController;
  late Animation<double> _pulseScale;

  @override
  void initState() {
    super.initState();
    elapsedTime = const Duration(hours: 2, minutes: 15);

    // Live tick every second
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => elapsedTime += const Duration(seconds: 1));
    });

    // LIVE badge pulse animation
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _pulseScale = Tween<double>(begin: 0.85, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  // ─────────────────────────── SHARED WIDGETS ──────────────────────────

  Widget _buildMapView() {
    return Container(
      color: const Color(0xFFE8F0FE),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Stylised map placeholder grid
          CustomPaint(painter: _MapGridPainter()),
          // Glowing location dot
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.45),
                        blurRadius: 16,
                        spreadRadius: 6,
                      ),
                    ],
                  ),
                  child:
                      const Icon(Icons.person_pin, color: Colors.white, size: 18),
                ),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    'You',
                    style: AppTypography.labelSmall.copyWith(
                        color: Colors.white, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveBadge() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ScaleTransition(
          scale: _pulseScale,
          child: Container(
            width: 10,
            height: 10,
            decoration: const BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          'LIVE',
          style: AppTypography.labelSmall.copyWith(
            color: Colors.red,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _buildParticipantsRow() {
    const count = 3;
    return Row(
      children: [
        SizedBox(
          height: 40,
          width: 144,
          child: Stack(
            children: [
              for (int i = 0; i < count; i++)
                Positioned(
                  left: i * 30.0,
                  child: _buildAvatar('avatar_$i'),
                ),
              Positioned(
                left: count * 30.0,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.surface,
                    border:
                        Border.all(color: AppColors.background, width: 2),
                  ),
                  child: Center(
                    child: Text('+2',
                        style: AppTypography.labelSmall
                            .copyWith(fontWeight: FontWeight.w700)),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Text(
          '${count + 2} participants',
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildAvatar(String url) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.background, width: 2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.full),
        child: CachedNetworkImage(
          imageUrl: url,
          fit: BoxFit.cover,
          placeholder: (_, __) => Container(color: AppColors.surfaceContainer),
          errorWidget: (_, __, ___) => Container(
            color: const Color(0xFFE5E7EB),
            child: const Icon(Icons.person, size: 20),
          ),
        ),
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String label, String value) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(height: 4),
          Text(value,
              style: AppTypography.titleMedium
                  .copyWith(fontWeight: FontWeight.w800)),
          Text(label,
              style: AppTypography.labelSmall
                  .copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  void _showEndDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('End Experience?'),
        content: const Text(
            'Are you sure you want to end this experience for all participants?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('End Experience'),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────── DESKTOP BUILD ───────────────────────────

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        // ── Left: Dashboard info panel ──
        Container(
          width: 360,
          decoration: const BoxDecoration(
            color: AppColors.background,
            border: Border(right: BorderSide(color: AppColors.border)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Panel header
              Container(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg, AppSpacing.xxl, AppSpacing.lg, AppSpacing.lg),
                decoration: const BoxDecoration(
                  border:
                      Border(bottom: BorderSide(color: AppColors.border)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _buildLiveBadge(),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.arrow_back_rounded,
                              color: AppColors.textSecondary),
                          onPressed: () => Navigator.pop(context),
                          tooltip: 'Back',
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      widget.title ?? 'Live Experience',
                      style: AppTypography.headlineMedium.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Stats row
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatChip(
                              Icons.schedule_rounded,
                              'Elapsed',
                              _formatDuration(elapsedTime),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: _buildStatChip(
                              Icons.people_rounded,
                              'Participants',
                              '${(widget.participants?.length ?? 5)}',
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: _buildStatChip(
                              Icons.location_on_rounded,
                              'Distance',
                              '3.2 km',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      // Participants
                      Text(
                        'Participants',
                        style: AppTypography.titleMedium.copyWith(
                            fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _buildParticipantsRow(),
                      const SizedBox(height: AppSpacing.xl),

                      // Activity log
                      Text(
                        'Activity',
                        style: AppTypography.titleMedium
                            .copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _buildActivityLog(),
                      const SizedBox(height: AppSpacing.xl),

                      // Experience info card
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: AppColors.primary.withOpacity(0.15)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.info_outline_rounded,
                                    size: 16, color: AppColors.primary),
                                const SizedBox(width: 6),
                                Text('Experience Info',
                                    style: AppTypography.labelMedium.copyWith(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w700)),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.md),
                            _buildInfoRow(Icons.event_rounded, 'Started',
                                'Today at 4:00 PM'),
                            const SizedBox(height: AppSpacing.sm),
                            _buildInfoRow(Icons.timer_outlined, 'Ends in',
                                '45 minutes'),
                            const SizedBox(height: AppSpacing.sm),
                            _buildInfoRow(
                                Icons.location_on_rounded,
                                'Location',
                                'Beira Lake, Colombo'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // End button
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: AppColors.border)),
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _showEndDialog,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: AppColors.error, width: 1.5),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.stop_circle_outlined,
                        color: AppColors.error, size: 20),
                    label: Text(
                      'End Experience',
                      style: AppTypography.labelLarge.copyWith(
                        color: AppColors.error,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // ── Right: Full map ──
        Expanded(child: _buildMapView()),
      ],
    );
  }

  Widget _buildActivityLog() {
    final events = [
      ('Alex joined the experience', '2m ago', Icons.person_add_rounded),
      ('Route checkpoint reached', '15m ago', Icons.flag_rounded),
      ('Experience started', '2h 15m ago', Icons.play_circle_rounded),
    ];

    return Column(
      children: events.map((e) {
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(e.$3, color: AppColors.primary, size: 15),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(e.$1,
                        style: AppTypography.bodySmall.copyWith(
                            fontWeight: FontWeight.w600)),
                    Text(e.$2,
                        style: AppTypography.labelSmall.copyWith(
                            color: AppColors.textHint)),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 15, color: AppColors.textHint),
        const SizedBox(width: 8),
        Text('$label: ',
            style: AppTypography.bodySmall
                .copyWith(color: AppColors.textSecondary)),
        Text(value,
            style: AppTypography.bodySmall
                .copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }

  // ─────────────────────────── MOBILE BUILD ────────────────────────────

  Widget _buildMobileLayout() {
    return Stack(
      children: [
        _buildMapView(),
        // Back button
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: const [
                          BoxShadow(color: Colors.black12, blurRadius: 8),
                        ],
                      ),
                      child: const Icon(Icons.arrow_back_rounded,
                          color: Colors.black87, size: 20),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  _buildLiveBadge(),
                ],
              ),
            ),
          ),
        ),
        // Bottom sheet
        _buildMobileBottomSheet(),
      ],
    );
  }

  Widget _buildMobileBottomSheet() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(AppRadius.xl),
            topRight: Radius.circular(AppRadius.xl),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 24,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        padding: EdgeInsets.only(
          left: AppSpacing.lg,
          right: AppSpacing.lg,
          top: AppSpacing.lg,
          bottom: MediaQuery.of(context).padding.bottom + AppSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 48,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              widget.title ?? 'Experience',
              style: AppTypography.headlineSmall
                  .copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Icon(Icons.schedule_rounded,
                    color: AppColors.primary, size: 18),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Ongoing • ${_formatDuration(elapsedTime)} elapsed',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            _buildParticipantsRow(),
            const SizedBox(height: AppSpacing.xl),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                onPressed: _showEndDialog,
                style: OutlinedButton.styleFrom(
                  side:
                      const BorderSide(color: AppColors.primary, width: 1.5),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.lg)),
                ),
                icon: const Icon(Icons.stop_circle_outlined,
                    color: AppColors.primary, size: 20),
                label: Text(
                  'End Experience',
                  style: AppTypography.labelLarge.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────── MAIN BUILD ──────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth >= 800) {
              return _buildDesktopLayout();
            }
            return _buildMobileLayout();
          },
        ),
      ),
    );
  }

  String _formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes % 60;
    final s = d.inSeconds % 60;
    if (h > 0) return '${h}h ${m}m';
    if (m > 0) return '${m}m ${s}s';
    return '${s}s';
  }
}

/// Simple map grid background painter
class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD0DCF5)
      ..strokeWidth = 1;

    const step = 40.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Draw some road-like paths
    final roadPaint = Paint()
      ..color = Colors.white.withOpacity(0.9)
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(Offset(0, size.height * 0.4),
        Offset(size.width, size.height * 0.4), roadPaint);
    canvas.drawLine(Offset(size.width * 0.35, 0),
        Offset(size.width * 0.35, size.height), roadPaint);
    canvas.drawLine(Offset(size.width * 0.7, 0),
        Offset(size.width * 0.7, size.height), roadPaint);
    canvas.drawLine(Offset(0, size.height * 0.7),
        Offset(size.width, size.height * 0.7), roadPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
