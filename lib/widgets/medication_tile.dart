import 'package:flutter/material.dart';

import '../core/theme/medix_theme.dart';
import '../models/medication.dart';

class MedicationTile extends StatelessWidget {
  const MedicationTile({
    required this.medication,
    required this.isFavorite,
    required this.onTap,
    required this.onFavorite,
    super.key,
  });

  final Medication medication;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback onFavorite;

  @override
  Widget build(BuildContext context) {
    final subtitle = medication.compactSubtitle;
    final ingredient = medication.activeIngredient.trim();

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: Color(0xFF173C61)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(13, 12, 8, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0x22168DFF),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.medication_outlined,
                  size: 22,
                  color: MedixColors.cyan,
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      medication.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        height: 1.2,
                      ),
                    ),
                    if (ingredient.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        ingredient,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: MedixColors.textMuted,
                          fontSize: 11,
                        ),
                      ),
                    ],
                    if (subtitle != null) ...[
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: MedixColors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                    const SizedBox(height: 7),
                    Wrap(
                      spacing: 6,
                      runSpacing: 5,
                      children: [
                        _InfoChip(
                          label: medication.requiresPrescription == true
                              ? 'Na recept'
                              : medication.requiresPrescription == false
                                  ? 'Bez recepta'
                                  : 'Izdavanje: —',
                          icon: medication.requiresPrescription == true
                              ? Icons.description_outlined
                              : medication.requiresPrescription == false
                                  ? Icons.add_circle_outline
                                  : Icons.help_outline_rounded,
                        ),
                        _InfoChip(
                          label: medication.category,
                          icon: Icons.category_outlined,
                        ),
                        if ((medication.atcCode ?? '').isNotEmpty)
                          _InfoChip(
                            label: medication.atcCode!,
                            icon: Icons.tag_rounded,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: isFavorite
                    ? 'Ukloni iz favorita'
                    : 'Dodaj u favorite',
                visualDensity: VisualDensity.compact,
                onPressed: onFavorite,
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  size: 21,
                  color: isFavorite
                      ? MedixColors.danger
                      : MedixColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.label,
    required this.icon,
  });

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 180),
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0x22168DFF),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: MedixColors.cyan),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 10,
                height: 1.1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
