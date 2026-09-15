import 'package:flutter/material.dart';

import 'app/app.dart';
import 'app/theme/theme_controller.dart';
import 'app/theme/theme_mode_store.dart';
import 'core/supabase/supabase_service.dart';
import 'features/auth/application/auth_repository_factory.dart';
import 'features/auth/application/session_controller.dart';
import 'features/events/application/catalog_controller.dart';
import 'features/tickets/application/purchase_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SupabaseService.initialize();

  final themeController =
      ThemeController(store: SharedPreferencesThemeModeStore());
  await themeController.load();

  final sessionController = SessionController(
    repository: AuthRepositoryFactory().create(),
  );
  await sessionController.restore();

  final catalogController = CatalogController();
  await catalogController.load();

  final purchaseController = PurchaseController();
  await purchaseController.load();

  runApp(
    AvessoApp(
      themeController: themeController,
      sessionController: sessionController,
      catalogController: catalogController,
      purchaseController: purchaseController,
    ),
  );
}