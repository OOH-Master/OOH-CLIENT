import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/responsive/responsive_builder.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_constants.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../auth/domain/entities/role.dart';
import '../../data/repository/inquiry_repository.dart';
import '../../domain/entities/inquiry.dart';
import '../blocs/inquiry_bloc.dart';
import '../widgets/inquiry_card.dart';
import '../widgets/inquiry_status_badge.dart';

class AdminInquiryManagementPage extends StatelessWidget {
  const AdminInquiryManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => InquiryBloc(context.read<InquiryRepository>())
        ..add(LoadInquiries(Role.admin)),
      child: const _AdminInquiryManagementView(),
    );
  }
}

class _AdminInquiryManagementView extends StatefulWidget {
  const _AdminInquiryManagementView();

  @override
  State<_AdminInquiryManagementView> createState() => _AdminInquiryManagementViewState();
}

class _AdminInquiryManagementViewState extends State<_AdminInquiryManagementView> {
  InquiryStatus? _statusFilter;
  String? _requesterTypeFilter;
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Inquiry> _filterInquiries(List<Inquiry> inquiries) {
    var filtered = inquiries;

    if (_statusFilter != null) {
      filtered = filtered.where((i) => i.status == _statusFilter).toList();
    }

    if (_requesterTypeFilter != null) {
      filtered = filtered.where((i) => i.requesterType == _requesterTypeFilter).toList();
    }

    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((i) {
        return (i.contactName?.toLowerCase().contains(query) ?? false) ||
            (i.contactEmail?.toLowerCase().contains(query) ?? false) ||
            i.id.toString().contains(query);
      }).toList();
    }

    return filtered;
  }

  void _handleAction(BuildContext context, Inquiry inquiry, String action) {
    final bloc = context.read<InquiryBloc>();
    switch (action) {
      case 'start_processing':
        bloc.add(TransitionInquiryStatus(inquiry.id, 'IN_PROGRESS', Role.admin));
        break;
      case 'request_quotes':
        bloc.add(RequestQuotes(inquiry.id));
        break;
      case 'send_offer':
        bloc.add(SendOffer(inquiry.id));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Upravljanje upitima'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.foreground,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: Column(
        children: [
          _buildFilterBar(context, l10n),
          Expanded(
            child: BlocConsumer<InquiryBloc, InquiryState>(
              listener: (context, state) {
                if (state is InquiryActionSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.message)),
                  );
                  context.read<InquiryBloc>().add(LoadInquiries(Role.admin));
                }
                if (state is InquiryError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: AppColors.destructive,
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state is InquiryLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is InquiriesLoaded) {
                  final filtered = _filterInquiries(state.inquiries);

                  if (filtered.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inbox_outlined, size: 64, color: AppColors.mutedForeground),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            l10n.noInquiries,
                            style: AppTypography.bodyMedium.copyWith(color: AppColors.mutedForeground),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      context.read<InquiryBloc>().add(LoadInquiries(Role.admin));
                    },
                    child: context.isDesktop
                        ? _buildDesktopList(filtered)
                        : _buildMobileList(filtered),
                  );
                }

                if (state is InquiryError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 48, color: AppColors.destructive),
                        const SizedBox(height: AppSpacing.md),
                        Text(state.message),
                        const SizedBox(height: AppSpacing.md),
                        ElevatedButton(
                          onPressed: () =>
                              context.read<InquiryBloc>().add(LoadInquiries(Role.admin)),
                          child: Text(l10n.retry),
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

  Widget _buildFilterBar(BuildContext context, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        children: [
          SizedBox(
            width: 200,
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: InputDecoration(
                hintText: l10n.search,
                prefixIcon: const Icon(Icons.search, size: 20),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  borderSide: BorderSide(color: AppColors.border),
                ),
                isDense: true,
              ),
              style: AppTypography.bodySmall,
            ),
          ),
          SizedBox(
            width: 180,
            child: DropdownButtonFormField<InquiryStatus?>(
              initialValue: _statusFilter,
              decoration: InputDecoration(
                labelText: l10n.status,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                isDense: true,
              ),
              style: AppTypography.bodySmall.copyWith(color: AppColors.foreground),
              items: [
                const DropdownMenuItem(value: null, child: Text('Svi statusi')),
                ...InquiryStatus.values.map((s) => DropdownMenuItem(
                      value: s,
                      child: Text(s.apiValue.replaceAll('_', ' ')),
                    )),
              ],
              onChanged: (v) => setState(() => _statusFilter = v),
            ),
          ),
          SizedBox(
            width: 160,
            child: DropdownButtonFormField<String?>(
              initialValue: _requesterTypeFilter,
              decoration: InputDecoration(
                labelText: 'Tip klijenta',
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                isDense: true,
              ),
              style: AppTypography.bodySmall.copyWith(color: AppColors.foreground),
              items: const [
                DropdownMenuItem(value: null, child: Text('Svi')),
                DropdownMenuItem(value: 'BRAND', child: Text('Brand')),
                DropdownMenuItem(value: 'AGENCY', child: Text('Agency')),
              ],
              onChanged: (v) => setState(() => _requesterTypeFilter = v),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileList(List<Inquiry> inquiries) {
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: inquiries.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, index) {
        final inquiry = inquiries[index];
        return Column(
          children: [
            InquiryCard(
              inquiry: inquiry,
              onTap: () => context.push('/app/inquiries/${inquiry.id}'),
            ),
            _buildActionButtons(context, inquiry),
          ],
        );
      },
    );
  }

  Widget _buildDesktopList(List<Inquiry> inquiries) {
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: inquiries.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, index) {
        final inquiry = inquiries[index];
        return Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppRadius.sm),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: InkWell(
                  onTap: () => context.push('/app/inquiries/${inquiry.id}'),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        inquiry.contactName ?? 'Upit #${inquiry.id}',
                        style: AppTypography.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (inquiry.contactEmail != null)
                        Text(
                          inquiry.contactEmail!,
                          style: AppTypography.bodySmall.copyWith(color: AppColors.mutedForeground),
                        ),
                    ],
                  ),
                ),
              ),
              if (inquiry.requesterType != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                  child: Chip(
                    label: Text(inquiry.requesterType!),
                    backgroundColor: AppColors.muted,
                    labelStyle: AppTypography.caption,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              InquiryStatusBadge(status: inquiry.status),
              const SizedBox(width: AppSpacing.md),
              _buildActionButtons(context, inquiry),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionButtons(BuildContext context, Inquiry inquiry) {
    Widget? actionButton;

    switch (inquiry.status) {
      case InquiryStatus.submitted:
        actionButton = _buildActionChip(
          label: 'Pokreni obradu',
          icon: Icons.play_arrow,
          color: AppColors.info,
          onPressed: () => _handleAction(context, inquiry, 'start_processing'),
        );
        break;
      case InquiryStatus.inProgress:
        actionButton = _buildActionChip(
          label: 'Zatrazi ponude',
          icon: Icons.request_quote,
          color: AppColors.primary,
          onPressed: () => _handleAction(context, inquiry, 'request_quotes'),
        );
        break;
      case InquiryStatus.pricingReady:
        actionButton = _buildActionChip(
          label: 'Posalji ponudu',
          icon: Icons.send,
          color: AppColors.success,
          onPressed: () => _handleAction(context, inquiry, 'send_offer'),
        );
        break;
      default:
        break;
    }

    if (actionButton == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xs),
      child: actionButton,
    );
  }

  Widget _buildActionChip({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16, color: color),
      label: Text(
        label,
        style: AppTypography.bodySmall.copyWith(color: color, fontWeight: FontWeight.w600),
      ),
      style: TextButton.styleFrom(
        backgroundColor: color.withValues(alpha: 0.1),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
      ),
    );
  }
}
