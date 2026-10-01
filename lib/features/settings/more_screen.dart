import 'package:flutter/material.dart';

import '../../core/theme/medix_theme.dart';
import '../../widgets/medix_brand.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Više')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 6, 18, 30),
        children: const [
          MedixBrand(),
          SizedBox(height: 24),
          _SettingsCard(
            icon: Icons.language,
            title: 'Jezik',
            subtitle: 'Hrvatski',
          ),
          SizedBox(height: 10),
          _SettingsCard(
            icon: Icons.dark_mode_outlined,
            title: 'Izgled',
            subtitle: 'Tamna tema',
          ),
          SizedBox(height: 10),
          _SettingsCard(
            icon: Icons.shield_outlined,
            title: 'Privatnost',
            subtitle: 'Bez obveznog korisničkog računa',
          ),
          SizedBox(height: 10),
          _SettingsCard(
            icon: Icons.info_outline,
            title: 'O aplikaciji',
            subtitle: 'MediX 0.1.0 · razvojna verzija',
          ),
        ],
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Color(0xFF173C61)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 8,
        ),
        leading: Icon(icon, color: MedixColors.cyan),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(subtitle),
      ),
    );
  }
}
