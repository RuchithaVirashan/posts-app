import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../dashboard/view/dashboard_page.dart';
import '../../profile/view/profile_page.dart';
import '../widgets/app_bottom_nav_bar.dart';
import 'placeholder_page.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  void _goToProfile() => setState(() => _index = 4);

  @override
  Widget build(BuildContext context) {
    final pages = [
      DashboardPage(onProfileTap: _goToProfile),
      const PlaceholderPage(
        icon: Icons.star_border_rounded,
        title: 'Top Rate',
      ),
      const PlaceholderPage(icon: Icons.article_outlined, title: 'News'),
      const PlaceholderPage(
        icon: Icons.chat_bubble_outline_rounded,
        title: 'Chat',
      ),
      const ProfilePage(),
    ];

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
      ),
    );
  }
}
