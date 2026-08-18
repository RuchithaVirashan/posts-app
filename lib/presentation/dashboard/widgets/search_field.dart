import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class SearchField extends StatelessWidget {
  const SearchField({super.key, required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: 'Search posts...',
        prefixIcon: const Icon(Icons.search, color: AppColors.secondary),
        suffixIcon: ValueListenableBuilder<TextEditingValue>(
          valueListenable: controller,
          builder: (context, value, _) {
            if (value.text.isEmpty) return const SizedBox.shrink();
            return IconButton(
              icon: const Icon(Icons.close, color: AppColors.secondary),
              onPressed: () {
                controller.clear();
                onChanged('');
              },
            );
          },
        ),
      ),
    );
  }
}
