import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/router/route_names.dart';
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

  void _handleLeading(BuildContext context) {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).maybePop();
    } else {
      // Rota aberta diretamente (deep link / refresh) sem histórico:
      // fallback seguro para a Home em vez de deixar o usuário preso.
      context.go(RouteNames.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final styles = AppTextStyles.of(context);
    final canPop = Navigator.of(context).canPop();

    return AppBar(
      automaticallyImplyLeading: false,
      leading: showBackButton
          ? IconButton(
              tooltip: canPop ? 'Voltar' : 'Início',
              icon: Icon(
                canPop ? Icons.arrow_back : Icons.home_outlined,
              ),
              onPressed: () => _handleLeading(context),
            )
          : null,
      centerTitle: false,
      actions: actions,
      title: title != null
          ? Text(title!, style: styles.titleLarge)
          : null,
    );
  }
}