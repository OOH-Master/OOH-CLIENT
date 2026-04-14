import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/responsive/responsive_builder.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_constants.dart';
import '../../../../core/theme/app_typography.dart';
import '../blocs/notification_bloc.dart';
import '../widgets/notification_tile.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Trigger load on page visit
    context.read<NotificationBloc>().add(LoadNotifications());
    return const _NotificationsView();
  }
}

class _NotificationsView extends StatelessWidget {
  const _NotificationsView();

  @override
  Widget build(BuildContext context) {
    final isDesktop = context.isDesktop;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Obavestenja'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.foreground,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        actions: [
          TextButton.icon(
            onPressed: () => context.read<NotificationBloc>().add(MarkAllRead()),
            icon: const Icon(Icons.done_all, size: 18),
            label: const Text('Oznaci sve'),
          ),
        ],
      ),
      body: BlocBuilder<NotificationBloc, NotificationState>(
        builder: (context, state) {
          if (state is NotificationLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is NotificationError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: AppColors.destructive),
                  const SizedBox(height: AppSpacing.md),
                  Text(state.message, style: AppTypography.bodyMedium),
                  const SizedBox(height: AppSpacing.md),
                  ElevatedButton(
                    onPressed: () => context.read<NotificationBloc>().add(LoadNotifications()),
                    child: const Text('Pokusaj ponovo'),
                  ),
                ],
              ),
            );
          }

          if (state is NotificationsLoaded) {
            if (state.notifications.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.notifications_off_outlined, size: 64, color: AppColors.mutedForeground),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Nemate obavestenja',
                      style: AppTypography.bodyLarge.copyWith(color: AppColors.mutedForeground),
                    ),
                  ],
                ),
              );
            }

            return Center(
              child: Container(
                constraints: BoxConstraints(maxWidth: isDesktop ? 700 : double.infinity),
                child: RefreshIndicator(
                  onRefresh: () async {
                    context.read<NotificationBloc>().add(LoadNotifications());
                  },
                  child: ListView.separated(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    itemCount: state.notifications.length,
                    separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.xs),
                    itemBuilder: (context, index) {
                      final notification = state.notifications[index];
                      return NotificationTile(
                        notification: notification,
                        onTap: () {
                          if (!notification.read) {
                            context.read<NotificationBloc>().add(MarkRead(notification.id));
                          }
                        },
                      );
                    },
                  ),
                ),
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
