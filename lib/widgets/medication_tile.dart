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
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: const BorderSide(color: Color(0xFF173C61)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0x22168DFF),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.medication_outlined,
                  color: MedixColors.cyan,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      medication.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 17,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      medication.subtitle,
                      style: const TextStyle(
                        color: MedixColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 7,
                      runSpacing: 7,
                      children: [
                        _InfoChip(
                          label: medication.requiresPrescription == true
                              ? 'Na recept'
                              : medication.requiresPrescription == false
                                  ? 'Bez recepta'
                                  : 'Režim izdavanja nije naveden',
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
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: isFavorite
                    ? 'Ukloni iz favorita'
                    : 'Dodaj u favorite',
                onPressed: onFavorite,
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
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
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0x22168DFF),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: MedixColors.cyan),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }
}
