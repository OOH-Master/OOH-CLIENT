import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/l10n/locale_cubit.dart';
import '../../../../core/responsive/responsive_builder.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_constants.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../auth/domain/entities/role.dart';
import '../../../auth/presentation/blocs/auth_bloc.dart';
import '../blocs/shell_cubit.dart';

class MainShellPage extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainShellPage({super.key, required this.navigationShell});

  void _goBranch(int index, BuildContext context) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
    context.read<ShellCubit>().setIndex(index);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocProvider(
      create: (_) => ShellCubit(),
      child: BlocBuilder<ShellCubit, ShellState>(
        builder: (context, shellState) {
          if (context.isDesktop) {
            return _buildDesktopLayout(context, l10n, shellState);
          }
          return _buildMobileLayout(context, l10n);
        },
      ),
    );
  }

  // ─── Mobile Layout ───────────────────────────────────────────────────

  Widget _buildMobileLayout(BuildContext context, AppLocalizations l10n) {
    return Scaffold(
      drawer: _buildDrawer(context, l10n),
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.dashboard_outlined),
            selectedIcon: const Icon(Icons.dashboard),
            label: l10n.dashboardTab,
          ),
          NavigationDestination(
            icon: const Icon(Icons.inventory_2_outlined),
            selectedIcon: const Icon(Icons.inventory_2),
            label: l10n.discoverTab,
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline),
            selectedIcon: const Icon(Icons.person),
            label: l10n.profileTab,
          ),
        ],
        onDestinationSelected: (index) => _goBranch(index, context),
      ),
    );
  }

  // ─── Desktop Layout ──────────────────────────────────────────────────

  Widget _buildDesktopLayout(
    BuildContext context,
    AppLocalizations l10n,
    ShellState shellState,
  ) {
    final expanded = shellState.sidebarExpanded;

    return Scaffold(
      body: Row(
        children: [
          _DesktopSidebar(
            expanded: expanded,
            currentIndex: navigationShell.currentIndex,
            onBranch: (i) => _goBranch(i, context),
            onToggle: () => context.read<ShellCubit>().toggleSidebar(),
          ),
          Expanded(child: navigationShell),
        ],
      ),
    );
  }

  // ─── Drawer (mobile only) ────────────────────────────────────────────

  Widget _buildDrawer(BuildContext context, AppLocalizations l10n) {
    return Drawer(
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          String name = 'User';
          String email = '';
          Role? role;
          if (authState is AuthAuthenticated) {
            name = authState.user.name;
            email = authState.user.email;
            role = authState.user.role;
          }

          return ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(color: AppColors.primary),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Text(
                        name.isNotEmpty ? name[0].toUpperCase() : 'U',
                        style: AppTypography.h3.copyWith(color: AppColors.primary),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(email, style: const TextStyle(color: Colors.white70)),
                    if (role != null)
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          role.name,
                          style: const TextStyle(color: Colors.white, fontSize: 11),
                        ),
                      ),
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(Icons.dashboard),
                title: Text(l10n.dashboardTab),
                selected: navigationShell.currentIndex == 0,
                onTap: () {
                  _goBranch(0, context);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.inventory_2),
                title: Text(l10n.discoverTab),
                selected: navigationShell.currentIndex == 1,
                onTap: () {
                  _goBranch(1, context);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.person),
                title: Text(l10n.profileTab),
                selected: navigationShell.currentIndex == 2,
                onTap: () {
                  _goBranch(2, context);
                  Navigator.pop(context);
                },
              ),
              const Divider(),
              ..._buildRoleLinks(context, l10n, role),
              const Divider(),
              ListTile(
                leading: Icon(Icons.logout, color: AppColors.destructive),
                title: Text(l10n.logout, style: TextStyle(color: AppColors.destructive)),
                onTap: () {
                  context.read<AuthBloc>().add(LogoutRequested());
                  Navigator.pop(context);
                },
              ),
              BlocBuilder<LocaleCubit, Locale>(
                builder: (context, locale) {
                  return ListTile(
                    leading: const Icon(Icons.language),
                    title: Text(locale.languageCode == 'sr' ? 'English' : 'Srpski'),
                    trailing: Text(
                      locale.languageCode.toUpperCase(),
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.mutedForeground,
                      ),
                    ),
                    onTap: () {
                      context.read<LocaleCubit>().toggle();
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  List<Widget> _buildRoleLinks(BuildContext context, AppLocalizations l10n, Role? role) {
    if (role == null) return [];

    switch (role) {
      case Role.admin:
        return [
          ListTile(
            leading: const Icon(Icons.admin_panel_settings_outlined),
            title: const Text('Upravljanje upitima'),
            onTap: () {
              Navigator.pop(context);
              context.push('/app/admin/inquiries');
            },
          ),
          ListTile(
            leading: const Icon(Icons.mail_outline),
            title: Text(l10n.allInquiries),
            onTap: () {
              Navigator.pop(context);
              context.push('/app/inquiries');
            },
          ),
          ListTile(
            leading: const Icon(Icons.people_outline),
            title: const Text('Korisnici'),
            onTap: () {
              Navigator.pop(context);
              context.push('/app/admin/users');
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: Text(l10n.configuration),
            onTap: () {
              Navigator.pop(context);
              context.push('/app/admin/config');
            },
          ),
        ];
      case Role.mediaOwner:
        return [
          ListTile(
            leading: const Icon(Icons.inventory),
            title: Text(l10n.myInventory),
            onTap: () {
              Navigator.pop(context);
              context.push('/app/my-inventory');
            },
          ),
          ListTile(
            leading: const Icon(Icons.add_circle_outline),
            title: Text(l10n.addInventory),
            onTap: () {
              Navigator.pop(context);
              context.push('/app/inventory/create');
            },
          ),
          ListTile(
            leading: const Icon(Icons.request_quote_outlined),
            title: const Text('Zahtevi za ponude'),
            onTap: () {
              Navigator.pop(context);
              context.push('/app/media-owner/quotes');
            },
          ),
          ListTile(
            leading: const Icon(Icons.event_available_outlined),
            title: const Text('Dostupnost'),
            onTap: () {
              Navigator.pop(context);
              context.push('/app/media-owner/availability');
            },
          ),
        ];
      case Role.brand:
        return [
          ListTile(
            leading: const Icon(Icons.mail_outline),
            title: Text(l10n.myInquiries),
            onTap: () {
              Navigator.pop(context);
              context.push('/app/inquiries');
            },
          ),
          ListTile(
            leading: const Icon(Icons.campaign_outlined),
            title: Text(l10n.campaigns),
            onTap: () {
              Navigator.pop(context);
              context.push('/app/campaigns');
            },
          ),
        ];
      case Role.agency:
        return [
          ListTile(
            leading: const Icon(Icons.business),
            title: Text(l10n.myBrands),
            onTap: () {
              Navigator.pop(context);
              context.push('/app/agency/brands');
            },
          ),
          ListTile(
            leading: const Icon(Icons.mail_outline),
            title: Text(l10n.myInquiries),
            onTap: () {
              Navigator.pop(context);
              context.push('/app/inquiries');
            },
          ),
          ListTile(
            leading: const Icon(Icons.campaign_outlined),
            title: Text(l10n.campaigns),
            onTap: () {
              Navigator.pop(context);
              context.push('/app/campaigns');
            },
          ),
        ];
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════
// Desktop Sidebar Widget
// ═══════════════════════════════════════════════════════════════════════

class _DesktopSidebar extends StatelessWidget {
  final bool expanded;
  final int currentIndex;
  final ValueChanged<int> onBranch;
  final VoidCallback onToggle;

  static const double _expandedWidth = 260;
  static const double _collapsedWidth = 72;

  const _DesktopSidebar({
    required this.expanded,
    required this.currentIndex,
    required this.onBranch,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        String name = 'User';
        String email = '';
        Role? role;
        if (authState is AuthAuthenticated) {
          name = authState.user.name;
          email = authState.user.email;
          role = authState.user.role;
        }

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          width: expanded ? _expandedWidth : _collapsedWidth,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              right: BorderSide(color: AppColors.border),
            ),
          ),
          child: Column(
            children: [
              // ── User header ──
              _buildHeader(name, email, role),
              const SizedBox(height: AppSpacing.xs),

              // ── Main nav items ──
              _SidebarItem(
                icon: Icons.dashboard_outlined,
                selectedIcon: Icons.dashboard,
                label: l10n.dashboardTab,
                selected: currentIndex == 0,
                expanded: expanded,
                onTap: () => onBranch(0),
              ),
              _SidebarItem(
                icon: Icons.inventory_2_outlined,
                selectedIcon: Icons.inventory_2,
                label: l10n.discoverTab,
                selected: currentIndex == 1,
                expanded: expanded,
                onTap: () => onBranch(1),
              ),
              _SidebarItem(
                icon: Icons.person_outline,
                selectedIcon: Icons.person,
                label: l10n.profileTab,
                selected: currentIndex == 2,
                expanded: expanded,
                onTap: () => onBranch(2),
              ),

              // ── Role-specific links ──
              ..._buildSidebarRoleLinks(context, l10n, role),

              const Spacer(),

              // ── Language toggle ──
              BlocBuilder<LocaleCubit, Locale>(
                builder: (context, locale) {
                  return _SidebarItem(
                    icon: Icons.language,
                    selectedIcon: Icons.language,
                    label: locale.languageCode == 'sr' ? 'English' : 'Srpski',
                    selected: false,
                    expanded: expanded,
                    onTap: () => context.read<LocaleCubit>().toggle(),
                  );
                },
              ),

              // ── Logout ──
              _SidebarItem(
                icon: Icons.logout,
                selectedIcon: Icons.logout,
                label: l10n.logout,
                selected: false,
                expanded: expanded,
                color: AppColors.destructive,
                onTap: () => context.read<AuthBloc>().add(LogoutRequested()),
              ),

              // ── Toggle button ──
              const Divider(height: 1),
              _buildToggleButton(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(String name, String email, Role? role) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: EdgeInsets.symmetric(
        horizontal: expanded ? AppSpacing.md : AppSpacing.sm,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: expanded
          ? Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.primary,
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : 'U',
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
                      Text(
                        name,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.bodySmall.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.foreground,
                        ),
                      ),
                      if (role != null)
                        Text(
                          role.name,
                          style: AppTypography.caption.copyWith(
                            color: AppColors.mutedForeground,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            )
          : Center(
              child: CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.primary,
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : 'U',
                  style: AppTypography.bodyMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
    );
  }

  List<Widget> _buildSidebarRoleLinks(BuildContext context, AppLocalizations l10n, Role? role) {
    if (role == null) return [];

    final links = <Widget>[
      Padding(
        padding: EdgeInsets.only(
          left: expanded ? AppSpacing.md : 0,
          top: AppSpacing.xs,
          bottom: AppSpacing.xs,
        ),
        child:
            expanded ? const Divider(height: 1) : Divider(height: 1, indent: AppSpacing.sm, endIndent: AppSpacing.sm),
      ),
    ];

    switch (role) {
      case Role.admin:
        links.addAll([
          _SidebarItem(
            icon: Icons.admin_panel_settings_outlined,
            selectedIcon: Icons.admin_panel_settings,
            label: 'Upravljanje upitima',
            selected: false,
            expanded: expanded,
            onTap: () => context.push('/app/admin/inquiries'),
          ),
          _SidebarItem(
            icon: Icons.mail_outline,
            selectedIcon: Icons.mail,
            label: l10n.allInquiries,
            selected: false,
            expanded: expanded,
            onTap: () => context.push('/app/inquiries'),
          ),
          _SidebarItem(
            icon: Icons.people_outline,
            selectedIcon: Icons.people,
            label: 'Korisnici',
            selected: false,
            expanded: expanded,
            onTap: () => context.push('/app/admin/users'),
          ),
          _SidebarItem(
            icon: Icons.settings_outlined,
            selectedIcon: Icons.settings,
            label: l10n.configuration,
            selected: false,
            expanded: expanded,
            onTap: () => context.push('/app/admin/config'),
          ),
        ]);
      case Role.mediaOwner:
        links.addAll([
          _SidebarItem(
            icon: Icons.inventory_outlined,
            selectedIcon: Icons.inventory,
            label: l10n.myInventory,
            selected: false,
            expanded: expanded,
            onTap: () => context.push('/app/my-inventory'),
          ),
          _SidebarItem(
            icon: Icons.add_circle_outline,
            selectedIcon: Icons.add_circle,
            label: l10n.addInventory,
            selected: false,
            expanded: expanded,
            onTap: () => context.push('/app/inventory/create'),
          ),
          _SidebarItem(
            icon: Icons.request_quote_outlined,
            selectedIcon: Icons.request_quote,
            label: 'Zahtevi za ponude',
            selected: false,
            expanded: expanded,
            onTap: () => context.push('/app/media-owner/quotes'),
          ),
          _SidebarItem(
            icon: Icons.event_available_outlined,
            selectedIcon: Icons.event_available,
            label: 'Dostupnost',
            selected: false,
            expanded: expanded,
            onTap: () => context.push('/app/media-owner/availability'),
          ),
        ]);
      case Role.brand:
        links.addAll([
          _SidebarItem(
            icon: Icons.mail_outline,
            selectedIcon: Icons.mail,
            label: l10n.myInquiries,
            selected: false,
            expanded: expanded,
            onTap: () => context.push('/app/inquiries'),
          ),
          _SidebarItem(
            icon: Icons.campaign_outlined,
            selectedIcon: Icons.campaign,
            label: l10n.campaigns,
            selected: false,
            expanded: expanded,
            onTap: () => context.push('/app/campaigns'),
          ),
        ]);
      case Role.agency:
        links.addAll([
          _SidebarItem(
            icon: Icons.business_outlined,
            selectedIcon: Icons.business,
            label: l10n.myBrands,
            selected: false,
            expanded: expanded,
            onTap: () => context.push('/app/agency/brands'),
          ),
          _SidebarItem(
            icon: Icons.mail_outline,
            selectedIcon: Icons.mail,
            label: l10n.myInquiries,
            selected: false,
            expanded: expanded,
            onTap: () => context.push('/app/inquiries'),
          ),
          _SidebarItem(
            icon: Icons.campaign_outlined,
            selectedIcon: Icons.campaign,
            label: l10n.campaigns,
            selected: false,
            expanded: expanded,
            onTap: () => context.push('/app/campaigns'),
          ),
        ]);
    }

    return links;
  }

  Widget _buildToggleButton() {
    return InkWell(
      onTap: onToggle,
      child: Container(
        height: 48,
        alignment: expanded ? Alignment.centerRight : Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        child: AnimatedRotation(
          turns: expanded ? 0 : 0.5,
          duration: const Duration(milliseconds: 200),
          child: Icon(
            Icons.chevron_left,
            color: AppColors.mutedForeground,
            size: 20,
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// Sidebar Item Widget
// ═══════════════════════════════════════════════════════════════════════

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool selected;
  final bool expanded;
  final Color? color;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.selected,
    required this.expanded,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final fg = color ?? (selected ? AppColors.primary : AppColors.mutedForeground);
    final bg = selected ? AppColors.secondary : Colors.transparent;

    final child = InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 44,
        margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xs,
          vertical: 2,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: expanded ? AppSpacing.sm : 0,
        ),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: expanded
            ? Row(
                children: [
                  Icon(selected ? selectedIcon : icon, size: 20, color: fg),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      label,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.bodySmall.copyWith(
                        color: fg,
                        fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              )
            : Center(
                child: Icon(selected ? selectedIcon : icon, size: 22, color: fg),
              ),
      ),
    );

    if (!expanded) {
      return Tooltip(message: label, child: child);
    }
    return child;
  }
}
