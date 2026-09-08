import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:avesso_x_go/app/router/route_names.dart';
import 'package:avesso_x_go/core/theme/app_colors.dart';
import 'package:avesso_x_go/core/theme/app_spacing.dart';
import 'package:avesso_x_go/core/theme/app_text_styles.dart';
import 'package:avesso_x_go/core/widgets/avesso_app_bar.dart';
import 'package:avesso_x_go/core/widgets/avesso_button.dart';
import 'package:avesso_x_go/core/widgets/avesso_text_field.dart';
import 'package:avesso_x_go/features/auth/application/session_scope.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    final session = SessionScope.of(context);
    final error = await session.login(
      email: _emailController.text,
      password: _passwordController.text,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _loading = false;
      _error = error;
    });

    if (error == null) {
      context.go(RouteNames.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final styles = AppTextStyles.of(context);

    return Scaffold(
      appBar: AvessoAppBar(title: 'Entrar', showBackButton: false),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Bem-vindo de volta', style: styles.headlineSmall),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Acesse sua conta para continuar.',
                  style: styles.bodyMedium,
                ),
                const SizedBox(height: AppSpacing.xl),
                AvessoTextField(
                  controller: _emailController,
                  label: 'E-mail',
                  hint: 'voce@exemplo.com',
                  prefixIcon: Icons.mail_outline,
                  keyboardType: TextInputType.emailAddress,
                  validator: _validateEmail,
                ),
                const SizedBox(height: AppSpacing.md),
                AvessoTextField(
                  controller: _passwordController,
                  label: 'Senha',
                  prefixIcon: Icons.lock_outline,
                  obscureText: _obscurePassword,
                  suffixIcon: IconButton(
                    tooltip: _obscurePassword
                        ? 'Mostrar senha'
                        : 'Ocultar senha',
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                    onPressed: () => setState(
                      () => _obscurePassword = !_obscurePassword,
                    ),
                  ),
                  validator: (value) => (value == null || value.isEmpty)
                      ? 'Informe sua senha'
                      : null,
                ),
                const SizedBox(height: AppSpacing.xs),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => context.push(RouteNames.forgotPassword),
                    child: const Text('Esqueci minha senha'),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                if (_error != null) ...[
                  Text(
                    _error!,
                    style: styles.bodyMedium.copyWith(color: colors.error),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                ],
                AvessoButton(
                  label: 'Entrar',
                  loading: _loading,
                  onPressed: _submit,
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Ainda não tem conta?',
                      style: styles.bodyMedium,
                    ),
                    TextButton(
                      onPressed: () => context.push(RouteNames.register),
                      child: const Text('Criar conta'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Informe seu e-mail';
    }
    if (!value.contains('@')) {
      return 'E-mail inválido';
    }
    return null;
  }
}