import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:avesso_x_go/app/router/route_names.dart';
import 'package:avesso_x_go/core/widgets/avesso_app_bar.dart';
import 'package:avesso_x_go/core/widgets/avesso_empty_state.dart';

class TicketsScreen extends StatelessWidget {
  const TicketsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AvessoAppBar(title: 'Meus ingressos'),
      body: SafeArea(
        child: AvessoEmptyState(
          title: 'Nenhum ingresso ainda',
          message:
              'Quando você comprar ingressos, eles aparecerão aqui.',
          icon: Icons.confirmation_number_outlined,
          actionLabel: 'Explorar eventos',
          onAction: () => context.go(RouteNames.events),
        ),
      ),
    );
  }
}