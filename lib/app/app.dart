import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/constants/app_constants.dart';
import '../core/theme/app_theme.dart';
import '../features/auth/application/session_controller.dart';
import '../features/auth/application/session_scope.dart';
import '../features/events/application/catalog_controller.dart';
import '../features/events/application/catalog_scope.dart';
import '../features/tickets/application/purchase_controller.dart';
import '../features/tickets/application/purchase_scope.dart';
import 'router/app_router.dart';
import 'theme/theme_controller.dart';
import 'theme/theme_mode_store.dart';
import 'theme/theme_scope.dart';

class AvessoApp extends StatefulWidget {
  const AvessoApp({
    super.key,
    this.router,
    this.themeController,
    this.sessionController,
    this.catalogController,
    this.purchaseController,
  });

  final GoRouter? router;
  final ThemeController? themeController;
  final SessionController? sessionController;
  final CatalogController? catalogController;
  final PurchaseController? purchaseController;

  @override
  State<AvessoApp> createState() => _AvessoAppState();
}

class _AvessoAppState extends State<AvessoApp> {
  late final ThemeController _themeController;
  late final SessionController _sessionController;
  late final CatalogController _catalogController;
  late final PurchaseController _purchaseController;

  @override
  void initState() {
    super.initState();
    _themeController = widget.themeController ??
        ThemeController(store: SharedPreferencesThemeModeStore());
    _sessionController =
        widget.sessionController ?? SessionController();
    _catalogController =
        widget.catalogController ?? CatalogController();
    _purchaseController =
        widget.purchaseController ?? PurchaseController();

    _themeController.load();
    if (widget.sessionController == null) {
      _sessionController.restore();
    }
    if (widget.catalogController == null) {
      _catalogController.load();
    }
    if (widget.purchaseController == null) {
      _purchaseController.load();
    }
  }

  @override
  void dispose() {
    if (widget.themeController == null) {
      _themeController.dispose();
    }
    if (widget.sessionController == null) {
      _sessionController.dispose();
    }
    if (widget.catalogController == null) {
      _catalogController.dispose();
    }
    if (widget.purchaseController == null) {
      _purchaseController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ThemeScope(
      controller: _themeController,
      child: SessionScope(
        controller: _sessionController,
        child: CatalogScope(
          controller: _catalogController,
          child: PurchaseScope(
            controller: _purchaseController,
            child: ListenableBuilder(
              listenable: _themeController,
              builder: (context, _) {
                return MaterialApp.router(
                  title: AppConstants.appName,
                  debugShowCheckedModeBanner: false,
                  theme: AppTheme.light,
                  darkTheme: AppTheme.dark,
                  themeMode: _themeController.mode,
                  routerConfig: widget.router ?? AppRouter.router,
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}