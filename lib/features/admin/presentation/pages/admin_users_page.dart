import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/responsive/responsive_builder.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_constants.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../data/repository/admin_user_repository.dart';
import '../blocs/admin_user_bloc.dart';
import '../widgets/user_edit_dialog.dart';

class AdminUsersPage extends StatelessWidget {
  const AdminUsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AdminUserBloc(context.read<AdminUserRepository>())
        ..add(LoadUsers()),
      child: const _AdminUsersView(),
    );
  }
}

class _AdminUsersView extends StatefulWidget {
  const _AdminUsersView();

  @override
  State<_AdminUsersView> createState() => _AdminUsersViewState();
}

class _AdminUsersViewState extends State<_AdminUsersView> {
  String? _selectedRole;
  final _searchController = TextEditingController();

  static const _roles = [
    null,
    'BRAND',
    'AGENCY',
    'MEDIA_OWNER',
    'INTERNAL_ADMIN',
  ];

  static const _roleLabels = {
    null: 'Sve uloge',
    'BRAND': 'Brend',
    'AGENCY': 'Agencija',
    'MEDIA_OWNER': 'Vlasnik medija',
    'INTERNAL_ADMIN': 'Admin',
  };

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _search() {
    context.read<AdminUserBloc>().add(LoadUsers(
      role: _selectedRole,
      search: _searchController.text.trim(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = context.isDesktop;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Korisnici'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.foreground,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: Column(
        children: [
          // Filter bar
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: isDesktop
                ? Row(
                    children: [
                      Expanded(flex: 3, child: _buildSearchField()),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(flex: 2, child: _buildRoleDropdown()),
                      const SizedBox(width: AppSpacing.sm),
                      _buildSearchButton(),
                    ],
                  )
                : Column(
                    children: [
                      _buildSearchField(),
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        children: [
                          Expanded(child: _buildRoleDropdown()),
                          const SizedBox(width: AppSpacing.sm),
                          _buildSearchButton(),
                        ],
                      ),
                    ],
                  ),
          ),
          // User list
          Expanded(
            child: BlocConsumer<AdminUserBloc, AdminUserState>(
              listener: (context, state) {
                if (state is AdminUserActionSuccess) {
                  AppSnackbar.show(context, state.message);
                } else if (state is AdminUserError) {
                  AppSnackbar.show(context, state.message, isError: true);
                }
              },
              builder: (context, state) {
                if (state is AdminUserLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is AdminUsersLoaded) {
                  if (state.users.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.people_outline, size: 64, color: AppColors.mutedForeground),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            'Nema korisnika',
                            style: AppTypography.bodyLarge.copyWith(color: AppColors.mutedForeground),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    itemCount: state.users.length,
                    separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.xs),
                    itemBuilder: (context, index) {
                      final user = state.users[index];
                      return _UserTile(
                        user: user,
                        onEdit: () => _showEditDialog(user),
                        onToggleEnabled: () => _toggleEnabled(user),
                      );
                    },
                  );
                }

                if (state is AdminUserError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 48, color: AppColors.destructive),
                        const SizedBox(height: AppSpacing.md),
                        Text(state.message),
                        const SizedBox(height: AppSpacing.md),
                        ElevatedButton(
                          onPressed: _search,
                          child: const Text('Pokusaj ponovo'),
                        ),
                      ],
                    ),
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Pretrazi korisnike...',
        prefixIcon: const Icon(Icons.search),
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
      onSubmitted: (_) => _search(),
    );
  }

  Widget _buildRoleDropdown() {
    return DropdownButtonFormField<String?>(
      initialValue: _selectedRole,
      isExpanded: true,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
      items: _roles
          .map((role) => DropdownMenuItem(
                value: role,
                child: Text(_roleLabels[role] ?? 'Sve'),
              ))
          .toList(),
      onChanged: (value) {
        setState(() => _selectedRole = value);
        _search();
      },
    );
  }

  Widget _buildSearchButton() {
    return ElevatedButton.icon(
      onPressed: _search,
      icon: const Icon(Icons.search, size: 18),
      label: const Text('Pretrazi'),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.primaryForeground,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  void _showEditDialog(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (_) => UserEditDialog(
        user: user,
        onSave: (data) {
          final userId = user['id'] as int;
          context.read<AdminUserBloc>().add(UpdateUser(userId, data));
        },
      ),
    );
  }

  void _toggleEnabled(Map<String, dynamic> user) {
    final userId = user['id'] as int;
    final enabled = user['enabled'] as bool? ?? true;
    if (enabled) {
      context.read<AdminUserBloc>().add(DisableUser(userId));
    } else {
      context.read<AdminUserBloc>().add(EnableUser(userId));
    }
  }
}

class _UserTile extends StatelessWidget {
  final Map<String, dynamic> user;
  final VoidCallback onEdit;
  final VoidCallback onToggleEnabled;

  const _UserTile({
    required this.user,
    required this.onEdit,
    required this.onToggleEnabled,
  });

  @override
  Widget build(BuildContext context) {
    final username = user['username'] ?? '';
    final email = user['email'] ?? '';
    final role = user['role'] ?? '';
    final enabled = user['enabled'] as bool? ?? true;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: enabled ? AppColors.border : AppColors.destructive.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: enabled ? AppColors.primary : AppColors.mutedForeground,
            child: Text(
              username.isNotEmpty ? username[0].toUpperCase() : 'U',
              style: AppTypography.bodyMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xxs,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      username,
                      style: AppTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: enabled ? AppColors.foreground : AppColors.mutedForeground,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.secondary,
                        borderRadius: BorderRadius.circular(AppRadius.full),
                      ),
                      child: Text(
                        role,
                        style: AppTypography.labelSmall.copyWith(color: AppColors.primary),
                      ),
                    ),
                    if (!enabled)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.destructive.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(AppRadius.full),
                        ),
                        child: Text(
                          'Deaktiviran',
                          style: AppTypography.labelSmall.copyWith(color: AppColors.destructive),
                        ),
                      ),
                  ],
                ),
                Text(
                  email,
                  style: AppTypography.caption.copyWith(color: AppColors.mutedForeground),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 20),
            color: AppColors.primary,
            onPressed: onEdit,
            tooltip: 'Izmeni',
          ),
          Switch(
            value: enabled,
            onChanged: (_) => onToggleEnabled(),
            activeThumbColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}
