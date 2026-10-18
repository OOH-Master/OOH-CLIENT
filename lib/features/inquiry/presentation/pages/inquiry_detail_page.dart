import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/sr_format.dart';
import '../../../../core/utils/sr_labels.dart';
import '../../../../core/widgets/ui/ui.dart';
import '../../../auth/domain/entities/role.dart';
import '../../../auth/presentation/blocs/auth_bloc.dart';
import '../../data/repository/inquiry_repository.dart';
import '../../domain/entities/currency_totals.dart';
import '../../domain/entities/inquiry.dart';
import '../blocs/inquiry_bloc.dart';
import '../utils/amount_input.dart';
import '../utils/inquiry_errors.dart';
import '../utils/pdf_opener.dart';
import '../widgets/inquiry_layout.dart';
import '../widgets/inquiry_progress.dart';
import '../widgets/inquiry_status_badge.dart';
import '../widgets/inquiry_unit_row.dart';
import '../widgets/pdf_download_button.dart';

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
      return InquiryScaffold(
        title: 'Upit',
        body: const EmptyState(
          icon: Icons.search_off_rounded,
          title: 'Upit nije pronađen',
          message: 'Adresa ne sadrži ispravan broj upita.',
        ),
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
  bool _downloadingInvoice = false;
  Inquiry? _last;

  bool get _isAdmin => widget.role == Role.admin;

  bool get _isClient => widget.role == Role.brand || widget.role == Role.agency;

  /// Brend i agencija dobijaju PDF svog upita u svakoj fazi (pregled upita, a
  /// posle i ponudu); stručnjak, kao i do sada, od slanja ponude.
  bool _isPdfAvailable(InquiryStatus status) {
    if (_isClient) return true;
    if (!_isAdmin) return false;
    return status == InquiryStatus.offerSent ||
        status == InquiryStatus.acceptedByClient ||
        status == InquiryStatus.rejectedByClient ||
        status == InquiryStatus.realized ||
        status == InquiryStatus.closed;
  }

  bool _isInvoiceAvailable(InquiryStatus status) {
    return status == InquiryStatus.acceptedByClient ||
        status == InquiryStatus.realized ||
        status == InquiryStatus.closed;
  }

  bool _canViewOffer(Inquiry inquiry) => _isClient && inquiry.status.hasOffer;

  void _reload() => context
      .read<InquiryBloc>()
      .add(LoadInquiryDetail(widget.inquiryId, widget.role));

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _downloadInvoice(Inquiry inquiry) async {
    if (_downloadingInvoice) return;
    setState(() => _downloadingInvoice = true);
    try {
      final repo = context.read<InquiryRepository>();
      final meta = await repo.getInvoiceForInquiry(inquiry.id);
      if (meta == null || meta['id'] == null) {
        if (mounted) {
          showInquirySnack(context, 'Faktura još nije generisana');
        }
        return;
      }
      final invoiceId = meta['id'] as int;
      final bytes = await repo.downloadInvoicePdf(invoiceId);
      if (bytes == null || bytes.isEmpty) return;

      final number = meta['invoiceNumber']?.toString() ?? '$invoiceId';
      final opened = await openPdfBytes(bytes, 'faktura-$number.pdf');
      if (mounted) {
        showInquirySnack(
          context,
          opened
              ? 'Faktura $number je preuzeta'
              : 'Otvaranje PDF-a nije podržano na ovom uređaju.',
          error: !opened,
        );
      }
    } catch (e) {
      if (mounted) {
        showInquirySnack(context, InquiryErrors.describe(e), error: true);
      }
    } finally {
      if (mounted) setState(() => _downloadingInvoice = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<InquiryBloc, InquiryState>(
      listener: (context, state) {
        if (state is InquiryActionSuccess) {
          showInquirySnack(context, state.message);
        }
        if (state is InquiryError && _last != null) {
          showInquirySnack(context, InquiryErrors.describe(state.message),
              error: true);
        }
      },
      builder: (context, state) {
        if (state is InquiryDetailLoaded) _last = state.inquiry;
        final inquiry = _last;

        final Widget body;
        if (inquiry == null) {
          body = state is InquiryError
              ? InquiryErrorView(error: state.message, onRetry: _reload)
              : const InquiryLoadingView();
        } else {
          if (_notesController.text.isEmpty && inquiry.adminNotes != null) {
            _notesController.text = inquiry.adminNotes!;
          }
          body = Column(
            children: [
              InquiryRefreshBar(visible: state is InquiryLoading),
              Expanded(child: _buildDetail(inquiry)),
            ],
          );
        }

        return InquiryScaffold(
          title: 'Upit #${widget.inquiryId}',
          appBarActions: [
            if (inquiry != null && _isPdfAvailable(inquiry.status))
              PdfDownloadButton(
                inquiryId: inquiry.id,
                role: widget.role,
                iconOnly: true,
              ),
          ],
          body: body,
        );
      },
    );
  }

  /// "Izbor površina, podnet 18.10.2026."; stručnjak vidi i klijenta:
  /// "Aurora Kozmetika d.o.o., izbor površina, podnet 18.10.2026."
  String _subtitle(Inquiry inquiry) {
    final client = !_isClient && (inquiry.clientName ?? '').isNotEmpty
        ? inquiry.clientName!
        : null;
    final type = SrLabels.inquiryType(inquiry.inquiryType);
    final parts = <String>[
      if (client != null) client,
      if (type.isNotEmpty) client == null ? type : type.toLowerCase(),
      if (inquiry.createdAt != null)
        'podnet ${SrFormat.date(inquiry.createdAt)}',
    ];
    return parts.join(', ');
  }

  Widget _buildDetail(Inquiry inquiry) {
    final wide = InquiryLayout.isWide(context);
    final offer = _canViewOffer(inquiry);

    final invoiceButton = _isInvoiceAvailable(inquiry.status)
        ? OutlinedButton.icon(
            onPressed:
                _downloadingInvoice ? null : () => _downloadInvoice(inquiry),
            icon: _downloadingInvoice
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.receipt_long_outlined, size: 19),
            label: const Text('Preuzmi fakturu'),
          )
        : null;

    final offerButton = FilledButton(
      onPressed: () =>
          context.push('/app/inquiries/${inquiry.id}/offer').then((_) {
        if (mounted) _reload();
      }),
      child: const Text('Pogledaj ponudu'),
    );

    final actions = <Widget>[
      InquiryStatusBadge(status: inquiry.status),
      if (wide && _isPdfAvailable(inquiry.status))
        PdfDownloadButton(inquiryId: inquiry.id, role: widget.role),
      if (invoiceButton != null) invoiceButton,
      if (wide && offer) offerButton,
    ];

    return LayoutBuilder(builder: (context, constraints) {
      final gutter = InquiryLayout.gutter(constraints.maxWidth, wide: wide);
      final contentWidth = constraints.maxWidth - 2 * gutter;
      final twoColumns = contentWidth >= 980;

      final progress = _ProgressCard(inquiry: inquiry);
      final facts = _FactsCard(inquiry: inquiry);
      final brief =
          _hasBriefData(inquiry) ? _BriefCard(inquiry: inquiry) : null;
      final items = _ItemsCard(
        inquiry: inquiry,
        isClient: _isClient,
        onEditPrice:
            _isAdmin ? (item) => _showQuotedPriceDialog(inquiry, item) : null,
      );
      final notes = _isAdmin ? _buildAdminNotesCard(inquiry) : null;

      final List<Widget> content;
      if (twoColumns) {
        content = [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [progress, const SizedBox(height: 20), items],
                ),
              ),
              const SizedBox(width: 24),
              SizedBox(
                width: 360,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    facts,
                    if (brief != null) ...[const SizedBox(height: 20), brief],
                    if (notes != null) ...[const SizedBox(height: 20), notes],
                  ],
                ),
              ),
            ],
          ),
        ];
      } else {
        content = [
          if (!wide && offer) ...[
            SizedBox(width: double.infinity, child: offerButton),
            const SizedBox(height: 16),
          ],
          progress,
          const SizedBox(height: 16),
          facts,
          if (brief != null) ...[const SizedBox(height: 16), brief],
          const SizedBox(height: 16),
          items,
          if (notes != null) ...[const SizedBox(height: 16), notes],
        ];
      }

      return ListView(
        padding: EdgeInsets.fromLTRB(gutter, 0, gutter, 40),
        children: [
          InquiryHeader(
            title: 'Upit #${inquiry.id}',
            subtitle: _subtitle(inquiry),
            showBack: true,
            actions: actions,
          ),
          ...content,
        ],
      );
    });
  }

  bool _hasBriefData(Inquiry inquiry) =>
      inquiry.isBrief ||
      (inquiry.campaignBrief ?? '').trim().isNotEmpty ||
      inquiry.targetCityNames.isNotEmpty ||
      inquiry.preferredMediaTypeNames.isNotEmpty;

  Widget _buildAdminNotesCard(Inquiry inquiry) {
    return SectionCard(
      title: 'Napomene stručnjaka',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _notesController,
            maxLines: 4,
            minLines: 3,
            decoration: const InputDecoration(
              hintText: 'Dogovor sa klijentom, napomene za vlasnike medija…',
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton(
              onPressed: () {
                context.read<InquiryBloc>().add(
                      UpdateAdminNotes(
                        inquiry.id,
                        _notesController.text,
                        widget.role,
                      ),
                    );
              },
              child: const Text('Sačuvaj napomene'),
            ),
          ),
        ],
      ),
    );
  }

  void _showQuotedPriceDialog(Inquiry inquiry, InquiryItem item) {
    final controller =
        TextEditingController(text: AmountInput.format(item.quotedPrice));
    final unit = item.summary;
    final currency = SrFormat.currencyLabel(item.priceCurrency);

    showDialog(
      context: context,
      builder: (dialogContext) {
        String? error;
        return StatefulBuilder(builder: (dialogContext, setDialogState) {
          void save() {
            final price = AmountInput.parse(controller.text);
            if (price == null || price < 0) {
              setDialogState(() => error = 'Unesite ispravan iznos');
              return;
            }
            context.read<InquiryBloc>().add(
                  UpdateQuotedPrice(inquiry.id, item.id, price, widget.role),
                );
            Navigator.pop(dialogContext);
          }

          return AlertDialog(
            title: const Text('Izmena cene'),
            content: SizedBox(
              width: 420,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  UnitLine(
                    imageUrl: unit.imageUrl,
                    digital: unit.isDigital,
                    code: unit.codeLabel,
                    title: unit.title,
                    subtitle: unit.location,
                    compact: true,
                    padding: const EdgeInsets.only(bottom: 16),
                  ),
                  TextField(
                    controller: controller,
                    autofocus: true,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    textAlign: TextAlign.right,
                    style: AppTypography.money,
                    onSubmitted: (_) => save(),
                    decoration: InputDecoration(
                      labelText: 'Cena za period kampanje',
                      suffixText: currency.isEmpty ? null : currency,
                      helperText: item.cyclesText.isEmpty
                          ? null
                          : 'Trajanje zakupa: ${item.cyclesText}',
                      errorText: error,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Otkaži'),
              ),
              FilledButton(onPressed: save, child: const Text('Sačuvaj')),
            ],
          );
        });
      },
    ).whenComplete(controller.dispose);
  }
}

/// Tok upita: koraci izvedeni iz statusa.
class _ProgressCard extends StatelessWidget {
  final Inquiry inquiry;

  const _ProgressCard({required this.inquiry});

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Tok upita',
      child: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: InquiryProgress(
          status: inquiry.status,
          brief: inquiry.isBrief,
          createdAt: inquiry.createdAt,
        ),
      ),
    );
  }
}

/// Osnovni podaci: period, budžet, tip, klijent i kontakt.
class _FactsCard extends StatelessWidget {
  final Inquiry inquiry;

  const _FactsCard({required this.inquiry});

  @override
  Widget build(BuildContext context) {
    final client = inquiry.clientName ?? '';
    final requester = SrLabels.requesterType(inquiry.requesterType);
    final noPeriod = inquiry.startDate == null && inquiry.endDate == null;

    final facts = <MetaItem>[
      MetaItem(
        label: 'Period kampanje',
        value: noPeriod
            ? 'Nije naveden'
            : SrFormat.period(inquiry.startDate, inquiry.endDate),
        note: noPeriod ? null : SrFormat.daysLabel(inquiry.days),
      ),
      MetaItem(
        label: 'Budžet',
        value: inquiry.budget == null
            ? 'Nije naveden'
            : SrFormat.money(inquiry.budget, 'EUR'),
        emphasize: inquiry.budget != null,
      ),
      if (SrLabels.inquiryType(inquiry.inquiryType).isNotEmpty)
        MetaItem(
          label: 'Tip upita',
          value: SrLabels.inquiryType(inquiry.inquiryType),
        ),
      if (client.isNotEmpty || requester.isNotEmpty)
        MetaItem(
          label: 'Klijent',
          value: client.isNotEmpty ? client : requester,
          note: client.isNotEmpty && requester.isNotEmpty ? requester : null,
        ),
      if ((inquiry.contactName ?? '').isNotEmpty)
        MetaItem(label: 'Kontakt osoba', value: inquiry.contactName!),
      if ((inquiry.contactEmail ?? '').isNotEmpty)
        MetaItem(label: 'Email', value: inquiry.contactEmail!),
      if ((inquiry.contactPhone ?? '').isNotEmpty)
        MetaItem(label: 'Telefon', value: inquiry.contactPhone!),
      if (inquiry.createdAt != null)
        MetaItem(label: 'Podnet', value: SrFormat.date(inquiry.createdAt)),
    ];

    return SectionCard(
      title: 'Podaci o upitu',
      child: LayoutBuilder(builder: (context, constraints) {
        final columns = constraints.maxWidth >= 480 ? 2 : 1;
        final itemWidth = (constraints.maxWidth - (columns - 1) * 20) / columns;
        return Wrap(
          spacing: 20,
          runSpacing: 16,
          children: [
            for (final fact in facts) SizedBox(width: itemWidth, child: fact),
          ],
        );
      }),
    );
  }
}

/// Brif kampanje: opis, ciljani gradovi, tipovi medija, publika i zahtevi.
class _BriefCard extends StatelessWidget {
  final Inquiry inquiry;

  const _BriefCard({required this.inquiry});

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(top: 16, bottom: 8),
        child: Text(text,
            style: AppTypography.labelMedium.copyWith(
                color: AppColors.mutedForeground, fontWeight: FontWeight.w600)),
      );

  @override
  Widget build(BuildContext context) {
    final brief = (inquiry.campaignBrief ?? '').trim();
    final paragraph = AppTypography.bodyMedium
        .copyWith(color: AppColors.foreground, height: 1.55);
    return SectionCard(
      title: inquiry.isBrief ? 'Brif kampanje' : 'Opis kampanje',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(brief.isEmpty ? 'Opis kampanje nije naveden.' : brief,
              style: brief.isEmpty
                  ? paragraph.copyWith(color: AppColors.mutedForeground)
                  : paragraph),
          if (inquiry.targetCityNames.isNotEmpty) ...[
            _label('Ciljani gradovi'),
            Text(inquiry.targetCityNames.join(', '), style: paragraph),
          ],
          if (inquiry.preferredMediaTypeNames.isNotEmpty) ...[
            _label('Tipovi medija'),
            Text(inquiry.preferredMediaTypeNames.join(', '), style: paragraph),
          ],
          if ((inquiry.targetAudience ?? '').isNotEmpty) ...[
            _label('Ciljna publika'),
            Text(inquiry.targetAudience!, style: paragraph),
          ],
          if ((inquiry.additionalRequirements ?? '').isNotEmpty) ...[
            _label('Dodatni zahtevi'),
            Text(inquiry.additionalRequirements!, style: paragraph),
          ],
        ],
      ),
    );
  }
}

/// Izabrane površine, grupisane po vlasniku medija, sa cenom za period.
class _ItemsCard extends StatelessWidget {
  final Inquiry inquiry;
  final bool isClient;
  final void Function(InquiryItem item)? onEditPrice;

  const _ItemsCard({
    required this.inquiry,
    required this.isClient,
    this.onEditPrice,
  });

  @override
  Widget build(BuildContext context) {
    final items = inquiry.items;
    if (items.isEmpty) {
      return SectionCard(
        title: 'Izabrane površine',
        child: const EmptyState(
          compact: true,
          icon: Icons.view_quilt_outlined,
          title: 'Površine još nisu dodeljene',
        ),
      );
    }

    // Grupe po vlasniku medija, redosledom prvog pojavljivanja.
    final groups = <String, List<InquiryItem>>{};
    for (final item in items) {
      groups.putIfAbsent(item.ownerName ?? '', () => []).add(item);
    }
    final cities = inquiry.unitCities.length;
    final owners = groups.keys.where((k) => k.isNotEmpty).length;
    final subtitle = [
      SrFormat.count(items.length, 'površina', 'površine', 'površina'),
      if (owners > 0)
        SrFormat.count(
            owners, 'vlasnik medija', 'vlasnika medija', 'vlasnika medija'),
      if (cities > 0) SrFormat.count(cities, 'grad', 'grada', 'gradova'),
    ].join(', ');

    final totals = inquiry.itemTotals;

    return SectionCard(
      title: 'Izabrane površine',
      subtitle: subtitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final entry in groups.entries) ...[
            if (entry.key != groups.keys.first)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Divider(),
              ),
            if (entry.key.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4, bottom: 4),
                child: OwnerGroupHeader(
                  name: entry.key,
                  countLabel: SrFormat.count(
                      entry.value.length, 'površina', 'površine', 'površina'),
                ),
              ),
            for (var i = 0; i < entry.value.length; i++) ...[
              if (i > 0) const Divider(color: AppColors.borderSoft),
              _ItemRow(item: entry.value[i], onEditPrice: onEditPrice),
            ],
          ],
          if (totals.isNotEmpty) ...[
            const Divider(),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text('Ukupno po stavkama',
                      style: AppTypography.labelLarge),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    for (final label in CurrencyTotals.labels(totals))
                      Text(label,
                          style: AppTypography.money.copyWith(fontSize: 18)),
                  ],
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _ItemRow extends StatelessWidget {
  final InquiryItem item;
  final void Function(InquiryItem item)? onEditPrice;

  const _ItemRow({required this.item, this.onEditPrice});

  @override
  Widget build(BuildContext context) {
    final price = item.quotedPrice;
    return InquiryUnitRow(
      unit: item.summary,
      trailing: (context, narrow) {
        final column = PriceColumn(
          amount: price == null
              ? 'Čeka cenu'
              : SrFormat.money(price, item.priceCurrency),
          caption: price == null ? null : item.cyclesText,
          muted: price == null,
        );
        final edit = onEditPrice == null
            ? null
            : IconButton(
                tooltip: 'Izmeni cenu',
                onPressed: () => onEditPrice!(item),
                icon: const Icon(Icons.edit_outlined,
                    size: 18, color: AppColors.primary),
              );
        return Row(
          mainAxisSize: narrow ? MainAxisSize.max : MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            column,
            if (edit != null) ...[const SizedBox(width: 4), edit],
          ],
        );
      },
    );
  }
}
