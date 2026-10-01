import 'package:flutter/material.dart';

import '../core/theme/medix_theme.dart';

class MedixBrand extends StatelessWidget {
  const MedixBrand({
    super.key,
    this.compact = false,
  });

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final size = compact ? 38.0 : 48.0;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(compact ? 12 : 15),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [MedixColors.cyan, MedixColors.primary],
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x44168DFF),
                blurRadius: 18,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Icon(
            Icons.medication_rounded,
            color: Colors.white,
            size: compact ? 24 : 30,
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'MediX',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: compact ? 23 : 30,
                letterSpacing: -0.7,
              ),
            ),
            if (!compact)
              const Text(
                'VAŠ VODIČ KROZ LIJEKOVE',
                style: TextStyle(
                  color: MedixColors.textSecondary,
                  fontSize: 9,
                  letterSpacing: 1.8,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
      ],
    );
  }
}
