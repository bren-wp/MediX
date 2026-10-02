import 'package:flutter/material.dart';

import '../../core/theme/medix_theme.dart';
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

  static const slides = <_OnboardingSlide>[
    _OnboardingSlide(
      title: 'Baza lijekova\nna jednom mjestu',
      subtitle:
          'Brza pretraga, detaljan pregled službenih podataka i jasan prikaz cijena i HZZO statusa.',
      icon: Icons.medication_rounded,
      secondaryIcon: Icons.search_rounded,
      color: MedixColors.cyan,
    ),
    _OnboardingSlide(
      title: 'Provjerite\ninterakcije lijekova',
      subtitle:
          'Usporedite terapiju i prepoznajte situacije koje zahtijevaju dodatnu stručnu provjeru.',
      icon: Icons.health_and_safety_rounded,
      secondaryIcon: Icons.hub_outlined,
      color: MedixColors.primary,
    ),
    _OnboardingSlide(
      title: 'Brinite o svom\nzdravlju',
      subtitle:
          'Spremite favorite, vodite terapiju, pratite raspored i koristite lokalne podsjetnike.',
      icon: Icons.calendar_month_rounded,
      secondaryIcon: Icons.notifications_active_outlined,
      color: MedixColors.warning,
    ),
  ];

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _complete() async {
    await widget.state.completeOnboarding();
  }

  void _next() {
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
                    const MedixBrand(compact: true),
                    const Spacer(),
                    TextButton(
                      onPressed: _complete,
                      child: const Text('Preskoči'),
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
                          page == slides.length - 1 ? 'Započni' : 'Dalje',
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(26, 30, 26, 18),
      child: Column(
        children: [
          Text(
            slide.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 29,
              fontWeight: FontWeight.w900,
              height: 1.1,
              letterSpacing: -.5,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            slide.subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: MedixColors.textSecondary,
              fontSize: 14,
              height: 1.45,
            ),
          ),
          const Spacer(),
          Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              color: MedixColors.surface,
              shape: BoxShape.circle,
              border: Border.all(
                color: slide.color.withValues(alpha: .55),
              ),
              boxShadow: [
                BoxShadow(
                  color: slide.color.withValues(alpha: .18),
                  blurRadius: 50,
                  spreadRadius: 8,
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  slide.icon,
                  size: 108,
                  color: slide.color,
                ),
                Positioned(
                  right: 34,
                  bottom: 38,
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: MedixColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: MedixColors.cyan.withValues(alpha: .55),
                      ),
                    ),
                    child: Icon(
                      slide.secondaryIcon,
                      size: 34,
                      color: MedixColors.cyan,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
        ],
      ),
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
