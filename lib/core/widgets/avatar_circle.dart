import 'package:flutter/material.dart';

class AvatarCircle extends StatelessWidget {
  final String? imageUrl;
  final String displayName;
  final double radius;
  final Color? backgroundColor;

  const AvatarCircle({
    super.key,
    this.imageUrl,
    required this.displayName,
    this.radius = 40,
    this.backgroundColor,
  });

  String get _initials {
    final parts = displayName.trim().split(' ');
    if (parts.isEmpty || parts[0].isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor = backgroundColor ?? theme.colorScheme.primaryContainer;

    return CircleAvatar(
      radius: radius,
      backgroundColor: bgColor,
      backgroundImage: imageUrl != null ? NetworkImage(imageUrl!) : null,
      onBackgroundImageError: imageUrl != null ? (e, s) {} : null,
      child: imageUrl == null
          ? Text(
              _initials,
              style: TextStyle(
                fontSize: radius * 0.6,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            )
          : null,
    );
  }
}
