import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/sr_format.dart';
import '../../../../core/widgets/ui/ui.dart';
import '../../../auth/domain/entities/role.dart';
import '../../../auth/presentation/blocs/auth_bloc.dart';
import '../../data/dto/notification_dto.dart';
import '../blocs/notification_bloc.dart';
import '../widgets/notification_tile.dart';

/// Obaveštenja korisnika, grupisana po danima ("Danas", "Juče", datum).
/// Na širokom ekranu stranica počinje zaglavljem sa akcijom, na telefonu ima
/// tanko zaglavlje sa dugmetom za povratak.
class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  static const double _maxWidth = 944;

  /// Stanje za koje je lista već zatražena (da se ne traži dvaput).
  NotificationState? _requestedFor;

  @override
  void initState() {
    super.initState();
    final bloc = context.read<NotificationBloc>();
    _requestedFor = bloc.state;
    bloc.add(const LoadNotifications());
  }

  void _markAll() => context.read<NotificationBloc>().add(const MarkAllRead());

  Future<void> _refresh() async {
    final bloc = context.read<NotificationBloc>();
    bloc.add(const LoadNotifications());
    await bloc.stream
        .firstWhere((s) => s is NotificationsLoaded || s is NotificationError)
        .timeout(const Duration(seconds: 15), onTimeout: () => bloc.state);
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 900;

    return BlocBuilder<NotificationBloc, NotificationState>(
      builder: (context, state) {
        // Zvonce zna samo broj nepročitanih — tada se lista traži jednom.
        if (state is NotificationsLoaded &&
            !state.listLoaded &&
            !identical(_requestedFor, state)) {
          _requestedFor = state;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              context.read<NotificationBloc>().add(const LoadNotifications());
            }
          });
        }

        final unread = state is NotificationsLoaded ? state.unreadCount : 0;
        final content = LayoutBuilder(
          builder: (context, constraints) {
            final extra = constraints.maxWidth - _maxWidth;
            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding:
                    EdgeInsets.only(right: extra > 0 ? extra : 0, bottom: 32),
                children: _children(context, state, wide, unread),
              ),
            );
          },
        );

        if (wide) {
          return Scaffold(backgroundColor: AppColors.background, body: content);
        }
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text('Obaveštenja'),
            actions: [
              IconButton(
                tooltip: 'Označi sve kao pročitano',
                onPressed: unread > 0 ? _markAll : null,
                icon: const Icon(Icons.done_all_rounded),
              ),
              const SizedBox(width: 4),
            ],
          ),
          body: content,
        );
      },
    );
  }

  List<Widget> _children(
      BuildContext context, NotificationState state, bool wide, int unread) {
    final side = wide ? 32.0 : 16.0;
    final children = <Widget>[];

    if (wide) {
      children.add(PageHeader(
        title: 'Obaveštenja',
        subtitle: _summary(unread),
        padding: const EdgeInsets.fromLTRB(32, 28, 32, 18),
        actions: [
          OutlinedButton.icon(
            onPressed: unread > 0 ? _markAll : null,
            icon: const Icon(Icons.done_all_rounded, size: 18),
            label: const Text('Označi sve kao pročitano'),
          ),
        ],
      ));
    }

    if (state is NotificationError) {
      children.add(EmptyState(
        icon: Icons.cloud_off_rounded,
        title: 'Obaveštenja nisu učitana',
        action: OutlinedButton(
          onPressed: () =>
              context.read<NotificationBloc>().add(const LoadNotifications()),
          child: const Text('Pokušaj ponovo'),
        ),
      ));
      return children;
    }

    if (state is! NotificationsLoaded || !state.listLoaded) {
      children.add(const Padding(
        padding: EdgeInsets.symmetric(vertical: 72),
        child: Center(child: CircularProgressIndicator()),
      ));
      return children;
    }

    if (state.notifications.isEmpty) {
      children.add(const EmptyState(
        icon: Icons.notifications_none_rounded,
        title: 'Nema obaveštenja',
      ));
      return children;
    }

    final summary = _summary(unread);
    if (!wide && summary != null) {
      children.add(Padding(
        padding: EdgeInsets.fromLTRB(side, 12, side - 8, 0),
        child: Row(
          children: [
            Expanded(
              child: Text(
                summary,
                style: AppTypography.labelMedium
                    .copyWith(color: AppColors.mutedForeground),
              ),
            ),
            TextButton(
              onPressed: _markAll,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                minimumSize: const Size(0, 36),
              ),
              child: const Text('Označi sve'),
            ),
          ],
        ),
      ));
    }

    final authState = context.read<AuthBloc>().state;
    final role = authState is AuthAuthenticated ? authState.user.role : null;

    for (final group in _group(state.notifications)) {
      children.add(Padding(
        padding: EdgeInsets.fromLTRB(side, wide ? 8 : 16, side, 8),
        child: Text(
          group.label,
          style: AppTypography.labelMedium.copyWith(
            color: AppColors.text2,
            fontWeight: FontWeight.w600,
          ),
        ),
      ));
      for (final n in group.items) {
        children.add(Padding(
          padding: EdgeInsets.fromLTRB(side, 0, side, 8),
          child: _tile(context, n, group.isToday, role),
        ));
      }
      children.add(const SizedBox(height: 8));
    }
    return children;
  }

  Widget _tile(
      BuildContext context, NotificationDto n, bool today, Role? role) {
    final bloc = context.read<NotificationBloc>();
    final target = _target(n, role);
    return NotificationTile(
      notification: n,
      timeLabel: today ? n.timeAgo : _clock(n.createdAtDate),
      onTap: () {
        if (!n.read) bloc.add(MarkRead(n.id));
      },
      openLabel: target?.$2,
      onOpen: target == null
          ? null
          : () {
              if (!n.read) bloc.add(MarkRead(n.id));
              context.push(target.$1);
            },
    );
  }

  /// Broj nepročitanih; kada ih nema, podnaslova nema.
  static String? _summary(int unread) {
    if (unread <= 0) return null;
    return SrFormat.count(unread, 'nepročitano obaveštenje',
        'nepročitana obaveštenja', 'nepročitanih obaveštenja');
  }

  /// Kuda vodi obaveštenje: vlasnik medija na zahteve za ponude, ostali na upit.
  static (String, String)? _target(NotificationDto n, Role? role) {
    final id = n.inquiryId;
    if (id == null || role == null) return null;
    switch (role) {
      case Role.mediaOwner:
        return ('/app/media-owner/quotes', 'Otvori zahteve za ponude');
      case Role.brand:
      case Role.agency:
        if ((n.type ?? '').toUpperCase() == 'OFFER_SENT') {
          return ('/app/inquiries/$id/offer', 'Pogledaj ponudu');
        }
        return ('/app/inquiries/$id', 'Otvori upit #$id');
      case Role.admin:
        return ('/app/inquiries/$id', 'Otvori upit #$id');
    }
  }

  static String _clock(DateTime? d) {
    if (d == null) return '';
    final h = d.hour.toString().padLeft(2, '0');
    final m = d.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  static List<_DayGroup> _group(List<NotificationDto> items) {
    final sorted = [...items]..sort((a, b) {
        final da = a.createdAtDate;
        final db = b.createdAtDate;
        if (da == null && db == null) return b.id.compareTo(a.id);
        if (da == null) return 1;
        if (db == null) return -1;
        return db.compareTo(da);
      });
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final groups = <_DayGroup>[];
    for (final n in sorted) {
      final d = n.createdAtDate;
      final day = d == null ? null : DateTime(d.year, d.month, d.day);
      final key = day?.toIso8601String() ?? 'bez-datuma';
      if (groups.isEmpty || groups.last.key != key) {
        groups.add(_DayGroup(key, _dayLabel(day, today), day == today));
      }
      groups.last.items.add(n);
    }
    return groups;
  }

  static const _weekdays = [
    'ponedeljak',
    'utorak',
    'sreda',
    'četvrtak',
    'petak',
    'subota',
    'nedelja',
  ];

  static const _months = [
    'januar',
    'februar',
    'mart',
    'april',
    'maj',
    'jun',
    'jul',
    'avgust',
    'septembar',
    'oktobar',
    'novembar',
    'decembar',
  ];

  static String _dayLabel(DateTime? day, DateTime today) {
    if (day == null) return 'Ranije';
    final diff = today.difference(day).inDays;
    if (diff == 0) return 'Danas';
    if (diff == 1) return 'Juče';
    final label =
        '${_weekdays[day.weekday - 1]}, ${day.day}. ${_months[day.month - 1]}';
    final full = day.year == today.year ? label : '$label ${day.year}.';
    return full[0].toUpperCase() + full.substring(1);
  }
}

class _DayGroup {
  final String key;
  final String label;
  final bool isToday;
  final List<NotificationDto> items = [];

  _DayGroup(this.key, this.label, this.isToday);
}
