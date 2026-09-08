import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:avesso_x_go/app/app.dart';
import 'package:avesso_x_go/app/router/app_router.dart';
import 'package:avesso_x_go/app/theme/theme_controller.dart';
import 'package:avesso_x_go/app/theme/theme_mode_store.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('SharedPreferencesThemeModeStore', () {
    test('salva e carrega o modo', () async {
      final store = SharedPreferencesThemeModeStore();

      await store.save(ThemeMode.light);
      expect(await store.load(), ThemeMode.light);

      await store.save(ThemeMode.system);
      expect(await store.load(), ThemeMode.system);
    });

    test('retorna nulo quando não há preferência salva', () async {
      final store = SharedPreferencesThemeModeStore();
      expect(await store.load(), isNull);
    });
  });

  group('ThemeController', () {
    test('salva a preferência ao alternar o modo', () async {
      final store = SharedPreferencesThemeModeStore();
      final controller = ThemeController(store: store);

      await controller.setMode(ThemeMode.light);

      expect(controller.isLight, isTrue);
      expect(await store.load(), ThemeMode.light);

      await controller.setMode(ThemeMode.dark);
      expect(controller.isDark, isTrue);
      expect(await store.load(), ThemeMode.dark);

      controller.dispose();
    });

    test('carrega preferência salva anteriormente', () async {
      SharedPreferences.setMockInitialValues({
        SharedPreferencesThemeModeStore.storageKey: 'dark',
      });
      final store = SharedPreferencesThemeModeStore();
      final controller = ThemeController(
        store: store,
        initialMode: ThemeMode.light,
      );

      await controller.load();

      expect(controller.isDark, isTrue);

      controller.dispose();
    });

    test('mantém o padrão quando não há preferência salva', () async {
      final store = SharedPreferencesThemeModeStore();
      final controller = ThemeController(store: store);

      await controller.load();

      expect(controller.isDark, isTrue);

      controller.dispose();
    });
  });

  group('SettingsScreen — troca de tema', () {
    Future<ThemeController> buildApp(WidgetTester tester) async {
      final controller =
          ThemeController(store: SharedPreferencesThemeModeStore());
      await tester.pumpWidget(
        AvessoApp(router: AppRouter.create(), themeController: controller),
      );
      await tester.pumpAndSettle();
      return controller;
    }

    Future<void> openSettings(WidgetTester tester) async {
      await tester.tap(find.text('Perfil'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Configurações'));
      await tester.pumpAndSettle();
    }

    Brightness currentBrightness(WidgetTester tester) {
      return Theme.of(tester.element(find.text('Claro'))).brightness;
    }

    testWidgets('alterna para o tema claro', (tester) async {
      final controller = await buildApp(tester);
      await openSettings(tester);

      await tester.tap(find.text('Claro'));
      await tester.pumpAndSettle();

      expect(controller.isLight, isTrue);
      expect(currentBrightness(tester), Brightness.light);
      expect(
        (await SharedPreferences.getInstance())
            .getString(SharedPreferencesThemeModeStore.storageKey),
        'light',
      );
    });

    testWidgets('alterna para o tema escuro', (tester) async {
      final controller = await buildApp(tester);
      await openSettings(tester);

      await tester.tap(find.text('Claro'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Escuro'));
      await tester.pumpAndSettle();

      expect(controller.isDark, isTrue);
      expect(currentBrightness(tester), Brightness.dark);
      expect(
        (await SharedPreferences.getInstance())
            .getString(SharedPreferencesThemeModeStore.storageKey),
        'dark',
      );
    });

    testWidgets('alterna para o tema sistema', (tester) async {
      final controller = await buildApp(tester);
      await openSettings(tester);

      await tester.tap(find.text('Sistema'));
      await tester.pumpAndSettle();

      expect(controller.isSystem, isTrue);
      expect(
        (await SharedPreferences.getInstance())
            .getString(SharedPreferencesThemeModeStore.storageKey),
        'system',
      );
    });

    testWidgets('aplicação carrega a preferência salva ao abrir', (tester) async {
      SharedPreferences.setMockInitialValues({
        SharedPreferencesThemeModeStore.storageKey: 'light',
      });
      final controller =
          ThemeController(store: SharedPreferencesThemeModeStore());
      await controller.load();

      await tester.pumpWidget(
        AvessoApp(router: AppRouter.create(), themeController: controller),
      );
      await tester.pumpAndSettle();

      expect(Theme.of(tester.element(find.text('Eventos em destaque'))).brightness,
          Brightness.light);
    });
  });
}