import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/user.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_event.dart';
import '../../auth/bloc/auth_state.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  void _comingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('$feature is coming soon.')));
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final user = authState is AuthAuthenticated ? authState.user : null;

    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          const SizedBox(height: 16),
          Text('Profile', style: AppTextStyles.title),
          const SizedBox(height: 28),
          Stack(
            clipBehavior: Clip.none,
            children: [
              CircleAvatar(
                radius: 56,
                backgroundColor: AppColors.primary,
                child: Text(
                  _initials(user),
                  style: const TextStyle(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 32,
                  ),
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: GestureDetector(
                  onTap: () => _comingSoon(context, 'Changing your photo'),
                  child: Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: AppColors.secondary,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.white, width: 2),
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      color: AppColors.white,
                      size: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(user?.displayName ?? 'Guest', style: AppTextStyles.title),
          const SizedBox(height: 20),
          _ProfileMenuItem(
            icon: Icons.settings_outlined,
            label: 'Settings',
            onTap: () => _comingSoon(context, 'Settings'),
          ),
          _ProfileMenuItem(
            icon: Icons.people_alt_outlined,
            label: 'My Friends',
            onTap: () => _comingSoon(context, 'Friends'),
          ),
          _ProfileMenuItem(
            icon: Icons.favorite_border_rounded,
            label: 'My Favourite',
            onTap: () => _comingSoon(context, 'Favourites'),
          ),
          _ProfileMenuItem(
            icon: Icons.star_border_rounded,
            label: 'Latest Reviews',
            onTap: () => _comingSoon(context, 'Reviews'),
          ),
          _ProfileMenuItem(
            icon: Icons.rss_feed_rounded,
            label: 'Followers',
            onTap: () => _comingSoon(context, 'Followers'),
          ),
          const Spacer(),
          _ProfileMenuItem(
            icon: Icons.power_settings_new_rounded,
            label: 'Log Out',
            color: AppColors.critical,
            onTap: () => context.read<AuthBloc>().add(
              const AuthLogoutRequested(),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  String _initials(User? user) {
    if (user == null) return '?';
    final first = user.firstName?.isNotEmpty == true
        ? user.firstName![0]
        : user.username[0];
    final last = user.lastName?.isNotEmpty == true ? user.lastName![0] : '';
    return '$first$last'.toUpperCase();
  }
}

class _ProfileMenuItem extends StatelessWidget {
  const _ProfileMenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final tint = color ?? AppColors.onSurface;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 22, color: tint),
            const SizedBox(width: 16),
            Text(
              label,
              style: AppTextStyles.body.copyWith(
                fontWeight: FontWeight.w600,
                color: tint,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
