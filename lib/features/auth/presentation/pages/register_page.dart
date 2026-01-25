import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/main_app_bar.dart';
import '../../../../core/theme/spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/role.dart';
import '../blocs/auth_bloc.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  Role _selectedRole = Role.brand;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onRegisterPressed() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
        RegisterSubmitted(
          name: _nameController.text,
          email: _emailController.text,
          password: _passwordController.text,
          role: _selectedRole,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: MainAppBar(showBackButton: true, showLoginButton: false),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthFailure) {
            AppSnackbar.show(context, state.message, isError: true);
          }
        },
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(Spacing.lg),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(Spacing.lg),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        l10n.authRegisterTitle,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: Spacing.xl),
                      AppTextField(
                        label: l10n.nameLabel,
                        controller: _nameController,
                        prefixIcon: Icons.person_outline,
                        validator: (value) => (value == null || value.isEmpty)
                          ? l10n.validatorRequired
                          : null,
                      ),
                      const SizedBox(height: Spacing.md),
                      AppTextField(
                        label: l10n.emailLabel,
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: Icons.email_outlined,
                        validator: (value) => (value == null || value.isEmpty)
                          ? l10n.validatorRequired
                          : null,
                      ),
                      const SizedBox(height: Spacing.md),
                      AppTextField(
                        label: l10n.passwordLabel,
                        controller: _passwordController,
                        obscureText: true,
                        prefixIcon: Icons.lock_outline,
                        validator: (value) => (value == null || value.isEmpty)
                          ? l10n.validatorRequired
                          : null,
                      ),
                      const SizedBox(height: Spacing.md),
                      DropdownButtonFormField<Role>(
                        value: _selectedRole,
                        decoration: InputDecoration(
                          labelText: l10n.roleLabel,
                          prefixIcon: const Icon(Icons.work_outline),
                        ),
                        items: Role.values.map((role) {
                          return DropdownMenuItem(
                            value: role,
                            child: Text(role.name),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedRole = value;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: Spacing.xl),
                      BlocBuilder<AuthBloc, AuthState>(
                        builder: (context, state) {
                          return PrimaryButton(
                            text: l10n.registerButton,
                            onPressed: _onRegisterPressed,
                            isLoading: state is AuthLoading,
                          );
                        },
                      ),
                      const SizedBox(height: Spacing.md),
                      SecondaryButton(
                        text: l10n.hasAccount,
                        onPressed: () => context.pop(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
