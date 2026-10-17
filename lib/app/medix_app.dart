import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../core/theme/medix_theme.dart';
import '../core/localization/medix_localizations.dart';
import '../data/medication_repository.dart';
import '../data/bundled_repository_loader.dart';
import '../features/home/app_shell.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../services/preferences_store.dart';
import '../services/notification_service.dart';
import '../state/medix_state.dart';
import '../widgets/medix_brand.dart';
import '../widgets/medix_page.dart';

class MedixApp extends StatefulWidget {
  const MedixApp({
    this.repositoryLoader,
    this.remindersFactory,
    super.key,
  });

  // Injectable for deterministic startup tests. Production uses the
  // verified offline catalog and native local-notification service.
  final Future<MedicationRepository> Function()? repositoryLoader;
  final TherapyReminderScheduler Function()? remindersFactory;

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
      // Never parse or cross-reference multi-megabyte medicine catalogs on
      // the Flutter UI isolate. Long synchronous work caused startup freezes.
      repository = await (widget.repositoryLoader ??
          loadBundledMedicineRepository)();
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
      // Never await the native notification plugin before showing the UI.
      // MedixState syncs existing alarms asynchronously after restore;
      // a slow or unavailable Android plugin must not delay startup.
      reminders = (widget.remindersFactory ??
          MedixNotificationService.new)();
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
    if (currentState == null) {
      return _materialApp(
        localeCode: MedixLanguages.primaryCode,
        home: _dataLoadFailed
            ? _DataLoadErrorScreen(onRetry: _retryLoad)
            : const _SplashScreen(),
      );
    }

    return AnimatedBuilder(
      animation: currentState,
      builder: (context, _) {
        return _materialApp(
          localeCode: currentState.localeCode,
          home: currentState.onboardingCompleted
              ? AppShell(state: currentState)
              : OnboardingScreen(state: currentState),
        );
      },
    );
  }

  Widget _materialApp({
    required String localeCode,
    required Widget home,
  }) {
    return MaterialApp(
      title: 'MediX',
      debugShowCheckedModeBanner: false,
      theme: MedixTheme.dark(),
      locale: Locale(MedixLanguages.normalize(localeCode)),
      supportedLocales: MedixLanguages.locales,
      localizationsDelegates: const [
        MedixLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: home,
    );
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    final loc = MedixLocalizations.of(context);
    return Scaffold(
      backgroundColor: MedixColors.background,
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: MedixColors.pageGradient,
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const MedixBrand(centered: true),
                  const SizedBox(height: 42),
                  const LinearProgressIndicator(
                    minHeight: 4,
                    borderRadius: BorderRadius.all(Radius.circular(999)),
                    color: MedixColors.cyan,
                    backgroundColor: MedixColors.surfaceElevated,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    loc.t('loading'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
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
    final loc = MedixLocalizations.of(context);
    return MedixPage(
      child: MedixEmptyState(
        icon: Icons.error_outline_rounded,
        title: loc.t('dataErrorTitle'),
        message: loc.t('dataErrorBody'),
        color: MedixColors.warning,
        actionLabel: loc.t('retry'),
        onAction: onRetry,
      ),
    );
  }
}
