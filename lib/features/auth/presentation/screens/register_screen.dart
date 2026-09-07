import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:avesso_x_go/app/router/route_names.dart';
import 'package:avesso_x_go/core/theme/app_spacing.dart';
import 'package:avesso_x_go/core/theme/app_text_styles.dart';
import 'package:avesso_x_go/core/widgets/avesso_app_bar.dart';
import 'package:avesso_x_go/core/widgets/avesso_button.dart';
import 'package:avesso_x_go/core/widgets/avesso_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      context.go(RouteNames.home);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                Text('Cadastre-se', style: AppTextStyles.headlineSmall),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Crie sua conta para acessar eventos exclusivos.',
                  style: AppTextStyles.bodyMedium,
                ),
                const SizedBox(height: AppSpacing.xl),
                AvessoTextField(
                  label: 'Nome completo',
                  hint: 'Seu nome',
                  prefixIcon: Icons.person_outline,
                  validator: (value) => (value == null || value.isEmpty)
                      ? 'Informe seu nome'
                      : null,
                ),
                const SizedBox(height: AppSpacing.md),
                AvessoTextField(
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
                  label: 'Confirmar senha',
                  prefixIcon: Icons.lock_outline,
                  obscureText: true,
                  validator: (value) => (value == null || value.isEmpty)
                      ? 'Confirme sua senha'
                      : null,
                ),
                const SizedBox(height: AppSpacing.xl),
                AvessoButton(
                  label: 'Criar conta',
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