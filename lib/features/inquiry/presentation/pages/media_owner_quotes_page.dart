import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/sr_format.dart';
import '../../../../core/utils/sr_labels.dart';
import '../../../../core/widgets/ui/ui.dart';
import '../../data/repository/inquiry_repository.dart';
import '../../domain/entities/currency_totals.dart';
import '../blocs/inquiry_bloc.dart';
import '../utils/amount_input.dart';
import '../utils/inquiry_errors.dart';
import '../widgets/inquiry_layout.dart';
import '../widgets/inquiry_unit_row.dart';
import '../widgets/status_pills.dart';

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

class _MediaOwnerQuotesView extends StatefulWidget {
  const _MediaOwnerQuotesView();

  @override
  State<_MediaOwnerQuotesView> createState() => _MediaOwnerQuotesViewState();
}

class _MediaOwnerQuotesViewState extends State<_MediaOwnerQuotesView> {
  static const _title = 'Zahtevi za ponude';

  List<QuoteData>? _last;

  /// Zahtev koji se upravo šalje ili odbija.
  int? _busyQuoteId;

  void _reload() => context.read<InquiryBloc>().add(LoadMediaOwnerQuotes());

  /// Otvoreni zahtevi prvi, zatim poslati pa odbijeni; u grupi najnoviji prvi.
  List<QuoteData> _sorted(List<QuoteData> quotes) {
    int rank(QuoteData q) => q.isEditable
        ? 0
        : q.status == 'SUBMITTED'
            ? 1
            : 2;
    final list = [...quotes];
    list.sort((a, b) {
      final byRank = rank(a).compareTo(rank(b));
      if (byRank != 0) return byRank;
      final da = SrFormat.parseDate(a.createdAt);
      final db = SrFormat.parseDate(b.createdAt);
      if (da != null && db != null && da != db) return db.compareTo(da);
      return b.inquiryId.compareTo(a.inquiryId);
    });
    return list;
  }

  void _submit(QuoteData quote, Map<int, double> prices) {
    setState(() => _busyQuoteId = quote.id);
    context.read<InquiryBloc>().add(SubmitQuoteWithPrices(quote.id, prices));
  }

  Future<void> _decline(QuoteData quote) async {
    final client = quote.clientName;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Odbiti zahtev za ponudu?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                'Upit #${quote.inquiryId}${client == null ? '' : ', $client'}'),
            const SizedBox(height: 8),
            const Text('Odbijen zahtev se ne može ponovo otvoriti.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Otkaži'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.destructive,
              foregroundColor: Colors.white,
            ),
            child: const Text('Odbij'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _busyQuoteId = quote.id);
    context.read<InquiryBloc>().add(DeclineQuote(quote.id));
  }

  @override
  Widget build(BuildContext context) {
    return InquiryScaffold(
      title: _title,
      body: BlocConsumer<InquiryBloc, InquiryState>(
        listener: (context, state) {
          if (state is InquiryActionSuccess) {
            showInquirySnack(context, state.message, success: true);
            _reload();
          }
          if (state is InquiryError) {
            setState(() => _busyQuoteId = null);
            if (_last != null) {
              showInquirySnack(context, InquiryErrors.describe(state.message),
                  error: true);
            }
          }
          if (state is MediaOwnerQuotesLoaded) {
            setState(() => _busyQuoteId = null);
          }
        },
        builder: (context, state) {
          if (state is MediaOwnerQuotesLoaded) _last = _sorted(state.quotes);
          final quotes = _last;
          if (quotes == null) {
            if (state is InquiryError) {
              return InquiryErrorView(error: state.message, onRetry: _reload);
            }
            return const InquiryLoadingView();
          }
          return Column(
            children: [
              InquiryRefreshBar(visible: state is InquiryLoading),
              Expanded(child: _buildList(quotes)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildList(List<QuoteData> quotes) {
    final wide = InquiryLayout.isWide(context);
    return LayoutBuilder(builder: (context, constraints) {
      final gutter = InquiryLayout.gutter(constraints.maxWidth, wide: wide);
      return RefreshIndicator(
        onRefresh: () async => _reload(),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(gutter, 0, gutter, 40),
          children: [
            const InquiryHeader(title: _title),
            if (quotes.isEmpty)
              const EmptyState(
                icon: Icons.request_quote_outlined,
                title: 'Nema zahteva za ponude',
              )
            else ...[
              _SummaryChips(quotes: quotes),
              const SizedBox(height: 16),
              for (var i = 0; i < quotes.length; i++) ...[
                if (i > 0) const SizedBox(height: 16),
                _QuoteCard(
                  key: ValueKey(quotes[i].id),
                  quote: quotes[i],
                  busy: _busyQuoteId == quotes[i].id,
                  onSubmit: (prices) => _submit(quotes[i], prices),
                  onDecline: () => _decline(quotes[i]),
                ),
              ],
            ],
          ],
        ),
      );
    });
  }
}

/// Oznake sa brojem zahteva po grupi: "Novi 2", "Poslati 3", "Odbijeni 1".
class _SummaryChips extends StatelessWidget {
  final List<QuoteData> quotes;

  const _SummaryChips({required this.quotes});

  @override
  Widget build(BuildContext context) {
    final open = quotes.where((q) => q.isEditable).length;
    final sent = quotes.where((q) => q.status == 'SUBMITTED').length;
    final declined = quotes.where((q) => q.status == 'DECLINED').length;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        StatusPill(label: 'Novi $open', tone: PillTone.info),
        StatusPill(label: 'Poslati $sent', tone: PillTone.success),
        StatusPill(label: 'Odbijeni $declined', tone: PillTone.danger),
      ],
    );
  }
}

class _QuoteCard extends StatefulWidget {
  final QuoteData quote;
  final bool busy;
  final ValueChanged<Map<int, double>> onSubmit;
  final VoidCallback onDecline;

  const _QuoteCard({
    super.key,
    required this.quote,
    required this.busy,
    required this.onSubmit,
    required this.onDecline,
  });

  @override
  State<_QuoteCard> createState() => _QuoteCardState();
}

class _QuoteCardState extends State<_QuoteCard> {
  final Map<int, TextEditingController> _priceControllers = {};

  @override
  void initState() {
    super.initState();
    _syncControllers();
  }

  @override
  void didUpdateWidget(covariant _QuoteCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncControllers();
  }

  /// Polje za svaku stavku; već uneta vrednost se ne gazi pri osvežavanju.
  void _syncControllers() {
    for (final item in widget.quote.items) {
      _priceControllers.putIfAbsent(
        item.id,
        () => TextEditingController(text: AmountInput.format(item.price)),
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

  bool get _isEditable => widget.quote.isEditable;

  /// Zbir po valuti: dok vlasnik menja cene, iz polja; inače sa servera.
  Map<String, double> get _totals {
    if (!_isEditable) return widget.quote.totals;
    return CurrencyTotals.sum(
      widget.quote.items,
      (item) => AmountInput.parse(_priceControllers[item.id]?.text ?? ''),
      (item) => item.priceCurrency,
    );
  }

  void _handleSubmit() {
    final prices = <int, double>{};
    for (final item in widget.quote.items) {
      final price = AmountInput.parse(_priceControllers[item.id]?.text ?? '');
      if (price == null || price < 0) {
        showInquirySnack(context, 'Unesite cenu za svaku površinu pre slanja.',
            error: true);
        return;
      }
      prices[item.id] = price;
    }
    widget.onSubmit(prices);
  }

  @override
  Widget build(BuildContext context) {
    final quote = widget.quote;
    return SectionCard(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _QuoteHeader(quote: quote),
          const SizedBox(height: 12),
          const Divider(),
          if (quote.items.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text('Zahtev nema površina.',
                  style: AppTypography.bodySmall
                      .copyWith(color: AppColors.mutedForeground)),
            ),
          for (var i = 0; i < quote.items.length; i++) ...[
            if (i > 0) const Divider(color: AppColors.borderSoft),
            _QuoteItemRow(
              item: quote.items[i],
              controller:
                  _isEditable ? _priceControllers[quote.items[i].id] : null,
              enabled: !widget.busy,
              onChanged: () => setState(() {}),
            ),
          ],
          const Divider(),
          const SizedBox(height: 12),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    final quote = widget.quote;
    final totals = CurrencyTotals.labels(_totals);
    final total = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Ukupno',
            style: AppTypography.labelMedium
                .copyWith(color: AppColors.mutedForeground)),
        const SizedBox(height: 2),
        Wrap(
          spacing: 14,
          runSpacing: 2,
          children: [
            if (totals.isEmpty)
              Text('—', style: AppTypography.money.copyWith(fontSize: 20))
            else
              for (final t in totals)
                Text(t, style: AppTypography.money.copyWith(fontSize: 20)),
          ],
        ),
        if (quote.status == 'SUBMITTED' && quote.submittedAt != null) ...[
          const SizedBox(height: 2),
          Text('Cene poslate ${SrFormat.date(quote.submittedAt)}',
              style: AppTypography.caption
                  .copyWith(color: AppColors.mutedForeground)),
        ],
      ],
    );

    if (!_isEditable) return total;

    final decline = OutlinedButton(
      onPressed: widget.busy ? null : widget.onDecline,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.destructive,
        side: BorderSide(color: AppColors.destructive.withValues(alpha: 0.45)),
      ),
      child: const Text('Odbij'),
    );
    final submit = FilledButton.icon(
      onPressed: widget.busy ? null : _handleSubmit,
      icon: widget.busy
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: AppColors.subtle),
            )
          : const Icon(Icons.send_rounded, size: 18),
      label: const Text('Pošalji ponudu'),
    );

    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth < 520) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            total,
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(child: decline),
                const SizedBox(width: 12),
                Expanded(flex: 2, child: submit),
              ],
            ),
          ],
        );
      }
      return Row(
        children: [
          Expanded(child: total),
          const SizedBox(width: 16),
          decline,
          const SizedBox(width: 10),
          submit,
        ],
      );
    });
  }
}

/// Upit, klijent, period i status zahteva.
class _QuoteHeader extends StatelessWidget {
  final QuoteData quote;

  const _QuoteHeader({required this.quote});

  @override
  Widget build(BuildContext context) {
    final type = SrLabels.inquiryType(quote.inquiryType);
    final requester = SrLabels.requesterType(quote.requesterType).toLowerCase();
    final name = quote.clientName ?? '';
    // "Aurora Kozmetika d.o.o. (brend)"
    final client = name.isEmpty
        ? requester
        : (requester.isEmpty ? name : '$name ($requester)');
    final days = quote.days;
    // "16.11. – 29.11.2026. (14 dana)"
    final dates = SrFormat.period(quote.startDate, quote.endDate);
    final period = quote.startDate == null && quote.endDate == null
        ? null
        : (days == null ? dates : '$dates (${SrFormat.daysLabel(days)})');
    final contact =
        quote.contactName != null && quote.contactName != quote.requesterName
            ? quote.contactName
            : null;
    final muted =
        AppTypography.bodySmall.copyWith(color: AppColors.mutedForeground);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Wrap(
                spacing: 8,
                runSpacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text('Upit #${quote.inquiryId}', style: AppTypography.h5),
                  if (client.isNotEmpty)
                    Text(client,
                        style: AppTypography.labelLarge
                            .copyWith(color: AppColors.text2)),
                  if (type.isNotEmpty) SpecChip(label: type),
                ],
              ),
            ),
            const SizedBox(width: 12),
            QuoteStatusPill(status: quote.status),
          ],
        ),
        if (period != null || contact != null) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 24,
            runSpacing: 4,
            children: [
              if (period != null) Text(period, style: muted),
              if (contact != null) Text('Kontakt: $contact', style: muted),
            ],
          ),
        ],
        if ((quote.campaignBrief ?? '').isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            quote.campaignBrief!,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.bodySmall.copyWith(color: AppColors.text2),
          ),
        ],
      ],
    );
  }
}

/// Površina u zahtevu: polje za cenu dok je zahtev otvoren, inače cena.
class _QuoteItemRow extends StatelessWidget {
  final QuoteItemData item;
  final TextEditingController? controller;
  final bool enabled;
  final VoidCallback onChanged;

  const _QuoteItemRow({
    required this.item,
    required this.controller,
    required this.enabled,
    required this.onChanged,
  });

  /// "Cenovnik: 180 € za 4 nedelje" (cena iz cenovnika za ceo period).
  String _listHint() {
    final unit = item.summary;
    final cycles = SrFormat.cyclesLabel(item.cycles, item.effectiveCycleType);
    if (item.listPrice != null) {
      final price = SrFormat.money(item.listPrice, item.priceCurrency);
      return cycles.isEmpty
          ? 'Cenovnik: $price'
          : 'Cenovnik: $price za $cycles';
    }
    if (unit.pricePerCycle != null) {
      return 'Cenovnik: ${SrFormat.priceWithCycle(unit.pricePerCycle, unit.currency ?? item.priceCurrency, unit.cycleType ?? item.effectiveCycleType)}';
    }
    return 'Površina nema cenu u cenovniku';
  }

  @override
  Widget build(BuildContext context) {
    return InquiryUnitRow(
      unit: item.summary,
      stackBelow: 600,
      trailing: (context, narrow) {
        if (controller == null) {
          return PriceColumn(
            amount: item.price == null
                ? 'Bez cene'
                : SrFormat.money(item.price, item.priceCurrency),
            caption: SrFormat.cyclesLabel(item.cycles, item.effectiveCycleType),
            muted: item.price == null,
          );
        }
        final currency = SrFormat.currencyLabel(item.priceCurrency);
        final field = SizedBox(
          width: 150,
          child: TextField(
            controller: controller,
            enabled: enabled,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textAlign: TextAlign.right,
            style: AppTypography.money.copyWith(fontSize: 15),
            onChanged: (_) => onChanged(),
            decoration: InputDecoration(
              isDense: true,
              hintText: 'Cena',
              suffixText: currency.isEmpty ? null : currency,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            ),
          ),
        );
        final hint = Text(
          _listHint(),
          textAlign: narrow ? TextAlign.left : TextAlign.right,
          style:
              AppTypography.caption.copyWith(color: AppColors.mutedForeground),
        );
        if (narrow) {
          return Row(
            children: [
              Expanded(child: hint),
              const SizedBox(width: 12),
              field,
            ],
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            field,
            const SizedBox(height: 4),
            ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 220), child: hint),
          ],
        );
      },
    );
  }
}
