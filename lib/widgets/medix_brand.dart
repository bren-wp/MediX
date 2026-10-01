import 'package:flutter/material.dart';

import '../core/theme/medix_theme.dart';

class MedixLogoMark extends StatelessWidget {
  const MedixLogoMark({
    super.key,
    this.size = 48,
  });

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * .28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF063250), Color(0xFF041422)],
        ),
        border: Border.all(
          color: MedixColors.cyan,
          width: size * .025,
        ),
        boxShadow: [
          BoxShadow(
            color: MedixColors.primary.withValues(alpha: .28),
            blurRadius: size * .36,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Transform.rotate(
            angle: -.72,
            child: Container(
              width: size * .48,
              height: size * .23,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(size),
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFF4FBFF),
                    Color(0xFF9FECFF),
                    Color(0xFF078AFF),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: MedixColors.cyan.withValues(alpha: .35),
                    blurRadius: size * .16,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            right: size * .14,
            bottom: size * .13,
            child: Container(
              width: size * .26,
              height: size * .26,
              decoration: BoxDecoration(
                color: MedixColors.primary,
                borderRadius: BorderRadius.circular(size * .07),
              ),
              child: Icon(
                Icons.add_rounded,
                color: Colors.white,
                size: size * .22,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MedixBrand extends StatelessWidget {
  const MedixBrand({
    super.key,
    this.compact = false,
    this.centered = false,
  });

  final bool compact;
  final bool centered;

  @override
  Widget build(BuildContext context) {
    final markSize = compact ? 38.0 : 52.0;
    final wordmark = Column(
      crossAxisAlignment:
          centered ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'MediX',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: compact ? 23 : 31,
            letterSpacing: -1.0,
            color: MedixColors.textPrimary,
          ),
        ),
        if (!compact)
          const Text(
            'VAŠ VODIČ KROZ LIJEKOVE',
            style: TextStyle(
              color: MedixColors.cyanSoft,
              fontSize: 8.5,
              letterSpacing: 2.0,
              fontWeight: FontWeight.w700,
            ),
          ),
      ],
    );

    if (centered) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          MedixLogoMark(size: markSize),
          const SizedBox(height: 12),
          wordmark,
        ],
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        MedixLogoMark(size: markSize),
        const SizedBox(width: 12),
        wordmark,
      ],
    );
  }
}
