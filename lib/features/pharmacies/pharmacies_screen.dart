import 'package:flutter/material.dart';

import '../../core/theme/medix_theme.dart';
import '../../widgets/medix_page.dart';

class PharmaciesScreen extends StatelessWidget {
  const PharmaciesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MedixPage(
      appBar: AppBar(title: const Text('Ljekarne u blizini')),
      safeArea: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        children: [
          Container(
            height: 210,
            decoration: BoxDecoration(
              color: MedixColors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: MedixColors.border),
            ),
            alignment: Alignment.center,
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.map_outlined,
                  size: 54,
                  color: MedixColors.cyan,
                ),
                SizedBox(height: 10),
                Text(
                  'Karta ljekarni',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Lokacijski provider bit će spojen uz Android dozvolu lokacije.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: MedixColors.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          const MedixSectionCard(
            accent: MedixColors.warning,
            child: Text(
              'MediX ne izmišlja lokacije ili radna vremena. Prije produkcijskog uključivanja ovog modula potreban je pouzdan izvor ljekarni i aktualnih radnih vremena.',
              style: TextStyle(
                color: MedixColors.textSecondary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
