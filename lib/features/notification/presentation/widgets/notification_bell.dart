import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_constants.dart';
import '../../../../core/theme/app_typography.dart';
import '../../data/dto/notification_dto.dart';
import '../blocs/notification_bloc.dart';
import 'notification_tile.dart';

class NotificationBell extends StatefulWidget {
  const NotificationBell({super.key});

  @override
  State<NotificationBell> createState() => _NotificationBellState();
}

class _NotificationBellState extends State<NotificationBell> {
  final _overlayKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    // Load unread count on init
    context.read<NotificationBloc>().add(LoadUnreadCount());
  }

  void _showDropdown(BuildContext context) {
    // Load full notifications
    context.read<NotificationBloc>().add(LoadNotifications());

    final RenderBox renderBox = _overlayKey.currentContext!.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    showMenu<void>(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx - 280 + size.width,
        position.dy + size.height,
        position.dx + size.width,
        0,
      ),
      constraints: const BoxConstraints(maxWidth: 360, maxHeight: 400),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
      items: [
        PopupMenuItem(
          enabled: false,
          padding: EdgeInsets.zero,
          child: _NotificationDropdown(
            onViewAll: () {
              Navigator.pop(context);
              context.push('/app/notifications');
            },
            onMarkAllRead: () {
              context.read<NotificationBloc>().add(MarkAllRead());
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationBloc, NotificationState>(
      builder: (context, state) {
        int unreadCount = 0;
        if (state is NotificationsLoaded) {
          unreadCount = state.unreadCount;
        }

        return IconButton(
          key: _overlayKey,
          icon: Badge(
            isLabelVisible: unreadCount > 0,
            label: Text(
              unreadCount > 99 ? '99+' : '$unreadCount',
              style: const TextStyle(fontSize: 10, color: Colors.white),
            ),
            backgroundColor: AppColors.destructive,
            child: Icon(
              Icons.notifications_outlined,
              color: AppColors.foreground,
              size: 22,
            ),
          ),
          onPressed: () => _showDropdown(context),
          tooltip: 'Obavestenja',
        );
      },
    );
  }
}

class _NotificationDropdown extends StatelessWidget {
  final VoidCallback onViewAll;
  final VoidCallback onMarkAllRead;

  const _NotificationDropdown({
    required this.onViewAll,
    required this.onMarkAllRead,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationBloc, NotificationState>(
      builder: (context, state) {
        List<NotificationDto> notifications = [];
        if (state is NotificationsLoaded) {
          notifications = state.notifications.take(5).toList();
        }

        return SizedBox(
          width: 340,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Obavestenja', style: AppTypography.h6),
                    TextButton(
                      onPressed: onMarkAllRead,
                      style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
                      child: Text(
                        'Oznaci sve kao procitano',
                        style: AppTypography.caption.copyWith(color: AppColors.primary),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              // Notifications
              if (state is NotificationLoading)
                const Padding(
                  padding: EdgeInsets.all(AppSpacing.lg),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (notifications.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Center(
                    child: Text(
                      'Nema obavestenja',
                      style: AppTypography.bodySmall.copyWith(color: AppColors.mutedForeground),
                    ),
                  ),
                )
              else
                ...notifications.map((n) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs, vertical: 2),
                  child: NotificationTile(
                    notification: n,
                    onTap: () {
                      if (!n.read) {
                        context.read<NotificationBloc>().add(MarkRead(n.id));
                      }
                    },
                  ),
                )),
              // Footer
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                child: Center(
                  child: TextButton(
                    onPressed: onViewAll,
                    child: Text(
                      'Pogledaj sve',
                      style: AppTypography.bodySmall.copyWith(color: AppColors.primary),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
