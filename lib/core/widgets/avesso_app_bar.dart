import 'package:flutter/material.dart';

import '../theme/app_text_styles.dart';

class AvessoAppBar extends StatelessWidget implements PreferredSizeWidget {
  const AvessoAppBar({
    super.key,
    this.title,
    this.showBackButton = true,
    this.actions,
  });

  final String? title;
  final bool showBackButton;
  final List<Widget>? actions;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: showBackButton,
      centerTitle: false,
      actions: actions,
      title: title != null
          ? Text(title!, style: AppTextStyles.titleLarge)
          : null,
    );
  }
}