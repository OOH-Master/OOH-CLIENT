import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/locale_cubit.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/ui/ui.dart';
import '../../../auth/domain/entities/role.dart';
import '../../../auth/presentation/blocs/auth_bloc.dart';
import '../../../notification/presentation/blocs/notification_bloc.dart';
import '../blocs/shell_cubit.dart';

/// Stavka navigacije: putanja, naziv i ikonice.
class NavEntry {
  final String path;
  final String label;
  final IconData icon;
  final IconData activeIcon;

  /// Druge putanje koje pripadaju ovoj stavci (npr. detalj upita).
  final List<String> alsoActiveFor;

  const NavEntry(this.path, this.label, this.icon, this.activeIcon,
      {this.alsoActiveFor = const []});

  bool matches(String location) {
    bool under(String p) =>
        location == p ||
        location.startsWith('$p/') ||
        location.startsWith('$p?');
    return under(path) || alsoActiveFor.any(under);
  }
}

String roleLabel(Role? role) {
  switch (role) {
    case Role.brand:
      return 'Brend';
    case Role.agency:
      return 'Agencija';
    case Role.mediaOwner:
      return 'Vlasnik medija';
    case Role.admin:
      return 'Stručnjak za lokacije';
    case null:
      return '';
  }
}

const mainNav = [
  NavEntry('/app/dashboard', 'Kontrolna tabla', Icons.space_dashboard_outlined,
      Icons.space_dashboard_rounded),
  NavEntry('/app/discover', 'Istraži površine', Icons.travel_explore_outlined,
      Icons.travel_explore_rounded),
];

/// Stavke koje zavise od uloge (naslov grupe + stavke).
(String, List<NavEntry>) roleNav(Role? role) {
  switch (role) {
    case Role.brand:
      return (
        'Upiti i kampanje',
        const [
          NavEntry('/app/inquiries', 'Moji upiti',
              Icons.forward_to_inbox_outlined, Icons.forward_to_inbox_rounded),
          NavEntry('/app/campaigns', 'Kampanje', Icons.campaign_outlined,
              Icons.campaign_rounded),
          NavEntry('/app/favorites', 'Omiljeno', Icons.favorite_border_rounded,
              Icons.favorite_rounded),
        ],
      );
    case Role.agency:
      return (
        'Agencija',
        const [
          NavEntry('/app/agency/brands', 'Moji brendovi',
              Icons.storefront_outlined, Icons.storefront_rounded),
          NavEntry('/app/inquiries', 'Moji upiti',
              Icons.forward_to_inbox_outlined, Icons.forward_to_inbox_rounded),
          NavEntry('/app/campaigns', 'Kampanje', Icons.campaign_outlined,
              Icons.campaign_rounded),
          NavEntry('/app/favorites', 'Omiljeno', Icons.favorite_border_rounded,
              Icons.favorite_rounded),
        ],
      );
    case Role.mediaOwner:
      return (
        'Vlasnik medija',
        const [
          NavEntry('/app/media-owner/quotes', 'Zahtevi za ponude',
              Icons.request_quote_outlined, Icons.request_quote_rounded),
          NavEntry('/app/my-inventory', 'Moj inventar',
              Icons.view_quilt_outlined, Icons.view_quilt_rounded,
              alsoActiveFor: ['/app/inventory']),
          NavEntry('/app/media-owner/availability', 'Dostupnost',
              Icons.event_available_outlined, Icons.event_available_rounded),
        ],
      );
    case Role.admin:
      return (
        'Upravljanje',
        const [
          NavEntry('/app/admin/inquiries', 'Upravljanje upitima',
              Icons.inventory_outlined, Icons.inventory_rounded),
          NavEntry('/app/inquiries', 'Svi upiti',
              Icons.forward_to_inbox_outlined, Icons.forward_to_inbox_rounded),
          NavEntry('/app/admin/users', 'Korisnici', Icons.group_outlined,
              Icons.group_rounded),
          NavEntry('/app/admin/config', 'Konfiguracija', Icons.tune_outlined,
              Icons.tune_rounded),
        ],
      );
    case null:
      return ('', const []);
  }
}

/// Okvir radnog dela aplikacije na širokom ekranu: tamni meni levo, sadržaj desno.
/// Na užim ekranima vraća samo sadržaj (navigaciju tada daje MainShellPage).
class AppFrame extends StatelessWidget {
  final String location;
  final Widget child;

  const AppFrame({super.key, required this.location, required this.child});

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 900;
    if (!wide) return child;
    return BlocProvider(
      create: (_) => ShellCubit(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Row(
          children: [
            AppSidebar(location: location),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}

class AppSidebar extends StatelessWidget {
  final String location;

  const AppSidebar({super.key, required this.location});

  static const double expandedWidth = 264;
  static const double collapsedWidth = 76;

  @override
  Widget build(BuildContext context) {
    final expanded =
        context.select<ShellCubit, bool>((c) => c.state.sidebarExpanded);
    final authState = context.watch<AuthBloc>().state;
    final user = authState is AuthAuthenticated ? authState.user : null;
    final role = user?.role;
    final (groupTitle, roleItems) = roleNav(role);
    final name = (user?.companyName?.isNotEmpty ?? false)
        ? user!.companyName!
        : (user?.name ?? '');

    Widget item(NavEntry e) => _SidebarItem(
          entry: e,
          selected: e.matches(location),
          expanded: expanded,
          onTap: () => context.go(e.path),
        );

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      width: expanded ? expandedWidth : collapsedWidth,
      decoration: const BoxDecoration(
        color: AppColors.ink,
        border: Border(right: BorderSide(color: AppColors.inkLine)),
      ),
      child: SafeArea(
        right: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                  expanded ? 20 : 0, 22, expanded ? 12 : 0, 18),
              child: expanded
                  ? Row(
                      children: [
                        const BrandMark(onDark: true, size: 34),
                        const Spacer(),
                        _IconTap(
                          icon: Icons.keyboard_double_arrow_left_rounded,
                          tooltip: 'Skupi meni',
                          onTap: () =>
                              context.read<ShellCubit>().toggleSidebar(),
                        ),
                      ],
                    )
                  : Center(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: () => context.read<ShellCubit>().toggleSidebar(),
                        child: const Tooltip(
                            message: 'Raširi meni',
                            child: BrandMark(compact: true, size: 36)),
                      ),
                    ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  for (final e in mainNav) item(e),
                  if (roleItems.isNotEmpty) ...[
                    const SizedBox(height: 18),
                    if (expanded)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                        child: Text(
                          groupTitle,
                          style: AppTypography.labelSmall
                              .copyWith(color: AppColors.inkMuted),
                        ),
                      )
                    else
                      const Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        child: Divider(color: AppColors.inkLine, height: 1),
                      ),
                    for (final e in roleItems) item(e),
                  ],
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                children: [
                  _NotificationsItem(
                    location: location,
                    expanded: expanded,
                  ),
                  BlocBuilder<LocaleCubit, Locale>(
                    builder: (context, locale) => _SidebarItem(
                      entry: NavEntry(
                        '',
                        locale.languageCode == 'sr' ? 'English' : 'Srpski',
                        Icons.translate_rounded,
                        Icons.translate_rounded,
                      ),
                      selected: false,
                      expanded: expanded,
                      onTap: () => context.read<LocaleCubit>().toggle(),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.fromLTRB(12, 10, 12, 16),
              padding: EdgeInsets.all(expanded ? 10 : 6),
              decoration: BoxDecoration(
                color: AppColors.inkRaised,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.inkLine),
              ),
              child: expanded
                  ? Row(
                      children: [
                        InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () => context.go('/app/profile'),
                          child: AppAvatar(
                              name: name.isEmpty ? '?' : name, size: 36),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: InkWell(
                            onTap: () => context.go('/app/profile'),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTypography.labelLarge
                                      .copyWith(color: Colors.white),
                                ),
                                Text(
                                  roleLabel(role),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTypography.caption
                                      .copyWith(color: AppColors.inkMuted),
                                ),
                              ],
                            ),
                          ),
                        ),
                        _IconTap(
                          icon: Icons.logout_rounded,
                          tooltip: 'Odjavi se',
                          onTap: () =>
                              context.read<AuthBloc>().add(LogoutRequested()),
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () => context.go('/app/profile'),
                          child: AppAvatar(
                              name: name.isEmpty ? '?' : name, size: 36),
                        ),
                        const SizedBox(height: 6),
                        _IconTap(
                          icon: Icons.logout_rounded,
                          tooltip: 'Odjavi se',
                          onTap: () =>
                              context.read<AuthBloc>().add(LogoutRequested()),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SidebarItem extends StatefulWidget {
  final NavEntry entry;
  final bool selected;
  final bool expanded;
  final VoidCallback onTap;

  /// Broj nepročitanih (obaveštenja); 0 = bez oznake.
  final int badge;

  const _SidebarItem({
    required this.entry,
    required this.selected,
    required this.expanded,
    required this.onTap,
    this.badge = 0,
  });

  @override
  State<_SidebarItem> createState() => _SidebarItemState();
}

class _SidebarItemState extends State<_SidebarItem> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final selected = widget.selected;
    final fg = selected
        ? Colors.white
        : (_hover ? AppColors.inkText : AppColors.inkMuted);
    final bg = selected
        ? AppColors.inkRaised
        : (_hover
            ? AppColors.inkRaised.withValues(alpha: 0.55)
            : Colors.transparent);

    final tile = MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          height: 44,
          margin: const EdgeInsets.symmetric(vertical: 2),
          padding: EdgeInsets.symmetric(horizontal: widget.expanded ? 12 : 0),
          decoration:
              BoxDecoration(color: bg, borderRadius: BorderRadius.circular(7)),
          child: Row(
            mainAxisAlignment: widget.expanded
                ? MainAxisAlignment.start
                : MainAxisAlignment.center,
            children: [
              Badge(
                isLabelVisible: widget.badge > 0 && !widget.expanded,
                smallSize: 8,
                backgroundColor: AppColors.destructive,
                child: Icon(
                  selected ? widget.entry.activeIcon : widget.entry.icon,
                  size: 21,
                  color: selected ? AppColors.primaryTint : fg,
                ),
              ),
              if (widget.expanded) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.entry.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.bodyMedium.copyWith(
                      color: fg,
                      fontSize: 14.5,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ),
                if (widget.badge > 0)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.destructive,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      widget.badge > 99 ? '99+' : '${widget.badge}',
                      style: AppTypography.labelSmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );

    return widget.expanded
        ? tile
        : Tooltip(message: widget.entry.label, preferBelow: false, child: tile);
  }
}

class _IconTap extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _IconTap(
      {required this.icon, required this.tooltip, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        borderRadius: BorderRadius.circular(9),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, size: 19, color: AppColors.inkMuted),
        ),
      ),
    );
  }
}

/// Stavka "Obaveštenja" sa brojem nepročitanih iz globalnog NotificationBloc-a.
class _NotificationsItem extends StatefulWidget {
  final String location;
  final bool expanded;

  const _NotificationsItem({required this.location, required this.expanded});

  @override
  State<_NotificationsItem> createState() => _NotificationsItemState();
}

class _NotificationsItemState extends State<_NotificationsItem> {
  static const _entry = NavEntry(
    '/app/notifications',
    'Obaveštenja',
    Icons.notifications_none_rounded,
    Icons.notifications_rounded,
  );

  @override
  void initState() {
    super.initState();
    context.read<NotificationBloc>().add(LoadUnreadCount());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationBloc, NotificationState>(
      builder: (context, state) => _SidebarItem(
        entry: _entry,
        selected: _entry.matches(widget.location),
        expanded: widget.expanded,
        badge: state is NotificationsLoaded ? state.unreadCount : 0,
        onTap: () => context.go(_entry.path),
      ),
    );
  }
}
