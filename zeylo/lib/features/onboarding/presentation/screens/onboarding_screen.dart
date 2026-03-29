import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/custom_button.dart';

/// Onboarding screen with carousel of 3 pages
///
/// Displays a PageView with onboarding pages and navigation buttons
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late PageController _pageController;
  int _currentPage = 0;

  final List<Map<String, String>> _pages = [
    {
      'kicker': 'LOCAL GEMS',
      'title': 'Welcome to Zeylo',
      'subtitle':
          'Discover curated experiences crafted by people who know every hidden corner of your city.',
      'statA': '2.4k+',
      'statALabel': 'experiences',
      'statB': '92%',
      'statBLabel': 'repeat explorers',
    },
    {
      'kicker': 'SMART DISCOVERY',
      'title': 'Find Your Next Story',
      'subtitle':
          'Move from searching to booking in minutes with recommendations that match your mood and schedule.',
      'statA': '15m',
      'statALabel': 'average to book',
      'statB': '180+',
      'statBLabel': 'new picks weekly',
    },
    {
      'kicker': 'COMMUNITY FIRST',
      'title': 'Connect Beyond The Plan',
      'subtitle':
          'Meet explorers with similar energy, collect memories together, and turn plans into traditions.',
      'statA': '34k+',
      'statALabel': 'community members',
      'statB': '4.9',
      'statBLabel': 'average rating',
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  void _goToPage(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
    );
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _goToPage(_currentPage - 1);
    }
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _goToPage(_currentPage + 1);
    } else {
      context.push('/login');
    }
  }

  IconData _visualIconForPage(int index) {
    if (index == 0) return Icons.explore_rounded;
    if (index == 1) return Icons.route_rounded;
    return Icons.groups_rounded;
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        const SizedBox(height: AppSpacing.xxl),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Zeylo',
              style: AppTypography.headlineLarge.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.6,
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Expanded(
          child: PageView(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            children: List.generate(_pages.length, (index) {
              final page = _pages[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF8B5CF6), Color(0xFF22D3EE)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: Icon(
                        _visualIconForPage(index),
                        size: 52,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    Text(
                      page['title']!,
                      textAlign: TextAlign.center,
                      style: AppTypography.displayMedium.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.8,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      page['subtitle']!,
                      textAlign: TextAlign.center,
                      style: AppTypography.bodyLarge.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _pages.length,
              (index) => Container(
                width: _currentPage == index ? 28 : 10,
                height: 10,
                margin: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  color: _currentPage == index
                      ? AppColors.primary
                      : AppColors.primaryLight.withOpacity(0.3),
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              ZeyloButton(
                onPressed: () => context.push('/signup'),
                label: 'Sign Up',
                variant: ButtonVariant.filled,
              ),
              const SizedBox(height: AppSpacing.md),
              ZeyloButton(
                onPressed: () => context.push('/login'),
                label: 'Log In',
                variant: ButtonVariant.outlined,
              ),
              const SizedBox(height: AppSpacing.md),
              TextButton(
                onPressed: _nextPage,
                child: Text(
                  _currentPage == _pages.length - 1 ? 'Continue' : 'Next',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopLayout() {
    final page = _pages[_currentPage];

    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF050816),
                Color(0xFF0A1331),
                Color(0xFF1B1243),
              ],
            ),
          ),
        ),
        const Positioned(
          top: -120,
          left: -60,
          child: _GlowOrb(
            size: 360,
            color: Color(0x665A8BFF),
          ),
        ),
        const Positioned(
          bottom: -180,
          right: -120,
          child: _GlowOrb(
            size: 460,
            color: Color(0x6653E2D2),
          ),
        ),
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1480),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 44, vertical: 34),
              child: Row(
                children: [
                  Expanded(
                    flex: 6,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 44),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _FrostBadge(text: page['kicker']!),
                          const SizedBox(height: 30),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 320),
                            switchInCurve: Curves.easeOut,
                            switchOutCurve: Curves.easeIn,
                            transitionBuilder: (child, animation) {
                              return FadeTransition(
                                opacity: animation,
                                child: SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(0.04, 0),
                                    end: Offset.zero,
                                  ).animate(animation),
                                  child: child,
                                ),
                              );
                            },
                            child: Column(
                              key: ValueKey<int>(_currentPage),
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  page['title']!,
                                  style: AppTypography.displayLarge.copyWith(
                                    fontSize: 66,
                                    height: 1.04,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -2,
                                  ),
                                ),
                                const SizedBox(height: 22),
                                ConstrainedBox(
                                  constraints:
                                      const BoxConstraints(maxWidth: 670),
                                  child: Text(
                                    page['subtitle']!,
                                    style: AppTypography.bodyLarge.copyWith(
                                      fontSize: 21,
                                      color: const Color(0xFFD0D8F0)
                                          .withOpacity(0.92),
                                      height: 1.55,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          Row(
                            children: [
                              _StatPill(
                                value: page['statA']!,
                                label: page['statALabel']!,
                              ),
                              const SizedBox(width: 16),
                              _StatPill(
                                value: page['statB']!,
                                label: page['statBLabel']!,
                              ),
                            ],
                          ),
                          const SizedBox(height: 28),
                          Row(
                            children: [
                              _TextIconButton(
                                onTap: _currentPage == 0 ? null : _previousPage,
                                icon: Icons.arrow_back_rounded,
                                label: 'Previous',
                              ),
                              const SizedBox(width: 10),
                              _TextIconButton(
                                onTap: _nextPage,
                                icon: Icons.arrow_forward_rounded,
                                label: _currentPage == _pages.length - 1
                                    ? 'Continue'
                                    : 'Next',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 5,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(34),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0x2EFFFFFF),
                                Color(0x16FFFFFF),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(34),
                            border: Border.all(
                              color: const Color(0x36FFFFFF),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(28),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: PageView.builder(
                                    controller: _pageController,
                                    onPageChanged: _onPageChanged,
                                    itemCount: _pages.length,
                                    itemBuilder: (context, index) {
                                      return _VisualStageCard(
                                        icon: _visualIconForPage(index),
                                        title: _pages[index]['title']!,
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Row(
                                  children:
                                      List.generate(_pages.length, (index) {
                                    return Expanded(
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(right: 8),
                                        child: _InteractiveProgressDot(
                                          active: _currentPage == index,
                                          onTap: () => _goToPage(index),
                                        ),
                                      ),
                                    );
                                  }),
                                ),
                                const SizedBox(height: 24),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _DesktopActionButton(
                                        label: 'Create Account',
                                        filled: true,
                                        onTap: () => context.push('/signup'),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _DesktopActionButton(
                                        label: 'Log In',
                                        filled: false,
                                        onTap: () => context.push('/login'),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth >= 980;
            if (isDesktop) {
              return _buildDesktopLayout();
            }
            return _buildMobileLayout();
          },
        ),
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          boxShadow: [
            BoxShadow(
              color: color,
              blurRadius: 160,
              spreadRadius: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class _FrostBadge extends StatelessWidget {
  const _FrostBadge({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0x2AFFFFFF),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: const Color(0x45FFFFFF)),
          ),
          child: Text(
            text,
            style: AppTypography.labelMedium.copyWith(
              color: Colors.white,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0x17FFFFFF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x3DFFFFFF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: AppTypography.headlineLarge.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            label,
            style: AppTypography.bodySmall.copyWith(
              color: const Color(0xC6D9ECFF),
            ),
          ),
        ],
      ),
    );
  }
}

class _TextIconButton extends StatefulWidget {
  const _TextIconButton({
    required this.onTap,
    required this.icon,
    required this.label,
  });

  final VoidCallback? onTap;
  final IconData icon;
  final String label;

  @override
  State<_TextIconButton> createState() => _TextIconButtonState();
}

class _TextIconButtonState extends State<_TextIconButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final disabled = widget.onTap == null;
    return MouseRegion(
      cursor: disabled ? SystemMouseCursors.basic : SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: disabled
                ? const Color(0x0AFFFFFF)
                : _hovered
                    ? const Color(0x22FFFFFF)
                    : const Color(0x17FFFFFF),
            border: Border.all(color: const Color(0x36FFFFFF)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                widget.label,
                style: AppTypography.titleMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VisualStageCard extends StatelessWidget {
  const _VisualStageCard({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1B255A),
            Color(0xFF2C145B),
            Color(0xFF0F3E62),
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(26),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                color: Colors.white.withOpacity(0.12),
              ),
              child: Icon(icon, size: 42, color: Colors.white),
            ),
            const Spacer(),
            Text(
              title,
              style: AppTypography.headlineMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'High-fidelity recommendations and real-time social planning in one polished flow.',
              style: AppTypography.bodyMedium.copyWith(
                color: const Color(0xE2D8E8FF),
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InteractiveProgressDot extends StatefulWidget {
  const _InteractiveProgressDot({
    required this.active,
    required this.onTap,
  });

  final bool active;
  final VoidCallback onTap;

  @override
  State<_InteractiveProgressDot> createState() =>
      _InteractiveProgressDotState();
}

class _InteractiveProgressDotState extends State<_InteractiveProgressDot> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final active = widget.active;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          height: 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            color: active
                ? Colors.white
                : _hovered
                    ? const Color(0xCCFFFFFF)
                    : const Color(0x62FFFFFF),
          ),
        ),
      ),
    );
  }
}

class _DesktopActionButton extends StatefulWidget {
  const _DesktopActionButton({
    required this.label,
    required this.onTap,
    required this.filled,
  });

  final String label;
  final VoidCallback onTap;
  final bool filled;

  @override
  State<_DesktopActionButton> createState() => _DesktopActionButtonState();
}

class _DesktopActionButtonState extends State<_DesktopActionButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedScale(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          scale: _hovered ? 1.015 : 1,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            height: 58,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: widget.filled
                  ? const LinearGradient(
                      colors: [Color(0xFF9C7BFF), Color(0xFF4CCBFF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: widget.filled
                  ? null
                  : _hovered
                      ? const Color(0x24FFFFFF)
                      : const Color(0x14FFFFFF),
              border: Border.all(
                color: widget.filled
                    ? Colors.transparent
                    : const Color(0x64FFFFFF),
              ),
              boxShadow: widget.filled
                  ? [
                      BoxShadow(
                        color: const Color(0xFF7A6BFF).withOpacity(0.45),
                        blurRadius: _hovered ? 22 : 14,
                        offset: const Offset(0, 8),
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: Text(
                widget.label,
                style: AppTypography.titleLarge.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
