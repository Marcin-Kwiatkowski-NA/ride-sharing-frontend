import 'package:flutter/material.dart';

class ProfileActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final Color? iconColor;
  final bool showChevron;

  const ProfileActionTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
    this.iconColor,
    this.showChevron = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (iconColor ?? theme.colorScheme.primary).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: iconColor ?? theme.colorScheme.primary),
      ),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      trailing: showChevron ? const Icon(Icons.chevron_right) : null,
      onTap: onTap,
    );
  }
}
