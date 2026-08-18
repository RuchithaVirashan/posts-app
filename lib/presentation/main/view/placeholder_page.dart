import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class PlaceholderPage extends StatelessWidget {
  const PlaceholderPage({super.key, required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: AppColors.secondary),
            const SizedBox(height: 16),
            Text(title, style: AppTextStyles.headline),
            const SizedBox(height: 8),
            const Text('Coming soon', style: AppTextStyles.bodySecondary),
          ],
        ),
      ),
    );
  }
}
