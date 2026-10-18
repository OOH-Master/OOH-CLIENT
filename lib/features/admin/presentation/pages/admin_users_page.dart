import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_constants.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/sr_format.dart';
import '../../../../core/utils/sr_labels.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/ui/ui.dart';
import '../../data/repository/admin_user_repository.dart';
import '../blocs/admin_user_bloc.dart';
import '../widgets/user_edit_dialog.dart';

class AdminUsersPage extends StatelessWidget {
  const AdminUsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          AdminUserBloc(context.read<AdminUserRepository>())..add(LoadUsers()),
      child: const _AdminUsersView(),
    );
  }
}

/// Prikaz korisnika: naziv, uloga i status iz odgovora servera.
class _UserView {
  final Map<String, dynamic> user;

  const _UserView(this.user);

  String _s(String key) => (user[key] as String?)?.trim() ?? '';

  String get username => _s('username');
  String get email => _s('email');
  String get role => _s('role');
  String get place => SrLabels.place(_s('city'), _s('country'));
  bool get enabled => user['enabled'] as bool? ?? true;
  bool get emailVerified => user['emailVerified'] == true;

  String get person => '${_s('firstName')} ${_s('lastName')}'.trim();

  /// Kompanija, pa ime i prezime, pa korisničko ime.
  String get displayName {
    final company = _s('companyName');
    if (company.isNotEmpty) return company;
    if (person.isNotEmpty) return person;
    return username.isEmpty ? 'Korisnik #${user['id']}' : username;
  }

  bool get locked {
    final until = SrFormat.parseDate(user['accountLockedUntil']?.toString());
    return until != null && until.isAfter(DateTime.now());
  }

  String get created => SrFormat.date(user['createdAt']);

  static PillTone roleTone(String role) {
    switch (role.toUpperCase()) {
      case 'BRAND':
        return PillTone.primary;
      case 'AGENCY':
        return PillTone.violet;
      case 'MEDIA_OWNER':
        return PillTone.info;
      case 'INTERNAL_ADMIN':
        return PillTone.dark;
      default:
        return PillTone.neutral;
    }
  }
}

class _AdminUsersView extends StatefulWidget {
  const _AdminUsersView();

  @override
  State<_AdminUsersView> createState() => _AdminUsersViewState();
}

class _AdminUsersViewState extends State<_AdminUsersView> {
  String? _selectedRole;
  bool? _enabled;
  final _searchController = TextEditingController();

  /// Poslednja učitana lista; ostaje vidljiva dok se lista osvežava.
  List<Map<String, dynamic>>? _lastUsers;

  static const _roles = [
    null,
    'BRAND',
    'AGENCY',
    'MEDIA_OWNER',
    'INTERNAL_ADMIN',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _search() {
    context.read<AdminUserBloc>().add(LoadUsers(
          role: _selectedRole,
          enabled: _enabled,
          search: _searchController.text.trim(),
        ));
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 900;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: wide ? null : AppBar(title: const Text('Korisnici')),
      body: BlocConsumer<AdminUserBloc, AdminUserState>(
        listener: (context, state) {
          if (state is AdminUserActionSuccess) {
            AppSnackbar.show(context, state.message);
          } else if (state is AdminUserError) {
            AppSnackbar.show(context, state.message, isError: true);
          }
        },
        buildWhen: (previous, current) => current is! AdminUserActionSuccess,
        builder: (context, state) {
          if (state is AdminUsersLoaded) _lastUsers = state.users;
          final users = _lastUsers;
          final busy = state is AdminUserLoading || state is AdminUserInitial;

          return Stack(
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  final side = wide ? 32.0 : 16.0;
                  final gutter =
                      math.max(side, (constraints.maxWidth - 1240) / 2);
                  final width = constraints.maxWidth - 2 * gutter;
                  return ListView(
                    padding:
                        EdgeInsets.fromLTRB(gutter, wide ? 0 : 16, gutter, 40),
                    children: [
                      if (wide)
                        PageHeader(
                          title: 'Korisnici',
                          subtitle: _summary(users),
                          padding: const EdgeInsets.only(top: 28, bottom: 22),
                        ),
                      _buildToolbar(),
                      const SizedBox(height: 16),
                      _buildList(state, users, width),
                    ],
                  );
                },
              ),
              if (busy && users != null)
                const Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: LinearProgressIndicator(minHeight: 2),
                ),
            ],
          );
        },
      ),
    );
  }

  /// "12 korisnika, 10 aktivnih"; dok lista nije učitana nema podnaslova.
  String? _summary(List<Map<String, dynamic>>? users) {
    if (users == null) return null;
    final active = users.where((u) => _UserView(u).enabled).length;
    return '${SrFormat.count(users.length, 'korisnik', 'korisnika', 'korisnika')}'
        ', ${SrFormat.count(active, 'aktivan', 'aktivna', 'aktivnih')}';
  }

  Widget _buildList(
      AdminUserState state, List<Map<String, dynamic>>? users, double width) {
    if (users == null) {
      if (state is AdminUserError) {
        return SectionCard(
          child: EmptyState(
            icon: Icons.cloud_off_rounded,
            title: 'Korisnici trenutno nisu dostupni',
            message: state.message,
            action: OutlinedButton.icon(
              onPressed: _search,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Pokušaj ponovo'),
            ),
          ),
        );
      }
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 64),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (users.isEmpty) {
      return const SectionCard(
        child: EmptyState(
          icon: Icons.group_off_outlined,
          title: 'Nema korisnika za ovaj izbor',
          message: 'Promenite pretragu, ulogu ili status.',
        ),
      );
    }

    if (width >= 900) {
      return _UsersTable(
        users: users,
        onEdit: _showEditDialog,
        onToggle: _toggleEnabled,
      );
    }
    return Column(
      children: [
        for (final u in users)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _UserCard(
              user: u,
              onEdit: () => _showEditDialog(u),
              onToggle: () => _toggleEnabled(u),
            ),
          ),
      ],
    );
  }

  Widget _buildToolbar() {
    final search = TextField(
      controller: _searchController,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        isDense: true,
        hintText: 'Pretraži po imenu, korisničkom imenu ili emailu',
        prefixIcon: const Icon(Icons.search_rounded, size: 20),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
      onSubmitted: (_) => _search(),
    );

    final role = DropdownButtonFormField<String?>(
      initialValue: _selectedRole,
      isExpanded: true,
      decoration: const InputDecoration(
        isDense: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        prefixIcon: Icon(Icons.badge_outlined, size: 20),
      ),
      items: _roles
          .map((r) => DropdownMenuItem(
                value: r,
                child: Text(r == null ? 'Sve uloge' : SrLabels.role(r),
                    overflow: TextOverflow.ellipsis),
              ))
          .toList(),
      onChanged: (value) {
        setState(() => _selectedRole = value);
        _search();
      },
    );

    final status = _StatusSegments(
      value: _enabled,
      onChanged: (v) {
        setState(() => _enabled = v);
        _search();
      },
    );

    final button = FilledButton.icon(
      onPressed: _search,
      icon: const Icon(Icons.search_rounded, size: 18),
      label: const Text('Pretraži'),
    );

    return DecoratedBox(
      decoration: AppDecorations.card(),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth >= 980) {
              return Row(
                children: [
                  Expanded(flex: 5, child: search),
                  const SizedBox(width: 12),
                  SizedBox(width: 230, child: role),
                  const SizedBox(width: 12),
                  status,
                  const SizedBox(width: 12),
                  button,
                ],
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                search,
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: role),
                    const SizedBox(width: 10),
                    button,
                  ],
                ),
                const SizedBox(height: 10),
                Align(alignment: Alignment.centerLeft, child: status),
              ],
            );
          },
        ),
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

class _StatusSegments extends StatelessWidget {
  final bool? value;
  final ValueChanged<bool?> onChanged;

  const _StatusSegments({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    const options = <(bool?, String)>[
      (null, 'Svi'),
      (true, 'Aktivni'),
      (false, 'Deaktivirani'),
    ];
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.surfaceSunken,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final (key, label) in options)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onChanged(key),
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color:
                        value == key ? AppColors.surface : Colors.transparent,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Text(
                    label,
                    style: AppTypography.labelMedium.copyWith(
                      color:
                          value == key ? AppColors.foreground : AppColors.text2,
                      fontWeight:
                          value == key ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Uloga i status korisnika kao oznake.
class _UserPills extends StatelessWidget {
  final _UserView view;
  final bool withRole;

  const _UserPills(this.view, {this.withRole = true});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        if (withRole)
          StatusPill(
            label: SrLabels.role(view.role),
            tone: _UserView.roleTone(view.role),
            dot: false,
            dense: true,
          ),
        StatusPill(
          label: view.enabled ? 'Aktivan' : 'Deaktiviran',
          tone: view.enabled ? PillTone.success : PillTone.neutral,
          dense: true,
        ),
        if (view.locked)
          const StatusPill(label: 'Zaključan', dense: true),
      ],
    );
  }
}

class _EmailLine extends StatelessWidget {
  final _UserView view;

  const _EmailLine(this.view);

  @override
  Widget build(BuildContext context) {
    final handle = view.username.isEmpty ? '' : '@${view.username}';
    final text = [handle, view.email].where((s) => s.isNotEmpty).join(', ');
    return Row(
      children: [
        Flexible(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.caption
                .copyWith(color: AppColors.mutedForeground),
          ),
        ),
        if (view.email.isNotEmpty) ...[
          const SizedBox(width: 4),
          Tooltip(
            message:
                view.emailVerified ? 'Email potvrđen' : 'Email nije potvrđen',
            child: Icon(
              view.emailVerified
                  ? Icons.verified_rounded
                  : Icons.help_outline_rounded,
              size: 14,
              color: view.emailVerified ? AppColors.success : AppColors.subtle,
            ),
          ),
        ],
      ],
    );
  }
}

class _UserActions extends StatelessWidget {
  final _UserView view;
  final VoidCallback onEdit;
  final VoidCallback onToggle;

  const _UserActions(
      {required this.view, required this.onEdit, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.edit_outlined, size: 20),
          onPressed: onEdit,
          tooltip: 'Izmeni',
        ),
        Tooltip(
          message: view.enabled ? 'Deaktiviraj nalog' : 'Aktiviraj nalog',
          child: Switch(
            value: view.enabled,
            onChanged: (_) => onToggle(),
            activeThumbColor: Colors.white,
          ),
        ),
      ],
    );
  }
}

/// Tabela korisnika na širokom ekranu.
class _UsersTable extends StatelessWidget {
  final List<Map<String, dynamic>> users;
  final ValueChanged<Map<String, dynamic>> onEdit;
  final ValueChanged<Map<String, dynamic>> onToggle;

  const _UsersTable(
      {required this.users, required this.onEdit, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final head =
        AppTypography.labelSmall.copyWith(color: AppColors.mutedForeground);
    return DecoratedBox(
      decoration: AppDecorations.card(),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 11, 12, 11),
            decoration: const BoxDecoration(
              color: AppColors.surfaceSunken,
              borderRadius:
                  BorderRadius.vertical(top: Radius.circular(AppRadius.card)),
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              children: [
                Expanded(flex: 5, child: Text('Korisnik', style: head)),
                Expanded(flex: 3, child: Text('Uloga', style: head)),
                Expanded(flex: 3, child: Text('Mesto', style: head)),
                Expanded(flex: 3, child: Text('Status', style: head)),
                Expanded(flex: 2, child: Text('Registrovan', style: head)),
                const SizedBox(width: 104),
              ],
            ),
          ),
          for (var i = 0; i < users.length; i++) ...[
            if (i > 0) const Divider(height: 1, color: AppColors.borderSoft),
            _UserRow(
              user: users[i],
              onEdit: () => onEdit(users[i]),
              onToggle: () => onToggle(users[i]),
            ),
          ],
        ],
      ),
    );
  }
}

class _UserRow extends StatelessWidget {
  final Map<String, dynamic> user;
  final VoidCallback onEdit;
  final VoidCallback onToggle;

  const _UserRow(
      {required this.user, required this.onEdit, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final view = _UserView(user);
    return Opacity(
      opacity: view.enabled ? 1 : 0.72,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 12, 12),
        child: Row(
          children: [
            Expanded(
              flex: 5,
              child: Row(
                children: [
                  AppAvatar(name: view.displayName, size: 38),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          view.displayName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.labelLarge,
                        ),
                        _EmailLine(view),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 3,
              child: Align(
                alignment: Alignment.centerLeft,
                child: StatusPill(
                  label: SrLabels.role(view.role),
                  tone: _UserView.roleTone(view.role),
                  dot: false,
                  dense: true,
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(
                view.place.isEmpty ? '—' : view.place,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.bodySmall.copyWith(color: AppColors.text2),
              ),
            ),
            Expanded(flex: 3, child: _UserPills(view, withRole: false)),
            Expanded(
              flex: 2,
              child: Text(
                view.created,
                style: AppTypography.bodySmall
                    .copyWith(color: AppColors.mutedForeground),
              ),
            ),
            SizedBox(
              width: 104,
              child: Align(
                alignment: Alignment.centerRight,
                child: _UserActions(
                    view: view, onEdit: onEdit, onToggle: onToggle),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Kartica korisnika za uži ekran.
class _UserCard extends StatelessWidget {
  final Map<String, dynamic> user;
  final VoidCallback onEdit;
  final VoidCallback onToggle;

  const _UserCard(
      {required this.user, required this.onEdit, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final view = _UserView(user);
    return SectionCard(
      padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AppAvatar(name: view.displayName, size: 40),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(view.displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.labelLarge.copyWith(fontSize: 15)),
                    _EmailLine(view),
                  ],
                ),
              ),
              _UserActions(view: view, onEdit: onEdit, onToggle: onToggle),
            ],
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Row(
              children: [
                Expanded(child: _UserPills(view)),
                if (view.place.isNotEmpty)
                  Flexible(
                    child: Text(
                      view.place,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.right,
                      style: AppTypography.caption
                          .copyWith(color: AppColors.mutedForeground),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
