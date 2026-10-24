import 'package:flutter/material.dart';

import '../../core/theme/medix_theme.dart';
import '../../core/localization/medix_localizations.dart';
import '../../state/medix_state.dart';
import '../../widgets/medix_brand.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({
    required this.state,
    super.key,
  });

  final MedixState state;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final controller = PageController();
  int page = 0;

  List<_OnboardingSlide> _slides(BuildContext context) {
    final loc = MedixLocalizations.of(context);
    return [
      _OnboardingSlide(
        title: loc.t('onboarding1Title'),
        subtitle: loc.t('onboarding1Body'),
        icon: Icons.medication_rounded,
        secondaryIcon: Icons.search_rounded,
        color: MedixColors.cyan,
      ),
      _OnboardingSlide(
        title: loc.t('onboarding2Title'),
        subtitle: loc.t('onboarding2Body'),
        icon: Icons.health_and_safety_rounded,
        secondaryIcon: Icons.hub_outlined,
        color: MedixColors.primary,
      ),
      _OnboardingSlide(
        title: loc.t('onboarding3Title'),
        subtitle: loc.t('onboarding3Body'),
        icon: Icons.calendar_month_rounded,
        secondaryIcon: Icons.notifications_active_outlined,
        color: MedixColors.warning,
      ),
    ];
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _complete() async {
    await widget.state.completeOnboarding();
  }

  void _next() {
    final slides = _slides(context);
    if (page == slides.length - 1) {
      _complete();
      return;
    }
    controller.nextPage(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = MedixLocalizations.of(context);
    final slides = _slides(context);
    return Scaffold(
      backgroundColor: MedixColors.background,
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: MedixColors.pageGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 14, 18, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: FittedBox(
                          alignment: Alignment.centerLeft,
                          fit: BoxFit.scaleDown,
                          child: const MedixBrand(compact: true),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: _complete,
                      child: Text(loc.t('skip')),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: controller,
                  itemCount: slides.length,
                  onPageChanged: (value) => setState(() => page = value),
                  itemBuilder: (context, index) =>
                      _SlideView(slide: slides[index]),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        slides.length,
                        (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: index == page ? 22 : 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: index == page
                                ? MedixColors.cyan
                                : MedixColors.surfaceBright,
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _next,
                        child: Text(
                          page == slides.length - 1
                              ? loc.t('start')
                              : loc.t('next'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SlideView extends StatelessWidget {
  const _SlideView({required this.slide});

  final _OnboardingSlide slide;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final largeText = MediaQuery.textScalerOf(context).scale(1) > 1.3;
        final compact = largeText || constraints.maxHeight < 550;
        final illustration = compact ? 150.0 : 214.0;
        // On small Android screens the title and image must scroll instead
        // of overflowing into the fixed onboarding action buttons.
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 18),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: (constraints.maxHeight - 36).clamp(0.0, double.infinity),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  slide.title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: compact ? 24 : 29,
                    fontWeight: FontWeight.w900,
                    height: 1.2,
                    letterSpacing: -.5,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  slide.subtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: MedixColors.textSecondary,
                    fontSize: 14,
                    height: 1.45,
                  ),
                ),
                SizedBox(height: compact ? 24 : 44),
                Container(
                  width: illustration,
                  height: illustration,
                  decoration: BoxDecoration(
                    color: MedixColors.surface,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: slide.color.withValues(alpha: .55),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: slide.color.withValues(alpha: .18),
                        blurRadius: 38,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(
                        slide.icon,
                        size: illustration * .49,
                        color: slide.color,
                      ),
                      Positioned(
                        right: illustration * .15,
                        bottom: illustration * .16,
                        child: Container(
                          width: illustration * .29,
                          height: illustration * .29,
                          decoration: BoxDecoration(
                            color: MedixColors.surfaceElevated,
                            borderRadius:
                                BorderRadius.circular(illustration * .09),
                            border: Border.all(
                              color: MedixColors.cyan.withValues(alpha: .55),
                            ),
                          ),
                          child: Icon(
                            slide.secondaryIcon,
                            size: illustration * .16,
                            color: MedixColors.cyan,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: compact ? 12 : 24),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _OnboardingSlide {
  const _OnboardingSlide({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.secondaryIcon,
    required this.color,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final IconData secondaryIcon;
  final Color color;
}
