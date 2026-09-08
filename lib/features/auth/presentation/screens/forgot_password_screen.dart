import 'package:flutter/material.dart';

import 'package:avesso_x_go/core/theme/app_spacing.dart';
import 'package:avesso_x_go/core/theme/app_text_styles.dart';
import 'package:avesso_x_go/core/widgets/avesso_app_bar.dart';
import 'package:avesso_x_go/core/widgets/avesso_button.dart';
import 'package:avesso_x_go/core/widgets/avesso_text_field.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Link de recuperação enviado (ambiente de demonstração).',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final styles = AppTextStyles.of(context);

    return Scaffold(
      appBar: AvessoAppBar(title: 'Recuperar senha'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Esqueceu sua senha?',
                  style: styles.headlineSmall,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Informe seu e-mail e enviaremos um link para '
                  'redefinir sua senha.',
                  style: styles.bodyMedium,
                ),
                const SizedBox(height: AppSpacing.xl),
                AvessoTextField(
                  label: 'E-mail',
                  hint: 'voce@exemplo.com',
                  prefixIcon: Icons.mail_outline,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) => (value == null || !value.contains('@'))
                      ? 'E-mail inválido'
                      : null,
                ),
                const SizedBox(height: AppSpacing.xl),
                AvessoButton(
                  label: 'Enviar link',
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