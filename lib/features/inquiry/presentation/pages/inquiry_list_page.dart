import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_constants.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../auth/domain/entities/role.dart';
import '../../../auth/presentation/blocs/auth_bloc.dart';
import '../../data/repository/inquiry_repository.dart';
import '../blocs/inquiry_bloc.dart';
import '../widgets/inquiry_card.dart';

class InquiryListPage extends StatelessWidget {
  const InquiryListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final role = authState.user.role;

    return BlocProvider(
      create: (context) => InquiryBloc(context.read<InquiryRepository>())
        ..add(LoadInquiries(role)),
      child: _InquiryListView(role: role),
    );
  }
}

class _InquiryListView extends StatelessWidget {
  final Role role;

  const _InquiryListView({required this.role});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n.inquiries),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.foreground,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: BlocBuilder<InquiryBloc, InquiryState>(
        builder: (context, state) {
          if (state is InquiryLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is InquiryError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: AppColors.destructive),
                  const SizedBox(height: AppSpacing.md),
                  Text(state.message, style: AppTypography.bodyMedium),
                  const SizedBox(height: AppSpacing.md),
                  ElevatedButton(
                    onPressed: () => context.read<InquiryBloc>().add(LoadInquiries(role)),
                    child: Text(l10n.retry),
                  ),
                ],
              ),
            );
          }

          if (state is InquiriesLoaded) {
            if (state.inquiries.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.mail_outline, size: 64, color: AppColors.mutedForeground),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      l10n.noInquiries,
                      style: AppTypography.bodyLarge.copyWith(
                        color: AppColors.mutedForeground,
                      ),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<InquiryBloc>().add(LoadInquiries(role));
              },
              child: ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.md),
                itemCount: state.inquiries.length,
                separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                itemBuilder: (context, index) {
                  final inquiry = state.inquiries[index];
                  return InquiryCard(
                    inquiry: inquiry,
                    onTap: () => context.push('/app/inquiries/${inquiry.id}'),
                  );
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
