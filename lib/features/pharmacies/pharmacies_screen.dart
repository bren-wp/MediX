import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/medix_theme.dart';
import '../../widgets/medix_page.dart';

class PharmaciesScreen extends StatefulWidget {
  const PharmaciesScreen({super.key});

  @override
  State<PharmaciesScreen> createState() => _PharmaciesScreenState();
}

class _PharmaciesScreenState extends State<PharmaciesScreen> {
  static const _channel =
      MethodChannel('com.brendigo.medix/navigation');

  bool opening = false;

  Future<void> _openMap() async {
    if (opening) return;

    setState(() => opening = true);
    try {
      await _channel.invokeMethod<bool>('openNearbyPharmacies');
    } on PlatformException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Na ovom uređaju nije moguće otvoriti aplikaciju za karte.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => opening = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MedixPage(
      appBar: AppBar(title: const Text('Ljekarne u blizini')),
      safeArea: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        children: [
          MedixSectionCard(
            accent: MedixColors.success,
            child: Column(
              children: [
                const MedixIconBubble(
                  icon: Icons.local_pharmacy_outlined,
                  color: MedixColors.success,
                  size: 72,
                ),
                const SizedBox(height: 14),
                const Text(
                  'Pronađite ljekarne oko sebe',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'MediX otvara pretragu ljekarni u instaliranoj Android aplikaciji za karte. Lokaciju i aktualne podatke obrađuje odabrana aplikacija za karte.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: MedixColors.textSecondary,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: opening ? null : _openMap,
                    icon: opening
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.map_outlined),
                    label: Text(
                      opening
                          ? 'Otvaranje...'
                          : 'Otvori ljekarne na karti',
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const MedixSectionCard(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MedixIconBubble(
                  icon: Icons.info_outline_rounded,
                  color: MedixColors.cyan,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'MediX ne prikazuje izmišljena radna vremena ili dostupnost lijekova. Za radno vrijeme, rutu i druge lokacijske podatke provjerite rezultat u aplikaciji za karte.',
                    style: TextStyle(
                      color: MedixColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
