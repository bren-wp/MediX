import 'package:flutter/material.dart';

import '../core/theme/medix_theme.dart';
import '../data/medication_repository.dart';
import '../features/home/app_shell.dart';
import '../state/medix_state.dart';

class MedixApp extends StatefulWidget {
  const MedixApp({super.key});

  @override
  State<MedixApp> createState() => _MedixAppState();
}

class _MedixAppState extends State<MedixApp> {
  late final MedixState state;

  @override
  void initState() {
    super.initState();
    state = MedixState(repository: MedicationRepository.demo());
  }

  @override
  void dispose() {
    state.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MediX',
      debugShowCheckedModeBanner: false,
      theme: MedixTheme.dark(),
      home: AppShell(state: state),
    );
  }
}
