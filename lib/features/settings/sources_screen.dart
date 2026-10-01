import 'package:flutter/material.dart';

import '../../core/theme/medix_theme.dart';
import '../../data/official_sources.dart';
import '../../widgets/medix_page.dart';

class SourcesScreen extends StatelessWidget {
  const SourcesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MedixPage(
      appBar: AppBar(title: const Text('Službeni izvori podataka')),
      safeArea: false,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        itemCount: OfficialSources.all.length,
        separatorBuilder: (_, __) => const SizedBox(height: 9),
        itemBuilder: (context, index) {
          final source = OfficialSources.all[index];
          return MedixSectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const MedixIconBubble(
                      icon: Icons.verified_user_outlined,
                      color: MedixColors.success,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        source.name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  source.authority,
                  style: const TextStyle(
                    color: MedixColors.cyanSoft,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  source.purpose,
                  style: const TextStyle(
                    color: MedixColors.textSecondary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  source.url,
                  style: const TextStyle(
                    color: MedixColors.textMuted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
