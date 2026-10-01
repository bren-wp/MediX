import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/theme/medix_theme.dart';
import '../data/medication_repository.dart';
import '../features/home/app_shell.dart';
import '../state/medix_state.dart';
import '../widgets/medix_brand.dart';

class MedixApp extends StatefulWidget {
  const MedixApp({super.key});

  @override
  State<MedixApp> createState() => _MedixAppState();
}

class _MedixAppState extends State<MedixApp> {
  MedixState? state;

  @override
  void initState() {
    super.initState();
    _loadRepository();
  }

  Future<void> _loadRepository() async {
    MedicationRepository repository;

    try {
      final raw = await rootBundle.loadString(
        'assets/data/medications_official.json',
      );
      repository = MedicationRepository.fromOfficialJson(raw);
    } catch (_) {
      repository = MedicationRepository.demo();
    }

    if (!mounted) {
      return;
    }

    setState(() {
      state = MedixState(repository: repository);
    });
  }

  @override
  void dispose() {
    state?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MediX',
      debugShowCheckedModeBanner: false,
      theme: MedixTheme.dark(),
      home: state == null
          ? const _SplashScreen()
          : AppShell(state: state!),
    );
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MedixColors.background,
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: MedixColors.pageGradient,
        ),
        child: const SafeArea(
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(28),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  MedixBrand(centered: true),
                  SizedBox(height: 42),
                  LinearProgressIndicator(
                    minHeight: 4,
                    borderRadius: BorderRadius.all(Radius.circular(999)),
                    color: MedixColors.cyan,
                    backgroundColor: MedixColors.surfaceElevated,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Učitavanje provjerenih podataka o lijekovima…',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: MedixColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
