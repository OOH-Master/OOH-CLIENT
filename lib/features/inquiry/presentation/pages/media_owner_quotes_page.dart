import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_constants.dart';
import '../../../../core/theme/app_typography.dart';
import '../../data/repository/inquiry_repository.dart';
import '../blocs/inquiry_bloc.dart';

class MediaOwnerQuotesPage extends StatelessWidget {
  const MediaOwnerQuotesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => InquiryBloc(context.read<InquiryRepository>())
        ..add(LoadMediaOwnerQuotes()),
      child: const _MediaOwnerQuotesView(),
    );
  }
}

class _MediaOwnerQuotesView extends StatelessWidget {
  const _MediaOwnerQuotesView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Zahtevi za ponude'),
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
            context.read<InquiryBloc>().add(LoadMediaOwnerQuotes());
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

          if (state is MediaOwnerQuotesLoaded) {
            if (state.quotes.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.request_quote_outlined, size: 64, color: AppColors.mutedForeground),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Nema zahteva za ponude',
                      style: AppTypography.bodyMedium.copyWith(color: AppColors.mutedForeground),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<InquiryBloc>().add(LoadMediaOwnerQuotes());
              },
              child: ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.md),
                itemCount: state.quotes.length,
                separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
                itemBuilder: (context, index) {
                  final quote = state.quotes[index];
                  return _QuoteCard(quote: quote);
                },
              ),
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
                        context.read<InquiryBloc>().add(LoadMediaOwnerQuotes()),
                    child: Text(l10n.retry),
                  ),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _QuoteCard extends StatefulWidget {
  final QuoteData quote;

  const _QuoteCard({required this.quote});

  @override
  State<_QuoteCard> createState() => _QuoteCardState();
}

class _QuoteCardState extends State<_QuoteCard> {
  final Map<int, TextEditingController> _priceControllers = {};

  @override
  void initState() {
    super.initState();
    for (final item in widget.quote.items) {
      _priceControllers[item.id] = TextEditingController(
        text: item.price?.toString() ?? '',
      );
    }
  }

  @override
  void dispose() {
    for (final c in _priceControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  bool get _isEditable =>
      widget.quote.status == 'NEW' || widget.quote.status == 'IN_PROGRESS';

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(widget.quote.status);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Upit #${widget.quote.inquiryId}',
                  style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                ),
                child: Text(
                  widget.quote.status.replaceAll('_', ' '),
                  style: AppTypography.caption.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ...widget.quote.items.map((item) => _buildQuoteItemRow(item)),
          if (_isEditable) ...[
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _handleDecline(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.destructive,
                      side: BorderSide(color: AppColors.destructive),
                    ),
                    child: const Text('Odbij'),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _handleSubmit(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.primaryForeground,
                    ),
                    child: const Text('Posalji ponudu'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuoteItemRow(QuoteItemData item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              item.inventoryName ?? 'Stavka #${item.id}',
              style: AppTypography.bodySmall,
            ),
          ),
          if (_isEditable)
            SizedBox(
              width: 120,
              child: TextField(
                controller: _priceControllers[item.id],
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Cena',
                  prefixText: 'EUR ',
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.xs),
                  ),
                  isDense: true,
                ),
                style: AppTypography.bodySmall,
              ),
            )
          else
            Text(
              item.price != null ? 'EUR ${item.price!.toStringAsFixed(2)}' : '-',
              style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600),
            ),
        ],
      ),
    );
  }

  void _handleSubmit(BuildContext context) {
    // Update prices first
    for (final item in widget.quote.items) {
      final priceText = _priceControllers[item.id]?.text ?? '';
      final price = double.tryParse(priceText);
      if (price != null) {
        context.read<InquiryBloc>().add(
              UpdateQuoteItemPrice(widget.quote.id, item.id, price),
            );
      }
    }
    // Then submit
    context.read<InquiryBloc>().add(SubmitQuote(widget.quote.id));
  }

  void _handleDecline(BuildContext context) {
    context.read<InquiryBloc>().add(DeclineQuote(widget.quote.id));
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'NEW':
        return AppColors.info;
      case 'IN_PROGRESS':
        return AppColors.warning;
      case 'SUBMITTED':
        return AppColors.success;
      case 'DECLINED':
        return AppColors.destructive;
      default:
        return AppColors.mutedForeground;
    }
  }
}
