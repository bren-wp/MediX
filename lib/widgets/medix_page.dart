import 'package:flutter/material.dart';

import '../core/theme/medix_theme.dart';

class MedixPage extends StatelessWidget {
  const MedixPage({
    required this.child,
    super.key,
    this.appBar,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.safeArea = true,
  });

  final PreferredSizeWidget? appBar;
  final Widget child;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final bool safeArea;

  @override
  Widget build(BuildContext context) {
    final body = DecoratedBox(
      decoration: const BoxDecoration(
        gradient: MedixColors.pageGradient,
      ),
      child: SizedBox.expand(
        child: safeArea ? SafeArea(child: child) : child,
      ),
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: appBar,
      body: body,
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
    );
  }
}

class MedixSectionCard extends StatelessWidget {
  const MedixSectionCard({
    required this.child,
    super.key,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.accent,
  });

  final Widget child;
  final EdgeInsets padding;
  final VoidCallback? onTap;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final card = Container(
      decoration: BoxDecoration(
        color: MedixColors.surface,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: accent?.withValues(alpha: .65) ?? MedixColors.borderSoft,
        ),
        boxShadow: [
          BoxShadow(
            color: (accent ?? MedixColors.primary).withValues(alpha: .05),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: padding,
        child: child,
      ),
    );

    if (onTap == null) {
      return card;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(17),
        child: card,
      ),
    );
  }
}

class MedixIconBubble extends StatelessWidget {
  const MedixIconBubble({
    required this.icon,
    super.key,
    this.color = MedixColors.primary,
    this.size = 42,
  });

  final IconData icon;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: .16),
        borderRadius: BorderRadius.circular(size * .3),
        border: Border.all(color: color.withValues(alpha: .32)),
      ),
      alignment: Alignment.center,
      child: Icon(icon, color: color, size: size * .56),
    );
  }
}


class MedixEmptyState extends StatelessWidget {
  const MedixEmptyState({
    required this.icon,
    required this.title,
    required this.message,
    super.key,
    this.color = MedixColors.cyan,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final Color color;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              MedixIconBubble(
                icon: icon,
                color: color,
                size: 76,
              ),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: MedixColors.textSecondary,
                  height: 1.45,
                ),
              ),
              if (actionLabel != null && onAction != null) ...[
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: onAction,
                  icon: const Icon(Icons.restart_alt_rounded),
                  label: Text(actionLabel!),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
