import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class VoiceButton extends StatelessWidget {
  final bool isActive;
  final VoidCallback onTap;
  final IconData icon;
  final Color? color;
  final String tooltip;

  const VoiceButton({
    super.key,
    required this.isActive,
    required this.onTap,
    required this.icon,
    required this.tooltip,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeColor = color ?? theme.colorScheme.primary;

    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: isActive
                ? activeColor.withOpacity(0.15)
                : theme.colorScheme.surfaceVariant.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
            border: isActive
                ? Border.all(color: activeColor.withOpacity(0.4), width: 1.5)
                : null,
          ),
          child: Icon(
            icon,
            color: isActive ? activeColor : theme.colorScheme.onSurfaceVariant,
            size: 20,
          ),
        )
            .animate(target: isActive ? 1 : 0)
            .shimmer(duration: 1200.ms, color: activeColor.withOpacity(0.3)),
      ),
    );
  }
}
