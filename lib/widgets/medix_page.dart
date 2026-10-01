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
