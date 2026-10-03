import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/theme/medix_theme.dart';
import '../data/medication_repository.dart';
import '../features/home/app_shell.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../services/preferences_store.dart';
import '../services/notification_service.dart';
import '../state/medix_state.dart';
import '../widgets/medix_brand.dart';
import '../widgets/medix_page.dart';

class MedixApp extends StatefulWidget {
  const MedixApp({super.key});

  @override
  State<MedixApp> createState() => _MedixAppState();
}

class _MedixAppState extends State<MedixApp> {
  MedixState? state;
  bool _loading = false;
  bool _dataLoadFailed = false;

  @override
  void initState() {
    super.initState();
    _loadRepository();
  }

  Future<void> _loadRepository() async {
    if (_loading) return;
    _loading = true;

    late final MedicationRepository repository;
    try {
      final halmedRaw = await rootBundle.loadString(
        'assets/data/halmed_catalog.json',
      );
      final reimbursementRaw = await rootBundle.loadString(
        'assets/data/medications_official.json',
      );
      final priceRaw = await rootBundle.loadString(
        'assets/data/halmed_prices_2026.json',
      );
      repository = MedicationRepository.fromBundledCatalogs(
        halmedJson: halmedRaw,
        reimbursementJson: reimbursementRaw,
        priceJson: priceRaw,
      );
    } catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'MediX startup',
          context: ErrorDescription(
            'while loading verified medicine catalogs',
          ),
        ),
      );
      _loading = false;
      if (mounted) {
        setState(() {
          _dataLoadFailed = true;
        });
      }
      return;
    }

    TherapyReminderScheduler? reminders;
    try {
      final notificationService = MedixNotificationService();
      await notificationService.initialize();
      reminders = notificationService;
    } catch (_) {
      reminders = null;
    }

    final loadedState = MedixState(
      repository: repository,
      persistence: MedixPreferences(),
      reminders: reminders,
    );

    try {
      await loadedState.restore();
    } catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'MediX startup',
          context: ErrorDescription(
            'while restoring local user state',
          ),
        ),
      );
    }

    _loading = false;
    if (!mounted) {
      loadedState.dispose();
      return;
    }

    setState(() {
      state = loadedState;
      _dataLoadFailed = false;
    });
  }

  void _retryLoad() {
    if (_loading) return;
    setState(() {
      _dataLoadFailed = false;
    });
    _loadRepository();
  }

  @override
  void dispose() {
    state?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentState = state;

    return MaterialApp(
      title: 'MediX',
      debugShowCheckedModeBanner: false,
      theme: MedixTheme.dark(),
      home: currentState == null
          ? _dataLoadFailed
              ? _DataLoadErrorScreen(onRetry: _retryLoad)
              : const _SplashScreen()
          : AnimatedBuilder(
              animation: currentState,
              builder: (context, _) {
                if (!currentState.onboardingCompleted) {
                  return OnboardingScreen(state: currentState);
                }
                return AppShell(state: currentState);
              },
            ),
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


class _DataLoadErrorScreen extends StatelessWidget {
  const _DataLoadErrorScreen({
    required this.onRetry,
  });

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return MedixPage(
      child: MedixEmptyState(
        icon: Icons.error_outline_rounded,
        title: 'Službeni podaci nisu učitani',
        message:
            'MediX neće prikazati demo ili zamjenske lijekove. Provjerite instalaciju aplikacije i pokušajte ponovno učitati provjerene kataloge.',
        color: MedixColors.warning,
        actionLabel: 'Pokušaj ponovno',
        onAction: onRetry,
      ),
    );
  }
}
