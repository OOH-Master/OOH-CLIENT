import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/config/api_client.dart';
import '../../../../core/config/api_config.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_constants.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../auth/domain/entities/role.dart';
import '../../../auth/presentation/blocs/auth_bloc.dart';
import '../../data/repository/inquiry_repository.dart';
import '../../domain/entities/inquiry.dart';
import '../blocs/inquiry_bloc.dart';
import '../widgets/inquiry_status_badge.dart';

class InquiryDetailPage extends StatelessWidget {
  final String inquiryId;

  const InquiryDetailPage({super.key, required this.inquiryId});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final role = authState.user.role;
    final id = int.tryParse(inquiryId);
    if (id == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Invalid inquiry ID')),
      );
    }

    return BlocProvider(
      create: (context) => InquiryBloc(context.read<InquiryRepository>())
        ..add(LoadInquiryDetail(id, role)),
      child: _InquiryDetailView(role: role, inquiryId: id),
    );
  }
}

class _InquiryDetailView extends StatefulWidget {
  final Role role;
  final int inquiryId;

  const _InquiryDetailView({required this.role, required this.inquiryId});

  @override
  State<_InquiryDetailView> createState() => _InquiryDetailViewState();
}

class _InquiryDetailViewState extends State<_InquiryDetailView> {
  final _notesController = TextEditingController();
  final _priceFormatter = NumberFormat('#,##0.00');

  AppLocalizations get l10n => AppLocalizations.of(context)!;
  bool _downloadingPdf = false;
  bool _downloadingInvoice = false;

  bool _isPdfAvailable(InquiryStatus status) {
    return status == InquiryStatus.offerSent ||
        status == InquiryStatus.acceptedByClient ||
        status == InquiryStatus.rejectedByClient ||
        status == InquiryStatus.realized ||
        status == InquiryStatus.closed;
  }

  Future<void> _downloadPdf(Inquiry inquiry) async {
    if (_downloadingPdf) return;
    setState(() => _downloadingPdf = true);

    try {
      final apiClient = context.read<ApiClient>();
      final response = await apiClient.get<List<int>>(
        '${ApiConfig.adminInquiries}/${inquiry.id}/pdf',
        options: Options(responseType: ResponseType.bytes),
      );

      final bytes = response.data ?? [];
      final base64Data = base64Encode(bytes);
      final dataUri = Uri.parse('data:application/pdf;base64,$base64Data');

      if (await canLaunchUrl(dataUri)) {
        await launchUrl(dataUri, mode: LaunchMode.externalApplication);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('PDF preuzet: ${inquiry.pdfFileName}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Greska pri preuzimanju PDF-a'),
            backgroundColor: AppColors.destructive,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _downloadingPdf = false);
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n.inquiryDetail),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.foreground,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: BlocConsumer<InquiryBloc, InquiryState>(
        listener: (context, state) {
          if (state is InquiryActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
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
                  Text(state.message),
                  const SizedBox(height: AppSpacing.md),
                  ElevatedButton(
                    onPressed: () => context.read<InquiryBloc>().add(
                          LoadInquiryDetail(widget.inquiryId, widget.role),
                        ),
                    child: Text(l10n.retry),
                  ),
                ],
              ),
            );
          }

          if (state is InquiryDetailLoaded) {
            return _buildDetail(state.inquiry);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildDetail(Inquiry inquiry) {
    if (_notesController.text.isEmpty && inquiry.adminNotes != null) {
      _notesController.text = inquiry.adminNotes!;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderCard(inquiry),
          const SizedBox(height: AppSpacing.md),
          _buildContactCard(inquiry),
          const SizedBox(height: AppSpacing.md),
          _buildCampaignCard(inquiry),
          const SizedBox(height: AppSpacing.md),
          if (inquiry.items.isNotEmpty) ...[
            _buildItemsCard(inquiry),
            const SizedBox(height: AppSpacing.md),
          ],
          if ((widget.role == Role.brand || widget.role == Role.agency) &&
              inquiry.status == InquiryStatus.offerSent) ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => context.push('/app/inquiries/${inquiry.id}/offer'),
                icon: const Icon(Icons.description_outlined),
                label: const Text('Pregled ponude'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
          if (widget.role == Role.admin) ...[
            _buildAdminNotesCard(inquiry),
            const SizedBox(height: AppSpacing.md),
            if (_isPdfAvailable(inquiry.status))
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _downloadPdf(inquiry),
                  icon: const Icon(Icons.picture_as_pdf),
                  label: Text(l10n.downloadPdf),
                ),
              ),
          ],
          if (_isInvoiceAvailable(inquiry.status)) ...[
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _downloadingInvoice ? null : () => _downloadInvoice(inquiry),
                icon: _downloadingInvoice
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.receipt_long),
                label: const Text('Skini fakturu'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  bool _isInvoiceAvailable(InquiryStatus status) {
    return status == InquiryStatus.acceptedByClient ||
        status == InquiryStatus.realized ||
        status == InquiryStatus.closed;
  }

  Future<void> _downloadInvoice(Inquiry inquiry) async {
    if (_downloadingInvoice) return;
    setState(() => _downloadingInvoice = true);
    try {
      final repo = context.read<InquiryRepository>();
      final meta = await repo.getInvoiceForInquiry(inquiry.id);
      if (meta == null || meta['id'] == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Faktura još nije generisana')),
          );
        }
        return;
      }
      final invoiceId = meta['id'] as int;
      final bytes = await repo.downloadInvoicePdf(invoiceId);
      if (bytes == null) return;

      final base64Data = base64Encode(bytes);
      final dataUri = Uri.parse('data:application/pdf;base64,$base64Data');
      if (await canLaunchUrl(dataUri)) {
        await launchUrl(dataUri, mode: LaunchMode.externalApplication);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Faktura ${meta['invoiceNumber']} preuzeta')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Greška pri preuzimanju fakture: $e'),
            backgroundColor: AppColors.destructive,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _downloadingInvoice = false);
    }
  }

  Widget _buildHeaderCard(Inquiry inquiry) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Inquiry #${inquiry.id}',
                  style: AppTypography.h3.copyWith(
                    color: AppColors.foreground,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (inquiry.requesterType != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    inquiry.requesterType!,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.mutedForeground,
                    ),
                  ),
                ],
                if (inquiry.createdAt != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    inquiry.createdAt!,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.mutedForeground,
                    ),
                  ),
                ],
              ],
            ),
          ),
          InquiryStatusBadge(status: inquiry.status),
        ],
      ),
    );
  }

  Widget _buildContactCard(Inquiry inquiry) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.contactName,
            style: AppTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.foreground,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildInfoRow(Icons.person, l10n.contactName, inquiry.contactName ?? '—'),
          _buildInfoRow(Icons.email, l10n.contactEmail, inquiry.contactEmail ?? '—'),
          _buildInfoRow(Icons.phone, l10n.contactPhone, inquiry.contactPhone ?? '—'),
        ],
      ),
    );
  }

  Widget _buildCampaignCard(Inquiry inquiry) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.campaignBrief,
            style: AppTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.foreground,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            inquiry.campaignBrief ?? '—',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.foreground,
              height: 1.5,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: _buildInfoRow(
                  Icons.calendar_today,
                  l10n.startDate,
                  inquiry.startDate ?? '—',
                ),
              ),
              Expanded(
                child: _buildInfoRow(
                  Icons.calendar_today,
                  l10n.endDate,
                  inquiry.endDate ?? '—',
                ),
              ),
            ],
          ),
          if (inquiry.budget != null)
            _buildInfoRow(
              Icons.monetization_on,
              l10n.budget,
              '€${_priceFormatter.format(inquiry.budget)}',
            ),
        ],
      ),
    );
  }

  Widget _buildItemsCard(Inquiry inquiry) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${l10n.items} (${inquiry.items.length})',
            style: AppTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.foreground,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          ...inquiry.items.map((item) => _buildItemRow(inquiry, item)),
        ],
      ),
    );
  }

  Widget _buildItemRow(Inquiry inquiry, InquiryItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.muted,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(
        children: [
          Icon(Icons.inventory_2, size: 20, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.inventoryItemName ?? 'Item #${item.id}',
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w500,
                    color: AppColors.foreground,
                  ),
                ),
                if (item.mediaOwnerName != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Row(
                      children: [
                        Icon(Icons.business, size: 14, color: AppColors.mutedForeground),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            item.mediaOwnerName!,
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.mutedForeground,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                if (item.inventoryItemAddress != null || item.inventoryItemCity != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Row(
                      children: [
                        Icon(Icons.location_on, size: 14, color: AppColors.mutedForeground),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            [
                              if (item.inventoryItemAddress != null) item.inventoryItemAddress!,
                              if (item.inventoryItemCity != null) item.inventoryItemCity!,
                            ].join(', '),
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.mutedForeground,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                if (item.quotedPrice != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      '${l10n.quotedPrice}: \u20AC${_priceFormatter.format(item.quotedPrice)}',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (widget.role == Role.admin)
            IconButton(
              icon: Icon(Icons.edit, size: 18, color: AppColors.primary),
              onPressed: () => _showQuotedPriceDialog(inquiry.id, item),
              tooltip: l10n.updatePrice,
            ),
        ],
      ),
    );
  }

  Widget _buildAdminNotesCard(Inquiry inquiry) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.adminNotes,
            style: AppTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.foreground,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _notesController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: l10n.adminNotes,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: () {
                context.read<InquiryBloc>().add(
                      UpdateAdminNotes(
                        inquiry.id,
                        _notesController.text,
                        widget.role,
                      ),
                    );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.primaryForeground,
              ),
              child: Text(l10n.saveNotes),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.mutedForeground),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.mutedForeground,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.foreground,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showQuotedPriceDialog(int inquiryId, InquiryItem item) {
    final controller = TextEditingController(
      text: item.quotedPrice?.toStringAsFixed(2) ?? '',
    );

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.updatePrice),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: l10n.quotedPrice,
              prefixText: '€ ',
              border: const OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                final price = double.tryParse(controller.text);
                if (price != null) {
                  context.read<InquiryBloc>().add(
                        UpdateQuotedPrice(
                          inquiryId,
                          item.id,
                          price,
                          widget.role,
                        ),
                      );
                  Navigator.pop(dialogContext);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.primaryForeground,
              ),
              child: Text(l10n.save),
            ),
          ],
        );
      },
    );
  }
}
