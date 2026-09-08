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

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;

  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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
    final error = await session.register(
      name: _nameController.text,
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
      appBar: AvessoAppBar(title: 'Criar conta'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Cadastre-se', style: styles.headlineSmall),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Crie sua conta para acessar eventos exclusivos.',
                  style: styles.bodyMedium,
                ),
                const SizedBox(height: AppSpacing.xl),
                AvessoTextField(
                  controller: _nameController,
                  label: 'Nome completo',
                  hint: 'Seu nome',
                  prefixIcon: Icons.person_outline,
                  textCapitalization: TextCapitalization.words,
                  validator: (value) => (value == null || value.isEmpty)
                      ? 'Informe seu nome'
                      : null,
                ),
                const SizedBox(height: AppSpacing.md),
                AvessoTextField(
                  controller: _emailController,
                  label: 'E-mail',
                  hint: 'voce@exemplo.com',
                  prefixIcon: Icons.mail_outline,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) => (value == null || !value.contains('@'))
                      ? 'E-mail inválido'
                      : null,
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
                  validator: (value) => (value == null || value.length < 6)
                      ? 'Mínimo de 6 caracteres'
                      : null,
                ),
                const SizedBox(height: AppSpacing.md),
                AvessoTextField(
                  controller: _confirmPasswordController,
                  label: 'Confirmar senha',
                  prefixIcon: Icons.lock_outline,
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Confirme sua senha';
                    }
                    if (value != _passwordController.text) {
                      return 'As senhas não conferem';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.xl),
                if (_error != null) ...[
                  Text(
                    _error!,
                    style: styles.bodyMedium.copyWith(color: colors.error),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                ],
                AvessoButton(
                  label: 'Criar conta',
                  loading: _loading,
                  onPressed: _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}